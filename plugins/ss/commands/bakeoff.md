---
description: Calibration loop for taste-heavy choices (v7.16.0). Generates N candidate implementations/outputs, renders a side-by-side contact sheet, captures your verdict, pins the winner with a regression test, and distills the ruling into the taste model. Converts fuzzy judgment into deterministic constants.
effort: high
args:
  - name: description
    description: The taste-heavy choice to bake off (e.g., "hero section color palette", "product-card copy tone", "ranking weights for search").
    required: true
  - name: --candidates
    description: Number of candidates to generate (default 3, max 6).
    required: false
  - name: --feature
    description: Feature number to attach the bakeoff to. Defaults to the current branch's feature.
    required: false
---

# SpecSwarm Bakeoff

**Origin lesson:** run by hand ~15 times in production, this loop (candidates → contact sheet → human verdict → distilled ruling → pinned winner) was the single most effective pattern for converting fuzzy judgment into deterministic constants. Generic across domains: color pickers, copy tone, layout variants, ranking weights.

## Phase 1: Resolve context + workspace

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/features-location.sh"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/bakeoff.sh"

# Resolve feature dir (branch NNN-slug → --feature override → latest feature)
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
FEATURE_NUM="${FEATURE_OVERRIDE:-$(echo "$BRANCH" | grep -oE '^[0-9]{3}' || true)}"
[ -z "$FEATURE_NUM" ] && FEATURE_NUM=$(list_features "$REPO_ROOT" | grep -oE '^[0-9]{3}' | sort -nr | head -1)
find_feature_dir "$FEATURE_NUM" "$REPO_ROOT" || { echo "❌ no feature dir; run /ss:specify first (bakeoffs attach to a feature)"; exit 1; }

SLUG=$(ss_bakeoff_slug "<the user's description>")
BAKEOFF_DIR=$(ss_bakeoff_dir "$FEATURE_DIR" "$SLUG")
echo "🍞 Bakeoff workspace: ${BAKEOFF_DIR}"
```

`N` = `--candidates` (default 3, clamp to 2–6).

## Phase 2: Generate N candidates (parallel, deliberately diverse)

**Claude — dispatch N parallel Task subagents (`subagent_type: general-purpose`) in ONE message.** Each gets the same brief plus a DISTINCT angle so the candidates genuinely differ (not one idea ×N):

- Angle rotation (pick N): conservative/on-convention · bold/high-contrast · minimal · dense/information-rich · playful · borrowed-from-best-in-class.
- Each agent's brief:
  ```
  You are candidate <i> of <N> in a SpecSwarm bakeoff: <description>.
  Your angle: <angle>. Read the relevant project context (spec.md, existing code)
  but DO NOT modify project files. Write your candidate into
  <BAKEOFF_DIR>/candidate-<i>/ :
    - NOTES.md — 3-6 lines: your angle, the key choices, the constants you chose
    - the candidate artifact(s): code file(s), copy text, config/constants file —
      whatever form the choice takes. Self-contained; runnable/viewable in isolation
      where possible.
  Return one line: CANDIDATE <i> READY <one-line self-description>.
  ```
- Visual choices + browser MCP available: after the agents finish, render each candidate (dev server or static open) and save a screenshot as `candidate-<i>/preview.png` (read the browser console while you're there — console errors disqualify a candidate).

## Phase 3: Render the contact sheet

```bash
SHEET=$(ss_bakeoff_sheet "$BAKEOFF_DIR" "<description>")
echo "📇 Contact sheet: ${SHEET}"
```

Present the sheet to the user (open/summarize it — images embed if screenshots were captured; text/code candidates appear side-by-side in fenced blocks).

## Phase 4: Capture the verdict (ONE AskUserQuestion call)

- Q1 — header "Winner": "Which candidate wins <description>?" Options = one per candidate, label "Candidate <i>: <its self-description>", description = its key choices/constants. If the diff between two is the real question, say so in the descriptions.
- Q2 (optional, multiSelect) — header "Grafts": "Any elements to graft from the non-winners?" Options = one notable element per losing candidate.

The user's free-text notes (the "Other" path or annotations) are first-class verdict data — capture them verbatim in `${BAKEOFF_DIR}/verdict.md` (winner, grafts, notes, date).

## Phase 5: Pin the winner

1. Apply the winning candidate (plus grafts) to the actual codebase as a normal task-sized change.
2. **Pin with a regression test**: extract the winner's decisive constants/outputs (palette hex values, copy strings, weight vector, layout tokens) and write a test asserting them, with a comment pointing at `${BAKEOFF_DIR}/verdict.md` as the provenance. The test's job is to make the next refactor unable to silently un-decide this bakeoff.
3. Run the slice gates (v7.14.0) as usual.

## Phase 6: Distill the ruling

```bash
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/taste.sh"
ss_taste_add "<kebab-slug of the ruling>" judgment \
  "bakeoff ${SLUG} feature ${FEATURE_NUM}" \
  "<the generalizable rule the verdict expressed — not 'candidate 2 won' but WHY it won>" \
  "<why — cite the bakeoff and what the losers got wrong>" \
  "<how to apply to future work of this kind>"
```

If the verdict was purely instance-specific (no generalizable preference expressed), skip distillation and say so.

## Report

- Workspace + contact sheet + verdict paths
- Winner + grafts, pinned-test path
- Taste ruling distilled (entry name) or explicitly skipped
