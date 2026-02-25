---
description: Fix bugs with test-driven approach and automatic retry - simplified bugfix workflow
args:
  - name: bug_description
    description: Natural language description of the bug to fix
    required: true
  - name: --regression-test
    description: Create failing test first (TDD approach - recommended)
    required: false
  - name: --hotfix
    description: Use expedited hotfix workflow for production issues
    required: false
  - name: --max-retries
    description: Maximum fix retry attempts (default 2)
    required: false
  - name: --background
    description: Run fix in background, return session ID for tracking
    required: false
  - name: --notify
    description: Play sound when complete (requires notifier plugin)
    required: false
  - name: --coordinate
    description: Multi-bug orchestrated debugging with logging, monitoring, and specialist agents
    required: false
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Fix bugs using a test-driven approach with automatic retry logic for failed fixes.

**Purpose**: Streamline bug fixing by combining bugfix workflow with retry logic and optional regression testing.

**Workflow**:
- **Standard**: Bugfix → Verify → (Retry if needed)
- **With --regression-test**: Create Test → Verify Fails → Bugfix → Verify Passes
- **With --hotfix**: Expedited workflow for production issues

**User Experience**:
- Single command instead of manual bugfix + validation
- Automatic retry if fix doesn't work
- Test-first approach ensures regression prevention
- Ready for final merge with `/specswarm:ship`

---

## Pre-Flight Checks

```bash
# Parse arguments
BUG_DESC=""
REGRESSION_TEST=false
HOTFIX=false
MAX_RETRIES=2
BACKGROUND_MODE=false
NOTIFY_ON_COMPLETE=false
COORDINATE_MODE=false

# Extract bug description (first non-flag argument)
for arg in $ARGUMENTS; do
  if [ "${arg:0:2}" != "--" ] && [ -z "$BUG_DESC" ]; then
    BUG_DESC="$arg"
  elif [ "$arg" = "--regression-test" ]; then
    REGRESSION_TEST=true
  elif [ "$arg" = "--hotfix" ]; then
    HOTFIX=true
  elif [ "$arg" = "--max-retries" ]; then
    shift
    MAX_RETRIES="$1"
  elif [ "$arg" = "--background" ]; then
    BACKGROUND_MODE=true
  elif [ "$arg" = "--notify" ]; then
    NOTIFY_ON_COMPLETE=true
  elif [ "$arg" = "--coordinate" ]; then
    COORDINATE_MODE=true
  fi
done

# Validate bug description
if [ -z "$BUG_DESC" ]; then
  echo "❌ Error: Bug description required"
  echo ""
  echo "Usage: /specswarm:fix \"bug description\" [options]"
  echo ""
  echo "Options:"
  echo "  --regression-test  Create failing test first (TDD approach)"
  echo "  --hotfix           Expedited workflow for production issues"
  echo "  --max-retries N    Maximum fix retry attempts (default 2)"
  echo "  --coordinate       Multi-bug orchestrated debugging"
  echo "  --background       Run fix in background mode"
  echo ""
  echo "Examples:"
  echo "  /specswarm:fix \"Login fails with special characters in password\""
  echo "  /specswarm:fix \"Cart total incorrect with discounts\" --regression-test"
  echo "  /specswarm:fix \"Production API timeout\" --hotfix"
  echo "  /specswarm:fix \"Memory leak in dashboard\" --regression-test --max-retries 3"
  echo "  /specswarm:fix \"navbar broken, sign-out fails, like button error\" --coordinate"
  exit 1
fi

# Get project root
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "❌ Error: Not in a git repository"
  exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

# Create session tracking for background mode
mkdir -p .specswarm/sessions
SESSION_ID="fix-$(date +%Y%m%d-%H%M%S)"

cat > ".specswarm/sessions/${SESSION_ID}.json" << EOF
{
  "type": "fix",
  "session_id": "$SESSION_ID",
  "bug_description": "$BUG_DESC",
  "started_at": "$(date -Iseconds 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S%z")",
  "status": "running",
  "regression_test": $REGRESSION_TEST,
  "hotfix": $HOTFIX,
  "max_retries": $MAX_RETRIES,
  "current_retry": 0,
  "background_mode": $BACKGROUND_MODE,
  "notify_on_complete": $NOTIFY_ON_COMPLETE,
  "coordinate_mode": $COORDINATE_MODE
}
EOF

# If background mode, show session info
if [ "$BACKGROUND_MODE" = true ]; then
  echo ""
  echo "🔄 Fix started in background mode"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Session ID: $SESSION_ID"
  echo "Bug: $BUG_DESC"
  echo ""
  echo "Track progress with:"
  echo "  /specswarm:status $SESSION_ID"
  echo ""
  if [ "$NOTIFY_ON_COMPLETE" = true ]; then
    echo "You will be notified when complete."
  fi
  echo ""
fi
```

---

## Environment Detection

Detect available capabilities before starting workflow:

```bash
# Get plugin directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

# Detect web project and Chrome DevTools MCP availability
CHROME_DEVTOOLS_MODE="disabled"
WEB_FRAMEWORK=""

if [ -f "$PLUGIN_DIR/lib/web-project-detector.sh" ]; then
  source "$PLUGIN_DIR/lib/web-project-detector.sh"

  # Check if Chrome DevTools MCP should be used
  if should_use_chrome_devtools "$REPO_ROOT"; then
    CHROME_DEVTOOLS_MODE="enabled"
  elif is_web_project "$REPO_ROOT"; then
    CHROME_DEVTOOLS_MODE="fallback"
  fi
fi
```

---

## Coordinate Mode (--coordinate)

**IF COORDINATE_MODE = true**, switch to orchestrated multi-bug debugging workflow instead of the standard sequential fix flow.

```bash
if [ "$COORDINATE_MODE" = true ]; then
  echo "🐛 SpecSwarm Fix - Coordinated Multi-Bug Debugging"
  echo "══════════════════════════════════════════"
  echo ""
  echo "Bug Report: $BUG_DESC"
  echo ""

  # Parse individual issues from the bug description
  BUG_COUNT=$(echo "$BUG_DESC" | tr ',' '\n' | tr ';' '\n' | grep -v '^$' | wc -l)

  echo "Identified $BUG_COUNT potential issue(s)"
  echo ""

  # Create debug session directory
  DEBUG_SESSION_ID=$(date +%Y%m%d-%H%M%S)
  DEBUG_DIR="${REPO_ROOT}/.debug-sessions/${DEBUG_SESSION_ID}"
  mkdir -p "$DEBUG_DIR"

  echo "Debug session: $DEBUG_SESSION_ID"
  echo "Directory: $DEBUG_DIR"
  echo ""
  echo "This workflow will:"
  echo "  1. Parse and categorize each bug"
  echo "  2. Analyze root causes and affected domains"
  echo "  3. Generate logging strategy for diagnostics"
  echo "  4. Orchestrate parallel fixes with specialist agents"
  echo "  5. Verify all fixes and check for regressions"
  echo ""
fi
```

**IF COORDINATE_MODE = true:**

1. **Parse individual bugs** from the description (comma/semicolon separated)
2. **Analyze each bug** to identify affected files, domains, and root causes
3. **Group by domain** (frontend, backend, database, etc.) for parallel assignment
4. **For 3+ bugs**: Launch parallel Task agents (specialist-routed) for each independent bug
5. **For 1-2 bugs**: Fix sequentially using `/specswarm:bugfix`
6. **After all fixes**: Run full test suite, create verification checklist
7. **Generate report** with fix summary, files modified, and test results

```bash
if [ "$COORDINATE_MODE" = true ]; then
  # Save problem description
  cat > "$DEBUG_DIR/problem-description.md" <<COORD_EOF
# Debug Session: $DEBUG_SESSION_ID

**Problem Description**: $BUG_DESC
**Strategy**: $([ "$BUG_COUNT" -ge 3 ] && echo "orchestrated" || echo "sequential")
**Issues**: $BUG_COUNT
COORD_EOF

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔍 Analyzing bugs and generating fix plan..."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
fi
```

For each bug identified, use `/specswarm:bugfix` (sequentially) or Task agents (in parallel if 3+ bugs).

After all fixes are applied, run verification:

```bash
if [ "$COORDINATE_MODE" = true ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ Coordinated Fix Complete"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Debug session: $DEBUG_SESSION_ID"
  echo "Issues fixed: $BUG_COUNT"
  echo ""
  echo "📝 NEXT STEPS"
  echo "  1. Review fixes above"
  echo "  2. Run manual verification"
  echo "  3. Ship when ready: /specswarm:ship"
  echo ""
  # Exit coordinate mode - skip standard fix workflow below
  exit 0
fi
```

**If COORDINATE_MODE = true, the standard workflow below is SKIPPED.**

---

## Execution Steps (Standard Mode)

### Step 1: Display Welcome Banner

```bash
if [ "$HOTFIX" = true ]; then
  echo "🚨 SpecSwarm Fix - HOTFIX Mode (Expedited)"
else
  echo "🔧 SpecSwarm Fix - Test-Driven Bug Resolution"
fi
echo "══════════════════════════════════════════"
echo ""
echo "Bug: $BUG_DESC"
echo ""

if [ "$HOTFIX" = true ]; then
  echo "⚡ HOTFIX MODE: Expedited workflow for production issues"
  echo ""
  echo "This workflow will:"
  echo "  1. Analyze bug and identify root cause"
  echo "  2. Implement fix immediately"
  echo "  3. Verify fix works"
  echo "  4. Skip comprehensive testing (fast path)"
  echo ""
elif [ "$REGRESSION_TEST" = true ]; then
  echo "✅ Test-Driven Mode: Creating regression test first"
  echo ""
  echo "This workflow will:"
  echo "  1. Create failing test that reproduces bug"
  echo "  2. Verify test fails (confirms bug exists)"
  echo "  3. Implement fix"
  echo "  4. Verify test passes (confirms fix works)"
  echo "  5. Run full test suite"
  echo "  6. Retry up to $MAX_RETRIES times if fix fails"
  echo ""
else
  echo "This workflow will:"
  echo "  1. Analyze bug and identify root cause"
  echo "  2. Implement fix"
  echo "  3. Verify fix works"
  echo "  4. Run test suite to catch regressions"
  echo "  5. Retry up to $MAX_RETRIES times if fix fails"
  echo ""
fi

# Show Chrome DevTools MCP status for web projects
if [ "$CHROME_DEVTOOLS_MODE" = "enabled" ]; then
  echo "🌐 Web project detected ($WEB_FRAMEWORK)"
  echo "🎯 Chrome DevTools MCP: Enhanced browser debugging available"
  echo ""
elif [ "$CHROME_DEVTOOLS_MODE" = "fallback" ]; then
  echo "🌐 Web project detected ($WEB_FRAMEWORK)"
  echo "📦 Using Playwright for browser automation"
  echo ""
fi

read -p "Press Enter to start, or Ctrl+C to cancel..."
echo ""
```

---

### Step 2: Phase 1 - Regression Test (Optional)

**IF --regression-test flag was provided:**

```bash
if [ "$REGRESSION_TEST" = true ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🧪 Phase 1: Creating Regression Test"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Creating a test that reproduces the bug..."
  echo ""
fi
```

**YOU MUST create a failing test that reproduces the bug:**

If REGRESSION_TEST = true:
  1. Analyze the bug description
  2. Identify the component/module affected
  3. Create a test file (e.g., `bug-NNN.test.ts`)
  4. Write a test that reproduces the bug behavior
  5. The test should FAIL before the fix

```bash
if [ "$REGRESSION_TEST" = true ]; then
  # Run the new test to verify it fails
  # (This confirms the bug actually exists)

  echo "Running test to verify it fails..."
  # Detect test runner and run test

  echo ""
  echo "✅ Test created and verified (currently failing as expected)"
  echo ""
fi
```

---

### Step 3: Phase 2 - Implement Fix

**YOU MUST NOW run the bugfix command using the SlashCommand tool:**

```bash
if [ "$HOTFIX" = true ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "⚡ Phase 2: Implementing Hotfix"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
  PHASE_NUM=2
  if [ "$REGRESSION_TEST" = true ]; then
    PHASE_NUM=2
  fi
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔧 Phase $PHASE_NUM: Implementing Fix"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi
echo ""
```

**Use the appropriate command:**

```
IF HOTFIX = true:
  Use the SlashCommand tool to execute: /specswarm:hotfix "$BUG_DESC"
ELSE:
  Use the SlashCommand tool to execute: /specswarm:bugfix "$BUG_DESC"
```

Wait for fix to be implemented.

```bash
echo ""
echo "✅ Fix implemented"
echo ""
```

---

### Step 4: Phase 3 - Verify Fix Works

**YOU MUST NOW verify the fix works:**

```bash
PHASE_NUM=3
if [ "$REGRESSION_TEST" = true ]; then
  PHASE_NUM=3
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Phase $PHASE_NUM: Verifying Fix"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
```

**Verification steps:**

1. If REGRESSION_TEST = true:
   - Run the regression test again
   - It should now PASS
   - If it still FAILS, fix didn't work

2. Run full test suite:
   - Detect test runner (npm test, pytest, etc.)
   - Run all tests
   - Check for any new failures

3. Store result as FIX_SUCCESSFUL (true/false)

```bash
# Detect and run test suite
if [ -f "package.json" ]; then
  if grep -q "\"test\":" package.json; then
    echo "Running test suite..."
    npm test
    TEST_RESULT=$?
  fi
fi

if [ $TEST_RESULT -eq 0 ]; then
  FIX_SUCCESSFUL=true
  echo ""
  echo "✅ All tests passing - fix verified!"
  echo ""
else
  FIX_SUCCESSFUL=false
  echo ""
  echo "❌ Tests failing - fix may not be complete"
  echo ""
fi
```

---

### Step 5: Phase 4 - Retry Logic (If Needed)

**IF fix failed and retries remaining:**

```bash
RETRY_COUNT=0

while [ "$FIX_SUCCESSFUL" = false ] && [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  RETRY_COUNT=$((RETRY_COUNT + 1))

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔄 Retry $RETRY_COUNT/$MAX_RETRIES: Attempting Another Fix"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Previous fix didn't resolve all test failures."
  echo "Analyzing test failures and implementing improved fix..."
  echo ""

  # Show Chrome DevTools diagnostics availability for web projects
  if [ "$CHROME_DEVTOOLS_MODE" = "enabled" ]; then
    echo "🌐 Chrome DevTools MCP available for enhanced failure diagnostics"
    echo "   (console errors, network failures, runtime state inspection)"
    echo ""
  fi
```

**YOU MUST re-run bugfix with additional context:**

```
Use the SlashCommand tool to execute: /specswarm:bugfix "Fix failed tests from previous attempt: $BUG_DESC. Test failures: [extract failure details from test output]"
```

**Re-verify:**
- Run tests again
- Update FIX_SUCCESSFUL based on results

```bash
  # Re-run tests
  npm test
  TEST_RESULT=$?

  if [ $TEST_RESULT -eq 0 ]; then
    FIX_SUCCESSFUL=true
    echo ""
    echo "✅ Fix successful on retry $RETRY_COUNT!"
    echo ""
    break
  else
    echo ""
    echo "❌ Still failing after retry $RETRY_COUNT"
    echo ""
  fi
done
```

---

### Step 6: Final Report

**Display completion summary:**

```bash
echo ""
echo "══════════════════════════════════════════"

if [ "$FIX_SUCCESSFUL" = true ]; then
  echo "🎉 BUG FIX COMPLETE"
  echo "══════════════════════════════════════════"
  echo ""
  echo "Bug: $BUG_DESC"
  echo ""
  if [ $RETRY_COUNT -gt 0 ]; then
    echo "✅ Fix implemented (succeeded on retry $RETRY_COUNT)"
  else
    echo "✅ Fix implemented"
  fi
  if [ "$REGRESSION_TEST" = true ]; then
    echo "✅ Regression test created and passing"
  fi
  echo "✅ All tests passing"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📝 NEXT STEPS"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "1. 🧪 Manual Testing"
  echo "   - Test the bug fix in your app"
  echo "   - Verify the original issue is resolved"
  echo "   - Check for any side effects"
  echo ""
  echo "2. 🚢 Ship When Ready"
  echo "   Run: /specswarm:ship"
  echo ""
  echo "   This will:"
  echo "   - Validate code quality"
  echo "   - Merge to parent branch if passing"
  echo "   - Complete the bugfix workflow"
  echo ""
else
  echo "⚠️  BUG FIX INCOMPLETE"
  echo "══════════════════════════════════════════"
  echo ""
  echo "Bug: $BUG_DESC"
  echo ""
  echo "❌ Fix attempted $((RETRY_COUNT + 1)) time(s) but tests still failing"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔧 RECOMMENDED ACTIONS"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "1. Review test failure output above"
  echo "2. Bug may be more complex than initially analyzed"
  echo "3. Consider:"
  echo "   - Manual investigation of root cause"
  echo "   - Breaking into smaller sub-bugs"
  echo "   - Requesting code review for insights"
  echo ""
  echo "4. Re-run with more retries:"
  echo "   /specswarm:fix \"$BUG_DESC\" --max-retries 5"
  echo ""
  echo "5. Or fix manually and run tests:"
  echo "   npm test"
  echo ""
fi

echo "══════════════════════════════════════════"
```

---

## Error Handling

If any step fails:

1. **Bugfix/hotfix command fails**: Display error, suggest reviewing bug description
2. **Test creation fails**: Display error, suggest creating test manually
3. **All retries exhausted**: Display final report with recommended actions (see Step 6)

**All errors should report clearly and suggest remediation.**

---

## Design Philosophy

**Test-Driven**: Optional --regression-test ensures bug won't resurface

**Resilient**: Automatic retry logic handles incomplete fixes

**Fast Path**: --hotfix for production emergencies

**User Experience**: Clear progress indicators, retry feedback, actionable next steps

---

## Comparison to Manual Workflow

**Before** (Manual):
```bash
/specswarm:bugfix "bug description"
# [Manually check if fix worked]
# [If failed, manually re-run bugfix]
# [Manually run tests]
/specswarm:complete
```
**3-5+ commands**, manual verification and retry logic

**After** (Fix):
```bash
/specswarm:fix "bug description" --regression-test
# [Automatic verification and retry]
/specswarm:ship
```
**2 commands**, automatic retry, regression test included

**Benefits**:
- Automatic retry eliminates manual orchestration
- Regression test prevents future regressions
- Clear success/failure reporting with next steps
