#!/bin/bash
# task-converter.sh - Convert SpecSwarm tasks to executable workflow.md files
# Part of Phase 2: Feature Workflow Engine
#
# This library converts task objects from SpecSwarm tasks.md into workflow.md
# files that can be executed by the Phase 1b orchestrator.

# Convert a task to workflow.md
# Args: task_json, project_path, spec_file, plan_file, output_file
task_to_workflow() {
  local task_json="$1"
  local project_path="$2"
  local spec_file="$3"
  local plan_file="$4"
  local output_file="$5"

  # Extract task fields
  local task_id=$(echo "$task_json" | jq -r '.id')
  local task_desc=$(echo "$task_json" | jq -r '.description')

  # Read context from spec and plan
  local spec_context=""
  local plan_context=""

  if [ -f "$spec_file" ]; then
    # Extract relevant sections from spec (first 50 lines to keep context manageable)
    spec_context=$(head -n 50 "$spec_file")
  fi

  if [ -f "$plan_file" ]; then
    # Extract relevant sections from plan (first 50 lines)
    plan_context=$(head -n 50 "$plan_file")
  fi

  # Generate workflow.md
  cat > "$output_file" <<EOF
# Workflow: $task_desc

**Task ID**: $task_id
**Generated**: $(date -Iseconds)
**Source**: SpecSwarm tasks.md via Feature Orchestrator

## Context

This task is part of a larger feature implementation orchestrated by the SpecLabs Feature Orchestrator (Phase 2).

### Feature Specification

\`\`\`
$spec_context
\`\`\`

### Implementation Plan

\`\`\`
$plan_context
\`\`\`

## Task Description

$task_desc

## Steps to Complete

You are an autonomous agent tasked with completing the above task. Follow these steps:

1. **Analyze the Context**
   - Review the feature specification above
   - Review the implementation plan above
   - Understand how this task fits into the larger feature

2. **Read Existing Code**
   - Use the Read and Glob tools to find relevant files in: \`$project_path\`
   - Understand the current codebase structure
   - Identify where changes need to be made

3. **Implement the Task**
   - Make the necessary code changes
   - Follow the coding patterns and conventions in the existing codebase
   - Ensure your implementation aligns with the specification and plan

4. **Verify Your Work**
   - Review your changes
   - Ensure the task requirements are fully met
   - Check for any obvious errors or issues

## Success Criteria

The task is considered complete when:

- ✅ All code changes are implemented
- ✅ Changes align with the feature specification
- ✅ Changes follow the implementation plan
- ✅ Code follows existing patterns and conventions
- ✅ No obvious errors or issues

## Validation

After you complete this task, the orchestrator will:

1. Run \`/speclabs:orchestrate-validate $project_path\`
2. Check for:
   - Playwright tests passing
   - No console errors
   - No network errors
   - No file system issues

If validation fails, the orchestrator will:
- Analyze the failure
- Provide you with refined instructions
- Ask you to retry (up to 3 times)

## Important Notes

- **Stay Focused**: Only complete this specific task, not the entire feature
- **Use Tools**: Use Read, Write, Edit, Glob, Grep tools as needed
- **Follow Patterns**: Match the coding style of the existing codebase
- **Ask Questions**: If the task is unclear, indicate that in your response

---

**Begin Task Execution**
EOF

  echo "✅ Workflow generated: $output_file"
}

# Convert tasks.md file to multiple workflow files
# Args: tasks_md_file, project_path, spec_file, plan_file, output_dir
tasks_file_to_workflows() {
  local tasks_md_file="$1"
  local project_path="$2"
  local spec_file="$3"
  local plan_file="$4"
  local output_dir="$5"

  if [ ! -f "$tasks_md_file" ]; then
    echo "Error: tasks.md file not found: $tasks_md_file" >&2
    return 1
  fi

  mkdir -p "$output_dir"

  local task_count=0

  # Parse tasks from tasks.md
  # This is a simplified parser - adjust based on actual tasks.md format
  while IFS= read -r line; do
    if [[ "$line" =~ ^##[[:space:]]*Task[[:space:]]*[0-9]+ ]] || \
       [[ "$line" =~ ^-[[:space:]]*\[[[:space:]]\][[:space:]]* ]]; then
      ((task_count++))

      # Extract task description
      local task_desc=$(echo "$line" | sed -E 's/^##[[:space:]]*Task[[:space:]]*[0-9]+:[[:space:]]*//; s/^-[[:space:]]*\[[[:space:]]\][[:space:]]*//')

      # Create task JSON
      local task_json=$(jq -n \
        --arg id "task_$task_count" \
        --arg desc "$task_desc" \
        '{id: $id, description: $desc}')

      # Generate workflow file
      local workflow_file="${output_dir}/workflow_task_${task_count}.md"
      task_to_workflow "$task_json" "$project_path" "$spec_file" "$plan_file" "$workflow_file"
    fi
  done < "$tasks_md_file"

  echo "✅ Generated $task_count workflow files in $output_dir"
  echo "$task_count"
}

# Enhance workflow with additional context
# Args: workflow_file, additional_context
workflow_add_context() {
  local workflow_file="$1"
  local additional_context="$2"

  if [ ! -f "$workflow_file" ]; then
    echo "Error: Workflow file not found: $workflow_file" >&2
    return 1
  fi

  # Insert additional context before "Begin Task Execution"
  local temp_file=$(mktemp)

  awk -v context="$additional_context" '
    /^---$/ && /Begin Task Execution/ {
      print "## Additional Context"
      print ""
      print context
      print ""
    }
    { print }
  ' "$workflow_file" > "$temp_file"

  mv "$temp_file" "$workflow_file"

  echo "✅ Added context to workflow: $workflow_file"
}

# Extract task from tasks.md by index
# Args: tasks_md_file, task_index (1-based)
extract_task_by_index() {
  local tasks_md_file="$1"
  local task_index="$2"

  if [ ! -f "$tasks_md_file" ]; then
    echo "Error: tasks.md file not found: $tasks_md_file" >&2
    return 1
  fi

  local current_index=0
  local task_content=""
  local in_task=false

  while IFS= read -r line; do
    # Check if this is a task header
    if [[ "$line" =~ ^##[[:space:]]*Task[[:space:]]*[0-9]+ ]]; then
      ((current_index++))

      if [ "$current_index" -eq "$task_index" ]; then
        in_task=true
        task_content="$line"
      elif [ "$in_task" = true ]; then
        # We've hit the next task, stop
        break
      fi
    elif [ "$in_task" = true ]; then
      # Accumulate task content until next task or end
      task_content="$task_content"$'\n'"$line"
    fi
  done < "$tasks_md_file"

  if [ -z "$task_content" ]; then
    echo "Error: Task $task_index not found in $tasks_md_file" >&2
    return 1
  fi

  echo "$task_content"
}

# Parse task description from task content
# Args: task_content
parse_task_description() {
  local task_content="$1"

  # Extract first line (task header)
  local first_line=$(echo "$task_content" | head -n 1)

  # Remove markdown formatting
  local description=$(echo "$first_line" | sed -E 's/^##[[:space:]]*Task[[:space:]]*[0-9]+:[[:space:]]*//; s/^-[[:space:]]*\[[[:space:]]\][[:space:]]*//')

  echo "$description"
}

# Generate workflow from task index
# Args: tasks_md_file, task_index, project_path, spec_file, plan_file, output_file
generate_workflow_by_index() {
  local tasks_md_file="$1"
  local task_index="$2"
  local project_path="$3"
  local spec_file="$4"
  local plan_file="$5"
  local output_file="$6"

  # Extract task content
  local task_content=$(extract_task_by_index "$tasks_md_file" "$task_index")

  if [ $? -ne 0 ]; then
    echo "Error: Could not extract task $task_index" >&2
    return 1
  fi

  # Parse description
  local task_desc=$(parse_task_description "$task_content")

  # Create task JSON
  local task_json=$(jq -n \
    --arg id "task_$task_index" \
    --arg desc "$task_desc" \
    --arg content "$task_content" \
    '{id: $id, description: $desc, content: $content}')

  # Generate workflow
  task_to_workflow "$task_json" "$project_path" "$spec_file" "$plan_file" "$output_file"

  echo "✅ Generated workflow for task $task_index: $output_file"
}

# Validate workflow file
# Args: workflow_file
validate_workflow() {
  local workflow_file="$1"

  if [ ! -f "$workflow_file" ]; then
    echo "❌ Workflow file not found: $workflow_file"
    return 1
  fi

  # Check for required sections
  local has_description=$(grep -q "## Task Description" "$workflow_file" && echo "true" || echo "false")
  local has_steps=$(grep -q "## Steps to Complete" "$workflow_file" && echo "true" || echo "false")
  local has_criteria=$(grep -q "## Success Criteria" "$workflow_file" && echo "true" || echo "false")

  if [ "$has_description" = "false" ] || [ "$has_steps" = "false" ] || [ "$has_criteria" = "false" ]; then
    echo "❌ Workflow validation failed: Missing required sections"
    return 1
  fi

  echo "✅ Workflow validation passed"
  return 0
}
