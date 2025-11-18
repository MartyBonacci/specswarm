#!/bin/bash
# Test script for natural language detection
# Usage: ./test-nl-detection.sh

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the dispatcher
source "${SCRIPT_DIR}/natural-language-dispatcher.sh"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
test_detection() {
  local input="$1"
  local expected_command="$2"
  local expected_min_confidence="$3"  # "high", "medium", "low", or "none"

  TESTS_RUN=$((TESTS_RUN + 1))

  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}Test #${TESTS_RUN}${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "Input: \"${input}\""

  # Detect workflow
  local result=$(detect_workflow "$input")
  local detected_command=$(echo "$result" | cut -d: -f1)
  local detected_confidence=$(echo "$result" | cut -d: -f2)
  local detected_score=$(echo "$result" | cut -d: -f3)

  echo -e "Expected: ${expected_command} (${expected_min_confidence}+ confidence)"
  echo -e "Detected: ${detected_command} (${detected_confidence} confidence, score: ${detected_score})"

  # Check if command matches
  if [ "$detected_command" = "$expected_command" ]; then
    # Check if confidence meets minimum
    case "$expected_min_confidence" in
      "high")
        if [ "$detected_confidence" = "high" ]; then
          echo -e "${GREEN}✓ PASS${NC}"
          TESTS_PASSED=$((TESTS_PASSED + 1))
        else
          echo -e "${RED}✗ FAIL: Expected high confidence, got ${detected_confidence}${NC}"
          TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
        ;;
      "medium")
        if [ "$detected_confidence" = "high" ] || [ "$detected_confidence" = "medium" ]; then
          echo -e "${GREEN}✓ PASS${NC}"
          TESTS_PASSED=$((TESTS_PASSED + 1))
        else
          echo -e "${RED}✗ FAIL: Expected medium+ confidence, got ${detected_confidence}${NC}"
          TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
        ;;
      "low")
        if [ "$detected_confidence" != "none" ]; then
          echo -e "${GREEN}✓ PASS${NC}"
          TESTS_PASSED=$((TESTS_PASSED + 1))
        else
          echo -e "${RED}✗ FAIL: Expected low+ confidence, got ${detected_confidence}${NC}"
          TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
        ;;
      "none")
        if [ "$detected_confidence" = "none" ]; then
          echo -e "${GREEN}✓ PASS${NC}"
          TESTS_PASSED=$((TESTS_PASSED + 1))
        else
          echo -e "${RED}✗ FAIL: Expected no detection, got ${detected_confidence}${NC}"
          TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
        ;;
    esac
  else
    echo -e "${RED}✗ FAIL: Expected ${expected_command}, got ${detected_command}${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# Print test header
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Natural Language Detection Test Suite${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# BUILD command tests
echo ""
echo -e "${YELLOW}=== BUILD Command Tests ===${NC}"
test_detection "Build user authentication with JWT" "build" "high"
test_detection "Create a payment processing system" "build" "high"
test_detection "Add dashboard analytics" "build" "high"
test_detection "Implement shopping cart functionality" "build" "high"
test_detection "I need a new feature for notifications" "build" "medium"
test_detection "develop an admin panel" "build" "high"

# FIX command tests
echo ""
echo -e "${YELLOW}=== FIX Command Tests ===${NC}"
test_detection "Fix the login button on mobile" "fix" "high"
test_detection "There's a bug in the checkout process" "fix" "high"
test_detection "Authentication doesn't work" "fix" "high"
test_detection "Getting an error when submitting the form" "fix" "high"
test_detection "Payment processing fails on Safari" "fix" "high"
test_detection "the search is broken" "fix" "high"

# SHIP command tests
echo ""
echo -e "${YELLOW}=== SHIP Command Tests ===${NC}"
test_detection "Ship this feature" "ship" "high"
test_detection "Deploy to production" "ship" "high"
test_detection "Merge to main" "ship" "high"
test_detection "I'm done with this" "ship" "high"
test_detection "ready to ship" "ship" "high"
test_detection "ship it" "ship" "high"

# UPGRADE command tests
echo ""
echo -e "${YELLOW}=== UPGRADE Command Tests ===${NC}"
test_detection "Upgrade to React 19" "upgrade" "high"
test_detection "Migrate from Redux to Zustand" "upgrade" "high"
test_detection "Update to the latest PostgreSQL" "upgrade" "high"
test_detection "Modernize the authentication system" "upgrade" "high"
test_detection "Switch to TypeScript 5.x" "upgrade" "medium"

# Edge case tests
echo ""
echo -e "${YELLOW}=== Edge Case Tests ===${NC}"
test_detection "Ship the bugfix" "ship" "high"  # Both "ship" and "bug" - ship should win
test_detection "help me with the app" "none" "none"  # Too vague - no clear match
test_detection "work on the dashboard" "none" "none"  # Ambiguous - what kind of work?

# Note: These cases are genuinely ambiguous and would trigger clarification in real use
# test_detection "Build fix for authentication" - Could be BUILD or FIX (both valid)
# test_detection "I need to fix the build" - Object is "build", but verb is "fix" (ambiguous)

# Print summary
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Test Summary${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Total Tests: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}✓ ALL TESTS PASSED!${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  exit 0
else
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${RED}✗ SOME TESTS FAILED${NC}"
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  exit 1
fi
