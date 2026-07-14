#!/bin/bash
# SpecSwarm Go-Loop Stop Hook (v7.17.0 — AUTO-MAGIC WS9)
#
# Drives the /ss:go full ladder:
#   specify → clarify (assume-first + assumptions review) → decisions →
#   plan → tasks → implement (preflight + slice gates + verify drain) →
#   retrospective → done (ship blessing)
#
# Separate from stop-hook.sh by design (epic decision D2): /ss:build and its
# state machine are untouched. This hook keys EXCLUSIVELY on
# .specswarm/go-loop.state and is a silent zero-overhead approve otherwise.
#
# Human touchpoints are NOT hook pauses — they happen in-turn via
# AskUserQuestion (assumptions review, decision sheet, sighted sign-off) and
# via the manual /ss:ship blessing at the end. The hook only advances phases
# whose artifacts prove completion.
#
# Output: always a single valid JSON object on stdout.

set -e

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
STATE_FILE="${REPO_ROOT}/.specswarm/go-loop.state"

# Zero overhead when /ss:go is not active
if [ ! -f "$STATE_FILE" ]; then
  echo '{"decision": "approve"}'
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo '{"decision": "approve", "reason": "jq not available - go-loop hook disabled"}'
  exit 0
fi

ACTIVE=$(jq -r '.active' "$STATE_FILE" 2>/dev/null || echo "false")
if [ "$ACTIVE" != "true" ]; then
  echo '{"decision": "approve"}'
  exit 0
fi

CURRENT_PHASE=$(jq -r '.current_phase' "$STATE_FILE")
FEATURE_DESC=$(jq -r '.feature_description' "$STATE_FILE")
FEATURE_NUM=$(jq -r '.feature_num' "$STATE_FILE")

FEATURES_DIR="${REPO_ROOT}/.specswarm/features"
[ -d "$FEATURES_DIR" ] || FEATURES_DIR="${REPO_ROOT}/features"
FEATURE_DIR=$(find "$FEATURES_DIR" -maxdepth 1 -type d -name "${FEATURE_NUM}-*" 2>/dev/null | head -1)

# Early phases: feature dir may not exist yet — stay put
if [ -z "$FEATURE_DIR" ] || [ ! -d "$FEATURE_DIR" ]; then
  echo '{"decision": "approve"}'
  exit 0
fi

NEXT_PHASE=""
NEXT_PROMPT=""

case "$CURRENT_PHASE" in
  "specify")
    if [ -f "${FEATURE_DIR}/spec.md" ]; then
      NEXT_PHASE="clarify"
      NEXT_PROMPT="Run /ss:clarify (assume-first: auto-fill gaps from taste model / corpus / codebase precedent into the ## Assumptions ledger; batch only genuine forks). Afterwards, present the full assumptions ledger to the user and capture confirm/override with ONE AskUserQuestion pass — this is the assumptions-review touchpoint. Distill any overrides into the taste model."
    fi
    ;;

  "clarify")
    # Assume-first clarify done when the spec carries structured assumptions
    # or a Clarifications section (either proves the pass ran)
    if grep -qE '^[[:space:]]*-[[:space:]]+A[0-9]+:' "${FEATURE_DIR}/spec.md" 2>/dev/null \
       || grep -q "## Clarifications" "${FEATURE_DIR}/spec.md" 2>/dev/null; then
      NEXT_PHASE="decisions"
      NEXT_PROMPT="Run /ss:plan to produce plan.md, then run /ss:decisions ${FEATURE_NUM} — the batched decision sheet is the second human touchpoint; keep it to one or two AskUserQuestion calls."
    fi
    ;;

  "decisions")
    # plan.md + a locked decision sheet (or an explicitly-empty one)
    if [ -f "${FEATURE_DIR}/plan.md" ] && \
       { grep -q 'status: locked' "${FEATURE_DIR}/decision-sheet.md" 2>/dev/null \
         || grep -q 'decision_count: 0' "${FEATURE_DIR}/decision-sheet.md" 2>/dev/null; }; then
      NEXT_PHASE="tasks"
      NEXT_PROMPT="Run /ss:tasks to generate the dependency-ordered tasks.md (canonical '- [ ] T###' checkboxes)."
    fi
    ;;

  "tasks")
    if [ -f "${FEATURE_DIR}/tasks.md" ]; then
      NEXT_PHASE="implement"
      NEXT_PROMPT="Run /ss:preflight ${FEATURE_NUM} first (any FAIL → fix before proceeding). Then run /ss:implement — slice gates are active (build+lint per task) and the verify queue drains at the end. Do not pause for anything except a sighted sign-off if one is requested."
    fi
    ;;

  "implement")
    # Done when tasks.md has canonical checkboxes, none unchecked, and the
    # verify queue has no pending markers.
    TASKS_MD="${FEATURE_DIR}/tasks.md"
    # grep -c prints 0 AND exits 1 on no-match — never `|| echo 0` after it
    TOTAL=$(grep -cE '^[[:space:]]*-[[:space:]]+\[[ xX]\][[:space:]]+T[0-9]+' "$TASKS_MD" 2>/dev/null || true)
    UNCHECKED=$(grep -cE '^[[:space:]]*-[[:space:]]+\[ \][[:space:]]+T[0-9]+' "$TASKS_MD" 2>/dev/null || true)
    TOTAL=${TOTAL:-0}
    UNCHECKED=${UNCHECKED:-0}
    PENDING=$(find "${REPO_ROOT}/.specswarm/verify-queue" -maxdepth 1 -type f -name '*.pending' 2>/dev/null | wc -l)
    if { [ "$TOTAL" -gt 0 ] && [ "$UNCHECKED" -eq 0 ] && [ "$PENDING" -eq 0 ]; } \
       || grep -q "All tasks completed" "$TASKS_MD" 2>/dev/null; then
      NEXT_PHASE="retrospective"
      NEXT_PROMPT="Run /ss:retrospective ${FEATURE_NUM} to distill this chunk's lessons into durable memory before ship."
    fi
    ;;

  "retrospective")
    # Last automated phase — one stop later, hand over to the ship blessing.
    NEEDS_SIGHTED=$(find "${REPO_ROOT}/.specswarm/verify-queue" -maxdepth 1 -type f -name '*.needs-sighted' 2>/dev/null | wc -l)
    FLAGGED=$(find "${REPO_ROOT}/.specswarm/verify-queue" -maxdepth 1 -type f -name '*.flagged' 2>/dev/null | wc -l)
    rm -f "$STATE_FILE"
    SIGHTED_NOTE=""
    [ "$NEEDS_SIGHTED" -gt 0 ] && SIGHTED_NOTE=" ${NEEDS_SIGHTED} task(s) need sighted sign-off (/ss:verify --sighted or the ship-time batch)."
    FLAG_NOTE=""
    [ "$FLAGGED" -gt 0 ] && FLAG_NOTE=" ${FLAGGED} flagged task(s) to review."
    jq -n \
      --arg desc "$FEATURE_DESC" \
      --arg extra "${SIGHTED_NOTE}${FLAG_NOTE}" \
      '{
        "decision": "approve",
        "reason": ("✅ /ss:go ladder complete: " + $desc + "\n\nRemaining human touchpoint: ship blessing — run /ss:ship when ready." + $extra),
        "systemMessage": "🏁 /ss:go complete — awaiting ship blessing (/ss:ship)"
      }'
    exit 0
    ;;

  *)
    echo '{"decision": "approve", "reason": "Unknown go-loop phase: '"$CURRENT_PHASE"'"}'
    exit 0
    ;;
esac

if [ -z "$NEXT_PHASE" ]; then
  echo '{"decision": "approve"}'
  exit 0
fi

jq --arg phase "$NEXT_PHASE" '.current_phase = $phase' "$STATE_FILE" > "${STATE_FILE}.tmp"
mv "${STATE_FILE}.tmp" "$STATE_FILE"

jq -n \
  --arg phase "$NEXT_PHASE" \
  --arg desc "$FEATURE_DESC" \
  --arg prompt "$NEXT_PROMPT" \
  '{
    "decision": "block",
    "reason": ("SpecSwarm /ss:go — " + $desc + "\n\n🔄 Next phase: " + $phase + "\n\n" + $prompt),
    "systemMessage": ("🔄 /ss:go phase: " + $phase)
  }'

exit 0
