---
description: Cross-workflow analytics dashboard showing performance metrics
---

## User Input

```text
$ARGUMENTS
```

## Goal

Display comprehensive analytics across all SpecLab workflows (bugfix, modify, hotfix, refactor, deprecate) with performance metrics, trends, and insights.

**Use Cases**:
- Track workflow efficiency
- Identify bottlenecks
- Measure quality improvements
- Report to stakeholders
- Optimize development process

---

## Execution Steps

### 1. Load Metrics Data

```bash
METRICS_FILE="/memory/workflow-metrics.json"

# If feature number provided in $ARGUMENTS, show detail for that feature
FEATURE_NUM=$ARGUMENTS

if [ -z "$FEATURE_NUM" ]; then
  # Show dashboard for all workflows
  MODE="dashboard"
else
  # Show detail for specific feature
  MODE="detail"
  FEATURE_NUM=$(printf "%03d" $FEATURE_NUM)
fi

# Check if metrics file exists
if [ ! -f "$METRICS_FILE" ]; then
  echo "📊 No metrics data found"
  echo ""
  echo "Metrics are collected when using SpecLab workflows with SpecTest installed."
  echo ""
  echo "To start collecting metrics:"
  echo "1. Install SpecTest plugin: claude plugin install /path/to/spectest"
  echo "2. Run any SpecLab workflow: /speclab:bugfix, /speclab:modify, etc."
  echo "3. Metrics will be automatically tracked"
  exit 0
fi

# Load metrics data
METRICS_DATA=$(cat "$METRICS_FILE")
```

---

### 2. Generate Dashboard (if MODE="dashboard")

```markdown
# 📊 SpecLab Workflow Metrics Dashboard

**Generated**: YYYY-MM-DD HH:MM
**Data Source**: ${METRICS_FILE}
**Period**: Last 30 days

---

## Summary Statistics

| Metric | Value |
|--------|-------|
| Total Workflows Executed | [N] |
| Total Features | [N bugfix, N modify, N hotfix, N refactor, N deprecate] |
| Average Time to Resolution | [duration] |
| Success Rate | [%] |
| Rework Cycles | [avg N per workflow] |

---

## Workflow Breakdown

### Bugfix Workflow (Regression-Test-First)

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Count | [N] | - | - |
| Avg Time to Fix | [duration] | <3h | ✅/⚠️ |
| Regressions Prevented | [N] | 100% | ✅/⚠️ |
| Test Coverage | [%] | >80% | ✅/⚠️ |

**Trend**: [↗️ Improving / ↘️ Declining / → Stable]

**Top Bugs Fixed** (by time saved):
1. Feature [NNN]: [title] - [duration]
2. Feature [NNN]: [title] - [duration]
3. Feature [NNN]: [title] - [duration]

---

### Modify Workflow (Impact-Analysis-First)

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Count | [N] | - | - |
| Avg Time to Modify | [duration] | <6h | ✅/⚠️ |
| Breaking Changes | [N] | Minimize | ✅/⚠️ |
| Backward Compat Rate | [%] | 100% | ✅/⚠️ |
| Unplanned Impacts | [N] | 0 | ✅/⚠️ |

**Trend**: [↗️ Improving / ↘️ Declining / → Stable]

**Top Modifications** (by complexity):
1. Feature [NNN]: [title] - [N dependencies affected]
2. Feature [NNN]: [title] - [N dependencies affected]
3. Feature [NNN]: [title] - [N dependencies affected]

---

### Hotfix Workflow (Emergency Response)

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Count | [N] | Minimize | ✅/⚠️ |
| Avg Time to Resolve | [duration] | <2h | ✅/⚠️ |
| Rollback Rate | [%] | <10% | ✅/⚠️ |
| Post-Mortems Done | [N] | 100% | ✅/⚠️ |

**Trend**: [↗️ Improving / ↘️ Declining / → Stable]

**Recent Hotfixes**:
1. Feature [NNN]: [title] - [resolution time]
2. Feature [NNN]: [title] - [resolution time]
3. Feature [NNN]: [title] - [resolution time]

**Hotfix Prevention Opportunity**: [N bugs could have been caught earlier with better testing]

---

### Refactor Workflow (Metrics-Driven Quality)

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Count | [N] | - | - |
| Avg Complexity Reduction | [%] | >50% | ✅/⚠️ |
| Avg Duplication Reduction | [%] | >70% | ✅/⚠️ |
| Behavior Preservation | [%] | 100% | ✅/⚠️ |
| Performance Regressions | [N] | 0 | ✅/⚠️ |

**Trend**: [↗️ Improving / ↘️ Declining / → Stable]

**Quality Improvements**:
- Total complexity reduced: [N points]
- Code duplication eliminated: [N lines]
- Maintainability improved: [avg % increase]

---

### Deprecate Workflow (Phased Sunset)

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Count | [N] | - | - |
| Avg Migration Rate | [%] | >90% | ✅/⚠️ |
| On-Time Completion | [%] | 100% | ✅/⚠️ |
| User Complaints | [N] | <5 | ✅/⚠️ |

**Trend**: [↗️ Improving / ↘️ Declining / → Stable]

**Recent Deprecations**:
1. Feature [NNN]: [title] - [migration rate]
2. Feature [NNN]: [title] - [migration rate]

---

## Performance Trends

### Time to Resolution (Last 30 Days)

```
Bugfix:    ████████░░ 2.1h avg (was 3.2h) ↗️ 34% faster
Modify:    ████████░░ 4.5h avg (was 5.8h) ↗️ 22% faster
Hotfix:    ███████░░░ 52m avg (was 1.2h) ↗️ 27% faster
Refactor:  ████████░░ 3.8h avg (was 4.5h) ↗️ 16% faster
Deprecate: N/A (long-running workflows)
```

**Overall Efficiency Gain**: [%] faster vs. previous period

---

## Quality Metrics

### Code Quality Impact

- **Bugs Fixed**: [N] total
  - Regressions prevented: [N] (100%)
  - Average time to fix: [duration]

- **Code Quality Improved**: [N] refactors
  - Complexity reduced: [avg %]
  - Duplication eliminated: [avg %]
  - Maintainability improved: [avg %]

- **Safe Modifications**: [N] modifications
  - Breaking changes: [N]
  - Backward compatibility: [%]
  - Unplanned impacts: [N]

---

## Insights & Recommendations

### 🎯 Top Wins
1. [Insight 1 - e.g., "Bugfix workflow prevented 15 regressions"]
2. [Insight 2 - e.g., "Refactoring reduced complexity by 67% on average"]
3. [Insight 3 - e.g., "Zero unplanned breaking changes in modifications"]

### ⚠️ Areas for Improvement
1. [Insight 1 - e.g., "Hotfix count increasing - consider better testing"]
2. [Insight 2 - e.g., "Some modifications taking >8h - improve impact analysis"]
3. [Insight 3 - e.g., "Deprecation timeline slippage - improve migration support"]

### 📈 Recommended Actions
1. [Action 1]
2. [Action 2]
3. [Action 3]

---

## Integration with SpecSwarm/SpecTest

**SpecSwarm Tech Stack Enforcement**:
- Violations detected: [N]
- Violations prevented: [N]
- Tech stack compliance: [%]

**SpecTest Performance Boost**:
- Parallel execution speedup: [avg Nx faster]
- Hooks executed: [N]
- Metrics tracking: ✅ Active

---

## Export Options

- **CSV Export**: [path to CSV file]
- **JSON Data**: ${METRICS_FILE}
- **Share Report**: [generate shareable summary]
```

---

### 3. Generate Feature Detail (if MODE="detail")

```markdown
# 📊 Workflow Metrics: Feature ${FEATURE_NUM}

**Generated**: YYYY-MM-DD HH:MM
**Feature**: [title]
**Workflow**: [bugfix/modify/hotfix/refactor/deprecate]
**Status**: [Completed/In Progress/Failed]

---

## Timeline

```
Specify   ████ 45s
Plan      ████ 2m 15s
Tasks     ██   30s
Implement ████████████ 6m 30s
────────────────────────────
Total:    ████████████████ 10m
```

**Phase Breakdown**:

| Phase | Duration | Iterations | Notes |
|-------|----------|------------|-------|
| Specify | [duration] | [N] | [notes] |
| Plan | [duration] | [N] | [notes] |
| Tasks | [duration] | [N] | [notes] |
| Implement | [duration] | [N] | [notes] |

---

## Workflow-Specific Metrics

[If bugfix workflow:]
### Bugfix Metrics
- Time to fix: [duration]
- Regression test created: ✅
- Test failed before fix: ✅
- Test passed after fix: ✅
- New regressions: 0 ✅
- Tech stack compliance: ✅

[If modify workflow:]
### Modify Metrics
- Time to modify: [duration]
- Dependencies analyzed: [N]
- Breaking changes: [N]
- Backward compatibility: [maintained/migration required]
- Impact analysis accuracy: [%]
- Unplanned impacts: [N]

[If hotfix workflow:]
### Hotfix Metrics
- Time to resolution: [duration]
- Rollback triggered: [Yes/No]
- Post-mortem done: [Yes/No]
- Root cause identified: [Yes/No]
- Permanent fix created: [Yes/No]

[If refactor workflow:]
### Refactor Metrics
- Time to refactor: [duration]
- Complexity before: [N]
- Complexity after: [N]
- Improvement: [%]
- Duplication before: [%]
- Duplication after: [%]
- Improvement: [%]
- Behavior preserved: ✅
- Performance impact: [None/Improved/Regressed]

[If deprecate workflow:]
### Deprecate Metrics
- Total timeline: [duration]
- Migration rate: [%]
- On-time completion: [Yes/No]
- User complaints: [N]
- Support tickets: [N]

---

## Quality Gates Passed

- ✅ All tests passed
- ✅ Tech stack compliant
- ✅ Code review approved
- ✅ Metrics met targets
- ✅ No regressions introduced

---

## Performance Comparison

**This Feature vs. Average**:
- Duration: [Faster/Slower] by [%]
- Quality: [Higher/Lower] by [%]
- Complexity: [More/Less] complex

---

## Artifacts Created

- Specification: [path]
- [Workflow-specific docs]
- Tasks: [path]
- Tests: [N tests created]

---

## Next Steps

[If workflow complete:]
✅ Workflow complete

[If workflow in progress:]
⏳ In progress:
- Current phase: [phase]
- Tasks remaining: [N]
- Estimated completion: [time]

[If workflow failed:]
❌ Workflow failed:
- Failure point: [phase]
- Error: [description]
- Recovery action: [recommendation]
```

---

### 4. Output Metrics

```
📊 SpecLab Workflow Metrics

[If dashboard mode:]
📈 Dashboard Summary:
- Total workflows: [N]
- Avg resolution time: [duration]
- Success rate: [%]
- Quality improvements: [highlights]

[If detail mode:]
📋 Feature ${FEATURE_NUM} Metrics:
- Workflow: [type]
- Duration: [time]
- Status: [status]
- Quality: [metrics summary]

📋 Full report (above)

💾 Data: ${METRICS_FILE}
```

---

## Metrics Data Structure

```json
{
  "features": {
    "042-login-timeout": {
      "workflow": "bugfix",
      "status": "completed",
      "phases": {
        "specify": {"duration_seconds": 45, "iterations": 1},
        "plan": {"duration_seconds": 135, "iterations": 1},
        "tasks": {"duration_seconds": 30, "iterations": 1},
        "implement": {"duration_seconds": 390, "iterations": 1}
      },
      "bugfix_metrics": {
        "time_to_fix_hours": 2.1,
        "regression_test_created": true,
        "test_failed_before": true,
        "test_passed_after": true,
        "new_regressions": 0,
        "tech_stack_compliant": true
      },
      "total_duration_seconds": 600,
      "timestamp": "2025-10-12T10:30:00Z"
    }
  },
  "summary": {
    "last_30_days": {
      "bugfix": {"count": 15, "avg_duration_hours": 2.1},
      "modify": {"count": 8, "avg_duration_hours": 4.5},
      "hotfix": {"count": 2, "avg_duration_hours": 0.87},
      "refactor": {"count": 5, "avg_duration_hours": 3.8},
      "deprecate": {"count": 1, "avg_duration_days": 45}
    }
  }
}
```

---

## Success Criteria

✅ Metrics data loaded
✅ Dashboard or detail view generated
✅ Trends analyzed
✅ Insights provided
✅ Recommendations clear
