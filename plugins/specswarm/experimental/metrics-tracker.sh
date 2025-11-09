#!/bin/bash
#
# Metrics Tracker for SpecLabs Orchestrator
# Collects and analyzes orchestration metrics for continuous improvement
#
# Part of Phase 1a: Test Orchestrator Foundation
#

set -euo pipefail

# Source dependencies if not already loaded
if ! declare -f state_get >/dev/null 2>&1; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/state-manager.sh"
fi

# Configuration
METRICS_DIR="${ORCHESTRATOR_STATE_DIR:-/home/marty/code-projects/specswarm/memory/orchestrator}/metrics"
mkdir -p "$METRICS_DIR"

#######################################
# Collect metrics from a session
# Arguments:
#   $1 - session_id: Session identifier
# Outputs:
#   JSON with collected metrics
#######################################
metrics_collect() {
  local session_id="$1"

  if ! state_exists "$session_id"; then
    echo "ERROR: Session not found: $session_id" >&2
    return 1
  fi

  # Get all relevant state
  local status=$(state_get "$session_id" "status")
  local created_at=$(state_get "$session_id" "created_at")
  local completed_at=$(state_get "$session_id" "completed_at" 2>/dev/null || echo "null")
  local retry_count=$(state_get "$session_id" "retries.count")
  local max_retries=$(state_get "$session_id" "retries.max")
  local agent_status=$(state_get "$session_id" "agent.status")
  local validation_status=$(state_get "$session_id" "validation.status")
  local decision_action=$(state_get "$session_id" "decision.action" 2>/dev/null || echo "null")
  local total_time=$(state_get "$session_id" "metrics.total_time_seconds" 2>/dev/null || echo "null")

  # Calculate success metrics
  local success=$([ "$status" == "success" ] && echo "true" || echo "false")
  local retry_success=$([ "$retry_count" -gt 0 ] && [ "$status" == "success" ] && echo "true" || echo "false")
  local escalated=$([ "$status" == "escalated" ] && echo "true" || echo "false")

  # Output metrics
  cat <<EOF
{
  "session_id": "$session_id",
  "timestamp": "$created_at",
  "status": "$status",
  "success": $success,
  "retry_success": $retry_success,
  "escalated": $escalated,
  "retry_count": $retry_count,
  "max_retries": $max_retries,
  "agent_status": "$agent_status",
  "validation_status": "$validation_status",
  "decision_action": "$decision_action",
  "total_time_seconds": $total_time
}
EOF

  return 0
}

#######################################
# Aggregate metrics from all sessions
# Arguments:
#   None
# Outputs:
#   JSON with aggregated metrics
#######################################
metrics_aggregate() {
  local all_sessions=$(state_list_sessions)

  local total=0
  local successful=0
  local failed=0
  local escalated=0
  local retry_successful=0
  local total_retries=0
  local total_time=0

  # Count sessions by status
  for session_id in $all_sessions; do
    if ! state_exists "$session_id"; then
      continue
    fi

    ((total++))

    local status=$(state_get "$session_id" "status" 2>/dev/null || echo "unknown")
    local retry_count=$(state_get "$session_id" "retries.count" 2>/dev/null || echo "0")
    local session_time=$(state_get "$session_id" "metrics.total_time_seconds" 2>/dev/null || echo "0")

    case "$status" in
      success)
        ((successful++))
        if [ "$retry_count" -gt 0 ]; then
          ((retry_successful++))
        fi
        ;;
      failure)
        ((failed++))
        ;;
      escalated)
        ((escalated++))
        ;;
    esac

    total_retries=$((total_retries + retry_count))
    if [ "$session_time" != "null" ] && [ "$session_time" -gt 0 ]; then
      total_time=$((total_time + session_time))
    fi
  done

  # Calculate rates
  local success_rate=0
  local retry_success_rate=0
  local escalation_rate=0
  local avg_retries=0
  local avg_time=0

  if [ "$total" -gt 0 ]; then
    success_rate=$(echo "scale=2; $successful * 100 / $total" | bc)
    escalation_rate=$(echo "scale=2; $escalated * 100 / $total" | bc)
    avg_retries=$(echo "scale=2; $total_retries / $total" | bc)
    avg_time=$(echo "scale=0; $total_time / $total" | bc)
  fi

  if [ "$successful" -gt 0 ]; then
    retry_success_rate=$(echo "scale=2; $retry_successful * 100 / $successful" | bc)
  fi

  # Output aggregated metrics
  cat <<EOF
{
  "total_sessions": $total,
  "successful": $successful,
  "failed": $failed,
  "escalated": $escalated,
  "retry_successful": $retry_successful,
  "success_rate": $success_rate,
  "retry_success_rate": $retry_success_rate,
  "escalation_rate": $escalation_rate,
  "avg_retries_per_session": $avg_retries,
  "avg_time_seconds": $avg_time,
  "total_retries": $total_retries
}
EOF

  return 0
}

#######################################
# Analyze failure patterns
# Arguments:
#   None
# Outputs:
#   JSON with failure analysis
#######################################
metrics_analyze_failures() {
  local all_sessions=$(state_list_sessions)

  # Initialize counters for each failure type
  declare -A failure_counts
  failure_counts[file_not_found]=0
  failure_counts[permission_error]=0
  failure_counts[syntax_error]=0
  failure_counts[dependency_error]=0
  failure_counts[timeout]=0
  failure_counts[console_errors]=0
  failure_counts[network_errors]=0
  failure_counts[ui_issues]=0
  failure_counts[validation_failure]=0
  failure_counts[unknown]=0

  local total_failures=0

  # Count failures by type
  for session_id in $all_sessions; do
    local status=$(state_get "$session_id" "status" 2>/dev/null || echo "unknown")

    if [ "$status" == "failure" ] || [ "$status" == "escalated" ]; then
      ((total_failures++))

      # Get agent error to determine failure type
      local agent_error=$(state_get "$session_id" "agent.error" 2>/dev/null || echo "")

      # Categorize (simplified - real would use decision_analyze_failure)
      if echo "$agent_error" | grep -qi "file not found"; then
        ((failure_counts[file_not_found]++))
      elif echo "$agent_error" | grep -qi "permission denied"; then
        ((failure_counts[permission_error]++))
      elif echo "$agent_error" | grep -qi "syntax"; then
        ((failure_counts[syntax_error]++))
      elif echo "$agent_error" | grep -qi "module not found\|import"; then
        ((failure_counts[dependency_error]++))
      elif echo "$agent_error" | grep -qi "timeout"; then
        ((failure_counts[timeout]++))
      else
        local validation_status=$(state_get "$session_id" "validation.status" 2>/dev/null || echo "")
        if [ "$validation_status" == "failed" ]; then
          local console_errors=$(state_get "$session_id" "validation.playwright.console_errors" 2>/dev/null || echo "0")
          if [ "$console_errors" != "0" ] && [ "$console_errors" != "null" ]; then
            ((failure_counts[console_errors]++))
          else
            ((failure_counts[validation_failure]++))
          fi
        else
          ((failure_counts[unknown]++))
        fi
      fi
    fi
  done

  # Build JSON output
  local json='{'
  json+='"total_failures": '$total_failures','
  json+='"by_type": {'

  local first=true
  for type in "${!failure_counts[@]}"; do
    if [ "$first" = true ]; then
      first=false
    else
      json+=','
    fi
    json+="\"$type\": ${failure_counts[$type]}"
  done

  json+='}}'

  echo "$json"
  return 0
}

#######################################
# Calculate retry effectiveness
# Arguments:
#   None
# Outputs:
#   JSON with retry effectiveness metrics
#######################################
metrics_retry_effectiveness() {
  local all_sessions=$(state_list_sessions)

  local total_with_retries=0
  local successful_after_retry=0
  local failed_after_retries=0

  for session_id in $all_sessions; do
    local retry_count=$(state_get "$session_id" "retries.count" 2>/dev/null || echo "0")

    if [ "$retry_count" -gt 0 ]; then
      ((total_with_retries++))

      local status=$(state_get "$session_id" "status" 2>/dev/null || echo "unknown")

      if [ "$status" == "success" ]; then
        ((successful_after_retry++))
      else
        ((failed_after_retries++))
      fi
    fi
  done

  local effectiveness_rate=0
  if [ "$total_with_retries" -gt 0 ]; then
    effectiveness_rate=$(echo "scale=2; $successful_after_retry * 100 / $total_with_retries" | bc)
  fi

  cat <<EOF
{
  "total_with_retries": $total_with_retries,
  "successful_after_retry": $successful_after_retry,
  "failed_after_retries": $failed_after_retries,
  "effectiveness_rate": $effectiveness_rate
}
EOF

  return 0
}

#######################################
# Generate recommendations
# Arguments:
#   None
# Outputs:
#   JSON array of recommendations
#######################################
metrics_recommendations() {
  local aggregated=$(metrics_aggregate)
  local failure_analysis=$(metrics_analyze_failures)
  local retry_effectiveness=$(metrics_retry_effectiveness)

  local recommendations='[]'

  # Success rate recommendations
  local success_rate=$(echo "$aggregated" | jq -r '.success_rate')
  if (( $(echo "$success_rate < 70" | bc -l) )); then
    recommendations=$(echo "$recommendations" | jq '. + [{
      "priority": "high",
      "category": "success_rate",
      "message": "Success rate is below 70%. Consider improving failure analysis and retry strategies."
    }]')
  fi

  # Retry effectiveness recommendations
  local retry_rate=$(echo "$retry_effectiveness" | jq -r '.effectiveness_rate')
  if (( $(echo "$retry_rate < 60" | bc -l) )); then
    recommendations=$(echo "$recommendations" | jq '. + [{
      "priority": "medium",
      "category": "retry_effectiveness",
      "message": "Retry effectiveness is below 60%. Review prompt refinement strategies."
    }]')
  fi

  # Escalation rate recommendations
  local escalation_rate=$(echo "$aggregated" | jq -r '.escalation_rate')
  if (( $(echo "$escalation_rate > 20" | bc -l) )); then
    recommendations=$(echo "$recommendations" | jq '. + [{
      "priority": "high",
      "category": "escalation_rate",
      "message": "Escalation rate is above 20%. Consider increasing max retries or improving strategies."
    }]')
  fi

  echo "$recommendations"
  return 0
}

#######################################
# Generate metrics report
# Arguments:
#   None
# Outputs:
#   Human-readable metrics report
#######################################
metrics_report() {
  local aggregated=$(metrics_aggregate)
  local failure_analysis=$(metrics_analyze_failures)
  local retry_effectiveness=$(metrics_retry_effectiveness)
  local recommendations=$(metrics_recommendations)

  # Extract values
  local total=$(echo "$aggregated" | jq -r '.total_sessions')
  local successful=$(echo "$aggregated" | jq -r '.successful')
  local success_rate=$(echo "$aggregated" | jq -r '.success_rate')
  local escalated=$(echo "$aggregated" | jq -r '.escalated')
  local escalation_rate=$(echo "$aggregated" | jq -r '.escalation_rate')
  local avg_retries=$(echo "$aggregated" | jq -r '.avg_retries_per_session')
  local retry_success_rate=$(echo "$aggregated" | jq -r '.retry_success_rate')
  local effectiveness=$(echo "$retry_effectiveness" | jq -r '.effectiveness_rate')

  # Generate report
  cat <<EOF

╔════════════════════════════════════════════════════════════╗
║  Orchestrator Metrics Report                               ║
╚════════════════════════════════════════════════════════════╝

## Overall Performance

Total Sessions:      $total
Successful:          $successful
Success Rate:        ${success_rate}%
Escalated:           $escalated
Escalation Rate:     ${escalation_rate}%

## Retry Metrics

Avg Retries/Session: $avg_retries
Retry Success Rate:  ${retry_success_rate}%
Retry Effectiveness: ${effectiveness}%

## Failure Analysis

$(echo "$failure_analysis" | jq -r '.by_type | to_entries[] | "  \(.key): \(.value)"')

## Recommendations

$(echo "$recommendations" | jq -r '.[] | "[\(.priority | ascii_upcase)] \(.message)"')

$(if [ $(echo "$recommendations" | jq 'length') -eq 0 ]; then
  echo "  No recommendations - orchestrator performing well!"
fi)

╚════════════════════════════════════════════════════════════╝
EOF

  return 0
}

#######################################
# Export metrics to JSON file
# Arguments:
#   $1 - output_file: Path to output file
# Returns:
#   0 on success
#######################################
metrics_export() {
  local output_file="$1"

  local aggregated=$(metrics_aggregate)
  local failure_analysis=$(metrics_analyze_failures)
  local retry_effectiveness=$(metrics_retry_effectiveness)
  local recommendations=$(metrics_recommendations)

  # Combine all metrics
  jq -n \
    --argjson aggregated "$aggregated" \
    --argjson failures "$failure_analysis" \
    --argjson retries "$retry_effectiveness" \
    --argjson recommendations "$recommendations" \
    '{
      "generated_at": (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
      "aggregated": $aggregated,
      "failure_analysis": $failures,
      "retry_effectiveness": $retries,
      "recommendations": $recommendations
    }' > "$output_file"

  echo "Metrics exported to: $output_file"
  return 0
}

# Export functions if sourced
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
  export -f metrics_collect
  export -f metrics_aggregate
  export -f metrics_analyze_failures
  export -f metrics_retry_effectiveness
  export -f metrics_recommendations
  export -f metrics_report
  export -f metrics_export
fi
