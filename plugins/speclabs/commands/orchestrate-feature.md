---
description: Orchestrate complete feature lifecycle from specification to implementation using autonomous agent
args:
  - name: feature_description
    description: Natural language description of the feature to build
    required: true
  - name: project_path
    description: Path to the target project (defaults to current working directory)
    required: false
  - name: --skip-specify
    description: Skip the specify phase (spec.md already exists)
    required: false
  - name: --skip-clarify
    description: Skip the clarify phase
    required: false
  - name: --skip-plan
    description: Skip the plan phase (plan.md already exists)
    required: false
  - name: --max-retries
    description: Maximum retries per task (default 3)
    required: false
  - name: --audit
    description: Run comprehensive code audit phase after implementation (compatibility, security, best practices)
    required: false
  - name: --validate
    description: Run interactive error detection with Playwright (monitors browser console + terminal output during interactions, auto-fixes errors, kills dev server when done)
    required: false
pre_orchestration_hook: |
  #!/bin/bash

  echo "🎯 Feature Orchestrator v2.5.0 - Interactive Error Detection with Playwright"
  echo ""
  echo "This orchestrator launches an autonomous agent that handles:"
  echo "  1. SpecSwarm Planning: specify → clarify → plan → tasks"
  echo "  2. SpecLabs Execution: automatically execute all tasks"
  echo "  3. Intelligent Bugfix: Auto-fix failures with /specswarm:bugfix"
  echo "  4. Code Audit: Comprehensive quality validation (if --audit)"
  echo "  5. Completion Report: Full summary with next steps"
  echo ""

  # Parse arguments
  FEATURE_DESC="$1"
  shift

  # Check if next arg is a path (doesn't start with --)
  if [ -n "$1" ] && [ "${1:0:2}" != "--" ]; then
    PROJECT_PATH="$1"
    shift
  else
    PROJECT_PATH="$(pwd)"
  fi

  SKIP_SPECIFY=false
  SKIP_CLARIFY=false
  SKIP_PLAN=false
  MAX_RETRIES=3
  RUN_AUDIT=false
  RUN_VALIDATE=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-specify) SKIP_SPECIFY=true; shift ;;
      --skip-clarify) SKIP_CLARIFY=true; shift ;;
      --skip-plan) SKIP_PLAN=true; shift ;;
      --max-retries) MAX_RETRIES="$2"; shift 2 ;;
      --audit) RUN_AUDIT=true; shift ;;
      --validate) RUN_VALIDATE=true; shift ;;
      *) shift ;;
    esac
  done

  # Validate project path
  if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ Error: Project path does not exist: $PROJECT_PATH"
    echo "   (Tip: Provide an explicit path or run from your project directory)"
    exit 1
  fi

  echo "📁 Project: $PROJECT_PATH"

  # Source orchestration library
  PLUGIN_DIR="/home/marty/code-projects/specswarm/plugins/speclabs"
  source "${PLUGIN_DIR}/lib/feature-orchestrator.sh"

  # Initialize orchestrator
  feature_init

  # Create feature session
  echo "📝 Creating feature orchestration session..."
  SESSION_ID=$(feature_create_session "$FEATURE_DESC" "$PROJECT_PATH")
  echo "✅ Feature Session: $SESSION_ID"
  echo ""

  # Export for agent
  export FEATURE_SESSION_ID="$SESSION_ID"
  export FEATURE_DESC="$FEATURE_DESC"
  export PROJECT_PATH="$PROJECT_PATH"
  export SKIP_SPECIFY="$SKIP_SPECIFY"
  export SKIP_CLARIFY="$SKIP_CLARIFY"
  export SKIP_PLAN="$SKIP_PLAN"
  export MAX_RETRIES="$MAX_RETRIES"
  export RUN_AUDIT="$RUN_AUDIT"
  export RUN_VALIDATE="$RUN_VALIDATE"
  export PLUGIN_DIR="$PLUGIN_DIR"

  echo "🚀 Launching orchestration agent for: $FEATURE_DESC"
  echo ""
---

# Agent-Based Feature Orchestration

I'll now launch an autonomous agent to handle the complete feature lifecycle.

**Orchestration Details**:
- **Feature**: ${FEATURE_DESC}
- **Project**: ${PROJECT_PATH}
- **Session ID**: ${FEATURE_SESSION_ID}
- **Audit**: ${RUN_AUDIT}
- **Validate**: ${RUN_VALIDATE}
- **Skip Phases**: Specify=${SKIP_SPECIFY}, Clarify=${SKIP_CLARIFY}, Plan=${SKIP_PLAN}

The agent will execute all phases automatically and report back when complete. This may take several minutes depending on feature complexity.

${RUN_VALIDATE} = true enables interactive error detection (Phase 2.5) - the agent will launch dev server, run Playwright browser automation with console monitoring, test interaction flows, and auto-fix errors before manual testing. Dev server will be stopped before returning control to user.

---

I'm using the Task tool to launch the orchestration agent with subagent_type "general-purpose":

**Agent Mission**: Execute the complete feature development lifecycle for "${FEATURE_DESC}" in ${PROJECT_PATH}

**Comprehensive Agent Instructions**:

═══════════════════════════════════════════════════════════════
🎯 FEATURE ORCHESTRATION AGENT - AUTONOMOUS EXECUTION
═══════════════════════════════════════════════════════════════

You are an autonomous feature orchestration agent. Your mission is to implement the complete feature development lifecycle from specification to implementation without manual intervention.

**MISSION**: Implement "${FEATURE_DESC}" in ${PROJECT_PATH}

**SESSION TRACKING**: ${FEATURE_SESSION_ID}

**CONFIGURATION**:
- Skip Specify: ${SKIP_SPECIFY}
- Skip Clarify: ${SKIP_CLARIFY}
- Skip Plan: ${SKIP_PLAN}
- Max Retries: ${MAX_RETRIES}
- Run Audit: ${RUN_AUDIT}
- Run Validate: ${RUN_VALIDATE}

═══════════════════════════════════════════════════════════════
📋 WORKFLOW - EXECUTE IN ORDER
═══════════════════════════════════════════════════════════════

## PHASE 1: PLANNING (Automatic)

### Step 1.1: Specification
IF ${SKIP_SPECIFY} = false:
  - Use the SlashCommand tool to execute: `/specswarm:specify "${FEATURE_DESC}"`
  - Wait for completion
  - Verify spec.md created in features/ directory
  - Update session: feature_complete_specswarm_phase "${FEATURE_SESSION_ID}" "specify"
ELSE:
  - Skip this step (spec.md already exists)

### Step 1.2: Clarification
IF ${SKIP_CLARIFY} = false:
  - Use the SlashCommand tool to execute: `/specswarm:clarify`
  - Answer any clarification questions if prompted
  - Wait for completion
  - Update session: feature_complete_specswarm_phase "${FEATURE_SESSION_ID}" "clarify"
ELSE:
  - Skip this step

### Step 1.3: Planning
IF ${SKIP_PLAN} = false:
  - Use the SlashCommand tool to execute: `/specswarm:plan`
  - Wait for plan.md generation
  - Review plan for implementation phases
  - Update session: feature_complete_specswarm_phase "${FEATURE_SESSION_ID}" "plan"
ELSE:
  - Skip this step (plan.md already exists)

### Step 1.4: Task Generation
- Use the SlashCommand tool to execute: `/specswarm:tasks`
- Wait for tasks.md generation
- Update session: feature_complete_specswarm_phase "${FEATURE_SESSION_ID}" "tasks"

### Step 1.5: Parse Tasks
- Use the Read tool to read ${PROJECT_PATH}/features/*/tasks.md
- Count total tasks (look for task IDs like T001, T002, etc.)
- Extract task list
- Report: "Found X tasks to execute"

═══════════════════════════════════════════════════════════════
🔨 PHASE 2: IMPLEMENTATION (Automatic Task Loop)
═══════════════════════════════════════════════════════════════

### Step 2.1: Initialize Implementation
- Create directory: ${PROJECT_PATH}/.speclabs/workflows/
- Initialize counters: completed=0, failed=0, total=X
- Update session: feature_start_implementation "${FEATURE_SESSION_ID}"

### Step 2.2: Execute Each Task
FOR EACH TASK in the task list:

  **Create Workflow File**:
  1. Extract task description from tasks.md
  2. Create workflow file: .speclabs/workflows/workflow_${TASK_ID}.md
  3. Workflow content:
     ```markdown
     # Task ${TASK_ID}: ${TASK_DESCRIPTION}

     ## Context
     - Feature: ${FEATURE_DESC}
     - Project: ${PROJECT_PATH}
     - Session: ${FEATURE_SESSION_ID}

     ## Task Details
     ${FULL_TASK_DESCRIPTION_FROM_TASKS_MD}

     ## Success Criteria
     - Task completes without errors
     - Code builds successfully
     - All tests pass (if applicable)
     ```

  **Execute Task**:
  1. Use the SlashCommand tool to execute: `/speclabs:orchestrate .speclabs/workflows/workflow_${TASK_ID}.md ${PROJECT_PATH}`
  2. Wait for task completion
  3. Check status from orchestrate session

  **Track Progress**:
  1. IF task succeeded:
     - Increment completed counter
     - Update session: feature_complete_task "${FEATURE_SESSION_ID}" "${TASK_ID}" "true"
  2. IF task failed:
     - Increment failed counter
     - Update session: feature_fail_task "${FEATURE_SESSION_ID}" "${TASK_ID}"
     - Log error details
  3. Report progress: "Task ${TASK_ID} complete (${completed}/${total} succeeded, ${failed} failed)"

  **Continue to next task**

### Step 2.3: Implementation Summary
- Report final statistics:
  - "✅ Completed: ${completed}/${total} tasks"
  - "❌ Failed: ${failed}/${total} tasks"
- Update session: feature_complete_implementation "${FEATURE_SESSION_ID}" "${completed}" "${failed}"
- If failed > 0: Prepare for bugfix phase

═══════════════════════════════════════════════════════════════
🔍 PHASE 2.5: INTERACTIVE ERROR DETECTION (Conditional - If ${RUN_VALIDATE}=true)
═══════════════════════════════════════════════════════════════

IF ${RUN_VALIDATE} = true:

  ### Step 2.5.1: Pre-Validation Setup
  - Report: "🔍 Starting interactive error detection with Playwright (--validate enabled)"
  - Create validation directory: ${PROJECT_PATH}/.speclabs/validation/
  - Initialize error retry counter: error_retry_count=0
  - Set max error retries: max_error_retries=3
  - Install Playwright if not present:
    ```bash
    cd ${PROJECT_PATH} && npx playwright install chromium --with-deps
    ```

  ### Step 2.5.2: Start Development Server
  - Use Bash tool to start dev server in background:
    ```bash
    cd ${PROJECT_PATH} && npm run dev > .speclabs/validation/dev-server.log 2>&1 &
    echo $! > .speclabs/validation/dev-server.pid
    ```
  - Wait 10 seconds for server startup
  - Verify server running: Check if process exists and port responding
  - Report: "✅ Dev server started (PID: [pid])"

  ### Step 2.5.3: Interactive Error Detection (Retry Loop)

  WHILE error_retry_count < max_error_retries:

    **Create Playwright Test Script:**
    - Use Write tool to create: ${PROJECT_PATH}/.speclabs/validation/error-detection-test.js
    - Script content:
      ```javascript
      const { chromium } = require('playwright');
      const fs = require('fs');

      (async () => {
        const consoleErrors = [];
        const pageErrors = [];

        // Launch browser
        const browser = await chromium.launch({ headless: true });
        const context = await browser.newContext({
          viewport: { width: 1280, height: 720 }
        });
        const page = await context.newPage();

        // Listen for console errors
        page.on('console', msg => {
          if (msg.type() === 'error') {
            consoleErrors.push({
              type: 'console',
              message: msg.text(),
              location: msg.location()
            });
          }
        });

        // Listen for uncaught exceptions
        page.on('pageerror', exception => {
          pageErrors.push({
            type: 'exception',
            message: exception.message,
            stack: exception.stack
          });
        });

        // Interaction Flow Testing
        try {
          // Navigate to homepage
          await page.goto('http://localhost:5173', { waitUntil: 'networkidle', timeout: 30000 });
          await page.waitForTimeout(2000);

          // Take screenshot of initial state
          await page.screenshot({ path: '.speclabs/validation/screenshot-home.png', fullPage: true });

          // Auto-detect and test navigation links (if any)
          const navLinks = await page.$$('nav a, header a, [role="navigation"] a');
          for (let i = 0; i < Math.min(navLinks.length, 5); i++) {
            try {
              await navLinks[i].click();
              await page.waitForTimeout(1000);
              await page.screenshot({ path: \`.speclabs/validation/screenshot-nav-\${i}.png\` });
              await page.goBack();
              await page.waitForTimeout(500);
            } catch (e) {
              console.log(\`Navigation test \${i} failed: \${e.message}\`);
            }
          }

          // Test any buttons on the page
          const buttons = await page.$$('button:visible');
          for (let i = 0; i < Math.min(buttons.length, 3); i++) {
            try {
              await buttons[i].click();
              await page.waitForTimeout(1000);
            } catch (e) {
              console.log(\`Button test \${i} failed: \${e.message}\`);
            }
          }

        } catch (error) {
          pageErrors.push({
            type: 'test-error',
            message: error.message,
            stack: error.stack
          });
        }

        // Save errors to JSON
        const allErrors = [...consoleErrors, ...pageErrors];
        fs.writeFileSync('.speclabs/validation/errors-${error_retry_count}.json',
          JSON.stringify(allErrors, null, 2));

        // Close browser
        await browser.close();

        // Exit with error count
        process.exit(allErrors.length > 0 ? 1 : 0);
      })();
      ```

    **Run Playwright Test:**
    - Use Bash tool:
      ```bash
      cd ${PROJECT_PATH} && node .speclabs/validation/error-detection-test.js 2>&1 | tee .speclabs/validation/test-output-${error_retry_count}.log
      ```
    - Capture exit code to determine if errors were found

    **Monitor Terminal Output:**
    - Use Read tool to read last 100 lines of dev-server.log
    - Look for error patterns:
      - "Error:", "ERROR", "Failed to compile"
      - Stack traces
      - Uncaught exceptions
      - Module not found errors
    - Document any terminal errors found

    **Parse Playwright Errors:**
    - Use Read tool to read: .speclabs/validation/errors-${error_retry_count}.json
    - Count total errors (consoleErrors + pageErrors + terminal errors)
    - Create human-readable error report

    **Decision Point:**
    - IF no errors found (browser + terminal clean):
      - Report: "✅ No errors detected - browser console and terminal clean"
      - BREAK out of retry loop
      - Continue to Step 2.5.4

    - IF errors found:
      - Report: "⚠️ Found ${error_count} errors (attempt ${error_retry_count + 1}/${max_error_retries})"
      - Report error breakdown:
        - Console errors: ${console_error_count}
        - Uncaught exceptions: ${page_error_count}
        - Terminal errors: ${terminal_error_count}
      - Create detailed error report: .speclabs/validation/error-report-${error_retry_count}.md

      **Attempt Auto-Fix:**
      1. Analyze errors to identify fixable issues:
         - Undefined variables/imports (check import statements)
         - Type errors (check prop types, function signatures)
         - Missing dependencies (check package.json)
         - Syntax errors (check for typos, missing brackets)
         - Module resolution errors (check file paths)
         - Common React errors (hooks rules, component lifecycle)
         - API call failures (check network requests in terminal)

      2. IF errors appear auto-fixable:
         - Use Read/Edit tools to fix identified issues
         - Document each fix in .speclabs/validation/fixes-applied-${error_retry_count}.md
         - Increment error_retry_count
         - Report: "🔧 Applied ${fixes_count} fixes, retrying validation..."
         - CONTINUE to next iteration of loop

      3. IF errors not auto-fixable OR ambiguous:
         - Report: "⚠️ Errors require manual intervention:"
         - List each error with file location and description
         - Document in final report with recommendations
         - BREAK out of retry loop

    - IF error_retry_count >= max_error_retries:
      - Report: "⚠️ Max retry attempts reached (${max_error_retries})"
      - Report: "Proceeding with ${error_count} remaining errors for manual review"
      - BREAK out of retry loop

  END WHILE

  ### Step 2.5.4: Kill Development Server (CRITICAL)
  - **MUST execute this step before returning control to user**
  - Use Bash tool:
    ```bash
    if [ -f ${PROJECT_PATH}/.speclabs/validation/dev-server.pid ]; then
      kill $(cat ${PROJECT_PATH}/.speclabs/validation/dev-server.pid) 2>/dev/null || true
      rm ${PROJECT_PATH}/.speclabs/validation/dev-server.pid
    fi
    # Verify process is dead
    ! ps -p $(cat ${PROJECT_PATH}/.speclabs/validation/dev-server.pid 2>/dev/null) > /dev/null 2>&1 || kill -9 $(cat ${PROJECT_PATH}/.speclabs/validation/dev-server.pid 2>/dev/null)
    ```
  - Report: "✅ Dev server stopped (port available for user)"

  ### Step 2.5.5: Validation Summary
  - Create summary report: .speclabs/validation/validation-summary.md
  - Include:
    - Total retry attempts: ${error_retry_count}
    - Errors found initially: ${initial_error_count}
    - Errors fixed: ${fixed_error_count}
    - Errors remaining: ${remaining_error_count}
    - Screenshots captured: List all .png files
    - Test scenarios executed: Homepage + ${nav_tests} navigation + ${button_tests} interactions
  - Report final status:
    - IF remaining_error_count = 0:
      - "✅ INTERACTIVE VALIDATION PASSED"
      - "   - Browser console: Clean"
      - "   - Terminal output: Clean"
      - "   - Navigation tested: ${nav_tests} links"
      - "   - Interactions tested: ${button_tests} buttons"
    - ELSE:
      - "⚠️ Validation completed with ${remaining_error_count} errors remaining"
      - "   See .speclabs/validation/ for:"
      - "   - error-report-*.md (detailed error analysis)"
      - "   - screenshot-*.png (visual states)"
      - "   - dev-server.log (terminal output)"
      - "   - fixes-applied-*.md (attempted fixes)"

ELSE:
  - Skip interactive error detection (--validate not specified)
  - Report: "⏭️ Skipping interactive error detection (use --validate to enable)"

═══════════════════════════════════════════════════════════════
🔧 PHASE 3: BUGFIX (Conditional - If Tasks Failed)
═══════════════════════════════════════════════════════════════

IF ${failed} > 0:

  ### Step 3.1: Execute Bugfix
  - Update session: feature_start_bugfix "${FEATURE_SESSION_ID}"
  - Use the SlashCommand tool to execute: `/specswarm:bugfix`
  - Wait for bugfix completion
  - Review bugfix results

  ### Step 3.2: Re-Verify Failed Tasks
  - Check if previously failed tasks are now fixed
  - Update success/failure counts
  - Update session: feature_complete_bugfix "${FEATURE_SESSION_ID}" "${fixed_count}"

═══════════════════════════════════════════════════════════════
🔍 PHASE 4: AUDIT (Conditional - If ${RUN_AUDIT}=true)
═══════════════════════════════════════════════════════════════

IF ${RUN_AUDIT} = true:

  ### Step 4.1: Initialize Audit
  - Create audit directory: ${PROJECT_PATH}/.speclabs/audit/
  - Update session: feature_start_audit "${FEATURE_SESSION_ID}"
  - Prepare audit report file

  ### Step 4.2: Run Audit Checks

  **Compatibility Audit**:
  - Check for deprecated patterns
  - Verify language version compatibility
  - Check library compatibility

  **Security Audit**:
  - Scan for hardcoded secrets
  - Check for SQL injection vulnerabilities
  - Verify XSS prevention
  - Look for dangerous functions (eval, exec, etc.)

  **Best Practices Audit**:
  - Check for TODO/FIXME comments
  - Verify error handling
  - Check for debug logging in production
  - Verify code organization

  ### Step 4.3: Calculate Quality Score
  - Count warnings and errors across all checks
  - Calculate score: 100 - (warnings + errors*2)
  - Minimum score: 0

  ### Step 4.4: Generate Audit Report
  - Create comprehensive markdown report
  - Include all findings with file locations and line numbers
  - Add quality score
  - Save to: ${PROJECT_PATH}/.speclabs/audit/audit-report-${DATE}.md
  - Update session: feature_complete_audit "${FEATURE_SESSION_ID}" "${AUDIT_REPORT_PATH}" "${QUALITY_SCORE}"

═══════════════════════════════════════════════════════════════
📊 PHASE 5: COMPLETION REPORT
═══════════════════════════════════════════════════════════════

### Step 5.1: Generate Final Report

Create comprehensive completion report with:

**Planning Artifacts**:
- ✅ Specification: ${SPEC_FILE_PATH}
- ✅ Plan: ${PLAN_FILE_PATH}
- ✅ Tasks: ${TASKS_FILE_PATH}

**Implementation Results**:
- ✅ Total Tasks: ${total}
- ✅ Completed Successfully: ${completed}
- ❌ Failed: ${failed}
- ⚠️  Fixed in Bugfix: ${fixed} (if bugfix ran)

**Quality Assurance**:
- Bugfix Phase: ${RAN_BUGFIX ? "✅ Executed" : "⏭️ Skipped (no failures)"}
- Audit Phase: ${RUN_AUDIT ? "✅ Executed (Score: ${QUALITY_SCORE}/100)" : "⏭️ Skipped (--audit not specified)"}
- Audit Report: ${AUDIT_REPORT_PATH} (if audit ran)

**Session Information**:
- Session ID: ${FEATURE_SESSION_ID}
- Session File: /memory/feature-orchestrator/sessions/${FEATURE_SESSION_ID}.json
- Feature Branch: ${BRANCH_NAME}

**Next Steps**:
1. Review implementation changes: `git diff`
2. Test manually: Run application and verify feature works
3. Complete feature: Run `/specswarm:complete` to finalize with git workflow

### Step 5.2: Update Session Status
- Update session: feature_complete "${FEATURE_SESSION_ID}" "true" "Orchestration complete"
- Mark session as ready for completion

### Step 5.3: Return Report
Return the complete report to the main Claude instance.

═══════════════════════════════════════════════════════════════
⚠️  ERROR HANDLING
═══════════════════════════════════════════════════════════════

**If Any Phase Fails**:
1. Document the failure point clearly
2. Include full error messages in report
3. Recommend manual intervention steps
4. Update session status to "failed"
5. DO NOT continue to next phase
6. Return error report immediately

**Retry Logic**:
- Individual task failures: Continue to next task (bugfix will handle)
- Planning phase failures: Stop immediately (cannot proceed without plan)
- Bugfix failures: Note in report but continue to audit
- Audit failures: Note in report but continue to completion

═══════════════════════════════════════════════════════════════
✅ SUCCESS CRITERIA
═══════════════════════════════════════════════════════════════

Orchestration is successful when:
- ✅ All planning phases complete (or skipped if --skip flags)
- ✅ All tasks executed (track success/failure counts)
- ✅ Bugfix ran if needed
- ✅ Audit completed if --audit flag set
- ✅ Comprehensive final report generated
- ✅ Session tracking file created and updated
- ✅ User receives clear next steps

═══════════════════════════════════════════════════════════════
🚀 BEGIN ORCHESTRATION
═══════════════════════════════════════════════════════════════

**YOUR INSTRUCTIONS**: Execute the complete workflow above autonomously.

**Start now with Phase 1, Step 1.1**

Report progress as you execute each step. Be thorough and complete all phases.

Good luck! 🎯
