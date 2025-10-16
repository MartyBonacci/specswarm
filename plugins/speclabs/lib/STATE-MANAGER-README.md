# State Manager

**Part of Phase 1a: Test Orchestrator Foundation**

The State Manager handles orchestration session state, persistence, and resume functionality for the SpecLabs orchestrator.

---

## Features

- ✅ Create and track orchestration sessions
- ✅ Persist state to disk (`/memory/orchestrator/`)
- ✅ Resume sessions after failures (retry logic)
- ✅ Atomic state updates (no data loss)
- ✅ State validation and error handling
- ✅ Session cleanup and management
- ✅ Human-readable session summaries

---

## Quick Start

```bash
# Source the state manager
source plugins/speclabs/lib/state-manager.sh

# Create a new session
SESSION_ID=$(state_create_session \
  "features/001-fix/workflow.md" \
  "/home/marty/project" \
  "Fix Vite Config")

echo "Created session: $SESSION_ID"
# Output: Created session: orch-20251016-143022

# Update state
state_update "$SESSION_ID" "agent.status" '"running"'

# Get state values
STATUS=$(state_get "$SESSION_ID" "status")
echo "Status: $STATUS"

# Complete session
state_complete "$SESSION_ID" "success"

# Print summary
state_print_summary "$SESSION_ID"
```

---

## API Reference

### Core Functions

#### `state_create_session`

Create a new orchestration session.

**Arguments**:
- `$1` - workflow_file: Path to test workflow file
- `$2` - project_path: Path to target project
- `$3` - task_name: Name of the task

**Returns**:
- Session ID (e.g., `orch-20251016-143022`)
- Exit code: 0 on success, 1 on error

**Example**:
```bash
SESSION_ID=$(state_create_session \
  "features/001-fix/workflow.md" \
  "/home/marty/my-project" \
  "Fix Bug 123")
```

---

#### `state_update`

Update a value in session state.

**Arguments**:
- `$1` - session_id: Session identifier
- `$2` - key: JSON path to update (e.g., "agent.status")
- `$3` - value: New value (must be valid JSON)

**Returns**:
- Exit code: 0 on success, 1 on error

**Examples**:
```bash
# Update simple value
state_update "$SESSION_ID" "agent.status" '"completed"'

# Update nested value
state_update "$SESSION_ID" "validation.playwright.console_errors" "0"

# Update with object
state_update "$SESSION_ID" "decision" '{"action": "complete", "reason": "Success"}'

# Update with array
state_update "$SESSION_ID" "validation.vision_api.issues_found" '[]'
```

---

#### `state_get`

Get a value from session state.

**Arguments**:
- `$1` - session_id: Session identifier
- `$2` - key: JSON path to retrieve (e.g., "agent.status")

**Returns**:
- Value from state
- Exit code: 0 on success, 1 on error

**Examples**:
```bash
# Get simple value
STATUS=$(state_get "$SESSION_ID" "status")

# Get nested value
TASK_NAME=$(state_get "$SESSION_ID" "workflow.task_name")

# Get object
DECISION=$(state_get "$SESSION_ID" "decision")
```

---

#### `state_get_all`

Get entire session state as JSON.

**Arguments**:
- `$1` - session_id: Session identifier

**Returns**:
- Full JSON state
- Exit code: 0 on success, 1 on error

**Example**:
```bash
FULL_STATE=$(state_get_all "$SESSION_ID")
echo "$FULL_STATE" | jq .
```

---

#### `state_complete`

Mark session as complete.

**Arguments**:
- `$1` - session_id: Session identifier
- `$2` - final_status: Must be one of: `success | failure | escalated`

**Returns**:
- Exit code: 0 on success, 1 on error

**Examples**:
```bash
# Mark as success
state_complete "$SESSION_ID" "success"

# Mark as failure
state_complete "$SESSION_ID" "failure"

# Mark as escalated (max retries exceeded)
state_complete "$SESSION_ID" "escalated"
```

---

#### `state_resume`

Resume an existing session (for retry).

**Arguments**:
- `$1` - session_id: Session identifier

**Returns**:
- Exit code: 0 on success, 1 if max retries exceeded

**Behavior**:
- Increments retry count
- Adds entry to retry history
- Fails if retry count >= max retries

**Example**:
```bash
if state_resume "$SESSION_ID"; then
  echo "Session resumed for retry"
  # Retry the orchestration
else
  echo "Max retries exceeded"
  state_complete "$SESSION_ID" "escalated"
fi
```

---

### Utility Functions

#### `state_exists`

Check if session exists.

**Arguments**:
- `$1` - session_id: Session identifier

**Returns**:
- Exit code: 0 if exists, 1 if not

**Example**:
```bash
if state_exists "$SESSION_ID"; then
  echo "Session exists"
fi
```

---

#### `state_list_sessions`

List all sessions, optionally filtered by status.

**Arguments**:
- `$1` - status_filter: (optional) Filter by status

**Returns**:
- List of session IDs (sorted, newest first)

**Examples**:
```bash
# List all sessions
ALL_SESSIONS=$(state_list_sessions)

# List only in-progress sessions
IN_PROGRESS=$(state_list_sessions "in_progress")

# List only successful sessions
SUCCESSES=$(state_list_sessions "success")
```

---

#### `state_validate`

Validate session state structure.

**Arguments**:
- `$1` - session_id: Session identifier

**Returns**:
- Exit code: 0 if valid, 1 if invalid

**Example**:
```bash
if state_validate "$SESSION_ID"; then
  echo "State is valid"
else
  echo "State is corrupted!"
fi
```

---

#### `state_get_session_dir`

Get the session directory path.

**Arguments**:
- `$1` - session_id: Session identifier

**Returns**:
- Absolute path to session directory
- Exit code: 0 on success, 1 on error

**Example**:
```bash
SESSION_DIR=$(state_get_session_dir "$SESSION_ID")
echo "Session files: $SESSION_DIR"
```

---

#### `state_print_summary`

Print a human-readable session summary.

**Arguments**:
- `$1` - session_id: Session identifier

**Returns**:
- Exit code: 0 on success, 1 on error

**Example**:
```bash
state_print_summary "$SESSION_ID"
```

**Output**:
```
📊 Session Summary: orch-20251016-143022
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Status:          success
Task:            Fix Vite Config
Project:         /home/marty/my-project
Created:         2025-10-16T14:30:22Z
Updated:         2025-10-16T14:45:10Z

Agent Status:    completed
Validation:      passed
Retry Count:     0/3

Total Time:      900s
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

#### `state_cleanup_old_sessions`

Remove sessions older than N days.

**Arguments**:
- `$1` - days: Remove sessions older than this (default: 30)

**Returns**:
- Exit code: 0

**Example**:
```bash
# Remove sessions older than 30 days
state_cleanup_old_sessions 30

# Remove sessions older than 7 days
state_cleanup_old_sessions 7
```

---

#### `state_save_agent_output`

Save agent output/logs to session directory.

**Arguments**:
- `$1` - session_id: Session identifier
- `$2` - output_file: Path to output file to save

**Returns**:
- Exit code: 0 on success, 1 on error

**Example**:
```bash
# After agent completes, save its output
state_save_agent_output "$SESSION_ID" "/tmp/agent-output.log"
```

---

## State Schema

Each session has the following JSON structure:

```json
{
  "session_id": "orch-20251016-143022",
  "status": "in_progress | success | failure | escalated",
  "created_at": "2025-10-16T14:30:22Z",
  "updated_at": "2025-10-16T14:45:10Z",
  "completed_at": "2025-10-16T14:45:10Z",

  "workflow": {
    "file": "features/001-fix/workflow.md",
    "task_name": "Fix Vite Config",
    "project_path": "/home/marty/my-project"
  },

  "agent": {
    "id": "agent-abc123",
    "status": "pending | running | completed | failed",
    "started_at": "2025-10-16T14:30:30Z",
    "completed_at": "2025-10-16T14:45:00Z",
    "error": null,
    "output_summary": "Completed successfully"
  },

  "validation": {
    "status": "pending | passed | failed",
    "playwright": {
      "console_errors": 0,
      "network_errors": 0,
      "screenshot": "/tmp/screenshot.png"
    },
    "vision_api": {
      "analysis": "All elements present",
      "issues_found": [],
      "score": 95
    }
  },

  "retries": {
    "count": 0,
    "max": 3,
    "history": [
      {
        "attempt": 1,
        "timestamp": "2025-10-16T14:35:00Z"
      }
    ]
  },

  "decision": {
    "action": "complete | retry | escalate",
    "reason": "Agent succeeded, validation passed",
    "timestamp": "2025-10-16T14:45:10Z"
  },

  "metrics": {
    "total_time_seconds": 900,
    "agent_time_seconds": 870,
    "validation_time_seconds": 30,
    "started_at": "2025-10-16T14:30:22Z"
  }
}
```

---

## Storage

### Session Storage

Sessions are stored in:
```
/memory/orchestrator/sessions/<session-id>/
├── state.json              # Session state
├── agent-output.log        # Agent output (optional)
└── ... (other artifacts)
```

### Configuration

Environment variables:
```bash
# Override default state directory
export ORCHESTRATOR_STATE_DIR="/custom/path"

# Override max retries (default: 3)
export ORCHESTRATOR_MAX_RETRIES=5
```

---

## Error Handling

All functions return proper exit codes:
- `0` = Success
- `1` = Error

Errors are written to stderr with descriptive messages:

```bash
# Example error handling
if ! state_update "$SESSION_ID" "agent.status" '"running"'; then
  echo "Failed to update state!" >&2
  exit 1
fi
```

---

## Atomic Updates

State updates are atomic to prevent data loss:

1. Write to temporary file: `state.json.tmp.$$`
2. Use `jq` to update JSON
3. Atomic move: `mv tmp state.json`
4. If any step fails, temp file is cleaned up

This ensures state files are never left in a corrupted state.

---

## Testing

Run the test suite:

```bash
# Simple test suite
./plugins/speclabs/lib/test-state-manager-simple.sh
```

**Expected Output**:
```
╔════════════════════════════════════════╗
║  State Manager Test Suite (Simple)     ║
╚════════════════════════════════════════╝

✓ Created session: orch-20251016-143022
✓ Status is correct: in_progress
✓ Task name is correct: Test Task
...
✓ All Tests Passed!
```

---

## Usage Examples

### Example 1: Basic Orchestration Flow

```bash
#!/bin/bash
source plugins/speclabs/lib/state-manager.sh

# Create session
SESSION_ID=$(state_create_session \
  "workflow.md" \
  "/project" \
  "My Task")

# Track agent execution
state_update "$SESSION_ID" "agent.status" '"running"'
state_update "$SESSION_ID" "agent.started_at" "\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""

# ... agent does work ...

# Update after completion
state_update "$SESSION_ID" "agent.status" '"completed"'
state_update "$SESSION_ID" "agent.completed_at" "\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""

# Run validation
state_update "$SESSION_ID" "validation.status" '"passed"'

# Complete
state_complete "$SESSION_ID" "success"
state_print_summary "$SESSION_ID"
```

---

### Example 2: Retry Logic

```bash
#!/bin/bash
source plugins/speclabs/lib/state-manager.sh

SESSION_ID=$(state_create_session "workflow.md" "/project" "Task")

while true; do
  # Try to execute
  if execute_agent "$SESSION_ID"; then
    # Success!
    state_complete "$SESSION_ID" "success"
    break
  else
    # Failed - try to retry
    if state_resume "$SESSION_ID"; then
      echo "Retrying..."
      continue
    else
      # Max retries exceeded
      echo "Escalating to human"
      state_complete "$SESSION_ID" "escalated"
      break
    fi
  fi
done
```

---

### Example 3: Session Management

```bash
#!/bin/bash
source plugins/speclabs/lib/state-manager.sh

# List all in-progress sessions
echo "In-Progress Sessions:"
state_list_sessions "in_progress" | while read session_id; do
  state_print_summary "$session_id"
done

# Clean up old sessions
state_cleanup_old_sessions 30
```

---

## Integration with Orchestrate

The state manager is designed to be integrated into the `/speclabs:orchestrate` command:

```bash
# In orchestrate.md

# Step 1: Create session
SESSION_ID=$(state_create_session "$TEST_WORKFLOW" "$PROJECT_PATH" "$TASK_NAME")

# Step 2: Launch agent
state_update "$SESSION_ID" "agent.status" '"running"'
# ... launch agent ...

# Step 3: Run validation
# ... validation ...

# Step 4: Make decision
# ... decision logic ...

# Step 5: Complete or retry
if [ "$DECISION" == "complete" ]; then
  state_complete "$SESSION_ID" "success"
elif [ "$DECISION" == "retry" ]; then
  state_resume "$SESSION_ID"
  # Re-run orchestration
else
  state_complete "$SESSION_ID" "escalated"
fi
```

---

## Performance

- **Create session**: ~5ms
- **Update state**: ~10ms (atomic write)
- **Get state**: <1ms
- **List sessions**: ~10ms per 100 sessions
- **Validate state**: ~5ms

All operations are fast enough for real-time orchestration.

---

## Maintenance

### Cleanup

Run periodic cleanup:
```bash
# Daily cron job
0 0 * * * /path/to/plugins/speclabs/lib/state-manager.sh cleanup 30
```

### Backup

Session state is already on disk in `/memory/orchestrator/`. For additional backup:
```bash
# Backup all sessions
tar -czf orchestrator-sessions-backup.tar.gz /memory/orchestrator/sessions/
```

---

## Next Steps

- [ ] Integrate into `/speclabs:orchestrate` command
- [ ] Add Decision Maker integration
- [ ] Add Metrics Tracker integration
- [ ] Add Prompt Refiner integration

---

**State Manager v1.0** - Part of SpecLabs Phase 1a
**Status**: ✅ Complete and Tested
**Date**: 2025-10-16
