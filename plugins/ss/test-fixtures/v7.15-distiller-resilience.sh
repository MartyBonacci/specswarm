#!/bin/bash
# v7.15.0 ruling-distiller + overnight-resilience tests (AUTO-MAGIC WS3+WS6)
#
# Behaviors under test:
#   [A] ss_overnight_classify maps (exit code, output, commits, dirty) to the
#       correct failure-mode token for all three observed headless death modes.
#   [B] Prompt construction: sync-gate + budget clauses present in BOTH the
#       autonomous and resume prompts; resume prompt names the failure mode,
#       the in-tree work, and the critical-self-review order; is_resumable.
#   [C] Ruling distiller end-to-end: ss_taste_add with check-type=deterministic
#       + an embedded specswarm-rule block generates an edit-time hook that
#       FIRES on a violating file and stays silent on a clean one — chunk N's
#       ruling enforced in chunk N+1 with no /ss:init re-run.
#   [D] ss_taste_judgment_paths returns judgment entries only (spec-mentor's
#       memory feed excludes mechanically-enforced rules).
#
# Run:  bash plugins/ss/test-fixtures/v7.15-distiller-resilience.sh
# Exit: 0 if all pass, 1 otherwise

set -u

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RES_LIB="${PLUGIN_DIR}/lib/overnight/resilience.sh"
TASTE_LIB="${PLUGIN_DIR}/lib/taste.sh"

PASS=0
FAIL=0
ok()  { PASS=$((PASS+1)); echo "  ✅ $1"; }
bad() { FAIL=$((FAIL+1)); echo "  ❌ $1"; }

SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT

# shellcheck disable=SC1090
source "$RES_LIB"

OUT="${SCRATCH}/out.log"

echo "── [A] failure-mode classification ──"
echo "OVERNIGHT_RESULT: success all 12 tasks done" > "$OUT"
[ "$(ss_overnight_classify 0 "$OUT" 5 0)" = "success" ] && ok "A1: success line → success" || bad "A1"

echo "OVERNIGHT_RESULT: partial 8/12 done" > "$OUT"
[ "$(ss_overnight_classify 0 "$OUT" 3 0)" = "partial" ] && ok "A2: partial line → partial" || bad "A2"

printf 'lots of output\n%.0s' {1..50} > "$OUT"
[ "$(ss_overnight_classify 0 "$OUT" 2 0)" = "partial" ] && ok "A3: no line + commits → partial" || bad "A3"

[ "$(ss_overnight_classify 124 "$OUT" 1 4)" = "timeout-stranded" ] && ok "A4: timeout + dirty tree → timeout-stranded" || bad "A4"
[ "$(ss_overnight_classify 143 "$OUT" 1 0)" = "timeout" ] && ok "A5: timeout + clean tree → timeout" || bad "A5"
[ "$(ss_overnight_classify 1 "$OUT" 0 2)" = "api-error" ] && ok "A6: nonzero exit → api-error" || bad "A6"

# yield-await signatures: exit 0, zero commits, plus one of {dirty tree, tiny output, awaiting language}
printf 'I have started the test suite in the background and will report back once it completes.\nlots of padding here to exceed the small-output threshold. %.0s' {1..10} > "$OUT"
[ "$(ss_overnight_classify 0 "$OUT" 0 0)" = "yield-await" ] && ok "A7: 'background…report back' text → yield-await" || bad "A7"

printf 'x' > "$OUT"
[ "$(ss_overnight_classify 0 "$OUT" 0 0)" = "yield-await" ] && ok "A8: near-empty output → yield-await" || bad "A8"

printf 'Preflight FAILED on version-currency; stopping as instructed. This run is blocked and here is a long explanation of exactly why, with enough detail that the output is clearly a deliberate report rather than a truncated one. Nothing was started or left running.\n' > "$OUT"
[ "$(ss_overnight_classify 0 "$OUT" 0 0)" = "blocked" ] && ok "A9: deliberate stop report → blocked" || bad "A9: got $(ss_overnight_classify 0 "$OUT" 0 0)"

[ "$(ss_overnight_classify 0 "$OUT" 0 3)" = "yield-await" ] && ok "A10: dirty tree + zero commits → yield-await" || bad "A10"

echo "── [B] prompt construction ──"
P=$(ss_overnight_build_prompt "004-cart" "/repo/.specswarm/features/004-cart" "004")
echo "$P" | grep -q 'SYNCHRONOUSLY' && ok "B1: sync-gate clause in autonomous prompt" || bad "B1"
echo "$P" | grep -q 'honest partial' && echo "$P" | grep -q 'Never die' && ok "B2: budget clause in autonomous prompt" || bad "B2"
echo "$P" | grep -q 'Do NOT call AskUserQuestion' && ok "B3: strict rules preserved" || bad "B3"
echo "$P" | grep -q '/ss:preflight 004' && ok "B4: workflow preserved" || bad "B4"

R=$(ss_overnight_build_resume_prompt "yield-await" "004-cart" "/repo/.specswarm/features/004-cart" "004" 7)
echo "$R" | grep -q 'yield-await' && ok "B5: resume names the failure mode" || bad "B5"
echo "$R" | grep -q '7 uncommitted path' && ok "B6: resume points at in-tree work" || bad "B6"
echo "$R" | grep -qi 'CRITICALLY REVIEW' && ok "B7: resume orders critical self-review" || bad "B7"
echo "$R" | grep -q 'SYNCHRONOUSLY' && ok "B8: clauses re-injected in resume" || bad "B8"
echo "$R" | grep -q 'COMMIT' && ok "B9: resume orders complete + commit" || bad "B9"

ss_overnight_is_resumable "timeout-stranded" && ok "B10: timeout-stranded resumable" || bad "B10"
ss_overnight_is_resumable "api-error" && ok "B11: api-error resumable" || bad "B11"
ss_overnight_is_resumable "yield-await" && ok "B12: yield-await resumable" || bad "B12"
ss_overnight_is_resumable "blocked" && bad "B13: blocked wrongly resumable" || ok "B13: blocked not resumable"
ss_overnight_is_resumable "success" && bad "B14: success wrongly resumable" || ok "B14: success not resumable"

echo "── [C] distiller: ruling → hook that FIRES ──"
REPO="${SCRATCH}/distillville"
mkdir -p "$REPO"
git -C "$REPO" init -q

RULE_BLOCK='<!-- specswarm-rule: no-pattern -->
<!-- path-glob: src/*.js -->
<!-- bad-pattern: console\.log\( -->
<!-- summary: No console.log in production source -->
<!-- severity: warn -->'

(cd "$REPO" && bash -c 'source "$1"; ss_taste_add "no-console-log" deterministic "verify DRIFT T004" "Never leave console.log in production source." "It shipped debug noise twice." "Use the project logger." "" "$2"' _ "$TASTE_LIB" "$RULE_BLOCK" >/dev/null 2>&1)

ENTRY="${REPO}/.specswarm/memory/feedback_no_console_log.md"
[ -f "$ENTRY" ] && ok "C1: entry written" || bad "C1"
grep -q 'specswarm-rule: no-pattern' "$ENTRY" && ok "C2: rule block embedded in entry" || bad "C2"

HOOK=$(find "${REPO}/.specswarm/hooks/generated" -name '*.sh' 2>/dev/null | head -1)
[ -n "$HOOK" ] && ok "C3: edit-time hook generated immediately (no /ss:init)" || bad "C3: no hook"

if [ -n "$HOOK" ]; then
  mkdir -p "${REPO}/src"
  echo 'console.log("debug");' > "${REPO}/src/app.js"
  ERR=$( (cd "$REPO" && bash "$HOOK" "${REPO}/src/app.js") 2>&1 )
  echo "$ERR" | grep -q 'No console.log in production source' && ok "C4: hook FIRES on violating file" || bad "C4: silent ($ERR)"

  echo 'logger.info("fine");' > "${REPO}/src/clean.js"
  ERR=$( (cd "$REPO" && bash "$HOOK" "${REPO}/src/clean.js") 2>&1 )
  [ -z "$ERR" ] && ok "C5: hook silent on clean file" || bad "C5: false positive ($ERR)"
fi

echo "── [D] judgment-paths feed ──"
(cd "$REPO" && bash -c 'source "$1"; ss_taste_add "hover-states" judgment "sighted T012" "Hover states everywhere." "Dead UI feel." "Style interactive elements."' _ "$TASTE_LIB" >/dev/null 2>&1)
PATHS=$(cd "$REPO" && bash -c 'source "$1"; ss_taste_judgment_paths' _ "$TASTE_LIB")
echo "$PATHS" | grep -q 'feedback_hover_states.md' && ok "D1: judgment entry included" || bad "D1: $PATHS"
echo "$PATHS" | grep -q 'feedback_no_console_log.md' && bad "D2: deterministic entry leaked into judgment feed" || ok "D2: deterministic entry excluded"

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
if [ "$FAIL" -eq 0 ]; then
  exit 0
else
  exit 1
fi
