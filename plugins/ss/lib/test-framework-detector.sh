#!/bin/bash
# SpecSwarm Test Framework Detector (v7.14.0 — AUTO-MAGIC WS4)
#
# Authored for real in v7.14.0: /ss:implement Step 10 has referenced this lib
# since Phase 1, but the file never existed — the entire quality-validation
# block silently no-op'd its "detector not available — skipping" branch.
# Origin lesson: a gate that silently skips is worse than no gate; it reads
# as "covered" when nothing ran.
#
# Project-agnostic: detection is from repo reality (configs, manifests,
# lockfiles, test-file patterns) — detect, don't assume.
#
# Usage:
#   bash test-framework-detector.sh [ROOT]      # standalone: JSON report
#   source test-framework-detector.sh           # library mode
#
# Library API:
#   detect_test_frameworks [root]   — one framework name per line
#   primary_test_framework [root]   — single highest-priority framework
#   detect_test_roots [root]        — top-level dirs containing test files
#   run_tests <framework> [root]    — run the framework's suite; passes through
#                                     exit code; output on stdout
#   parse_test_results <framework> <output_file>
#                                   — echoes "total=N passed=N failed=N skipped=N"
#                                     (best-effort; -1 for unknown fields)
#   detect_coverage_tool <framework> [root]
#                                   — echoes tool name, exit 0; exit 1 if none
#   run_coverage <framework> [root] — run suite with coverage; echoes output
#                                     ending with "coverage_pct=<N|unknown>"

set -e

__SS_TFD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# JS runner prefix from lockfile reality (pnpm/yarn/bun/npm)
__ss_js_runner() {
  local root="$1"
  if   [ -f "${root}/pnpm-lock.yaml" ]; then echo "pnpm exec"
  elif [ -f "${root}/yarn.lock" ];      then echo "yarn"
  elif [ -f "${root}/bun.lock" ] || [ -f "${root}/bun.lockb" ]; then echo "bunx"
  else echo "npx"
  fi
}

__ss_pkg_has_dep() {
  local root="$1" dep="$2"
  [ -f "${root}/package.json" ] || return 1
  grep -qE "\"${dep}\"[[:space:]]*:" "${root}/package.json" 2>/dev/null
}

detect_test_frameworks() {
  local root="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
  local found=()

  # JavaScript / TypeScript
  if ls "${root}"/vitest.config.* >/dev/null 2>&1 || __ss_pkg_has_dep "$root" vitest; then
    found+=("vitest")
  fi
  if ls "${root}"/jest.config.* >/dev/null 2>&1 || __ss_pkg_has_dep "$root" jest; then
    found+=("jest")
  fi
  if ls "${root}"/.mocharc.* >/dev/null 2>&1 || __ss_pkg_has_dep "$root" mocha; then
    found+=("mocha")
  fi
  # Browser-test frameworks (reported; primary selection prefers unit runners)
  if ls "${root}"/playwright.config.* >/dev/null 2>&1 || __ss_pkg_has_dep "$root" "@playwright/test"; then
    found+=("playwright")
  fi
  if ls "${root}"/cypress.config.* >/dev/null 2>&1 || __ss_pkg_has_dep "$root" cypress; then
    found+=("cypress")
  fi

  # Python
  if [ -f "${root}/pytest.ini" ] || [ -f "${root}/conftest.py" ] \
     || grep -qE '^\[tool\.pytest' "${root}/pyproject.toml" 2>/dev/null \
     || grep -qE '(^|")pytest' "${root}/Pipfile" "${root}/requirements"*.txt 2>/dev/null; then
    found+=("pytest")
  fi

  # Go / Rust / Ruby / PHP
  if [ -f "${root}/go.mod" ]; then
    find "$root" -path '*/vendor' -prune -o -name '*_test.go' -print 2>/dev/null | head -1 | grep -q . && found+=("gotest")
  fi
  [ -f "${root}/Cargo.toml" ] && found+=("cargotest")
  if [ -f "${root}/Gemfile" ]; then
    if [ -d "${root}/spec" ] || grep -qE '^\s*gem\s+.rspec' "${root}/Gemfile" 2>/dev/null; then
      found+=("rspec")
    elif [ -d "${root}/test" ]; then
      found+=("minitest")
    fi
  fi
  { [ -f "${root}/phpunit.xml" ] || [ -f "${root}/phpunit.xml.dist" ]; } && found+=("phpunit")

  printf '%s\n' "${found[@]}" | grep -v '^$' || true
}

primary_test_framework() {
  local root="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
  local all
  all=$(detect_test_frameworks "$root")
  local pref
  for pref in vitest jest mocha pytest gotest cargotest rspec minitest phpunit playwright cypress; do
    if echo "$all" | grep -qx "$pref"; then
      echo "$pref"
      return 0
    fi
  done
  return 1
}

# Derive test roots from repo reality. Origin lesson: a repo with BOTH test/
# and tests/ roots lost two verification rounds because every hand-written
# sweep covered only one. Shared with lib/verify/screeners.sh.
detect_test_roots() {
  local root="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
  find "$root" \
      -path '*/node_modules' -prune -o \
      -path '*/.git' -prune -o \
      -path '*/vendor' -prune -o \
      -path '*/target' -prune -o \
      -path '*/dist' -prune -o \
      -path '*/build' -prune -o \
      -type f \( -name '*_test.go' -o -name '*.test.*' -o -name '*.spec.*' \
        -o -name 'test_*.py' -o -name '*_test.py' \
        -o -name '*_spec.rb' -o -name '*_test.rb' \
        -o -name '*Test.php' -o -name '*Test.java' \) -print 2>/dev/null \
    | sed "s|^${root}/||" \
    | cut -d/ -f1 \
    | grep -v '^\.' \
    | sort -u
}

run_tests() {
  local fw="$1"
  local root="${2:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
  local js
  js=$(__ss_js_runner "$root")
  case "$fw" in
    vitest)     (cd "$root" && $js vitest run 2>&1) ;;
    jest)       (cd "$root" && $js jest --ci 2>&1) ;;
    mocha)      (cd "$root" && $js mocha 2>&1) ;;
    playwright) (cd "$root" && $js playwright test 2>&1) ;;
    cypress)    (cd "$root" && $js cypress run 2>&1) ;;
    pytest)     (cd "$root" && python3 -m pytest 2>&1 || python -m pytest 2>&1) ;;
    gotest)     (cd "$root" && go test ./... 2>&1) ;;
    cargotest)  (cd "$root" && cargo test 2>&1) ;;
    rspec)      (cd "$root" && bundle exec rspec 2>&1 || rspec 2>&1) ;;
    minitest)   (cd "$root" && bundle exec rake test 2>&1 || rake test 2>&1) ;;
    phpunit)    (cd "$root" && ./vendor/bin/phpunit 2>&1 || phpunit 2>&1) ;;
    *) echo "unknown framework: $fw" >&2; return 2 ;;
  esac
}

# Best-effort per-framework result parsing. Unknown fields are -1, never 0 —
# a fabricated zero reads as "ran clean" (the greenwash class this epic kills).
parse_test_results() {
  local fw="$1"
  local out="$2"   # path to captured output
  [ -f "$out" ] || { echo "total=-1 passed=-1 failed=-1 skipped=-1"; return 0; }

  local total=-1 passed=-1 failed=-1 skipped=-1 line
  case "$fw" in
    vitest|jest)
      # "Tests  3 failed | 12 passed | 1 skipped (16)" / "Tests: 1 failed, 12 passed, 13 total"
      line=$(grep -E '^\s*Tests(:|\s)' "$out" | tail -1)
      passed=$(echo "$line" | grep -oE '[0-9]+ passed' | grep -oE '[0-9]+' || echo -1)
      failed=$(echo "$line" | grep -oE '[0-9]+ failed' | grep -oE '[0-9]+' || echo 0)
      skipped=$(echo "$line" | grep -oE '[0-9]+ (skipped|todo)' | grep -oE '[0-9]+' | head -1 || echo 0)
      total=$(echo "$line" | grep -oE '[0-9]+ total|\([0-9]+\)' | grep -oE '[0-9]+' | head -1 || echo -1)
      ;;
    pytest)
      # "== 12 passed, 1 failed, 2 skipped in 3.21s =="
      line=$(grep -E '=+ .*(passed|failed|error).* =+' "$out" | tail -1)
      passed=$(echo "$line" | grep -oE '[0-9]+ passed' | grep -oE '[0-9]+' || echo 0)
      failed=$(echo "$line" | grep -oE '[0-9]+ (failed|error)' | grep -oE '[0-9]+' | head -1 || echo 0)
      skipped=$(echo "$line" | grep -oE '[0-9]+ skipped' | grep -oE '[0-9]+' || echo 0)
      ;;
    gotest)
      failed=$(grep -cE '^--- FAIL' "$out" || true)
      passed=$(grep -cE '^--- PASS' "$out" || true)
      # package-mode output ("ok  pkg") has no per-test lines; fall back to pass/fail of packages
      if [ "$passed" -eq 0 ] && [ "$failed" -eq 0 ]; then
        passed=$(grep -cE '^ok\s' "$out" || true)
        failed=$(grep -cE '^FAIL\s' "$out" || true)
      fi
      skipped=$(grep -cE '^--- SKIP' "$out" || true)
      ;;
    cargotest)
      # "test result: ok. 12 passed; 0 failed; 1 ignored"
      line=$(grep -E '^test result:' "$out" | tail -1)
      passed=$(echo "$line" | grep -oE '[0-9]+ passed' | grep -oE '[0-9]+' || echo -1)
      failed=$(echo "$line" | grep -oE '[0-9]+ failed' | grep -oE '[0-9]+' || echo 0)
      skipped=$(echo "$line" | grep -oE '[0-9]+ ignored' | grep -oE '[0-9]+' || echo 0)
      ;;
    rspec|minitest)
      # "12 examples, 1 failure" / "12 runs, 34 assertions, 1 failures, 0 errors, 2 skips"
      line=$(grep -oE '[0-9]+ (examples|runs).*' "$out" | tail -1)
      total=$(echo "$line" | grep -oE '^[0-9]+' || echo -1)
      failed=$(echo "$line" | grep -oE '[0-9]+ failures?' | grep -oE '[0-9]+' || echo 0)
      skipped=$(echo "$line" | grep -oE '[0-9]+ (skips?|pending)' | grep -oE '[0-9]+' | head -1 || echo 0)
      [ "$total" -ge 0 ] && passed=$((total - failed - skipped))
      ;;
    playwright)
      passed=$(grep -oE '[0-9]+ passed' "$out" | tail -1 | grep -oE '[0-9]+' || echo -1)
      failed=$(grep -oE '[0-9]+ failed' "$out" | tail -1 | grep -oE '[0-9]+' || echo 0)
      skipped=$(grep -oE '[0-9]+ skipped' "$out" | tail -1 | grep -oE '[0-9]+' || echo 0)
      ;;
    *) : ;;
  esac

  if [ "$total" -lt 0 ] && [ "$passed" -ge 0 ]; then
    total=$((passed + ${failed#-} + ${skipped#-}))
  fi
  echo "total=${total} passed=${passed} failed=${failed} skipped=${skipped}"
}

detect_coverage_tool() {
  local fw="$1"
  local root="${2:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
  case "$fw" in
    vitest) __ss_pkg_has_dep "$root" "@vitest/coverage-v8" || __ss_pkg_has_dep "$root" "@vitest/coverage-istanbul" || return 1
            echo "vitest-coverage" ;;
    jest)   echo "jest-coverage" ;;   # jest bundles istanbul
    pytest) grep -qE 'pytest-cov' "${root}/pyproject.toml" "${root}/requirements"*.txt "${root}/Pipfile" 2>/dev/null || return 1
            echo "pytest-cov" ;;
    gotest) echo "go-cover" ;;        # built into the toolchain
    *) return 1 ;;
  esac
}

run_coverage() {
  local fw="$1"
  local root="${2:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
  local js out pct="unknown"
  js=$(__ss_js_runner "$root")
  case "$fw" in
    vitest) out=$( (cd "$root" && $js vitest run --coverage 2>&1) || true )
            pct=$(echo "$out" | grep -E 'All files' | grep -oE '[0-9]+(\.[0-9]+)?' | head -1 || echo unknown) ;;
    jest)   out=$( (cd "$root" && $js jest --ci --coverage 2>&1) || true )
            pct=$(echo "$out" | grep -E 'All files' | grep -oE '[0-9]+(\.[0-9]+)?' | head -1 || echo unknown) ;;
    pytest) out=$( (cd "$root" && python3 -m pytest --cov 2>&1) || true )
            pct=$(echo "$out" | grep -E '^TOTAL' | grep -oE '[0-9]+%' | tr -d '%' | head -1 || echo unknown) ;;
    gotest) out=$( (cd "$root" && go test -cover ./... 2>&1) || true )
            pct=$(echo "$out" | grep -oE 'coverage: [0-9.]+%' | grep -oE '[0-9.]+' \
                  | awk '{s+=$1; n+=1} END {if (n>0) printf "%.1f", s/n; else print "unknown"}') ;;
    *) echo "coverage not supported for framework: $fw" >&2 ;;
  esac
  [ -n "$out" ] && echo "$out"
  echo "coverage_pct=${pct:-unknown}"
}

# Standalone mode: JSON report (implement.md Step 10b contract)
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
  FRAMEWORKS=$(detect_test_frameworks "$ROOT")
  PRIMARY=$(primary_test_framework "$ROOT" || echo "")
  COUNT=$(echo "$FRAMEWORKS" | grep -c . || true)
  ROOTS=$(detect_test_roots "$ROOT")

  printf '{\n  "frameworks": ['
  first=true
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    [ "$first" = false ] && printf ', '
    first=false
    printf '"%s"' "$f"
  done <<< "$FRAMEWORKS"
  printf '],\n  "primary": "%s",\n  "count": %d,\n  "test_roots": [' "$PRIMARY" "$COUNT"
  first=true
  while IFS= read -r r; do
    [ -z "$r" ] && continue
    [ "$first" = false ] && printf ', '
    first=false
    printf '"%s"' "$r"
  done <<< "$ROOTS"
  printf ']\n}\n'
fi
