#!/bin/bash
# v7.16.0 bakeoff + decided-by-data + ground-truth-bias tests (AUTO-MAGIC WS7+WS8)
#
# Behaviors under test:
#   [A] lib/bakeoff.sh: workspace creation, slugging, and contact-sheet
#       assembly (NOTES.md + images as links + text inlined + explicit
#       truncation notice — no silent caps). Errors when no candidates exist.
#   [B] lib/decisions/decided-by-data.sh: marker parsing (metric +
#       review-when), multi-file scan, silence on marker-free files.
#   [C] lib/preflight/checks/ground-truth-bias.sh: PASS-skip on plans with no
#       eval language; WARN FIRES on eval-against-acceptance with no
#       provenance note; PASS when provenance/segmentation is addressed.
#
# Run:  bash plugins/ss/test-fixtures/v7.16-bakeoff-databias.sh
# Exit: 0 if all pass, 1 otherwise

set -u

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BAKE_LIB="${PLUGIN_DIR}/lib/bakeoff.sh"
DBD_LIB="${PLUGIN_DIR}/lib/decisions/decided-by-data.sh"
GTB_CHECK="${PLUGIN_DIR}/lib/preflight/checks/ground-truth-bias.sh"

PASS=0
FAIL=0
ok()  { PASS=$((PASS+1)); echo "  ✅ $1"; }
bad() { FAIL=$((FAIL+1)); echo "  ❌ $1"; }

SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT

# shellcheck disable=SC1090
source "$BAKE_LIB"
# shellcheck disable=SC1090
source "$DBD_LIB"

echo "── [A] bakeoff workspace + contact sheet ──"
FEAT="${SCRATCH}/features/007-hero"
mkdir -p "$FEAT"

[ "$(ss_bakeoff_slug 'Hero Section: Color Palette!')" = "hero-section-color-palette" ] \
  && ok "A1: slugging" || bad "A1"

BDIR=$(ss_bakeoff_dir "$FEAT" "hero-palette")
[ -d "$BDIR" ] && [ "$BDIR" = "${FEAT}/bakeoff/hero-palette" ] && ok "A2: workspace created" || bad "A2: $BDIR"

set +e
ss_bakeoff_sheet "$BDIR" "Hero palette" >/dev/null 2>&1
RC=$?
set -e
[ "$RC" -ne 0 ] && ok "A3: errors with no candidates" || bad "A3: silent on empty"

mkdir -p "${BDIR}/candidate-1" "${BDIR}/candidate-2"
printf 'Angle: bold. Primary #FF2D55.\n' > "${BDIR}/candidate-1/NOTES.md"
printf ':root { --primary: #FF2D55; }\n' > "${BDIR}/candidate-1/palette.css"
printf 'fake-png' > "${BDIR}/candidate-1/preview.png"
printf 'Angle: minimal. Primary #222222.\n' > "${BDIR}/candidate-2/NOTES.md"
seq 1 200 | sed 's/^/const line/' > "${BDIR}/candidate-2/tokens.js"

SHEET=$(ss_bakeoff_sheet "$BDIR" "Hero palette")
[ -f "$SHEET" ] && ok "A4: sheet written" || bad "A4"
grep -q '^## Candidate 1' "$SHEET" && grep -q '^## Candidate 2' "$SHEET" && ok "A5: one section per candidate" || bad "A5"
grep -q 'Angle: bold' "$SHEET" && ok "A6: NOTES.md inlined" || bad "A6"
grep -q '!\[candidate 1 — preview.png\](candidate-1/preview.png)' "$SHEET" && ok "A7: image embedded as relative link" || bad "A7"
grep -q -- '--primary: #FF2D55' "$SHEET" && ok "A8: code inlined in fenced block" || bad "A8"
grep -q 'truncated at 120 of 200 lines' "$SHEET" && ok "A9: truncation is explicit (no silent caps)" || bad "A9"

echo "── [B] DECIDED-BY-DATA scanner ──"
SPEC="${SCRATCH}/spec.md"
cat > "$SPEC" <<'EOF'
# Spec
The default sort is newest-first. [DECIDED-BY-DATA: search-ctr-by-sort, 2 weeks post-launch]
Some other line.
Retention default 30 days [DECIDED-BY-DATA: storage-cost-per-user]
EOF
OUT=$(ss_dbd_scan "$SPEC")
[ "$(echo "$OUT" | wc -l)" -eq 2 ] && ok "B1: both markers found" || bad "B1: $OUT"
echo "$OUT" | grep -qP "spec.md\t2\tsearch-ctr-by-sort\t2 weeks post-launch" && ok "B2: metric + review-when parsed" || bad "B2: $OUT"
echo "$OUT" | grep -qP "storage-cost-per-user\tunspecified" && ok "B3: missing review-when → unspecified" || bad "B3: $OUT"

PLAIN="${SCRATCH}/plain.md"
echo "# Nothing here" > "$PLAIN"
[ -z "$(ss_dbd_scan "$PLAIN")" ] && ok "B4: silent on marker-free file" || bad "B4"

FEAT2="${SCRATCH}/features/008-x"
mkdir -p "$FEAT2"
cp "$SPEC" "${FEAT2}/spec.md"
echo "# plan" > "${FEAT2}/plan.md"
[ "$(ss_dbd_scan_feature "$FEAT2" | wc -l)" -eq 2 ] && ok "B5: feature-scope scan" || bad "B5"

echo "── [C] ground-truth-bias check ──"
run_gtb() { set +e; OUT=$(bash "$GTB_CHECK" "$1" 2>&1); RC=$?; set -e; LINE1=$(echo "$OUT" | head -1); }

PLAN="${SCRATCH}/plan-clean.md"
printf '# Plan\nBuild the cart. Test with fixtures.\n' > "$PLAN"
run_gtb "$PLAN"
echo "$LINE1" | grep -q '^PASS ground-truth-bias: skipped' && [ "$RC" -eq 0 ] \
  && ok "C1: no eval language → PASS-skip" || bad "C1: $LINE1"

PLAN="${SCRATCH}/plan-biased.md"
cat > "$PLAN" <<'EOF'
# Plan
Tune the ranking weights against the user-accepted suggestions from Q2.
Score each variant by acceptance rate.
EOF
run_gtb "$PLAN"
echo "$LINE1" | grep -q '^WARN ground-truth-bias:' && [ "$RC" -eq 1 ] \
  && ok "C2: eval without provenance → WARN FIRES" || bad "C2: $LINE1"
echo "$OUT" | grep -q "scorer's own suggestions" && ok "C3: origin lesson surfaced" || bad "C3"

PLAN="${SCRATCH}/plan-guarded.md"
cat > "$PLAN" <<'EOF'
# Plan
Tune the ranking weights against the user-accepted suggestions from Q2,
excluding self-generated items (interface gravity guard): acceptances that were
the system's own suggestions are segmented out of the ground truth.
EOF
run_gtb "$PLAN"
echo "$LINE1" | grep -q '^PASS ground-truth-bias:' && [ "$RC" -eq 0 ] \
  && ok "C4: provenance addressed → PASS" || bad "C4: $LINE1"

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
if [ "$FAIL" -eq 0 ]; then
  exit 0
else
  exit 1
fi
