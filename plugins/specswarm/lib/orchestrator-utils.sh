#!/bin/bash
# SpecSwarm Orchestrator Utilities
# Provides helper functions for multi-agent orchestration

# Analyze tasks.md and return dependency graph as JSON
analyze_task_dependencies() {
  local tasks_file="$1"

  if [ ! -f "$tasks_file" ]; then
    echo '{"error": "tasks.md not found"}'
    return 1
  fi

  # Extract tasks and dependencies using Python for robust parsing
  python3 << 'PYTHON_SCRIPT'
import re
import json
import sys

tasks_file = sys.argv[1] if len(sys.argv) > 1 else "$tasks_file"

try:
    with open("$tasks_file", "r") as f:
        content = f.read()
except:
    print('{"error": "Could not read tasks file"}')
    sys.exit(1)

# Parse tasks (T001, T002, etc.)
tasks = []

# Pattern to match task headers like "### T001: Task description" or "### T001 - Task description"
task_pattern = r'###\s+(T\d{3})[:\s\-]+(.+?)(?=###\s+T\d{3}|##\s|$)'
matches = re.findall(task_pattern, content, re.DOTALL)

for task_id, task_content in matches:
    # Check for dependencies in the task content
    deps = re.findall(r'(?:depends on|after|requires|blocked by)\s+(T\d{3})', task_content, re.IGNORECASE)

    # Extract first line as title
    lines = task_content.strip().split('\n')
    title = lines[0].strip() if lines else task_content[:50]

    tasks.append({
        "id": task_id,
        "title": title[:100],
        "content": task_content.strip()[:500],  # First 500 chars for routing
        "dependencies": list(set(deps))  # Dedupe
    })

# Build execution streams using topological sort
streams = []
completed = set()
remaining = {t["id"]: t for t in tasks}
max_iterations = len(tasks) + 1  # Prevent infinite loops

iteration = 0
while remaining and iteration < max_iterations:
    iteration += 1
    # Find tasks with all dependencies satisfied
    stream = []
    for task_id, task in list(remaining.items()):
        deps_satisfied = all(d in completed for d in task["dependencies"])
        if deps_satisfied:
            stream.append(task_id)

    if not stream:
        # Circular dependency or error - add remaining as final stream
        stream = list(remaining.keys())

    streams.append(stream)
    for task_id in stream:
        completed.add(task_id)
        remaining.pop(task_id, None)

# Calculate statistics
total_tasks = len(tasks)
parallel_potential = max(len(s) for s in streams) if streams else 0

result = {
    "tasks": tasks,
    "streams": streams,
    "statistics": {
        "total_tasks": total_tasks,
        "total_streams": len(streams),
        "max_parallel": parallel_potential,
        "has_dependencies": any(t["dependencies"] for t in tasks)
    }
}

print(json.dumps(result, indent=2))
PYTHON_SCRIPT
}

# Determine best agent type for a task based on content
route_task_to_agent() {
  local task_content="$1"
  local content_lower=$(echo "$task_content" | tr '[:upper:]' '[:lower:]')

  # Check for architecture keywords (highest priority)
  if echo "$content_lower" | grep -qE 'architecture|schema|database|api design|endpoint design|migration|erd|system design'; then
    echo "system-architect"
    return
  fi

  # Check for frontend keywords
  if echo "$content_lower" | grep -qE 'component|react|jsx|tsx|form|button|modal|hook|usestate|useeffect|props|frontend|ui element'; then
    echo "react-typescript-specialist"
    return
  fi

  # Check for design keywords
  if echo "$content_lower" | grep -qE 'design|layout|styling|css|tailwind|theme|color|typography|responsive|ux|visual'; then
    echo "ui-designer"
    return
  fi

  # Check for functional programming keywords
  if echo "$content_lower" | grep -qE 'functional|pure function|compose|pipe|transform|curry|immutable|either|result type'; then
    echo "functional-patterns"
    return
  fi

  # Check for TypeScript type system keywords
  if echo "$content_lower" | grep -qE 'type definition|interface|typescript|generic type|enum|union type|utility type'; then
    echo "react-typescript-specialist"
    return
  fi

  # Default
  echo "general-purpose"
}

# Route all tasks and return JSON mapping
route_all_tasks() {
  local analysis_json="$1"

  if ! command -v jq &> /dev/null; then
    echo '{"error": "jq required for task routing"}'
    return 1
  fi

  # Parse tasks from analysis and route each one
  echo "$analysis_json" | jq -c '.tasks[]' | while read -r task; do
    local task_id=$(echo "$task" | jq -r '.id')
    local task_content=$(echo "$task" | jq -r '.content')
    local agent_type=$(route_task_to_agent "$task_content")
    echo "{\"task_id\": \"$task_id\", \"agent_type\": \"$agent_type\"}"
  done | jq -s '.'
}

# Generate MANIFEST.md content
generate_manifest() {
  local feature_dir="$1"
  local feature_name="$2"
  local total_tasks="$3"
  local streams="$4"
  local duration="$5"
  local execution_log="$6"

  cat << MANIFEST
# Implementation Manifest

**Generated**: $(date -Iseconds 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S%z")
**Feature**: ${feature_name}

## Orchestration Summary

| Metric | Value |
|--------|-------|
| Total Tasks | ${total_tasks} |
| Execution Streams | ${streams} |
| Duration | ${duration}s |
| Mode | Parallel Orchestration |

## Execution Log

${execution_log:-"[Execution details will be populated by orchestrator agent]"}

## Files Modified

[Will be populated after execution]

## Integration Notes

[Cross-task dependencies and integration points]

---
*Generated by SpecSwarm Orchestrator v1.0.0*
MANIFEST
}

# Create initial orchestration context file
create_orchestration_context() {
  local feature_dir="$1"
  local tasks_file="$2"
  local output_file="${feature_dir}/.orchestration-context.json"

  # Analyze dependencies
  local analysis=$(analyze_task_dependencies "$tasks_file")

  # Route tasks to agents
  local routing=$(route_all_tasks "$analysis")

  # Combine into context
  if command -v jq &> /dev/null; then
    echo "$analysis" | jq --argjson routing "$routing" '. + {routing: $routing}' > "$output_file"
  else
    echo "$analysis" > "$output_file"
  fi

  echo "$output_file"
}

# Check if orchestration should be used (heuristic)
should_use_orchestration() {
  local tasks_file="$1"
  local threshold="${2:-3}"  # Default: use orchestration if 3+ tasks

  if [ ! -f "$tasks_file" ]; then
    echo "false"
    return
  fi

  local task_count=$(grep -cE '^###\s+T\d{3}' "$tasks_file" 2>/dev/null || echo "0")

  if [ "$task_count" -ge "$threshold" ]; then
    echo "true"
  else
    echo "false"
  fi
}

# Display orchestration plan (for user confirmation)
display_orchestration_plan() {
  local analysis_json="$1"

  if ! command -v jq &> /dev/null; then
    echo "Cannot display plan: jq not available"
    return 1
  fi

  local total=$(echo "$analysis_json" | jq -r '.statistics.total_tasks')
  local streams=$(echo "$analysis_json" | jq -r '.statistics.total_streams')
  local max_parallel=$(echo "$analysis_json" | jq -r '.statistics.max_parallel')

  echo ""
  echo "Orchestration Plan"
  echo "=================="
  echo ""
  echo "Total Tasks:     $total"
  echo "Exec Streams:    $streams"
  echo "Max Parallel:    $max_parallel"
  echo ""
  echo "Execution Order:"

  local stream_num=1
  echo "$analysis_json" | jq -r '.streams[]' | while read -r stream; do
    local tasks=$(echo "$stream" | jq -r 'join(", ")')
    echo "  Stream $stream_num: $tasks"
    stream_num=$((stream_num + 1))
  done
}
