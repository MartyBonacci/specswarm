#!/bin/bash
# SpecSwarm Verify Queue Prompt (v7.12.0)
#
# Stop hook. At every natural pause point (Claude finishes responding),
# checks .specswarm/verify-queue/ for pending verifications and emits a
# systemMessage prompting Claude (or the user) to run /ss:verify.
#
# v7.12.0: when the pending count exceeds SPECSWARM_VERIFY_QUEUE_LIST_MAX
# (default 8), emit a compact per-feature summary instead of one bullet
# per task — prevents the systemMessage from flooding the conversation
# on large queues. Set the env var very high to always force the full list.
#
# Silent when:
#   - No verify-queue directory exists
#   - No .pending files in the queue
#
# Does NOT block Claude — always returns decision=approve. The point is
# to surface the recommendation, not to gate further work.

set -e

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
QUEUE_DIR="${REPO_ROOT}/.specswarm/verify-queue"

# Threshold for full-list vs compact-summary mode.
LIST_MAX="${SPECSWARM_VERIFY_QUEUE_LIST_MAX:-8}"

if [ ! -d "$QUEUE_DIR" ]; then
  echo '{"decision": "approve"}'
  exit 0
fi

# Collect pending markers (sorted, deterministic)
PENDING_FILES=()
while IFS= read -r f; do
  [ -n "$f" ] && PENDING_FILES+=("$f")
done < <(find "$QUEUE_DIR" -maxdepth 1 -type f -name '*.pending' 2>/dev/null | sort)

COUNT="${#PENDING_FILES[@]}"

if [ "$COUNT" -eq 0 ]; then
  echo '{"decision": "approve"}'
  exit 0
fi

if [ "$COUNT" -le "$LIST_MAX" ]; then
  # Full per-task list (preserves pre-v7.12.0 behavior for small queues).
  ITEMS=()
  for f in "${PENDING_FILES[@]}"; do
    task_id=$(basename "$f" .pending)
    desc=$(grep -E '^task_desc=' "$f" 2>/dev/null | head -n1 | cut -d= -f2- | head -c 80)
    feature=$(grep -E '^feature_dir=' "$f" 2>/dev/null | head -n1 | cut -d= -f2- | xargs -n1 basename 2>/dev/null)
    if [ -n "$desc" ]; then
      ITEMS+=("${task_id} — ${desc}")
    else
      ITEMS+=("${task_id} (${feature})")
    fi
  done
  LIST=$(printf '  • %s\n' "${ITEMS[@]}")

  MSG="🔍 SpecSwarm verification queue: ${COUNT} task(s) pending adversarial review.
${LIST}
Recommended: run \`/ss:verify\` (or \`/ss:verify T###\` for a specific task) before /ss:ship.
Each pending task lives in .specswarm/verify-queue/<TaskID>.pending."
else
  # Compact summary: group by feature_dir basename, preserving first-seen order.
  declare -A FEATURE_COUNTS=()
  FEATURE_ORDER=()
  for f in "${PENDING_FILES[@]}"; do
    feature=$(grep -E '^feature_dir=' "$f" 2>/dev/null | head -n1 | cut -d= -f2- | xargs -n1 basename 2>/dev/null)
    [ -z "$feature" ] && feature="(unknown)"
    if [ -z "${FEATURE_COUNTS[$feature]:-}" ]; then
      FEATURE_ORDER+=("$feature")
      FEATURE_COUNTS[$feature]=1
    else
      FEATURE_COUNTS[$feature]=$(( FEATURE_COUNTS[$feature] + 1 ))
    fi
  done

  GROUP_LINES=()
  for feat in "${FEATURE_ORDER[@]}"; do
    GROUP_LINES+=("${feat}: ${FEATURE_COUNTS[$feat]}")
  done
  GROUPED=$(printf '  • %s\n' "${GROUP_LINES[@]}")

  MSG="🔍 SpecSwarm verification queue: ${COUNT} task(s) pending adversarial review.
${GROUPED}
Run \`/ss:verify\` to review (or \`/ss:verify T###\` for one) before /ss:ship. Details in .specswarm/verify-queue/."
fi

jq -n -c --arg msg "$MSG" '{decision: "approve", systemMessage: $msg}'
