#!/bin/bash
#
# State Manager for SpecLabs Orchestrator
# Handles orchestration session state, persistence, and resume functionality
#
# Part of Phase 1a: Test Orchestrator Foundation
#

set -euo pipefail

# Configuration
STATE_DIR="${ORCHESTRATOR_STATE_DIR:-/home/marty/code-projects/specswarm/memory/orchestrator}"
SESSIONS_DIR="$STATE_DIR/sessions"

# Ensure directories exist
mkdir -p "$SESSIONS_DIR"

#######################################
# Create a new orchestration session
# Arguments:
#   $1 - workflow_file: Path to test workflow file
#   $2 - project_path: Path to target project
#   $3 - task_name: Name of the task
# Outputs:
#   session_id: Unique session identifier
# Returns:
#   0 on success, 1 on error
#######################################
state_create_session() {
  local workflow_file="$1"
  local project_path="$2"
  local task_name="$3"

  # Generate unique session ID (with milliseconds to avoid collisions)
  local session_id="orch-$(date +%Y%m%d-%H%M%S)-$(date +%3N)"
  local session_dir="$SESSIONS_DIR/$session_id"

  # Create session directory
  if ! mkdir -p "$session_dir"; then
    echo "ERROR: Failed to create session directory: $session_dir" >&2
    return 1
  fi

  # Initialize state file
  local state_file="$session_dir/state.json"
  cat > "$state_file" <<EOF
{
  "session_id": "$session_id",
  "status": "in_progress",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",

  "workflow": {
    "file": "$workflow_file",
    "task_name": "$task_name",
    "project_path": "$project_path"
  },

  "agent": {
    "id": null,
    "status": "pending",
    "started_at": null,
    "completed_at": null,
    "error": null,
    "output_summary": null
  },

  "validation": {
    "status": "pending",
    "playwright": {
      "console_errors": null,
      "network_errors": null,
      "screenshot": null
    },
    "vision_api": {
      "analysis": null,
      "issues_found": [],
      "score": null
    }
  },

  "retries": {
    "count": 0,
    "max": ${ORCHESTRATOR_MAX_RETRIES:-3},
    "history": []
  },

  "decision": {
    "action": null,
    "reason": null,
    "timestamp": null
  },

  "metrics": {
    "total_time_seconds": null,
    "agent_time_seconds": null,
    "validation_time_seconds": null,
    "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  }
}
EOF

  # Verify state file was created
  if [ ! -f "$state_file" ]; then
    echo "ERROR: Failed to create state file: $state_file" >&2
    return 1
  fi

  # Return session ID
  echo "$session_id"
  return 0
}

#######################################
# Update a value in session state
# Arguments:
#   $1 - session_id: Session identifier
#   $2 - key: JSON path to update (e.g., "agent.status")
#   $3 - value: New value (must be valid JSON)
# Returns:
#   0 on success, 1 on error
#######################################
state_update() {
  local session_id="$1"
  local key="$2"
  local value="$3"

  local state_file="$SESSIONS_DIR/$session_id/state.json"

  # Check if session exists
  if [ ! -f "$state_file" ]; then
    echo "ERROR: Session not found: $session_id" >&2
    return 1
  fi

  # Update timestamp
  local current_time="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  # Use jq to update JSON
  # Write to temp file first (atomic write)
  local temp_file="${state_file}.tmp.$$"

  if ! jq \
    --arg updated "$current_time" \
    ".$key = $value | .updated_at = \$updated" \
    "$state_file" > "$temp_file" 2>/dev/null; then
    echo "ERROR: Failed to update state. Key: $key, Value: $value" >&2
    rm -f "$temp_file"
    return 1
  fi

  # Atomic move
  if ! mv "$temp_file" "$state_file"; then
    echo "ERROR: Failed to save state file" >&2
    rm -f "$temp_file"
    return 1
  fi

  return 0
}

#######################################
# Get a value from session state
# Arguments:
#   $1 - session_id: Session identifier
#   $2 - key: JSON path to retrieve (e.g., "agent.status")
# Outputs:
#   value: The requested value
# Returns:
#   0 on success, 1 on error
#######################################
state_get() {
  local session_id="$1"
  local key="$2"

  local state_file="$SESSIONS_DIR/$session_id/state.json"

  # Check if session exists
  if [ ! -f "$state_file" ]; then
    echo "ERROR: Session not found: $session_id" >&2
    return 1
  fi

  # Get value using jq
  local value
  if ! value=$(jq -r ".$key" "$state_file" 2>/dev/null); then
    echo "ERROR: Failed to get state value. Key: $key" >&2
    return 1
  fi

  echo "$value"
  return 0
}

#######################################
# Get entire session state
# Arguments:
#   $1 - session_id: Session identifier
# Outputs:
#   Full JSON state
# Returns:
#   0 on success, 1 on error
#######################################
state_get_all() {
  local session_id="$1"

  local state_file="$SESSIONS_DIR/$session_id/state.json"

  # Check if session exists
  if [ ! -f "$state_file" ]; then
    echo "ERROR: Session not found: $session_id" >&2
    return 1
  fi

  cat "$state_file"
  return 0
}

#######################################
# Mark session as complete
# Arguments:
#   $1 - session_id: Session identifier
#   $2 - final_status: success | failure | escalated
# Returns:
#   0 on success, 1 on error
#######################################
state_complete() {
  local session_id="$1"
  local final_status="$2"

  # Validate final_status
  if [[ ! "$final_status" =~ ^(success|failure|escalated)$ ]]; then
    echo "ERROR: Invalid final status: $final_status. Must be: success | failure | escalated" >&2
    return 1
  fi

  # Calculate total time
  local started_at=$(state_get "$session_id" "metrics.started_at")
  local current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  local started_epoch=$(date -d "$started_at" +%s 2>/dev/null || echo 0)
  local current_epoch=$(date -d "$current_time" +%s 2>/dev/null || date +%s)
  local total_time=$((current_epoch - started_epoch))

  # Update state
  state_update "$session_id" "status" "\"$final_status\"" && \
  state_update "$session_id" "completed_at" "\"$current_time\"" && \
  state_update "$session_id" "metrics.total_time_seconds" "$total_time"

  return $?
}

#######################################
# Resume an existing session (for retry)
# Arguments:
#   $1 - session_id: Session identifier
# Returns:
#   0 on success, 1 on error
#######################################
state_resume() {
  local session_id="$1"

  local state_file="$SESSIONS_DIR/$session_id/state.json"

  # Check if session exists
  if [ ! -f "$state_file" ]; then
    echo "ERROR: Session $session_id not found" >&2
    return 1
  fi

  # Get current retry count
  local retry_count
  retry_count=$(state_get "$session_id" "retries.count")
  local max_retries
  max_retries=$(state_get "$session_id" "retries.max")

  # Check if we can retry
  if [ "$retry_count" -ge "$max_retries" ]; then
    echo "ERROR: Max retries ($max_retries) exceeded for session $session_id" >&2
    return 1
  fi

  # Increment retry count
  local new_retry_count=$((retry_count + 1))
  state_update "$session_id" "retries.count" "$new_retry_count"

  # Add to retry history
  local retry_timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  local retry_history_entry="{\"attempt\": $new_retry_count, \"timestamp\": \"$retry_timestamp\"}"

  # Append to history array
  local state_file="$SESSIONS_DIR/$session_id/state.json"
  local temp_file="${state_file}.tmp.$$"

  jq ".retries.history += [$retry_history_entry] | .updated_at = \"$retry_timestamp\"" \
    "$state_file" > "$temp_file" && \
  mv "$temp_file" "$state_file"

  echo "Resuming session $session_id (retry $new_retry_count of $max_retries)"
  return 0
}

#######################################
# Check if session exists
# Arguments:
#   $1 - session_id: Session identifier
# Returns:
#   0 if exists, 1 if not
#######################################
state_exists() {
  local session_id="$1"
  local state_file="$SESSIONS_DIR/$session_id/state.json"

  [ -f "$state_file" ]
  return $?
}

#######################################
# List all sessions
# Arguments:
#   $1 - status_filter: (optional) Filter by status: in_progress | success | failure | escalated
# Outputs:
#   List of session IDs
# Returns:
#   0 on success
#######################################
state_list_sessions() {
  local status_filter="${1:-}"

  if [ -z "$status_filter" ]; then
    # List all sessions
    find "$SESSIONS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort -r
  else
    # List sessions with specific status
    for session_dir in "$SESSIONS_DIR"/*; do
      if [ -d "$session_dir" ]; then
        local session_id=$(basename "$session_dir")
        local status=$(state_get "$session_id" "status" 2>/dev/null || echo "")
        if [ "$status" == "$status_filter" ]; then
          echo "$session_id"
        fi
      fi
    done | sort -r
  fi

  return 0
}

#######################################
# Clean up old sessions
# Arguments:
#   $1 - days: Remove sessions older than N days
# Returns:
#   0 on success
#######################################
state_cleanup_old_sessions() {
  local days="${1:-30}"

  echo "Cleaning up sessions older than $days days..."

  local count=0
  find "$SESSIONS_DIR" -mindepth 1 -maxdepth 1 -type d -mtime "+$days" | while read -r session_dir; do
    local session_id=$(basename "$session_dir")
    echo "Removing old session: $session_id"
    rm -rf "$session_dir"
    ((count++))
  done

  echo "Removed $count old sessions"
  return 0
}

#######################################
# Validate session state structure
# Arguments:
#   $1 - session_id: Session identifier
# Returns:
#   0 if valid, 1 if invalid
#######################################
state_validate() {
  local session_id="$1"
  local state_file="$SESSIONS_DIR/$session_id/state.json"

  # Check if file exists
  if [ ! -f "$state_file" ]; then
    echo "ERROR: State file not found: $state_file" >&2
    return 1
  fi

  # Check if valid JSON
  if ! jq empty "$state_file" 2>/dev/null; then
    echo "ERROR: Invalid JSON in state file: $state_file" >&2
    return 1
  fi

  # Check required fields
  local required_fields=(
    "session_id"
    "status"
    "workflow"
    "agent"
    "validation"
    "retries"
    "metrics"
  )

  for field in "${required_fields[@]}"; do
    if ! jq -e ".$field" "$state_file" >/dev/null 2>&1; then
      echo "ERROR: Missing required field: $field" >&2
      return 1
    fi
  done

  return 0
}

#######################################
# Save agent output/logs to session
# Arguments:
#   $1 - session_id: Session identifier
#   $2 - output_file: Path to output file to save
# Returns:
#   0 on success, 1 on error
#######################################
state_save_agent_output() {
  local session_id="$1"
  local output_file="$2"

  local session_dir="$SESSIONS_DIR/$session_id"

  if [ ! -d "$session_dir" ]; then
    echo "ERROR: Session not found: $session_id" >&2
    return 1
  fi

  if [ ! -f "$output_file" ]; then
    echo "ERROR: Output file not found: $output_file" >&2
    return 1
  fi

  # Copy output to session directory
  cp "$output_file" "$session_dir/agent-output.log"
  return $?
}

#######################################
# Get session directory path
# Arguments:
#   $1 - session_id: Session identifier
# Outputs:
#   Absolute path to session directory
# Returns:
#   0 on success, 1 on error
#######################################
state_get_session_dir() {
  local session_id="$1"
  local session_dir="$SESSIONS_DIR/$session_id"

  if [ ! -d "$session_dir" ]; then
    echo "ERROR: Session not found: $session_id" >&2
    return 1
  fi

  echo "$session_dir"
  return 0
}

#######################################
# Print session summary
# Arguments:
#   $1 - session_id: Session identifier
# Outputs:
#   Human-readable session summary
# Returns:
#   0 on success, 1 on error
#######################################
state_print_summary() {
  local session_id="$1"

  if ! state_exists "$session_id"; then
    echo "ERROR: Session not found: $session_id" >&2
    return 1
  fi

  echo "📊 Session Summary: $session_id"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Status:          $(state_get "$session_id" "status")"
  echo "Task:            $(state_get "$session_id" "workflow.task_name")"
  echo "Project:         $(state_get "$session_id" "workflow.project_path")"
  echo "Created:         $(state_get "$session_id" "created_at")"
  echo "Updated:         $(state_get "$session_id" "updated_at")"
  echo ""
  echo "Agent Status:    $(state_get "$session_id" "agent.status")"
  echo "Validation:      $(state_get "$session_id" "validation.status")"
  echo "Retry Count:     $(state_get "$session_id" "retries.count")/$(state_get "$session_id" "retries.max")"
  echo ""

  local total_time=$(state_get "$session_id" "metrics.total_time_seconds")
  if [ "$total_time" != "null" ]; then
    echo "Total Time:      ${total_time}s"
  fi

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  return 0
}

# Export functions if sourced
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
  export -f state_create_session
  export -f state_update
  export -f state_get
  export -f state_get_all
  export -f state_complete
  export -f state_resume
  export -f state_exists
  export -f state_list_sessions
  export -f state_cleanup_old_sessions
  export -f state_validate
  export -f state_save_agent_output
  export -f state_get_session_dir
  export -f state_print_summary
fi
