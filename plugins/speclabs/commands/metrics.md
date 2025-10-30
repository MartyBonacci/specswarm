---
description: Display orchestration metrics and performance analytics across all feature sessions
args:
  - name: --session-id
    description: Show detailed metrics for a specific session
    required: false
  - name: --recent
    description: Number of recent sessions to show (default 10)
    required: false
  - name: --export
    description: Export metrics to CSV file
    required: false
---

# SpecLabs Orchestration Metrics Dashboard

```bash
echo "📊 SpecLabs Orchestration Metrics Dashboard"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Parse arguments
SESSION_ID=""
RECENT_COUNT=10
EXPORT_CSV=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --session-id) SESSION_ID="$2"; shift 2 ;;
    --recent) RECENT_COUNT="$2"; shift 2 ;;
    --export) EXPORT_CSV=true; shift ;;
    *) shift ;;
  esac
done

# Define paths (use environment variable or default)
SPECSWARM_ROOT="${SPECSWARM_ROOT:-$HOME/code-projects/specswarm}"
MEMORY_DIR="${SPECSWARM_ROOT}/memory"
ORCHESTRATOR_SESSIONS="${MEMORY_DIR}/orchestrator/sessions"
FEATURE_SESSIONS="${MEMORY_DIR}/feature-orchestrator/sessions"

# Check if session directories exist
if [ ! -d "$ORCHESTRATOR_SESSIONS" ] && [ ! -d "$FEATURE_SESSIONS" ]; then
  echo "⚠️  No orchestration sessions found"
  echo ""
  echo "Sessions will be created when you run:"
  echo "  - /speclabs:orchestrate"
  echo "  - /speclabs:orchestrate-feature"
  echo ""
  exit 0
fi
```

## Metrics Overview

```bash
# Count total sessions
TOTAL_ORCHESTRATE=$(ls -1 "$ORCHESTRATOR_SESSIONS"/*.json 2>/dev/null | wc -l || echo "0")
TOTAL_FEATURE=$(ls -1 "$FEATURE_SESSIONS"/*.json 2>/dev/null | wc -l || echo "0")
TOTAL_SESSIONS=$((TOTAL_ORCHESTRATE + TOTAL_FEATURE))

echo "### Overall Statistics"
echo ""
echo "**Total Orchestration Sessions**: $TOTAL_SESSIONS"
echo "  - Task-level orchestrations: $TOTAL_ORCHESTRATE"
echo "  - Feature-level orchestrations: $TOTAL_FEATURE"
echo ""

if [ "$TOTAL_SESSIONS" -eq 0 ]; then
  echo "No sessions to analyze. Run an orchestration command to generate metrics."
  exit 0
fi
```

## Session-Specific Metrics

```bash
if [ -n "$SESSION_ID" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "### Detailed Metrics: $SESSION_ID"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Find session file
  SESSION_FILE=""
  if [ -f "${ORCHESTRATOR_SESSIONS}/${SESSION_ID}.json" ]; then
    SESSION_FILE="${ORCHESTRATOR_SESSIONS}/${SESSION_ID}.json"
  elif [ -f "${FEATURE_SESSIONS}/${SESSION_ID}.json" ]; then
    SESSION_FILE="${FEATURE_SESSIONS}/${SESSION_ID}.json"
  else
    echo "❌ Session not found: $SESSION_ID"
    exit 1
  fi

  # Parse session data
  SESSION_TYPE=$(jq -r '.type // "orchestrator"' "$SESSION_FILE")
  STATUS=$(jq -r '.status' "$SESSION_FILE")
  CREATED=$(jq -r '.created_at' "$SESSION_FILE")
  COMPLETED=$(jq -r '.completed_at // "In Progress"' "$SESSION_FILE")

  echo "**Session Type**: $SESSION_TYPE"
  echo "**Status**: $STATUS"
  echo "**Created**: $CREATED"
  echo "**Completed**: $COMPLETED"
  echo ""

  # Feature-specific metrics
  if [ "$SESSION_TYPE" = "feature_orchestrator" ]; then
    FEATURE_DESC=$(jq -r '.feature_description' "$SESSION_FILE")
    TOTAL_TASKS=$(jq -r '.implementation.total_count // 0' "$SESSION_FILE")
    COMPLETED_TASKS=$(jq -r '.implementation.completed_count // 0' "$SESSION_FILE")
    FAILED_TASKS=$(jq -r '.implementation.failed_count // 0' "$SESSION_FILE")
    QUALITY=$(jq -r '.metrics.quality_score // "N/A"' "$SESSION_FILE")

    echo "**Feature**: $FEATURE_DESC"
    echo "**Tasks**: $COMPLETED_TASKS / $TOTAL_TASKS completed"
    echo "**Failed**: $FAILED_TASKS"
    echo "**Quality Score**: $QUALITY"
    echo ""

    # Show phase breakdown
    echo "#### Phase Breakdown:"
    echo ""
    SPEC_DURATION=$(jq -r '.phases.specify.duration // "N/A"' "$SESSION_FILE")
    PLAN_DURATION=$(jq -r '.phases.plan.duration // "N/A"' "$SESSION_FILE")
    IMPL_DURATION=$(jq -r '.phases.implementation.duration // "N/A"' "$SESSION_FILE")

    echo "- Specify: $SPEC_DURATION"
    echo "- Plan: $PLAN_DURATION"
    echo "- Implementation: $IMPL_DURATION"
    echo ""
  else
    # Task-level orchestration metrics
    WORKFLOW=$(jq -r '.workflow_file // "N/A"' "$SESSION_FILE")
    ATTEMPTS=$(jq -r '.total_attempts // 1' "$SESSION_FILE")
    SUCCESS=$(jq -r '.result.success // false' "$SESSION_FILE")

    echo "**Workflow**: $WORKFLOW"
    echo "**Attempts**: $ATTEMPTS"
    echo "**Success**: $SUCCESS"
    echo ""
  fi

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  exit 0
fi
```

## Recent Sessions Summary

```bash
echo "### Recent Sessions (Last $RECENT_COUNT)"
echo ""

# Get recent sessions from both directories
RECENT_SESSIONS=$(
  (ls -t "$ORCHESTRATOR_SESSIONS"/*.json 2>/dev/null || true; \
   ls -t "$FEATURE_SESSIONS"/*.json 2>/dev/null || true) | \
  head -n "$RECENT_COUNT"
)

if [ -z "$RECENT_SESSIONS" ]; then
  echo "No sessions found."
  exit 0
fi

# Table header
printf "%-25s %-15s %-20s %-10s %-15s\n" "Session ID" "Type" "Status" "Tasks" "Quality"
printf "%-25s %-15s %-20s %-10s %-15s\n" "-------------------------" "---------------" "--------------------" "----------" "---------------"

# Initialize counters for aggregates
TOTAL_SUCCESS=0
TOTAL_FAILED=0
TOTAL_TASK_COUNT=0
TOTAL_COMPLETED_TASKS=0
QUALITY_SUM=0
QUALITY_COUNT=0

# Process each session
for SESSION_FILE in $RECENT_SESSIONS; do
  SESSION_ID=$(basename "$SESSION_FILE" .json)
  TYPE=$(jq -r '.type // "orchestrator"' "$SESSION_FILE")
  STATUS=$(jq -r '.status' "$SESSION_FILE")

  # Determine type label
  if [ "$TYPE" = "feature_orchestrator" ]; then
    TYPE_LABEL="feature"
    TOTAL_TASKS=$(jq -r '.implementation.total_count // 0' "$SESSION_FILE")
    COMPLETED=$(jq -r '.implementation.completed_count // 0' "$SESSION_FILE")
    TASKS_DISPLAY="$COMPLETED/$TOTAL_TASKS"
    QUALITY=$(jq -r '.metrics.quality_score // ""' "$SESSION_FILE")

    TOTAL_TASK_COUNT=$((TOTAL_TASK_COUNT + TOTAL_TASKS))
    TOTAL_COMPLETED_TASKS=$((TOTAL_COMPLETED_TASKS + COMPLETED))

    if [ -n "$QUALITY" ] && [ "$QUALITY" != "null" ] && [ "$QUALITY" != "N/A" ]; then
      QUALITY_SUM=$(echo "$QUALITY_SUM + $QUALITY" | bc 2>/dev/null || echo "$QUALITY_SUM")
      QUALITY_COUNT=$((QUALITY_COUNT + 1))
      QUALITY_DISPLAY="${QUALITY}/100"
    else
      QUALITY_DISPLAY="N/A"
    fi
  else
    TYPE_LABEL="task"
    TASKS_DISPLAY="1/1"
    QUALITY_DISPLAY="N/A"
  fi

  # Count successes/failures
  SUCCESS=$(jq -r '.result.success // false' "$SESSION_FILE")
  if [ "$SUCCESS" = "true" ]; then
    TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
  else
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
  fi

  # Truncate session ID if too long
  SHORT_ID="${SESSION_ID:0:24}"

  printf "%-25s %-15s %-20s %-10s %-15s\n" "$SHORT_ID" "$TYPE_LABEL" "$STATUS" "$TASKS_DISPLAY" "$QUALITY_DISPLAY"
done

echo ""
```

## Aggregate Metrics

```bash
echo "### Aggregate Metrics"
echo ""

SUCCESS_RATE=0
if [ "$TOTAL_SESSIONS" -gt 0 ]; then
  SUCCESS_RATE=$(echo "scale=1; ($TOTAL_SUCCESS * 100) / $TOTAL_SESSIONS" | bc 2>/dev/null || echo "0")
fi

AVG_QUALITY="N/A"
if [ "$QUALITY_COUNT" -gt 0 ]; then
  AVG_QUALITY=$(echo "scale=1; $QUALITY_SUM / $QUALITY_COUNT" | bc 2>/dev/null || echo "N/A")
fi

TASK_COMPLETION_RATE="N/A"
if [ "$TOTAL_TASK_COUNT" -gt 0 ]; then
  TASK_COMPLETION_RATE=$(echo "scale=1; ($TOTAL_COMPLETED_TASKS * 100) / $TOTAL_TASK_COUNT" | bc 2>/dev/null || echo "0")
fi

echo "**Success Rate**: ${SUCCESS_RATE}% ($TOTAL_SUCCESS/$TOTAL_SESSIONS)"
echo "**Failed Sessions**: $TOTAL_FAILED"
echo "**Task Completion Rate**: ${TASK_COMPLETION_RATE}%"
echo "**Average Quality Score**: $AVG_QUALITY/100"
echo ""
```

## Export to CSV

```bash
if [ "$EXPORT_CSV" = "true" ]; then
  EXPORT_FILE="${MEMORY_DIR}/metrics-export-$(date +%Y%m%d-%H%M%S).csv"

  echo "📄 Exporting metrics to CSV..."

  # CSV header
  echo "session_id,type,status,total_tasks,completed_tasks,quality_score,created_at,completed_at" > "$EXPORT_FILE"

  # Export all sessions
  ALL_SESSIONS=$(
    (ls -t "$ORCHESTRATOR_SESSIONS"/*.json 2>/dev/null || true; \
     ls -t "$FEATURE_SESSIONS"/*.json 2>/dev/null || true)
  )

  for SESSION_FILE in $ALL_SESSIONS; do
    SESSION_ID=$(basename "$SESSION_FILE" .json)
    TYPE=$(jq -r '.type // "orchestrator"' "$SESSION_FILE")
    STATUS=$(jq -r '.status' "$SESSION_FILE")
    CREATED=$(jq -r '.created_at' "$SESSION_FILE")
    COMPLETED=$(jq -r '.completed_at // ""' "$SESSION_FILE")

    if [ "$TYPE" = "feature_orchestrator" ]; then
      TOTAL=$(jq -r '.implementation.total_count // 0' "$SESSION_FILE")
      COMP=$(jq -r '.implementation.completed_count // 0' "$SESSION_FILE")
      QUAL=$(jq -r '.metrics.quality_score // ""' "$SESSION_FILE")
    else
      TOTAL=1
      COMP=$(jq -r '.result.success // false' "$SESSION_FILE" | grep -q "true" && echo "1" || echo "0")
      QUAL=""
    fi

    echo "$SESSION_ID,$TYPE,$STATUS,$TOTAL,$COMP,$QUAL,$CREATED,$COMPLETED" >> "$EXPORT_FILE"
  done

  echo "✅ Metrics exported to: $EXPORT_FILE"
  echo ""
fi
```

---

## Usage Examples

```
# Show dashboard with recent sessions
/speclabs:metrics

# Show detailed metrics for a specific session
/speclabs:metrics --session-id feature-20251026-123456

# Show last 20 sessions
/speclabs:metrics --recent 20

# Export all metrics to CSV
/speclabs:metrics --export
```

---

**Purpose**: Track orchestration performance, quality metrics, and success rates across all SpecLabs workflows. Use this dashboard to identify patterns, monitor improvement, and analyze orchestration effectiveness.

**Key Metrics**:
- Success rate across all orchestrations
- Task completion rates for feature-level orchestrations
- Average quality scores
- Phase duration breakdowns
- Session history and trends

**Data Source**: Orchestration session data stored in `/memory/orchestrator/sessions/` and `/memory/feature-orchestrator/sessions/`
