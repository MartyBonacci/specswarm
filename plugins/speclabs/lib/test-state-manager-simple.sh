#!/bin/bash
#
# Simple Test Script for State Manager
# Quick validation of core functionality
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Source state manager
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/state-manager.sh"

echo "╔════════════════════════════════════════╗"
echo "║  State Manager Test Suite (Simple)     ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Test 1: Create Session
echo "Test 1: Create Session"
SESSION_ID=$(state_create_session "test-workflow.md" "/test/project" "Test Task")
if [ -n "$SESSION_ID" ]; then
  echo -e "${GREEN}✓${NC} Created session: $SESSION_ID"
else
  echo -e "${RED}✗${NC} Failed to create session"
  exit 1
fi
echo ""

# Test 2: Get State
echo "Test 2: Get State Values"
STATUS=$(state_get "$SESSION_ID" "status")
if [ "$STATUS" == "in_progress" ]; then
  echo -e "${GREEN}✓${NC} Status is correct: $STATUS"
else
  echo -e "${RED}✗${NC} Status is incorrect: $STATUS"
  exit 1
fi

TASK_NAME=$(state_get "$SESSION_ID" "workflow.task_name")
if [ "$TASK_NAME" == "Test Task" ]; then
  echo -e "${GREEN}✓${NC} Task name is correct: $TASK_NAME"
else
  echo -e "${RED}✗${NC} Task name is incorrect: $TASK_NAME"
  exit 1
fi
echo ""

# Test 3: Update State
echo "Test 3: Update State"
state_update "$SESSION_ID" "agent.status" '"running"'
AGENT_STATUS=$(state_get "$SESSION_ID" "agent.status")
if [ "$AGENT_STATUS" == "running" ]; then
  echo -e "${GREEN}✓${NC} Agent status updated: $AGENT_STATUS"
else
  echo -e "${RED}✗${NC} Agent status not updated: $AGENT_STATUS"
  exit 1
fi
echo ""

# Test 4: Resume Session (Retry)
echo "Test 4: Resume Session (Retry)"
state_resume "$SESSION_ID" >/dev/null
RETRY_COUNT=$(state_get "$SESSION_ID" "retries.count")
if [ "$RETRY_COUNT" == "1" ]; then
  echo -e "${GREEN}✓${NC} Retry count incremented: $RETRY_COUNT"
else
  echo -e "${RED}✗${NC} Retry count not incremented: $RETRY_COUNT"
  exit 1
fi
echo ""

# Test 5: Complete Session
echo "Test 5: Complete Session"
state_complete "$SESSION_ID" "success"
FINAL_STATUS=$(state_get "$SESSION_ID" "status")
if [ "$FINAL_STATUS" == "success" ]; then
  echo -e "${GREEN}✓${NC} Session completed: $FINAL_STATUS"
else
  echo -e "${RED}✗${NC} Session not completed: $FINAL_STATUS"
  exit 1
fi
echo ""

# Test 6: List Sessions
echo "Test 6: List Sessions"
SESSIONS=$(state_list_sessions)
if echo "$SESSIONS" | grep -q "$SESSION_ID"; then
  echo -e "${GREEN}✓${NC} Session appears in list"
else
  echo -e "${RED}✗${NC} Session not in list"
  exit 1
fi
echo ""

# Test 7: Session Directory
echo "Test 7: Session Directory"
SESSION_DIR=$(state_get_session_dir "$SESSION_ID")
if [ -d "$SESSION_DIR" ]; then
  echo -e "${GREEN}✓${NC} Session directory exists: $SESSION_DIR"
else
  echo -e "${RED}✗${NC} Session directory not found: $SESSION_DIR"
  exit 1
fi

if [ -f "$SESSION_DIR/state.json" ]; then
  echo -e "${GREEN}✓${NC} State file exists in directory"
else
  echo -e "${RED}✗${NC} State file not found in directory"
  exit 1
fi
echo ""

# Test 8: Print Summary
echo "Test 8: Print Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
state_print_summary "$SESSION_ID"
echo ""

# Test 9: State Validation
echo "Test 9: State Validation"
if state_validate "$SESSION_ID" 2>/dev/null; then
  echo -e "${GREEN}✓${NC} State is valid"
else
  echo -e "${RED}✗${NC} State validation failed"
  exit 1
fi
echo ""

# Test 10: Error Handling
echo "Test 10: Error Handling"
if state_get "invalid-session" "status" 2>/dev/null; then
  echo -e "${RED}✗${NC} Should have failed for invalid session"
  exit 1
else
  echo -e "${GREEN}✓${NC} Correctly failed for invalid session"
fi
echo ""

echo "╔════════════════════════════════════════╗"
echo "║  All Tests Passed!                     ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}✓ State Manager is working correctly${NC}"
echo ""
