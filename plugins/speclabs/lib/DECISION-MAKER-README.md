# Decision Maker

**Part of Phase 1a: Test Orchestrator Foundation**

The Decision Maker is the "brain" of the SpecLabs orchestrator. It analyzes orchestration results, categorizes failures, generates retry strategies, and decides the next action: complete, retry, or escalate to human.

---

## Features

- ✅ Intelligent decision logic (complete/retry/escalate)
- ✅ Failure analysis with 9 failure types
- ✅ Automated retry strategy generation
- ✅ Escalation detection and messaging
- ✅ Detailed reasoning and explanations
- ✅ Decision state tracking
- ✅ Human-readable summaries

---

## Quick Start

```bash
# Source the decision maker (and state manager)
source plugins/speclabs/lib/state-manager.sh
source plugins/speclabs/lib/decision-maker.sh

# After agent execution and validation, make a decision
SESSION_ID="orch-20251016-123456-789"
DECISION=$(decision_make "$SESSION_ID")

case "$DECISION" in
  complete)
    echo "Success! Task completed"
    state_complete "$SESSION_ID" "success"
    ;;
  retry)
    echo "Retrying with refined approach"
    STRATEGY=$(decision_generate_retry_strategy "$SESSION_ID")
    echo "$STRATEGY" | jq -r '.base_strategy'
    state_resume "$SESSION_ID"
    # Re-run orchestration with refined prompt
    ;;
  escalate)
    echo "Escalating to human"
    decision_get_escalation_message "$SESSION_ID"
    state_complete "$SESSION_ID" "escalated"
    ;;
esac
```

---

## API Reference

### Core Decision Functions

#### `decision_make`

Make a decision on what to do next based on session state.

**Arguments**:
- `$1` - session_id: Session identifier

**Returns**:
- Decision: `complete` | `retry` | `escalate` | `unknown`
- Exit code: 0 on success, 1 on error

**Decision Logic**:
```
IF agent.status == "completed" AND validation.status == "passed"
  → RETURN "complete"

ELSE IF retry_count < max_retries AND (agent failed OR validation failed)
  → RETURN "retry"

ELSE IF retry_count >= max_retries
  → RETURN "escalate"

ELSE
  → RETURN "unknown"
```

**Example**:
```bash
DECISION=$(decision_make "$SESSION_ID")
echo "Decision: $DECISION"
# Output: Decision: retry
```

---

#### `decision_make_detailed`

Get detailed decision with reasoning and context.

**Arguments**:
- `$1` - session_id: Session identifier

**Returns**:
- JSON object with decision, reason, details, and state snapshot
- Exit code: 0 on success, 1 on error

**Output Format**:
```json
{
  "decision": "retry",
  "reason": "Agent failed to complete task",
  "details": "Will refine prompt and retry (attempt 2/3)",
  "state": {
    "agent_status": "failed",
    "validation_status": "pending",
    "retry_count": 1,
    "max_retries": 3
  }
}
```

**Example**:
```bash
DETAILED=$(decision_make_detailed "$SESSION_ID")
DECISION=$(echo "$DETAILED" | jq -r '.decision')
REASON=$(echo "$DETAILED" | jq -r '.reason')
echo "$DECISION: $REASON"
# Output: retry: Agent failed to complete task
```

---

### Failure Analysis Functions

#### `decision_analyze_failure`

Analyze and categorize the failure type.

**Arguments**:
- `$1` - session_id: Session identifier

**Returns**:
- JSON object with failure_type, strategy, and details
- Exit code: 0 on success

**Failure Types Detected** (9 types):

| Failure Type | Detection Pattern | Example |
|--------------|-------------------|---------|
| `file_not_found` | "file not found", "no such file", "cannot find" | "Error: file not found src/main.ts" |
| `permission_error` | "permission denied", "access denied" | "Permission denied: /etc/config" |
| `syntax_error` | "syntax error", "syntaxerror", "unexpected token" | "SyntaxError: unexpected token at line 42" |
| `dependency_error` | "module not found", "cannot import" | "ModuleNotFoundError: No module named 'foo'" |
| `timeout` | "timeout", "timed out" | "Task timed out after 300s" |
| `console_errors` | validation.playwright.console_errors > 0 | JavaScript runtime errors |
| `network_errors` | validation.playwright.network_errors > 0 | Failed API calls, 404/500 errors |
| `ui_issues` | validation.vision_api.issues_found != [] | Missing UI elements, styling issues |
| `validation_failure` | Other validation failures | General validation issues |

**Output Format**:
```json
{
  "failure_type": "file_not_found",
  "strategy": "Add explicit file paths and verify they exist before modifying",
  "details": {
    "agent_status": "failed",
    "agent_error": "Error: file not found src/main.ts",
    "validation_status": "pending",
    "console_errors": null,
    "network_errors": null,
    "vision_issues": []
  }
}
```

**Example**:
```bash
ANALYSIS=$(decision_analyze_failure "$SESSION_ID")
FAILURE_TYPE=$(echo "$ANALYSIS" | jq -r '.failure_type')
STRATEGY=$(echo "$ANALYSIS" | jq -r '.strategy')

echo "Failure: $FAILURE_TYPE"
echo "Strategy: $STRATEGY"
```

---

#### `decision_generate_retry_strategy`

Generate specific retry recommendations based on failure analysis.

**Arguments**:
- `$1` - session_id: Session identifier

**Returns**:
- JSON object with retry strategy details
- Exit code: 0 on success

**Retry Strategies by Failure Type**:

| Failure Type | Retry Approach | Prompt Refinements | Additional Context |
|--------------|----------------|-------------------|-------------------|
| `file_not_found` | `explicit_paths` | Add absolute paths, verify existence | Project structure overview |
| `permission_error` | `check_permissions` | Verify write permissions, use relative paths | File system permissions |
| `syntax_error` | `add_examples` | Include syntax examples, add type definitions | Working code patterns |
| `dependency_error` | `verify_dependencies` | Check package.json, verify imports | Dependency list |
| `timeout` | `break_down_task` | Break into subtasks, implement incrementally | Task breakdown strategy |
| `console_errors` | `fix_runtime_errors` | Add error handling, fix undefined refs | Console error details |
| `network_errors` | `fix_api_calls` | Verify endpoints, add error handling | API documentation |
| `ui_issues` | `improve_ui` | Ensure elements present, apply styling | UI requirements |

**Output Format**:
```json
{
  "failure_type": "file_not_found",
  "base_strategy": "Add explicit file paths and verify they exist before modifying",
  "retry_approach": "explicit_paths",
  "prompt_refinements": "- Add absolute file paths\n- Verify files exist before modifying\n- Use 'find' or 'ls' to locate files",
  "additional_context": "Project structure overview",
  "retry_count": 1,
  "max_retries": 3,
  "escalation_warning": ""
}
```

**Example**:
```bash
RETRY_STRATEGY=$(decision_generate_retry_strategy "$SESSION_ID")

echo "Base Strategy:"
echo "$RETRY_STRATEGY" | jq -r '.base_strategy'

echo -e "\nPrompt Refinements:"
echo "$RETRY_STRATEGY" | jq -r '.prompt_refinements'

echo -e "\nAdditional Context Needed:"
echo "$RETRY_STRATEGY" | jq -r '.additional_context'
```

---

### State Management Functions

#### `decision_record`

Record a decision in the session state.

**Arguments**:
- `$1` - session_id: Session identifier
- `$2` - decision: `complete` | `retry` | `escalate` | `unknown`
- `$3` - reason: Explanation of the decision

**Returns**:
- Exit code: 0 on success, 1 on error

**Example**:
```bash
decision_record "$SESSION_ID" "retry" "Agent failed due to missing file"
```

---

#### `decision_should_escalate`

Check if the session should be escalated to human.

**Arguments**:
- `$1` - session_id: Session identifier

**Returns**:
- Exit code: 0 if should escalate, 1 if not

**Example**:
```bash
if decision_should_escalate "$SESSION_ID"; then
  echo "Escalating to human"
  decision_get_escalation_message "$SESSION_ID"
  state_complete "$SESSION_ID" "escalated"
else
  echo "Retrying automatically"
  state_resume "$SESSION_ID"
fi
```

---

### Output Functions

#### `decision_print_summary`

Print a human-readable decision summary.

**Arguments**:
- `$1` - session_id: Session identifier

**Returns**:
- Exit code: 0 on success

**Example Output**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Decision: RETRY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Reason: Agent failed to complete task
Details: Will refine prompt and retry (attempt 2/3)

Retry Strategy:
Add explicit file paths and verify they exist before modifying
```

**Example**:
```bash
decision_print_summary "$SESSION_ID"
```

---

#### `decision_get_escalation_message`

Get formatted escalation message for human review.

**Arguments**:
- `$1` - session_id: Session identifier

**Returns**:
- Human-readable escalation message
- Exit code: 0 on success

**Example Output**:
```
╔════════════════════════════════════════════════════════════╗
║  HUMAN ESCALATION REQUIRED                                 ║
╚════════════════════════════════════════════════════════════╝

Session: orch-20251016-123456-789
Task: Fix Vite Config

The orchestrator has attempted this task 3 times without success.

Last Agent Error:
Error: file not found src/main.ts

What happened:
- Multiple autonomous attempts failed
- Automatic recovery strategies exhausted
- Task complexity may exceed autonomous capability

Next Steps:
1. Review session details: state_print_summary "orch-20251016-123456-789"
2. Examine agent output: cat $(state_get_session_dir "orch-20251016-123456-789")/agent-output.log
3. Decide whether to:
   - Modify the task workflow and retry manually
   - Complete the task manually
   - Break the task into smaller subtasks
   - Abandon this approach

Session directory: /memory/orchestrator/sessions/orch-20251016-123456-789

╚════════════════════════════════════════════════════════════╝
```

**Example**:
```bash
decision_get_escalation_message "$SESSION_ID"
```

---

## Decision Logic

### Complete Decision

**Conditions**:
- Agent status: `completed`
- Validation status: `passed`

**Action**:
- Mark session as `success`
- Return `complete`

**Example**:
```bash
# Agent succeeded, validation passed
state_update "$SESSION_ID" "agent.status" '"completed"'
state_update "$SESSION_ID" "validation.status" '"passed"'

DECISION=$(decision_make "$SESSION_ID")
# Returns: "complete"
```

---

### Retry Decision

**Conditions**:
- retry_count < max_retries
- AND (agent failed OR validation failed)

**Action**:
- Return `retry`
- Generate retry strategy
- Suggest prompt refinements

**Example**:
```bash
# Agent failed, retries available
state_update "$SESSION_ID" "agent.status" '"failed"'
state_update "$SESSION_ID" "agent.error" '"File not found"'

DECISION=$(decision_make "$SESSION_ID")
# Returns: "retry"

STRATEGY=$(decision_generate_retry_strategy "$SESSION_ID")
# Returns: Strategy with explicit paths approach
```

---

### Escalate Decision

**Conditions**:
- retry_count >= max_retries
- Task still failing

**Action**:
- Return `escalate`
- Generate escalation message
- Mark session as `escalated`

**Example**:
```bash
# Max retries exceeded
# (retry_count is managed by state_resume)

DECISION=$(decision_make "$SESSION_ID")
# Returns: "escalate"

decision_get_escalation_message "$SESSION_ID"
state_complete "$SESSION_ID" "escalated"
```

---

## Integration with Orchestrate

```bash
#!/bin/bash
# orchestrate.md implementation

source plugins/speclabs/lib/state-manager.sh
source plugins/speclabs/lib/decision-maker.sh

# Step 1: Create session
SESSION_ID=$(state_create_session "$WORKFLOW" "$PROJECT" "$TASK")

# Step 2: Launch agent
# ... agent execution ...

# Step 3: Run validation
# ... validation ...

# Step 4: Make decision
DECISION=$(decision_make "$SESSION_ID")

case "$DECISION" in
  complete)
    echo "✓ Task completed successfully"
    state_complete "$SESSION_ID" "success"
    ;;

  retry)
    echo "↻ Retrying with refined approach"

    # Get retry strategy
    RETRY_STRATEGY=$(decision_generate_retry_strategy "$SESSION_ID")
    REFINEMENTS=$(echo "$RETRY_STRATEGY" | jq -r '.prompt_refinements')
    CONTEXT=$(echo "$RETRY_STRATEGY" | jq -r '.additional_context')

    # Resume session
    state_resume "$SESSION_ID"

    # Re-launch agent with refined prompt
    # Include $REFINEMENTS and $CONTEXT in prompt
    # ... retry execution ...
    ;;

  escalate)
    echo "⚠ Escalating to human"
    decision_get_escalation_message "$SESSION_ID"
    state_complete "$SESSION_ID" "escalated"
    ;;
esac
```

---

## Usage Examples

### Example 1: Basic Decision Flow

```bash
#!/bin/bash
source plugins/speclabs/lib/state-manager.sh
source plugins/speclabs/lib/decision-maker.sh

SESSION_ID=$(state_create_session "workflow.md" "/project" "Task")

# Simulate agent execution
state_update "$SESSION_ID" "agent.status" '"completed"'

# Simulate validation
state_update "$SESSION_ID" "validation.status" '"passed"'

# Make decision
DECISION=$(decision_make "$SESSION_ID")
echo "Decision: $DECISION"  # Output: complete

# Print summary
decision_print_summary "$SESSION_ID"
```

---

### Example 2: Retry with Strategy

```bash
#!/bin/bash
source plugins/speclabs/lib/state-manager.sh
source plugins/speclabs/lib/decision-maker.sh

SESSION_ID=$(state_create_session "workflow.md" "/project" "Task")

# Simulate failure
state_update "$SESSION_ID" "agent.status" '"failed"'
state_update "$SESSION_ID" "agent.error" '"File not found: src/main.ts"'

# Analyze failure
ANALYSIS=$(decision_analyze_failure "$SESSION_ID")
echo "Failure Type: $(echo "$ANALYSIS" | jq -r '.failure_type')"
# Output: file_not_found

# Generate retry strategy
RETRY_STRATEGY=$(decision_generate_retry_strategy "$SESSION_ID")
echo "Strategy: $(echo "$RETRY_STRATEGY" | jq -r '.base_strategy')"
# Output: Add explicit file paths and verify they exist before modifying

# Get prompt refinements
echo "$RETRY_STRATEGY" | jq -r '.prompt_refinements'
# Output:
# - Add absolute file paths
# - Verify files exist before modifying
# - Use 'find' or 'ls' to locate files
```

---

### Example 3: Retry Loop with Decision Maker

```bash
#!/bin/bash
source plugins/speclabs/lib/state-manager.sh
source plugins/speclabs/lib/decision-maker.sh

SESSION_ID=$(state_create_session "workflow.md" "/project" "Task")

while true; do
  # Execute agent
  execute_agent "$SESSION_ID"

  # Run validation
  run_validation "$SESSION_ID"

  # Make decision
  DECISION=$(decision_make "$SESSION_ID")

  case "$DECISION" in
    complete)
      echo "✓ Success!"
      state_complete "$SESSION_ID" "success"
      break
      ;;

    retry)
      echo "↻ Retrying..."

      # Get strategy
      STRATEGY=$(decision_generate_retry_strategy "$SESSION_ID")

      # Resume (increments retry count)
      if ! state_resume "$SESSION_ID"; then
        echo "Max retries exceeded"
        DECISION="escalate"
        break
      fi

      # Continue loop with refined approach
      continue
      ;;

    escalate)
      echo "⚠ Escalating to human"
      decision_get_escalation_message "$SESSION_ID"
      state_complete "$SESSION_ID" "escalated"
      break
      ;;
  esac
done
```

---

### Example 4: Detailed Analysis and Reporting

```bash
#!/bin/bash
source plugins/speclabs/lib/state-manager.sh
source plugins/speclabs/lib/decision-maker.sh

SESSION_ID="orch-20251016-123456-789"

# Get detailed decision
DETAILED=$(decision_make_detailed "$SESSION_ID")

# Extract components
DECISION=$(echo "$DETAILED" | jq -r '.decision')
REASON=$(echo "$DETAILED" | jq -r '.reason')
DETAILS=$(echo "$DETAILED" | jq -r '.details')

# Analyze failure if not complete
if [ "$DECISION" != "complete" ]; then
  ANALYSIS=$(decision_analyze_failure "$SESSION_ID")
  FAILURE_TYPE=$(echo "$ANALYSIS" | jq -r '.failure_type')
  STRATEGY=$(echo "$ANALYSIS" | jq -r '.strategy')

  # Generate report
  cat <<EOF
Decision Report
===============
Decision: $DECISION
Reason: $REASON
Details: $DETAILS

Failure Analysis:
Type: $FAILURE_TYPE
Strategy: $STRATEGY
EOF

  # Get retry strategy
  if [ "$DECISION" == "retry" ]; then
    RETRY_STRATEGY=$(decision_generate_retry_strategy "$SESSION_ID")
    echo ""
    echo "Retry Strategy:"
    echo "$RETRY_STRATEGY" | jq -r '.prompt_refinements'
  fi
fi
```

---

## Testing

Run the test suite:

```bash
./plugins/speclabs/lib/test-decision-maker.sh
```

**Test Coverage** (14 tests):

1. ✅ Success Case (Complete)
2. ✅ Agent Failure (Retry)
3. ✅ Validation Failure (Retry)
4. ✅ Max Retries (Escalate)
5. ✅ Detailed Decision
6. ✅ Failure Analysis (File Not Found)
7. ✅ Failure Analysis (Syntax Error)
8. ✅ Retry Strategy Generation
9. ✅ Record Decision
10. ✅ Should Escalate Check
11. ✅ Print Decision Summary
12. ✅ Escalation Message
13. ✅ Console Error Detection
14. ✅ Network Error Detection

**Expected Output**:
```
╔════════════════════════════════════════╗
║  Decision Maker Test Suite             ║
╚════════════════════════════════════════╝

✓ Test 1: Success Case
✓ Test 2: Agent Failure
...
✓ Test 14: Network Error Detection

╔════════════════════════════════════════╗
║  All Tests Passed!                     ║
╚════════════════════════════════════════╝
```

---

## Performance

- **Decision making**: <1ms (simple state reads)
- **Failure analysis**: ~5ms (regex matching + state reads)
- **Retry strategy generation**: ~10ms (analysis + template generation)
- **Detailed decision**: ~5ms (combines decision + reasoning)

All operations are fast enough for real-time orchestration.

---

## Error Handling

All functions return proper exit codes:
- `0` = Success
- `1` = Error

Errors are written to stderr:

```bash
if ! decision_make "$SESSION_ID" >/dev/null; then
  echo "Failed to make decision" >&2
  exit 1
fi
```

---

## Next Steps

### Immediate Integration
- [ ] Integrate into `/speclabs:orchestrate` command
- [ ] Add retry loop with refined prompts
- [ ] Test with real workflows

### Future Enhancements (Phase 1b+)
- [ ] Machine learning for failure pattern detection
- [ ] Success rate tracking per failure type
- [ ] Adaptive retry strategy based on history
- [ ] Confidence scores for decisions
- [ ] Multi-failure root cause analysis

---

## Dependencies

- **State Manager**: Required for session state access
- **jq**: Required for JSON parsing
- **bash 4.0+**: Required for arrays and string manipulation

---

## Files

```
plugins/speclabs/lib/
├── decision-maker.sh           # Implementation (560 lines)
├── test-decision-maker.sh      # Test suite (315 lines)
└── DECISION-MAKER-README.md    # This file
```

---

**Decision Maker v1.0** - Part of SpecLabs Phase 1a
**Status**: ✅ Complete and Tested (14/14 tests passing)
**Date**: 2025-10-16
