#!/bin/bash
# SpecSwarm Watchdog Check Cycle (v7.9.0)
#
# One iteration of the watchdog's work. Runnable standalone for /ss:watchdog once.
#
# Detects:
#   - New commits (HEAD changed since last cycle)
#   - Newly checked tasks (via existing detect-completion.sh)
#   - Queue size changes (pending and flagged)
#   - Conduct run completions/deaths + orphan listeners (v7.18.0, auto-enabled
#     when .specswarm/conduct/ exists)
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
        *.specswarm/features/*/plan.md|*.specswarm/features/*/spec.md)
          ss_watchdog_log "spec artifact changed: ${f} — preflight recommended"
          # We don't auto-run preflight (network calls in background daemon
          # may hit rate limits or fail silently). Log the hint instead.

          # v7.16.0 (WS8): surface DECIDED-BY-DATA deferrals so review-when
          # conditions don't rot forgotten in the spec.
          local dbd_lib
          dbd_lib="$(dirname "${BASH_SOURCE[0]}")/../decisions/decided-by-data.sh"
          if [ -f "$dbd_lib" ]; then
            # shellcheck disable=SC1091
            source "$dbd_lib"
            local markers
            markers=$(ss_dbd_scan "${repo_root}/${f}" 2>/dev/null || true)
            if [ -n "$markers" ]; then
              local mcount
              mcount=$(echo "$markers" | wc -l)
              ss_watchdog_log "DECIDED-BY-DATA: ${mcount} open deferral(s) in ${f}"
              while IFS=$'\t' read -r mfile mline metric review; do
                ss_watchdog_log "  • ${metric} (review-when: ${review}) at ${mfile##*/}:${mline}"
              done <<< "$markers"
              if declare -f ss_notify >/dev/null 2>&1; then
                ss_notify info "SpecSwarm: data-deferred decisions" \
                  "${mcount} DECIDED-BY-DATA marker(s) in ${f##*/} — check review-when conditions" || true
              fi
            fi
          fi
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

  # 4. Conduct runs (v7.18.0) — mentor→builder dispatch monitoring
  # Auto-enabled when .specswarm/conduct/ exists (created by /ss:mentor-init).
  # Pushes run completions/deaths so the human never has to ask "is anything
  # running?" — the pilot human asked that six times in one week.
  local conduct_dir="${repo_root}/.specswarm/conduct"
  if [ -d "${conduct_dir}/runs" ]; then
    local notified_file="${conduct_dir}/.watchdog-notified"
    local conduct_running=""
    local run rname ec

    # First cycle ever: seed the notified list with already-finalized runs so
    # starting the watchdog on an established mentor dir doesn't replay history.
    if [ ! -f "$notified_file" ]; then
      for run in "${conduct_dir}/runs"/*/; do
        [ -f "${run}exit-code" ] && basename "$run"
      done > "$notified_file" 2>/dev/null || true
      ss_watchdog_log "conduct monitoring initialized ($(wc -l < "$notified_file" 2>/dev/null || echo 0) prior runs)"
    fi

    for run in "${conduct_dir}/runs"/*/; do
      [ -d "$run" ] || continue
      rname=$(basename "$run")
      if [ ! -f "${run}exit-code" ]; then
        conduct_running="${conduct_running}${rname} "
        continue
      fi
      grep -qxF "$rname" "$notified_file" 2>/dev/null && continue
      ec=$(cat "${run}exit-code" 2>/dev/null || echo "?")
      if [ "$ec" = "0" ] && [ -s "${run}result.md" ]; then
        ss_watchdog_log "conduct run completed: ${rname} (exit 0)"
        if declare -f ss_notify >/dev/null 2>&1; then
          ss_notify success "SpecSwarm conduct: run completed" "${rname} finished — independent verification is next (never trust the self-report)" || true
        fi
      elif [ "$ec" = "0" ]; then
        # Clean exit, empty result.md — the verified-but-uncommitted tell
        ss_watchdog_log "conduct run SUSPICIOUS: ${rname} (exit 0, empty result.md)"
        if declare -f ss_notify >/dev/null 2>&1; then
          ss_notify urgent "SpecSwarm conduct: empty result" "${rname} exited clean with an EMPTY result.md — check the builder tree for uncommitted work" || true
        fi
      else
        ss_watchdog_log "conduct run DIED: ${rname} (exit ${ec})"
        if declare -f ss_notify >/dev/null 2>&1; then
          ss_notify urgent "SpecSwarm conduct: run died" "${rname} ended abnormally (exit ${ec}) — run the builder-death checklist (detached HEAD? uncommitted work? orphan servers?)" || true
        fi
      fi
      echo "$rname" >> "$notified_file"
    done

    local last_conduct_running
    last_conduct_running=$(ss_watchdog_get "conduct_running" || echo "")
    if [ "$conduct_running" != "$last_conduct_running" ]; then
      ss_watchdog_log "conduct running: ${conduct_running:-none}"
      ss_watchdog_set "conduct_running" "$conduct_running"
    fi

    # Orphan-listener sweep: only meaningful when NO dispatch is running —
    # a listener then is a leftover from a killed builder squatting a test port.
    if [ -z "$conduct_running" ] && [ -f "${conduct_dir}/config" ]; then
      local watch_ports
      watch_ports=$(grep -E '^WATCH_PORTS=' "${conduct_dir}/config" 2>/dev/null | head -n1 | cut -d= -f2-)
      local orphaned=""
      local port
      for port in $watch_ports; do
        if command -v ss >/dev/null 2>&1; then
          ss -tln 2>/dev/null | grep -qE ":${port}[[:space:]]" && orphaned="${orphaned}${port} "
        elif command -v lsof >/dev/null 2>&1; then
          lsof -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1 && orphaned="${orphaned}${port} "
        fi
      done
      local last_orphaned
      last_orphaned=$(ss_watchdog_get "conduct_orphan_ports" || echo "")
      if [ "$orphaned" != "$last_orphaned" ]; then
        ss_watchdog_set "conduct_orphan_ports" "$orphaned"
        if [ -n "$orphaned" ]; then
          ss_watchdog_log "orphan listeners on watched ports (no dispatch running): ${orphaned}"
          if declare -f ss_notify >/dev/null 2>&1; then
            ss_notify urgent "SpecSwarm conduct: orphan servers" "listeners on port(s) ${orphaned}with no dispatch running — likely leftovers from a killed builder" || true
          fi
        else
          ss_watchdog_log "orphan listeners cleared"
        fi
      fi
    fi
  fi

  # 5. Experimental: headless Claude dispatch for /ss:verify
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
