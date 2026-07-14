#!/bin/bash
# SpecSwarm Preflight Check: assumptions-provenance (v7.13.0 — AUTO-MAGIC WS2)
#
# Verifies the feature spec's `## Assumptions` ledger: every structured entry
# (`- A<n>: ...`) must carry a provenance citation (`*source:*` with a
# taste:/corpus:/codebase:/convention: prefix) and a lifecycle status
# (`*status:*` auto-filled|confirmed|overridden).
#
# Origin lesson: assume-with-provenance beats ask — but ONLY if every
# assumption is traceable to what resolved it. An uncited assumption is just
# a guess wearing a ledger entry's clothes; reviewing it "like a diff" is
# impossible when there's nothing to check it against.
#
# Severity model:
#   - spec.md missing or no `## Assumptions` heading → PASS-skip (pre-v7.13
#     specs are legal; subsystem not configured)
#   - heading present, zero structured entries → WARN (applicable-but-empty,
#     v7.11.0 WARN-on-zero rule; legacy prose bullets also land here)
#   - structured entry missing source/status, or bad prefix/status value → FAIL
#
# Input:  $1 = absolute path to plan.md (spec.md is resolved as its sibling)
# Output: First line "PASS|WARN|FAIL <summary>", then indented details.

set -e

PLAN_PATH="${1:-}"
if [ -z "$PLAN_PATH" ] || [ ! -f "$PLAN_PATH" ]; then
  echo "FAIL assumptions-provenance: plan path missing or not found ($PLAN_PATH)"
  exit 2
fi

SPEC_PATH="$(dirname "$PLAN_PATH")/spec.md"

if [ ! -f "$SPEC_PATH" ]; then
  echo "PASS assumptions-provenance: skipped (no spec.md sibling to check)"
  exit 0
fi

if ! grep -qE '^## Assumptions' "$SPEC_PATH" 2>/dev/null; then
  echo "PASS assumptions-provenance: skipped (spec has no ## Assumptions section — pre-v7.13 spec)"
  exit 0
fi

# Extract the Assumptions section body (up to the next ## heading)
SECTION=$(awk '
  /^## Assumptions/ { insec = 1; next }
  insec && /^## /   { insec = 0 }
  insec             { print }
' "$SPEC_PATH")

# Structured entries: "- A<n>: ..." — ignore the template placeholder line
ENTRIES=$(echo "$SECTION" | grep -E '^[[:space:]]*-[[:space:]]+A[0-9]+:' | grep -vF '[assumption statement]' || true)

if [ -z "$ENTRIES" ]; then
  # WARN-on-zero (v7.11.0): the section exists (subsystem configured) but has
  # no structured entries. Either no assumptions were recorded, or legacy
  # prose bullets carry provenance nowhere a reviewer can audit.
  UNSTRUCTURED=$(echo "$SECTION" | grep -cE '^[[:space:]]*-[[:space:]]' || true)
  echo "WARN assumptions-provenance: ## Assumptions exists but has 0 structured A<n> entries (${UNSTRUCTURED} unstructured bullet(s)) — is this expected?"
  exit 1
fi

VALID_SOURCE='\*source:\*[[:space:]]*(taste|corpus|codebase|convention):'
VALID_STATUS='\*status:\*[[:space:]]*(auto-filled|confirmed|overridden)([[:space:]]|$)'

TOTAL=0
BAD=()
while IFS= read -r line; do
  [ -z "$line" ] && continue
  TOTAL=$((TOTAL + 1))
  id=$(echo "$line" | grep -oE 'A[0-9]+' | head -n1)
  if ! echo "$line" | grep -qE "$VALID_SOURCE"; then
    BAD+=("${id}: missing or invalid *source:* (need taste:/corpus:/codebase:/convention: citation)")
  elif ! echo "$line" | grep -qE "$VALID_STATUS"; then
    BAD+=("${id}: missing or invalid *status:* (need auto-filled|confirmed|overridden)")
  fi
done <<< "$ENTRIES"

if [ "${#BAD[@]}" -gt 0 ]; then
  echo "FAIL assumptions-provenance: ${#BAD[@]} of ${TOTAL} assumption(s) lack valid provenance"
  for b in "${BAD[@]}"; do
    echo "  🚫 ${b}"
  done
  echo "  Spec: ${SPEC_PATH}"
  exit 2
fi

UNREVIEWED=$(echo "$ENTRIES" | grep -cE '\*status:\*[[:space:]]*auto-filled' || true)
echo "PASS assumptions-provenance: ${TOTAL}/${TOTAL} assumption(s) provenance-cited (${UNREVIEWED} still auto-filled/unreviewed)"
exit 0
