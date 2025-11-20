---
name: feature-metrics
description: 'Feature-level orchestration metrics and analytics. Analyzes completed features from actual project artifacts (spec.md, tasks.md) rather than orchestration sessions. Shows completion rates, test metrics, and git history. v2.8.0: Initial release with feature detection and comprehensive analytics.'
visibility: public
command_type: project
---

# Feature-Level Metrics Dashboard

```bash
#!/bin/bash

# Parse arguments
PROJECT_PATH=""
RECENT_COUNT=10
EXPORT_FILE=""
FEATURE_NUMBER=""
SPRINT_FILTER=""
SHOW_DETAILS=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --recent)
      RECENT_COUNT="$2"
      shift 2
      ;;
    --export)
      EXPORT_FILE="${2:-feature-metrics-$(date +%Y%m%d_%H%M%S).csv}"
      shift 2
      ;;
    --feature)
      FEATURE_NUMBER="$2"
      shift 2
      ;;
    --sprint)
      SPRINT_FILTER="$2"
      shift 2
      ;;
    --details)
      SHOW_DETAILS=true
      shift
      ;;
    --path)
      PROJECT_PATH="$2"
      shift 2
      ;;
    *)
      if [ -z "$PROJECT_PATH" ] && [ -d "$1" ]; then
        PROJECT_PATH="$1"
      fi
      shift
      ;;
  esac
done

# Default to current directory if no path specified
PROJECT_PATH="${PROJECT_PATH:-$(pwd)}"

# Source the feature metrics collector library
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$PLUGIN_ROOT/lib/feature-metrics-collector.sh"

# Set project root for library
export PROJECT_ROOT="$PROJECT_PATH"

echo "📊 SpecLabs Feature-Level Metrics Dashboard"
echo "============================================"
echo ""
echo "Project: $PROJECT_PATH"
echo ""

# Collect all feature data
echo "🔍 Scanning for features..."
features_json=$(fm_analyze_all_features "$PROJECT_PATH")

# Check if any features found
total_features=$(echo "$features_json" | jq 'length')

if [ "$total_features" -eq 0 ]; then
  echo ""
  echo "ℹ️  No features found in $PROJECT_PATH"
  echo ""
  echo "Features are detected by the presence of spec.md files."
  echo "Make sure you're in a project directory with SpecSwarm features."
  echo ""
  echo "Searched for:"
  echo "  - */spec.md"
  echo "  - features/*/spec.md"
  echo "  - .features/*/spec.md"
  echo ""
  exit 0
fi

echo "✅ Found $total_features features"
echo ""

# Calculate aggregates
aggregates=$(fm_calculate_aggregates "$features_json")

# Display based on requested view
if [ -n "$FEATURE_NUMBER" ]; then
  #==========================================================================
  # SINGLE FEATURE DETAILS
  #==========================================================================

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Feature $FEATURE_NUMBER Details"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Find the feature
  feature=$(echo "$features_json" | jq --arg num "$FEATURE_NUMBER" \
    '.[] | select(.metadata.feature_number == $num)')

  if [ -z "$feature" ] || [ "$feature" = "null" ]; then
    echo "❌ Feature $FEATURE_NUMBER not found"
    exit 1
  fi

  # Display metadata
  echo "📋 Metadata"
  echo "───────────"
  echo "$feature" | jq -r '"  Name: \(.metadata.feature_name)
  Status: \(.metadata.status)
  Parent Branch: \(.metadata.parent_branch)
  Created: \(.metadata.created_at)
  Completed: \(.metadata.completed_at // "N/A")
  Directory: \(.metadata.feature_dir)"'
  echo ""

  # Display task stats
  echo "✅ Tasks"
  echo "────────"
  echo "$feature" | jq -r '"  Total: \(.tasks.total)
  Completed: \(.tasks.completed) (\(.tasks.completion_rate)%)
  Failed: \(.tasks.failed)
  Pending: \(.tasks.pending)"'
  echo ""

  # Display test stats
  if [ "$(echo "$feature" | jq '.tests.total_tests')" -gt 0 ]; then
    echo "🧪 Tests"
    echo "────────"
    echo "$feature" | jq -r '"  Total: \(.tests.total_tests)
  Passing: \(.tests.passing_tests) (\(.tests.pass_rate)%)
  Failing: \(.tests.failing_tests)"'
    echo ""
  fi

  # Display git stats
  echo "🔀 Git History"
  echo "──────────────"
  echo "$feature" | jq -r '"  Branch: \(.git.branch)
  Commits: \(.git.commits)
  Merged: \(.git.merged)
  Merge Date: \(.git.merge_date // "N/A")"'
  echo ""

elif [ -n "$SPRINT_FILTER" ]; then
  #==========================================================================
  # SPRINT AGGREGATE VIEW
  #==========================================================================

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Sprint: $SPRINT_FILTER"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Filter features for this sprint
  sprint_features=$(fm_filter_features "$features_json" "metadata.parent_branch" "$SPRINT_FILTER")
  sprint_count=$(echo "$sprint_features" | jq 'length')

  if [ "$sprint_count" -eq 0 ]; then
    echo "ℹ️  No features found for sprint: $SPRINT_FILTER"
    exit 0
  fi

  # Calculate sprint aggregates
  sprint_aggregates=$(fm_calculate_aggregates "$sprint_features")

  echo "📊 Sprint Statistics"
  echo "────────────────────"
  echo "$sprint_aggregates" | jq -r '"  Total Features: \(.features.total)
  Completed: \(.features.completed)
  In Progress: \(.features.in_progress)

  Total Tasks: \(.tasks.total)
  Completed: \(.tasks.completed)
  Failed: \(.tasks.failed)
  Avg Completion Rate: \(.tasks.avg_completion_rate)%

  Total Tests: \(.tests.total)
  Passing: \(.tests.passing) (\(.tests.avg_pass_rate)%)
  Failing: \(.tests.failing)"'
  echo ""

  echo "📝 Features in $SPRINT_FILTER"
  echo "─────────────────────────────"
  echo "$sprint_features" | jq -r '.[] | "  [\(.metadata.feature_number)] \(.metadata.feature_name)
    Status: \(.metadata.status) | Tasks: \(.tasks.completed)/\(.tasks.total) | Tests: \(.tests.passing_tests)/\(.tests.total_tests)\n"'
  echo ""

else
  #==========================================================================
  # DASHBOARD SUMMARY VIEW
  #==========================================================================

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Overall Statistics"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  echo "📊 Features"
  echo "───────────"
  echo "$aggregates" | jq -r '"  Total: \(.features.total)
  Completed: \(.features.completed)
  In Progress: \(.features.in_progress)"'
  echo ""

  echo "✅ Tasks"
  echo "────────"
  echo "$aggregates" | jq -r '"  Total: \(.tasks.total)
  Completed: \(.tasks.completed)
  Failed: \(.tasks.failed)
  Avg Completion Rate: \(.tasks.avg_completion_rate)%"'
  echo ""

  echo "🧪 Tests"
  echo "────────"
  if [ "$(echo "$aggregates" | jq '.tests.total')" -gt 0 ]; then
    echo "$aggregates" | jq -r '"  Total: \(.tests.total)
  Passing: \(.tests.passing) (\(.tests.avg_pass_rate)%)
  Failing: \(.tests.failing)"'
  else
    echo "  No test data found"
  fi
  echo ""

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Recent Features (Last $RECENT_COUNT)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Get recent features
  recent_features=$(fm_get_recent "$features_json" "$RECENT_COUNT")

  # Display recent features table
  echo "$recent_features" | jq -r '.[] |
    "[\(.metadata.feature_number)] \(.metadata.feature_name)
  Status: \(.metadata.status) | Parent: \(.metadata.parent_branch)
  Tasks: \(.tasks.completed)/\(.tasks.total) (\(.tasks.completion_rate)%)  | Tests: \(.tests.passing_tests)/\(.tests.total_tests) (\(.tests.pass_rate)%)
  Created: \(.metadata.created_at)
  "'

  # Sprint breakdown
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Features by Sprint/Parent Branch"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Group by parent branch
  echo "$features_json" | jq -r 'group_by(.metadata.parent_branch) |
    .[] |
    "[\(.[0].metadata.parent_branch)]
  Features: \(length)
  Tasks Completed: \([.[].tasks.completed] | add)/\([.[].tasks.total] | add)
  "'

fi

# Export to CSV if requested
if [ -n "$EXPORT_FILE" ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Exporting to CSV"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  exported_file=$(fm_export_csv "$features_json" "$EXPORT_FILE")
  echo "✅ Metrics exported to: $exported_file"
  echo ""
  echo "Total rows: $((total_features + 1))"  # +1 for header
  echo ""
fi

# Help message for next steps
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Available Commands"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  /speclabs:feature-metrics                  Dashboard summary"
echo "  /speclabs:feature-metrics --recent 20      Show last 20 features"
echo "  /speclabs:feature-metrics --feature 015    Feature 015 details"
echo "  /speclabs:feature-metrics --sprint sprint-4   Sprint aggregates"
echo "  /speclabs:feature-metrics --export         Export to CSV"
echo "  /speclabs:feature-metrics --path /project  Analyze specific project"
echo ""

```

This command provides comprehensive feature-level metrics by analyzing actual project artifacts instead of orchestration sessions.

## What It Tracks

**Feature Detection**:
- Scans for spec.md files to identify features
- Works with any feature directory structure
- No orchestration session required

**Metrics Collected**:
1. **Feature Metadata** (from spec.md YAML):
   - Feature number, name, status
   - Parent branch, created/completed dates
   - Directory location

2. **Task Statistics** (from tasks.md):
   - Total, completed, failed, pending tasks
   - Completion rate percentage
   - Status markers (✅ COMPLETED, ❌ FAILED)

3. **Test Metrics** (from validation/testing docs):
   - Total tests, passing, failing
   - Pass rate percentage
   - Extracted from validation summaries

4. **Git History**:
   - Branch information
   - Commit counts
   - Merge status and dates

## Usage Examples

### Dashboard Summary
```bash
/speclabs:feature-metrics
```
Shows overall statistics and recent features.

### Feature Details
```bash
/speclabs:feature-metrics --feature 015
```
Complete metrics for Feature 015.

### Sprint Analysis
```bash
/speclabs:feature-metrics --sprint sprint-4
```
Aggregated metrics for all features in sprint-4.

### Export to CSV
```bash
/speclabs:feature-metrics --export
/speclabs:feature-metrics --export metrics-2025-11.csv
```

### Analyze Different Project
```bash
/speclabs:feature-metrics --path /home/user/projects/myapp
```

## Key Features

**No Session Required**: Analyzes actual feature artifacts, works with v2.6.1+ features that use `/specswarm:implement`

**Sprint Tracking**: Group features by parent branch for sprint-level analytics

**Export Capabilities**: CSV export for spreadsheet analysis

**Git Integration**: Tracks merge status and commit history

**Comprehensive**: Combines metadata, tasks, tests, and git data in one view

## Difference from `/speclabs:metrics`

| Feature | /speclabs:metrics | /speclabs:feature-metrics |
|---------|-------------------|---------------------------|
| Data Source | Orchestration sessions | Project artifacts (spec.md, tasks.md) |
| Workflow | Pre-v2.6.1 (per-task orchestration) | v2.6.1+ (specswarm implement) |
| Use Case | Task-level automation tracking | Feature-level completion analytics |
| Requires Session | Yes | No |

## Feature 015 Example

Feature 015 (Testing Infrastructure) metrics would show:
- 76 total tasks
- 76 completed tasks (100%)
- 136 total tests
- 131 passing tests (96.3%)
- Parent branch: sprint-4
- Status: Complete
- Git: Merged to sprint-4

This data comes from reading Feature 015's actual files, not orchestration sessions.
