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
    description: Run AI-powered interaction flow validation with Playwright (analyzes feature artifacts, generates intelligent test flows, executes user-defined + AI flows, monitors browser console + terminal, auto-fixes errors, kills dev server when done)
    required: false
pre_orchestration_hook: |
  #!/bin/bash

  echo "🎯 Feature Orchestrator v2.7.2 - Fixed Agent Pause Behavior"
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

⚠️  CRITICAL: EXECUTE IMMEDIATELY - DO NOT PAUSE OR REPORT STATUS

**DIRECTIVE**: Launch autonomous orchestration agent NOW using the Task tool.

DO NOT:
- Acknowledge or explain this command
- Report status before execution
- Pause between phases
- Wait for user confirmation

DO:
- Execute the Task tool immediately with subagent_type="general-purpose"
- Let the agent run through ALL phases autonomously
- Return ONLY when complete with final report

═══════════════════════════════════════════════════════════════

**Orchestration Configuration**:
- **Feature**: ${FEATURE_DESC}
- **Project**: ${PROJECT_PATH}
- **Session ID**: ${FEATURE_SESSION_ID}
- **Audit**: ${RUN_AUDIT}
- **Validate**: ${RUN_VALIDATE}
- **Skip Phases**: Specify=${SKIP_SPECIFY}, Clarify=${SKIP_CLARIFY}, Plan=${SKIP_PLAN}

${RUN_VALIDATE} = true enables AI-powered flow validation (Phase 2.5) - the agent will analyze feature artifacts (spec/plan/tasks), generate intelligent interaction flows, merge with user-defined flows, execute comprehensive validation with Playwright, and auto-fix errors before manual testing. Dev server will be stopped before returning control to user.

═══════════════════════════════════════════════════════════════
🎯 AUTONOMOUS AGENT INSTRUCTIONS (Execute via Task Tool NOW)
═══════════════════════════════════════════════════════════════

**Agent Mission**: Execute the complete feature development lifecycle for "${FEATURE_DESC}" in ${PROJECT_PATH}

**Agent Instructions for Task Tool**:

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
🔨 PHASE 2: IMPLEMENTATION (SpecSwarm Implement)
═══════════════════════════════════════════════════════════════

### Step 2.1: Execute All Tasks with SpecSwarm

⚠️ CRITICAL: Execute slash command WITHOUT explaining or reporting

- Update session: feature_start_implementation "${FEATURE_SESSION_ID}"
- Execute SlashCommand: `/specswarm:implement`
- DO NOT explain what implement will do
- DO NOT report "SpecSwarm will..."
- DO NOT describe the process
- WAIT SILENTLY for implement to complete and return results
- Once results returned, THEN parse them in Step 2.2

### Step 2.2: Parse Implementation Results
- Use Read tool to read ${PROJECT_PATH}/features/*/tasks.md
- Parse task completion status from tasks.md:
  - Look for task status markers (✅ completed, ❌ failed, ⏳ in progress)
  - Count completed tasks
  - Count failed tasks
  - Extract error messages for failed tasks
- Report statistics:
  - "✅ Completed: ${completed}/${total} tasks"
  - "❌ Failed: ${failed}/${total} tasks"
  - If failed > 0: List failed task IDs with error summaries

### Step 2.3: Update Session
- Update session: feature_complete_implementation "${FEATURE_SESSION_ID}" "${completed}" "${failed}"
- If failed > 0: Prepare for bugfix phase (Phase 3)

═══════════════════════════════════════════════════════════════
🔍 PHASE 2.5: INTERACTIVE ERROR DETECTION (Conditional - If ${RUN_VALIDATE}=true)
═══════════════════════════════════════════════════════════════

IF ${RUN_VALIDATE} = true:

  ### Step 2.5.1: Initialize Validation Phase
  - Report: "🔍 Starting interactive error detection (--validate enabled)"
  - Update session: feature_start_validation "${FEATURE_SESSION_ID}"

  ### Step 2.5.2: Delegate to Standalone Validator

  ⚠️ CRITICAL: Execute validation WITHOUT explaining or reporting

  - Execute SlashCommand:
    ```bash
    /speclabs:validate-feature ${PROJECT_PATH} --session-id ${FEATURE_SESSION_ID}
    ```
  - DO NOT report "Detected project type..."
  - DO NOT explain what validation orchestrator will do
  - DO NOT describe the validation process
  - WAIT SILENTLY for validation to complete and return results
  - Once results returned, THEN parse them in Step 2.5.3

  ### Step 2.5.3: Parse Validation Results from Session
  - Use Bash tool to read validation results:
    ```bash
    source ${PLUGIN_DIR}/lib/feature-orchestrator.sh
    SESSION_FILE="${FEATURE_SESSION_DIR}/${FEATURE_SESSION_ID}.json"

    validation_status=$(jq -r '.validation.status' "$SESSION_FILE")
    validation_type=$(jq -r '.validation.type' "$SESSION_FILE")
    total_flows=$(jq -r '.validation.summary.total_flows' "$SESSION_FILE")
    passed_flows=$(jq -r '.validation.summary.passed_flows' "$SESSION_FILE")
    failed_flows=$(jq -r '.validation.summary.failed_flows' "$SESSION_FILE")
    error_count=$(jq -r '.validation.error_count' "$SESSION_FILE")
    ```

  ### Step 2.5.4: Report Validation Summary
  - Display validation results:
    - IF validation_status = "passed":
      - "✅ VALIDATION PASSED"
      - "   Type: ${validation_type}"
      - "   Flows: ${passed_flows}/${total_flows} passed"
      - "   Errors: 0"
      - ""
      - "All interaction flows passed with no errors detected."
    - ELSE IF validation_status = "failed":
      - "⚠️  VALIDATION COMPLETED WITH ISSUES"
      - "   Type: ${validation_type}"
      - "   Flows: ${passed_flows}/${total_flows} passed, ${failed_flows}/${total_flows} failed"
      - "   Errors: ${error_count}"
      - ""
      - "See ${PROJECT_PATH}/.speclabs/validation/ for:"
      - "  - flow-results.json (complete execution data)"
      - "  - screenshots/*.png (visual states)"
      - "  - dev-server.log (terminal output)"
    - ELSE:
      - "❌ VALIDATION ERROR"
      - "   Validation failed to execute properly"
      - "   Check ${PROJECT_PATH}/.speclabs/validation/ for logs"

ELSE:
  - Skip interactive error detection (--validate not specified)
  - Report: "⏭️ Skipping interactive error detection (use --validate to enable)"

═══════════════════════════════════════════════════════════════
🔧 PHASE 2.5.1: WEBAPP VALIDATOR FEATURES (Informational)
═══════════════════════════════════════════════════════════════

The standalone /speclabs:validate-feature command provides:

**Automatic Project Type Detection:**
- Webapp: React, Vite, Next.js, React Router apps
- Android: AndroidManifest.xml projects (validator planned for v2.7.1)
- REST API: OpenAPI/Swagger specs (validator planned for v2.7.2)
- Desktop GUI: Electron apps (validator planned for v2.7.3)

**Intelligent Flow Generation (Webapp v2.7.0):**
- AI-Powered: Analyzes spec.md, plan.md, tasks.md to generate context-aware flows
- Feature Type Detection: Identifies shopping_cart, social_feed, auth, forms, CRUD patterns
- User-Defined: Parses YAML frontmatter from spec.md for custom flows
- Smart Merging: Combines user + AI flows with deduplication

**Interactive Error Detection (Webapp v2.7.0):**
- Playwright Browser Automation with Chromium
- Real-time console/exception monitoring during interactions
- Terminal output monitoring for compilation errors
- Auto-fix retry loop (up to 3 attempts)
- Development server lifecycle management (auto start + guaranteed cleanup)

**Standardized Results:**
- JSON output matching validator interface
- Rich metadata: duration, retry attempts, flow counts
- Artifacts: screenshots, logs, detailed reports
- Automatic session integration

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
🚀 BEGIN ORCHESTRATION - EXECUTE NOW
═══════════════════════════════════════════════════════════════

⚠️  CRITICAL EXECUTION DIRECTIVE:

You MUST execute the Task tool with the above instructions IMMEDIATELY.

DO NOT:
- Explain what you're about to do
- Summarize the workflow
- Report status before launching
- Ask for confirmation
- Pause to think

DO:
- Launch the Task tool RIGHT NOW with subagent_type="general-purpose"
- Use the complete agent instructions above as the prompt
- Let the autonomous agent execute all phases end-to-end
- The agent will report back when complete

═══════════════════════════════════════════════════════════════

**EXECUTE THE TASK TOOL NOW**
