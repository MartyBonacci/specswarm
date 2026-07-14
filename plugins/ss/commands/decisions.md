---
description: Pre-batch all strategic decisions for a feature into one AskUserQuestion-driven sheet, BEFORE /ss:tasks runs. Collapses the mid-chunk "wait, decide this" interrupts into a single front-loaded touchpoint. Hybrid deterministic-scan + decision-miner subagent; writes decision-sheet.md and appends a locked Pre-Batched Decisions section to plan.md.
effort: medium
args:
  - name: feature_num
    description: Feature number (e.g., 002). Defaults to current branch's feature, then latest feature dir.
    required: false
  - name: --scan-only
    description: Run only the deterministic scan and print candidates. Skip the agent + AskUserQuestion phases.
    required: false
  - name: --dry-run
    description: Run scan + agent (produces decision-sheet.draft.md) but skip AskUserQuestion and plan.md mutation.
    required: false
---

# SpecSwarm Decision Pre-Batching

The biggest Marty-time reducer in the v7.x toolchain. Mid-chunk strategic-decision interrupts cost ~15–25 interactions across `/ss:tasks` + `/ss:implement`. This command collapses them into ONE front-loaded touchpoint by:

1. Deterministically scanning `plan.md` for candidate decisions
2. Dispatching the `decision-miner` subagent to dedup/prioritize/polish into 0–8 well-formed questions
3. Asking Marty all of them via 1-2 `AskUserQuestion` calls (4-question limit per call)
4. Writing `decision-sheet.md` (canonical record + provenance)
5. Appending a "Pre-Batched Decisions" section to `plan.md` so `/ss:tasks` and `/ss:implement` see the answers without code changes

After this command runs successfully, the chunk should execute autonomously through `/ss:tasks` → `/ss:implement` with minimal further interrupts (only true edge cases the miner missed).

## Phase 1: Resolve feature

```bash
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/features-location.sh"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/decisions/scan-plan.sh"
# shellcheck disable=SC1091
[ -f "${PLUGIN_DIR}/lib/notify.sh" ] && source "${PLUGIN_DIR}/lib/notify.sh"

FEATURE_NUM=""
SCAN_ONLY=false
DRY_RUN=false

while [ $# -gt 0 ]; do
  case "$1" in
    --scan-only) SCAN_ONLY=true; shift ;;
    --dry-run)   DRY_RUN=true;   shift ;;
    -h|--help)
      cat <<EOF
Usage: /ss:decisions [FEATURE_NUM] [options]

Pre-batch strategic decisions for a feature.

Options:
  --scan-only   Print deterministic candidates only (no agent, no questions)
  --dry-run     Scan + agent (writes decision-sheet.draft.md); skip questions + plan.md mutation

Examples:
  /ss:decisions
  /ss:decisions 002
  /ss:decisions --scan-only
  /ss:decisions --dry-run
EOF
      exit 0
      ;;
    *)
      if [ -z "$FEATURE_NUM" ]; then FEATURE_NUM="$1"; fi
      shift
      ;;
  esac
done

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Resolve feature (same cascade as /ss:retrospective)
if [ -z "$FEATURE_NUM" ]; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  FEATURE_NUM=$(echo "$BRANCH" | grep -oE '^[0-9]{3}' || echo "")
fi
if [ -z "$FEATURE_NUM" ]; then
  get_features_dir "$REPO_ROOT"
  FEATURE_NUM=$(find "$FEATURES_DIR" -maxdepth 1 -type d -name '[0-9][0-9][0-9]-*' 2>/dev/null \
    | sort | tail -1 | xargs -n1 basename 2>/dev/null \
    | grep -oE '^[0-9]{3}' || echo "")
fi
if [ -z "$FEATURE_NUM" ]; then
  echo "❌ No feature number provided and no feature dirs found." >&2
  exit 2
fi
if ! find_feature_dir "$FEATURE_NUM" "$REPO_ROOT"; then
  echo "❌ Feature $FEATURE_NUM not found." >&2
  exit 2
fi
FEATURE_ID=$(basename "$FEATURE_DIR")
PLAN_PATH="${FEATURE_DIR}/plan.md"

if [ ! -f "$PLAN_PATH" ]; then
  echo "❌ plan.md not found at $PLAN_PATH. Run /ss:plan first." >&2
  exit 2
fi

FOUNDATION="${REPO_ROOT}/.specswarm"
TECH_STACK="${FOUNDATION}/tech-stack.md"
CONSTITUTION="${FOUNDATION}/constitution.md"
QUALITY_STANDARDS="${FOUNDATION}/quality-standards.md"

echo "🔍 Decisions for $FEATURE_ID"
echo "  plan.md:          $PLAN_PATH"
echo "  tech-stack.md:    $([ -f "$TECH_STACK" ] && echo "$TECH_STACK" || echo "(absent — version-anchor check skipped)")"
echo "  constitution:     $([ -f "$CONSTITUTION" ] && echo "$CONSTITUTION" || echo "(absent — constitution callout check skipped)")"
echo "  quality-standards:$([ -f "$QUALITY_STANDARDS" ] && echo " $QUALITY_STANDARDS" || echo " (absent — prior-commitments check skipped)")"
echo ""
```

## Phase 2: Deterministic scan

```bash
SCAN_OUTPUT=$(ss_scan_plan_decisions "$PLAN_PATH" "$FOUNDATION" 2>/dev/null || echo "")
CANDIDATE_COUNT=$(echo "$SCAN_OUTPUT" | grep -c . || echo 0)

echo "📊 Scan candidates: ${CANDIDATE_COUNT} signals across $(echo "$SCAN_OUTPUT" | cut -f1 | sort -u | wc -l) kind(s)"
echo ""
echo "$SCAN_OUTPUT" | cut -f1 | sort | uniq -c | sed 's/^/  /'
echo ""

if [ "$SCAN_ONLY" = true ]; then
  echo "─── --scan-only mode: printing candidates and exiting. ───"
  echo "$SCAN_OUTPUT" | awk -F'\t' '{printf "  [%s] line %s: %s\n", $1, $2, substr($3, 1, 100)}'
  exit 0
fi

if [ "$CANDIDATE_COUNT" -eq 0 ]; then
  echo "✅ No decision candidates detected. plan.md appears fully anchored."
  echo "   You can proceed directly to /ss:tasks → /ss:implement."
  exit 0
fi
```

## Phase 3: Stash context for the decision-miner agent

```bash
CONTEXT_DIR="${REPO_ROOT}/.specswarm/decisions"
mkdir -p "$CONTEXT_DIR"
CONTEXT_FILE="${CONTEXT_DIR}/${FEATURE_ID}.context"
DRAFT_PATH="${FEATURE_DIR}/decision-sheet.draft.md"

# Memory dir (best-effort, for agent reference)
MEM_DIR=""
if [ -f "${PLUGIN_DIR}/lib/intervention.sh" ]; then
  # shellcheck disable=SC1091
  source "${PLUGIN_DIR}/lib/intervention.sh"
  MEM_DIR=$(ss_intervention_dir 2>/dev/null || echo "")
fi

{
  echo "feature_id=${FEATURE_ID}"
  echo "plan_path=${PLAN_PATH}"
  echo "tech_stack_path=$([ -f "$TECH_STACK" ] && echo "$TECH_STACK" || echo "")"
  echo "constitution_path=$([ -f "$CONSTITUTION" ] && echo "$CONSTITUTION" || echo "")"
  echo "quality_standards_path=$([ -f "$QUALITY_STANDARDS" ] && echo "$QUALITY_STANDARDS" || echo "")"
  echo "output_path=${DRAFT_PATH}"
  echo "memory_dir=${MEM_DIR}"
  echo "candidates<<EOF_CANDIDATES"
  echo "$SCAN_OUTPUT"
  echo "EOF_CANDIDATES"
} > "$CONTEXT_FILE"

echo "📦 Context bundle: $CONTEXT_FILE"
echo "📝 Agent will write draft to: $DRAFT_PATH"
echo ""
```

## Phase 4: Dispatch decision-miner subagent

**Claude — perform this:**

1. Read `${CONTEXT_FILE}` to load the structured context (heredoc-delimited).
2. Dispatch a single Task call:
   ```
   Task(
     subagent_type: "decision-miner",
     description: "Mine decisions for <FEATURE_ID>",
     prompt: <<<END
   You are running decision mining for SpecSwarm feature <FEATURE_ID>.

   feature_id: <FEATURE_ID>
   plan_path: <PLAN_PATH>
   tech_stack_path: <TECH_STACK or empty>
   constitution_path: <CONSTITUTION or empty>
   quality_standards_path: <QUALITY_STANDARDS or empty>
   output_path: <DRAFT_PATH>
   memory_dir: <MEM_DIR>

   candidates (TSV from deterministic scanner — high recall, low precision):
   <SCAN_OUTPUT contents>

   Per your system prompt: triage each candidate against plan.md context,
   reject ones already-resolved, group related candidates, cap at 8, write
   decision-sheet.draft.md to <DRAFT_PATH>, and return:
   DECISIONS_WRITTEN, DRAFT_PATH, IMPACT_SPAN summary.
   END
   )
   ```
3. Parse the agent's return: `DECISIONS_WRITTEN: N` tells you how many decisions to ask.

## Phase 5: Honor --dry-run

```bash
if [ "$DRY_RUN" = true ]; then
  echo ""
  echo "─── --dry-run mode: agent has written ${DRAFT_PATH}. Skipping AskUserQuestion + plan.md mutation. ───"
  echo ""
  if [ -f "$DRAFT_PATH" ]; then
    echo "Draft preview (first 60 lines):"
    head -n 60 "$DRAFT_PATH"
  fi
  exit 0
fi
```

## Phase 6: Ask the user (Claude calls AskUserQuestion)

**Claude — for this phase:**

1. Read `${DRAFT_PATH}` and parse each `## D<N>: ...` section to extract its `header`, `question`, `options[]`, and `recommended`.
2. **Group decisions into batches of ≤4** (AskUserQuestion limit). 0 decisions → skip this phase. 1-4 → one call. 5-8 → two calls back-to-back.
3. For each batch, call `AskUserQuestion` with:
   - `questions[].question` ← the `**Question:**` text
   - `questions[].header` ← the `## D<N>:` tag (truncated to 12 chars)
   - `questions[].options[].label` ← the `Options:` labels
   - `questions[].options[].description` ← each option's description
   - If `**Recommended:**` is set, put that option FIRST and append "(Recommended)" to its label
4. Collect all answers (across however many calls) into a map `{tag → answer}`.

## Phase 7: Write the final decision-sheet + mutate plan.md

**Claude — after collecting answers:**

1. Write the canonical `${FEATURE_DIR}/decision-sheet.md` containing:
   ```yaml
   ---
   generated_at: <DRAFT generated_at>
   answered_at: <today's date>
   feature: <FEATURE_ID>
   status: locked
   decision_count: <N>
   ---

   # Decision Sheet — <N> decision(s) locked

   ## D1: <Tag>: <Selected Label>
   **Question:** <verbatim from draft>
   **Answer:** <selected label> — <selected description>
   **Notes:** <user's free-text notes if AskUserQuestion captured any>

   ---
   ## D2: ...
   ```
2. Append a single new section to `plan.md` (do NOT modify existing content):
   ```markdown

   ---

   ## Pre-Batched Decisions (locked <YYYY-MM-DD>)

   The following decisions were locked at chunk start via `/ss:decisions`. Subsequent `/ss:tasks` and `/ss:implement` work MUST apply these without re-asking.

   - **<Tag>:** <selected label> — <one-line summary>
   - **<Tag>:** <selected label> — ...

   See `./decision-sheet.md` for full provenance.
   ```
3. **Distill reusable rulings into the taste model (v7.13.0):** for each answered decision, classify it:
   - **Reusable ruling** — the answer expresses a policy/preference that will recur beyond this feature (naming standards, UX conventions, error-handling posture, tooling choices). Distill it:
     ```bash
     source "${PLUGIN_DIR}/lib/taste.sh"
     ss_taste_add "<kebab-slug>" "<deterministic|judgment>" \
       "AskUserQuestion /ss:decisions D<n> feature <FEATURE_ID>" \
       "<the rule>" "<why — what forced the decision>" "<how to apply next time>"
     ```
     `check-type`: `deterministic` if mechanically checkable (grep/glob/command), else `judgment`. Duplicates are skipped automatically. For `deterministic` rules, pass the optional 8th arg — a `<!-- specswarm-rule: ... -->` block (constitution grammar) — and the edit-time hook is generated immediately (v7.15.0).
   - **One-off scope choice** — specific to this feature → do NOT distill; decision-sheet.md records it.
   Report how many rulings were distilled (with entry names) in Phase 8's summary.
4. Delete the draft: `rm -f ${DRAFT_PATH}`.
5. Clean up the context bundle: `rm -f ${CONTEXT_FILE}`.

## Phase 8: Confirm + notify

```bash
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
[ -f "${PLUGIN_DIR}/lib/notify.sh" ] && source "${PLUGIN_DIR}/lib/notify.sh"

FEATURE_DIR_RESOLVED="<feature_dir from earlier>"  # Claude substitutes
FINAL_SHEET="${FEATURE_DIR_RESOLVED}/decision-sheet.md"

if [ -f "$FINAL_SHEET" ]; then
  DECISION_COUNT=$(grep -cE '^## D[0-9]+:' "$FINAL_SHEET" 2>/dev/null || echo 0)
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ Decision pre-batching complete"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  decisions locked:  $DECISION_COUNT"
  echo "  canonical record:  $FINAL_SHEET"
  echo "  plan.md updated:   Pre-Batched Decisions section appended"
  echo ""
  echo "Next: /ss:tasks (will read plan.md's Pre-Batched Decisions section)"

  if declare -f ss_notify >/dev/null 2>&1; then
    ss_notify success "SpecSwarm decisions locked" "${DECISION_COUNT} decision(s) for ${FEATURE_ID} — autonomous /ss:tasks unblocked" || true
  fi
fi
```

## How this fits with the v7 toolchain

The full chunk lifecycle with pre-batched decisions:

```
1. /ss:specify   — write spec.md
2. /ss:plan      — write plan.md (generates decision surface)
3. /ss:preflight — deterministic checks (v7.1.0)
4. /ss:decisions — pre-batch all strategic decisions  ← THIS COMMAND (v7.6.0)
5. /ss:tasks     — generate tasks.md (reads plan.md including Pre-Batched Decisions)
6. /ss:implement — write code (auto-queues verifications on T### checkbox flips, v7.4.0)
   ↳ During this phase: only true edge cases the miner missed should interrupt Marty
   ↳ Mid-chunk catches → /ss:intervention (v7.3.0)
7. /ss:verify    — adversarial spec-mentor per task (v7.4.0)
8. /ss:retrospective — distill chunk lessons to memory (v7.5.0)
9. /ss:ship      — squash merge + cleanup
```

With pre-batched decisions, steps 5-7 should run autonomously after step 4. That's the architectural win: Marty's path is collapsed from ~15-25 mid-chunk interrupts to ONE upfront batch + occasional intervention.

## Project-agnostic guarantees

- Feature resolution via `find_feature_dir` (no hardcoded paths)
- Foundation files auto-discovered at `.specswarm/{tech-stack,constitution}.md` — each scan kind skips silently when its file is absent
- Memory dir via existing v7.3.0 helpers (intervention.sh)
- AskUserQuestion handled by Claude (the slash command instructs; doesn't directly invoke)
- `--scan-only` and `--dry-run` available for inspection without token spend
- Zero decisions detected is a valid PASS — command exits cleanly with a "fully anchored" message
