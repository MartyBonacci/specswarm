#!/bin/bash
# SpecSwarm Taste-Model Helper (v7.13.0 — AUTO-MAGIC epic, WS1)
#
# The taste model IS the memory corpus (epic decision D1): every distilled
# ruling is a feedback_*.md file — short name, one-line description, the rule,
# WHY, HOW-TO-APPLY. Compressed rules, never transcripts. This lib is the ONE
# writer all accretion sources share (AskUserQuestion answers, sighted-gate
# verdicts, /ss:intervention graduation, retrospective output) so every entry
# lands well-formed, deduplicated, and indexed.
#
# Origin lesson: rules survive sessions; transcripts don't. Answers that used
# to die in spec.md / decision-sheet.md now accrete into reusable rulings.
#
# Public API:
#   ss_taste_dir
#     Echoes the absolute path of the directory taste entries are written to.
#     Resolution order:
#       1. .specswarm/references.md "Memory directories" section, first entry
#       2. <repo_root>/memory/ if it exists with a sibling MEMORY.md
#       3. <repo_root>/.specswarm/memory/ (created if missing; becomes
#          load-bearing for consumption once /ss:init declares it in
#          references.md)
#
#   ss_taste_slug "<text>"
#     Filesystem-safe slug (lowercase, kebab, ≤40 chars).
#
#   ss_taste_exists <dir> <slug>
#     Returns 0 (and echoes the path) if feedback_<slug>.md already exists.
#
#   ss_taste_add <slug> <check-type> <source> <rule> <why> <how> [description]
#     Writes feedback_<slug>.md to ss_taste_dir and updates the MEMORY.md
#     index. check-type ∈ deterministic|judgment.
#       deterministic — mechanically checkable (a preflight check / generated
#                       hook can enforce it)
#       judgment      — needs a judging mind (spec-mentor loads these)
#     source = provenance string, e.g. "AskUserQuestion /ss:decisions D2
#     feature 004" or "sighted-gate verdict T012". Echoes the written path.
#     Duplicate slug → skips (idempotent), notes on stderr, still exit 0.
#     Invalid/missing args → exit 1 with reason on stderr.
#
#   ss_taste_index_update <dir> <filename> <description>
#     Appends a one-line pointer under "## Distilled Rules" in MEMORY.md
#     (in <dir> or its parent). Silent no-op when no index exists.
#
#   ss_taste_list [N]
#     Lists the last N (default 10) feedback entries with their check-type.

set -e

__SS_TASTE_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${__SS_TASTE_LIB}/references-loader.sh"

ss_taste_dir() {
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

  # 1. references.md memory dirs (first entry)
  local first_mem_dir
  first_mem_dir=$(ss_references_memory_dirs 2>/dev/null | head -n1)
  if [ -n "$first_mem_dir" ] && [ -d "$first_mem_dir" ]; then
    echo "$first_mem_dir"
    return 0
  fi

  # 2. <repo_root>/memory/ with sibling MEMORY.md
  if [ -d "${repo_root}/memory" ] && [ -f "${repo_root}/MEMORY.md" ]; then
    echo "${repo_root}/memory"
    return 0
  fi

  # 3. Project-local fallback
  local fallback="${repo_root}/.specswarm/memory"
  mkdir -p "$fallback" 2>/dev/null || true
  echo "$fallback"
}

ss_taste_slug() {
  local text="${1:-untitled}"
  echo "$text" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -c 'a-z0-9' '-' \
    | sed -E 's/-+/-/g; s/^-//; s/-$//' \
    | cut -c1-40
}

ss_taste_exists() {
  local dir="$1"
  local slug="$2"
  [ -z "$dir" ] || [ -z "$slug" ] && return 1
  # Filenames use underscores (memory-corpus convention); slugs use kebab.
  local fname="feedback_$(echo "$slug" | tr '-' '_').md"
  if [ -f "${dir%/}/${fname}" ]; then
    echo "${dir%/}/${fname}"
    return 0
  fi
  return 1
}

ss_taste_add() {
  local slug_raw="$1"
  local check_type="$2"
  local source_prov="$3"
  local rule="$4"
  local why="$5"
  local how="$6"
  local description="${7:-}"

  if [ -z "$slug_raw" ] || [ -z "$rule" ] || [ -z "$why" ] || [ -z "$how" ]; then
    echo "taste: missing required arg (need slug, rule, why, how)" >&2
    return 1
  fi
  case "$check_type" in
    deterministic|judgment) ;;
    *)
      echo "taste: check-type must be 'deterministic' or 'judgment' (got '${check_type}')" >&2
      return 1
      ;;
  esac

  local slug
  slug=$(ss_taste_slug "$slug_raw")
  [ -z "$slug" ] && { echo "taste: slug reduced to empty" >&2; return 1; }

  local dir
  dir=$(ss_taste_dir)

  # Dedup guard — accretion is idempotent per ruling name.
  local existing
  if existing=$(ss_taste_exists "$dir" "$slug"); then
    echo "taste: entry '${slug}' already exists, skipped (${existing})" >&2
    echo "$existing"
    return 0
  fi

  [ -z "$description" ] && description=$(echo "$rule" | head -n1 | head -c 100)

  local date_str
  date_str=$(date +%Y-%m-%d)
  local fname="feedback_$(echo "$slug" | tr '-' '_').md"
  local target="${dir%/}/${fname}"

  cat > "$target" <<EOF
---
name: ${slug}
description: ${description}
metadata:
  type: feedback
  check-type: ${check_type}
  source: ${source_prov:-unspecified}
  date: ${date_str}
---

${rule}

**Why:** ${why}

**How to apply:** ${how}
EOF

  ss_taste_index_update "$dir" "$fname" "$description"

  echo "$target"
}

ss_taste_index_update() {
  local dir="$1"
  local filename="$2"
  local description="$3"

  local parent
  parent=$(dirname "$dir")
  local index=""
  if [ -f "${dir}/MEMORY.md" ]; then
    index="${dir}/MEMORY.md"
  elif [ -f "${parent}/MEMORY.md" ]; then
    index="${parent}/MEMORY.md"
  fi

  [ -z "$index" ] && return 0  # No index file; silent OK

  # Avoid duplicate entries
  if grep -qF "$filename" "$index" 2>/dev/null; then
    return 0
  fi

  if ! grep -qE '^## Distilled Rules' "$index" 2>/dev/null; then
    printf '\n## Distilled Rules\n' >> "$index"
  fi

  local short_desc
  short_desc=$(echo "$description" | head -c 100 | tr '\n' ' ')
  local rel_path="${filename}"
  if [ "$(dirname "$index")" != "$dir" ]; then
    rel_path="$(basename "$dir")/${filename}"
  fi

  local tmp
  tmp=$(mktemp)
  awk -v entry="- [${short_desc}](${rel_path})" '
    /^## Distilled Rules/ {
      print
      print entry
      inserted = 1
      next
    }
    { print }
  ' "$index" > "$tmp" && mv "$tmp" "$index"
}

ss_taste_list() {
  local limit="${1:-10}"
  local dir
  dir=$(ss_taste_dir)

  local found=0
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    found=$((found + 1))
    local base desc ctype
    base=$(basename "$f")
    desc=$(grep -E '^description:' "$f" 2>/dev/null | head -n1 | sed -E 's/^description:[[:space:]]*//')
    ctype=$(grep -E '^[[:space:]]*check-type:' "$f" 2>/dev/null | head -n1 | sed -E 's/^[[:space:]]*check-type:[[:space:]]*//')
    printf "  %-14s  %s\n      %s\n" "[${ctype:-judgment}]" "$base" "${desc:-(no description)}"
  done < <(find "$dir" -maxdepth 1 -type f -name 'feedback_*.md' 2>/dev/null | sort -r | head -n "$limit")

  if [ "$found" -eq 0 ]; then
    echo "(no distilled rules yet)"
  fi
}
