#!/bin/bash
# SpecSwarm Overnight Autonomous Runner (v7.10.0)
#
# Invokable by cron / systemd / launchd / /schedule plugin. Runs a feature's
# /ss:preflight → /ss:implement → /ss:verify → /ss:retrospective chain
# autonomously via headless `claude --print`, with strict no-questions semantics
# (decisions must be pre-batched in decision-sheet.md).
#
# Usage:
#   run.sh <feature_num> [--timeout SECONDS] [--allow-dirty]
#
# Exit codes:
#   0   — success (full chain completed; commits may or may not have landed)
#   1   — preflight blocked (artifacts not ready)
#   2   — autonomous run errored or returned non-zero
#   3   — wall-clock timeout (SIGTERM'd the child)
#   4   — already running (PID file held by another process)
#
# Notifies via ss_notify on every terminal state.

set -e

PLUGIN_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.." && pwd)"

# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/features-location.sh"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/overnight/state.sh"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/overnight/preflight.sh"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/overnight/resilience.sh"
# shellcheck disable=SC1091
[ -f "${PLUGIN_DIR}/lib/notify.sh" ] && source "${PLUGIN_DIR}/lib/notify.sh"

# ─── Parse args ─────────────────────────────────────────────────────────────
FEATURE_NUM=""
TIMEOUT_SECONDS=$((8 * 3600))  # 8 hours default
ALLOW_DIRTY=false

while [ $# -gt 0 ]; do
  case "$1" in
    --timeout)     TIMEOUT_SECONDS="$2"; shift 2 ;;
    --allow-dirty) ALLOW_DIRTY=true;     shift ;;
    *)             [ -z "$FEATURE_NUM" ] && FEATURE_NUM="$1"; shift ;;
  esac
done

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

if [ -z "$FEATURE_NUM" ]; then
  # Auto-resolve: current branch NNN-slug
  BRANCH=$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  FEATURE_NUM=$(echo "$BRANCH" | grep -oE '^[0-9]{3}' || echo "")
fi

if [ -z "$FEATURE_NUM" ] || ! find_feature_dir "$FEATURE_NUM" "$REPO_ROOT"; then
  echo "❌ overnight: cannot resolve feature (got '$FEATURE_NUM')" >&2
  exit 1
fi
FEATURE_ID=$(basename "$FEATURE_DIR")

# ─── Acquire PID lock ───────────────────────────────────────────────────────
PID_FILE=$(ss_overnight_pid_file)
LOG_FILE=$(ss_overnight_log_file)

if ss_overnight_is_running; then
  EXISTING_PID=$(cat "$PID_FILE")
  echo "❌ overnight: already running (pid=${EXISTING_PID})" >&2
  exit 4
fi

echo "$$" > "$PID_FILE"
ss_overnight_state_init "$FEATURE_ID"
ss_overnight_rotate_log
ss_overnight_log "── overnight run start ─────────────────────────────"
ss_overnight_log "feature:  $FEATURE_ID"
ss_overnight_log "timeout:  ${TIMEOUT_SECONDS}s"
ss_overnight_log "pid:      $$"

# Cleanup hooks for every exit path
finalize() {
  local verdict="$1"
  local exit_code="$2"
  local notes="$3"
  local now
  now=$(date -Iseconds 2>/dev/null || date)
  ss_overnight_set finished_at "$now"
  ss_overnight_set exit_code "$exit_code"
  ss_overnight_set verdict "$verdict"
  ss_overnight_set notes "$notes"
  ss_overnight_log "── overnight run end (verdict=${verdict}, exit=${exit_code}) ─"
  rm -f "$PID_FILE" 2>/dev/null || true

  if declare -f ss_notify >/dev/null 2>&1; then
    case "$verdict" in
      success)
        ss_notify success "SpecSwarm overnight: $FEATURE_ID" "$notes" || true
        ;;
      blocked|aborted|timeout|partial)
        ss_notify urgent "SpecSwarm overnight: $FEATURE_ID ${verdict}" "$notes" || true
        ;;
    esac
  fi
}
trap 'finalize "aborted" 130 "interrupted by signal"' INT TERM

# ─── Phase 1: Preflight ─────────────────────────────────────────────────────
ss_overnight_log "running preflight (allow_dirty=${ALLOW_DIRTY})"
PREFLIGHT_OUTPUT=$(ss_overnight_preflight "$FEATURE_DIR" "$ALLOW_DIRTY" 2>&1 || true)
echo "$PREFLIGHT_OUTPUT" >> "$LOG_FILE"

if ! echo "$PREFLIGHT_OUTPUT" | grep -qE 'STATUS:[[:space:]]+✅|STATUS:[[:space:]]+⚠️'; then
  finalize blocked 1 "preflight blocked; see ${LOG_FILE}"
  exit 1
fi

# ─── Phase 2: Autonomous claude --print dispatch ────────────────────────────
START_COMMIT=$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || echo "")
ss_overnight_log "start commit: ${START_COMMIT:0:12}"
ss_overnight_log "dispatching headless claude --print (timeout ${TIMEOUT_SECONDS}s)"

# Prompt construction lives in lib/overnight/resilience.sh (v7.15.0) so the
# sync-gate + budget clauses are injected into every dispatch site and are
# unit-testable without running claude.
AUTONOMOUS_PROMPT=$(ss_overnight_build_prompt "$FEATURE_ID" "$FEATURE_DIR" "$FEATURE_NUM")

OVERNIGHT_OUTPUT_FILE="${FEATURE_DIR}/overnight.output.log"

# Use timeout(1) to enforce the wall-clock cap. claude --print reads stdin.
set +e
echo "$AUTONOMOUS_PROMPT" | timeout --signal=TERM "${TIMEOUT_SECONDS}s" claude --print \
  > "$OVERNIGHT_OUTPUT_FILE" 2>> "$LOG_FILE"
CLAUDE_EXIT=$?
set -e

ss_overnight_log "claude --print exited with code ${CLAUDE_EXIT}"

# ─── Phase 3: Classify result + bounded resume (v7.15.0 — AUTO-MAGIC WS6) ───
# Classification now inspects the WORKING TREE, not just the commit count —
# stranded uncommitted work is the primary signal of a mid-slice death.
classify_current() {
  END_COMMIT=$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || echo "")
  COMMITS_ADDED=$(git -C "$REPO_ROOT" rev-list --count "${START_COMMIT}..${END_COMMIT}" 2>/dev/null || echo 0)
  DIRTY_COUNT=$(git -C "$REPO_ROOT" status --porcelain 2>/dev/null | wc -l)
  MODE=$(ss_overnight_classify "$CLAUDE_EXIT" "$OVERNIGHT_OUTPUT_FILE" "$COMMITS_ADDED" "$DIRTY_COUNT")
  ss_overnight_log "end commit:   ${END_COMMIT:0:12} (${COMMITS_ADDED} new commit(s), ${DIRTY_COUNT} dirty path(s))"
  ss_overnight_log "classified:   ${MODE}"
}

classify_current

# One bounded resume attempt for the three recoverable failure modes.
# The resume prompt names the failure mode, points at the in-tree work, and
# orders a critical self-review of the half-done diff before completing +
# committing (this exact protocol recovered 3/3 real production failures).
if ss_overnight_is_resumable "$MODE"; then
  RESUME_TIMEOUT=$(( TIMEOUT_SECONDS / 4 ))
  [ "$RESUME_TIMEOUT" -lt 900 ] && RESUME_TIMEOUT=900
  RESUME_PROMPT_FILE="${FEATURE_DIR}/overnight-resume.prompt"
  ss_overnight_build_resume_prompt "$MODE" "$FEATURE_ID" "$FEATURE_DIR" "$FEATURE_NUM" "$DIRTY_COUNT" \
    > "$RESUME_PROMPT_FILE"
  ss_overnight_log "resume: mode=${MODE}; re-dispatching once (timeout ${RESUME_TIMEOUT}s); prompt at ${RESUME_PROMPT_FILE}"

  set +e
  timeout --signal=TERM "${RESUME_TIMEOUT}s" claude --print < "$RESUME_PROMPT_FILE" \
    >> "$OVERNIGHT_OUTPUT_FILE" 2>> "$LOG_FILE"
  CLAUDE_EXIT=$?
  set -e
  ss_overnight_log "resume claude --print exited with code ${CLAUDE_EXIT}"
  RESUMED_FROM="$MODE"
  classify_current
  MODE_NOTE="resumed after ${RESUMED_FROM}; final ${MODE}"
else
  MODE_NOTE="$MODE"
fi

case "$MODE" in
  success)
    RESULT_LINE=$(grep -E '^OVERNIGHT_RESULT:' "$OVERNIGHT_OUTPUT_FILE" 2>/dev/null | tail -n1)
    finalize success 0 "${COMMITS_ADDED} commit(s); ${MODE_NOTE}; $(echo "$RESULT_LINE" | sed -E 's/^OVERNIGHT_RESULT:[[:space:]]*//;s/^success[[:space:]]*//')"
    exit 0
    ;;
  partial)
    finalize partial 0 "${COMMITS_ADDED} commit(s); ${MODE_NOTE}; ${DIRTY_COUNT} dirty path(s); review output"
    exit 2
    ;;
  timeout|timeout-stranded)
    finalize timeout 3 "wall-clock timeout (${MODE_NOTE}); ${COMMITS_ADDED} commit(s), ${DIRTY_COUNT} dirty path(s)"
    exit 3
    ;;
  api-error)
    finalize aborted "$CLAUDE_EXIT" "claude --print exited ${CLAUDE_EXIT} (${MODE_NOTE}); ${COMMITS_ADDED} commit(s), ${DIRTY_COUNT} dirty path(s)"
    exit 2
    ;;
  yield-await|blocked|*)
    finalize blocked 0 "${MODE_NOTE}; ${COMMITS_ADDED} commit(s), ${DIRTY_COUNT} dirty path(s); review output"
    exit 2
    ;;
esac
