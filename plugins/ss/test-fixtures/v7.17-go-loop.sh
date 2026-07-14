#!/bin/bash
# v7.17.0 /ss:go ladder tests (AUTO-MAGIC WS9)
#
# Behaviors under test (hooks/go-loop-hook.sh):
#   1. Zero-overhead approve when no go-loop.state exists (and always emits a
#      single valid JSON object — the v7.12 hook contract).
#   2. Phase machine advances on artifact evidence only:
#      specify→clarify (spec.md), clarify→decisions (A<n> entries or
#      Clarifications), decisions→tasks (plan.md + locked decision-sheet),
#      tasks→implement (tasks.md), implement→retrospective (all canonical
#      checkboxes done + verify queue drained), retrospective→done
#      (state deleted, ship-blessing handover, needs-sighted surfaced).
#   3. Stays put (approve) when the phase's artifact is missing — no
#      premature advancement.
#   4. /ss:build's state machine is untouched: go-loop hook ignores
#      build-loop.state entirely.
#
# Run:  bash plugins/ss/test-fixtures/v7.17-go-loop.sh
# Exit: 0 if all pass, 1 otherwise

set -u

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="${PLUGIN_DIR}/hooks/go-loop-hook.sh"

PASS=0
FAIL=0
ok()  { PASS=$((PASS+1)); echo "  ✅ $1"; }
bad() { FAIL=$((FAIL+1)); echo "  ❌ $1"; }

SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT

REPO="${SCRATCH}/gotown"
mkdir -p "$REPO"
git -C "$REPO" init -q
FEAT="${REPO}/.specswarm/features/009-go-test"
mkdir -p "$FEAT" "${REPO}/.specswarm/verify-queue"
STATE="${REPO}/.specswarm/go-loop.state"

set_state() { # $1=phase
  jq -n --arg p "$1" '{active: true, feature_description: "go test feature", feature_num: "009", current_phase: $p, started_at: "2026-07-13T00:00:00"}' > "$STATE"
}
run_hook() {
  OUT=$(cd "$REPO" && bash "$HOOK")
  echo "$OUT" | jq -e . >/dev/null 2>&1 || { bad "hook emitted invalid JSON: $OUT"; return 1; }
  DECISION=$(echo "$OUT" | jq -r '.decision')
}

echo "── [A] contract basics ──"
rm -f "$STATE"
run_hook && [ "$DECISION" = "approve" ] && ok "A1: no state → silent approve" || bad "A1"

jq -n '{active: true, current_phase: "implement", feature_num: "009", feature_description: "x"}' > "${REPO}/.specswarm/build-loop.state"
run_hook && [ "$DECISION" = "approve" ] && ok "A2: build-loop.state alone is ignored (build untouched)" || bad "A2"
rm -f "${REPO}/.specswarm/build-loop.state"

set_state "specify"
jq '.active = false' "$STATE" > "${STATE}.tmp" && mv "${STATE}.tmp" "$STATE"
run_hook && [ "$DECISION" = "approve" ] && ok "A3: inactive state → approve" || bad "A3"

echo "── [B] phase machine ──"
set_state "specify"
run_hook && [ "$DECISION" = "approve" ] && ok "B1: specify stays put without spec.md" || bad "B1"

echo "# Spec" > "${FEAT}/spec.md"
set_state "specify"
run_hook && [ "$DECISION" = "block" ] && [ "$(jq -r .current_phase "$STATE")" = "clarify" ] \
  && ok "B2: spec.md → advance to clarify (block)" || bad "B2: $DECISION/$(jq -r .current_phase "$STATE")"
echo "$OUT" | jq -r '.reason' | grep -q 'assumptions-review touchpoint' && ok "B3: clarify prompt includes assumptions review" || bad "B3"

set_state "clarify"
run_hook && [ "$DECISION" = "approve" ] && ok "B4: clarify stays put without assumptions" || bad "B4"
cat >> "${FEAT}/spec.md" <<'EOF'

## Assumptions
- A1: something — *source:* taste:x — *status:* auto-filled
EOF
set_state "clarify"
run_hook && [ "$(jq -r .current_phase "$STATE")" = "decisions" ] && ok "B5: structured assumptions → decisions" || bad "B5"

set_state "decisions"
run_hook && [ "$DECISION" = "approve" ] && ok "B6: decisions stays put without plan+locked sheet" || bad "B6"
echo "# Plan" > "${FEAT}/plan.md"
printf -- '---\nstatus: locked\ndecision_count: 3\n---\n' > "${FEAT}/decision-sheet.md"
set_state "decisions"
run_hook && [ "$(jq -r .current_phase "$STATE")" = "tasks" ] && ok "B7: plan + locked sheet → tasks" || bad "B7"

set_state "tasks"
run_hook && [ "$DECISION" = "approve" ] && ok "B8: tasks stays put without tasks.md" || bad "B8"
printf -- '- [ ] T001 first task\n- [ ] T002 second task\n' > "${FEAT}/tasks.md"
set_state "tasks"
run_hook && [ "$(jq -r .current_phase "$STATE")" = "implement" ] && ok "B9: tasks.md → implement" || bad "B9"
echo "$OUT" | jq -r '.reason' | grep -q '/ss:preflight 009' && ok "B10: implement prompt runs preflight first" || bad "B10"

set_state "implement"
run_hook && [ "$DECISION" = "approve" ] && ok "B11: implement stays put with unchecked tasks" || bad "B11"
printf -- '- [X] T001 first task\n- [x] T002 second task\n' > "${FEAT}/tasks.md"
touch "${REPO}/.specswarm/verify-queue/T001.pending"
set_state "implement"
run_hook && [ "$DECISION" = "approve" ] && ok "B12: implement stays put with pending verifications" || bad "B12"
rm -f "${REPO}/.specswarm/verify-queue/T001.pending"
set_state "implement"
run_hook && [ "$(jq -r .current_phase "$STATE")" = "retrospective" ] && ok "B13: all checked + queue drained → retrospective" || bad "B13"

touch "${REPO}/.specswarm/verify-queue/T002.needs-sighted"
set_state "retrospective"
run_hook && [ "$DECISION" = "approve" ] && ok "B14: retrospective → done (approve)" || bad "B14"
[ ! -f "$STATE" ] && ok "B15: state deleted at done" || bad "B15"
echo "$OUT" | jq -r '.reason' | grep -q '/ss:ship' && ok "B16: ship-blessing handover" || bad "B16"
echo "$OUT" | jq -r '.reason' | grep -q '1 task(s) need sighted sign-off' && ok "B17: needs-sighted surfaced in handover" || bad "B17"

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
if [ "$FAIL" -eq 0 ]; then
  exit 0
else
  exit 1
fi
