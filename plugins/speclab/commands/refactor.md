---
description: Metrics-driven code quality improvement with behavior preservation
---

<!--
ATTRIBUTION CHAIN:
1. Original methodology: spec-kit-extensions by Marty Bonacci (2025)
2. Adapted: SpecLab plugin by Marty Bonacci & Claude Code (2025)
3. Based on: GitHub spec-kit | MIT License
-->

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Execute metrics-driven refactoring workflow to improve code quality while preserving behavior.

**Key Principles**:
1. **Metrics First**: Establish baseline before refactoring
2. **Behavior Preservation**: No functional changes
3. **Testable**: Verify identical behavior before/after
4. **Measurable Improvement**: Quantify quality gains
5. **Incremental**: Small, safe refactoring steps

**Refactoring Types**: Extract function/module, reduce complexity, eliminate duplication, improve naming, optimize performance

**Coverage**: Addresses ~10% of development work (quality improvement)

---

## Smart Integration

```bash
SPECSWARM_INSTALLED=$(claude plugin list | grep -q "specswarm" && echo "true" || echo "false")
SPECTEST_INSTALLED=$(claude plugin list | grep -q "spectest" && echo "true" || echo "false")

if [ "$SPECTEST_INSTALLED" = "true" ]; then
  EXECUTION_MODE="parallel"
  ENABLE_HOOKS=true
  ENABLE_METRICS=true
  echo "🎯 SpecTest detected (parallel execution, hooks, metrics enabled)"
elif [ "$SPECSWARM_INSTALLED" = "true" ]; then
  ENABLE_TECH_VALIDATION=true
  echo "🎯 SpecSwarm detected (tech stack enforcement enabled)"
fi
```

---

## Execution Steps

### 1. Discover Refactor Context

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
REFACTOR_NUM=$(echo "$CURRENT_BRANCH" | grep -oE 'refactor/([0-9]{3})' | grep -oE '[0-9]{3}')

if [ -z "$REFACTOR_NUM" ]; then
  echo "♻️  Refactor Workflow"
  echo "Provide refactor number:"
  read -p "Refactor number: " REFACTOR_NUM
  REFACTOR_NUM=$(printf "%03d" $REFACTOR_NUM)
fi

FEATURE_DIR="${REPO_ROOT}/features/${REFACTOR_NUM}-refactor"
mkdir -p "$FEATURE_DIR"

REFACTOR_SPEC="${FEATURE_DIR}/refactor.md"
BASELINE_METRICS="${FEATURE_DIR}/baseline-metrics.md"
TASKS_FILE="${FEATURE_DIR}/tasks.md"
```

---

### 2. Establish Baseline Metrics

Analyze target code and establish baseline:

```markdown
# Baseline Metrics: Refactor ${REFACTOR_NUM}

**Target**: [File/module/function to refactor]
**Analysis Date**: YYYY-MM-DD

---

## Code Metrics

### Complexity Metrics
- **Cyclomatic Complexity**: [N] (target: <10)
- **Cognitive Complexity**: [N] (target: <15)
- **Nesting Depth**: [N] (target: <4)
- **Function Length**: [N lines] (target: <50)

### Quality Metrics
- **Code Duplication**: [N%] (target: <3%)
- **Test Coverage**: [N%] (target: >80%)
- **Maintainability Index**: [N/100] (target: >65)

### Performance Metrics (if applicable)
- **Execution Time**: [duration]
- **Memory Usage**: [MB]
- **Database Queries**: [N]

---

## Identified Issues

| Issue | Severity | Metric | Current | Target |
|-------|----------|--------|---------|--------|
| [Issue 1] | High | [Metric] | [Value] | [Value] |
| [Issue 2] | Medium | [Metric] | [Value] | [Value] |

---

## Refactoring Opportunities

### Opportunity 1: [Type - e.g., Extract Function]
**Location**: [file:line]
**Issue**: [What's wrong]
**Approach**: [How to refactor]
**Expected Improvement**: [Metric improvement]

[Repeat for each opportunity]

---

## Behavior Preservation Tests

**Existing Tests**: [N tests]
**Coverage**: [N%]
**Additional Tests Needed**: [Y/N - list if yes]

**Test Strategy**:
- Run full test suite before refactoring
- Verify 100% pass rate
- Run same tests after each refactor step
- Verify identical results

---

## Success Criteria

**Metrics Improvement Targets**:
- Complexity: [current] → [target]
- Duplication: [current] → [target]
- Test Coverage: [current] → [target]
- Maintainability: [current] → [target]

**Non-Negotiables**:
- ✅ All tests pass (before and after)
- ✅ No functional changes
- ✅ No performance regression
```

Write to `$BASELINE_METRICS`.

---

### 3. Create Refactor Specification

```markdown
# Refactor ${REFACTOR_NUM}: [Title]

**Status**: Active
**Created**: YYYY-MM-DD
**Baseline Metrics**: ${BASELINE_METRICS}

---

## Refactoring Goal

**What We're Improving**: [Brief description]

**Why**: [Motivation]
- Pain point 1
- Pain point 2

**Type**: [Extract Function/Reduce Complexity/Eliminate Duplication/Improve Naming/Optimize Performance]

---

## Target Code

**Location**: [file:line range]
**Current Issues**:
- Issue 1
- Issue 2

---

## Refactoring Plan

### Step 1: [Refactor Action]
**What**: [Description]
**Files**: [list]
**Validation**: [How to verify]

### Step 2: [Refactor Action]
[Repeat pattern]

---

## Behavior Preservation

**Critical**: No functional changes allowed

**Validation Strategy**:
1. Capture test suite results (before)
2. Apply refactoring step
3. Run test suite (after)
4. Compare results (must be identical)
5. Repeat for each step

---

## Expected Improvements

**Metrics**:
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Complexity | [N] | [Target] | [%] |
| Duplication | [N%] | [Target] | [%] |
| Maintainability | [N] | [Target] | [%] |

---

## Risks

| Risk | Mitigation |
|------|------------|
| [Risk 1] | [Mitigation] |

---

## Tech Stack Compliance

${TECH_STACK_VALIDATION}
```

Write to `$REFACTOR_SPEC`.

---

### 4. Generate Tasks

```markdown
# Tasks: Refactor ${REFACTOR_NUM}

**Workflow**: Refactor (Metrics-Driven, Behavior-Preserving)

---

## Phase 1: Baseline Establishment

### T001: Establish Baseline Metrics
**Description**: Run code analysis tools, capture metrics
**Validation**: Baseline documented in ${BASELINE_METRICS}

### T002: Run Full Test Suite (Baseline)
**Description**: Capture test results before refactoring
**Expected**: 100% pass rate (or document failures)
**Parallel**: No

---

## Phase 2: Incremental Refactoring

[For each refactoring step, create task sequence:]

### T003: Refactor Step 1 - [Description]
**Description**: [What's changing]
**Files**: [list]
**Validation**: Code compiles, no functional changes
**Parallel**: No (incremental steps)

### T004: Test Step 1
**Description**: Run test suite after step 1
**Expected**: Identical results to baseline
**Parallel**: No (depends on T003)

[Repeat T00N/T00N+1 pattern for each refactor step]

---

## Phase 3: Validation and Metrics

### T00N: Run Full Test Suite (Final)
**Description**: Verify all tests still pass
**Expected**: 100% pass rate, identical to baseline

### T00N+1: Measure Final Metrics
**Description**: Capture metrics after refactoring
**Expected**: Measurable improvement in target metrics
**Parallel**: [P]

### T00N+2: Compare Metrics
**Description**: Generate before/after comparison
**Expected**: Improvements meet success criteria
**Parallel**: No

---

## Summary

**Total Tasks**: [N]
**Refactoring Steps**: [N]
**Estimated Time**: [time]

**Success Criteria**:
- ✅ All tests pass (identical results before/after)
- ✅ Measurable metrics improvement
- ✅ No functional changes
- ✅ No performance regression
```

Write to `$TASKS_FILE`.

---

### 5. Execute Refactoring Workflow

Execute tasks incrementally with test validation after each step:

```
♻️  Executing Refactor Workflow

Phase 1: Baseline Establishment
T001: Establish Baseline Metrics
  [Analyze code, capture metrics]
  ✓ Baseline: Complexity=45, Duplication=12%, Maintainability=52

T002: Run Full Test Suite (Baseline)
  [Run tests]
  ✓ 247 tests passed

Phase 2: Incremental Refactoring
T003: Extract Function - processUserData
  [Apply refactoring]
T004: Test Step 1
  [Run tests]
  ✓ 247 tests passed (identical to baseline)

[Repeat for each refactoring step]

Phase 3: Validation and Metrics
T00N: Run Full Test Suite (Final)
  ✓ 247 tests passed (100% identical to baseline)

T00N+1: Measure Final Metrics
  ✓ Complexity=12 (was 45) - 73% improvement ✅
  ✓ Duplication=2% (was 12%) - 83% improvement ✅
  ✓ Maintainability=78 (was 52) - 50% improvement ✅

T00N+2: Compare Metrics
  ✓ All success criteria met
```

---

## Final Output

```
✅ Refactor Workflow Complete - Refactor ${REFACTOR_NUM}

📊 Metrics Improvement:
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Complexity | [N] | [N] | [%] ✅ |
| Duplication | [N%] | [N%] | [%] ✅ |
| Maintainability | [N] | [N] | [%] ✅ |

✅ Behavior Preservation:
- All tests passed (before and after)
- Identical test results
- No functional changes
- No performance regression

⏱️  Time to Refactor: ${DURATION}

📈 Next Steps:
1. Review: ${REFACTOR_SPEC}
2. Commit refactoring
3. Share metrics improvements with team
```

---

## Operating Principles

1. **Metrics First**: Establish measurable baseline
2. **Incremental**: Small, safe refactoring steps
3. **Test After Each Step**: Verify behavior preservation
4. **Measurable**: Quantify quality improvements
5. **No Functional Changes**: Behavior must be identical
6. **Tech Compliance**: Validate against tech stack

---

## Success Criteria

✅ Baseline metrics established
✅ Incremental refactoring steps completed
✅ All tests pass (before and after)
✅ Identical test results (behavior preserved)
✅ Measurable metrics improvement
✅ No performance regression
✅ Tech stack compliant

---

**Workflow Coverage**: Addresses ~10% of development work (quality improvement)
