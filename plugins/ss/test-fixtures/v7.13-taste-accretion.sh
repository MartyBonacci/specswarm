#!/bin/bash
# v7.13.0 taste-model accretion tests (AUTO-MAGIC epic, WS1 / slice S2.1)
#
# Behaviors under test (lib/taste.sh):
#   1. ss_taste_add writes a well-formed feedback_*.md (frontmatter: name,
#      description, type: feedback, check-type, source, date; body: rule +
#      **Why:** + **How to apply:**) — the distilled-rule shape a fresh
#      session can apply without transcript access.
#   2. Dedup: re-adding the same slug is an idempotent skip (one file, exit 0).
#   3. MEMORY.md index gains exactly one "## Distilled Rules" pointer.
#   4. Violating input FIRES: bad check-type and missing args exit 1, no file.
#   5. Directory resolution: references.md memory dir (tier 1) wins over the
#      .specswarm/memory fallback (tier 3).
#   6. Slug normalization: mixed case/punctuation → kebab name, snake filename.
#
# Also under test (lib/preflight/checks/assumptions-provenance.sh):
#   7. PASS-skip when spec.md or ## Assumptions absent (pre-v7.13 specs legal).
#   8. WARN-on-zero when section exists but has no structured entries.
#   9. FAIL fires on entries missing *source:*/*status:* or with bad values.
#  10. PASS on fully provenance-cited entries.
#
# Run:  bash plugins/ss/test-fixtures/v7.13-taste-accretion.sh
# Exit: 0 if all pass, 1 otherwise

set -u

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TASTE_LIB="${PLUGIN_DIR}/lib/taste.sh"

PASS=0
FAIL=0
ok()  { PASS=$((PASS+1)); echo "  ✅ $1"; }
bad() { FAIL=$((FAIL+1)); echo "  ❌ $1"; }

SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT

# Synthetic, stack-agnostic repo (deliberately shares nothing with SpecSwarm)
mk_repo() {
  local name="$1"
  local repo="${SCRATCH}/${name}"
  mkdir -p "$repo"
  git -C "$repo" init -q
  echo "$repo"
}

# Run a taste.sh function inside a repo, capturing stdout/stderr/exit code.
# Usage: run_taste <repo> <fn> [args...] ; sets OUT, ERR, RC
run_taste() {
  local repo="$1"; shift
  set +e
  OUT=$(cd "$repo" && bash -c 'source "$1"; shift; "$@"' _ "$TASTE_LIB" "$@" 2>"${SCRATCH}/err")
  RC=$?
  set -e
  ERR=$(cat "${SCRATCH}/err")
}

echo "── [A] well-formed entry written to fallback dir ──"
REPO=$(mk_repo "plainville")
run_taste "$REPO" ss_taste_add "hover-states-required" "judgment" \
  "AskUserQuestion /ss:decisions D2 feature 004" \
  "Every interactive element gets a visible hover state." \
  "Two shipped slices bounced at sighted review for dead-feeling UI." \
  "When adding buttons/links/cards, include hover styling in the same slice."

ENTRY="${REPO}/.specswarm/memory/feedback_hover_states_required.md"
[ "$RC" -eq 0 ] && ok "A1: exit 0" || bad "A1: exit $RC (err: $ERR)"
[ "$OUT" = "$ENTRY" ] && ok "A2: echoes written path" || bad "A2: path was '$OUT'"
[ -f "$ENTRY" ] && ok "A3: file exists in .specswarm/memory fallback" || bad "A3: file missing"
grep -q '^name: hover-states-required$' "$ENTRY" && ok "A4: name frontmatter" || bad "A4: name missing"
grep -q '^  type: feedback$' "$ENTRY" && ok "A5: type feedback" || bad "A5: type missing"
grep -q '^  check-type: judgment$' "$ENTRY" && ok "A6: check-type" || bad "A6: check-type missing"
grep -q '^  source: AskUserQuestion /ss:decisions D2 feature 004$' "$ENTRY" && ok "A7: provenance" || bad "A7: provenance missing"
grep -q '^\*\*Why:\*\* ' "$ENTRY" && ok "A8: Why line" || bad "A8: Why missing"
grep -q '^\*\*How to apply:\*\* ' "$ENTRY" && ok "A9: How-to-apply line" || bad "A9: How missing"
grep -q '^description: Every interactive element' "$ENTRY" && ok "A10: description defaults to rule" || bad "A10: description wrong"

echo "── [B] dedup is an idempotent skip ──"
run_taste "$REPO" ss_taste_add "hover-states-required" "judgment" "src2" "other rule" "w" "h"
[ "$RC" -eq 0 ] && ok "B1: duplicate add exits 0" || bad "B1: exit $RC"
echo "$ERR" | grep -q "already exists" && ok "B2: skip noted on stderr" || bad "B2: no skip note"
COUNT=$(find "${REPO}/.specswarm/memory" -name 'feedback_*.md' | wc -l)
[ "$COUNT" -eq 1 ] && ok "B3: still exactly one file" || bad "B3: $COUNT files"
grep -q 'Every interactive element gets a visible hover state' "$ENTRY" \
  && ok "B4: original body untouched" || bad "B4: body overwritten"

echo "── [C] MEMORY.md index pointer, exactly once ──"
REPO=$(mk_repo "indexton")
mkdir -p "${REPO}/memory"
printf '# Memory\n' > "${REPO}/MEMORY.md"
run_taste "$REPO" ss_taste_add "tabs-not-spaces" "deterministic" "test" "Use tabs." "why" "how"
[ -f "${REPO}/memory/feedback_tabs_not_spaces.md" ] && ok "C1: tier-2 dir (repo/memory) used" || bad "C1: wrong dir ($OUT)"
grep -q '^## Distilled Rules$' "${REPO}/MEMORY.md" && ok "C2: index section created" || bad "C2: section missing"
grep -q 'feedback_tabs_not_spaces.md' "${REPO}/MEMORY.md" && ok "C3: pointer line present" || bad "C3: pointer missing"
run_taste "$REPO" ss_taste_add "tabs-not-spaces" "deterministic" "test" "Use tabs." "why" "how"
LINES=$(grep -c 'feedback_tabs_not_spaces.md' "${REPO}/MEMORY.md")
[ "$LINES" -eq 1 ] && ok "C4: pointer not duplicated" || bad "C4: $LINES pointer lines"

echo "── [D] violating input FIRES ──"
REPO=$(mk_repo "violationham")
run_taste "$REPO" ss_taste_add "bad-type" "vibes" "src" "rule" "why" "how"
[ "$RC" -eq 1 ] && ok "D1: invalid check-type exits 1" || bad "D1: exit $RC"
echo "$ERR" | grep -q "check-type must be" && ok "D2: reason on stderr" || bad "D2: no reason"
[ ! -f "${REPO}/.specswarm/memory/feedback_bad_type.md" ] && ok "D3: no file written" || bad "D3: file written anyway"
run_taste "$REPO" ss_taste_add "missing-why" "judgment" "src" "rule" "" "how"
[ "$RC" -eq 1 ] && ok "D4: missing why exits 1" || bad "D4: exit $RC"

echo "── [E] references.md memory dir wins (tier 1) ──"
REPO=$(mk_repo "referencia")
DECLARED="${SCRATCH}/declared-memory"
mkdir -p "$DECLARED" "${REPO}/.specswarm"
cat > "${REPO}/.specswarm/references.md" <<EOF
# References

## Memory directories

- path: ${DECLARED}
EOF
run_taste "$REPO" ss_taste_add "declared-dir-wins" "judgment" "src" "rule" "why" "how"
[ -f "${DECLARED}/feedback_declared_dir_wins.md" ] && ok "E1: entry landed in declared dir" || bad "E1: not in declared dir ($OUT)"
[ ! -d "${REPO}/.specswarm/memory" ] && ok "E2: fallback dir not created" || bad "E2: fallback created anyway"

echo "── [F] slug normalization ──"
REPO=$(mk_repo "slugville")
run_taste "$REPO" ss_taste_add "Buttons Use Brand Blue!" "judgment" "src" "rule" "why" "how"
[ -f "${REPO}/.specswarm/memory/feedback_buttons_use_brand_blue.md" ] \
  && ok "F1: mixed case/punctuation normalized" || bad "F1: got '$OUT'"
grep -q '^name: buttons-use-brand-blue$' "${REPO}/.specswarm/memory/feedback_buttons_use_brand_blue.md" \
  && ok "F2: kebab name in frontmatter" || bad "F2: name wrong"

CHECK="${PLUGIN_DIR}/lib/preflight/checks/assumptions-provenance.sh"

# Build a feature dir with a plan.md and optional spec.md; run the check on plan.md
mk_feature() {
  local name="$1"
  local dir="${SCRATCH}/feat-${name}"
  mkdir -p "$dir"
  echo "# Plan" > "${dir}/plan.md"
  echo "$dir"
}
run_check() {
  set +e
  OUT=$(bash "$CHECK" "$1/plan.md" 2>&1)
  RC=$?
  set -e
  LINE1=$(echo "$OUT" | head -1)
}
assert_status() {
  local want="$1" label="$2"
  local got
  got=$(echo "$LINE1" | awk '{print $1}')
  [ "$got" = "$want" ] && ok "$label" || bad "$label (got: $LINE1)"
}

echo "── [G] assumptions-provenance: PASS-skip cases ──"
DIR=$(mk_feature "nospec")
run_check "$DIR"
assert_status PASS "G1: no spec.md → PASS-skip"
[ "$RC" -eq 0 ] && ok "G2: exit 0" || bad "G2: exit $RC"

DIR=$(mk_feature "nosection")
printf '# Spec\n\n## Functional Requirements\n- stuff\n' > "${DIR}/spec.md"
run_check "$DIR"
assert_status PASS "G3: no ## Assumptions → PASS-skip (pre-v7.13 spec)"

echo "── [H] assumptions-provenance: WARN-on-zero ──"
DIR=$(mk_feature "emptysec")
printf '# Spec\n\n## Assumptions\n\n## Success Criteria\n- x\n' > "${DIR}/spec.md"
run_check "$DIR"
assert_status WARN "H1: section present, zero entries → WARN"
[ "$RC" -eq 1 ] && ok "H2: exit 1" || bad "H2: exit $RC"

DIR=$(mk_feature "proseonly")
printf '# Spec\n\n## Assumptions\n- users have modern browsers\n- data fits in memory\n' > "${DIR}/spec.md"
run_check "$DIR"
assert_status WARN "H3: only unstructured prose bullets → WARN"
echo "$LINE1" | grep -q '2 unstructured' && ok "H4: unstructured count reported" || bad "H4: count missing ($LINE1)"

DIR=$(mk_feature "placeholder")
printf '# Spec\n\n## Assumptions\n- A1: [assumption statement] — *source:* [taste:<entry-name> | corpus:<file>] — *status:* auto-filled\n' > "${DIR}/spec.md"
run_check "$DIR"
assert_status WARN "H5: template placeholder not counted as an entry"

echo "── [I] assumptions-provenance: violating entries FIRE ──"
DIR=$(mk_feature "nosource")
printf '# Spec\n\n## Assumptions\n- A1: sessions auto-extend — *status:* auto-filled\n' > "${DIR}/spec.md"
run_check "$DIR"
assert_status FAIL "I1: missing *source:* → FAIL"
[ "$RC" -eq 2 ] && ok "I2: exit 2" || bad "I2: exit $RC"
echo "$OUT" | grep -q 'A1: missing or invalid \*source' && ok "I3: names the entry" || bad "I3: entry not named"

DIR=$(mk_feature "badprefix")
printf '# Spec\n\n## Assumptions\n- A1: use OAuth — *source:* vibes:felt-right — *status:* auto-filled\n' > "${DIR}/spec.md"
run_check "$DIR"
assert_status FAIL "I4: invalid source prefix → FAIL"

DIR=$(mk_feature "nostatus")
printf '# Spec\n\n## Assumptions\n- A1: use OAuth — *source:* corpus:FLOWS.md §5.1\n' > "${DIR}/spec.md"
run_check "$DIR"
assert_status FAIL "I5: missing *status:* → FAIL"

DIR=$(mk_feature "badstatus")
printf '# Spec\n\n## Assumptions\n- A1: use OAuth — *source:* corpus:FLOWS.md §5.1 — *status:* maybe\n' > "${DIR}/spec.md"
run_check "$DIR"
assert_status FAIL "I6: invalid status value → FAIL"

echo "── [J] assumptions-provenance: clean ledger PASSes ──"
DIR=$(mk_feature "clean")
cat > "${DIR}/spec.md" <<'SPEC'
# Spec

## Assumptions
- A1: sessions auto-extend on activity — *source:* taste:session-timeout-ux — *status:* auto-filled
- A2: OAuth-first signup — *source:* corpus:INTERACTION-FLOWS.md §5.11.5.1 — *status:* confirmed
- A3: inline form errors — *source:* codebase:app/components/ContactForm.tsx:88 — *status:* overridden
- A4: 30-day soft-delete retention — *source:* convention:common SaaS default — *status:* auto-filled

## Success Criteria
- x
SPEC
run_check "$DIR"
assert_status PASS "J1: all four prefixes + all three statuses accepted"
echo "$LINE1" | grep -q '4/4' && ok "J2: counts all entries" || bad "J2: count wrong ($LINE1)"
echo "$LINE1" | grep -q '2 still auto-filled' && ok "J3: unreviewed count surfaced" || bad "J3: unreviewed count wrong ($LINE1)"

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
if [ "$FAIL" -eq 0 ]; then
  exit 0
else
  exit 1
fi
