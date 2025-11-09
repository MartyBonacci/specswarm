#!/bin/bash
#
# Test Script for Vision API
# Validates screenshot capture, analysis, and UI validation
#
# NOTE: Tests use mock implementations
# Real implementation requires Playwright and Claude Vision API
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
source "$SCRIPT_DIR/vision-api.sh"

echo "╔════════════════════════════════════════╗"
echo "║  Vision API Test Suite                 ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "NOTE: Using mock implementations for Phase 1a"
echo ""

#######################################
# Test 1: Capture Screenshot
#######################################
echo "Test 1: Capture Screenshot"

SESSION_1=$(state_create_session "workflow.md" "/project" "Test Vision")

SCREENSHOT=$(vision_capture_screenshot "$SESSION_1" "http://localhost:3000")

if [ -f "$SCREENSHOT" ]; then
  echo -e "${GREEN}✓${NC} Screenshot captured: $SCREENSHOT"
else
  echo -e "${RED}✗${NC} Screenshot not captured"
  exit 1
fi

if echo "$SCREENSHOT" | grep -q "$SESSION_1"; then
  echo -e "${GREEN}✓${NC} Screenshot filename includes session ID"
else
  echo -e "${RED}✗${NC} Screenshot filename doesn't include session ID"
  exit 1
fi

echo ""

#######################################
# Test 2: Analyze Screenshot (Pass)
#######################################
echo "Test 2: Analyze Screenshot (Should Pass)"

REQUIREMENTS="UI should have a login form with email and password fields"
ANALYSIS=$(vision_analyze "$SCREENSHOT" "$REQUIREMENTS")

if echo "$ANALYSIS" | jq -e '.summary' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Analysis includes summary"
else
  echo -e "${RED}✗${NC} Analysis missing summary"
  exit 1
fi

if echo "$ANALYSIS" | jq -e '.score' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Analysis includes score"
else
  echo -e "${RED}✗${NC} Analysis missing score"
  exit 1
fi

if echo "$ANALYSIS" | jq -e '.issues_found' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Analysis includes issues_found"
else
  echo -e "${RED}✗${NC} Analysis missing issues_found"
  exit 1
fi

SCORE=$(echo "$ANALYSIS" | jq -r '.score')
if [ "$SCORE" -ge 90 ]; then
  echo -e "${GREEN}✓${NC} Score indicates passing: $SCORE"
else
  echo -e "${YELLOW}⚠${NC}  Score below threshold: $SCORE (expected >=90 for simple requirements)"
fi

echo ""

#######################################
# Test 3: Analyze Screenshot (Fail - Missing Element)
#######################################
echo "Test 3: Analyze Screenshot (Should Fail - Missing Element)"

REQUIREMENTS_FAIL="UI must have a submit button"
ANALYSIS_FAIL=$(vision_analyze "$SCREENSHOT" "$REQUIREMENTS_FAIL")

SCORE_FAIL=$(echo "$ANALYSIS_FAIL" | jq -r '.score')
if [ "$SCORE_FAIL" -lt 90 ]; then
  echo -e "${GREEN}✓${NC} Score indicates failure: $SCORE_FAIL"
else
  echo -e "${RED}✗${NC} Score should be <90 for missing element: $SCORE_FAIL"
  exit 1
fi

ISSUES=$(echo "$ANALYSIS_FAIL" | jq -r '.issues_found | length')
if [ "$ISSUES" -gt 0 ]; then
  echo -e "${GREEN}✓${NC} Issues detected: $ISSUES"
else
  echo -e "${RED}✗${NC} No issues detected when element is missing"
  exit 1
fi

ISSUE_TEXT=$(echo "$ANALYSIS_FAIL" | jq -r '.issues_found[0]')
if echo "$ISSUE_TEXT" | grep -qi "submit button"; then
  echo -e "${GREEN}✓${NC} Issue describes missing submit button"
else
  echo -e "${RED}✗${NC} Issue doesn't describe problem: $ISSUE_TEXT"
  exit 1
fi

echo ""

#######################################
# Test 4: Complete Vision Validation (Pass)
#######################################
echo "Test 4: Complete Vision Validation (Pass)"

SESSION_2=$(state_create_session "workflow.md" "/project" "Test Vision Pass")

REQUIREMENTS_PASS="Basic UI elements"
RESULT=$(vision_validate "$SESSION_2" "http://localhost:3000" "$REQUIREMENTS_PASS")

if echo "$RESULT" | jq -e '.status' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Validation result includes status"
else
  echo -e "${RED}✗${NC} Validation result missing status"
  exit 1
fi

STATUS=$(echo "$RESULT" | jq -r '.status')
if [ "$STATUS" == "passed" ]; then
  echo -e "${GREEN}✓${NC} Validation status: passed"
else
  echo -e "${RED}✗${NC} Validation should pass for basic requirements: $STATUS"
  exit 1
fi

# Check state was updated
STATE_STATUS=$(state_get "$SESSION_2" "validation.status")
if [ "$STATE_STATUS" == "passed" ]; then
  echo -e "${GREEN}✓${NC} State updated with validation status"
else
  echo -e "${RED}✗${NC} State not updated correctly"
  exit 1
fi

STATE_SCORE=$(state_get "$SESSION_2" "validation.vision_api.score")
if [ "$STATE_SCORE" -ge 90 ]; then
  echo -e "${GREEN}✓${NC} State includes score: $STATE_SCORE"
else
  echo -e "${RED}✗${NC} Score in state is too low: $STATE_SCORE"
  exit 1
fi

echo ""

#######################################
# Test 5: Complete Vision Validation (Fail)
#######################################
echo "Test 5: Complete Vision Validation (Fail)"

SESSION_3=$(state_create_session "workflow.md" "/project" "Test Vision Fail")

REQUIREMENTS_FAIL_2="Must have submit button"
RESULT_FAIL=$(vision_validate "$SESSION_3" "http://localhost:3000" "$REQUIREMENTS_FAIL_2")

STATUS_FAIL=$(echo "$RESULT_FAIL" | jq -r '.status')
if [ "$STATUS_FAIL" == "failed" ]; then
  echo -e "${GREEN}✓${NC} Validation status: failed"
else
  echo -e "${RED}✗${NC} Validation should fail when element missing: $STATUS_FAIL"
  exit 1
fi

# Check state
STATE_STATUS_FAIL=$(state_get "$SESSION_3" "validation.status")
if [ "$STATE_STATUS_FAIL" == "failed" ]; then
  echo -e "${GREEN}✓${NC} State updated with failed status"
else
  echo -e "${RED}✗${NC} State should show failed"
  exit 1
fi

STATE_ISSUES=$(state_get "$SESSION_3" "validation.vision_api.issues_found")
if echo "$STATE_ISSUES" | jq -e '.[0]' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} State includes issues found"
else
  echo -e "${RED}✗${NC} State missing issues"
  exit 1
fi

echo ""

#######################################
# Test 6: Check Specific Elements
#######################################
echo "Test 6: Check Specific Elements"

ELEMENTS='["login button", "email field", "password field"]'
ELEMENT_RESULTS=$(vision_check_elements "$SCREENSHOT" "$ELEMENTS")

if echo "$ELEMENT_RESULTS" | jq -e '.[0].element' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Element check results include element names"
else
  echo -e "${RED}✗${NC} Element results missing element names"
  exit 1
fi

if echo "$ELEMENT_RESULTS" | jq -e '.[0].found' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Element check results include found status"
else
  echo -e "${RED}✗${NC} Element results missing found status"
  exit 1
fi

ELEMENT_COUNT=$(echo "$ELEMENT_RESULTS" | jq 'length')
if [ "$ELEMENT_COUNT" -eq 3 ]; then
  echo -e "${GREEN}✓${NC} Checked all 3 elements"
else
  echo -e "${RED}✗${NC} Expected 3 elements, got: $ELEMENT_COUNT"
  exit 1
fi

echo ""

#######################################
# Test 7: Validate Design Spec
#######################################
echo "Test 7: Validate Against Design Spec"

# Create mock design spec file
DESIGN_SPEC_FILE="/tmp/design-spec-test.md"
cat > "$DESIGN_SPEC_FILE" <<'EOF'
# UI Design Specification

## Required Elements
- Login form
- Email input field
- Password input field
- Submit button

## Styling
- Clean, modern design
- Responsive layout
EOF

DESIGN_RESULT=$(vision_validate_design "$SCREENSHOT" "$DESIGN_SPEC_FILE")

if echo "$DESIGN_RESULT" | jq -e '.summary' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Design validation includes summary"
else
  echo -e "${RED}✗${NC} Design validation missing summary"
  exit 1
fi

rm -f "$DESIGN_SPEC_FILE"
echo ""

#######################################
# Test 8: Compare Screenshots
#######################################
echo "Test 8: Compare Screenshots (Before/After)"

SCREENSHOT_BEFORE="$SCREENSHOT"
SCREENSHOT_AFTER=$(vision_capture_screenshot "$SESSION_1" "http://localhost:3000/updated")

COMPARISON=$(vision_compare "$SCREENSHOT_BEFORE" "$SCREENSHOT_AFTER")

if echo "$COMPARISON" | jq -e '.similarity_score' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Comparison includes similarity score"
else
  echo -e "${RED}✗${NC} Comparison missing similarity score"
  exit 1
fi

if echo "$COMPARISON" | jq 'has("differences_found")' | grep -q "true"; then
  echo -e "${GREEN}✓${NC} Comparison includes differences_found"
else
  echo -e "${RED}✗${NC} Comparison missing differences_found"
  exit 1
fi

echo ""

#######################################
# Test 9: Accessibility Check
#######################################
echo "Test 9: Accessibility Check"

ACCESSIBILITY=$(vision_check_accessibility "$SCREENSHOT")

if echo "$ACCESSIBILITY" | jq -e '.score' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Accessibility check includes score"
else
  echo -e "${RED}✗${NC} Accessibility check missing score"
  exit 1
fi

if echo "$ACCESSIBILITY" | jq -e '.checks' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Accessibility check includes checks"
else
  echo -e "${RED}✗${NC} Accessibility check missing checks"
  exit 1
fi

A11Y_SCORE=$(echo "$ACCESSIBILITY" | jq -r '.score')
if [ "$A11Y_SCORE" -ge 80 ]; then
  echo -e "${GREEN}✓${NC} Accessibility score acceptable: $A11Y_SCORE"
else
  echo -e "${YELLOW}⚠${NC}  Accessibility score low: $A11Y_SCORE"
fi

echo ""

#######################################
# Test 10: Get Validation Results
#######################################
echo "Test 10: Get Validation Results"

RESULTS=$(vision_get_results "$SESSION_2")

if echo "$RESULTS" | jq -e '.status' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Results include status"
else
  echo -e "${RED}✗${NC} Results missing status"
  exit 1
fi

if echo "$RESULTS" | jq -e '.score' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Results include score"
else
  echo -e "${RED}✗${NC} Results missing score"
  exit 1
fi

if echo "$RESULTS" | jq -e '.screenshot' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Results include screenshot path"
else
  echo -e "${RED}✗${NC} Results missing screenshot path"
  exit 1
fi

echo ""

#######################################
# Test 11: Generate Report
#######################################
echo "Test 11: Generate Validation Report"

REPORT=$(vision_report "$SESSION_2")

if echo "$REPORT" | grep -q "Vision API Validation Report"; then
  echo -e "${GREEN}✓${NC} Report includes title"
else
  echo -e "${RED}✗${NC} Report missing title"
  exit 1
fi

if echo "$REPORT" | grep -q "Session: $SESSION_2"; then
  echo -e "${GREEN}✓${NC} Report includes session ID"
else
  echo -e "${RED}✗${NC} Report missing session ID"
  exit 1
fi

if echo "$REPORT" | grep -q "Status:"; then
  echo -e "${GREEN}✓${NC} Report includes status"
else
  echo -e "${RED}✗${NC} Report missing status"
  exit 1
fi

echo ""

#######################################
# Test 12: Integration with Decision Maker
#######################################
echo "Test 12: Integration with Decision Maker"

# Source decision maker
source "$SCRIPT_DIR/decision-maker.sh"

# Session with UI issues should be detected
SESSION_4=$(state_create_session "workflow.md" "/project" "Test UI Integration")
state_update "$SESSION_4" "agent.status" '"completed"'
state_update "$SESSION_4" "validation.status" '"failed"'
state_update "$SESSION_4" "validation.vision_api.issues_found" '["Missing submit button", "Header not styled"]'
state_update "$SESSION_4" "validation.vision_api.score" "70"

# Decision should be retry
DECISION=$(decision_make "$SESSION_4")
if [ "$DECISION" == "retry" ]; then
  echo -e "${GREEN}✓${NC} Decision Maker returns retry for UI issues"
else
  echo -e "${RED}✗${NC} Decision should be retry: $DECISION"
  exit 1
fi

# Analyze failure should detect UI issues
ANALYSIS_DM=$(decision_analyze_failure "$SESSION_4")
FAILURE_TYPE=$(echo "$ANALYSIS_DM" | jq -r '.failure_type')
if [ "$FAILURE_TYPE" == "ui_issues" ]; then
  echo -e "${GREEN}✓${NC} Decision Maker detects ui_issues failure type"
else
  echo -e "${RED}✗${NC} Failure type should be ui_issues: $FAILURE_TYPE"
  exit 1
fi

echo ""

#######################################
# Test 13: Screenshot Cleanup
#######################################
echo "Test 13: Screenshot Cleanup"

# Create old screenshot
OLD_SCREENSHOT="$VISION_SCREENSHOTS_DIR/old-screenshot.png"
touch "$OLD_SCREENSHOT"
# Make it appear old (this is a mock - real test would set actual old date)
# For this test, we'll just verify the cleanup function runs

vision_cleanup 30 >/dev/null 2>&1

echo -e "${GREEN}✓${NC} Cleanup function runs without error"

echo ""

#######################################
# Test 14: Mock Implementation Notice
#######################################
echo "Test 14: Mock Implementation Verification"

# Verify this is clearly a mock
if grep -q "MOCK IMPLEMENTATION" "$SCRIPT_DIR/vision-api.sh"; then
  echo -e "${GREEN}✓${NC} Code clearly marked as MOCK"
else
  echo -e "${YELLOW}⚠${NC}  Code should be marked as MOCK"
fi

if grep -q "playwright" "$SCRIPT_DIR/vision-api.sh"; then
  echo -e "${GREEN}✓${NC} Code includes Playwright integration comments"
else
  echo -e "${YELLOW}⚠${NC}  Code should document Playwright integration"
fi

if grep -q "api.anthropic.com" "$SCRIPT_DIR/vision-api.sh"; then
  echo -e "${GREEN}✓${NC} Code includes Claude API integration comments"
else
  echo -e "${YELLOW}⚠${NC}  Code should document Claude API integration"
fi

echo ""

echo "╔════════════════════════════════════════╗"
echo "║  All Tests Passed!                     ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}✓ Vision API structure is working correctly${NC}"
echo ""
echo -e "${YELLOW}NOTE: This is a mock implementation for Phase 1a${NC}"
echo -e "${YELLOW}Production requires:${NC}"
echo "  - Playwright for screenshot capture"
echo "  - Claude API with vision capabilities"
echo "  - Integration points are clearly documented in code"
echo ""
