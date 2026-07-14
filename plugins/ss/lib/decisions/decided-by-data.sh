#!/bin/bash
# SpecSwarm DECIDED-BY-DATA Marker Scanner (v7.16.0 — AUTO-MAGIC WS8)
#
# Specs and plans may defer a genuine fork to a named metric instead of
# forcing a premature ruling:
#
#   [DECIDED-BY-DATA: signup-conversion-rate, 2 weeks post-launch]
#                     └── metric ──────────┘  └── review-when ──┘
#
# Origin lesson: some forks have no defensible answer at spec time — the
# honest move is to name the deciding metric and the review point, ship the
# cheap default, and let the data rule. The marker makes that deferral
# trackable instead of forgotten.
#
# Public API:
#   ss_dbd_scan <file> [file...]
#     Scans files for markers. Echoes one TSV record per marker:
#       file<TAB>line<TAB>metric<TAB>review_when
#     Silent (exit 0) when none found.
#
#   ss_dbd_scan_feature <feature_dir>
#     Convenience: scans the feature's spec.md + plan.md (whichever exist).

set -e

ss_dbd_scan() {
  local f
  for f in "$@"; do
    [ -f "$f" ] || continue
    grep -nE '\[DECIDED-BY-DATA:' "$f" 2>/dev/null | while IFS=: read -r lineno rest; do
      # Extract the bracket body: "metric, review-when"
      local body metric review
      body=$(echo "$rest" | sed -E 's/.*\[DECIDED-BY-DATA:[[:space:]]*//; s/\].*//')
      metric=$(echo "$body" | cut -d, -f1 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
      review=$(echo "$body" | cut -s -d, -f2- | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
      [ -z "$metric" ] && continue
      printf '%s\t%s\t%s\t%s\n' "$f" "$lineno" "$metric" "${review:-unspecified}"
    done
  done
  return 0
}

ss_dbd_scan_feature() {
  local dir="$1"
  [ -d "$dir" ] || return 0
  local targets=()
  [ -f "${dir}/spec.md" ] && targets+=("${dir}/spec.md")
  [ -f "${dir}/plan.md" ] && targets+=("${dir}/plan.md")
  [ "${#targets[@]}" -eq 0 ] && return 0
  ss_dbd_scan "${targets[@]}"
}
