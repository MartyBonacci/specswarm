---
description: Expedited emergency response workflow for critical production issues
hidden: true
effort: high
---

<!--
ATTRIBUTION CHAIN:
1. Original methodology: spec-kit-extensions (https://github.com/MartyBonacci/spec-kit-extensions)
   by Marty Bonacci (2025)
2. Adapted: SpecLab plugin by Marty Bonacci & Claude Code (2025)
3. Based on: GitHub spec-kit (https://github.com/github/spec-kit)
   Copyright (c) GitHub, Inc. | MIT License
-->

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Execute expedited emergency response workflow for critical production issues requiring immediate resolution.

**Key Principles**:
1. **Speed First**: Minimal process overhead, maximum velocity
2. **Safety**: Despite speed, maintain essential safeguards
3. **Rollback Ready**: Always have rollback plan
4. **Post-Mortem**: After fire is out, analyze and learn
5. **Communication**: Keep stakeholders informed

**Use Cases**: Critical bugs, security vulnerabilities, data corruption, service outages

**Coverage**: Addresses ~10-15% of development work (emergencies)

---

## Smart Integration Detection

```bash
# Check for SpecSwarm (tech stack enforcement) - OPTIONAL in hotfix
SPECSWARM_INSTALLED=$(claude plugin list | grep -q "specswarm" && echo "true" || echo "false")

# Check for SpecTest (parallel execution, hooks, metrics)
SPECTEST_INSTALLED=$(claude plugin list | grep -q "spectest" && echo "true" || echo "false")

# In hotfix mode, integration is OPTIONAL - speed is priority
if [ "$SPECTEST_INSTALLED" = "true" ]; then
  ENABLE_METRICS=true
  echo "🎯 SpecTest detected (metrics enabled, but minimal overhead)"
fi

if [ "$SPECSWARM_INSTALLED" = "true" ]; then
  TECH_VALIDATION_AVAILABLE=true
  echo "🎯 SpecSwarm detected (tech validation available if time permits)"
fi
```

**Note**: In hotfix mode, speed takes precedence. Tech validation and hooks are OPTIONAL.

---

## Pre-Workflow Hook (if SpecTest installed)

```bash
if [ "$ENABLE_METRICS" = "true" ]; then
  echo "🎣 Pre-Hotfix Hook (minimal overhead mode)"
  WORKFLOW_START_TIME=$(date +%s)
  echo "✓ Emergency metrics tracking initialized"
  echo ""
fi
```

---

## Execution Steps

### 1. Discover Hotfix Context

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

# Try to extract hotfix number from branch (hotfix/NNN-*)
HOTFIX_NUM=$(echo "$CURRENT_BRANCH" | grep -oE 'hotfix/([0-9]{3})' | grep -oE '[0-9]{3}')

if [ -z "$HOTFIX_NUM" ]; then
  echo "🚨 HOTFIX WORKFLOW - EMERGENCY MODE"
  echo ""
  echo "No hotfix branch detected. Provide hotfix number:"
  read -p "Hotfix number: " HOTFIX_NUM
  HOTFIX_NUM=$(printf "%03d" $HOTFIX_NUM)
fi

# Source features location helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
source "$PLUGIN_DIR/lib/features-location.sh"

# Initialize features directory
ensure_features_dir "$REPO_ROOT"

FEATURE_DIR="${FEATURES_DIR}/${HOTFIX_NUM}-hotfix"
mkdir -p "$FEATURE_DIR"

HOTFIX_SPEC="${FEATURE_DIR}/hotfix.md"
TASKS_FILE="${FEATURE_DIR}/tasks.md"
```

Output:
```
🚨 Hotfix Workflow - EMERGENCY MODE - Hotfix ${HOTFIX_NUM}
✓ Branch: ${CURRENT_BRANCH}
✓ Feature directory: ${FEATURE_DIR}
⚡ Expedited process active (minimal overhead)
```

---

### 2. Create Minimal Hotfix Specification

Create `$HOTFIX_SPEC` with ESSENTIAL details only:

```markdown
# Hotfix ${HOTFIX_NUM}: [Title]

**🚨 EMERGENCY**: [Critical/High Priority]
**Created**: YYYY-MM-DD HH:MM
**Status**: Active

---

## Emergency Summary

**What's Broken**: [Brief description]

**Impact**:
- Users affected: [scope]
- Service status: [degraded/down]
- Data at risk: [Yes/No]

**Urgency**: [Immediate/Within hours/Within day]

---

## Immediate Actions

**1. Mitigation** (if applicable):
- [Temporary mitigation in place? Describe]

**2. Hotfix Scope**:
- [What needs to be fixed immediately]

**3. Rollback Plan**:
- [How to rollback if hotfix fails]

---

## Technical Details

**Root Cause** (if known):
- [Quick analysis]

**Fix Approach**:
- [Minimal changes to resolve emergency]

**Files Affected**:
- [List critical files]

**Testing Strategy**:
- [Minimal essential tests - what MUST pass?]

---

## Deployment Plan

**Target**: Production
**Rollout**: [Immediate/Phased]
**Rollback Trigger**: [When to rollback]

---

## Post-Mortem Required

**After Emergency Resolved**:
- [ ] Root cause analysis
- [ ] Permanent fix (if hotfix is temporary)
- [ ] Process improvements
- [ ] Documentation updates
- [ ] Team retrospective

---

## Metadata

**Workflow**: Hotfix (Emergency Response)
**Created By**: SpecLab Plugin v1.0.0
```

**Prompt user for:**
- Emergency summary
- Impact assessment
- Rollback plan

Write to `$HOTFIX_SPEC`.

Output:
```
📋 Hotfix Specification (Minimal)
✓ Created: ${HOTFIX_SPEC}
✓ Emergency documented
✓ Rollback plan defined
⚡ Ready for immediate action
```

---

### 3. Generate Minimal Tasks

Create `$TASKS_FILE` with ESSENTIAL tasks only:

```markdown
# Tasks: Hotfix ${HOTFIX_NUM} - EMERGENCY

**Workflow**: Hotfix (Expedited)
**Status**: Active
**Created**: YYYY-MM-DD HH:MM

---

## ⚡ EMERGENCY MODE - MINIMAL PROCESS

**Speed Priority**: Essential tasks only
**Tech Validation**: ${TECH_VALIDATION_AVAILABLE} (OPTIONAL - use if time permits)
**Metrics**: ${ENABLE_METRICS} (lightweight tracking)

---

## Emergency Tasks

### T001: Implement Hotfix
**Description**: [Minimal fix to resolve emergency]
**Files**: [list]
**Validation**: [Essential test only]
**Parallel**: No (focused fix)

### T002: Essential Testing
**Description**: Verify hotfix resolves emergency
**Test Scope**: MINIMAL (critical path only)
**Expected**: Emergency resolved
**Parallel**: No

### T003: Deploy to Production
**Description**: Emergency deployment
**Rollback Plan**: ${ROLLBACK_PLAN}
**Validation**: Service restored
**Parallel**: No

### T004: Monitor Post-Deployment
**Description**: Watch metrics, error rates, user reports
**Duration**: [monitoring period]
**Escalation**: [when to rollback]
**Parallel**: No

---

## Post-Emergency Tasks (After Fire Out)

### T005: Root Cause Analysis
**Description**: Deep dive into why emergency occurred
**Output**: Root cause doc
**Timeline**: Within 24-48 hours

### T006: Permanent Fix (if hotfix is temporary)
**Description**: Replace hotfix with proper solution
**Workflow**: Use /speclab:bugfix for permanent fix
**Timeline**: [timeframe]

### T007: Post-Mortem
**Description**: Team retrospective and process improvements
**Timeline**: Within 1 week

---

## Summary

**Emergency Tasks**: 4 (T001-T004)
**Post-Emergency Tasks**: 3 (T005-T007)
**Estimated Time to Resolution**: <1-2 hours (emergency tasks only)

**Success Criteria**:
- ✅ Emergency resolved
- ✅ Service restored
- ✅ No data loss
- ✅ Rollback plan tested (if triggered)
```

Write to `$TASKS_FILE`.

Output:
```
📊 Emergency Tasks Generated
✓ Created: ${TASKS_FILE}
✓ 4 emergency tasks (immediate resolution)
✓ 3 post-emergency tasks (learning and improvement)
⚡ Estimated resolution time: <1-2 hours
```

---

### 4. Execute Emergency Tasks

**Execute T001-T004 with MAXIMUM SPEED**:

```
🚨 Executing Hotfix Workflow - EMERGENCY MODE

⚡ T001: Implement Hotfix
[Execute minimal fix]
${TECH_VALIDATION_IF_TIME_PERMITS}

⚡ T002: Essential Testing
[Run critical path tests only]

⚡ T003: Deploy to Production
[Emergency deployment]
✓ Deployed
⏱️  Monitoring...

⚡ T004: Monitor Post-Deployment
[Watch metrics for N minutes]
${MONITORING_RESULTS}

${EMERGENCY_RESOLVED_OR_ROLLBACK}
```

**If Emergency Resolved**:
```
✅ EMERGENCY RESOLVED

📊 Resolution:
- Time to fix: [duration]
- Service status: Restored
- Impact: Mitigated

📋 Post-Emergency Actions Required:
- T005: Root cause analysis (within 24-48h)
- T006: Permanent fix (if hotfix is temporary)
- T007: Post-mortem (within 1 week)

Schedule these using normal workflows when appropriate.
```

**If Rollback Triggered**:
```
🔄 ROLLBACK INITIATED

Reason: [rollback trigger hit]
Status: Rolling back hotfix

[Execute rollback plan from hotfix.md]

✅ Rollback Complete
Service status: [current status]

⚠️  Hotfix failed - need alternative approach
Recommend: Escalate to senior engineer / architect
```

---

## Post-Workflow Hook (if SpecTest installed)

```bash
if [ "$ENABLE_METRICS" = "true" ]; then
  echo ""
  echo "🎣 Post-Hotfix Hook"

  WORKFLOW_END_TIME=$(date +%s)
  WORKFLOW_DURATION=$((WORKFLOW_END_TIME - WORKFLOW_START_TIME))
  WORKFLOW_MINUTES=$(echo "scale=0; $WORKFLOW_DURATION / 60" | bc)

  echo "✓ Emergency resolved"
  echo "⏱️  Time to Resolution: ${WORKFLOW_MINUTES} minutes"

  # Update metrics
  METRICS_FILE=".specswarm/workflow-metrics.json"
  echo "📊 Emergency metrics saved: ${METRICS_FILE}"

  echo ""
  echo "📋 Post-Emergency Actions:"
  echo "- Complete T005-T007 in normal hours"
  echo "- Schedule post-mortem"
  echo "- Document learnings"
fi
```

---

## Final Output

```
✅ Hotfix Workflow Complete - Hotfix ${HOTFIX_NUM}

🚨 Emergency Status: RESOLVED

📋 Artifacts Created:
- ${HOTFIX_SPEC}
- ${TASKS_FILE}

📊 Results:
- Emergency resolved in: ${RESOLUTION_TIME}
- Service status: Restored
- Rollback triggered: [Yes/No]

⏱️  Time to Resolution: ${WORKFLOW_DURATION}

📋 Post-Emergency Actions Required:
1. Root cause analysis (T005) - within 24-48h
2. Permanent fix (T006) - if hotfix is temporary
3. Post-mortem (T007) - within 1 week

📈 Next Steps:
- Monitor production metrics closely
- Schedule post-mortem meeting
- Plan permanent fix: /speclab:bugfix (if hotfix is temporary)
```

---

## Error Handling

**If hotfix fails**:
- Execute rollback plan immediately
- Escalate to senior engineer
- Document failure for post-mortem

**If rollback fails**:
- CRITICAL: Manual intervention required
- Alert on-call engineer
- Document all actions taken

**If emergency worsens**:
- Stop hotfix attempt
- Consider service shutdown / maintenance mode
- Escalate to incident commander

---

## Operating Principles

1. **Speed Over Process**: Minimize overhead, maximize velocity
2. **Essential Only**: Skip non-critical validations
3. **Rollback Ready**: Always have escape hatch
4. **Monitor Closely**: Watch post-deployment metrics
5. **Learn After**: Post-mortem is mandatory
6. **Communicate**: Keep stakeholders informed
7. **Temporary OK**: Hotfix can be temporary (permanent fix later)

---

## Success Criteria

✅ Emergency resolved quickly (<2 hours)
✅ Service restored to normal operation
✅ No data loss or corruption
✅ Rollback plan tested (if needed)
✅ Post-emergency tasks scheduled
✅ Incident documented for learning

---

**Workflow Coverage**: Addresses ~10-15% of development work (emergencies)
**Speed**: ~45-90 minutes average time to resolution
**Integration**: Optional SpecSwarm/SpecTest (speed takes priority)
**Graduation Path**: Proven workflow will graduate to SpecSwarm stable
