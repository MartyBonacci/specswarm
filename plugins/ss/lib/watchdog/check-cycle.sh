#!/bin/bash
# SpecSwarm Watchdog Check Cycle (v7.9.0)
#
# One iteration of the watchdog's work. Runnable standalone for /ss:watchdog once.
#
# Detects:
#   - New commits (HEAD changed since last cycle)
#   - Newly checked tasks (via existing detect-completion.sh)
#   - Queue size changes (pending and flagged)
#
# Actions on detection:
#   - Run preflight if plan.md was touched in the new commit(s)
#   - Detect newly-checked tasks and add to verify-queue
#   - ss_notify urgent if any .flagged exists
#   - If --with-verify is enabled, dispatch headless `claude --print` to run /ss:verify
#     (EXPERIMENTAL — may require Claude Code CLI tweaks across versions)
#
# Output:
#   Writes events to watchdog log.
#   Updates state file.
#   Returns 0 always (errors are logged, never fatal).

set -e

PLUGIN_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.." && pwd)"

# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/watchdog/state.sh"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/verify/queue.sh" 2>/dev/null || true
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/verify/detect-completion.sh" 2>/dev/null || true
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/verify/task-context.sh" 2>/dev/null || true
# shellcheck disable=SC1091
[ -f "${PLUGIN_DIR}/lib/notify.sh" ] && source "${PLUGIN_DIR}/lib/notify.sh"

ss_watchdog_check_cycle() {
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

  ss_watchdog_rotate_log

  local now
  now=$(date -Iseconds 2>/dev/null || date)
  ss_watchdog_set "last_check_at" "$now"

  # 1. Detect new commits
  local current_commit
  current_commit=$(git -C "$repo_root" rev-parse HEAD 2>/dev/null || echo "")
  local last_commit
  last_commit=$(ss_watchdog_get "last_commit" || echo "")

  local commits_changed=false
  if [ "$current_commit" != "$last_commit" ] && [ -n "$current_commit" ]; then
    commits_changed=true
    if [ -n "$last_commit" ]; then
      ss_watchdog_log "new commits detected: ${last_commit:0:8}..${current_commit:0:8}"
    else
      ss_watchdog_log "watchdog initialized at commit ${current_commit:0:8}"
    fi
    ss_watchdog_set "last_commit" "$current_commit"
  fi

  # 2. If commits changed, check what was touched
  if [ "$commits_changed" = true ] && [ -n "$last_commit" ]; then
    # Files changed in the new commits
    local changed_files
    changed_files=$(git -C "$repo_root" diff --name-only "${last_commit}..${current_commit}" 2>/dev/null || echo "")

    # If any tasks.md was touched, scan the COMMIT-RANGE diff for newly-checked tasks
    # (cannot reuse working-tree-based ss_detect_newly_checked here — after commit,
    # working tree matches HEAD, so HEAD-based diff is empty)
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      case "$f" in
        *.specswarm/features/*/tasks.md)
          local tasks_md="${repo_root}/${f}"
          local feature_dir
          feature_dir=$(dirname "$tasks_md")
          ss_watchdog_log "tasks.md changed: ${f} — scanning commit range for newly-checked tasks"

          # Newly-checked = +"- [X] T###" lines in the commit-range diff
          local newly_checked
          newly_checked=$(git -C "$repo_root" diff --no-color "${last_commit}..${current_commit}" -- "$f" 2>/dev/null \
            | grep -E '^\+[[:space:]]*-[[:space:]]+\[[xX]\][[:space:]]+T[0-9]+' \
            | grep -oE 'T[0-9]+' \
            | sort -u)

          while IFS= read -r tid; do
            [ -z "$tid" ] && continue
            local desc=""
            local refs=""
            if declare -f ss_task_description >/dev/null 2>&1; then
              desc=$(ss_task_description "$tasks_md" "$tid" 2>/dev/null || echo "")
            fi
            if declare -f ss_task_refs >/dev/null 2>&1; then
              refs=$(ss_task_refs "$tasks_md" "$tid" 2>/dev/null | tr '\n' ' ' | sed 's/ *$//')
            fi
            if declare -f ss_verify_queue_add >/dev/null 2>&1; then
              ss_verify_queue_add "$tid" "$feature_dir" "$tasks_md" "$desc" "$refs" 2>/dev/null || true
              ss_watchdog_log "queued verification for ${tid}"
            fi
          done <<< "$newly_checked"
          ;;
        *.specswarm/features/*/plan.md)
          ss_watchdog_log "plan.md changed: ${f} — preflight recommended"
          # We don't auto-run preflight (network calls in background daemon
          # may hit rate limits or fail silently). Log the hint instead.
          ;;
      esac
    done <<< "$changed_files"
  fi

  # 3. Queue size changes
  local queue_dir="${repo_root}/.specswarm/verify-queue"
  local pending=0
  local flagged=0
  if [ -d "$queue_dir" ]; then
    pending=$(find "$queue_dir" -maxdepth 1 -type f -name '*.pending' 2>/dev/null | wc -l)
    flagged=$(find "$queue_dir" -maxdepth 1 -type f -name '*.flagged' 2>/dev/null | wc -l)
  fi

  local last_pending
  last_pending=$(ss_watchdog_get "last_queue_pending")
  last_pending=${last_pending:-0}
  local last_flagged
  last_flagged=$(ss_watchdog_get "last_queue_flagged")
  last_flagged=${last_flagged:-0}

  if [ "$pending" -ne "$last_pending" ]; then
    ss_watchdog_log "queue pending changed: ${last_pending} → ${pending}"
    ss_watchdog_set "last_queue_pending" "$pending"
  fi
  if [ "$flagged" -ne "$last_flagged" ]; then
    ss_watchdog_log "queue flagged changed: ${last_flagged} → ${flagged}"
    ss_watchdog_set "last_queue_flagged" "$flagged"

    # New flagged tasks → notify urgently
    if [ "$flagged" -gt "$last_flagged" ] && declare -f ss_notify >/dev/null 2>&1; then
      local new_flagged=$((flagged - last_flagged))
      ss_notify urgent "SpecSwarm watchdog: flagged tasks" "${new_flagged} new task(s) flagged for review — run /ss:verify" || true
    fi
  fi

  # 4. Experimental: headless Claude dispatch for /ss:verify
  local with_verify
  with_verify=$(ss_watchdog_get "with_verify" || echo "false")
  if [ "$with_verify" = "true" ] && [ "$pending" -gt 0 ]; then
    if command -v claude >/dev/null 2>&1; then
      ss_watchdog_log "dispatching headless /ss:verify --all (with_verify enabled, ${pending} pending)"
      # Detached + cwd at repo root + non-interactive. Output captured to log.
      # v7.15.0 (WS6): every headless dispatch carries the sync-gate + budget
      # clauses — this site died the same yield-await death as overnight runs.
      local wd_clauses=""
      if [ -f "${SS_WATCHDOG_LIB_DIR:-$(dirname "${BASH_SOURCE[0]}")}/../overnight/resilience.sh" ]; then
        # shellcheck disable=SC1091
        source "${SS_WATCHDOG_LIB_DIR:-$(dirname "${BASH_SOURCE[0]}")}/../overnight/resilience.sh"
        wd_clauses=$(ss_overnight_prompt_clauses)
      fi
      (
        cd "$repo_root" || exit 0
        claude --print "Run /ss:verify --all and report any DRIFT or NEEDS-MARTY verdicts.

${wd_clauses}" \
          >> "$(ss_watchdog_log_file)" 2>&1 &
        disown
      )
    else
      ss_watchdog_log "with_verify=true but claude CLI not found in PATH; skipping headless dispatch"
    fi
  fi

  return 0
}

# Allow direct invocation: bash check-cycle.sh
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  ss_watchdog_check_cycle
fi
