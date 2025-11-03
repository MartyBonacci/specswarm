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
    description: Run automated error detection after implementation (launches dev server, runs Lighthouse audit, captures console errors, attempts auto-fix up to 3 times)
    required: false
pre_orchestration_hook: |
  #!/bin/bash

  echo "🎯 Feature Orchestrator v2.4.0 - Automated Error Detection"
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

${RUN_VALIDATE} = true enables automated error detection (Phase 6.5) - the agent will launch dev server, run Lighthouse audit, capture console errors, and auto-fix issues before manual testing.

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
🔍 PHASE 2.5: AUTOMATED ERROR DETECTION (Conditional - If ${RUN_VALIDATE}=true)
═══════════════════════════════════════════════════════════════

IF ${RUN_VALIDATE} = true:

  ### Step 2.5.1: Pre-Validation Setup
  - Report: "🔍 Starting automated error detection (--validate enabled)"
  - Create validation directory: ${PROJECT_PATH}/.speclabs/validation/
  - Initialize error retry counter: error_retry_count=0
  - Set max error retries: max_error_retries=3

  ### Step 2.5.2: Start Development Server
  - Use Bash tool to start dev server in background:
    ```bash
    cd ${PROJECT_PATH} && npm run dev > .speclabs/validation/dev-server.log 2>&1 &
    echo $! > .speclabs/validation/dev-server.pid
    ```
  - Wait 10 seconds for server startup
  - Verify server running: Check if process exists and port responding
  - Report: "✅ Dev server started (PID: [pid])"

  ### Step 2.5.3: Run Lighthouse Audit (Retry Loop)

  WHILE error_retry_count < max_error_retries:

    **Run Lighthouse:**
    - Use Bash tool:
      ```bash
      npx lighthouse http://localhost:5173 \
        --output=json \
        --output-path=${PROJECT_PATH}/.speclabs/validation/lighthouse-report-${error_retry_count}.json \
        --quiet \
        --chrome-flags="--headless --no-sandbox"
      ```
    - Wait for completion (timeout: 60 seconds)

    **Parse Console Errors:**
    - Use Read tool to read lighthouse-report-${error_retry_count}.json
    - Extract console errors from: `audits.errors.details.items[]`
    - Filter for severity: "error" (ignore warnings)
    - Extract error messages, sources, and line numbers
    - Count total errors found

    **Decision Point:**
    - IF no console errors found:
      - Report: "✅ No console errors detected (Lighthouse audit passed)"
      - BREAK out of retry loop
      - Continue to Step 2.5.4

    - IF console errors found:
      - Report: "⚠️ Found ${error_count} console errors (attempt ${error_retry_count + 1}/${max_error_retries})"
      - Create error report: .speclabs/validation/errors-${error_retry_count}.md
      - Write error details to report (formatted for agent analysis)

      **Attempt Auto-Fix:**
      1. Analyze errors to identify fixable issues:
         - Undefined variables/imports
         - Type errors
         - Missing dependencies
         - Syntax errors
         - Common React/JavaScript errors

      2. IF errors appear auto-fixable:
         - Use Read/Edit tools to fix identified issues
         - Document fixes in validation log
         - Increment error_retry_count
         - Use Bash tool to rebuild: `cd ${PROJECT_PATH} && npm run build`
         - Wait for build completion
         - Report: "🔧 Applied fixes, retrying Lighthouse audit..."
         - CONTINUE to next iteration of loop

      3. IF errors not auto-fixable:
         - Report: "⚠️ Errors require manual intervention"
         - Document errors in final report
         - BREAK out of retry loop

    - IF error_retry_count >= max_error_retries:
      - Report: "⚠️ Max retry attempts reached (${max_error_retries})"
      - Report: "Proceeding with ${error_count} remaining errors for manual review"
      - BREAK out of retry loop

  END WHILE

  ### Step 2.5.4: Kill Development Server
  - Use Bash tool:
    ```bash
    if [ -f ${PROJECT_PATH}/.speclabs/validation/dev-server.pid ]; then
      kill $(cat ${PROJECT_PATH}/.speclabs/validation/dev-server.pid) 2>/dev/null || true
      rm ${PROJECT_PATH}/.speclabs/validation/dev-server.pid
    fi
    ```
  - Report: "✅ Dev server stopped"

  ### Step 2.5.5: Validation Summary
  - Create summary report: .speclabs/validation/validation-summary.md
  - Include:
    - Total retry attempts: ${error_retry_count}
    - Errors found: ${initial_error_count}
    - Errors fixed: ${fixed_error_count}
    - Errors remaining: ${remaining_error_count}
    - Lighthouse reports generated: ${error_retry_count + 1}
  - Report final status:
    - IF remaining_error_count = 0:
      - "✅ Automated error detection PASSED - No console errors"
    - ELSE:
      - "⚠️ Automated error detection completed with ${remaining_error_count} errors remaining"
      - "See .speclabs/validation/ for detailed reports"

ELSE:
  - Skip automated error detection (--validate not specified)
  - Report: "⏭️ Skipping automated error detection (use --validate to enable)"

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
