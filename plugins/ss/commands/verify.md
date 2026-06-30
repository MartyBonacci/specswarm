---
description: Adversarial spec-vs-implementation verification for a completed task. Dispatches the spec-mentor subagent with fresh context (no anchoring bias), parses its verdict (PASS / DRIFT / NEEDS-MARTY), and updates the verification queue. The v7.4.0 architectural replacement for a dedicated "mentor session."
effort: medium
args:
  - name: task_id
    description: Task to verify (e.g., T011). If omitted, processes the oldest pending verification.
    required: false
  - name: --all
    description: Process every pending verification in the queue.
    required: false
  - name: --drain
    description: Alias for --all. Drains every pending marker (used by /ss:implement at chunk end).
    required: false
  - name: --feature
    description: Override auto-detected feature number (e.g., --feature 002).
    required: false
  - name: --queue
    description: List the current queue (pending + verified + flagged counts).
    required: false
---

# SpecSwarm Spec-Mentor Verification

Runs adversarial verification on a completed task: dispatches a fresh `spec-mentor` subagent (no carried context, no anchoring bias) to compare what the spec says against what the code does, returns a structured verdict, and updates `.specswarm/verify-queue/`.

This is the architectural piece that replaces the dual mentor↔builder session pattern. Instead of a long-running mentor session catching drift, **a fresh subagent fires once per completed task** — better adversarial value, lower context cost, fully automatable.

## Phase 1: Resolve target task(s)

```bash
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/verify/queue.sh"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/verify/task-context.sh"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/references-loader.sh"
# shellcheck disable=SC1091
[ -f "${PLUGIN_DIR}/lib/notify.sh" ] && source "${PLUGIN_DIR}/lib/notify.sh"

# Parse arguments
TASK_ID=""
PROCESS_ALL=false
FEATURE_OVERRIDE=""
QUEUE_MODE=false

while [ $# -gt 0 ]; do
  case "$1" in
    --all|--drain) PROCESS_ALL=true; shift ;;
    --queue)   QUEUE_MODE=true;      shift ;;
    --feature) FEATURE_OVERRIDE="$2"; shift 2 ;;
    -h|--help)
      cat <<EOF
Usage: /ss:verify [TASK_ID] [options]

Adversarial spec-vs-implementation verification for completed task(s).

Options:
  --all              Process every pending task in the queue
  --drain            Alias for --all (drains the whole queue)
  --feature NUM      Override auto-detected feature number
  --queue            Show queue status (pending / verified / flagged counts)

Examples:
  /ss:verify T011
  /ss:verify --all
  /ss:verify --drain
  /ss:verify --queue
EOF
      exit 0
      ;;
    *)
      if [ -z "$TASK_ID" ]; then TASK_ID="$1"; fi
      shift
      ;;
  esac
done

# Queue overview mode — useful for "how many pending right now?"
if [ "$QUEUE_MODE" = true ]; then
  PENDING=$(ss_verify_queue_count pending)
  VERIFIED=$(ss_verify_queue_count verified)
  FLAGGED=$(ss_verify_queue_count flagged)
  echo "📋 SpecSwarm verification queue:"
  echo "  pending:  $PENDING"
  echo "  verified: $VERIFIED"
  echo "  flagged:  $FLAGGED"
  if [ "$PENDING" -gt 0 ]; then
    echo ""
    echo "Pending:"
    ss_verify_queue_list_pending | sed 's/^/  • /'
  fi
  if [ "$FLAGGED" -gt 0 ]; then
    echo ""
    echo "Flagged (need review):"
    find "$(ss_verify_queue_dir)" -maxdepth 1 -type f -name '*.flagged' \
      -exec basename {} \; 2>/dev/null | sed 's/\.flagged$//' | sed 's/^/  ⚠️  /'
  fi
  exit 0
fi

# Resolve target task list
TARGETS=()
if [ "$PROCESS_ALL" = true ]; then
  while IFS= read -r t; do
    [ -n "$t" ] && TARGETS+=("$t")
  done < <(ss_verify_queue_list_pending)
elif [ -n "$TASK_ID" ]; then
  TARGETS=("$TASK_ID")
else
  # Default: oldest pending
  OLDEST=$(ss_verify_queue_list_pending | head -n1)
  [ -n "$OLDEST" ] && TARGETS=("$OLDEST")
fi

if [ "${#TARGETS[@]}" -eq 0 ]; then
  echo "✅ No pending verifications. Queue is empty."
  exit 0
fi

echo "🔍 Verification targets: ${TARGETS[*]}"
echo ""
```

## Phase 2: Gather context for each target

For each target task, the bash below assembles the structured input the `spec-mentor` subagent needs. Claude then dispatches one Task tool call per target with `subagent_type=spec-mentor`.

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Resolve spec corpus paths once (project-agnostic via references.md)
CORPUS_PATHS=""
while IFS= read -r p; do
  [ -z "$p" ] && continue
  case "$p" in
    /*) ABS="$p" ;;
    *) ABS="${REPO_ROOT}/${p}" ;;
  esac
  CORPUS_PATHS="${CORPUS_PATHS}${ABS}\n"
done < <(ss_references_spec_corpus_paths 2>/dev/null)

# Per-target context bundle
for tid in "${TARGETS[@]}"; do
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Preparing verification context for ${tid}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Pull queue context
  QUEUE_DATA=$(ss_verify_queue_get "$tid" 2>/dev/null || echo "")
  if [ -z "$QUEUE_DATA" ]; then
    echo "⚠️  ${tid}: no .pending file in queue. Re-queue by toggling its checkbox, or run with --queue to see status."
    continue
  fi

  # Parse queue file
  FEATURE_DIR=$(echo "$QUEUE_DATA" | grep -E '^feature_dir=' | head -n1 | cut -d= -f2-)
  TASKS_MD=$(echo "$QUEUE_DATA" | grep -E '^tasks_md=' | head -n1 | cut -d= -f2-)
  TASK_DESC=$(echo "$QUEUE_DATA" | grep -E '^task_desc=' | head -n1 | cut -d= -f2-)
  REFS=$(echo "$QUEUE_DATA" | grep -E '^refs=' | head -n1 | cut -d= -f2-)

  # Pull the full task block from tasks.md
  TASK_BLOCK=$(ss_task_block "$TASKS_MD" "$tid" 2>/dev/null || echo "")

  # Compute the git diff for the task's work. Heuristic:
  #   - If the previous commit message contains the task ID, diff HEAD~1..HEAD
  #   - Otherwise, diff against HEAD (uncommitted working tree)
  DIFF_RANGE="HEAD"
  if git -C "$REPO_ROOT" log -1 --pretty='%B' 2>/dev/null | grep -qF "$tid"; then
    DIFF_RANGE="HEAD~1"
  fi
  DIFF=$(git -C "$REPO_ROOT" diff "$DIFF_RANGE" -- ':(exclude)*/tasks.md' 2>/dev/null | head -c 30000)

  # Stash the structured context so Claude can pass it verbatim to the subagent
  CONTEXT_FILE="${REPO_ROOT}/.specswarm/verify-queue/${tid}.context"
  {
    echo "task_id=${tid}"
    echo "feature_dir=${FEATURE_DIR}"
    echo "tasks_md=${TASKS_MD}"
    echo "task_desc=${TASK_DESC}"
    echo "refs=${REFS}"
    echo "diff_range=${DIFF_RANGE}"
    echo "spec_corpus_paths<<EOF_CORPUS"
    echo -e "$CORPUS_PATHS" | sed '/^$/d'
    echo "EOF_CORPUS"
    echo "task_block<<EOF_BLOCK"
    echo "$TASK_BLOCK"
    echo "EOF_BLOCK"
    echo "diff<<EOF_DIFF"
    echo "$DIFF"
    echo "EOF_DIFF"
  } > "$CONTEXT_FILE"

  echo "  ✓ Context written to: ${CONTEXT_FILE}"
  echo "  task_desc: ${TASK_DESC}"
  echo "  refs:      ${REFS:-(none)}"
  echo "  diff:      $(echo "$DIFF" | wc -l) lines, $(echo "$DIFF" | wc -c) chars"
  echo ""
done
```

## Phase 3: Dispatch spec-mentor for each target

For each target, Claude must dispatch ONE `Task` tool call with `subagent_type="spec-mentor"`. The prompt to the agent should bundle the context fields from the `.context` file written above.

**Claude — perform this for each target task in the TARGETS list:**

1. Read `${REPO_ROOT}/.specswarm/verify-queue/${tid}.context` to load the structured context bundle.
2. Dispatch a Task tool call:
   ```
   Task(
     subagent_type: "spec-mentor",
     description: "Verify task <tid>",
     prompt: <<<END
   You are verifying SpecSwarm task <tid>.

   Task block from tasks.md:
   <task_block>

   §refs in task description: <refs>
   Feature directory: <feature_dir>
   Spec corpus paths (one per line):
   <spec_corpus_paths>

   Git diff (range <diff_range>, excluding tasks.md):
   <diff>

   Read the referenced spec sections, read the changed files, and emit your
   verdict in the exact format from your system prompt (VERDICT / SUMMARY /
   CITATIONS / FINDINGS / RECOMMENDATIONS).
   END
   )
   ```
3. Parse the verdict from the agent's response:
   - VERDICT line: PASS / DRIFT / NEEDS-MARTY
   - SUMMARY line: one-line capture
   - Everything else: details for the user
4. Resolve the queue entry by running:
   ```bash
   source ${CLAUDE_PLUGIN_ROOT}/lib/verify/queue.sh
   ss_verify_queue_resolve <tid> <VERDICT> "<SUMMARY + key findings>"
   ```
5. On DRIFT or NEEDS-MARTY: fire `ss_notify urgent "SpecSwarm <tid> flagged" "<SUMMARY>"`.
6. Clean up the temporary context file: `rm -f ${REPO_ROOT}/.specswarm/verify-queue/${tid}.context`.

## Phase 4: Report

After all targets process, display a final summary:

```bash
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/verify/queue.sh"

PENDING=$(ss_verify_queue_count pending)
VERIFIED=$(ss_verify_queue_count verified)
FLAGGED=$(ss_verify_queue_count flagged)

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SpecSwarm verification complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  pending:  %d\n" "$PENDING"
printf "  verified: %d\n" "$VERIFIED"
printf "  flagged:  %d\n" "$FLAGGED"

if [ "$FLAGGED" -gt 0 ]; then
  echo ""
  echo "⚠️  Flagged tasks need review before /ss:ship:"
  find "$(ss_verify_queue_dir)" -maxdepth 1 -type f -name '*.flagged' 2>/dev/null \
    | while IFS= read -r f; do
        tid=$(basename "$f" .flagged)
        summary=$(grep -E '^details=' "$f" 2>/dev/null | head -n1 | cut -d= -f2- | head -c 120)
        echo "  • ${tid}: ${summary}"
      done
fi
```

## How auto-queue works (recap)

1. Claude edits `tasks.md` and ticks `- [X] T011`.
2. PostToolUse hook `tasks-completion-detector.sh` notices the checkbox flip, writes `.specswarm/verify-queue/T011.pending`, emits a one-line systemMessage.
3. At Claude's next Stop event, `verify-queue-prompt.sh` emits a reminder — a per-task bullet list when the queue is small (≤ `SPECSWARM_VERIFY_QUEUE_LIST_MAX`, default 8), or a compact per-feature summary when it's larger (v7.12.0).
4. User (or Claude responding to the reminder) invokes `/ss:verify T011` — and you're here.

## Project-agnostic guarantees

- Spec corpus discovered via `.specswarm/references.md` (no hardcoded paths)
- Auto-queue works for any project using SpecSwarm's canonical `- [ ] T###` tasks.md format
- Manual `/ss:verify T###` works for any format (even if auto-queue can't detect completion)
- Notifications fire only if a notify mechanism is available (graceful degradation)
- Silent no-op when verification queue is empty
