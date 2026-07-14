#!/bin/bash
# SpecSwarm Quality Gates (v7.14.0 — AUTO-MAGIC WS4, epic decision D4)
#
# Authored for real in v7.14.0: /ss:implement Step 10e has sourced this lib
# since Phase 1, but the file never existed — browser-test detection silently
# no-op'd. Now also home to the per-slice build+lint gates.
#
# Origin lessons:
#   build gate  — framework-boundary breaks (e.g. React Router v7 `.server`
#                 modules) are invisible to typecheck AND unit tests; only the
#                 production build catches them.
#   lint gate   — a real ship was halted at the very end by lint errors in
#                 unwired code; catching them at ship means archaeology,
#                 catching them per slice means a 30-second fix.
#
# Project-agnostic: commands are DETECTED from repo manifests (package.json
# scripts, Makefile targets, Cargo.toml, go.mod, linter configs) — never
# assumed from stack conventions.
#
# Public API (source this file):
#   detect_browser_test_framework [root]
#     Echoes "playwright" | "cypress" | "none".
#
#   detect_build_command [root]
#     Echoes the production build command, or nothing (exit 1) if none found.
#
#   detect_lint_command [root]
#     Echoes the lint command, or nothing (exit 1) if none found.
#
#   run_slice_gates [root]
#     Runs build + lint synchronously. Honors SPECSWARM_SLICE_GATES:
#       block (default) — failure prints FAIL and exits 2 (halt the task loop;
#                         the failure becomes a fix task before proceeding)
#       warn            — failure prints WARN and exits 1 (surfaced, not fatal)
#       off             — prints PASS-skip and exits 0 without running anything
#     Output contract: first line "PASS|WARN|FAIL slice-gates: <summary>",
#     then indented details (same grammar as preflight checks).
#     WARN-on-zero: manifests exist but no build AND no lint command is
#     detectable → WARN (applicable-but-empty); no manifests at all → PASS-skip.

set -e

detect_browser_test_framework() {
  local root="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
  if ls "${root}"/playwright.config.* >/dev/null 2>&1 \
     || grep -qE '"@playwright/test"[[:space:]]*:' "${root}/package.json" 2>/dev/null; then
    echo "playwright"
  elif ls "${root}"/cypress.config.* >/dev/null 2>&1 \
     || grep -qE '"cypress"[[:space:]]*:' "${root}/package.json" 2>/dev/null; then
    echo "cypress"
  else
    echo "none"
  fi
}

__ss_qg_pm_run() {
  local root="$1"
  if   [ -f "${root}/pnpm-lock.yaml" ]; then echo "pnpm run"
  elif [ -f "${root}/yarn.lock" ];      then echo "yarn"
  elif [ -f "${root}/bun.lock" ] || [ -f "${root}/bun.lockb" ]; then echo "bun run"
  else echo "npm run"
  fi
}

__ss_pkg_has_script() {
  local root="$1" script="$2"
  [ -f "${root}/package.json" ] || return 1
  # Look inside the "scripts" block only (crude but dependency-free)
  awk '/"scripts"[[:space:]]*:/{inb=1} inb{print} inb && /}/{exit}' "${root}/package.json" 2>/dev/null \
    | grep -qE "\"${script}\"[[:space:]]*:"
}

__ss_makefile_has_target() {
  local root="$1" target="$2"
  [ -f "${root}/Makefile" ] || return 1
  grep -qE "^${target}[[:space:]]*:" "${root}/Makefile" 2>/dev/null
}

detect_build_command() {
  local root="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
  if __ss_pkg_has_script "$root" build; then
    echo "$(__ss_qg_pm_run "$root") build"
  elif __ss_makefile_has_target "$root" build; then
    echo "make build"
  elif [ -f "${root}/Cargo.toml" ]; then
    echo "cargo build"
  elif [ -f "${root}/go.mod" ]; then
    echo "go build ./..."
  else
    return 1
  fi
}

detect_lint_command() {
  local root="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
  if [ -f "${root}/biome.json" ] || [ -f "${root}/biome.jsonc" ]; then
    echo "npx biome check ."
  elif __ss_pkg_has_script "$root" lint; then
    echo "$(__ss_qg_pm_run "$root") lint"
  elif ls "${root}"/.eslintrc* >/dev/null 2>&1 || ls "${root}"/eslint.config.* >/dev/null 2>&1; then
    echo "npx eslint ."
  elif [ -f "${root}/ruff.toml" ] || grep -qE '^\[tool\.ruff' "${root}/pyproject.toml" 2>/dev/null; then
    echo "ruff check ."
  elif [ -f "${root}/.flake8" ]; then
    echo "flake8"
  elif [ -f "${root}/go.mod" ]; then
    echo "go vet ./..."
  elif [ -f "${root}/.rubocop.yml" ]; then
    echo "rubocop"
  else
    return 1
  fi
}

run_slice_gates() {
  local root="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
  local mode="${SPECSWARM_SLICE_GATES:-block}"

  case "$mode" in
    off)
      echo "PASS slice-gates: skipped (SPECSWARM_SLICE_GATES=off)"
      return 0
      ;;
    block|warn) : ;;
    *)
      echo "WARN slice-gates: unknown SPECSWARM_SLICE_GATES='${mode}' — treating as block"
      mode="block"
      ;;
  esac

  # No manifests at all → not applicable → clean PASS-skip
  if [ ! -f "${root}/package.json" ] && [ ! -f "${root}/Makefile" ] \
     && [ ! -f "${root}/Cargo.toml" ] && [ ! -f "${root}/go.mod" ] \
     && [ ! -f "${root}/pyproject.toml" ] && [ ! -f "${root}/Gemfile" ]; then
    echo "PASS slice-gates: skipped (no build manifest detected)"
    return 0
  fi

  local build_cmd lint_cmd
  build_cmd=$(detect_build_command "$root" || true)
  lint_cmd=$(detect_lint_command "$root" || true)

  # WARN-on-zero: manifests exist but nothing detectable to run
  if [ -z "$build_cmd" ] && [ -z "$lint_cmd" ]; then
    echo "WARN slice-gates: manifests present but no build or lint command detectable — is this expected?"
    return 1
  fi

  local failures=()
  local ran=()

  if [ -n "$build_cmd" ]; then
    ran+=("build: ${build_cmd}")
    if ! (cd "$root" && eval "$build_cmd") > /tmp/ss-slice-build.$$ 2>&1; then
      failures+=("build failed (${build_cmd}) — tail:")
      failures+=("$(tail -n 15 /tmp/ss-slice-build.$$ | sed 's/^/    /')")
    fi
    rm -f /tmp/ss-slice-build.$$
  fi

  if [ -n "$lint_cmd" ]; then
    ran+=("lint: ${lint_cmd}")
    if ! (cd "$root" && eval "$lint_cmd") > /tmp/ss-slice-lint.$$ 2>&1; then
      failures+=("lint failed (${lint_cmd}) — tail:")
      failures+=("$(tail -n 15 /tmp/ss-slice-lint.$$ | sed 's/^/    /')")
    fi
    rm -f /tmp/ss-slice-lint.$$
  fi

  if [ "${#failures[@]}" -gt 0 ]; then
    if [ "$mode" = "warn" ]; then
      echo "WARN slice-gates: ${#failures[@]} gate failure(s) (SPECSWARM_SLICE_GATES=warn)"
    else
      echo "FAIL slice-gates: gate failure — fix before proceeding to the next task"
    fi
    printf '  %s\n' "${failures[@]}"
    [ "$mode" = "warn" ] && return 1
    return 2
  fi

  echo "PASS slice-gates: $(IFS='; '; echo "${ran[*]}")"
  return 0
}
