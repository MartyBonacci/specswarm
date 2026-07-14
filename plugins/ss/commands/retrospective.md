---
description: Auto-retrospective for a completed SpecSwarm feature/chunk. Gathers feature-scope signals (git log, tasks.md, verify-queue outcomes, captured interventions, MEMORY.md), dispatches the chunk-retrospective subagent, which writes 1-3 durable memory files capturing the chunk's lessons. Solves the "session memory dies when session ends" problem.
effort: medium
args:
  - name: feature_num
    description: Feature number to retrospect (e.g., 002). Defaults to the latest feature dir.
    required: false
  - name: --parent
    description: Override the parent branch for the commit range (defaults to .specswarm/build-loop.state parent_branch, then main, then master).
    required: false
  - name: --dry-run
    description: Gather signals and show what would be sent to the agent, but do not dispatch or write files.
    required: false
---

# SpecSwarm Chunk Retrospective

Auto-distills the lessons from a completed feature/chunk into 1–3 durable memory entries. Combats the failure mode where a Claude Code session ends and its accumulated wisdom (corrections, decisions, drifts caught) disappears — only memory files persist.

The subagent (`chunk-retrospective`) reads structured signals from the chunk and writes new `feedback_*.md` / `project_*.md` / `intervention_*.md` files directly to the project's memory directory. This command then updates `MEMORY.md` per file.

**Recommended workflow:** run this BEFORE `/ss:ship`, so the new memory files are part of the squash commit.

## Phase 1: Resolve feature + parent branch

```bash
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/features-location.sh"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/references-loader.sh"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/intervention.sh"
# shellcheck disable=SC1091
[ -f "${PLUGIN_DIR}/lib/notify.sh" ] && source "${PLUGIN_DIR}/lib/notify.sh"

# Parse args
FEATURE_NUM=""
PARENT_OVERRIDE=""
DRY_RUN=false

while [ $# -gt 0 ]; do
  case "$1" in
    --parent)  PARENT_OVERRIDE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true;          shift ;;
    -h|--help)
      cat <<EOF
Usage: /ss:retrospective [FEATURE_NUM] [options]

Auto-retrospective for a completed SpecSwarm feature.

Options:
  --parent BRANCH    Override parent branch (default: build-loop.state, then main/master)
  --dry-run          Show what would be sent to the agent; don't dispatch or write

Examples:
  /ss:retrospective
  /ss:retrospective 002
  /ss:retrospective --parent develop
  /ss:retrospective --dry-run
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

# Resolve feature
if [ -z "$FEATURE_NUM" ]; then
  # Try current branch (NNN-slug)
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  FEATURE_NUM=$(echo "$BRANCH" | grep -oE '^[0-9]{3}' || echo "")
fi

if [ -z "$FEATURE_NUM" ]; then
  # Fall back to latest feature dir
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
  echo "❌ Feature $FEATURE_NUM not found under $FEATURES_DIR" >&2
  exit 2
fi
FEATURE_ID=$(basename "$FEATURE_DIR")

# Resolve parent branch
PARENT_BRANCH="$PARENT_OVERRIDE"
if [ -z "$PARENT_BRANCH" ]; then
  STATE="${REPO_ROOT}/.specswarm/build-loop.state"
  if [ -f "$STATE" ]; then
    PARENT_BRANCH=$(grep -E '^parent_branch=' "$STATE" 2>/dev/null | head -n1 | cut -d= -f2- | tr -d '"' || echo "")
  fi
fi
if [ -z "$PARENT_BRANCH" ]; then
  for candidate in main master; do
    if git -C "$REPO_ROOT" rev-parse --verify "$candidate" >/dev/null 2>&1; then
      PARENT_BRANCH="$candidate"
      break
    fi
  done
fi
PARENT_BRANCH="${PARENT_BRANCH:-main}"

echo "🔍 Retrospective target"
echo "  feature:        $FEATURE_ID"
echo "  feature_dir:    $FEATURE_DIR"
echo "  parent_branch:  $PARENT_BRANCH"
echo ""
```

## Phase 2: Gather signals

```bash
# Commits on the feature branch since divergence from parent
MERGE_BASE=$(git -C "$REPO_ROOT" merge-base HEAD "$PARENT_BRANCH" 2>/dev/null || echo "")
if [ -n "$MERGE_BASE" ]; then
  COMMITS=$(git -C "$REPO_ROOT" log --no-merges --pretty='%h%n%s%n%b%n---END-COMMIT---' "${MERGE_BASE}..HEAD" 2>/dev/null | head -c 30000)
else
  COMMITS=""
fi

TASKS_MD="${FEATURE_DIR}/tasks.md"
[ -f "$TASKS_MD" ] || TASKS_MD=""

# Verify-queue outcomes
QUEUE_DIR="${REPO_ROOT}/.specswarm/verify-queue"
VERIFIED_LIST=""
FLAGGED_LIST=""
if [ -d "$QUEUE_DIR" ]; then
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    tid=$(basename "$f" .verified)
    VERIFIED_LIST="${VERIFIED_LIST}${tid}\n"
  done < <(find "$QUEUE_DIR" -maxdepth 1 -type f -name '*.verified' 2>/dev/null | sort)

  while IFS= read -r f; do
    [ -z "$f" ] && continue
    tid=$(basename "$f" .flagged)
    details=$(grep -E '^details=' "$f" 2>/dev/null | head -n1 | cut -d= -f2- | head -c 240)
    FLAGGED_LIST="${FLAGGED_LIST}${tid}: ${details}\n"
  done < <(find "$QUEUE_DIR" -maxdepth 1 -type f -name '*.flagged' 2>/dev/null | sort)
fi

# Memory dir + index + existing entries (description-only for dedup hints)
MEM_DIR=$(ss_intervention_dir 2>/dev/null || echo "")
MEM_INDEX=""
EXISTING_MEMORY_SUMMARY=""
if [ -n "$MEM_DIR" ] && [ -d "$MEM_DIR" ]; then
  if [ -f "${MEM_DIR}/MEMORY.md" ]; then
    MEM_INDEX="${MEM_DIR}/MEMORY.md"
  elif [ -f "$(dirname "$MEM_DIR")/MEMORY.md" ]; then
    MEM_INDEX="$(dirname "$MEM_DIR")/MEMORY.md"
  fi

  EXISTING_MEMORY_SUMMARY=$(find "$MEM_DIR" -maxdepth 1 -type f -name '*.md' 2>/dev/null | sort \
    | while IFS= read -r mf; do
        base=$(basename "$mf")
        [ "$base" = "MEMORY.md" ] && continue
        desc=$(grep -E '^description:' "$mf" 2>/dev/null | head -n1 | sed -E 's/^description:[[:space:]]*//' | head -c 140)
        echo "  - ${base}: ${desc}"
      done | head -c 8000)
fi

# Recent interventions tied to this feature (best-effort)
RECENT_INTERVENTIONS=""
if [ -n "$MEM_DIR" ]; then
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    # Filter to ones that mention this feature_id (best-effort)
    if grep -qF "$FEATURE_ID" "$f" 2>/dev/null; then
      RECENT_INTERVENTIONS="${RECENT_INTERVENTIONS}${f}\n"
    fi
  done < <(find "$MEM_DIR" -maxdepth 1 -type f -name 'intervention_*.md' 2>/dev/null | sort -r | head -n 20)
fi

echo "🧾 Signals gathered"
echo "  commits:                  $(echo "$COMMITS" | grep -c '^---END-COMMIT---$' || echo 0) commit(s)"
echo "  tasks.md:                 $([ -n "$TASKS_MD" ] && echo "present" || echo "absent")"
echo "  verified tasks:           $(echo -e "$VERIFIED_LIST" | grep -c . || echo 0)"
echo "  flagged tasks:            $(echo -e "$FLAGGED_LIST" | grep -c . || echo 0)"
echo "  recent interventions:     $(echo -e "$RECENT_INTERVENTIONS" | grep -c . || echo 0)"
echo "  memory_dir:               ${MEM_DIR:-(none)}"
echo "  memory_index:             ${MEM_INDEX:-(none)}"
echo "  existing memory files:    $(echo "$EXISTING_MEMORY_SUMMARY" | grep -c '^  -' || echo 0)"
echo ""

# Stash the context bundle for the agent
CONTEXT_DIR="${REPO_ROOT}/.specswarm/retrospective"
mkdir -p "$CONTEXT_DIR"
CONTEXT_FILE="${CONTEXT_DIR}/${FEATURE_ID}.context"

{
  echo "feature_id=${FEATURE_ID}"
  echo "feature_dir=${FEATURE_DIR}"
  echo "parent_branch=${PARENT_BRANCH}"
  echo "tasks_md_path=${TASKS_MD}"
  echo "memory_dir=${MEM_DIR}"
  echo "memory_index_path=${MEM_INDEX}"
  echo "verified_tasks<<EOF_V"
  echo -e "$VERIFIED_LIST"
  echo "EOF_V"
  echo "flagged_tasks<<EOF_F"
  echo -e "$FLAGGED_LIST"
  echo "EOF_F"
  echo "recent_interventions<<EOF_I"
  echo -e "$RECENT_INTERVENTIONS"
  echo "EOF_I"
  echo "existing_memory_summary<<EOF_M"
  echo "$EXISTING_MEMORY_SUMMARY"
  echo "EOF_M"
  echo "commits<<EOF_C"
  echo "$COMMITS"
  echo "EOF_C"
} > "$CONTEXT_FILE"

echo "📦 Context bundle written: $CONTEXT_FILE"
echo ""

if [ "$DRY_RUN" = true ]; then
  echo "─── DRY RUN: stopping here. Re-run without --dry-run to dispatch agent. ───"
  echo ""
  echo "First 60 lines of context:"
  head -n 60 "$CONTEXT_FILE"
  exit 0
fi
```

## Phase 3: Dispatch chunk-retrospective subagent

**Claude — now perform the following:**

1. Read `${REPO_ROOT}/.specswarm/retrospective/${FEATURE_ID}.context` to load the structured context bundle. Each field is heredoc-delimited (`EOF_V`, `EOF_F`, `EOF_I`, `EOF_M`, `EOF_C`).

2. Dispatch a single Task tool call:
   ```
   Task(
     subagent_type: "chunk-retrospective",
     description: "Retrospect feature <FEATURE_ID>",
     prompt: <<<END
   You are running a retrospective for SpecSwarm feature <FEATURE_ID>.

   Context bundle (from the calling /ss:retrospective command):

   feature_id: <FEATURE_ID>
   feature_dir: <FEATURE_DIR>
   parent_branch: <PARENT_BRANCH>
   tasks_md_path: <TASKS_MD>
   memory_dir: <MEM_DIR>
   memory_index_path: <MEM_INDEX>

   verified_tasks:
   <VERIFIED_LIST contents>

   flagged_tasks (DRIFT / NEEDS-MARTY with details):
   <FLAGGED_LIST contents>

   recent_interventions (already-captured intervention files for this feature):
   <RECENT_INTERVENTIONS — list of paths>

   existing_memory_summary (file: description — for dedup; do NOT duplicate these):
   <EXISTING_MEMORY_SUMMARY>

   commits (git log --no-merges <merge-base(HEAD, parent_branch)>..HEAD, %h\n%s\n%b\n---END-COMMIT---):
   <COMMITS>

   Per your system prompt:
   1. Read these signals carefully (commits + flagged_tasks first).
   2. Identify 1–3 durable lessons worth saving as memory.
   3. Classify each (feedback / project / intervention).
   4. Write each as a memory file directly via your Write tool to <MEM_DIR>.
   5. Return the structured RETROSPECTIVE SUMMARY format with FILES_WRITTEN, SOURCE_EVENTS, SKIPPED_DUPLICATES, NEXT_CHUNK_HEADS_UP sections.
   END
   )
   ```

3. Parse the agent's RETROSPECTIVE SUMMARY response. For each entry under `FILES_WRITTEN:`, extract `path`, `kind`, `name`, `description`.

## Phase 4: Update MEMORY.md per new file + cleanup

For each file the agent wrote (parsed from FILES_WRITTEN), run:

```bash
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/intervention.sh"

# Inputs from the agent's FILES_WRITTEN — Claude substitutes these
FILE_PATH="<absolute path of new memory file>"
FILE_DESC="<description from agent>"
FILE_NAME=$(basename "$FILE_PATH")

# Reuse the intervention helper — it appends under an appropriate index section
ss_intervention_index_update \
  "$(dirname "$FILE_PATH")" \
  "$FILE_NAME" \
  "$FILE_DESC"
```

Then:

```bash
# v7.15.0 (AUTO-MAGIC WS3): regenerate edit-time hooks from any deterministic
# feedback entries carrying embedded specswarm-rule blocks — the intervention
# captured in THIS chunk fires automatically in the NEXT chunk, no /ss:init
# re-run required.
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/taste.sh"
ss_taste_generate_hooks || true

# Cleanup the context bundle once the agent is done
rm -f "${REPO_ROOT}/.specswarm/retrospective/${FEATURE_ID}.context" 2>/dev/null

# Fire a success notification — Marty likes a ping when a retrospective ships memory entries
if declare -f ss_notify >/dev/null 2>&1; then
  COUNT=<number of FILES_WRITTEN from agent>
  if [ "$COUNT" -gt 0 ]; then
    ss_notify success "SpecSwarm retrospective complete" "${COUNT} memory file(s) written for ${FEATURE_ID}" || true
  fi
fi
```

## Phase 5: Final summary

Display:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SpecSwarm Retrospective Complete — <FEATURE_ID>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Memory files written:
  <list of paths>

📝 Source events:
  <list from agent>

⚠️  Heads-up for next chunk:
  <NEXT_CHUNK_HEADS_UP list, if any>

Recommended next step: /ss:ship (these memory files are part of the working tree
and will be included in the squash commit).
```

## How this fits with the v7 toolchain

| Stage | v7.x command | What it captures |
|---|---|---|
| Before implement | `/ss:preflight` (v7.1.0) | Deterministic plan.md checks |
| During implement | `tasks-completion-detector` (v7.4.0) | Auto-queues verifications on checkbox flip |
| At task completion | `/ss:verify` + spec-mentor (v7.4.0) | Adversarial PASS/DRIFT/NEEDS-MARTY |
| Mid-chunk catch | `/ss:intervention` (v7.3.0) | Marty captures "feels off" moments |
| Before ship | **`/ss:retrospective` (v7.5.0)** | **Synthesizes everything into durable memory** |
| Async signal | `ss_notify` (v7.2.0) | Phone/desktop ping on urgent events |

The retrospective consumes the outputs of every prior stage. If you've been running /ss:verify and /ss:intervention diligently, retrospective has rich signal. If you haven't, it falls back to git log + tasks.md.

## Project-agnostic guarantees

- Feature resolution via `find_feature_dir` (no hardcoded paths)
- Memory dir via the same 3-tier cascade as v7.3.0 (`references.md` → `<repo>/memory/` → `.specswarm/interventions/`)
- Parent branch auto-resolves from `build-loop.state` → `main` → `master`
- Skips silently if no git repo / no feature dir / no signals
- The agent works with partial signals (e.g., empty verify-queue is fine)
- Notifications fire only if `ss_notify` is wired (graceful degradation)
