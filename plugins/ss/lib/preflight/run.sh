#!/bin/bash
# SpecSwarm Preflight Orchestrator
#
# Runs all 7 deterministic preflight checks against a target plan.md (or any
# markdown file) and aggregates results. Designed to be called from the
# /ss:preflight slash command, from inside /ss:plan as a final validation step,
# or directly from CI.
#
# Project-agnostic: all checks discover project context via SpecSwarm's
# existing infrastructure (.specswarm/references.md, lockfiles, git root).
#
# Usage:
#   run.sh [path/to/plan.md]
#     If no path is given, auto-discovers the most recent feature's plan.md.
#
#   run.sh --json [path/to/plan.md]
#     Emit results as JSON (for CI / further automation).
#
#   run.sh --feature <num> [--quiet]
#     Resolve to the given feature number's plan.md.
#
# Exit codes:
#   0 — all checks passed (or only WARNs)
#   1 — at least one WARN
#   2 — at least one FAIL

set -e

PRE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_LIB="$(cd "${PRE_DIR}/.." && pwd)"
# shellcheck disable=SC1091
source "${PLUGIN_LIB}/features-location.sh"
# shellcheck disable=SC1091
[ -f "${PLUGIN_LIB}/notify.sh" ] && source "${PLUGIN_LIB}/notify.sh"

JSON_OUTPUT=false
QUIET=false
TARGET=""
FEATURE_NUM=""

while [ $# -gt 0 ]; do
  case "$1" in
    --json) JSON_OUTPUT=true; shift ;;
    --quiet) QUIET=true; shift ;;
    --feature) FEATURE_NUM="$2"; shift 2 ;;
    --help|-h)
      cat <<EOF
SpecSwarm preflight: deterministic checks for plan.md before /ss:implement.

Usage:
  $(basename "$0") [PATH]              Run against given plan.md path
  $(basename "$0") --feature NUM       Run against feature NUM's plan.md
  $(basename "$0") --json [PATH]       Emit JSON results
  $(basename "$0") --quiet [PATH]      Suppress per-check detail lines

Checks (each runs only if it can — graceful skip otherwise):
  • version-currency        — pinned versions exist in their registry (cached 24h)
  • memory-coverage         — referenced memory files exist; index has no orphans
  • spec-section-existence  — §X.Y refs resolve in spec corpus
  • grep-word-boundary      — grep patterns won't false-positive
  • heading-fidelity        — quoted headings match spec corpus verbatim
  • assumptions-provenance  — spec ## Assumptions entries carry source + status
  • ground-truth-bias       — evals against acceptance data address provenance

Exit codes: 0=pass, 1=warn, 2=fail.
EOF
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 2
      ;;
    *)
      TARGET="$1"; shift
      ;;
  esac
done

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Resolve TARGET
if [ -z "$TARGET" ] && [ -n "$FEATURE_NUM" ]; then
  if find_feature_dir "$FEATURE_NUM" "$REPO_ROOT"; then
    TARGET="${FEATURE_DIR}/plan.md"
  else
    echo "❌ Feature $FEATURE_NUM not found under .specswarm/features/" >&2
    exit 2
  fi
fi

if [ -z "$TARGET" ]; then
  # Auto-discover: pick the highest-numbered feature with a plan.md
  get_features_dir "$REPO_ROOT"
  if [ -d "$FEATURES_DIR" ]; then
    LATEST=$(find "$FEATURES_DIR" -maxdepth 2 -type f -name 'plan.md' 2>/dev/null \
      | sort | tail -1)
    if [ -n "$LATEST" ]; then
      TARGET="$LATEST"
    fi
  fi
fi

if [ -z "$TARGET" ] || [ ! -f "$TARGET" ]; then
  echo "❌ No plan.md found. Pass a path or use --feature NUM." >&2
  exit 2
fi

# Run all checks
CHECKS=(
  "version-currency"
  "memory-coverage"
  "spec-section-existence"
  "grep-word-boundary"
  "heading-fidelity"
  "assumptions-provenance"
  "ground-truth-bias"
)

declare -A STATUS
declare -A SUMMARY
declare -A DETAILS
OVERALL=0  # 0=pass, 1=warn, 2=fail

for name in "${CHECKS[@]}"; do
  script="${PRE_DIR}/checks/${name}.sh"
  if [ ! -x "$script" ] && [ -f "$script" ]; then
    chmod +x "$script" 2>/dev/null || true
  fi

  if [ ! -f "$script" ]; then
    STATUS[$name]="ERROR"
    SUMMARY[$name]="check script missing"
    continue
  fi

  output=$(bash "$script" "$TARGET" 2>&1 || true)
  first_line=$(echo "$output" | head -1)
  details=$(echo "$output" | tail -n +2)

  # Parse first line: "STATUS check-name: rest"
  status=$(echo "$first_line" | awk '{print $1}')
  summary=$(echo "$first_line" | sed -E 's/^[A-Z]+[[:space:]]+[a-z-]+:[[:space:]]*//')

  STATUS[$name]="$status"
  SUMMARY[$name]="$summary"
  DETAILS[$name]="$details"

  case "$status" in
    FAIL) [ "$OVERALL" -lt 2 ] && OVERALL=2 ;;
    WARN) [ "$OVERALL" -lt 1 ] && OVERALL=1 ;;
  esac
done

# JSON output mode
if [ "$JSON_OUTPUT" = true ]; then
  printf '{\n  "target": "%s",\n  "checks": {\n' "$TARGET"
  first=true
  for name in "${CHECKS[@]}"; do
    [ "$first" = false ] && printf ',\n'
    first=false
    # Escape details for JSON via jq
    details_json=$(printf '%s' "${DETAILS[$name]}" | jq -Rs . 2>/dev/null || echo '""')
    printf '    "%s": {"status":"%s","summary":%s,"details":%s}' \
      "$name" \
      "${STATUS[$name]}" \
      "$(printf '%s' "${SUMMARY[$name]}" | jq -Rs . 2>/dev/null || echo '""')" \
      "$details_json"
  done
  printf '\n  },\n  "overall": %d\n}\n' "$OVERALL"
  exit "$OVERALL"
fi

# Human-readable output
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SpecSwarm Preflight — $(basename "$(dirname "$TARGET")")/$(basename "$TARGET")"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

for name in "${CHECKS[@]}"; do
  case "${STATUS[$name]}" in
    PASS) icon="✅"; PASS_COUNT=$((PASS_COUNT + 1)) ;;
    WARN) icon="⚠️ "; WARN_COUNT=$((WARN_COUNT + 1)) ;;
    FAIL) icon="🚫"; FAIL_COUNT=$((FAIL_COUNT + 1)) ;;
    *)    icon="❓" ;;
  esac
  printf "%s  %-26s %s\n" "$icon" "$name" "${SUMMARY[$name]}"
  if [ "$QUIET" != true ] && [ -n "${DETAILS[$name]}" ]; then
    echo "${DETAILS[$name]}" | sed 's/^/     /'
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "Summary: %d passed, %d warning(s), %d blocked\n" "$PASS_COUNT" "$WARN_COUNT" "$FAIL_COUNT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Fire a notification on FAIL so users who stepped away know they're needed.
# Silently no-ops if no notification mechanism is available.
if [ "$OVERALL" -eq 2 ] && declare -f ss_notify >/dev/null 2>&1; then
  feature_name=$(basename "$(dirname "$TARGET")")
  ss_notify urgent "SpecSwarm preflight blocked" \
    "${feature_name}: ${FAIL_COUNT} check(s) failed — review before /ss:implement" || true
fi

exit "$OVERALL"
