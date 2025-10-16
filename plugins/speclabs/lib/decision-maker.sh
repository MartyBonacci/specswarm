#!/bin/bash
#
# Decision Maker for SpecLabs Orchestrator
# Analyzes orchestration results and decides next action
#
# Part of Phase 1a: Test Orchestrator Foundation
#

set -euo pipefail

# Source state manager if not already loaded
if ! declare -f state_get >/dev/null 2>&1; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/state-manager.sh"
fi

#######################################
# Make decision on what to do next
# Arguments:
#   $1 - session_id: Session identifier
# Outputs:
#   decision: complete | retry | escalate | unknown
# Returns:
#   0 on success, 1 on error
#######################################
decision_make() {
  local session_id="$1"

  # Validate session exists
  if ! state_exists "$session_id"; then
    echo "ERROR: Session not found: $session_id" >&2
    return 1
  fi

  # Get current state
  local agent_status
  agent_status=$(state_get "$session_id" "agent.status")
  local validation_status
  validation_status=$(state_get "$session_id" "validation.status")
  local retry_count
  retry_count=$(state_get "$session_id" "retries.count")
  local max_retries
  max_retries=$(state_get "$session_id" "retries.max")

  # Decision Logic Tree

  # DECISION: COMPLETE
  # Agent succeeded AND validation passed
  if [ "$agent_status" == "completed" ] && [ "$validation_status" == "passed" ]; then
    echo "complete"
    return 0
  fi

  # DECISION: RETRY (within retry limit)
  # Agent failed OR validation failed, AND we have retries left
  if [ "$retry_count" -lt "$max_retries" ]; then
    if [ "$agent_status" == "failed" ] || [ "$validation_status" == "failed" ]; then
      echo "retry"
      return 0
    fi

    # Also retry if agent completed but validation failed
    if [ "$agent_status" == "completed" ] && [ "$validation_status" == "failed" ]; then
      echo "retry"
      return 0
    fi
  fi

  # DECISION: ESCALATE (max retries exceeded)
  # We've tried multiple times and still failing
  if [ "$retry_count" -ge "$max_retries" ]; then
    echo "escalate"
    return 0
  fi

  # DECISION: UNKNOWN (shouldn't happen)
  # This indicates an unexpected state
  echo "unknown"
  return 0
}

#######################################
# Get detailed decision with reasoning
# Arguments:
#   $1 - session_id: Session identifier
# Outputs:
#   JSON object with decision, reason, and details
# Returns:
#   0 on success, 1 on error
#######################################
decision_make_detailed() {
  local session_id="$1"

  # Get basic decision
  local decision
  decision=$(decision_make "$session_id")

  # Get state for reasoning
  local agent_status
  agent_status=$(state_get "$session_id" "agent.status")
  local validation_status
  validation_status=$(state_get "$session_id" "validation.status")
  local retry_count
  retry_count=$(state_get "$session_id" "retries.count")
  local max_retries
  max_retries=$(state_get "$session_id" "retries.max")

  # Build reasoning based on decision
  local reason
  local details

  case "$decision" in
    complete)
      reason="Agent succeeded and validation passed"
      details="Ready for deployment"
      ;;
    retry)
      if [ "$agent_status" == "failed" ]; then
        reason="Agent failed to complete task"
        details="Will refine prompt and retry (attempt $((retry_count + 1))/$max_retries)"
      elif [ "$validation_status" == "failed" ]; then
        reason="Validation detected issues"
        details="Will refine requirements and retry (attempt $((retry_count + 1))/$max_retries)"
      else
        reason="Task did not meet success criteria"
        details="Will retry with refined approach (attempt $((retry_count + 1))/$max_retries)"
      fi
      ;;
    escalate)
      reason="Max retries ($max_retries) exceeded"
      details="Human intervention required - automated attempts exhausted"
      ;;
    unknown)
      reason="Unexpected state encountered"
      details="Agent: $agent_status, Validation: $validation_status, Retries: $retry_count/$max_retries"
      ;;
  esac

  # Output as JSON
  cat <<EOF
{
  "decision": "$decision",
  "reason": "$reason",
  "details": "$details",
  "state": {
    "agent_status": "$agent_status",
    "validation_status": "$validation_status",
    "retry_count": $retry_count,
    "max_retries": $max_retries
  }
}
EOF

  return 0
}

#######################################
# Analyze failure and generate retry strategy
# Arguments:
#   $1 - session_id: Session identifier
# Outputs:
#   Retry strategy description
# Returns:
#   0 on success, 1 on error
#######################################
decision_analyze_failure() {
  local session_id="$1"

  # Get failure information
  local agent_status
  agent_status=$(state_get "$session_id" "agent.status")
  local agent_error
  agent_error=$(state_get "$session_id" "agent.error")
  local validation_status
  validation_status=$(state_get "$session_id" "validation.status")

  # Get validation details if available
  local console_errors
  console_errors=$(state_get "$session_id" "validation.playwright.console_errors" 2>/dev/null || echo "null")
  local network_errors
  network_errors=$(state_get "$session_id" "validation.playwright.network_errors" 2>/dev/null || echo "null")
  local vision_issues
  vision_issues=$(state_get "$session_id" "validation.vision_api.issues_found" 2>/dev/null || echo "[]")

  # Analyze and categorize failure
  local failure_type="unknown"
  local strategy=""

  # Agent failure analysis
  if [ "$agent_status" == "failed" ]; then
    # File/path errors
    if echo "$agent_error" | grep -qi "file not found\|no such file\|cannot find"; then
      failure_type="file_not_found"
      strategy="Add explicit file paths and verify they exist before modifying"

    # Permission errors
    elif echo "$agent_error" | grep -qi "permission denied\|access denied"; then
      failure_type="permission_error"
      strategy="Check file permissions and project path access"

    # Syntax/compilation errors
    elif echo "$agent_error" | grep -qi "syntax error\|syntaxerror\|compilation failed\|type error\|unexpected token"; then
      failure_type="syntax_error"
      strategy="Review code syntax and type definitions, add more examples"

    # Dependency errors
    elif echo "$agent_error" | grep -qi "module not found\|modulenotfounderror\|cannot import\|importerror\|dependency"; then
      failure_type="dependency_error"
      strategy="Verify dependencies are installed and import paths are correct"

    # Timeout errors
    elif echo "$agent_error" | grep -qi "timeout\|timed out"; then
      failure_type="timeout"
      strategy="Break task into smaller subtasks or increase timeout"

    # General agent failure
    else
      failure_type="general_agent_failure"
      strategy="Add more context, examples, and explicit step-by-step instructions"
    fi

  # Validation failure analysis
  elif [ "$validation_status" == "failed" ]; then
    # Console errors detected
    if [ "$console_errors" != "null" ] && [ "$console_errors" != "0" ]; then
      failure_type="console_errors"
      strategy="Fix JavaScript errors - review console output and add error handling"

    # Network errors detected
    elif [ "$network_errors" != "null" ] && [ "$network_errors" != "0" ]; then
      failure_type="network_errors"
      strategy="Fix API/network issues - verify endpoints and error responses"

    # Visual/UI issues
    elif [ "$vision_issues" != "[]" ]; then
      failure_type="ui_issues"
      strategy="Address UI issues - ensure all elements render correctly and are styled properly"

    # General validation failure
    else
      failure_type="validation_failure"
      strategy="Review validation criteria and ensure all requirements are met"
    fi
  fi

  # Output analysis
  cat <<EOF
{
  "failure_type": "$failure_type",
  "strategy": "$strategy",
  "details": {
    "agent_status": "$agent_status",
    "agent_error": "$agent_error",
    "validation_status": "$validation_status",
    "console_errors": $console_errors,
    "network_errors": $network_errors,
    "vision_issues": $vision_issues
  }
}
EOF

  return 0
}

#######################################
# Generate retry strategy based on failure
# Arguments:
#   $1 - session_id: Session identifier
# Outputs:
#   Retry strategy recommendations
# Returns:
#   0 on success, 1 on error
#######################################
decision_generate_retry_strategy() {
  local session_id="$1"

  # Analyze failure
  local analysis
  analysis=$(decision_analyze_failure "$session_id")

  local failure_type
  failure_type=$(echo "$analysis" | jq -r '.failure_type')
  local strategy
  strategy=$(echo "$analysis" | jq -r '.strategy')
  local retry_count
  retry_count=$(state_get "$session_id" "retries.count")

  # Build retry strategy
  local retry_approach=""
  local prompt_refinements=""
  local additional_context=""

  case "$failure_type" in
    file_not_found)
      retry_approach="explicit_paths"
      prompt_refinements="- Add absolute file paths\n- Verify files exist before modifying\n- Use 'find' or 'ls' to locate files"
      additional_context="Project structure overview"
      ;;

    permission_error)
      retry_approach="check_permissions"
      prompt_refinements="- Verify write permissions\n- Check project path is accessible\n- Use relative paths from project root"
      additional_context="File system permissions"
      ;;

    syntax_error)
      retry_approach="add_examples"
      prompt_refinements="- Include correct syntax examples\n- Reference existing code patterns\n- Add type definitions"
      additional_context="Similar working examples from codebase"
      ;;

    dependency_error)
      retry_approach="verify_dependencies"
      prompt_refinements="- Check package.json/requirements\n- Verify import paths\n- Ensure dependencies are installed"
      additional_context="Dependency list and import patterns"
      ;;

    timeout)
      retry_approach="break_down_task"
      prompt_refinements="- Break into smaller subtasks\n- Focus on one component at a time\n- Implement incrementally"
      additional_context="Task breakdown strategy"
      ;;

    console_errors)
      retry_approach="fix_runtime_errors"
      prompt_refinements="- Add error handling\n- Fix undefined references\n- Validate data before use"
      additional_context="Console error details"
      ;;

    network_errors)
      retry_approach="fix_api_calls"
      prompt_refinements="- Verify API endpoints\n- Add error handling for network requests\n- Check response status codes"
      additional_context="API documentation"
      ;;

    ui_issues)
      retry_approach="improve_ui"
      prompt_refinements="- Ensure all UI elements are present\n- Apply proper styling\n- Verify responsive design"
      additional_context="UI requirements and design specs"
      ;;

    *)
      retry_approach="add_more_context"
      prompt_refinements="- Provide more detailed requirements\n- Add step-by-step instructions\n- Include examples from similar tasks"
      additional_context="General context and examples"
      ;;
  esac

  # Escalation warning if nearing max retries
  local escalation_warning=""
  local max_retries
  max_retries=$(state_get "$session_id" "retries.max")
  if [ "$retry_count" -ge $((max_retries - 1)) ]; then
    escalation_warning="WARNING: This is the final retry attempt. Next failure will escalate to human."
  fi

  # Output retry strategy
  cat <<EOF
{
  "failure_type": "$failure_type",
  "base_strategy": "$strategy",
  "retry_approach": "$retry_approach",
  "prompt_refinements": "$prompt_refinements",
  "additional_context": "$additional_context",
  "retry_count": $retry_count,
  "max_retries": $max_retries,
  "escalation_warning": "$escalation_warning"
}
EOF

  return 0
}

#######################################
# Record decision in session state
# Arguments:
#   $1 - session_id: Session identifier
#   $2 - decision: complete | retry | escalate
#   $3 - reason: Why this decision was made
# Returns:
#   0 on success, 1 on error
#######################################
decision_record() {
  local session_id="$1"
  local decision="$2"
  local reason="$3"

  # Validate decision
  if [[ ! "$decision" =~ ^(complete|retry|escalate|unknown)$ ]]; then
    echo "ERROR: Invalid decision: $decision" >&2
    return 1
  fi

  # Record decision
  local timestamp
  timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  local decision_json
  decision_json=$(cat <<EOF
{
  "action": "$decision",
  "reason": "$reason",
  "timestamp": "$timestamp"
}
EOF
  )

  state_update "$session_id" "decision" "$decision_json"
  return $?
}

#######################################
# Check if should escalate to human
# Arguments:
#   $1 - session_id: Session identifier
# Returns:
#   0 if should escalate, 1 if not
#######################################
decision_should_escalate() {
  local session_id="$1"

  local retry_count
  retry_count=$(state_get "$session_id" "retries.count")
  local max_retries
  max_retries=$(state_get "$session_id" "retries.max")

  # Escalate if max retries reached
  if [ "$retry_count" -ge "$max_retries" ]; then
    return 0
  fi

  # Don't escalate yet
  return 1
}

#######################################
# Get human escalation message
# Arguments:
#   $1 - session_id: Session identifier
# Outputs:
#   Human-readable escalation message
# Returns:
#   0 on success
#######################################
decision_get_escalation_message() {
  local session_id="$1"

  local task_name
  task_name=$(state_get "$session_id" "workflow.task_name")
  local retry_count
  retry_count=$(state_get "$session_id" "retries.count")
  local agent_error
  agent_error=$(state_get "$session_id" "agent.error")

  cat <<EOF
╔════════════════════════════════════════════════════════════╗
║  HUMAN ESCALATION REQUIRED                                 ║
╚════════════════════════════════════════════════════════════╝

Session: $session_id
Task: $task_name

The orchestrator has attempted this task $retry_count times without success.

Last Agent Error:
$agent_error

What happened:
- Multiple autonomous attempts failed
- Automatic recovery strategies exhausted
- Task complexity may exceed autonomous capability

Next Steps:
1. Review session details: state_print_summary "$session_id"
2. Examine agent output: cat \$(state_get_session_dir "$session_id")/agent-output.log
3. Decide whether to:
   - Modify the task workflow and retry manually
   - Complete the task manually
   - Break the task into smaller subtasks
   - Abandon this approach

Session directory: \$(state_get_session_dir "$session_id")

╚════════════════════════════════════════════════════════════╝
EOF

  return 0
}

#######################################
# Print decision summary
# Arguments:
#   $1 - session_id: Session identifier
# Outputs:
#   Human-readable decision summary
# Returns:
#   0 on success
#######################################
decision_print_summary() {
  local session_id="$1"

  # Get detailed decision
  local decision_data
  decision_data=$(decision_make_detailed "$session_id")

  local decision
  decision=$(echo "$decision_data" | jq -r '.decision')
  local reason
  reason=$(echo "$decision_data" | jq -r '.reason')
  local details
  details=$(echo "$decision_data" | jq -r '.details')

  # Print summary with color
  local color
  case "$decision" in
    complete) color='\033[0;32m' ;;  # Green
    retry) color='\033[1;33m' ;;     # Yellow
    escalate) color='\033[0;31m' ;;  # Red
    *) color='\033[0m' ;;            # No color
  esac
  local nc='\033[0m'

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "${color}Decision: $(echo "$decision" | tr '[:lower:]' '[:upper:]')${nc}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Reason: $reason"
  echo "Details: $details"
  echo ""

  # Show retry strategy if retrying
  if [ "$decision" == "retry" ]; then
    echo "Retry Strategy:"
    local retry_strategy
    retry_strategy=$(decision_generate_retry_strategy "$session_id")
    echo "$retry_strategy" | jq -r '.base_strategy'
    echo ""
  fi

  # Show escalation message if escalating
  if [ "$decision" == "escalate" ]; then
    decision_get_escalation_message "$session_id"
  fi

  return 0
}

# Export functions if sourced
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
  export -f decision_make
  export -f decision_make_detailed
  export -f decision_analyze_failure
  export -f decision_generate_retry_strategy
  export -f decision_record
  export -f decision_should_escalate
  export -f decision_get_escalation_message
  export -f decision_print_summary
fi
