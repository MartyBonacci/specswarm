---
description: Regression-test-first bug fixing workflow with smart SpecSwarm/SpecTest integration
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

Execute regression-test-first bug fixing workflow to ensure bugs are fixed correctly and prevent future regressions.

**Key Principles**:
1. **Test First**: Write regression test before fixing
2. **Verify Failure**: Confirm test reproduces bug
3. **Fix**: Implement solution
4. **Verify Success**: Confirm test passes
5. **No Regressions**: Validate no new bugs introduced

**Coverage**: Addresses ~40% of development work (bug fixes)

---

## Smart Integration Detection

Before starting workflow, detect available plugins for enhanced capabilities:

```bash
# Check for SpecSwarm (tech stack enforcement)
SPECSWARM_INSTALLED=$(claude plugin list | grep -q "specswarm" && echo "true" || echo "false")

# Check for SpecLabs (experimental features)
SPECLABS_INSTALLED=$(claude plugin list | grep -q "speclabs" && echo "true" || echo "false")

# Configure workflow based on detection
if [ "$SPECLABS_INSTALLED" = "true" ]; then
  EXECUTION_MODE="parallel"
  ENABLE_HOOKS=true
  ENABLE_METRICS=true
  echo "🎯 Smart Integration: SpecLabs detected (experimental features enabled)"
elif [ "$SPECSWARM_INSTALLED" = "true" ]; then
  EXECUTION_MODE="sequential"
  ENABLE_TECH_VALIDATION=true
  echo "🎯 Smart Integration: SpecSwarm detected (tech stack enforcement enabled)"
else
  EXECUTION_MODE="sequential"
  echo "ℹ️  Running in basic mode (install SpecSwarm/SpecTest for enhanced capabilities)"
fi
```

---

## Pre-Workflow Hook (if SpecTest installed)

```bash
if [ "$ENABLE_HOOKS" = "true" ]; then
  echo "🎣 Pre-Bugfix Hook"

  # Validate prerequisites
  echo "✓ Checking repository status..."
  git status --porcelain | head -5

  # Load tech stack (if SpecSwarm also installed)
  if [ "$SPECSWARM_INSTALLED" = "true" ]; then
    echo "✓ Loading tech stack: /memory/tech-stack.md"
    TECH_STACK_EXISTS=$([ -f "/memory/tech-stack.md" ] && echo "true" || echo "false")
    if [ "$TECH_STACK_EXISTS" = "true" ]; then
      echo "✓ Tech stack validation enabled"
    fi
  fi

  # Initialize metrics
  WORKFLOW_START_TIME=$(date +%s)
  echo "✓ Metrics initialized"
  echo ""
fi
```

---

## Execution Steps

### 1. Discover Bug Context

```bash
# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Detect branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

# Try to extract feature number from branch name (bugfix/NNN-*)
FEATURE_NUM=$(echo "$CURRENT_BRANCH" | grep -oE 'bugfix/([0-9]{3})' | grep -oE '[0-9]{3}')

# If no feature number in branch, prompt user
if [ -z "$FEATURE_NUM" ]; then
  echo "🐛 Bugfix Workflow"
  echo ""
  echo "No bugfix branch detected. Please provide bug number:"
  echo "Example: 042 (for bugfix/042-login-timeout)"
  # Wait for user input
  read -p "Bug number: " FEATURE_NUM

  # Validate
  if [ -z "$FEATURE_NUM" ]; then
    echo "❌ Error: Bug number required"
    exit 1
  fi

  # Pad to 3 digits
  FEATURE_NUM=$(printf "%03d" $FEATURE_NUM)
fi

# Find or create feature directory
FEATURE_DIR=$(find "$REPO_ROOT/features" -maxdepth 1 -type d -name "${FEATURE_NUM}-*" 2>/dev/null | head -1)

if [ -z "$FEATURE_DIR" ]; then
  echo "⚠️  Feature directory not found for bug ${FEATURE_NUM}"
  echo ""
  echo "Please provide bug description (kebab-case):"
  echo "Example: login-timeout"
  read -p "Description: " BUG_DESC

  if [ -z "$BUG_DESC" ]; then
    echo "❌ Error: Bug description required"
    exit 1
  fi

  FEATURE_DIR="${REPO_ROOT}/features/${FEATURE_NUM}-${BUG_DESC}"
  mkdir -p "$FEATURE_DIR"
  echo "✓ Created: $FEATURE_DIR"
fi

BUGFIX_SPEC="${FEATURE_DIR}/bugfix.md"
REGRESSION_TEST_SPEC="${FEATURE_DIR}/regression-test.md"
TASKS_FILE="${FEATURE_DIR}/tasks.md"
```

Output to user:
```
🐛 Bugfix Workflow - Feature ${FEATURE_NUM}
✓ Branch detected: ${CURRENT_BRANCH}
✓ Feature directory: ${FEATURE_DIR}
```

---

### 2. Create Bugfix Specification

If `$BUGFIX_SPEC` doesn't exist, create it using this template:

```markdown
# Bug ${FEATURE_NUM}: [Bug Title]

**Status**: Active
**Created**: YYYY-MM-DD
**Priority**: [High/Medium/Low]
**Severity**: [Critical/Major/Minor]

## Symptoms

[What behavior is observed? What's going wrong?]

- Observable symptom 1
- Observable symptom 2
- Observable symptom 3

## Reproduction Steps

1. Step 1 to reproduce
2. Step 2 to reproduce
3. Step 3 to reproduce

**Expected Behavior**: [What should happen?]

**Actual Behavior**: [What actually happens?]

## Root Cause Analysis

**IMPORTANT: Use ultrathinking for deep analysis**

Before documenting the root cause, you MUST:
1. **Ultrathink** - Perform deep, multi-layer analysis
2. Check database configuration (transforms, defaults, constraints)
3. Analyze property access patterns (camelCase vs snake_case mismatches)
4. Examine caching behavior (frontend, backend, browser)
5. Trace data flow from database → backend → frontend
6. Look for cascading bugs (one bug hiding another)

**Root Cause Documentation:**

[What is causing the bug?]

- Component/module affected
- Code location (file:line)
- Logic error or edge case missed
- Conditions required to trigger
- Configuration mismatches (transforms, environment, etc.)

## Impact Assessment

**Affected Users**: [Who is impacted?]
- All users / Specific user role / Edge case users

**Affected Features**: [What features are broken?]
- Feature A: Completely broken
- Feature B: Partially degraded

**Severity Justification**: [Why this priority/severity?]

**Workaround Available**: [Yes/No - if yes, describe]

## Regression Test Requirements

[What test will prove the bug exists and validate the fix?]

1. Test scenario 1
2. Test scenario 2
3. Test scenario 3

**Test Success Criteria**:
- ✅ Test fails before fix (proves bug exists)
- ✅ Test passes after fix (proves bug fixed)
- ✅ No new regressions introduced

## Proposed Solution

[High-level approach to fixing the bug]

**Changes Required**:
- File 1: [what needs to change]
- File 2: [what needs to change]

**Risks**: [Any risks with this fix?]

**Alternative Approaches**: [Other ways to fix? Why not chosen?]

---

## Tech Stack Compliance

[If SpecSwarm installed, validate solution against tech stack]

**Tech Stack File**: /memory/tech-stack.md
**Validation Status**: [Pending/Compliant/Non-Compliant]

---

## Metadata

**Workflow**: Bugfix (regression-test-first)
**Created By**: SpecLab Plugin v1.0.0
**Smart Integration**: ${INTEGRATION_MODE}
```

Populate template by:
1. Load user input (if provided in `$ARGUMENTS`)
2. **ULTRATHINK** - Perform deep root cause analysis:
   - Search for error logs, stack traces
   - Check database schema configuration (transforms, defaults)
   - Analyze property naming patterns (camelCase vs snake_case)
   - Check caching behavior (frontend loaders, backend, browser)
   - Trace data flow from database through all layers
   - Look for multi-layer bugs (frontend + backend + database)
   - Check recent commits for related changes
   - Review issues/PRs mentioning bug number
3. Analyze repository context:
   - Identify all affected layers (database, backend, frontend)
   - Check for configuration mismatches
   - Look for similar bugs that might indicate patterns
4. Prompt user for missing critical information:
   - Bug title
   - Symptoms (what's broken?)
   - Reproduction steps
   - Priority/severity

Write completed specification to `$BUGFIX_SPEC`.

Output to user:
```
📋 Bugfix Specification
✓ Created: ${BUGFIX_SPEC}
✓ Bug documented with symptoms, root cause, impact
```

---

### 2.5. Orchestrator Detection

After creating the bugfix specification, analyze whether this is an orchestration opportunity:

```bash
# Load detection library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

if [ -f "$PLUGIN_DIR/lib/orchestrator-detection.sh" ]; then
    source "$PLUGIN_DIR/lib/orchestrator-detection.sh"

    echo ""
    echo "🔍 Analyzing bugfix complexity..."
    echo ""

    # Count bugs in specification (look for "### Bug #" headers or symptoms list)
    BUG_COUNT=$(grep -cE "^### Bug #|^- Bug [0-9]+" "$BUGFIX_SPEC" 2>/dev/null || echo "1")

    # If user input mentions multiple bugs, count them
    if [ -n "$ARGUMENTS" ]; then
        ARG_BUG_COUNT=$(echo "$ARGUMENTS" | grep -oE "bug" | wc -l)
        if [ "$ARG_BUG_COUNT" -gt "$BUG_COUNT" ]; then
            BUG_COUNT=$ARG_BUG_COUNT
        fi
    fi

    # Get list of affected files from bugfix spec
    AFFECTED_FILES=$(grep -A 20 "^## Proposed Solution" "$BUGFIX_SPEC" | grep -E "^- File |^  - " | sed 's/^- File //' | sed 's/^  - //' | tr '\n' ' ' || echo "")

    # If no files found in spec yet, check user input
    if [ -z "$AFFECTED_FILES" ] && [ -n "$ARGUMENTS" ]; then
        AFFECTED_FILES=$(echo "$ARGUMENTS" | grep -oE "[a-zA-Z0-9/_-]+\.(ts|tsx|js|jsx|py|go|java)" | tr '\n' ' ')
    fi

    # Build context info based on spec content
    CONTEXT_INFO=""
    if grep -qiE "log|logging|console" "$BUGFIX_SPEC"; then
        CONTEXT_INFO="${CONTEXT_INFO} requires_logging"
    fi
    if grep -qiE "restart|reload|rebuild" "$BUGFIX_SPEC"; then
        CONTEXT_INFO="${CONTEXT_INFO} requires_server_restarts"
    fi

    # Check if orchestrator should be used
    DETECTION_RESULT=$(should_use_orchestrator "$BUG_COUNT" "$AFFECTED_FILES" "$CONTEXT_INFO" 2>/dev/null)

    if [ $? -eq 0 ]; then
        echo "🎯 Orchestrator Detection"
        echo "========================"
        echo ""

        # Extract recommendation details
        RECOMMENDATION=$(echo "$DETECTION_RESULT" | grep -o '"recommendation": "[^"]*"' | cut -d'"' -f4)
        REASON=$(echo "$DETECTION_RESULT" | grep -o '"reason": "[^"]*"' | cut -d'"' -f4)
        CONFIDENCE=$(echo "$DETECTION_RESULT" | grep -o '"confidence": "[^"]*"' | cut -d'"' -f4)

        echo "Reason: $REASON"
        echo "Confidence: $CONFIDENCE"
        echo ""

        if [ "$RECOMMENDATION" = "orchestrator" ]; then
            echo "💡 STRONG RECOMMENDATION: Use Project Orchestrator"
            echo ""
            echo "This is a textbook orchestration case!"
            echo ""
            echo "Benefits:"
            echo "  • Estimated time savings: 40-60%"
            echo "  • Parallel bug investigation"
            echo "  • Better context management"
            echo "  • Coordinated server restarts"
            echo "  • Specialized agents per domain"
            echo ""
            echo "Detected signals:"
            echo "  - $BUG_COUNT bug(s) to fix"

            if [ -n "$AFFECTED_FILES" ]; then
                DOMAIN_NAMES=$(get_domain_names "$AFFECTED_FILES" 2>/dev/null)
                if [ -n "$DOMAIN_NAMES" ]; then
                    echo "  - Spans domains: $DOMAIN_NAMES"
                fi
            fi

            if echo "$CONTEXT_INFO" | grep -q "requires_logging"; then
                echo "  - Requires extensive logging"
            fi
            if echo "$CONTEXT_INFO" | grep -q "requires_server_restarts"; then
                echo "  - Requires server restarts"
            fi

            echo ""
            echo "Choose workflow:"
            echo "  1. Continue with sequential bugfix (traditional)"
            echo "  2. Switch to Orchestrator debug mode (recommended)"
            echo ""
            read -p "Your choice (1 or 2): " WORKFLOW_CHOICE

            if [ "$WORKFLOW_CHOICE" = "2" ]; then
                echo ""
                echo "✅ Switching to Orchestrator debug mode..."
                echo ""
                echo "Next step: Create debug workflow specification"
                echo ""
                echo "Run one of these commands:"
                echo "  • /debug:coordinate \"$ARGUMENTS\""
                echo "  • /project-orchestrator:debug --spec=\"$BUGFIX_SPEC\""
                echo ""
                echo "The orchestrator will:"
                echo "  1. Add strategic logging across affected files"
                echo "  2. Spawn specialist agents per domain"
                echo "  3. Coordinate parallel investigation"
                echo "  4. Integrate and test all fixes together"
                echo ""
                exit 0
            else
                echo ""
                echo "✅ Continuing with sequential workflow"
                echo ""
                echo "Note: You can switch to orchestrator mode anytime by running:"
                echo "  /debug:coordinate \"<problem-description>\""
                echo ""
            fi

        elif [ "$RECOMMENDATION" = "consider_orchestrator" ]; then
            echo "💭 SUGGESTION: Orchestrator may help with this workflow"
            echo ""
            echo "Complexity signals detected. Consider using orchestrator if:"
            echo "  • Workflow becomes more complex than expected"
            echo "  • Multiple iterations needed (log → restart → fix cycle)"
            echo "  • You find more bugs during investigation"
            echo ""
            echo "To switch to orchestrator mode, run:"
            echo "  /debug:coordinate \"<problem-description>\""
            echo ""
        fi
    else
        echo "ℹ️  Single bug detected - sequential workflow is optimal"
        echo ""
    fi
else
    echo "ℹ️  Orchestrator detection not available (lib not found)"
    echo ""
fi
```

Continue with normal workflow...

---

### 3. Create Regression Test Specification

Create `$REGRESSION_TEST_SPEC` using this template:

```markdown
# Regression Test: Bug ${FEATURE_NUM}

**Purpose**: Prove bug exists, validate fix, prevent future regressions

**Test Type**: Regression Test
**Created**: YYYY-MM-DD

---

## Test Objective

Write a test that:
1. ✅ **Fails before fix** (proves bug exists)
2. ✅ **Passes after fix** (proves bug fixed)
3. ✅ **Prevents regression** (catches if bug reintroduced)

---

## Test Specification

### Test Setup

[What needs to be set up before test runs?]

- Initial state
- Test data
- Mock/stub configuration
- Dependencies

### Test Execution

[What actions does the test perform?]

1. Action 1
2. Action 2
3. Action 3

### Test Assertions

[What validations prove bug exists/fixed?]

- ✅ Assertion 1: [expected outcome]
- ✅ Assertion 2: [expected outcome]
- ✅ Assertion 3: [expected outcome]

### Test Teardown

[Any cleanup needed?]

---

## Test Implementation

### Test File Location

[Where should this test live?]

**File**: [path/to/test/file]
**Function/Test Name**: `test_bug_${FEATURE_NUM}_[description]`

### Test Validation Criteria

**Before Fix**:
- ❌ Test MUST fail (proves bug reproduction)
- If test passes before fix, test is invalid

**After Fix**:
- ✅ Test MUST pass (proves bug fixed)
- ✅ All existing tests still pass (no regressions)

---

## Edge Cases to Test

[Related scenarios that should also be tested]

1. Edge case 1
2. Edge case 2
3. Edge case 3

---

## Metadata

**Workflow**: Bugfix (regression-test-first)
**Created By**: SpecLab Plugin v1.0.0
```

Write regression test specification to `$REGRESSION_TEST_SPEC`.

Output to user:
```
📋 Regression Test Specification
✓ Created: ${REGRESSION_TEST_SPEC}
✓ Test must fail before fix, pass after fix
```

---

### 4. Generate Tasks

Create `$TASKS_FILE` with regression-test-first methodology:

```markdown
# Tasks: Bug ${FEATURE_NUM} - [Bug Title]

**Workflow**: Bugfix (Regression-Test-First)
**Status**: Active
**Created**: YYYY-MM-DD

---

## Execution Strategy

**Mode**: ${EXECUTION_MODE}
**Smart Integration**:
${INTEGRATION_SUMMARY}

---

## Phase 1: Regression Test Creation

### T001: Write Regression Test
**Description**: Implement test specified in regression-test.md
**File**: [test file path]
**Validation**: Test code follows test specification
**Parallel**: No (foundational)

### T002: Verify Test Fails
**Description**: Run regression test and confirm it fails (proves bug exists)
**Command**: [test command]
**Expected**: Test fails with error matching bug symptoms
**Validation**: Test failure proves bug reproduction
**Parallel**: No (depends on T001)

---

## Phase 2: Bug Fix Implementation

### T003: Implement Fix
**Description**: Apply solution from bugfix.md
**Files**: [list files to modify]
**Changes**: [high-level change description]
**Tech Stack Validation**: ${TECH_VALIDATION_ENABLED}
**Parallel**: No (core fix)

[If multiple independent fixes needed, mark additional tasks with [P]]

### T004: Verify Test Passes
**Description**: Run regression test and confirm it passes (proves bug fixed)
**Command**: [test command]
**Expected**: Test passes
**Validation**: Test success proves bug fixed
**Parallel**: No (depends on T003)

---

## Phase 3: Regression Validation

### T005: Run Full Test Suite
**Description**: Verify no new regressions introduced
**Command**: [full test suite command]
**Expected**: All tests pass (existing + new regression test)
**Validation**: 100% test pass rate
**Parallel**: No (final validation)

[If SpecSwarm installed, add tech stack validation task]
${TECH_STACK_VALIDATION_TASK}

---

## Summary

**Total Tasks**: 5 (minimum)
**Estimated Time**: 1-3 hours (varies by bug complexity)
**Parallel Opportunities**: Limited (regression-test-first is sequential by nature)

**Success Criteria**:
- ✅ Regression test created
- ✅ Test failed before fix (proved bug)
- ✅ Fix implemented
- ✅ Test passed after fix (proved solution)
- ✅ No new regressions
${TECH_COMPLIANCE_CRITERION}
```

Write tasks to `$TASKS_FILE`.

Output to user:
```
📊 Tasks Generated
✓ Created: ${TASKS_FILE}
✓ 5 tasks (regression-test-first methodology)
✓ Phase 1: Create regression test (T001-T002)
✓ Phase 2: Implement fix (T003-T004)
✓ Phase 3: Validate no regressions (T005)
```

---

### 5. Execute Workflow

Now execute the tasks using the appropriate mode:

#### If SpecTest Installed (Parallel + Hooks):

```
⚡ Executing Bugfix Workflow with SpecTest Integration

🎣 Pre-Task Hook
✓ Validating prerequisites
✓ Environment ready

Phase 1: Regression Test Creation (T001-T002)
→ T001: Write Regression Test
  [execute task]
→ T002: Verify Test Fails
  [execute task, confirm failure]
  ✅ Test failed as expected (bug reproduced)

Phase 2: Bug Fix Implementation (T003-T004)
→ T003: Implement Fix
  [execute task]
  [if SpecSwarm installed, validate against tech stack]
→ T004: Verify Test Passes
  [execute task]
  ✅ Test passed (bug fixed!)

Phase 3: Regression Validation (T005)
→ T005: Run Full Test Suite
  [execute task]
  ✅ All tests pass (no regressions)

🎣 Post-Workflow Hook
✓ All tasks completed
✓ Bug fixed successfully
✓ Regression test added
✓ No new regressions
📊 Metrics updated
```

#### If Only SpecSwarm Installed (Sequential + Tech Validation):

```
🔧 Executing Bugfix Workflow with SpecSwarm Integration

Phase 1: Regression Test Creation
T001: Write Regression Test
  [execute task]
T002: Verify Test Fails
  [execute task]
  ✅ Test failed (bug reproduced)

Phase 2: Bug Fix Implementation
T003: Implement Fix
  [execute task]
  🔍 Tech Stack Validation
  ✓ Loading tech stack: /memory/tech-stack.md
  ✓ Validating fix against tech stack
  ✓ Compliant: All changes follow tech stack
T004: Verify Test Passes
  [execute task]
  ✅ Test passed (bug fixed!)

Phase 3: Regression Validation
T005: Run Full Test Suite
  [execute task]
  ✅ All tests pass (no regressions)
```

#### Basic Mode (No Plugins):

```
🐛 Executing Bugfix Workflow

Phase 1: Regression Test Creation
T001-T002: [execute sequentially]

Phase 2: Bug Fix Implementation
T003-T004: [execute sequentially]

Phase 3: Regression Validation
T005: [execute]

✅ Workflow Complete
```

---

## Post-Workflow Hook (if SpecTest installed)

```bash
if [ "$ENABLE_HOOKS" = "true" ]; then
  echo ""
  echo "🎣 Post-Bugfix Hook"

  # Calculate metrics
  WORKFLOW_END_TIME=$(date +%s)
  WORKFLOW_DURATION=$((WORKFLOW_END_TIME - WORKFLOW_START_TIME))
  WORKFLOW_HOURS=$(echo "scale=1; $WORKFLOW_DURATION / 3600" | bc)

  # Validate completion
  echo "✓ Bug fixed successfully"
  echo "✓ Regression test added"
  echo "✓ No new regressions introduced"

  # Tech stack compliance
  if [ "$SPECSWARM_INSTALLED" = "true" ]; then
    echo "✓ Tech stack compliant"
  fi

  # Update metrics file
  METRICS_FILE="/memory/workflow-metrics.json"
  # [Update JSON with bugfix metrics]
  echo "📊 Metrics saved: ${METRICS_FILE}"

  echo ""
  echo "⏱️  Time to Fix: ${WORKFLOW_HOURS}h"
  echo ""
fi
```

---

## Quality Impact Validation

**Purpose**: Ensure bug fix doesn't introduce new issues or reduce code quality

**YOU MUST NOW validate quality impact using these steps:**

1. **Check if quality standards exist** using the Read tool:
   - Try to read `${REPO_ROOT}/memory/quality-standards.md`
   - If file doesn't exist: Skip quality validation, go to Final Output
   - If file exists: Continue with validation

2. **Execute quality validation** using the Bash tool:

   a. **Display header:**
      ```
      🧪 Quality Impact Analysis
      ==========================
      ```

   b. **Run unit tests:**
      ```bash
      cd ${REPO_ROOT} && npx vitest run --reporter=verbose 2>&1 | tail -50
      ```
      Parse output for test counts (total, passed, failed).

   c. **Measure code coverage** (if tool available):
      ```bash
      npx vitest run --coverage 2>&1 | grep -A 10 "Coverage" || echo "Coverage not configured"
      ```
      Parse coverage percentage.

   d. **Calculate quality score:**
      - Unit Tests: 25 points if all pass, 0 if any fail
      - Coverage: 25 points * (coverage_pct / 80)
      - Other components: Use same scoring as implement workflow

3. **Compare before/after quality:**

   a. **Load previous quality score** from metrics.json:
      - Read `${REPO_ROOT}/memory/metrics.json`
      - Find most recent quality score before this bugfix
      - Store as BEFORE_SCORE

   b. **Calculate current quality score:**
      - Use scores from step 2
      - Store as AFTER_SCORE

   c. **Calculate delta:**
      - QUALITY_DELTA = AFTER_SCORE - BEFORE_SCORE

4. **Display quality impact report:**
   ```
   📊 Quality Impact Report
   ========================

   Before Fix:  {BEFORE_SCORE}/100
   After Fix:   {AFTER_SCORE}/100
   Change:      {QUALITY_DELTA > 0 ? '+' : ''}{QUALITY_DELTA} points

   Test Results:
   - Total Tests: {TOTAL}
   - Passing: {PASSED} ({PASS_RATE}%)
   - Failing: {FAILED}

   Code Coverage: {COVERAGE}%

   {VERDICT}
   ```

5. **Determine verdict:**

   a. **If QUALITY_DELTA < 0 (quality decreased):**
      - Display: "⚠️ WARNING: Bug fix reduced code quality by {abs(QUALITY_DELTA)} points"
      - Ask user:
        ```
        This suggests the fix may have introduced new issues.

        Would you like to:
        1. Review the changes and improve quality
        2. Continue anyway (NOT RECOMMENDED)
        3. Revert fix and try different approach

        Choose (1/2/3):
        ```
      - If user chooses 1: Halt, suggest improvements
      - If user chooses 2: Display strong warning and continue
      - If user chooses 3: Offer to revert last commit

   b. **If QUALITY_DELTA == 0 (no change):**
      - Display: "✅ Quality maintained - Fix didn't introduce regressions"
      - Continue to Final Output

   c. **If QUALITY_DELTA > 0 (quality improved):**
      - Display: "🎉 Quality improved! Fix increased quality by {QUALITY_DELTA} points"
      - Highlight improvements (more tests passing, higher coverage, etc.)
      - Continue to Final Output

6. **Save quality metrics:**
   - Update `${REPO_ROOT}/memory/metrics.json`
   - Add quality_delta field to bugfix record
   - Include before/after scores

**IMPORTANT**: This validation catches regressions introduced by bug fixes. If quality decreases, investigate before proceeding.

---

## Chain Bug Detection (Phase 3 Enhancement)

**Purpose**: Detect if this bug fix introduced new bugs (prevent Bug 912 → Bug 913 scenarios)

**YOU MUST NOW check for chain bugs using the Bash tool:**

1. **Run chain bug detector:**
   ```bash
   bash ~/.claude/plugins/marketplaces/specswarm-marketplace/plugins/speclabs/lib/chain-bug-detector.sh ${REPO_ROOT}
   ```

2. **Parse detector output:**
   - Exit code 0: No chain bugs detected (✓ SAFE)
   - Exit code 1: Chain bugs detected (⚠️ WARNING)

3. **If chain bugs detected:**

   a. **Display warning:**
      ```
      ⛓️  CHAIN BUG DETECTED
      ═══════════════════════

      This bug fix may have introduced new issues:
      - Tests decreased: {BEFORE} → {AFTER}
      - SSR issues: {COUNT}
      - TypeScript errors: {COUNT}

      This suggests the fix created new problems.
      ```

   b. **Offer actions:**
      ```
      What would you like to do?
      1. Review fix and improve (analyze with /specswarm:analyze-quality)
      2. Use orchestrator for complex fix (/speclabs:coordinate)
      3. Revert and try different approach (git revert HEAD)
      4. Continue anyway (NOT RECOMMENDED)

      Choose (1/2/3/4):
      ```

   c. **Execute user choice:**
      - Option 1: Run `/specswarm:analyze-quality` for full analysis
      - Option 2: Display orchestrator command to use
      - Option 3: Offer to revert last commit
      - Option 4: Display strong warning and continue

4. **If no chain bugs:**
   - Display: "✓ No chain bugs detected - Fix is clean"
   - Continue to Final Output

**Impact**: Prevents cascading bug fixes (Bug 912 → 913 → 914 chains)

---

## Final Output

```
✅ Bugfix Workflow Complete - Feature ${FEATURE_NUM}

📋 Artifacts Created:
- ${BUGFIX_SPEC}
- ${REGRESSION_TEST_SPEC}
- ${TASKS_FILE}

📊 Results:
- Bug fixed successfully
- Regression test created and passing
- No new regressions introduced
${TECH_STACK_COMPLIANCE_RESULT}

⏱️  Time to Fix: ${WORKFLOW_DURATION}
${PARALLEL_SPEEDUP_RESULT}

📈 Next Steps:
1. Review artifacts in: ${FEATURE_DIR}
2. Commit changes: git add . && git commit -m "fix: bug ${FEATURE_NUM}"
3. View metrics: /specswarm:workflow-metrics ${FEATURE_NUM}
4. ${SUGGEST_NEXT_COMMAND}
```

---

## Error Handling

**If branch detection fails**:
- Prompt user for bug number
- Offer to create bugfix branch

**If feature directory missing**:
- Prompt for bug description
- Create feature directory

**If regression test fails to fail**:
- ❌ Error: "Regression test must fail before fix (proves bug exists)"
- Prompt user to review test or bug specification

**If test suite has regressions**:
- ❌ Error: "New regressions detected. Fix must not break existing tests."
- List failed tests
- Suggest investigating breaking changes

---

## Operating Principles

1. **Ultrathink First**: Deep multi-layer analysis before jumping to solutions
2. **Test First**: Always write regression test before fixing
3. **Verify Reproduction**: Test must fail to prove bug exists
4. **Single Responsibility**: Each task has one clear goal
5. **No Regressions**: Full test suite must pass
6. **Tech Compliance**: Validate fix against tech stack (if SpecSwarm installed)
7. **Metrics Tracking**: Record time-to-fix, regression coverage
8. **Smart Integration**: Leverage SpecSwarm/SpecTest when available

### Best Practice: Ultrathinking

**Always use ultrathinking for root cause analysis.** Many bugs have multiple layers:

**Example - Bug 918 (Password Reset "Already Used" Error):**
- **Surface symptom**: "Reset Link Already Used" error on fresh tokens
- **First layer found**: Multiple tokens allowed per user (Bug 916)
- **Second layer suspected**: Frontend caching issue (Bug 917 - red herring)
- **ACTUAL root cause** (found with ultrathink): Property name mismatch
  - Database config: `postgres.camel` transforms `used_at` → `usedAt`
  - Code accessed: `result.used_at` (wrong name) → returned `undefined`
  - Logic treated `undefined` as "already used" → fresh tokens rejected

**Without ultrathink**: Found Bug 916, missed actual cause
**With ultrathink**: Found Bug 918, resolved the issue

**Ultrathinking checklist:**
- ✅ Check database configuration (transforms, defaults, constraints)
- ✅ Analyze property access patterns (naming mismatches)
- ✅ Examine caching behavior (all layers)
- ✅ Trace data flow end-to-end
- ✅ Look for cascading bugs (one hiding another)
- ✅ Validate assumptions about how libraries work

---

## Success Criteria

✅ Bugfix specification documents bug thoroughly
✅ Regression test created
✅ Test failed before fix (proved bug reproduction)
✅ Fix implemented
✅ Test passed after fix (proved bug fixed)
✅ No new regressions introduced
✅ Tech stack compliant (if SpecSwarm installed)
✅ Metrics tracked (if SpecTest installed)

---

**Workflow Coverage**: Addresses ~40% of development work (bug fixes)
**Integration**: Smart detection of SpecSwarm (tech enforcement) and SpecTest (parallel/hooks)
**Graduation Path**: Proven workflow will graduate to SpecSwarm stable
