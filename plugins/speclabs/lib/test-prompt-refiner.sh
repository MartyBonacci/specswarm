#!/bin/bash
#
# Test Script for Prompt Refiner
# Validates prompt refinement logic and context injection
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/state-manager.sh"
source "$SCRIPT_DIR/decision-maker.sh"
source "$SCRIPT_DIR/prompt-refiner.sh"

echo "╔════════════════════════════════════════╗"
echo "║  Prompt Refiner Test Suite             ║"
echo "╚════════════════════════════════════════╝"
echo ""

#######################################
# Test 1: Basic Prompt Refinement (File Not Found)
#######################################
echo "Test 1: Basic Prompt Refinement (File Not Found)"

# Create session with file not found error
SESSION_1=$(state_create_session "workflow.md" "/project" "Test Refinement")
state_update "$SESSION_1" "agent.status" '"failed"'
state_update "$SESSION_1" "agent.error" '"Error: file not found src/main.ts"'
state_update "$SESSION_1" "retries.count" "1"

ORIGINAL_PROMPT="Please fix the bug in the authentication module."

REFINED=$(prompt_refine "$SESSION_1" "$ORIGINAL_PROMPT")

# Check that refined prompt includes key elements
if echo "$REFINED" | grep -q "RETRY ATTEMPT 1"; then
  echo -e "${GREEN}✓${NC} Includes retry attempt number"
else
  echo -e "${RED}✗${NC} Missing retry attempt number"
  exit 1
fi

if echo "$REFINED" | grep -q "file_not_found"; then
  echo -e "${GREEN}✓${NC} Includes failure type"
else
  echo -e "${RED}✗${NC} Missing failure type"
  exit 1
fi

if echo "$REFINED" | grep -q "absolute file paths"; then
  echo -e "${GREEN}✓${NC} Includes specific guidance"
else
  echo -e "${RED}✗${NC} Missing specific guidance"
  exit 1
fi

if echo "$REFINED" | grep -q "Original Task"; then
  echo -e "${GREEN}✓${NC} Includes original prompt"
else
  echo -e "${RED}✗${NC} Missing original prompt"
  exit 1
fi

if echo "$REFINED" | grep -q "Verification Checklist"; then
  echo -e "${GREEN}✓${NC} Includes verification checklist"
else
  echo -e "${RED}✗${NC} Missing verification checklist"
  exit 1
fi

echo ""

#######################################
# Test 2: Syntax Error Refinement
#######################################
echo "Test 2: Syntax Error Refinement"

SESSION_2=$(state_create_session "workflow.md" "/project" "Test Syntax Error")
state_update "$SESSION_2" "agent.status" '"failed"'
state_update "$SESSION_2" "agent.error" '"SyntaxError: unexpected token at line 42"'
state_update "$SESSION_2" "retries.count" "1"

REFINED_2=$(prompt_refine "$SESSION_2" "Fix the component.")

if echo "$REFINED_2" | grep -q "syntax_error"; then
  echo -e "${GREEN}✓${NC} Detected syntax error failure type"
else
  echo -e "${RED}✗${NC} Failed to detect syntax error"
  exit 1
fi

if echo "$REFINED_2" | grep -q "Follow language syntax strictly"; then
  echo -e "${GREEN}✓${NC} Includes syntax-specific guidance"
else
  echo -e "${RED}✗${NC} Missing syntax-specific guidance"
  exit 1
fi

if echo "$REFINED_2" | grep -q "Example.*Valid TypeScript Syntax"; then
  echo -e "${GREEN}✓${NC} Includes code examples"
else
  echo -e "${RED}✗${NC} Missing code examples"
  exit 1
fi

echo ""

#######################################
# Test 3: Dependency Error Refinement
#######################################
echo "Test 3: Dependency Error Refinement"

SESSION_3=$(state_create_session "workflow.md" "/project" "Test Dependency Error")
state_update "$SESSION_3" "agent.status" '"failed"'
state_update "$SESSION_3" "agent.error" '"ModuleNotFoundError: No module named foo"'
state_update "$SESSION_3" "retries.count" "1"

REFINED_3=$(prompt_refine "$SESSION_3" "Add the feature.")

if echo "$REFINED_3" | grep -q "dependency_error"; then
  echo -e "${GREEN}✓${NC} Detected dependency error"
else
  echo -e "${RED}✗${NC} Failed to detect dependency error"
  exit 1
fi

if echo "$REFINED_3" | grep -q "Verify imports exist"; then
  echo -e "${GREEN}✓${NC} Includes dependency guidance"
else
  echo -e "${RED}✗${NC} Missing dependency guidance"
  exit 1
fi

if echo "$REFINED_3" | grep -q "package.json"; then
  echo -e "${GREEN}✓${NC} References package.json"
else
  echo -e "${RED}✗${NC} Missing package.json reference"
  exit 1
fi

echo ""

#######################################
# Test 4: Console Error Refinement
#######################################
echo "Test 4: Console Error Refinement"

SESSION_4=$(state_create_session "workflow.md" "/project" "Test Console Errors")
state_update "$SESSION_4" "agent.status" '"completed"'
state_update "$SESSION_4" "validation.status" '"failed"'
state_update "$SESSION_4" "validation.playwright.console_errors" "3"
state_update "$SESSION_4" "retries.count" "1"

REFINED_4=$(prompt_refine "$SESSION_4" "Implement the form.")

if echo "$REFINED_4" | grep -q "console_errors"; then
  echo -e "${GREEN}✓${NC} Detected console errors"
else
  echo -e "${RED}✗${NC} Failed to detect console errors"
  exit 1
fi

if echo "$REFINED_4" | grep -q "Add error handling"; then
  echo -e "${GREEN}✓${NC} Includes error handling guidance"
else
  echo -e "${RED}✗${NC} Missing error handling guidance"
  exit 1
fi

if echo "$REFINED_4" | grep -q "try-catch"; then
  echo -e "${GREEN}✓${NC} Includes try-catch example"
else
  echo -e "${RED}✗${NC} Missing try-catch example"
  exit 1
fi

echo ""

#######################################
# Test 5: Timeout Refinement
#######################################
echo "Test 5: Timeout Refinement"

SESSION_5=$(state_create_session "workflow.md" "/project" "Test Timeout")
state_update "$SESSION_5" "agent.status" '"failed"'
state_update "$SESSION_5" "agent.error" '"Task timed out after 300 seconds"'
state_update "$SESSION_5" "retries.count" "1"

REFINED_5=$(prompt_refine "$SESSION_5" "Refactor the entire codebase.")

if echo "$REFINED_5" | grep -q "timeout"; then
  echo -e "${GREEN}✓${NC} Detected timeout"
else
  echo -e "${RED}✗${NC} Failed to detect timeout"
  exit 1
fi

if echo "$REFINED_5" | grep -q "Break into smaller steps"; then
  echo -e "${GREEN}✓${NC} Includes task breakdown guidance"
else
  echo -e "${RED}✗${NC} Missing task breakdown guidance"
  exit 1
fi

echo ""

#######################################
# Test 6: Permission Error Refinement
#######################################
echo "Test 6: Permission Error Refinement"

SESSION_6=$(state_create_session "workflow.md" "/project" "Test Permission Error")
state_update "$SESSION_6" "agent.status" '"failed"'
state_update "$SESSION_6" "agent.error" '"Permission denied: /etc/config"'
state_update "$SESSION_6" "retries.count" "1"

REFINED_6=$(prompt_refine "$SESSION_6" "Update configuration.")

if echo "$REFINED_6" | grep -q "permission_error"; then
  echo -e "${GREEN}✓${NC} Detected permission error"
else
  echo -e "${RED}✗${NC} Failed to detect permission error"
  exit 1
fi

if echo "$REFINED_6" | grep -q "Check write permissions"; then
  echo -e "${GREEN}✓${NC} Includes permission guidance"
else
  echo -e "${RED}✗${NC} Missing permission guidance"
  exit 1
fi

echo ""

#######################################
# Test 7: Network Error Refinement
#######################################
echo "Test 7: Network Error Refinement"

SESSION_7=$(state_create_session "workflow.md" "/project" "Test Network Errors")
state_update "$SESSION_7" "agent.status" '"completed"'
state_update "$SESSION_7" "validation.status" '"failed"'
state_update "$SESSION_7" "validation.playwright.network_errors" "2"
state_update "$SESSION_7" "retries.count" "1"

REFINED_7=$(prompt_refine "$SESSION_7" "Add API integration.")

if echo "$REFINED_7" | grep -q "network_errors"; then
  echo -e "${GREEN}✓${NC} Detected network errors"
else
  echo -e "${RED}✗${NC} Failed to detect network errors"
  exit 1
fi

if echo "$REFINED_7" | grep -q "Verify API endpoints"; then
  echo -e "${GREEN}✓${NC} Includes API guidance"
else
  echo -e "${RED}✗${NC} Missing API guidance"
  exit 1
fi

echo ""

#######################################
# Test 8: UI Issues Refinement
#######################################
echo "Test 8: UI Issues Refinement"

SESSION_8=$(state_create_session "workflow.md" "/project" "Test UI Issues")
state_update "$SESSION_8" "agent.status" '"completed"'
state_update "$SESSION_8" "validation.status" '"failed"'
state_update "$SESSION_8" "validation.vision_api.issues_found" '["Missing submit button"]'
state_update "$SESSION_8" "retries.count" "1"

REFINED_8=$(prompt_refine "$SESSION_8" "Build the form.")

if echo "$REFINED_8" | grep -q "ui_issues"; then
  echo -e "${GREEN}✓${NC} Detected UI issues"
else
  echo -e "${RED}✗${NC} Failed to detect UI issues"
  exit 1
fi

if echo "$REFINED_8" | grep -q "Include all UI elements"; then
  echo -e "${GREEN}✓${NC} Includes UI guidance"
else
  echo -e "${RED}✗${NC} Missing UI guidance"
  exit 1
fi

echo ""

#######################################
# Test 9: Save Refined Prompt
#######################################
echo "Test 9: Save Refined Prompt"

REFINED_PROMPT="Test refined prompt content"
SAVED_FILE=$(prompt_save "$SESSION_1" "$REFINED_PROMPT")

if [ -f "$SAVED_FILE" ]; then
  echo -e "${GREEN}✓${NC} Refined prompt saved: $SAVED_FILE"
else
  echo -e "${RED}✗${NC} Failed to save refined prompt"
  exit 1
fi

SAVED_CONTENT=$(cat "$SAVED_FILE")
if [ "$SAVED_CONTENT" == "$REFINED_PROMPT" ]; then
  echo -e "${GREEN}✓${NC} Saved content matches"
else
  echo -e "${RED}✗${NC} Saved content doesn't match"
  exit 1
fi

# Check that state was updated
PROMPT_FILE=$(state_get "$SESSION_1" "prompt.refined_file")
if [ "$PROMPT_FILE" == "$SAVED_FILE" ]; then
  echo -e "${GREEN}✓${NC} State updated with prompt file path"
else
  echo -e "${RED}✗${NC} State not updated correctly"
  exit 1
fi

echo ""

#######################################
# Test 10: Prompt Diff
#######################################
echo "Test 10: Prompt Diff"

ORIGINAL="Original prompt text here."
REFINED_LONG="Original prompt text here.

Additional guidance.
More guidance.
Even more guidance.
Checklist items."

DIFF_OUTPUT=$(prompt_diff "$ORIGINAL" "$REFINED_LONG")

if echo "$DIFF_OUTPUT" | grep -q "Prompt Refinement Summary"; then
  echo -e "${GREEN}✓${NC} Diff includes summary header"
else
  echo -e "${RED}✗${NC} Missing summary header"
  exit 1
fi

if echo "$DIFF_OUTPUT" | grep -q "Added:"; then
  echo -e "${GREEN}✓${NC} Diff shows added lines"
else
  echo -e "${RED}✗${NC} Missing added lines count"
  exit 1
fi

if echo "$DIFF_OUTPUT" | grep -q "Additions include:"; then
  echo -e "${GREEN}✓${NC} Diff lists additions"
else
  echo -e "${RED}✗${NC} Missing additions list"
  exit 1
fi

echo ""

#######################################
# Test 11: Get Stats
#######################################
echo "Test 11: Get Refinement Stats"

STATS=$(prompt_get_stats "$SESSION_1")

if echo "$STATS" | jq -e '.session_id' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Stats include session_id"
else
  echo -e "${RED}✗${NC} Stats missing session_id"
  exit 1
fi

RETRY_COUNT_STAT=$(echo "$STATS" | jq -r '.retry_count')
if [ "$RETRY_COUNT_STAT" -ge 0 ]; then
  echo -e "${GREEN}✓${NC} Stats include retry_count: $RETRY_COUNT_STAT"
else
  echo -e "${RED}✗${NC} Stats missing retry_count"
  exit 1
fi

FAILURE_TYPE_STAT=$(echo "$STATS" | jq -r '.failure_type')
if [ -n "$FAILURE_TYPE_STAT" ] && [ "$FAILURE_TYPE_STAT" != "null" ]; then
  echo -e "${GREEN}✓${NC} Stats include failure_type: $FAILURE_TYPE_STAT"
else
  echo -e "${RED}✗${NC} Stats missing failure_type"
  exit 1
fi

echo ""

#######################################
# Test 12: Multiple Retry Refinement
#######################################
echo "Test 12: Multiple Retry Refinement (Retry 2)"

# Create session with retry count 2
SESSION_9=$(state_create_session "workflow.md" "/project" "Test Multiple Retries")
state_update "$SESSION_9" "agent.status" '"failed"'
state_update "$SESSION_9" "agent.error" '"File not found"'
state_update "$SESSION_9" "retries.count" "2"

REFINED_9=$(prompt_refine "$SESSION_9" "Fix the bug.")

if echo "$REFINED_9" | grep -q "RETRY ATTEMPT 2"; then
  echo -e "${GREEN}✓${NC} Shows correct retry number (2)"
else
  echo -e "${RED}✗${NC} Wrong retry number"
  exit 1
fi

echo ""

#######################################
# Test 13: Refinement with Complex Original Prompt
#######################################
echo "Test 13: Refinement with Complex Original Prompt"

COMPLEX_PROMPT="## Task: Implement Authentication

Please implement the following:

1. Create login form
2. Add validation
3. Connect to API
4. Handle errors

Requirements:
- Use TypeScript
- Follow existing patterns
- Add tests"

REFINED_COMPLEX=$(prompt_refine "$SESSION_1" "$COMPLEX_PROMPT")

if echo "$REFINED_COMPLEX" | grep -q "## Task: Implement Authentication"; then
  echo -e "${GREEN}✓${NC} Preserves original prompt structure"
else
  echo -e "${RED}✗${NC} Lost original prompt structure"
  exit 1
fi

if echo "$REFINED_COMPLEX" | grep -q "1. Create login form"; then
  echo -e "${GREEN}✓${NC} Preserves original requirements"
else
  echo -e "${RED}✗${NC} Lost original requirements"
  exit 1
fi

echo ""

#######################################
# Test 14: Refinement Length Check
#######################################
echo "Test 14: Refinement Length Check"

SHORT_PROMPT="Fix bug."
REFINED_SHORT=$(prompt_refine "$SESSION_1" "$SHORT_PROMPT")

ORIGINAL_LENGTH=$(echo "$SHORT_PROMPT" | wc -c)
REFINED_LENGTH=$(echo "$REFINED_SHORT" | wc -c)

if [ "$REFINED_LENGTH" -gt "$((ORIGINAL_LENGTH * 3))" ]; then
  echo -e "${GREEN}✓${NC} Refined prompt is significantly longer (${REFINED_LENGTH} vs ${ORIGINAL_LENGTH} chars)"
else
  echo -e "${YELLOW}⚠${NC}  Refined prompt may not have enough guidance (${REFINED_LENGTH} vs ${ORIGINAL_LENGTH} chars)"
fi

echo ""

echo "╔════════════════════════════════════════╗"
echo "║  All Tests Passed!                     ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}✓ Prompt Refiner is working correctly${NC}"
echo ""
