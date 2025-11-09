#!/bin/bash
#
# Test Script for Metrics Tracker
# Validates metrics collection and analysis
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/state-manager.sh"
source "$SCRIPT_DIR/metrics-tracker.sh"

echo "╔════════════════════════════════════════╗"
echo "║  Metrics Tracker Test Suite            ║"
echo "╚════════════════════════════════════════╝"
echo ""

#######################################
# Test 1: Collect Metrics from Session
#######################################
echo "Test 1: Collect Metrics from Session"

# Create test session
SESSION_1=$(state_create_session "workflow.md" "/project" "Test Metrics")
state_update "$SESSION_1" "agent.status" '"completed"'
state_update "$SESSION_1" "validation.status" '"passed"'
state_complete "$SESSION_1" "success"

METRICS=$(metrics_collect "$SESSION_1")

if echo "$METRICS" | jq -e '.session_id' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Metrics include session_id"
else
  echo -e "${RED}✗${NC} Metrics missing session_id"
  exit 1
fi

if echo "$METRICS" | jq -e '.success' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Metrics include success flag"
else
  echo -e "${RED}✗${NC} Metrics missing success flag"
  exit 1
fi

SUCCESS=$(echo "$METRICS" | jq -r '.success')
if [ "$SUCCESS" == "true" ]; then
  echo -e "${GREEN}✓${NC} Success flag is true"
else
  echo -e "${RED}✗${NC} Success flag should be true: $SUCCESS"
  exit 1
fi

echo ""

#######################################
# Test 2: Aggregate Metrics
#######################################
echo "Test 2: Aggregate Metrics"

# Create a few more test sessions
SESSION_2=$(state_create_session "workflow.md" "/project" "Test 2")
state_update "$SESSION_2" "agent.status" '"failed"'
state_complete "$SESSION_2" "failure"

SESSION_3=$(state_create_session "workflow.md" "/project" "Test 3")
state_update "$SESSION_3" "retries.count" "2"
state_complete "$SESSION_3" "success"

AGGREGATED=$(metrics_aggregate)

if echo "$AGGREGATED" | jq -e '.total_sessions' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Aggregated metrics include total_sessions"
else
  echo -e "${RED}✗${NC} Aggregated metrics missing total_sessions"
  exit 1
fi

TOTAL=$(echo "$AGGREGATED" | jq -r '.total_sessions')
if [ "$TOTAL" -ge 3 ]; then
  echo -e "${GREEN}✓${NC} Total sessions count: $TOTAL"
else
  echo -e "${RED}✗${NC} Expected at least 3 sessions: $TOTAL"
  exit 1
fi

if echo "$AGGREGATED" | jq -e '.success_rate' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Includes success_rate"
else
  echo -e "${RED}✗${NC} Missing success_rate"
  exit 1
fi

echo ""

#######################################
# Test 3: Analyze Failures
#######################################
echo "Test 3: Analyze Failures"

# Create session with specific failure
SESSION_4=$(state_create_session "workflow.md" "/project" "Test Failure")
state_update "$SESSION_4" "agent.status" '"failed"'
state_update "$SESSION_4" "agent.error" '"File not found: src/main.ts"'
state_complete "$SESSION_4" "failure"

FAILURE_ANALYSIS=$(metrics_analyze_failures)

if echo "$FAILURE_ANALYSIS" | jq -e '.total_failures' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Analysis includes total_failures"
else
  echo -e "${RED}✗${NC} Analysis missing total_failures"
  exit 1
fi

if echo "$FAILURE_ANALYSIS" | jq -e '.by_type' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Analysis includes by_type breakdown"
else
  echo -e "${RED}✗${NC} Analysis missing by_type"
  exit 1
fi

if echo "$FAILURE_ANALYSIS" | jq -e '.by_type.file_not_found' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Analysis tracks file_not_found"
else
  echo -e "${RED}✗${NC} Analysis missing file_not_found tracking"
  exit 1
fi

echo ""

#######################################
# Test 4: Retry Effectiveness
#######################################
echo "Test 4: Retry Effectiveness"

RETRY_METRICS=$(metrics_retry_effectiveness)

if echo "$RETRY_METRICS" | jq -e '.total_with_retries' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Retry metrics include total_with_retries"
else
  echo -e "${RED}✗${NC} Retry metrics missing total_with_retries"
  exit 1
fi

if echo "$RETRY_METRICS" | jq -e '.effectiveness_rate' >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Retry metrics include effectiveness_rate"
else
  echo -e "${RED}✗${NC} Retry metrics missing effectiveness_rate"
  exit 1
fi

TOTAL_RETRIES=$(echo "$RETRY_METRICS" | jq -r '.total_with_retries')
if [ "$TOTAL_RETRIES" -ge 1 ]; then
  echo -e "${GREEN}✓${NC} Found sessions with retries: $TOTAL_RETRIES"
else
  echo -e "${RED}✗${NC} Expected at least 1 session with retries"
  exit 1
fi

echo ""

#######################################
# Test 5: Generate Recommendations
#######################################
echo "Test 5: Generate Recommendations"

RECOMMENDATIONS=$(metrics_recommendations)

if echo "$RECOMMENDATIONS" | jq -e 'type' | grep -q "array"; then
  echo -e "${GREEN}✓${NC} Recommendations is an array"
else
  echo -e "${RED}✗${NC} Recommendations should be an array"
  exit 1
fi

# Check if recommendations have required fields
REC_COUNT=$(echo "$RECOMMENDATIONS" | jq 'length')
echo -e "${GREEN}✓${NC} Generated $REC_COUNT recommendations"

if [ "$REC_COUNT" -gt 0 ]; then
  if echo "$RECOMMENDATIONS" | jq -e '.[0].priority' >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Recommendations include priority"
  else
    echo -e "${RED}✗${NC} Recommendations missing priority"
    exit 1
  fi

  if echo "$RECOMMENDATIONS" | jq -e '.[0].message' >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Recommendations include message"
  else
    echo -e "${RED}✗${NC} Recommendations missing message"
    exit 1
  fi
fi

echo ""

#######################################
# Test 6: Generate Report
#######################################
echo "Test 6: Generate Report"

REPORT=$(metrics_report)

if echo "$REPORT" | grep -q "Orchestrator Metrics Report"; then
  echo -e "${GREEN}✓${NC} Report includes title"
else
  echo -e "${RED}✗${NC} Report missing title"
  exit 1
fi

if echo "$REPORT" | grep -q "Total Sessions:"; then
  echo -e "${GREEN}✓${NC} Report includes total sessions"
else
  echo -e "${RED}✗${NC} Report missing total sessions"
  exit 1
fi

if echo "$REPORT" | grep -q "Success Rate:"; then
  echo -e "${GREEN}✓${NC} Report includes success rate"
else
  echo -e "${RED}✗${NC} Report missing success rate"
  exit 1
fi

if echo "$REPORT" | grep -q "Retry Effectiveness:"; then
  echo -e "${GREEN}✓${NC} Report includes retry effectiveness"
else
  echo -e "${RED}✗${NC} Report missing retry effectiveness"
  exit 1
fi

echo ""

#######################################
# Test 7: Export Metrics
#######################################
echo "Test 7: Export Metrics"

EXPORT_FILE="/tmp/metrics-export-test.json"
metrics_export "$EXPORT_FILE" >/dev/null

if [ -f "$EXPORT_FILE" ]; then
  echo -e "${GREEN}✓${NC} Metrics exported to file"
else
  echo -e "${RED}✗${NC} Export file not created"
  exit 1
fi

if jq empty "$EXPORT_FILE" 2>/dev/null; then
  echo -e "${GREEN}✓${NC} Export file is valid JSON"
else
  echo -e "${RED}✗${NC} Export file is not valid JSON"
  exit 1
fi

if jq -e '.aggregated' "$EXPORT_FILE" >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Export includes aggregated metrics"
else
  echo -e "${RED}✗${NC} Export missing aggregated metrics"
  exit 1
fi

if jq -e '.failure_analysis' "$EXPORT_FILE" >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Export includes failure analysis"
else
  echo -e "${RED}✗${NC} Export missing failure analysis"
  exit 1
fi

rm -f "$EXPORT_FILE"
echo ""

#######################################
# Test 8: Metrics for Successful Session with Retries
#######################################
echo "Test 8: Metrics for Successful Session with Retries"

# Create session that succeeded after retries
SESSION_5=$(state_create_session "workflow.md" "/project" "Test Retry Success")
state_update "$SESSION_5" "retries.count" "2"
state_complete "$SESSION_5" "success"

METRICS_5=$(metrics_collect "$SESSION_5")

RETRY_SUCCESS=$(echo "$METRICS_5" | jq -r '.retry_success')
if [ "$RETRY_SUCCESS" == "true" ]; then
  echo -e "${GREEN}✓${NC} Correctly identified as retry_success"
else
  echo -e "${RED}✗${NC} Should be marked as retry_success: $RETRY_SUCCESS"
  exit 1
fi

echo ""

#######################################
# Test 9: Metrics for Escalated Session
#######################################
echo "Test 9: Metrics for Escalated Session"

SESSION_6=$(state_create_session "workflow.md" "/project" "Test Escalated")
state_update "$SESSION_6" "retries.count" "3"
state_complete "$SESSION_6" "escalated"

METRICS_6=$(metrics_collect "$SESSION_6")

ESCALATED=$(echo "$METRICS_6" | jq -r '.escalated')
if [ "$ESCALATED" == "true" ]; then
  echo -e "${GREEN}✓${NC} Correctly identified as escalated"
else
  echo -e "${RED}✗${NC} Should be marked as escalated: $ESCALATED"
  exit 1
fi

echo ""

#######################################
# Test 10: Comprehensive Metrics
#######################################
echo "Test 10: Comprehensive Metrics Check"

FINAL_AGGREGATED=$(metrics_aggregate)

echo "Final Metrics:"
echo "$FINAL_AGGREGATED" | jq '.'

FINAL_TOTAL=$(echo "$FINAL_AGGREGATED" | jq -r '.total_sessions')
FINAL_SUCCESS=$(echo "$FINAL_AGGREGATED" | jq -r '.successful')
FINAL_ESCALATED=$(echo "$FINAL_AGGREGATED" | jq -r '.escalated')

if [ "$FINAL_TOTAL" -ge 6 ]; then
  echo -e "${GREEN}✓${NC} Total sessions: $FINAL_TOTAL"
else
  echo -e "${RED}✗${NC} Expected at least 6 sessions: $FINAL_TOTAL"
  exit 1
fi

if [ "$FINAL_SUCCESS" -ge 3 ]; then
  echo -e "${GREEN}✓${NC} Successful sessions: $FINAL_SUCCESS"
else
  echo -e "${RED}✗${NC} Expected at least 3 successful: $FINAL_SUCCESS"
  exit 1
fi

echo ""

echo "╔════════════════════════════════════════╗"
echo "║  All Tests Passed!                     ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}✓ Metrics Tracker is working correctly${NC}"
echo ""
