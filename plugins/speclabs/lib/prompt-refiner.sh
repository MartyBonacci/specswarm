#!/bin/bash
#
# Prompt Refiner for SpecLabs Orchestrator
# Generates refined prompts based on failure analysis and retry strategies
#
# Part of Phase 1a: Test Orchestrator Foundation
#

set -euo pipefail

# Source dependencies if not already loaded
if ! declare -f state_get >/dev/null 2>&1; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/state-manager.sh"
fi

if ! declare -f decision_analyze_failure >/dev/null 2>&1; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/decision-maker.sh"
fi

#######################################
# Refine a prompt based on failure analysis
# Arguments:
#   $1 - session_id: Session identifier
#   $2 - original_prompt: Original prompt text
# Outputs:
#   Refined prompt text
# Returns:
#   0 on success, 1 on error
#######################################
prompt_refine() {
  local session_id="$1"
  local original_prompt="$2"

  # Validate session exists
  if ! state_exists "$session_id"; then
    echo "ERROR: Session not found: $session_id" >&2
    return 1
  fi

  # Get failure analysis and retry strategy
  local analysis
  analysis=$(decision_analyze_failure "$session_id")
  local retry_strategy
  retry_strategy=$(decision_generate_retry_strategy "$session_id")

  # Extract key information
  local failure_type
  failure_type=$(echo "$analysis" | jq -r '.failure_type')
  local retry_count
  retry_count=$(state_get "$session_id" "retries.count")
  local agent_error
  agent_error=$(state_get "$session_id" "agent.error")

  # Build refined prompt
  local refined_prompt

  # Add header with retry context
  refined_prompt="## RETRY ATTEMPT $retry_count - Refined Prompt

**Previous Failure Type**: $failure_type
**Previous Error**: $agent_error

**Important**: The previous attempt failed. Please carefully follow the additional guidance below.

---

"

  # Add failure-specific guidance
  refined_prompt+="$(prompt_add_failure_guidance "$failure_type" "$retry_strategy")"
  refined_prompt+="

---

## Original Task

$original_prompt

---

## Additional Requirements (Based on Failure Analysis)

"

  # Add specific requirements based on failure type
  refined_prompt+="$(prompt_add_requirements "$failure_type" "$retry_strategy")"

  # Add examples if applicable
  local examples
  examples=$(prompt_add_examples "$failure_type" "$session_id")
  if [ -n "$examples" ]; then
    refined_prompt+="

---

## Examples

$examples"
  fi

  # Add final checklist
  refined_prompt+="

---

## Verification Checklist

Before completing the task, verify:
$(prompt_add_checklist "$failure_type")

---

**Remember**: Take extra care to avoid the previous failure. Follow all guidance above.
"

  echo "$refined_prompt"
  return 0
}

#######################################
# Add failure-specific guidance
# Arguments:
#   $1 - failure_type
#   $2 - retry_strategy (JSON)
# Outputs:
#   Guidance text
#######################################
prompt_add_failure_guidance() {
  local failure_type="$1"
  local retry_strategy="$2"

  local base_strategy
  base_strategy=$(echo "$retry_strategy" | jq -r '.base_strategy')
  local prompt_refinements
  prompt_refinements=$(echo "$retry_strategy" | jq -r '.prompt_refinements')

  cat <<EOF
### What Went Wrong

The previous attempt failed due to: **$failure_type**

### Strategy for This Retry

$base_strategy

### Key Refinements

$prompt_refinements
EOF
}

#######################################
# Add specific requirements based on failure type
# Arguments:
#   $1 - failure_type
#   $2 - retry_strategy (JSON)
# Outputs:
#   Requirements text
#######################################
prompt_add_requirements() {
  local failure_type="$1"
  local retry_strategy="$2"

  local additional_context
  additional_context=$(echo "$retry_strategy" | jq -r '.additional_context')

  case "$failure_type" in
    file_not_found)
      cat <<'EOF'
1. **Use absolute file paths** - Always specify full paths from project root
2. **Verify files exist first** - Use tools to check file existence before operations
3. **List directory contents** - If unsure about file locations, list directories first
4. **Double-check spelling** - Ensure file names and paths are spelled correctly
5. **Consider case sensitivity** - File paths may be case-sensitive

**Additional Context Needed**: Project structure, file locations
EOF
      ;;

    permission_error)
      cat <<'EOF'
1. **Check write permissions** - Verify you have permission to modify files
2. **Use relative paths** - Work within the project directory
3. **Avoid system directories** - Don't try to modify /etc, /usr, etc.
4. **Create in user space** - Only create files in project directories

**Additional Context Needed**: File system permissions, project boundaries
EOF
      ;;

    syntax_error)
      cat <<'EOF'
1. **Follow language syntax strictly** - Pay attention to language-specific syntax rules
2. **Include all required elements** - Don't omit semicolons, braces, etc.
3. **Match existing code style** - Follow the patterns in the codebase
4. **Validate syntax before completing** - Double-check your code syntax
5. **Use proper indentation** - Maintain consistent indentation

**Additional Context Needed**: Language syntax rules, existing code examples
EOF
      ;;

    dependency_error)
      cat <<'EOF'
1. **Verify imports exist** - Check that modules/packages are available
2. **Use correct import paths** - Ensure import statements match file structure
3. **Check package.json** - Verify dependencies are listed and installed
4. **Use installed versions** - Don't import packages that aren't installed
5. **Match existing imports** - Follow import patterns in the codebase

**Additional Context Needed**: Installed dependencies, import patterns
EOF
      ;;

    timeout)
      cat <<'EOF'
1. **Break into smaller steps** - Don't try to do everything at once
2. **Focus on one component** - Complete one piece at a time
3. **Avoid complex refactors** - Keep changes minimal and focused
4. **Implement incrementally** - Build up functionality step by step
5. **Skip non-essential work** - Focus on core requirements only

**Additional Context Needed**: Task breakdown, priority order
EOF
      ;;

    console_errors)
      cat <<'EOF'
1. **Add error handling** - Wrap code in try-catch where appropriate
2. **Check for undefined** - Verify variables exist before using them
3. **Validate data types** - Ensure data matches expected types
4. **Handle null/undefined** - Check for null values before accessing properties
5. **Test error paths** - Consider what happens when things go wrong

**Additional Context Needed**: Console error details, error patterns
EOF
      ;;

    network_errors)
      cat <<'EOF'
1. **Verify API endpoints** - Ensure URLs are correct and accessible
2. **Add error handling** - Handle network failures gracefully
3. **Check response status** - Verify 200/201 responses before proceeding
4. **Handle timeouts** - Add timeout handling for network requests
5. **Validate responses** - Check response format and content

**Additional Context Needed**: API documentation, endpoint list
EOF
      ;;

    ui_issues)
      cat <<'EOF'
1. **Include all UI elements** - Ensure all required elements are present
2. **Apply proper styling** - Use correct CSS classes and styles
3. **Check responsive design** - Verify layout works at different sizes
4. **Test accessibility** - Ensure elements are accessible
5. **Match design specs** - Follow the UI requirements exactly

**Additional Context Needed**: UI design specifications, required elements
EOF
      ;;

    *)
      cat <<EOF
1. **Review the error carefully** - Understand what went wrong
2. **Add more context** - Provide additional information in your approach
3. **Break down the task** - Approach it step by step
4. **Verify each step** - Check your work as you go
5. **Follow best practices** - Use standard patterns and approaches

**Additional Context**: $additional_context
EOF
      ;;
  esac
}

#######################################
# Add code examples based on failure type
# Arguments:
#   $1 - failure_type
#   $2 - session_id
# Outputs:
#   Examples text (if applicable)
#######################################
prompt_add_examples() {
  local failure_type="$1"
  local session_id="$2"

  case "$failure_type" in
    file_not_found)
      cat <<'EOF'
### Example: Verify File Exists Before Editing

```bash
# WRONG - editing without checking
Edit src/main.ts

# RIGHT - verify first
Read src/main.ts
# (If Read succeeds, then Edit)
Edit src/main.ts
```

### Example: List Directory Contents

```bash
# Find files before operating on them
Glob pattern="src/**/*.ts"
# (This shows available files)
```
EOF
      ;;

    syntax_error)
      cat <<'EOF'
### Example: Valid TypeScript Syntax

```typescript
// WRONG - syntax error
function foo() {
  return bar
}

// RIGHT - proper syntax
function foo(): string {
  return bar;
}
```

### Example: Check Existing Code Patterns

```bash
# Read existing files to see patterns
Read src/components/Example.tsx
# (Match the style and patterns you see)
```
EOF
      ;;

    dependency_error)
      cat <<'EOF'
### Example: Check Dependencies First

```bash
# Read package.json to see what's installed
Read package.json

# Use only dependencies that are listed
```

### Example: Check Existing Imports

```bash
# Read a working file to see import patterns
Read src/components/WorkingComponent.tsx
# (Use the same import style)
```
EOF
      ;;

    console_errors)
      cat <<'EOF'
### Example: Add Error Handling

```typescript
// WRONG - no error handling
const data = JSON.parse(response);
const value = data.items[0].value;

// RIGHT - with error handling
try {
  const data = JSON.parse(response);
  if (data && data.items && data.items.length > 0) {
    const value = data.items[0].value;
  }
} catch (error) {
  console.error('Failed to parse response:', error);
}
```
EOF
      ;;

    *)
      # No examples for other failure types
      echo ""
      ;;
  esac
}

#######################################
# Add verification checklist
# Arguments:
#   $1 - failure_type
# Outputs:
#   Checklist text
#######################################
prompt_add_checklist() {
  local failure_type="$1"

  case "$failure_type" in
    file_not_found)
      cat <<'EOF'
- [ ] All file paths are absolute or verified to exist
- [ ] Directory structure has been confirmed
- [ ] File names are spelled correctly (including case)
- [ ] No assumptions about file locations
EOF
      ;;

    permission_error)
      cat <<'EOF'
- [ ] All operations are within project directory
- [ ] No system directories are being modified
- [ ] Write permissions are available for target files
- [ ] Paths are relative to project root
EOF
      ;;

    syntax_error)
      cat <<'EOF'
- [ ] All syntax is valid for the target language
- [ ] Brackets, parentheses, and braces are balanced
- [ ] Semicolons are included where required
- [ ] Indentation is consistent
- [ ] Code follows patterns in existing files
EOF
      ;;

    dependency_error)
      cat <<'EOF'
- [ ] All imports reference installed packages
- [ ] Import paths match file structure
- [ ] package.json includes all dependencies
- [ ] Import style matches existing code
EOF
      ;;

    timeout)
      cat <<'EOF'
- [ ] Task has been broken into small steps
- [ ] Only essential changes are included
- [ ] Complex refactoring has been avoided
- [ ] Each step is focused and minimal
EOF
      ;;

    console_errors)
      cat <<'EOF'
- [ ] Null/undefined checks are in place
- [ ] Error handling has been added
- [ ] Variables are validated before use
- [ ] Try-catch blocks wrap risky operations
EOF
      ;;

    network_errors)
      cat <<'EOF'
- [ ] API endpoints are correct
- [ ] Response status codes are checked
- [ ] Error handling for network failures is present
- [ ] Timeouts are handled appropriately
EOF
      ;;

    ui_issues)
      cat <<'EOF'
- [ ] All required UI elements are present
- [ ] Styling is applied correctly
- [ ] Layout is responsive
- [ ] Accessibility requirements are met
EOF
      ;;

    *)
      cat <<'EOF'
- [ ] Previous error has been carefully analyzed
- [ ] Root cause has been addressed
- [ ] Additional context has been incorporated
- [ ] Solution follows best practices
EOF
      ;;
  esac
}

#######################################
# Read workflow file
# Arguments:
#   $1 - workflow_file: Path to workflow file
# Outputs:
#   Workflow content
# Returns:
#   0 on success, 1 on error
#######################################
prompt_read_workflow() {
  local workflow_file="$1"

  if [ ! -f "$workflow_file" ]; then
    echo "ERROR: Workflow file not found: $workflow_file" >&2
    return 1
  fi

  cat "$workflow_file"
  return 0
}

#######################################
# Save refined prompt
# Arguments:
#   $1 - session_id: Session identifier
#   $2 - refined_prompt: Refined prompt text
# Returns:
#   0 on success, 1 on error
#######################################
prompt_save() {
  local session_id="$1"
  local refined_prompt="$2"

  local session_dir
  session_dir=$(state_get_session_dir "$session_id")

  if [ -z "$session_dir" ]; then
    echo "ERROR: Could not get session directory" >&2
    return 1
  fi

  local retry_count
  retry_count=$(state_get "$session_id" "retries.count")

  local prompt_file="$session_dir/refined-prompt-retry-$retry_count.md"

  echo "$refined_prompt" > "$prompt_file"

  # Also update state with prompt file path
  state_update "$session_id" "prompt.refined_file" "\"$prompt_file\""

  echo "$prompt_file"
  return 0
}

#######################################
# Generate refinement diff/summary
# Arguments:
#   $1 - original_prompt: Original prompt
#   $2 - refined_prompt: Refined prompt
# Outputs:
#   Summary of what was added
#######################################
prompt_diff() {
  local original_prompt="$1"
  local refined_prompt="$2"

  local original_lines
  original_lines=$(echo "$original_prompt" | wc -l)
  local refined_lines
  refined_lines=$(echo "$refined_prompt" | wc -l)
  local added_lines=$((refined_lines - original_lines))

  cat <<EOF
Prompt Refinement Summary
═════════════════════════

Original prompt: $original_lines lines
Refined prompt:  $refined_lines lines
Added:           $added_lines lines (+$(echo "scale=0; $added_lines * 100 / $original_lines" | bc)%)

Additions include:
- Retry context and failure analysis
- Failure-specific guidance
- Additional requirements
- Code examples (if applicable)
- Verification checklist

The refined prompt provides explicit guidance to avoid repeating the previous failure.
EOF
}

#######################################
# Get refinement statistics for a session
# Arguments:
#   $1 - session_id: Session identifier
# Outputs:
#   JSON with refinement stats
#######################################
prompt_get_stats() {
  local session_id="$1"

  local retry_count
  retry_count=$(state_get "$session_id" "retries.count")

  local failure_type
  local analysis
  analysis=$(decision_analyze_failure "$session_id" 2>/dev/null || echo '{"failure_type":"unknown"}')
  failure_type=$(echo "$analysis" | jq -r '.failure_type')

  local has_examples="false"
  if [ "$failure_type" == "file_not_found" ] || \
     [ "$failure_type" == "syntax_error" ] || \
     [ "$failure_type" == "dependency_error" ] || \
     [ "$failure_type" == "console_errors" ]; then
    has_examples="true"
  fi

  cat <<EOF
{
  "session_id": "$session_id",
  "retry_count": $retry_count,
  "failure_type": "$failure_type",
  "has_examples": $has_examples,
  "refinements_applied": [
    "failure_context",
    "retry_strategy",
    "requirements",
    "checklist"
  ]
}
EOF
}

# Export functions if sourced
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
  export -f prompt_refine
  export -f prompt_add_failure_guidance
  export -f prompt_add_requirements
  export -f prompt_add_examples
  export -f prompt_add_checklist
  export -f prompt_read_workflow
  export -f prompt_save
  export -f prompt_diff
  export -f prompt_get_stats
fi
