#!/bin/bash
# SpecSwarm v7.12.0 verify-queue-prompt threshold/summary test suite.
#
# Exercises the three documented behaviors of hooks/verify-queue-prompt.sh:
#   (a) 0 pending → silent {"decision":"approve"} (no systemMessage)
#   (b) <= LIST_MAX pending → full per-task bullet list (unchanged)
#   (c) > LIST_MAX pending → compact per-feature summary
#
# Each invocation must emit exactly ONE valid JSON object; we pipe stdout
# through `jq .` to prove it parses.
#
# Run:  bash plugins/ss/test-fixtures/v7.12-verify-queue-summary.sh
# Exit: 0 if all assertions pass, 1 otherwise.

set -u

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="${PLUGIN_DIR}/hooks/verify-queue-prompt.sh"
PASS=0
FAIL=0

ok()  { PASS=$((PASS+1)); echo "  ✅ $1"; }
bad() { FAIL=$((FAIL+1)); echo "  ❌ $1"; }

# make_pending <queue_dir> <task_id> <feature_basename> <desc>
make_pending() {
  local qdir="$1" tid="$2" feat="$3" desc="$4"
  cat > "${qdir}/${tid}.pending" <<EOF
task_id=${tid}
feature_dir=/fake/repo/.specswarm/features/${feat}
task_desc=${desc}
EOF
}

run_hook() {
  # cd into the fake repo root so the hook's `pwd` fallback kicks in
  # (git rev-parse will fail in a non-git dir, which we want).
  ( cd "$1" && bash "$HOOK" )
}

# ---------------------------------------------------------------------------
echo
echo "── Case (a): empty queue dir → silent approve ──────────────────────────"
TMP_A="$(mktemp -d)"
trap 'rm -rf "$TMP_A" "${TMP_B:-}" "${TMP_C:-}"' EXIT
mkdir -p "${TMP_A}/.specswarm/verify-queue"

OUT_A="$(run_hook "$TMP_A")"
echo "    raw: $OUT_A"

# Must be exactly one valid JSON object
if echo "$OUT_A" | jq -e . >/dev/null 2>&1; then
  ok "case (a) output parses as JSON"
else
  bad "case (a) output is not valid JSON"
fi

DECISION_A=$(echo "$OUT_A" | jq -r '.decision')
[ "$DECISION_A" = "approve" ] && ok "case (a) decision == approve" || bad "case (a) decision != approve (got '$DECISION_A')"

HAS_MSG_A=$(echo "$OUT_A" | jq -r 'has("systemMessage")')
[ "$HAS_MSG_A" = "false" ] && ok "case (a) systemMessage absent (silent)" || bad "case (a) emitted a systemMessage when it should have been silent"

# ---------------------------------------------------------------------------
echo
echo "── Case (b): 3 pending (<= 8 threshold) → full bullet list ─────────────"
TMP_B="$(mktemp -d)"
mkdir -p "${TMP_B}/.specswarm/verify-queue"
QDIR_B="${TMP_B}/.specswarm/verify-queue"
make_pending "$QDIR_B" T001 034-graphics-facilitator-pilot "Add facilitator_sessions Drizzle table for pilot mode"
make_pending "$QDIR_B" T002 034-graphics-facilitator-pilot "Generate + apply migration"
make_pending "$QDIR_B" T003 034-graphics-facilitator-pilot "Seed site_config.graphics_pilot"

OUT_B="$(run_hook "$TMP_B")"
echo "    raw: $OUT_B"

echo "$OUT_B" | jq -e . >/dev/null 2>&1 && ok "case (b) output parses as JSON" || bad "case (b) invalid JSON"

DECISION_B=$(echo "$OUT_B" | jq -r '.decision')
[ "$DECISION_B" = "approve" ] && ok "case (b) decision == approve" || bad "case (b) decision != approve"

MSG_B=$(echo "$OUT_B" | jq -r '.systemMessage')
echo "    systemMessage:"
echo "$MSG_B" | sed 's/^/      /'

echo "$MSG_B" | grep -q "3 task(s) pending" && ok "case (b) header shows correct count (3)" || bad "case (b) header count missing/wrong"
echo "$MSG_B" | grep -qE 'T001 — Add facilitator_sessions' && ok "case (b) T001 bullet present with desc" || bad "case (b) T001 bullet missing"
echo "$MSG_B" | grep -qE 'T002 — Generate \+ apply migration' && ok "case (b) T002 bullet present with desc" || bad "case (b) T002 bullet missing"
echo "$MSG_B" | grep -qE 'T003 — Seed site_config' && ok "case (b) T003 bullet present with desc" || bad "case (b) T003 bullet missing"
echo "$MSG_B" | grep -q '/ss:verify' && ok "case (b) footer mentions /ss:verify" || bad "case (b) footer missing /ss:verify hint"

# Should NOT mention "Details in" (compact-summary-only footer)
echo "$MSG_B" | grep -q 'Details in' && bad "case (b) leaked compact-summary footer" || ok "case (b) did not leak compact footer"

# ---------------------------------------------------------------------------
echo
echo "── Case (c): 23 pending across 2 features (> 8 threshold) → summary ───"
TMP_C="$(mktemp -d)"
mkdir -p "${TMP_C}/.specswarm/verify-queue"
QDIR_C="${TMP_C}/.specswarm/verify-queue"

# 21 tasks in feature one (T001–T021), 2 in feature two (T022, T023)
for i in $(seq 1 21); do
  tid=$(printf "T%03d" "$i")
  make_pending "$QDIR_C" "$tid" 034-graphics-facilitator-pilot "Implementation step ${i}"
done
make_pending "$QDIR_C" T022 035-checkout-rewrite "Add checkout shipping calculator"
make_pending "$QDIR_C" T023 035-checkout-rewrite "Wire calculator into cart total"

OUT_C="$(run_hook "$TMP_C")"
echo "    raw: $OUT_C"

echo "$OUT_C" | jq -e . >/dev/null 2>&1 && ok "case (c) output parses as JSON" || bad "case (c) invalid JSON"

DECISION_C=$(echo "$OUT_C" | jq -r '.decision')
[ "$DECISION_C" = "approve" ] && ok "case (c) decision == approve" || bad "case (c) decision != approve"

MSG_C=$(echo "$OUT_C" | jq -r '.systemMessage')
echo "    systemMessage:"
echo "$MSG_C" | sed 's/^/      /'

echo "$MSG_C" | grep -q "23 task(s) pending" && ok "case (c) header shows correct total count (23)" || bad "case (c) header count missing/wrong"
echo "$MSG_C" | grep -qE '034-graphics-facilitator-pilot: 21' && ok "case (c) feature one grouped count == 21" || bad "case (c) feature one count wrong"
echo "$MSG_C" | grep -qE '035-checkout-rewrite: 2' && ok "case (c) feature two grouped count == 2" || bad "case (c) feature two count wrong"
echo "$MSG_C" | grep -q 'Details in .specswarm/verify-queue/' && ok "case (c) footer points to queue dir" || bad "case (c) footer missing queue dir pointer"

# Must NOT include any per-task bullets in summary mode
if echo "$MSG_C" | grep -qE 'T00[1-9] — '; then
  bad "case (c) leaked per-task bullet — summary mode failed"
else
  ok "case (c) emitted no per-task bullets"
fi

# Length sanity: should be a handful of lines (header + 2 group lines + footer)
LINES_C=$(echo "$MSG_C" | wc -l | tr -d ' ')
if [ "$LINES_C" -le 6 ]; then
  ok "case (c) compact (${LINES_C} lines)"
else
  bad "case (c) too long (${LINES_C} lines)"
fi

# ---------------------------------------------------------------------------
echo
echo "── Case (d): override threshold via env var ────────────────────────────"
# With LIST_MAX=2, the case-(b) fixture (3 pending) should switch to summary.
TMP_D="$(mktemp -d)"
mkdir -p "${TMP_D}/.specswarm/verify-queue"
make_pending "${TMP_D}/.specswarm/verify-queue" T001 034-graphics-facilitator-pilot "x"
make_pending "${TMP_D}/.specswarm/verify-queue" T002 034-graphics-facilitator-pilot "y"
make_pending "${TMP_D}/.specswarm/verify-queue" T003 034-graphics-facilitator-pilot "z"

OUT_D="$( cd "$TMP_D" && SPECSWARM_VERIFY_QUEUE_LIST_MAX=2 bash "$HOOK" )"
echo "    raw: $OUT_D"

MSG_D=$(echo "$OUT_D" | jq -r '.systemMessage')
echo "$MSG_D" | grep -qE '034-graphics-facilitator-pilot: 3' && ok "case (d) LIST_MAX=2 forced summary mode" || bad "case (d) env override ignored"
rm -rf "$TMP_D"

# ---------------------------------------------------------------------------
echo
echo "── Summary ─────────────────────────────────────────────────────────────"
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
if [ "$FAIL" -eq 0 ]; then
  echo "  ✅ ALL ASSERTIONS PASSED"
  exit 0
else
  echo "  ❌ SOME ASSERTIONS FAILED"
  exit 1
fi
