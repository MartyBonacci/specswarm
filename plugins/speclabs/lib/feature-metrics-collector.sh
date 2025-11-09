#!/bin/bash
# feature-metrics-collector.sh - Collect metrics from completed features
# Analyzes actual feature directories instead of orchestration sessions
# Part of SpecLabs v2.8.0+

# Feature metrics work by scanning project directories for feature artifacts
# (spec.md, tasks.md, plan.md) and aggregating completion data

# Default project path (can be overridden)
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"

# Feature detection patterns
FEATURE_PATTERNS=(
  "*/spec.md"           # Standard SpecSwarm features
  "features/*/spec.md"  # Features subdirectory
  ".features/*/spec.md" # Hidden features directory
)

#=============================================================================
# FEATURE DETECTION
#=============================================================================

# Find all feature directories in a project
# Args: project_path
# Returns: Array of feature directory paths
fm_find_features() {
  local project_path="${1:-$PROJECT_ROOT}"
  local features=()

  # Look for spec.md files (indicates a feature)
  while IFS= read -r spec_file; do
    local feature_dir=$(dirname "$spec_file")
    features+=("$feature_dir")
  done < <(find "$project_path" -type f -name "spec.md" 2>/dev/null | sort)

  # Return as JSON array
  printf '%s\n' "${features[@]}" | jq -R . | jq -s .
}

# Get feature metadata from spec.md YAML frontmatter
# Args: feature_dir
# Returns: JSON object with metadata
fm_get_feature_metadata() {
  local feature_dir="$1"
  local spec_file="$feature_dir/spec.md"

  if [ ! -f "$spec_file" ]; then
    echo "{}"
    return 1
  fi

  # Extract YAML frontmatter (between --- markers)
  local frontmatter=$(sed -n '/^---$/,/^---$/p' "$spec_file" | sed '1d;$d')

  # Parse YAML fields (simplified YAML parser)
  local feature_number=$(echo "$frontmatter" | grep '^feature_number:' | sed 's/feature_number:[[:space:]]*//')
  local parent_branch=$(echo "$frontmatter" | grep '^parent_branch:' | sed 's/parent_branch:[[:space:]]*//')
  local status=$(echo "$frontmatter" | grep '^status:' | sed 's/status:[[:space:]]*//')
  local created_at=$(echo "$frontmatter" | grep '^created_at:' | sed 's/created_at:[[:space:]]*//')
  local completed_at=$(echo "$frontmatter" | grep '^completed_at:' | sed 's/completed_at:[[:space:]]*//')

  # Get feature name from spec.md first heading
  local feature_name=$(grep -m 1 '^#[[:space:]]' "$spec_file" | sed 's/^#[[:space:]]*//')

  # Build JSON object
  jq -n \
    --arg feature_number "${feature_number:-unknown}" \
    --arg feature_name "${feature_name:-Unnamed Feature}" \
    --arg parent_branch "${parent_branch:-main}" \
    --arg status "${status:-unknown}" \
    --arg created_at "${created_at:-}" \
    --arg completed_at "${completed_at:-}" \
    --arg feature_dir "$feature_dir" \
    '{
      feature_number: $feature_number,
      feature_name: $feature_name,
      parent_branch: $parent_branch,
      status: $status,
      created_at: $created_at,
      completed_at: $completed_at,
      feature_dir: $feature_dir
    }'
}

#=============================================================================
# TASK ANALYSIS
#=============================================================================

# Analyze tasks.md for completion statistics
# Args: feature_dir
# Returns: JSON object with task stats
fm_analyze_tasks() {
  local feature_dir="$1"
  local tasks_file="$feature_dir/tasks.md"
  local spec_file="$feature_dir/spec.md"

  if [ ! -f "$tasks_file" ]; then
    echo '{"total": 0, "completed": 0, "failed": 0, "pending": 0, "completion_rate": 0}'
    return 0
  fi

  # Try multiple task count patterns
  local total=0

  # Pattern 1: "### T001:" or "### T[0-9]" (new format - try first)
  local count1=$(grep -c '^###[[:space:]]*T[0-9]' "$tasks_file" 2>/dev/null || echo "0")
  count1=$(echo "$count1" | tr -d '\n' | tr -d ' ')
  if [ -n "$count1" ] && [ "$count1" -gt 0 ] 2>/dev/null; then
    total=$count1
  fi

  # Pattern 2: "## Task X:" (old format)
  if [ "$total" -eq 0 ]; then
    local count2=$(grep -c '^##[[:space:]]*Task[[:space:]]' "$tasks_file" 2>/dev/null || echo "0")
    count2=$(echo "$count2" | tr -d '\n' | tr -d ' ')
    if [ -n "$count2" ] && [ "$count2" -gt 0 ] 2>/dev/null; then
      total=$count2
    fi
  fi

  # Pattern 3: Check for "Total Tasks:" in summary
  if [ "$total" -eq 0 ]; then
    local summary_total=$(grep '^**Total Tasks**:' "$tasks_file" | sed 's/^**Total Tasks**:[[:space:]]*//' | grep -oE '[0-9]+' | head -1 | tr -d '\n' | tr -d ' ')
    if [ -n "$summary_total" ] && [ "$summary_total" -gt 0 ] 2>/dev/null; then
      total=$summary_total
    fi
  fi

  # Count completed tasks (✅ COMPLETED marker)
  local completed=$(grep -c '✅ COMPLETED' "$tasks_file" 2>/dev/null || echo "0")
  completed=$(echo "$completed" | tr -d '\n' | tr -d ' ')
  [ -z "$completed" ] && completed=0

  # Count failed tasks (❌ FAILED marker)
  local failed=$(grep -c '❌ FAILED' "$tasks_file" 2>/dev/null || echo "0")
  failed=$(echo "$failed" | tr -d '\n' | tr -d ' ')
  [ -z "$failed" ] && failed=0

  # If no explicit markers but feature is Complete in spec.md, assume all tasks completed
  if [ "$completed" -eq 0 ] 2>/dev/null && [ "$failed" -eq 0 ] 2>/dev/null && [ "$total" -gt 0 ] 2>/dev/null && [ -f "$spec_file" ]; then
    local feature_status=$(grep '^status:' "$spec_file" | sed 's/^status:[[:space:]]*//' | tr -d '\n' | tr -d ' ')
    if [ "$feature_status" = "Complete" ] || [ "$feature_status" = "complete" ]; then
      completed=$total
    fi
  fi

  # Pending = total - completed - failed
  local pending=$(($total - $completed - $failed))

  # Calculate completion rate
  local completion_rate=0
  if [ "$total" -gt 0 ]; then
    completion_rate=$(echo "scale=1; ($completed * 100) / $total" | bc)
  fi

  jq -n \
    --argjson total "$total" \
    --argjson completed "$completed" \
    --argjson failed "$failed" \
    --argjson pending "$pending" \
    --arg completion_rate "$completion_rate" \
    '{
      total: $total,
      completed: $completed,
      failed: $failed,
      pending: $pending,
      completion_rate: ($completion_rate | tonumber)
    }'
}

#=============================================================================
# TEST METRICS ANALYSIS
#=============================================================================

# Extract test metrics from quality analysis or test results
# Args: feature_dir
# Returns: JSON object with test metrics
fm_analyze_tests() {
  local feature_dir="$1"

  # Look for test results in common locations
  local test_sources=(
    "$feature_dir/.speclabs/validation/validation-summary.md"
    "$feature_dir/docs/TESTING.md"
    "$feature_dir/test-results.json"
  )

  # Try to find test pass/fail counts
  for source in "${test_sources[@]}"; do
    if [ -f "$source" ]; then
      # Try to extract test counts (varies by format)
      # This is a simplified parser - adjust based on actual formats

      # Pattern 1: "131/136 tests passing"
      if grep -q '[0-9]*/[0-9]*.*passing' "$source"; then
        local passing=$(grep -oP '\d+(?=/\d+.*passing)' "$source" | head -1)
        local total=$(grep -oP '(?<=/)\d+(?=.*passing)' "$source" | head -1)

        if [ -n "$passing" ] && [ -n "$total" ]; then
          local pass_rate=$(echo "scale=1; ($passing * 100) / $total" | bc)
          jq -n \
            --argjson passing "$passing" \
            --argjson total "$total" \
            --arg pass_rate "$pass_rate" \
            '{
              total_tests: $total,
              passing_tests: $passing,
              failing_tests: ($total - $passing),
              pass_rate: ($pass_rate | tonumber)
            }'
          return 0
        fi
      fi

      # Pattern 2: Look for "✅ 131/136 Tests Passing"
      if grep -q '✅.*[0-9]*/[0-9]*.*Passing' "$source"; then
        local passing=$(grep -oP '(?<=✅\s)\d+(?=/\d+)' "$source" | head -1)
        local total=$(grep -oP '(?<=✅\s\d{1,5}/)\d+' "$source" | head -1)

        if [ -n "$passing" ] && [ -n "$total" ]; then
          local pass_rate=$(echo "scale=1; ($passing * 100) / $total" | bc)
          jq -n \
            --argjson passing "$passing" \
            --argjson total "$total" \
            --arg pass_rate "$pass_rate" \
            '{
              total_tests: $total,
              passing_tests: $passing,
              failing_tests: ($total - $passing),
              pass_rate: ($pass_rate | tonumber)
            }'
          return 0
        fi
      fi
    fi
  done

  # No test data found
  echo '{"total_tests": 0, "passing_tests": 0, "failing_tests": 0, "pass_rate": 0}'
}

#=============================================================================
# GIT HISTORY ANALYSIS
#=============================================================================

# Get git metadata for a feature
# Args: feature_dir
# Returns: JSON object with git data
fm_analyze_git_history() {
  local feature_dir="$1"
  local project_root=$(git -C "$feature_dir" rev-parse --show-toplevel 2>/dev/null || echo "")

  if [ -z "$project_root" ]; then
    echo '{"branch": null, "commits": 0, "merged": false, "merge_date": null}'
    return 0
  fi

  # Get current/last branch for this feature
  local branch=$(git -C "$project_root" log --all --format=%D -- "$feature_dir" | grep -oP '(?<=origin/|HEAD -> )[^,]*' | head -1 || echo "unknown")

  # Count commits for this feature directory
  local commits=$(git -C "$project_root" log --oneline --all -- "$feature_dir" | wc -l)

  # Check if feature was merged (look for merge commit)
  local merged=false
  local merge_date=""
  local merge_commit=$(git -C "$project_root" log --merges --all --format=%H -- "$feature_dir" | head -1 || echo "")

  if [ -n "$merge_commit" ]; then
    merged=true
    merge_date=$(git -C "$project_root" show -s --format=%ci "$merge_commit" 2>/dev/null || echo "")
  fi

  jq -n \
    --arg branch "$branch" \
    --argjson commits "$commits" \
    --argjson merged "$([ "$merged" = true ] && echo true || echo false)" \
    --arg merge_date "$merge_date" \
    '{
      branch: $branch,
      commits: $commits,
      merged: $merged,
      merge_date: $merge_date
    }'
}

#=============================================================================
# COMPREHENSIVE FEATURE ANALYSIS
#=============================================================================

# Get complete metrics for a single feature
# Args: feature_dir
# Returns: JSON object with all metrics
fm_analyze_feature() {
  local feature_dir="$1"

  # Get all component metrics
  local metadata=$(fm_get_feature_metadata "$feature_dir")
  local tasks=$(fm_analyze_tasks "$feature_dir")
  local tests=$(fm_analyze_tests "$feature_dir")
  local git=$(fm_analyze_git_history "$feature_dir")

  # Combine into single JSON object
  jq -n \
    --argjson metadata "$metadata" \
    --argjson tasks "$tasks" \
    --argjson tests "$tests" \
    --argjson git "$git" \
    '{
      metadata: $metadata,
      tasks: $tasks,
      tests: $tests,
      git: $git
    }'
}

# Get metrics for all features in a project
# Args: project_path
# Returns: JSON array of feature metrics
fm_analyze_all_features() {
  local project_path="${1:-$PROJECT_ROOT}"
  local features_json="[]"

  # Find all features
  local feature_dirs=$(fm_find_features "$project_path")

  # Analyze each feature
  while IFS= read -r feature_dir; do
    if [ -n "$feature_dir" ] && [ "$feature_dir" != "null" ]; then
      local feature_metrics=$(fm_analyze_feature "$feature_dir")
      features_json=$(echo "$features_json" | jq --argjson feature "$feature_metrics" '. += [$feature]')
    fi
  done < <(echo "$feature_dirs" | jq -r '.[]')

  echo "$features_json"
}

#=============================================================================
# AGGREGATE STATISTICS
#=============================================================================

# Calculate aggregate statistics across all features
# Args: features_json (array of feature metrics)
# Returns: JSON object with aggregate stats
fm_calculate_aggregates() {
  local features_json="$1"

  # Count features by status
  local total_features=$(echo "$features_json" | jq 'length')
  local completed_features=$(echo "$features_json" | jq '[.[] | select(.metadata.status == "Complete" or .metadata.status == "complete")] | length')
  local in_progress=$(echo "$features_json" | jq '[.[] | select(.metadata.status == "In Progress" or .metadata.status == "in_progress")] | length')

  # Sum task statistics
  local total_tasks=$(echo "$features_json" | jq '[.[].tasks.total] | add // 0')
  local completed_tasks=$(echo "$features_json" | jq '[.[].tasks.completed] | add // 0')
  local failed_tasks=$(echo "$features_json" | jq '[.[].tasks.failed] | add // 0')

  # Calculate average completion rate
  local avg_completion_rate=0
  if [ "$total_features" -gt 0 ]; then
    avg_completion_rate=$(echo "$features_json" | jq '[.[].tasks.completion_rate] | add / length')
  fi

  # Sum test statistics
  local total_tests=$(echo "$features_json" | jq '[.[].tests.total_tests] | add // 0')
  local passing_tests=$(echo "$features_json" | jq '[.[].tests.passing_tests] | add // 0')

  # Calculate average pass rate
  local avg_pass_rate=0
  if [ "$total_tests" -gt 0 ]; then
    avg_pass_rate=$(echo "scale=1; ($passing_tests * 100) / $total_tests" | bc)
  fi

  jq -n \
    --argjson total_features "$total_features" \
    --argjson completed_features "$completed_features" \
    --argjson in_progress "$in_progress" \
    --argjson total_tasks "$total_tasks" \
    --argjson completed_tasks "$completed_tasks" \
    --argjson failed_tasks "$failed_tasks" \
    --arg avg_completion_rate "$avg_completion_rate" \
    --argjson total_tests "$total_tests" \
    --argjson passing_tests "$passing_tests" \
    --arg avg_pass_rate "$avg_pass_rate" \
    '{
      features: {
        total: $total_features,
        completed: $completed_features,
        in_progress: $in_progress
      },
      tasks: {
        total: $total_tasks,
        completed: $completed_tasks,
        failed: $failed_tasks,
        avg_completion_rate: ($avg_completion_rate | tonumber)
      },
      tests: {
        total: $total_tests,
        passing: $passing_tests,
        failing: ($total_tests - $passing_tests),
        avg_pass_rate: ($avg_pass_rate | tonumber)
      }
    }'
}

#=============================================================================
# EXPORT FUNCTIONS
#=============================================================================

# Export feature metrics to CSV
# Args: features_json, output_file
fm_export_csv() {
  local features_json="$1"
  local output_file="$2"

  # CSV header
  echo "Feature Number,Feature Name,Status,Parent Branch,Total Tasks,Completed Tasks,Failed Tasks,Completion Rate,Total Tests,Passing Tests,Pass Rate,Git Branch,Commits,Merged,Created At" > "$output_file"

  # CSV rows
  echo "$features_json" | jq -r '.[] | [
    .metadata.feature_number,
    .metadata.feature_name,
    .metadata.status,
    .metadata.parent_branch,
    .tasks.total,
    .tasks.completed,
    .tasks.failed,
    .tasks.completion_rate,
    .tests.total_tests,
    .tests.passing_tests,
    .tests.pass_rate,
    .git.branch,
    .git.commits,
    .git.merged,
    .metadata.created_at
  ] | @csv' >> "$output_file"

  echo "$output_file"
}

# Filter features by criteria
# Args: features_json, filter_field, filter_value
# Example: fm_filter_features "$features" "metadata.parent_branch" "sprint-4"
fm_filter_features() {
  local features_json="$1"
  local filter_field="$2"
  local filter_value="$3"

  echo "$features_json" | jq --arg field "$filter_field" --arg value "$filter_value" \
    '[.[] | select(getpath($field | split(".")) == $value)]'
}

# Sort features by field
# Args: features_json, sort_field, order (asc|desc)
fm_sort_features() {
  local features_json="$1"
  local sort_field="$2"
  local order="${3:-asc}"

  if [ "$order" = "desc" ]; then
    echo "$features_json" | jq --arg field "$sort_field" \
      'sort_by(getpath($field | split("."))) | reverse'
  else
    echo "$features_json" | jq --arg field "$sort_field" \
      'sort_by(getpath($field | split(".")))'
  fi
}

# Get recent features
# Args: features_json, count
fm_get_recent() {
  local features_json="$1"
  local count="${2:-10}"

  echo "$features_json" | jq --argjson count "$count" \
    'sort_by(.metadata.created_at) | reverse | .[:$count]'
}
