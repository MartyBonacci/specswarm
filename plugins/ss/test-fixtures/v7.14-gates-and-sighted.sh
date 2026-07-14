#!/bin/bash
# v7.14.0 deterministic-gates + sighted-classification tests (AUTO-MAGIC WS4+WS5)
#
# Behaviors under test:
#   [A] queue.sh NEEDS-SIGHTED lifecycle: NEEDS-SIGHTED → .needs-sighted;
#       SIGHTED-PASS → .verified; SIGHTED-REJECT → .flagged; _add/_clear wipe
#       the new suffix; _count generalizes.
#   [B] screeners (lib/verify/screeners.sh): sighted classifier fires on
#       visual surfaces and stays quiet on backend/test/server files;
#       geometry / roundtrip / fixture-shape / test-globs clauses FIRE on
#       violating diffs and stay quiet on clean ones.
#   [C] test-framework-detector.sh: detection from repo reality (vitest /
#       pytest / gotest), primary priority, test-root derivation (the
#       test/ + tests/ dual-root trap), result parsing, valid JSON standalone.
#   [D] quality-gates.sh: build/lint command detection from manifests,
#       run_slice_gates block/warn/off semantics, WARN-on-zero, and a
#       violating fixture proving a broken build FAILs (exit 2).
#
# Run:  bash plugins/ss/test-fixtures/v7.14-gates-and-sighted.sh
# Exit: 0 if all pass, 1 otherwise

set -u

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QUEUE_LIB="${PLUGIN_DIR}/lib/verify/queue.sh"
SCREEN_LIB="${PLUGIN_DIR}/lib/verify/screeners.sh"
TFD_LIB="${PLUGIN_DIR}/lib/test-framework-detector.sh"
QG_LIB="${PLUGIN_DIR}/lib/quality-gates.sh"

PASS=0
FAIL=0
ok()  { PASS=$((PASS+1)); echo "  ✅ $1"; }
bad() { FAIL=$((FAIL+1)); echo "  ❌ $1"; }

SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT

mk_repo() {
  local repo="${SCRATCH}/$1"
  mkdir -p "$repo"
  git -C "$repo" init -q
  echo "$repo"
}

echo "── [A] queue.sh NEEDS-SIGHTED lifecycle ──"
REPO=$(mk_repo "queueton")
QDIR="${REPO}/.specswarm/verify-queue"
run_q() { (cd "$REPO" && bash -c 'source "$1"; shift; "$@"' _ "$QUEUE_LIB" "$@"); }

run_q ss_verify_queue_add T001 featdir tasks.md "render the hero banner" "§2.1"
run_q ss_verify_queue_resolve T001 NEEDS-SIGHTED "spec-mentor PASS; visual surface"
[ -f "${QDIR}/T001.needs-sighted" ] && ok "A1: NEEDS-SIGHTED → .needs-sighted" || bad "A1: marker missing"
[ ! -f "${QDIR}/T001.pending" ] && ok "A2: .pending consumed" || bad "A2: .pending remains"
[ "$(run_q ss_verify_queue_count needs-sighted)" -eq 1 ] && ok "A3: count generalizes" || bad "A3: count wrong"

run_q ss_verify_queue_resolve T001 SIGHTED-PASS "human approved"
[ -f "${QDIR}/T001.verified" ] && ok "A4: SIGHTED-PASS → .verified" || bad "A4: not verified"
[ ! -f "${QDIR}/T001.needs-sighted" ] && ok "A5: .needs-sighted consumed" || bad "A5: marker remains"
grep -q 'verdict=SIGHTED-PASS' "${QDIR}/T001.verified" && ok "A6: sign-off verdict recorded" || bad "A6: verdict missing"

run_q ss_verify_queue_add T002 featdir tasks.md "restyle nav" "§3"
run_q ss_verify_queue_resolve T002 NEEDS-SIGHTED "visual"
run_q ss_verify_queue_resolve T002 SIGHTED-REJECT "spacing is wrong"
[ -f "${QDIR}/T002.flagged" ] && ok "A7: SIGHTED-REJECT → .flagged" || bad "A7: not flagged"

run_q ss_verify_queue_add T002 featdir tasks.md "restyle nav (retry)" "§3"
[ -f "${QDIR}/T002.pending" ] && [ ! -f "${QDIR}/T002.flagged" ] \
  && ok "A8: re-add wipes prior states" || bad "A8: stale state left"
run_q ss_verify_queue_resolve T002 NEEDS-SIGHTED "visual"
run_q ss_verify_queue_clear T002
[ ! -f "${QDIR}/T002.needs-sighted" ] && ok "A9: clear removes .needs-sighted" || bad "A9: leak"

echo "── [B] diff screeners ──"
run_screen() { # $1=repo $2=files-content $3=diff-content
  local files="${SCRATCH}/files.txt" diff="${SCRATCH}/diff.txt"
  printf '%s\n' "$2" > "$files"
  printf '%s\n' "$3" > "$diff"
  (cd "$1" && bash -c 'source "$1"; ss_screen_diff "$2" "$3" "$4"' _ "$SCREEN_LIB" "$files" "$diff" "$1")
}

REPO=$(mk_repo "screenville")
OUT=$(run_screen "$REPO" "app/components/HeroBanner.tsx
app/styles/hero.css" "+ const x = 1")
echo "$OUT" | grep -q '^SIGHTED yes' && ok "B1: component+css → SIGHTED" || bad "B1: no SIGHTED ($OUT)"
echo "$OUT" | grep -q '^CLAUSE sighted:' && ok "B2: sighted clause emitted" || bad "B2: clause missing"

OUT=$(run_screen "$REPO" "server/db/schema.ts
server/api/users.ts" "+ const q = sql\`select 1\`")
echo "$OUT" | grep -q '^SIGHTED' && bad "B3: backend diff wrongly SIGHTED" || ok "B3: backend diff not sighted"

OUT=$(run_screen "$REPO" "app/components/__tests__/Hero.test.tsx
app/routes/data.server.tsx" "+ test stuff")
echo "$OUT" | grep -q '^SIGHTED' && bad "B4: test/server files wrongly SIGHTED" || ok "B4: test/.server excluded"

OUT=$(run_screen "$REPO" "src/geometry/board.ts" "+  const flipped = mirrorAcrossAxis(points, 'y')
+  return rotate(flipped, 90)")
echo "$OUT" | grep -q '^CLAUSE geometry:' && ok "B5: geometry clause FIRES on mirror/rotate diff" || bad "B5: geometry silent"

OUT=$(run_screen "$REPO" "src/io/save.ts" "+ export function encodeBoard(b) {
+ export function decodeBoard(s) {")
echo "$OUT" | grep -q '^CLAUSE roundtrip:' && ok "B6: roundtrip clause FIRES on encode/decode" || bad "B6: roundtrip silent"

OUT=$(run_screen "$REPO" "test/fixtures/board.json" "+ {\"cells\": []}")
echo "$OUT" | grep -q '^CLAUSE fixture-shape:' && ok "B7: fixture-shape clause FIRES" || bad "B7: fixture silent"

OUT=$(run_screen "$REPO" "src/util/math.ts" "+ export const add = (a, b) => a + b")
[ -z "$(echo "$OUT" | grep '^CLAUSE' | grep -vE 'test-globs')" ] && ok "B8: clean diff → no content clauses" || bad "B8: false positive ($OUT)"

REPO=$(mk_repo "dualroots")
mkdir -p "${REPO}/test" "${REPO}/tests" "${REPO}/src"
echo "x" > "${REPO}/test/a.test.js"
echo "y" > "${REPO}/tests/test_b.py"
OUT=$(run_screen "$REPO" "src/util/math.ts" "+ const x = 1")
echo "$OUT" | grep -q '^CLAUSE test-globs: This repo has 2 distinct test roots' \
  && ok "B9: dual test-root trap FIRES (test/ + tests/)" || bad "B9: dual-root silent ($OUT)"

echo "── [C] test-framework-detector ──"
REPO=$(mk_repo "vitestville")
cat > "${REPO}/package.json" <<'EOF'
{ "name": "x", "devDependencies": { "vitest": "^3.0.0", "@playwright/test": "^1.50.0" } }
EOF
touch "${REPO}/pnpm-lock.yaml"
run_tfd() { local r="$1"; shift; (cd "$r" && bash -c 'source "$1"; shift; "$@"' _ "$TFD_LIB" "$@"); }
FW=$(run_tfd "$REPO" detect_test_frameworks "$REPO")
echo "$FW" | grep -qx vitest && ok "C1: vitest detected from package.json" || bad "C1: $FW"
echo "$FW" | grep -qx playwright && ok "C2: playwright detected alongside" || bad "C2: $FW"
[ "$(run_tfd "$REPO" primary_test_framework "$REPO")" = "vitest" ] && ok "C3: primary prefers unit runner" || bad "C3: wrong primary"

REPO=$(mk_repo "goville")
echo "module example.com/x" > "${REPO}/go.mod"
mkdir -p "${REPO}/pkg"
echo "package pkg" > "${REPO}/pkg/a_test.go"
[ "$(run_tfd "$REPO" primary_test_framework "$REPO")" = "gotest" ] && ok "C4: gotest via go.mod + _test.go" || bad "C4"

REPO=$(mk_repo "pyville")
touch "${REPO}/pytest.ini"
mkdir -p "${REPO}/test" "${REPO}/tests"
echo "def test_a(): pass" > "${REPO}/test/test_a.py"
echo "def test_b(): pass" > "${REPO}/tests/test_b.py"
ROOTS=$(run_tfd "$REPO" detect_test_roots "$REPO")
[ "$(echo "$ROOTS" | grep -c .)" -eq 2 ] && ok "C5: both test roots derived from reality" || bad "C5: $ROOTS"

JSON=$( (cd "$REPO" && bash "$TFD_LIB" "$REPO") )
echo "$JSON" | jq -e . >/dev/null 2>&1 && ok "C6: standalone emits valid JSON" || bad "C6: invalid JSON"
[ "$(echo "$JSON" | jq -r .primary)" = "pytest" ] && ok "C7: JSON primary=pytest" || bad "C7"
[ "$(echo "$JSON" | jq '.test_roots | length')" -eq 2 ] && ok "C8: JSON test_roots has both" || bad "C8"

OUTF="${SCRATCH}/pytest.out"
echo "========= 12 passed, 1 failed, 2 skipped in 3.21s =========" > "$OUTF"
RES=$(run_tfd "$REPO" parse_test_results pytest "$OUTF")
[ "$RES" = "total=15 passed=12 failed=1 skipped=2" ] && ok "C9: pytest results parsed" || bad "C9: $RES"

echo "test result: ok. 34 passed; 2 failed; 1 ignored; 0 measured" > "$OUTF"
RES=$(run_tfd "$REPO" parse_test_results cargotest "$OUTF")
[ "$RES" = "total=37 passed=34 failed=2 skipped=1" ] && ok "C10: cargo results parsed" || bad "C10: $RES"

echo "── [D] quality-gates ──"
run_qg() { local r="$1"; shift; (cd "$r" && bash -c 'source "$1"; shift; "$@"' _ "$QG_LIB" "$@"); }

REPO=$(mk_repo "buildville")
cat > "${REPO}/package.json" <<'EOF'
{ "name": "x", "scripts": { "build": "true", "lint": "true" } }
EOF
touch "${REPO}/pnpm-lock.yaml"
[ "$(run_qg "$REPO" detect_build_command "$REPO")" = "pnpm run build" ] && ok "D1: build cmd from scripts+lockfile" || bad "D1"
[ "$(run_qg "$REPO" detect_lint_command "$REPO")" = "pnpm run lint" ] && ok "D2: lint cmd from scripts" || bad "D2"

REPO=$(mk_repo "rustville")
echo '[package]' > "${REPO}/Cargo.toml"
[ "$(run_qg "$REPO" detect_build_command "$REPO")" = "cargo build" ] && ok "D3: cargo build detected" || bad "D3"

REPO=$(mk_repo "gates-pass")
cat > "${REPO}/Makefile" <<'EOF'
build:
	@echo built ok
EOF
set +e
OUT=$(run_qg "$REPO" run_slice_gates "$REPO"); RC=$?
set -e
echo "$OUT" | head -1 | grep -q '^PASS slice-gates:' && [ "$RC" -eq 0 ] \
  && ok "D4: passing build → PASS exit 0" || bad "D4: rc=$RC ($OUT)"

REPO=$(mk_repo "gates-fail")
cat > "${REPO}/Makefile" <<'EOF'
build:
	@echo "error: unwired module" >&2; exit 1
EOF
set +e
OUT=$(run_qg "$REPO" run_slice_gates "$REPO"); RC=$?
set -e
echo "$OUT" | head -1 | grep -q '^FAIL slice-gates:' && [ "$RC" -eq 2 ] \
  && ok "D5: broken build FIRES → FAIL exit 2 (block default)" || bad "D5: rc=$RC ($OUT)"
echo "$OUT" | grep -q 'unwired module' && ok "D6: failure output tail included" || bad "D6"

set +e
OUT=$(cd "$REPO" && SPECSWARM_SLICE_GATES=warn bash -c 'source "$1"; run_slice_gates "$2"' _ "$QG_LIB" "$REPO"); RC=$?
set -e
echo "$OUT" | head -1 | grep -q '^WARN slice-gates:' && [ "$RC" -eq 1 ] \
  && ok "D7: warn mode → WARN exit 1" || bad "D7: rc=$RC"

set +e
OUT=$(cd "$REPO" && SPECSWARM_SLICE_GATES=off bash -c 'source "$1"; run_slice_gates "$2"' _ "$QG_LIB" "$REPO"); RC=$?
set -e
echo "$OUT" | grep -q 'skipped (SPECSWARM_SLICE_GATES=off)' && [ "$RC" -eq 0 ] \
  && ok "D8: off mode → PASS-skip" || bad "D8: rc=$RC"

REPO=$(mk_repo "gates-none")
set +e
OUT=$(run_qg "$REPO" run_slice_gates "$REPO"); RC=$?
set -e
echo "$OUT" | grep -q 'no build manifest' && [ "$RC" -eq 0 ] \
  && ok "D9: no manifests → clean PASS-skip" || bad "D9: rc=$RC ($OUT)"

REPO=$(mk_repo "gates-zero")
echo '{ "name": "x" }' > "${REPO}/package.json"
set +e
OUT=$(run_qg "$REPO" run_slice_gates "$REPO"); RC=$?
set -e
echo "$OUT" | head -1 | grep -q '^WARN slice-gates:' && [ "$RC" -eq 1 ] \
  && ok "D10: manifest but no commands → WARN-on-zero" || bad "D10: rc=$RC ($OUT)"

[ "$(run_qg "$REPO" detect_browser_test_framework "$REPO")" = "none" ] && ok "D11: browser framework none" || bad "D11"
cat > "${REPO}/package.json" <<'EOF'
{ "name": "x", "devDependencies": { "@playwright/test": "^1.50.0" } }
EOF
[ "$(run_qg "$REPO" detect_browser_test_framework "$REPO")" = "playwright" ] && ok "D12: playwright detected" || bad "D12"

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
if [ "$FAIL" -eq 0 ]; then
  exit 0
else
  exit 1
fi
