#!/bin/bash
# SpecSwarm Verification Queue
#
# Single source of truth for the verification queue file format.
# Each pending verification is a tiny key=value file at:
#   <repo>/.specswarm/verify-queue/<task_id>.pending
#
# Lifecycle:
#   .pending       — task was marked done; verification not yet run
#   .verified      — verification ran, PASS (or human sighted sign-off, SIGHTED-PASS)
#   .flagged       — verification ran, DRIFT or NEEDS-MARTY (or sighted reject, SIGHTED-REJECT)
#   .needs-sighted — (v7.14.0) diff touches UI/visual/3D/rendering surfaces;
#                    spec-mentor PASS alone cannot clear it — requires explicit
#                    human sighted sign-off (/ss:verify --sighted or the /ss:ship
#                    batch review). Origin lesson: every false-green that reached
#                    the product owner was in this class — correct DOM + green
#                    suites with a visually wrong result.
#
# Public API (all silent + non-fatal on missing repo / queue dir):
#   ss_verify_queue_dir
#     Echoes the absolute path of the queue directory (creates if missing).
#
#   ss_verify_queue_add <task_id> <feature_dir> <tasks_md> <task_desc> <refs>
#     Writes <task_id>.pending. Overwrites if already pending. Strips .verified/.flagged.
#
#   ss_verify_queue_list_pending
#     Echoes one task_id per line for every .pending file. Sorted.
#
#   ss_verify_queue_get <task_id>
#     Echoes the .pending file's contents (key=value lines) for the given task.
#     Returns 1 if no .pending file exists.
#
#   ss_verify_queue_resolve <task_id> <verdict> [details]
#     verdict: PASS | DRIFT | NEEDS-MARTY | NEEDS-SIGHTED | SIGHTED-PASS | SIGHTED-REJECT
#     Renames .pending → .verified (PASS), .flagged (DRIFT/NEEDS-MARTY), or
#     .needs-sighted (NEEDS-SIGHTED). SIGHTED-PASS/-REJECT resolve a
#     .needs-sighted marker to .verified/.flagged after human review.
#     Appends verdict + details + resolved_at to the file.
#
#   ss_verify_queue_clear <task_id>
#     Removes any queue file for the given task (any state suffix).

set -e

ss_verify_queue_dir() {
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
  local dir="${repo_root}/.specswarm/verify-queue"
  mkdir -p "$dir" 2>/dev/null || true
  echo "$dir"
}

ss_verify_queue_add() {
  local task_id="$1"
  local feature_dir="$2"
  local tasks_md="$3"
  local task_desc="$4"
  local refs="$5"

  [ -z "$task_id" ] && return 1

  local dir
  dir=$(ss_verify_queue_dir)
  local target="${dir}/${task_id}.pending"

  # Wipe any prior state for this task so re-completion re-queues cleanly
  rm -f "${dir}/${task_id}.verified" "${dir}/${task_id}.flagged" "${dir}/${task_id}.needs-sighted" 2>/dev/null || true

  {
    printf 'task_id=%s\n' "$task_id"
    printf 'queued_at=%s\n' "$(date -Iseconds 2>/dev/null || date)"
    printf 'feature_dir=%s\n' "$feature_dir"
    printf 'tasks_md=%s\n' "$tasks_md"
    printf 'task_desc=%s\n' "$(echo "$task_desc" | tr '\n' ' ' | head -c 300)"
    printf 'refs=%s\n' "$refs"
  } > "$target" 2>/dev/null
}

ss_verify_queue_list_pending() {
  local dir
  dir=$(ss_verify_queue_dir)
  [ -d "$dir" ] || return 0
  find "$dir" -maxdepth 1 -type f -name '*.pending' 2>/dev/null \
    | xargs -n1 basename 2>/dev/null \
    | sed 's/\.pending$//' \
    | sort
}

ss_verify_queue_get() {
  local task_id="$1"
  [ -z "$task_id" ] && return 1
  local dir
  dir=$(ss_verify_queue_dir)
  local target="${dir}/${task_id}.pending"
  [ -f "$target" ] || return 1
  cat "$target"
}

ss_verify_queue_resolve() {
  local task_id="$1"
  local verdict="$2"
  local details="$3"

  [ -z "$task_id" ] && return 1

  local dir
  dir=$(ss_verify_queue_dir)
  local pending="${dir}/${task_id}.pending"
  # Sighted sign-off verdicts resolve a .needs-sighted marker instead of .pending
  case "$verdict" in
    SIGHTED-PASS|SIGHTED-REJECT)
      pending="${dir}/${task_id}.needs-sighted"
      ;;
  esac
  [ -f "$pending" ] || return 1

  local suffix="verified"
  case "$verdict" in
    PASS|SIGHTED-PASS) suffix="verified" ;;
    DRIFT|NEEDS-MARTY|SIGHTED-REJECT) suffix="flagged" ;;
    NEEDS-SIGHTED) suffix="needs-sighted" ;;
    *) suffix="flagged"; verdict="UNKNOWN" ;;
  esac

  local target="${dir}/${task_id}.${suffix}"

  {
    cat "$pending"
    printf 'verdict=%s\n' "$verdict"
    printf 'details=%s\n' "$(echo "$details" | tr '\n' ' ' | head -c 1000)"
    printf 'resolved_at=%s\n' "$(date -Iseconds 2>/dev/null || date)"
  } > "$target" 2>/dev/null

  rm -f "$pending" 2>/dev/null || true
}

ss_verify_queue_clear() {
  local task_id="$1"
  [ -z "$task_id" ] && return 1
  local dir
  dir=$(ss_verify_queue_dir)
  rm -f "${dir}/${task_id}.pending" "${dir}/${task_id}.verified" "${dir}/${task_id}.flagged" "${dir}/${task_id}.needs-sighted" 2>/dev/null || true
}

ss_verify_queue_count() {
  local kind="${1:-pending}"
  local dir
  dir=$(ss_verify_queue_dir)
  [ -d "$dir" ] || { echo 0; return 0; }
  find "$dir" -maxdepth 1 -type f -name "*.${kind}" 2>/dev/null | wc -l
}
