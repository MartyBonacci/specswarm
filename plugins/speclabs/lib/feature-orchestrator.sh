#!/bin/bash
# feature-orchestrator.sh - Feature-level orchestration with SpecSwarm integration
# Part of Phase 2: Feature Workflow Engine
#
# This library manages feature-level orchestration sessions, integrating
# SpecSwarm planning commands with SpecLabs task execution.

# Source dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Don't source state-manager here to avoid circular dependency
# It will be sourced by the command that uses this library

# Feature session directory
SPECSWARM_ROOT="${SPECSWARM_ROOT:-/home/marty/code-projects/specswarm}"
FEATURE_SESSION_DIR="${SPECSWARM_ROOT}/memory/feature-orchestrator/sessions"

# Initialize feature orchestrator
feature_init() {
  mkdir -p "$FEATURE_SESSION_DIR"
  echo "✅ Feature orchestrator initialized"
}

# Create a new feature session
# Args: feature_name, project_path
# Returns: feature_session_id
feature_create_session() {
  local feature_name="$1"
  local project_path="$2"

  local timestamp=$(date +%Y%m%d_%H%M%S)
  local session_id="feature_${timestamp}"
  local session_file="${FEATURE_SESSION_DIR}/${session_id}.json"

  # Create initial session structure
  cat > "$session_file" <<EOF
{
  "session_id": "$session_id",
  "feature_name": "$feature_name",
  "project_path": "$project_path",
  "created_at": "$(date -Iseconds)",
  "updated_at": "$(date -Iseconds)",
  "status": "planning",
  "phase": "specify",
  "specswarm": {
    "specify": {
      "status": "pending",
      "started_at": null,
      "completed_at": null,
      "output_file": null
    },
    "clarify": {
      "status": "pending",
      "started_at": null,
      "completed_at": null,
      "output_file": null
    },
    "plan": {
      "status": "pending",
      "started_at": null,
      "completed_at": null,
      "output_file": null
    },
    "tasks": {
      "status": "pending",
      "started_at": null,
      "completed_at": null,
      "output_file": null,
      "task_count": 0
    }
  },
  "implementation": {
    "status": "pending",
    "tasks": [],
    "completed_count": 0,
    "failed_count": 0,
    "total_count": 0
  },
  "bugfix": {
    "status": "not_needed",
    "attempts": 0,
    "issues_fixed": 0
  },
  "metrics": {
    "total_time_seconds": 0,
    "planning_time_seconds": 0,
    "implementation_time_seconds": 0,
    "bugfix_time_seconds": 0,
    "total_retries": 0,
    "total_validations": 0
  },
  "result": {
    "success": false,
    "message": "",
    "artifacts": []
  }
}
EOF

  echo "$session_id"
}

# Update feature session field
# Args: session_id, json_path, value
feature_update() {
  local session_id="$1"
  local json_path="$2"
  local value="$3"

  local session_file="${FEATURE_SESSION_DIR}/${session_id}.json"

  if [ ! -f "$session_file" ]; then
    echo "Error: Session $session_id not found" >&2
    return 1
  fi

  # Update the field and timestamp
  local temp_file=$(mktemp)
  jq --arg path "$json_path" \
     --argjson value "$value" \
     --arg updated_at "$(date -Iseconds)" \
     'setpath($path | split("."); $value) | .updated_at = $updated_at' \
     "$session_file" > "$temp_file"

  mv "$temp_file" "$session_file"
}

# Get feature session field
# Args: session_id, json_path
feature_get() {
  local session_id="$1"
  local json_path="$2"

  local session_file="${FEATURE_SESSION_DIR}/${session_id}.json"

  if [ ! -f "$session_file" ]; then
    echo "Error: Session $session_id not found" >&2
    return 1
  fi

  jq -r ".$json_path" "$session_file"
}

# Start SpecSwarm phase
# Args: session_id, phase_name (specify|clarify|plan|tasks)
feature_start_specswarm_phase() {
  local session_id="$1"
  local phase_name="$2"

  feature_update "$session_id" "specswarm.${phase_name}.status" '"in_progress"'
  feature_update "$session_id" "specswarm.${phase_name}.started_at" "\"$(date -Iseconds)\""
  feature_update "$session_id" "phase" "\"$phase_name\""
}

# Complete SpecSwarm phase
# Args: session_id, phase_name, output_file
feature_complete_specswarm_phase() {
  local session_id="$1"
  local phase_name="$2"
  local output_file="$3"

  feature_update "$session_id" "specswarm.${phase_name}.status" '"complete"'
  feature_update "$session_id" "specswarm.${phase_name}.completed_at" "\"$(date -Iseconds)\""
  feature_update "$session_id" "specswarm.${phase_name}.output_file" "\"$output_file\""
}

# Parse tasks.md and add to feature session
# Args: session_id, tasks_md_file
feature_parse_tasks() {
  local session_id="$1"
  local tasks_md_file="$2"

  if [ ! -f "$tasks_md_file" ]; then
    echo "Error: tasks.md file not found: $tasks_md_file" >&2
    return 1
  fi

  # Parse tasks from markdown
  # Look for task sections (## Task X or - [ ] patterns)
  local task_count=0
  local tasks_json="[]"

  # Extract tasks using grep and awk
  # This is a simplified parser - adjust based on actual tasks.md format
  while IFS= read -r line; do
    if [[ "$line" =~ ^##[[:space:]]*Task[[:space:]]*[0-9]+ ]] || \
       [[ "$line" =~ ^-[[:space:]]*\[[[:space:]]\][[:space:]]* ]]; then
      ((task_count++))

      # Extract task description (simplified)
      local task_desc=$(echo "$line" | sed -E 's/^##[[:space:]]*Task[[:space:]]*[0-9]+:[[:space:]]*//; s/^-[[:space:]]*\[[[:space:]]\][[:space:]]*//')

      # Add task to JSON array
      tasks_json=$(echo "$tasks_json" | jq --arg id "task_$task_count" \
                                             --arg desc "$task_desc" \
                                             '. += [{
                                               "id": $id,
                                               "description": $desc,
                                               "status": "pending",
                                               "orchestrate_session_id": null,
                                               "workflow_file": null,
                                               "attempts": 0,
                                               "retries": 0,
                                               "validation_passed": false
                                             }]')
    fi
  done < "$tasks_md_file"

  # Update feature session with parsed tasks
  feature_update "$session_id" "implementation.tasks" "$tasks_json"
  feature_update "$session_id" "implementation.total_count" "$task_count"
  feature_update "$session_id" "specswarm.tasks.task_count" "$task_count"

  echo "$task_count"
}

# Get next pending task
# Args: session_id
# Returns: task JSON object or empty if none
feature_get_next_task() {
  local session_id="$1"
  local session_file="${FEATURE_SESSION_DIR}/${session_id}.json"

  jq -r '.implementation.tasks[] | select(.status == "pending") | @json' "$session_file" | head -n 1
}

# Update task status
# Args: session_id, task_id, status, [orchestrate_session_id]
feature_update_task() {
  local session_id="$1"
  local task_id="$2"
  local status="$3"
  local orchestrate_session_id="${4:-null}"

  local session_file="${FEATURE_SESSION_DIR}/${session_id}.json"
  local temp_file=$(mktemp)

  jq --arg task_id "$task_id" \
     --arg status "$status" \
     --arg orch_id "$orchestrate_session_id" \
     --arg updated_at "$(date -Iseconds)" \
     '(.implementation.tasks[] | select(.id == $task_id) | .status) = $status |
      (.implementation.tasks[] | select(.id == $task_id) | .orchestrate_session_id) = $orch_id |
      .updated_at = $updated_at' \
     "$session_file" > "$temp_file"

  mv "$temp_file" "$session_file"
}

# Increment task attempt counter
# Args: session_id, task_id
feature_increment_task_attempts() {
  local session_id="$1"
  local task_id="$2"

  local session_file="${FEATURE_SESSION_DIR}/${session_id}.json"
  local temp_file=$(mktemp)

  jq --arg task_id "$task_id" \
     '(.implementation.tasks[] | select(.id == $task_id) | .attempts) += 1' \
     "$session_file" > "$temp_file"

  mv "$temp_file" "$session_file"
}

# Mark task as complete
# Args: session_id, task_id, validation_passed
feature_complete_task() {
  local session_id="$1"
  local task_id="$2"
  local validation_passed="$3"

  feature_update_task "$session_id" "$task_id" "complete"

  local session_file="${FEATURE_SESSION_DIR}/${session_id}.json"
  local temp_file=$(mktemp)

  jq --arg task_id "$task_id" \
     --argjson validated "$validation_passed" \
     '(.implementation.tasks[] | select(.id == $task_id) | .validation_passed) = $validated |
      .implementation.completed_count += 1' \
     "$session_file" > "$temp_file"

  mv "$temp_file" "$session_file"
}

# Mark task as failed
# Args: session_id, task_id
feature_fail_task() {
  local session_id="$1"
  local task_id="$2"

  feature_update_task "$session_id" "$task_id" "failed"

  local session_file="${FEATURE_SESSION_DIR}/${session_id}.json"
  local temp_file=$(mktemp)

  jq '.implementation.failed_count += 1' "$session_file" > "$temp_file"

  mv "$temp_file" "$session_file"
}

# Move feature to implementation phase
# Args: session_id
feature_start_implementation() {
  local session_id="$1"

  feature_update "$session_id" "status" '"implementing"'
  feature_update "$session_id" "phase" '"implementation"'
  feature_update "$session_id" "implementation.status" '"in_progress"'
}

# Move feature to bugfix phase
# Args: session_id
feature_start_bugfix() {
  local session_id="$1"

  feature_update "$session_id" "status" '"fixing"'
  feature_update "$session_id" "phase" '"bugfix"'
  feature_update "$session_id" "bugfix.status" '"in_progress"'

  local session_file="${FEATURE_SESSION_DIR}/${session_id}.json"
  local temp_file=$(mktemp)

  jq '.bugfix.attempts += 1' "$session_file" > "$temp_file"
  mv "$temp_file" "$session_file"
}

# Complete bugfix phase
# Args: session_id, issues_fixed
feature_complete_bugfix() {
  local session_id="$1"
  local issues_fixed="$2"

  feature_update "$session_id" "bugfix.status" '"complete"'
  feature_update "$session_id" "bugfix.issues_fixed" "$issues_fixed"
}

# Start audit phase
# Args: session_id
feature_start_audit() {
  local session_id="$1"
  local session_file="${FEATURE_SESSION_DIR}/${session_id}.json"

  if [ ! -f "$session_file" ]; then
    echo "Error: Session $session_id not found" >&2
    return 1
  fi

  local temp_file=$(mktemp)

  # Add audit section if it doesn't exist, otherwise update it
  jq --arg started_at "$(date -Iseconds)" \
     --arg updated_at "$(date -Iseconds)" \
     '.audit = {
        "status": "in_progress",
        "started_at": $started_at,
        "completed_at": null,
        "report_file": null,
        "quality_score": null,
        "checks": {
          "compatibility": {"status": "pending", "warnings": 0, "errors": 0},
          "security": {"status": "pending", "warnings": 0, "errors": 0},
          "best_practices": {"status": "pending", "warnings": 0, "errors": 0}
        }
      } |
      .phase = "audit" |
      .updated_at = $updated_at' \
     "$session_file" > "$temp_file"

  mv "$temp_file" "$session_file"
}

# Complete audit phase
# Args: session_id, report_file, quality_score
feature_complete_audit() {
  local session_id="$1"
  local report_file="$2"
  local quality_score="${3:-0}"
  local session_file="${FEATURE_SESSION_DIR}/${session_id}.json"

  if [ ! -f "$session_file" ]; then
    echo "Error: Session $session_id not found" >&2
    return 1
  fi

  local temp_file=$(mktemp)

  jq --arg completed_at "$(date -Iseconds)" \
     --arg report_file "$report_file" \
     --argjson quality_score "$quality_score" \
     --arg updated_at "$(date -Iseconds)" \
     '.audit.status = "complete" |
      .audit.completed_at = $completed_at |
      .audit.report_file = $report_file |
      .audit.quality_score = $quality_score |
      .metrics.quality_score = $quality_score |
      .updated_at = $updated_at' \
     "$session_file" > "$temp_file"

  mv "$temp_file" "$session_file"
}

# Complete feature session
# Args: session_id, success (true|false), message
feature_complete() {
  local session_id="$1"
  local success="$2"
  local message="$3"

  feature_update "$session_id" "status" '"complete"'
  feature_update "$session_id" "result.success" "$success"
  feature_update "$session_id" "result.message" "\"$message\""
}

# Get feature session summary
# Args: session_id
feature_summary() {
  local session_id="$1"
  local session_file="${FEATURE_SESSION_DIR}/${session_id}.json"

  if [ ! -f "$session_file" ]; then
    echo "Error: Session $session_id not found" >&2
    return 1
  fi

  echo "📊 Feature Session Summary"
  echo "=========================="
  echo ""
  echo "Feature: $(jq -r '.feature_name' "$session_file")"
  echo "Status: $(jq -r '.status' "$session_file")"
  echo "Phase: $(jq -r '.phase' "$session_file")"
  echo ""
  echo "SpecSwarm Planning:"
  echo "  - Specify: $(jq -r '.specswarm.specify.status' "$session_file")"
  echo "  - Clarify: $(jq -r '.specswarm.clarify.status' "$session_file")"
  echo "  - Plan: $(jq -r '.specswarm.plan.status' "$session_file")"
  echo "  - Tasks: $(jq -r '.specswarm.tasks.status' "$session_file") ($(jq -r '.specswarm.tasks.task_count' "$session_file") tasks)"
  echo ""
  echo "Implementation:"
  echo "  - Total Tasks: $(jq -r '.implementation.total_count' "$session_file")"
  echo "  - Completed: $(jq -r '.implementation.completed_count' "$session_file")"
  echo "  - Failed: $(jq -r '.implementation.failed_count' "$session_file")"
  echo ""
  echo "Bugfix:"
  echo "  - Status: $(jq -r '.bugfix.status' "$session_file")"
  echo "  - Attempts: $(jq -r '.bugfix.attempts' "$session_file")"
  echo "  - Issues Fixed: $(jq -r '.bugfix.issues_fixed' "$session_file")"
  echo ""
  echo "Result:"
  echo "  - Success: $(jq -r '.result.success' "$session_file")"
  echo "  - Message: $(jq -r '.result.message' "$session_file")"
  echo ""
}

# Export feature session report
# Args: session_id
feature_export_report() {
  local session_id="$1"
  local session_file="${FEATURE_SESSION_DIR}/${session_id}.json"

  if [ ! -f "$session_file" ]; then
    echo "Error: Session $session_id not found" >&2
    return 1
  fi

  local report_file="${FEATURE_SESSION_DIR}/${session_id}_report.md"

  cat > "$report_file" <<EOF
# Feature Orchestration Report

**Session ID**: $session_id
**Feature**: $(jq -r '.feature_name' "$session_file")
**Status**: $(jq -r '.status' "$session_file")
**Created**: $(jq -r '.created_at' "$session_file")
**Updated**: $(jq -r '.updated_at' "$session_file")

## Planning Phase (SpecSwarm)

| Command | Status | Output File |
|---------|--------|-------------|
| specify | $(jq -r '.specswarm.specify.status' "$session_file") | $(jq -r '.specswarm.specify.output_file' "$session_file") |
| clarify | $(jq -r '.specswarm.clarify.status' "$session_file") | $(jq -r '.specswarm.clarify.output_file' "$session_file") |
| plan | $(jq -r '.specswarm.plan.status' "$session_file") | $(jq -r '.specswarm.plan.output_file' "$session_file") |
| tasks | $(jq -r '.specswarm.tasks.status' "$session_file") | $(jq -r '.specswarm.tasks.output_file' "$session_file") |

**Tasks Generated**: $(jq -r '.specswarm.tasks.task_count' "$session_file")

## Implementation Phase

**Total Tasks**: $(jq -r '.implementation.total_count' "$session_file")
**Completed**: $(jq -r '.implementation.completed_count' "$session_file")
**Failed**: $(jq -r '.implementation.failed_count' "$session_file")

### Task Details

EOF

  # Add task details
  jq -r '.implementation.tasks[] | "- **\(.id)**: \(.description)\n  - Status: \(.status)\n  - Attempts: \(.attempts)\n  - Validation: \(.validation_passed)\n"' "$session_file" >> "$report_file"

  cat >> "$report_file" <<EOF

## Bugfix Phase

**Status**: $(jq -r '.bugfix.status' "$session_file")
**Attempts**: $(jq -r '.bugfix.attempts' "$session_file")
**Issues Fixed**: $(jq -r '.bugfix.issues_fixed' "$session_file")

## Metrics

- **Total Time**: $(jq -r '.metrics.total_time_seconds' "$session_file")s
- **Planning Time**: $(jq -r '.metrics.planning_time_seconds' "$session_file")s
- **Implementation Time**: $(jq -r '.metrics.implementation_time_seconds' "$session_file")s
- **Bugfix Time**: $(jq -r '.metrics.bugfix_time_seconds' "$session_file")s
- **Total Retries**: $(jq -r '.metrics.total_retries' "$session_file")
- **Total Validations**: $(jq -r '.metrics.total_validations' "$session_file")

## Result

**Success**: $(jq -r '.result.success' "$session_file")
**Message**: $(jq -r '.result.message' "$session_file")

---
*Generated by SpecLabs Feature Orchestrator (Phase 2)*
EOF

  echo "$report_file"
}

# Initialize on source
feature_init
