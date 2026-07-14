---
description: The single default entry point (v7.17.0). Walks the full AUTO-MAGIC ladder — specify → assume-first clarify → plan → decisions → tasks → preflight → implement (slice gates + verify) → retrospective — pausing ONLY for the batched decision sheet, the assumptions review, sighted gates, and the ship blessing. Every phase command remains available as an escape hatch.
effort: high
args:
  - name: feature_description
    description: Natural-language description of the feature/chunk to build (reference your spec docs if you have them).
    required: true
  - name: --quality
    description: "Quality threshold hint recorded in state (informational; gates are enforced by implement/ship)."
    required: false
---

# SpecSwarm Go — the full ladder, ≤4 human touchpoints

**North star:** a small feature ships end-to-end with at most 4 human touchpoints — (1) this kickoff, (2) the assumptions review + batched decision sheet (back-to-back), (3) sighted gates on visual slices, (4) the ship blessing. Everything else runs itself. If you find yourself wanting to ask the user something outside those four, check the taste model and codebase precedent first (assume-with-provenance).

`/ss:build` is untouched and still works; `/ss:go` is the v7.17.0 ladder that includes the autonomous-loop phases (decisions, preflight, verify, retrospective) that build predates.

## Step 1: Kickoff — write the go-loop state

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/features-location.sh"

mkdir -p "${REPO_ROOT}/.specswarm"

# Refuse to stack loops
if [ -f "${REPO_ROOT}/.specswarm/go-loop.state" ] || [ -f "${REPO_ROOT}/.specswarm/build-loop.state" ]; then
  echo "❌ A build/go loop is already active. Finish it or remove the state file first."
  exit 1
fi

# Next feature number (mirrors /ss:build's convention)
get_features_dir "$REPO_ROOT"
LAST_NUM=$(list_features "$REPO_ROOT" 2>/dev/null | grep -oE '^[0-9]{3}' | sort -nr | head -1)
NEXT_NUM=$(printf '%03d' $(( ${LAST_NUM:-0} + 1 )))

jq -n \
  --arg desc "<feature_description>" \
  --arg num "$NEXT_NUM" \
  --arg started "$(date -Iseconds)" \
  '{
    active: true,
    feature_description: $desc,
    feature_num: $num,
    current_phase: "specify",
    started_at: $started
  }' > "${REPO_ROOT}/.specswarm/go-loop.state"

echo "🚀 /ss:go — feature ${NEXT_NUM}, ladder engaged (state: .specswarm/go-loop.state)"
```

## Step 2: Run the ladder

Use the SlashCommand tool to execute: `/ss:specify <feature_description>`

From here the **go-loop Stop hook** (`hooks/go-loop-hook.sh`) drives phase advancement — after each phase's artifacts land, it blocks the stop and feeds the next phase's instructions. The phases, in order, with their pause semantics:

| Phase | Command(s) | Pauses? |
|---|---|---|
| specify | `/ss:specify` | no — assumptions get `convention:` provenance, `[NEEDS CLARIFICATION]` markers flow to clarify |
| clarify | `/ss:clarify` (assume-first) | **yes — assumptions review**: present the `## Assumptions` ledger, ONE AskUserQuestion confirm/override pass; overrides distill to the taste model |
| decisions | `/ss:plan` then `/ss:decisions` | **yes — the batched decision sheet** (adjacent to the assumptions review: the two form one sitting) |
| tasks | `/ss:tasks` | no |
| implement | `/ss:preflight` then `/ss:implement` | no (slice gates run synchronously; verify queue drains; visual slices become NEEDS-SIGHTED, they do NOT pause implement) |
| retrospective | `/ss:retrospective` | no |
| done | — | **yes — ship blessing**: the hook hands over with "run `/ss:ship` when ready"; ship batch-reviews any NEEDS-SIGHTED items (**sighted gate** touchpoint) and requires your blessing for the merge |

Rules while the ladder runs:
- NEVER interrupt with an ad-hoc question the taste model or codebase precedent could answer — record an assumption with provenance instead.
- If something feels off mid-ladder, capture it with `/ss:intervention` (it does not pause the ladder).
- A preflight FAIL or slice-gate FAIL halts forward motion until fixed — that's the gate doing its job, not a touchpoint.

## Escape hatches

Every phase command works standalone (`/ss:specify`, `/ss:clarify`, `/ss:plan`, `/ss:decisions`, `/ss:tasks`, `/ss:preflight`, `/ss:implement`, `/ss:verify`, `/ss:retrospective`, `/ss:ship`). To abort the ladder: `rm .specswarm/go-loop.state` — nothing else needs cleanup; artifacts already written stay valid.
