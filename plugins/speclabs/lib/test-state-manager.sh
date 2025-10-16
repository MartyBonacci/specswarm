#!/bin/bash
#
# Test Script for State Manager
# Validates all state manager functions
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Source the state manager
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/state-manager.sh"

#######################################
# Test helper: Assert equals
#######################################
assert_equals() {
  local expected="$1"
  local actual="$2"
  local test_name="$3"

  ((TESTS_RUN++))

  if [ "$expected" == "$actual" ]; then
    echo -e "${GREEN}✓${NC} $test_name"
    ((TESTS_PASSED++))
    return 0
  else
    echo -e "${RED}✗${NC} $test_name"
    echo "  Expected: $expected"
    echo "  Actual:   $actual"
    ((TESTS_FAILED++))
    return 1
  fi
}

#######################################
# Test helper: Assert success
#######################################
assert_success() {
  local exit_code="$1"
  local test_name="$2"

  ((TESTS_RUN++))

  if [ "$exit_code" -eq 0 ]; then
    echo -e "${GREEN}✓${NC} $test_name"
    ((TESTS_PASSED++))
    return 0
  else
    echo -e "${RED}✗${NC} $test_name (exit code: $exit_code)"
    ((TESTS_FAILED++))
    return 1
  fi
}

#######################################
# Test helper: Assert failure
#######################################
assert_failure() {
  local exit_code="$1"
  local test_name="$2"

  ((TESTS_RUN++))

  if [ "$exit_code" -ne 0 ]; then
    echo -e "${GREEN}✓${NC} $test_name"
    ((TESTS_PASSED++))
    return 0
  else
    echo -e "${RED}✗${NC} $test_name"
    ((TESTS_FAILED++))
    return 1
  fi
}

#######################################
# Test: Create session
#######################################
test_create_session() {
  echo ""
  echo "Test Suite: Create Session"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  local session_id
  session_id=$(state_create_session \
    "features/test/workflow.md" \
    "/home/marty/project" \
    "Test Task")
  local create_result=$?
  assert_success "$create_result" "Should create session"

  # Check session ID format
  if [[ $session_id =~ ^orch-[0-9]{8}-[0-9]{6}$ ]]; then
    assert_equals "true" "true" "Session ID format is correct"
  else
    assert_equals "correct_format" "$session_id" "Session ID format is correct"
  fi

  # Check session exists
  state_exists "$session_id"
  assert_success $? "Session should exist"

  # Validate state structure
  state_validate "$session_id" 2>/dev/null
  assert_success $? "State should be valid"

  # Check initial values
  local status
  status=$(state_get "$session_id" "status")
  assert_equals "in_progress" "$status" "Initial status should be in_progress"

  local task_name
  task_name=$(state_get "$session_id" "workflow.task_name")
  assert_equals "Test Task" "$task_name" "Task name should be set"

  local agent_status
  agent_status=$(state_get "$session_id" "agent.status")
  assert_equals "pending" "$agent_status" "Agent status should be pending"

  local retry_count
  retry_count=$(state_get "$session_id" "retries.count")
  assert_equals "0" "$retry_count" "Retry count should be 0"

  # Return session ID for other tests
  echo "$session_id"
}

#######################################
# Test: Update state
#######################################
test_update_state() {
  local session_id="$1"

  echo ""
  echo "Test Suite: Update State"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Update agent status
  state_update "$session_id" "agent.status" '"running"'
  assert_success "Should update agent status"

  local agent_status
  agent_status=$(state_get "$session_id" "agent.status")
  assert_equals "running" "$agent_status" "Agent status should be updated"

  # Update nested value
  state_update "$session_id" "validation.playwright.console_errors" "0"
  assert_success "Should update nested value"

  local console_errors
  console_errors=$(state_get "$session_id" "validation.playwright.console_errors")
  assert_equals "0" "$console_errors" "Console errors should be updated"

  # Update with object
  state_update "$session_id" "decision" '{"action": "complete", "reason": "Success"}'
  assert_success "Should update with object"

  local decision_action
  decision_action=$(state_get "$session_id" "decision.action")
  assert_equals "complete" "$decision_action" "Decision action should be set"
}

#######################################
# Test: Get state
#######################################
test_get_state() {
  local session_id="$1"

  echo ""
  echo "Test Suite: Get State"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Get simple value
  local status
  status=$(state_get "$session_id" "status")
  assert_success "Should get simple value"

  # Get nested value
  local task_name
  task_name=$(state_get "$session_id" "workflow.task_name")
  assert_equals "Test Task" "$task_name" "Should get nested value"

  # Get entire state
  local full_state
  full_state=$(state_get_all "$session_id")
  assert_success "Should get full state"

  # Verify it's valid JSON
  echo "$full_state" | jq empty 2>/dev/null
  assert_success "Full state should be valid JSON"
}

#######################################
# Test: Resume session
#######################################
test_resume_session() {
  local session_id="$1"

  echo ""
  echo "Test Suite: Resume Session"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Resume session (retry)
  state_resume "$session_id" >/dev/null
  assert_success "Should resume session"

  local retry_count
  retry_count=$(state_get "$session_id" "retries.count")
  assert_equals "1" "$retry_count" "Retry count should increment"

  # Resume again
  state_resume "$session_id" >/dev/null
  assert_success "Should resume again"

  retry_count=$(state_get "$session_id" "retries.count")
  assert_equals "2" "$retry_count" "Retry count should increment again"

  # Resume third time
  state_resume "$session_id" >/dev/null
  assert_success "Should resume third time"

  retry_count=$(state_get "$session_id" "retries.count")
  assert_equals "3" "$retry_count" "Retry count should be 3"

  # Try to resume beyond max (should fail)
  state_resume "$session_id" >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    assert_equals "true" "true" "Should fail to resume beyond max retries"
  else
    assert_equals "should_fail" "succeeded" "Should fail to resume beyond max retries"
  fi
}

#######################################
# Test: Complete session
#######################################
test_complete_session() {
  echo ""
  echo "Test Suite: Complete Session"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Create new session for completion test
  local session_id
  session_id=$(state_create_session \
    "features/test/complete.md" \
    "/home/marty/project" \
    "Completion Test")

  # Complete with success
  state_complete "$session_id" "success"
  assert_success "Should complete session with success"

  local status
  status=$(state_get "$session_id" "status")
  assert_equals "success" "$status" "Status should be success"

  local completed_at
  completed_at=$(state_get "$session_id" "completed_at")
  if [ "$completed_at" != "null" ]; then
    assert_equals "true" "true" "Completed_at should be set"
  else
    assert_equals "not_null" "null" "Completed_at should be set"
  fi

  # Test invalid status
  state_complete "$session_id" "invalid" >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    assert_equals "true" "true" "Should reject invalid status"
  else
    assert_equals "should_fail" "succeeded" "Should reject invalid status"
  fi
}

#######################################
# Test: List sessions
#######################################
test_list_sessions() {
  echo ""
  echo "Test Suite: List Sessions"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Create multiple sessions
  local session1=$(state_create_session "f1.md" "/p1" "Task 1")
  local session2=$(state_create_session "f2.md" "/p2" "Task 2")
  state_complete "$session2" "success"

  # List all sessions
  local all_sessions
  all_sessions=$(state_list_sessions)
  assert_success "Should list all sessions"

  # Count sessions
  local count
  count=$(echo "$all_sessions" | wc -l)
  if [ "$count" -ge 2 ]; then
    assert_equals "true" "true" "Should have at least 2 sessions"
  else
    assert_equals ">=2" "$count" "Should have at least 2 sessions"
  fi

  # List by status
  local success_sessions
  success_sessions=$(state_list_sessions "success")
  assert_success "Should list success sessions"

  local in_progress_sessions
  in_progress_sessions=$(state_list_sessions "in_progress")
  assert_success "Should list in_progress sessions"
}

#######################################
# Test: Error handling
#######################################
test_error_handling() {
  echo ""
  echo "Test Suite: Error Handling"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Get non-existent session
  state_get "invalid-session-id" "status" >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    assert_equals "true" "true" "Should fail for non-existent session"
  else
    assert_equals "should_fail" "succeeded" "Should fail for non-existent session"
  fi

  # Update non-existent session
  state_update "invalid-session-id" "status" '"test"' >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    assert_equals "true" "true" "Should fail to update non-existent session"
  else
    assert_equals "should_fail" "succeeded" "Should fail to update non-existent session"
  fi

  # Resume non-existent session
  state_resume "invalid-session-id" >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    assert_equals "true" "true" "Should fail to resume non-existent session"
  else
    assert_equals "should_fail" "succeeded" "Should fail to resume non-existent session"
  fi
}

#######################################
# Test: Session directory
#######################################
test_session_directory() {
  local session_id="$1"

  echo ""
  echo "Test Suite: Session Directory"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Get session directory
  local session_dir
  session_dir=$(state_get_session_dir "$session_id")
  assert_success "Should get session directory"

  # Verify directory exists
  if [ -d "$session_dir" ]; then
    assert_equals "true" "true" "Session directory should exist"
  else
    assert_equals "exists" "not_found" "Session directory should exist"
  fi

  # Verify state.json exists
  if [ -f "$session_dir/state.json" ]; then
    assert_equals "true" "true" "State file should exist in directory"
  else
    assert_equals "exists" "not_found" "State file should exist in directory"
  fi
}

#######################################
# Test: Print summary
#######################################
test_print_summary() {
  local session_id="$1"

  echo ""
  echo "Test Suite: Print Summary"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Print summary (just verify it doesn't error)
  state_print_summary "$session_id" >/dev/null
  assert_success "Should print summary without error"
}

#######################################
# Main test runner
#######################################
main() {
  echo "╔════════════════════════════════════════╗"
  echo "║  State Manager Test Suite              ║"
  echo "╚════════════════════════════════════════╝"

  # Run tests
  local test_session_id
  test_session_id=$(test_create_session)
  test_update_state "$test_session_id"
  test_get_state "$test_session_id"
  test_resume_session "$test_session_id"
  test_complete_session
  test_list_sessions
  test_error_handling
  test_session_directory "$test_session_id"
  test_print_summary "$test_session_id"

  # Print results
  echo ""
  echo "╔════════════════════════════════════════╗"
  echo "║  Test Results                          ║"
  echo "╚════════════════════════════════════════╝"
  echo ""
  echo "Tests Run:    $TESTS_RUN"
  echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
  echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
  echo ""

  if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    return 0
  else
    echo -e "${RED}✗ Some tests failed${NC}"
    return 1
  fi
}

# Run tests
main "$@"
