#!/bin/bash
# SpecSwarm Bakeoff Helper (v7.16.0 — AUTO-MAGIC WS7)
#
# Deterministic plumbing for the /ss:bakeoff calibration loop: generate N
# candidates → contact sheet → human verdict → distilled taste ruling →
# pinned winner. Run by hand ~15 times in production, this loop was the
# single most effective pattern for converting fuzzy judgment into
# deterministic constants.
#
# Public API:
#   ss_bakeoff_dir <feature_dir> <slug>
#     Echoes (and creates) the bakeoff workspace:
#     <feature_dir>/bakeoff/<slug>/
#
#   ss_bakeoff_slug "<text>"
#     Filesystem-safe kebab slug (≤40 chars).
#
#   ss_bakeoff_sheet <bakeoff_dir> <title>
#     Assembles <bakeoff_dir>/contact-sheet.md from the candidate
#     subdirectories (candidate-1/, candidate-2/, …). Per candidate:
#       - a "## Candidate N" section
#       - the candidate's NOTES.md content (its self-description), if present
#       - every *.png/*.jpg embedded as a relative image link
#       - every other regular file inlined as a fenced code block
#         (truncated to 120 lines with an explicit truncation notice —
#         no silent caps)
#     Echoes the sheet path. Errors (exit 1) if no candidate dirs exist.

set -e

ss_bakeoff_slug() {
  local text="${1:-untitled}"
  echo "$text" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -c 'a-z0-9' '-' \
    | sed -E 's/-+/-/g; s/^-//; s/-$//' \
    | cut -c1-40
}

ss_bakeoff_dir() {
  local feature_dir="$1"
  local slug="$2"
  [ -z "$feature_dir" ] || [ -z "$slug" ] && return 1
  local dir="${feature_dir%/}/bakeoff/${slug}"
  mkdir -p "$dir" 2>/dev/null
  echo "$dir"
}

ss_bakeoff_sheet() {
  local bdir="$1"
  local title="${2:-Bakeoff}"
  [ -d "$bdir" ] || return 1

  local candidates
  candidates=$(find "$bdir" -maxdepth 1 -type d -name 'candidate-*' 2>/dev/null | sort -V)
  if [ -z "$candidates" ]; then
    echo "bakeoff: no candidate-* directories in ${bdir}" >&2
    return 1
  fi

  local sheet="${bdir%/}/contact-sheet.md"
  {
    echo "# Contact Sheet — ${title}"
    echo ""
    echo "_One section per candidate. Review side by side; verdicts are captured by /ss:bakeoff and distilled into the taste model._"

    local cdir n
    while IFS= read -r cdir; do
      [ -z "$cdir" ] && continue
      n=$(basename "$cdir" | sed 's/^candidate-//')
      echo ""
      echo "## Candidate ${n}"
      echo ""

      if [ -f "${cdir}/NOTES.md" ]; then
        cat "${cdir}/NOTES.md"
        echo ""
      fi

      local f rel
      while IFS= read -r f; do
        [ -z "$f" ] && continue
        rel="${f#"${bdir}"/}"
        case "$f" in
          */NOTES.md) : ;;
          *.png|*.jpg|*.jpeg|*.gif|*.webp)
            echo "![candidate ${n} — $(basename "$f")](${rel})"
            echo ""
            ;;
          *)
            echo "**\`${rel#candidate-${n}/}\`**"
            echo ""
            echo '```'
            head -n 120 "$f"
            if [ "$(wc -l < "$f")" -gt 120 ]; then
              echo "… (truncated at 120 of $(wc -l < "$f") lines — open ${rel} for the rest)"
            fi
            echo '```'
            echo ""
            ;;
        esac
      done < <(find "$cdir" -type f 2>/dev/null | sort)
    done <<< "$candidates"
  } > "$sheet"

  echo "$sheet"
}
