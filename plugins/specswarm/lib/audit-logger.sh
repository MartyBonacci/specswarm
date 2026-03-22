#!/bin/bash
# SpecSwarm Audit Logger
# Writes structured events to .specswarm/audit.jsonl
# Used by build, fix, modify, ship workflows for metrics

# Log an audit event to .specswarm/audit.jsonl
# Usage: audit_log <event_type> [key=value ...]
# Example: audit_log "phase_start" phase="specify" feature="001-auth"
audit_log() {
  local event_type="$1"
  shift

  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
  local audit_file="${repo_root}/.specswarm/audit.jsonl"

  # Ensure directory exists
  mkdir -p "${repo_root}/.specswarm" 2>/dev/null || return 0

  local timestamp
  timestamp=$(date -Iseconds 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S%z")

  # Build JSON object from key=value pairs
  local json_args="--arg ts \"$timestamp\" --arg event \"$event_type\""
  local json_template='{timestamp: $ts, event: $event'

  for pair in "$@"; do
    local key="${pair%%=*}"
    local value="${pair#*=}"
    json_args="$json_args --arg $key \"$value\""
    json_template="$json_template, $key: \$$key"
  done

  json_template="$json_template}"

  # Use eval to expand the dynamic jq args
  eval "jq -n -c $json_args '$json_template'" >> "$audit_file" 2>/dev/null || true
}

# Log a build phase transition
# Usage: audit_phase <phase_name> <status> <feature_num> [duration_seconds]
audit_phase() {
  local phase="$1"
  local status="$2"
  local feature_num="$3"
  local duration="${4:-}"

  if [ -n "$duration" ]; then
    audit_log "phase_${status}" phase="$phase" feature="$feature_num" duration_s="$duration"
  else
    audit_log "phase_${status}" phase="$phase" feature="$feature_num"
  fi
}

# Log a build start
# Usage: audit_build_start <feature_num> <feature_desc> <flags>
audit_build_start() {
  audit_log "build_start" feature="$1" description="$2" flags="$3"
}

# Log a build completion
# Usage: audit_build_complete <feature_num> <quality_score> <task_count>
audit_build_complete() {
  audit_log "build_complete" feature="$1" quality_score="$2" task_count="$3"
}

# Log a fix workflow
# Usage: audit_fix <feature_num> <status> <retries>
audit_fix() {
  audit_log "fix_${2}" feature="$1" retries="$3"
}

# Log a ship event
# Usage: audit_ship <feature_num> <status> <quality_score>
audit_ship() {
  audit_log "ship_${2}" feature="$1" quality_score="$3"
}

# Read recent audit events
# Usage: audit_recent [count] [event_filter]
audit_recent() {
  local count="${1:-20}"
  local filter="${2:-}"

  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
  local audit_file="${repo_root}/.specswarm/audit.jsonl"

  if [ ! -f "$audit_file" ]; then
    echo "[]"
    return 0
  fi

  if [ -n "$filter" ]; then
    tail -n "$count" "$audit_file" | jq -s --arg f "$filter" '[.[] | select(.event | contains($f))]' 2>/dev/null || echo "[]"
  else
    tail -n "$count" "$audit_file" | jq -s '.' 2>/dev/null || echo "[]"
  fi
}

# Get audit summary statistics
# Usage: audit_summary
audit_summary() {
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
  local audit_file="${repo_root}/.specswarm/audit.jsonl"

  if [ ! -f "$audit_file" ]; then
    echo '{"total_events": 0}'
    return 0
  fi

  jq -s '{
    total_events: length,
    builds_started: [.[] | select(.event == "build_start")] | length,
    builds_completed: [.[] | select(.event == "build_complete")] | length,
    fixes: [.[] | select(.event | startswith("fix_"))] | length,
    ships: [.[] | select(.event | startswith("ship_"))] | length,
    quality_checks: [.[] | select(.event == "quality_check")] | length,
    quality_issues: [.[] | select(.event == "quality_check" and .has_issues == true)] | length
  }' "$audit_file" 2>/dev/null || echo '{"total_events": 0}'
}
