---
description: Check status of background SpecSwarm sessions and workflows
args:
  - name: session_id
    description: Session ID to check (optional - lists all if omitted)
    required: false
  - name: --verbose
    description: Show detailed session information
    required: false
  - name: --json
    description: Output in JSON format
    required: false
---

## User Input

```text
$ARGUMENTS
```

## Goal

Check the status of background SpecSwarm sessions (build, fix, release) or list all active/recent sessions.

**Purpose**: Track progress of background workflows without interrupting their execution.

---

## Implementation

```bash
#!/bin/bash

echo "📊 SpecSwarm Session Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
SESSIONS_DIR="${REPO_ROOT}/.specswarm/sessions"

# Parse arguments
SESSION_ID=""
VERBOSE=false
JSON_OUTPUT=false

for arg in $ARGUMENTS; do
  if [ "${arg:0:2}" != "--" ] && [ -z "$SESSION_ID" ]; then
    SESSION_ID="$arg"
  elif [ "$arg" = "--verbose" ]; then
    VERBOSE=true
  elif [ "$arg" = "--json" ]; then
    JSON_OUTPUT=true
  fi
done

# Check if sessions directory exists
if [ ! -d "$SESSIONS_DIR" ]; then
  echo "ℹ️  No sessions found"
  echo ""
  echo "Start a background session with:"
  echo "  /specswarm:build \"feature\" --background"
  echo "  /specswarm:fix \"bug\" --background"
  echo "  /specswarm:release --background"
  exit 0
fi

# Function to display session status
display_session() {
  local session_file=$1
  local session_name=$(basename "$session_file" .json)

  if [ ! -f "$session_file" ]; then
    echo "❌ Session not found: $session_name"
    return 1
  fi

  # Parse session JSON
  if command -v jq &> /dev/null; then
    local session_type=$(jq -r '.type // "build"' "$session_file")
    local status=$(jq -r '.status // "unknown"' "$session_file")
    local started_at=$(jq -r '.started_at // "unknown"' "$session_file")
    local current_phase=$(jq -r '.current_phase // "unknown"' "$session_file")
    local description=$(jq -r '.feature_description // .bug_description // "N/A"' "$session_file")
    local quality_score=$(jq -r '.quality_score // "N/A"' "$session_file")

    # Determine status emoji (use status field, not active flag)
    local status_emoji="⏳"
    if [ "$status" = "completed" ]; then
      status_emoji="✅"
    elif [ "$status" = "failed" ]; then
      status_emoji="❌"
    elif [ "$status" = "running" ]; then
      status_emoji="🔄"
    fi

    if [ "$JSON_OUTPUT" = true ]; then
      cat "$session_file"
      return 0
    fi

    echo "┌─────────────────────────────────────────────"
    echo "│ Session: $session_name"
    echo "├─────────────────────────────────────────────"
    echo "│ Status:      $status_emoji $status"
    echo "│ Type:        $session_type"
    echo "│ Description: $description"
    echo "│ Started:     $started_at"
    echo "│ Phase:       $current_phase"

    if [ "$VERBOSE" = true ]; then
      local phases_complete=$(jq -r '.phases_complete // [] | join(", ")' "$session_file")
      local quality_threshold=$(jq -r '.quality_threshold // 80' "$session_file")
      local run_validate=$(jq -r '.run_validate // false' "$session_file")

      echo "├─────────────────────────────────────────────"
      echo "│ Phases Complete: ${phases_complete:-none}"
      echo "│ Quality Score:   $quality_score"
      echo "│ Quality Gate:    $quality_threshold%"
      echo "│ Validation:      $run_validate"
    fi

    echo "└─────────────────────────────────────────────"
    echo ""
  else
    # Fallback without jq
    echo "Session: $session_name"
    cat "$session_file"
    echo ""
  fi
}

# If specific session requested
if [ -n "$SESSION_ID" ]; then
  session_file="${SESSIONS_DIR}/${SESSION_ID}.json"

  # Also check build-loop.state for active builds
  if [ ! -f "$session_file" ] && [ -f "${REPO_ROOT}/.specswarm/build-loop.state" ]; then
    active_session=$(jq -r '.session_id' "${REPO_ROOT}/.specswarm/build-loop.state" 2>/dev/null)
    if [ "$active_session" = "$SESSION_ID" ]; then
      session_file="${REPO_ROOT}/.specswarm/build-loop.state"
    fi
  fi

  display_session "$session_file"
  exit 0
fi

# List all sessions
echo "📋 All Sessions"
echo ""

# Count sessions
session_count=$(find "$SESSIONS_DIR" -name "*.json" 2>/dev/null | wc -l)

if [ "$session_count" -eq 0 ]; then
  echo "ℹ️  No sessions found"
  exit 0
fi

# Display recent sessions (last 10)
echo "Recent sessions (newest first):"
echo ""

find "$SESSIONS_DIR" -name "*.json" -type f -printf '%T@ %p\n' 2>/dev/null | \
  sort -rn | head -10 | cut -d' ' -f2- | \
  while read session_file; do
    display_session "$session_file"
  done

# Check for active build
if [ -f "${REPO_ROOT}/.specswarm/build-loop.state" ]; then
  active=$(jq -r '.active' "${REPO_ROOT}/.specswarm/build-loop.state" 2>/dev/null)
  if [ "$active" = "true" ]; then
    echo ""
    echo "🔄 Active Build Detected"
    echo "━━━━━━━━━━━━━━━━━━━━━━━"
    display_session "${REPO_ROOT}/.specswarm/build-loop.state"
  fi
fi

echo ""
echo "Commands:"
echo "  /specswarm:status <session-id>           View specific session"
echo "  /specswarm:status <session-id> --verbose Full details"
echo "  /specswarm:status --json                 JSON output"
```

---

## Usage Examples

### List All Sessions
```bash
/specswarm:status
```

### Check Specific Session
```bash
/specswarm:status build-20250127-143022-001
```

### Verbose Output
```bash
/specswarm:status build-20250127-143022-001 --verbose
```

### JSON Output (for scripting)
```bash
/specswarm:status build-20250127-143022-001 --json
```

---

## Session Types

- **build-***: Feature build workflows (`/specswarm:build --background`)
- **fix-***: Bug fix workflows (`/specswarm:fix --background`)
- **release-***: Release workflows (`/specswarm:release --background`)

---

## Notes

- Sessions are stored in `.specswarm/sessions/`
- Active build state is in `.specswarm/build-loop.state`
- Sessions are retained for troubleshooting and audit purposes
- Use `/specswarm:checkpoint` to manage checkpoints for sessions
