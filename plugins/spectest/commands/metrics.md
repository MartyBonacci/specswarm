---
description: View performance metrics and analytics dashboard for features
---

<!--
ATTRIBUTION CHAIN:
1. Original: GitHub spec-kit (https://github.com/github/spec-kit)
   Copyright (c) GitHub, Inc. | MIT License
2. Adapted: SpecKit plugin by Marty Bonacci (2025)
3. Forked: SpecSwarm plugin with tech stack management
   by Marty Bonacci & Claude Code (2025)
4. Enhanced: SpecTest plugin - NEW metrics command
   by Marty Bonacci & Claude Code (2025)
-->

## User Input

```text
$ARGUMENTS
```

Optional: Feature number (e.g., "001") or feature name to view specific metrics.
If not provided, shows summary of all features.

## Overview

The `/spectest:metrics` command displays performance analytics for SpecTest workflow executions, including:
- Time spent per phase (specify, plan, tasks, implement)
- Parallel execution efficiency
- Tech stack violation tracking
- Quality scores
- Comparative analysis across features

## Execution Flow

### 1. Load Metrics Data

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
METRICS_FILE="${REPO_ROOT}/memory/metrics.json"
```

**If metrics.json does not exist**:
```
📊 No metrics data found

Metrics are automatically collected when using SpecTest commands.
Run a feature workflow to start collecting data:

1. /spectest:specify <description>
2. /spectest:plan
3. /spectest:tasks
4. /spectest:implement

Metrics will be saved to /memory/metrics.json
```

**If metrics.json exists**: Proceed to step 2

### 2. Parse User Input

**If $ARGUMENTS is empty**: Show summary dashboard (all features)
**If $ARGUMENTS contains feature number** (e.g., "001"): Show detailed feature metrics
**If $ARGUMENTS contains feature name**: Search for matching feature and show details

### 3. Display Dashboard

#### Option A: Summary Dashboard (No Arguments)

```
📊 SpecTest Performance Metrics - Summary

Total Features Tracked: 5
Total Implementation Time: 42m 30s
Average Time per Feature: 8m 30s
Overall Speedup: 2.7x faster (vs sequential)

Recent Features:
┌─────┬───────────────────────────────┬──────────┬──────────┬────────┐
│ ID  │ Feature Name                  │ Duration │ Speedup  │ Status │
├─────┼───────────────────────────────┼──────────┼──────────┼────────┤
│ 005 │ product-catalog               │ 7m 15s   │ 3.1x     │ ✓ Done │
│ 004 │ shopping-cart                 │ 9m 42s   │ 2.8x     │ ✓ Done │
│ 003 │ payment-integration           │ 11m 5s   │ 2.3x     │ ✓ Done │
│ 002 │ user-profile                  │ 6m 18s   │ 2.9x     │ ✓ Done │
│ 001 │ user-authentication           │ 8m 10s   │ 2.5x     │ ✓ Done │
└─────┴───────────────────────────────┴──────────┴──────────┴────────┘

Performance Trends:
• Average parallel efficiency: 78%
• Tech stack violations: 0
• Average quality score: 93/100

View detailed metrics: /spectest:metrics <feature-number>
```

#### Option B: Detailed Feature Metrics (With Feature Number)

```
📊 SpecTest Performance Metrics

Feature: 001-user-authentication
Status: ✓ Completed
Started: 2025-10-11 10:00:00
Completed: 2025-10-11 10:08:10

Phase Breakdown:
┌───────────┬──────────┬─────────┬──────────────────────┐
│ Phase     │ Duration │ Iters   │ Quality Metrics      │
├───────────┼──────────┼─────────┼──────────────────────┤
│ Specify   │ 52s      │ 2       │ Score: 95/100        │
│ Plan      │ 95s      │ 1       │ Auto-add: 2 libs     │
│ Tasks     │ 28s      │ 1       │ Parallel: 14 tasks   │
│ Implement │ 315s     │ 1       │ Batches: 3           │
├───────────┼──────────┼─────────┼──────────────────────┤
│ Total     │ 8m 10s   │ 5 ops   │ Clean (no errors)    │
└───────────┴──────────┴─────────┴──────────────────────┘

Implementation Details:
• Total tasks: 26
  - Sequential: 12 tasks (4m 30s)
  - Parallel: 14 tasks in 3 batches (2m 15s)
• Tech stack compliance: ✓ No violations
• Quality checks: ✓ All passed

Performance Analysis:
• Actual time: 8m 10s
• Sequential estimate: 20m 35s
• Time saved: 12m 25s
• Speedup factor: 2.5x faster

Parallel Execution Breakdown:
┌─────────┬───────────────────────────┬───────┬──────────┐
│ Batch   │ Tasks                     │ Count │ Duration │
├─────────┼───────────────────────────┼───────┼──────────┤
│ Batch 1 │ Models (T003-T008)        │ 6     │ 95s      │
│ Batch 2 │ Services (T011-T016)      │ 5     │ 58s      │
│ Batch 3 │ Tests (T021-T023)         │ 3     │ 42s      │
└─────────┴───────────────────────────┴───────┴──────────┘

Efficiency: 78% (ideal: 100% linear speedup)

Next Steps:
• Review implementation: Check modified files
• Compare with other features: /spectest:metrics
• Run analyze: /spectest:analyze
```

### 4. Metrics Calculation Logic

**For each phase**: Calculate duration from start_time to end_time
**For implement phase**: Special calculations:
- Sequential time = Sum of all task durations (estimated 5min/task avg)
- Parallel time = Sum of batch durations + sequential task durations
- Time saved = Sequential time - Parallel time
- Speedup factor = Sequential time / Parallel time

**Quality Score** (for specify phase):
```
Score = (100 points) - penalties:
- [NEEDS CLARIFICATION] markers: -5 points each
- Missing mandatory sections: -10 points each
- Incomplete requirements: -3 points each
Minimum score: 0
```

**Parallel Efficiency**:
```
Ideal time = Longest task in batch
Actual time = Batch execution time
Efficiency = (Ideal / Actual) * 100%

Note: 100% = perfect parallelization, <50% = overhead issues
```

### 5. Data Persistence

Metrics are stored in `/memory/metrics.json` with this structure:

```json
{
  "schema_version": "1.0.0",
  "features": {
    "001-user-authentication": {
      "created": "2025-10-11T10:00:00Z",
      "updated": "2025-10-11T10:08:10Z",
      "status": "completed",
      "phases": {
        "specify": {
          "duration_seconds": 52,
          "start_time": "2025-10-11T10:00:00Z",
          "end_time": "2025-10-11T10:00:52Z",
          "iterations": 2,
          "quality_score": 0.95,
          "clarifications": 0
        },
        "plan": {
          "duration_seconds": 95,
          "start_time": "2025-10-11T10:01:00Z",
          "end_time": "2025-10-11T10:02:35Z",
          "iterations": 1,
          "tech_stack_auto_adds": 2,
          "tech_stack_conflicts": 0,
          "tech_stack_violations": 0
        },
        "tasks": {
          "duration_seconds": 28,
          "start_time": "2025-10-11T10:02:40Z",
          "end_time": "2025-10-11T10:03:08Z",
          "total_tasks": 26,
          "parallel_tasks": 14,
          "sequential_tasks": 12
        },
        "implement": {
          "duration_seconds": 315,
          "start_time": "2025-10-11T10:03:15Z",
          "end_time": "2025-10-11T10:08:30Z",
          "parallel_batches": 3,
          "tasks_executed": 26,
          "violations": 0,
          "speedup_factor": 2.5,
          "estimated_sequential_time": 1235,
          "time_saved": 745,
          "batches": [
            {
              "batch_number": 1,
              "tasks": ["T003", "T004", "T005", "T006", "T007", "T008"],
              "duration_seconds": 95
            },
            {
              "batch_number": 2,
              "tasks": ["T011", "T012", "T013", "T014", "T015"],
              "duration_seconds": 58
            },
            {
              "batch_number": 3,
              "tasks": ["T021", "T022", "T023"],
              "duration_seconds": 42
            }
          ]
        }
      },
      "total_duration_seconds": 490
    }
  }
}
```

### 6. Error Handling

**If feature not found**:
```
❌ Feature not found: {feature_id}

Available features:
- 001-user-authentication
- 002-user-profile
- 003-payment-integration

View all metrics: /spectest:metrics
```

**If metrics incomplete** (feature in progress):
```
⚠️ Incomplete metrics for feature: 001-user-authentication

Status: In progress (last phase: tasks)

Completed phases:
✓ Specify (52s)
✓ Plan (95s)
✓ Tasks (28s)
⏳ Implement (not started)

Run /spectest:implement to continue
```

## Usage Examples

```bash
# View summary dashboard
/spectest:metrics

# View specific feature by number
/spectest:metrics 001

# View specific feature by partial name
/spectest:metrics user-auth

# After implementing a feature
/spectest:implement
# (automatically saves metrics and displays summary)
```

## Integration Notes

- Metrics are automatically collected by all SpecTest commands
- Pre/post hooks update metrics.json
- No manual configuration required
- Metrics persist across sessions
- Can be exported/analyzed externally (JSON format)

## Comparison with Other Features

When viewing summary dashboard, the command compares:
- Average speedup across features
- Trends in parallel efficiency
- Quality score improvements
- Tech stack violation patterns

This helps identify:
- Which features had best parallel opportunities
- Areas for workflow optimization
- Common bottlenecks
