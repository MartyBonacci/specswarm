---
description: Coordinate complex debugging workflows with logging, monitoring, and agent orchestration
---

<!--
ATTRIBUTION:
Debug Coordinate Plugin
by Marty Bonacci & Claude Code (2025)
Based on: docs/learnings/2025-10-14-orchestrator-missed-opportunity.md
-->

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Execute systematic debugging coordination workflow:
1. **Discovery Phase** - Add logging and collect data
2. **Analysis Phase** - Correlate patterns and identify root causes
3. **Orchestration Phase** - Spawn specialist agents and coordinate fixes
4. **Integration Phase** - Verify fixes work together

**Usage**: `/debug:coordinate <problem-description>`

**Example**:
```bash
/debug:coordinate "navbar not updating after sign-in, sign-out not working, like button blank page"
```

---

## Pre-Coordination Hook

```bash
echo "🐛 Debug Coordinator"
echo "==================="
echo ""
echo "Systematic debugging with logging, monitoring, and agent orchestration"
echo ""

# Record start time
COORD_START_TIME=$(date +%s)

# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

---

## Execution Steps

### Step 1: Parse Problem Description

```bash
# Get problem description from arguments
PROBLEM_DESC="$ARGUMENTS"

if [ -z "$PROBLEM_DESC" ]; then
    echo "❌ Error: Problem description required"
    echo ""
    echo "Usage: /debug:coordinate <problem-description>"
    echo ""
    echo "Example:"
    echo "/debug:coordinate \"navbar not updating, sign-out broken, like button error\""
    exit 1
fi

echo "📋 Problem: $PROBLEM_DESC"
echo ""
```

---

### Step 2: Discovery Phase - Initial Analysis

Analyze the problem description to identify:
- How many distinct issues are mentioned
- Which domains might be affected
- Whether orchestration is appropriate

```bash
echo "🔍 Phase 1: Discovery & Analysis"
echo "================================"
echo ""

# Count potential bugs (look for separators like commas, "and", bullet points)
BUG_COUNT=$(echo "$PROBLEM_DESC" | tr ',' '\n' | tr ';' '\n' | grep -v '^$' | wc -l)

echo "Analyzing problem description..."
echo "  • Identified $BUG_COUNT potential issue(s)"
echo ""

# Create debug session directory
DEBUG_SESSION_ID=$(date +%Y%m%d-%H%M%S)
DEBUG_DIR="${REPO_ROOT}/.debug-sessions/${DEBUG_SESSION_ID}"
mkdir -p "$DEBUG_DIR"

echo "Created debug session: $DEBUG_SESSION_ID"
echo "Directory: $DEBUG_DIR"
echo ""

# Write problem description to session
cat > "$DEBUG_DIR/problem-description.md" <<EOF
# Debug Session: $DEBUG_SESSION_ID

**Created**: $(date)
**Problem Description**: $PROBLEM_DESC

## Issues Identified

EOF

# Parse individual issues
ISSUE_NUM=1
echo "$PROBLEM_DESC" | tr ',' '\n' | tr ';' '\n' | grep -v '^$' | while read -r ISSUE; do
    ISSUE_TRIMMED=$(echo "$ISSUE" | sed 's/^ *//g' | sed 's/ *$//g')
    if [ -n "$ISSUE_TRIMMED" ]; then
        echo "$ISSUE_NUM. $ISSUE_TRIMMED" >> "$DEBUG_DIR/problem-description.md"
        ISSUE_NUM=$((ISSUE_NUM + 1))
    fi
done

echo "✅ Problem analysis complete"
echo ""
```

---

### Step 3: Determine Debugging Strategy

Based on the number of issues, decide whether to use orchestration:

```bash
echo "🎯 Determining debugging strategy..."
echo ""

if [ "$BUG_COUNT" -ge 3 ]; then
    STRATEGY="orchestrated"
    echo "Strategy: ORCHESTRATED (multi-bug scenario)"
    echo ""
    echo "Rationale:"
    echo "  • $BUG_COUNT distinct issues detected"
    echo "  • Parallel investigation will be faster"
    echo "  • Orchestrator recommended for 3+ bugs"
    echo ""
else
    STRATEGY="sequential"
    echo "Strategy: SEQUENTIAL (1-2 bugs)"
    echo ""
    echo "Rationale:"
    echo "  • $BUG_COUNT issue(s) detected"
    echo "  • Sequential debugging is efficient for small sets"
    echo ""
fi

# Save strategy to session
echo "**Strategy**: $STRATEGY" >> "$DEBUG_DIR/problem-description.md"
echo "" >> "$DEBUG_DIR/problem-description.md"
```

---

### Step 4: Discovery Phase - Add Logging Strategy

Generate a logging strategy document that identifies where to add instrumentation:

```markdown
Create a logging strategy specification:

Analyze the problem description and generate a comprehensive logging plan.

For each suspected issue:
1. Identify likely affected files/components
2. Specify logging points to add
3. Define what data to capture
4. Determine monitoring approach

**Output**: Create `$DEBUG_DIR/logging-strategy.md` with:
- Files to instrument
- Logging statements to add
- Data to capture
- Monitoring commands
```

**Logging Strategy Template**:

```markdown
# Logging Strategy

## Issue 1: [Issue Description]

### Suspected Files
- `path/to/file1.ts` - [reason]
- `path/to/file2.ts` - [reason]

### Logging Points

**File**: `path/to/file1.ts`
**Location**: Line XX (in function `functionName`)
**Log Statement**:
```typescript
console.log('[DEBUG-1] FunctionName:', { variable1, variable2, context })
```
**Purpose**: Capture state at critical point

### Monitoring
- Watch for: `[DEBUG-1]` in console
- Expected output: Values should be X
- Error indicators: null, undefined, unexpected values

---

## Issue 2: [Issue Description]
...
```

```bash
echo "📝 Phase 2: Logging Strategy"
echo "============================"
echo ""

echo "Generating logging strategy..."
echo ""
echo "ACTION REQUIRED: Analyze the problem and create logging strategy"
echo ""
echo "Create file: $DEBUG_DIR/logging-strategy.md"
echo ""
echo "For each issue in the problem description:"
echo "  1. Identify suspected files/components"
echo "  2. Determine strategic logging points"
echo "  3. Specify what data to capture"
echo "  4. Define monitoring approach"
echo ""
echo "Use template from: plugins/debug-coordinate/templates/logging-strategy-template.md"
echo ""
```

After logging strategy is created, proceed to implementation:

```bash
echo "After creating logging strategy, implement the logging:"
echo ""
echo "  1. Add logging statements to suspected files"
echo "  2. Ensure logs are easily searchable (use prefixes like [DEBUG-1])"
echo "  3. Capture relevant context (variables, state, params)"
echo "  4. Commit logging additions (so they can be reverted later)"
echo ""
```

---

### Step 5: Analysis Phase - Run & Monitor

```bash
echo "📊 Phase 3: Monitor & Analyze"
echo "============================="
echo ""

echo "Next steps:"
echo "  1. Start the application (if not running)"
echo "  2. Reproduce each issue"
echo "  3. Capture log output to: $DEBUG_DIR/logs/"
echo "  4. Analyze patterns and identify root causes"
echo ""
echo "Monitoring commands:"
echo "  • Save logs: [command] 2>&1 | tee $DEBUG_DIR/logs/session.log"
echo "  • Watch specific pattern: tail -f [logfile] | grep DEBUG"
echo "  • Filter errors: grep -E 'ERROR|WARN|DEBUG' [logfile]"
echo ""
```

Create analysis template:

```bash
cat > "$DEBUG_DIR/analysis-template.md" <<'EOF'
# Debug Analysis

## Issue 1: [Description]

### Log Evidence
```
[Paste relevant log output]
```

### Root Cause
[What is causing this issue?]

**File**: path/to/file.ts
**Line**: XX
**Problem**: [Specific issue - e.g., variable undefined, wrong condition, etc.]

### Domain
- [ ] Backend
- [ ] Frontend
- [ ] Database
- [ ] Config
- [ ] Testing

### Fix Strategy
[How to fix this issue]

---

## Issue 2: [Description]
...

---

## Summary

**Total Issues**: X
**Domains Affected**: [list]
**Orchestration Recommended**: Yes/No
EOF

echo "Created analysis template: $DEBUG_DIR/analysis-template.md"
echo ""
echo "Fill in this template as you analyze logs and identify root causes"
echo ""
```

---

### Step 6: Orchestration Phase - Generate Fix Plan

Once root causes are identified, generate orchestration plan:

```bash
echo "🎯 Phase 4: Orchestration Planning"
echo "==================================="
echo ""

if [ "$STRATEGY" = "orchestrated" ]; then
    echo "Generating orchestration plan for parallel fixes..."
    echo ""

    cat > "$DEBUG_DIR/orchestration-plan.md" <<'EOF'
# Orchestration Plan

## Execution Strategy

**Mode**: Parallel
**Agents**: [Number based on domains]

---

## Agent Assignments

### Agent 1: [Domain] Track
**Responsibility**: [Description]
**Issues**: #1, #3
**Files to Modify**:
- path/to/file1.ts
- path/to/file2.ts

**Changes Required**:
1. [Specific change 1]
2. [Specific change 2]

**Dependencies**: None (can run in parallel)

---

### Agent 2: [Domain] Track
**Responsibility**: [Description]
**Issues**: #2, #4
**Files to Modify**:
- path/to/file3.tsx
- path/to/file4.tsx

**Changes Required**:
1. [Specific change 1]
2. [Specific change 2]

**Dependencies**: None (can run in parallel)

---

## Coordination Points

### Server Restarts
- After Agent 1 completes (backend changes)
- After Agent 2 completes (if needed)

### Integration Testing
- After all agents complete
- Run full test suite
- Manual verification of each fix

---

## Success Criteria
- [ ] All issues resolved
- [ ] No new regressions
- [ ] Tests pass
- [ ] Application works as expected
EOF

    echo "✅ Orchestration plan template created: $DEBUG_DIR/orchestration-plan.md"
    echo ""
    echo "ACTION REQUIRED: Fill in orchestration plan based on analysis"
    echo ""
    echo "Then launch orchestrator:"
    echo "  /project-orchestrator:debug --plan=$DEBUG_DIR/orchestration-plan.md"
    echo ""

else
    echo "Sequential debugging workflow (1-2 bugs)"
    echo ""
    echo "Fix issues sequentially using /speclab:bugfix for each"
    echo ""
fi
```

---

### Step 7: Integration Phase - Verification

```bash
echo "✅ Phase 5: Integration & Verification"
echo "======================================="
echo ""

echo "After fixes are implemented:"
echo ""
echo "1. Run integration tests"
echo "2. Manually verify each issue is fixed"
echo "3. Check for new regressions"
echo "4. Remove debug logging (or keep if useful)"
echo "5. Document learnings"
echo ""
echo "Verification checklist: $DEBUG_DIR/verification-checklist.md"
echo ""

cat > "$DEBUG_DIR/verification-checklist.md" <<'EOF'
# Verification Checklist

## Issue Verification

- [ ] Issue 1: [Description] - FIXED
- [ ] Issue 2: [Description] - FIXED
- [ ] Issue 3: [Description] - FIXED

## Regression Testing

- [ ] Existing tests still pass
- [ ] No new errors in console
- [ ] No performance degradation
- [ ] All user flows work correctly

## Cleanup

- [ ] Remove temporary debug logging (or commit if useful)
- [ ] Update documentation
- [ ] Create regression tests for each fix
- [ ] Document learnings

## Metrics

**Debugging Time**: [X hours]
**Number of Issues Fixed**: [X]
**Strategy Used**: [Sequential/Orchestrated]
**Time Savings** (if orchestrated): [X%]
EOF

echo "Created verification checklist"
echo ""
```

---

## Post-Coordination Hook

```bash
echo ""
echo "📊 Debug Coordination Summary"
echo "=============================="
echo ""

# Calculate duration
COORD_END_TIME=$(date +%s)
COORD_DURATION=$((COORD_END_TIME - COORD_START_TIME))
COORD_MINUTES=$((COORD_DURATION / 60))

echo "Session ID: $DEBUG_SESSION_ID"
echo "Duration: ${COORD_MINUTES}m ${COORD_DURATION}s"
echo "Strategy: $STRATEGY"
echo "Issues: $BUG_COUNT"
echo ""
echo "Artifacts Created:"
echo "  • $DEBUG_DIR/problem-description.md"
echo "  • $DEBUG_DIR/logging-strategy.md"
echo "  • $DEBUG_DIR/analysis-template.md"
if [ "$STRATEGY" = "orchestrated" ]; then
    echo "  • $DEBUG_DIR/orchestration-plan.md"
fi
echo "  • $DEBUG_DIR/verification-checklist.md"
echo ""
echo "📈 Next Steps:"
echo ""
if [ "$STRATEGY" = "orchestrated" ]; then
    echo "ORCHESTRATED WORKFLOW:"
    echo "  1. Fill in logging-strategy.md"
    echo "  2. Implement logging and run application"
    echo "  3. Analyze logs and complete analysis-template.md"
    echo "  4. Fill in orchestration-plan.md"
    echo "  5. Launch orchestrator: /project-orchestrator:debug --plan=$DEBUG_DIR/orchestration-plan.md"
    echo "  6. Verify all fixes with verification-checklist.md"
else
    echo "SEQUENTIAL WORKFLOW:"
    echo "  1. Fill in logging-strategy.md"
    echo "  2. Implement logging and run application"
    echo "  3. Analyze logs and identify root causes"
    echo "  4. Fix issues one by one using /speclab:bugfix"
    echo "  5. Verify with verification-checklist.md"
fi
echo ""
echo "💡 Tip: This structured approach ensures:"
echo "  • Systematic investigation (not random debugging)"
echo "  • Clear documentation of findings"
echo "  • Efficient parallelization (when possible)"
echo "  • Verifiable results"
echo ""
```

---

## Success Criteria

✅ Problem description parsed
✅ Debug session created
✅ Strategy determined (sequential vs orchestrated)
✅ Logging strategy template created
✅ Analysis template created
✅ Orchestration plan template created (if needed)
✅ Verification checklist created
✅ Clear next steps provided

---

## Error Handling

**If no problem description provided**:
- Display usage example
- Exit with error

**If repository not detected**:
- Create debug session in current directory
- Warn user about missing git context

---

## Design Philosophy

Based on learnings from [2025-10-14-orchestrator-missed-opportunity.md](../../../docs/learnings/2025-10-14-orchestrator-missed-opportunity.md):

1. **Systematic Over Random**: Structured phases prevent random debugging
2. **Logging First**: Add instrumentation before making changes
3. **Parallel When Possible**: 3+ bugs → orchestrate
4. **Document Everything**: Create audit trail for learnings
5. **Verify Thoroughly**: Checklists ensure nothing missed

---

**This plugin transforms chaotic debugging into systematic investigation with clear orchestration opportunities.**
