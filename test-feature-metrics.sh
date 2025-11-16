#!/bin/bash
# Test script for feature-metrics system

# Source the library
source plugins/speclabs/lib/feature-metrics-collector.sh

# Set project
export PROJECT_ROOT="/home/marty/code-projects/customcult2"

echo "================================================"
echo "Testing Feature Metrics Collection"
echo "================================================"
echo ""

# Test 1: Find features
echo "Test 1: Finding features in $PROJECT_ROOT"
features=$(fm_find_features "$PROJECT_ROOT")
count=$(echo "$features" | jq 'length')
echo "Found: $count features"
echo ""

# Test 2: Analyze Feature 015 specifically
feature_015_dir="/home/marty/code-projects/customcult2/features/015-add-comprehensive-testing-infrastructure-with-vitest-for-unit-component-tests-an"

echo "Test 2: Analyzing Feature 015"
echo "Directory: $feature_015_dir"
echo ""

echo "  Metadata:"
metadata=$(fm_get_feature_metadata "$feature_015_dir")
echo "$metadata" | jq .
echo ""

echo "  Tasks:"
tasks=$(fm_analyze_tasks "$feature_015_dir")
echo "$tasks" | jq .
echo ""

echo "  Tests:"
tests=$(fm_analyze_tests "$feature_015_dir")
echo "$tests" | jq .
echo ""

echo "  Git History:"
git_history=$(fm_analyze_git_history "$feature_015_dir")
echo "$git_history" | jq .
echo ""

# Test 3: Complete Feature Analysis
echo "Test 3: Complete Feature 015 Analysis"
complete=$(fm_analyze_feature "$feature_015_dir")
echo "$complete" | jq .
echo ""

# Test 4: Aggregates
echo "Test 4: Project Aggregates"
all_features=$(fm_analyze_all_features "$PROJECT_ROOT")
aggregates=$(fm_calculate_aggregates "$all_features")
echo "$aggregates" | jq .
echo ""

# Test 5: Sprint Filtering
echo "Test 5: Features in sprint-4"
sprint4=$(fm_filter_features "$all_features" "metadata.parent_branch" "sprint-4")
echo "Count: $(echo "$sprint4" | jq 'length')"
echo ""

echo "================================================"
echo "Tests Complete!"
echo "================================================"
