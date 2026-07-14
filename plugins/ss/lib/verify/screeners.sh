#!/bin/bash
# SpecSwarm Verify-Time Diff Screeners (v7.14.0 — AUTO-MAGIC WS4/WS5)
#
# Deterministic classifiers that run over a task's diff BEFORE spec-mentor
# dispatch. Each screener is cheap (grep over paths + diff text) and, when it
# fires, emits a CLAUSE line that /ss:verify injects into spec-mentor's
# context — the deterministic half detects applicability, the judgment half
# (spec-mentor) enforces the requirement.
#
# Origin lessons (each screener carries its own):
#   sighted       — every false-green that reached the product owner was a
#                   UI/visual/3D slice: correct DOM + green suites, visually
#                   wrong result. These need human eyes, not just PASS.
#   geometry      — symmetric fixtures are their own mirror image and
#                   mathematically cannot catch axis/orientation bugs. A
#                   y-inversion and a nose/tail label swap both survived
#                   green suites in production.
#   roundtrip     — encode/decode tests that only assert round-trip identity
#                   stay green when both directions share the same convention
#                   bug. At least one OFF-MODULE physical truth is required.
#   fixture-shape — schema-derived fixtures pass while production data fails;
#                   fixtures must mirror what the PRODUCTION writer emits.
#   test-globs    — a repo had both test/ and tests/ roots; every hand-written
#                   targeted sweep covered only one, costing two verification
#                   rounds. Sweeps must cover every detected test root.
#
# Public API:
#   ss_screen_diff <changed_files_file> <diff_file> [repo_root]
#     changed_files_file: one changed path per line (git diff --name-only)
#     diff_file:          the unified diff text
#     Prints, one per line:
#       SIGHTED yes <reason>            (at most once; absent when not sighted)
#       CLAUSE <name>: <requirement>    (0..N; inject verbatim into spec-mentor)
#     Always exits 0.
#
#   ss_screen_sighted <changed_files_file>
#     Exit 0 + echoes reason if the file set touches UI/visual/3D/rendering
#     surfaces; exit 1 otherwise.
#
#   ss_detect_test_roots [repo_root]
#     Echoes each top-level directory containing test-pattern files, one per
#     line (e.g. "test", "tests", "src" for co-located *.test.ts).

set -e

# ── Sighted classifier (WS5) ────────────────────────────────────────────────
# Path/extension/component patterns only — cheap by design.

__SS_SIGHTED_EXT='\.(css|scss|sass|less|styl|svg|glsl|vert|frag|wgsl|html)$'
__SS_SIGHTED_COMPONENT='\.(tsx|jsx|vue|svelte)$'
__SS_SIGHTED_PATH='(^|/)(components?|ui|views?|pages?|layouts?|styles?|themes?|shaders?|animations?)(/|$)|three|webgl|canvas'
__SS_TESTLIKE='(^|/)(__tests__|__fixtures__|fixtures|testdata|test|tests|spec)(/|$)|\.(test|spec|stories)\.|\.server\.'

ss_screen_sighted() {
  local files_file="$1"
  [ -f "$files_file" ] || return 1

  local hits
  hits=$(grep -vE "$__SS_TESTLIKE" "$files_file" 2>/dev/null \
    | grep -E "${__SS_SIGHTED_EXT}|${__SS_SIGHTED_COMPONENT}" || true)
  if [ -z "$hits" ]; then
    hits=$(grep -vE "$__SS_TESTLIKE" "$files_file" 2>/dev/null \
      | grep -iE "$__SS_SIGHTED_PATH" || true)
  fi

  [ -z "$hits" ] && return 1
  local count first
  count=$(echo "$hits" | wc -l)
  first=$(echo "$hits" | head -n1)
  echo "${count} visual-surface file(s), e.g. ${first}"
  return 0
}

# ── Test-root detection (WS4 test-glob reality) ─────────────────────────────

__SS_TEST_FILE_PATTERNS=(
  -name '*_test.go' -o -name '*.test.*' -o -name '*.spec.*'
  -o -name 'test_*.py' -o -name '*_test.py'
  -o -name '*_spec.rb' -o -name '*_test.rb'
  -o -name '*Test.php' -o -name '*Test.java'
)

ss_detect_test_roots() {
  local root="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
  [ -d "$root" ] || return 0
  find "$root" \
      -path '*/node_modules' -prune -o \
      -path '*/.git' -prune -o \
      -path '*/vendor' -prune -o \
      -path '*/target' -prune -o \
      -path '*/dist' -prune -o \
      -path '*/build' -prune -o \
      -type f \( "${__SS_TEST_FILE_PATTERNS[@]}" \) -print 2>/dev/null \
    | sed "s|^${root}/||" \
    | cut -d/ -f1 \
    | grep -v '^\.' \
    | sort -u
}

# ── Diff-content screeners (WS4.3 / WS4.4 / WS4.5) ──────────────────────────

__SS_GEOMETRY_RE='rotat|mirror|flip|invert|coordinat|orientation|quaternion|matrix|axis|degrees|radians|clockwise'
__SS_ROUNDTRIP_RE='encode|decode|serializ|deserializ|toJSON|fromJSON|marshal|unmarshal|stringify.*parse|parse.*stringify'
__SS_FIXTURE_RE='(^|/)(__fixtures__|fixtures|testdata)(/|$)|\.fixture\.|fixtures?\.(ts|js|py|go|rb|json)$'

ss_screen_diff() {
  local files_file="$1"
  local diff_file="$2"
  local root="${3:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

  [ -f "$files_file" ] || return 0

  # WS5: sighted classification
  local reason
  if reason=$(ss_screen_sighted "$files_file"); then
    echo "SIGHTED yes ${reason}"
    echo "CLAUSE sighted: This slice touches visual surfaces. A PASS verdict here covers spec conformance ONLY — it does not clear the slice; it will be held as NEEDS-SIGHTED for human review (including reading the browser console) before ship."
  fi

  # WS4.3: geometry/orientation — only added/changed lines, non-test files
  if [ -f "$diff_file" ]; then
    local changed_src
    changed_src=$(grep -E '^[+-]' "$diff_file" 2>/dev/null | grep -vE '^(\+\+\+|---)' || true)
    if echo "$changed_src" | grep -qiE "$__SS_GEOMETRY_RE"; then
      echo "CLAUSE geometry: This diff touches coordinate/orientation/mirror logic. REQUIRE at least one test fixture that is asymmetric in every relevant axis, plus an explicit flip/inversion test. Symmetric fixtures are their own mirror image and cannot catch axis bugs — flag DRIFT if only symmetric fixtures exist."
    fi

    # WS4.4: round-trip greenwash
    if echo "$changed_src" | grep -qiE "$__SS_ROUNDTRIP_RE"; then
      echo "CLAUSE roundtrip: This diff touches encode/decode or transform logic. REQUIRE at least one test asserting an OFF-MODULE physical truth (a hand-computed expected value or output from the canonical producer) — round-trip identity alone stays green when both directions share the same convention bug. Flag DRIFT if all transform tests are round-trip-only."
    fi
  fi

  # WS4.5: fixture-shape-mirrors-writer
  if grep -qiE "$__SS_FIXTURE_RE" "$files_file" 2>/dev/null; then
    echo "CLAUSE fixture-shape: This diff changes test fixtures. REQUIRE that fixture shapes mirror what the PRODUCTION writer actually emits (grep the writer's output construction, not the schema) — schema-derived fixtures pass while production data fails. Flag DRIFT if a fixture field set diverges from the writer's."
  fi

  # WS4: test-glob reality — multiple test roots means targeted sweeps are risky
  local roots
  roots=$(ss_detect_test_roots "$root")
  local root_count
  root_count=$(echo "$roots" | grep -c . || true)
  if [ "$root_count" -gt 1 ]; then
    echo "CLAUSE test-globs: This repo has ${root_count} distinct test roots ($(echo "$roots" | tr '\n' ' ' | sed 's/ $//')). Any targeted test sweep MUST use globs covering ALL roots that contain files relevant to this diff — flag DRIFT if the task's test run visibly targeted only a subset."
  fi

  return 0
}
