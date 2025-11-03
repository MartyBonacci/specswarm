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

  echo "🎯 Feature Orchestrator v2.6.0 - AI-Powered Flow Validation"
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

${RUN_VALIDATE} = true enables AI-powered flow validation (Phase 2.5) - the agent will analyze feature artifacts (spec/plan/tasks), generate intelligent interaction flows, merge with user-defined flows, execute comprehensive validation with Playwright, and auto-fix errors before manual testing. Dev server will be stopped before returning control to user.

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

  ### Step 2.5.1: Pre-Validation Setup & Intelligent Flow Generation
  - Report: "🔍 Starting interactive error detection with Playwright (--validate enabled)"
  - Create validation directory: ${PROJECT_PATH}/.speclabs/validation/
  - Initialize error retry counter: error_retry_count=0
  - Set max error retries: max_error_retries=3

  **A. Parse User-Defined Flows (from spec.md)**
  - Locate spec.md in features/ directory
  - Use Read tool to read spec.md
  - Parse YAML frontmatter to extract `interaction_flows` section (if present)
  - Validate flow structure:
    - Each flow must have: id, name, description, priority, requires_auth, steps
    - Each step must have: action, description
    - Action-specific required fields:
      - navigate: target (URL)
      - click/verify_text/verify_visible/wait_for_selector: selector
      - type: selector + text
      - screenshot: filename
  - Store valid user-defined flows in memory
  - Report: "📝 Found ${user_flow_count} user-defined flows in spec.md"

  **B. AI-Powered Flow Generation (from feature artifacts)**

  **B1. Read Feature Artifacts:**
  - Use Read tool to read:
    - spec.md: Full content (user stories, acceptance criteria, user flows, functional requirements, API specs)
    - plan.md: Full content (components, routes, implementation phases, data models)
    - tasks.md: Full content (task descriptions, acceptance criteria, user story mappings)

  **B2. Extract Key Information:**
  - From spec.md:
    - Parse ## User Stories section → extract story ID, title, scenario, acceptance criteria
    - Parse ### User Flow sections → extract step-by-step interaction sequences
    - Parse ## Functional Requirements → identify P0/P1 requirements
    - Parse ## User Interface → identify pages, components, user flows
    - Parse ## API Specification → identify endpoints, auth requirements

  - From plan.md:
    - Extract component names from ### Components section
    - Extract route paths from ### Routes section
    - Extract API endpoint paths from ### API Endpoints section

  - From tasks.md:
    - Extract task IDs, descriptions, acceptance criteria
    - Map tasks to user stories
    - Identify implemented components and features

  **B3. Feature Type Detection:**
  - Analyze extracted information to detect feature type:
    - **shopping_cart**: Keywords: cart, checkout, purchase, order, product
    - **social_feed**: Keywords: feed, post, tweet, like, comment, share
    - **authentication**: Keywords: login, signin, signup, register, auth
    - **profile**: Keywords: profile, settings, account, user info
    - **search**: Keywords: search, filter, query, results
    - **crud**: Keywords: create, read, update, delete, edit, list
    - **form**: Keywords: form, submit, input, validate, field
  - Use keyword frequency and context to determine primary feature type
  - Report detected type: "🎯 Detected feature type: ${feature_type}"

  **B4. Generate AI Flows Based on Feature Type:**

  **For ALL Features (baseline flows):**
  - Generate navigation flow:
    - Test all routes mentioned in plan.md
    - Click navigation links found in spec.md user flows
    - Verify page loads without errors

  **For shopping_cart features:**
  - Generate "Browse Products" flow:
    - Navigate to /products (or equivalent from routes)
    - Wait for product grid/list to load
    - Screenshot products page
  - Generate "Add to Cart" flow:
    - Navigate to products
    - Click "Add to Cart" button (use data-testid or button text from acceptance criteria)
    - Verify cart badge increments
    - Open cart view
    - Verify item appears in cart
    - Screenshot cart with item
  - Generate "Remove from Cart" flow:
    - Add item to cart
    - Open cart
    - Click remove button
    - Verify cart badge decrements
    - Verify empty cart message (if mentioned in requirements)
  - Generate "Checkout" flow:
    - Add item to cart
    - Proceed to checkout
    - Fill shipping form fields (use field names from plan.md)
    - Fill payment form fields
    - Submit order
    - Verify confirmation page/message
    - Screenshot confirmation

  **For social_feed features:**
  - Generate "View Feed" flow:
    - Navigate to feed route
    - Wait for posts/tweets to load
    - Screenshot feed
  - Generate "Post Content" flow:
    - Navigate to feed
    - Find post composer (from components in plan.md)
    - Type content into textarea
    - Verify character counter (if mentioned)
    - Click submit
    - Verify new post appears at top
  - Generate "Interaction" flow (if like/comment mentioned):
    - Navigate to feed
    - Click like button on first post
    - Verify like count increments
    - Verify button state changes

  **For authentication features:**
  - Generate "Sign Up" flow:
    - Navigate to signup route
    - Fill registration form fields
    - Submit form
    - Verify success message or redirect
  - Generate "Login" flow:
    - Navigate to login route
    - Fill credentials (test data)
    - Submit form
    - Verify redirect to authenticated area
  - Generate "Logout" flow:
    - Login first
    - Click logout button
    - Verify redirect to public page

  **For form features:**
  - Generate "Form Validation" flow:
    - Navigate to form route
    - Submit empty form
    - Verify validation errors appear
    - Fill required fields
    - Submit form
    - Verify success message

  **For crud features:**
  - Generate "Create" flow:
    - Navigate to create route
    - Fill form fields
    - Submit
    - Verify item appears in list
  - Generate "Read/List" flow:
    - Navigate to list route
    - Verify items load
    - Click item to view details
  - Generate "Update" flow:
    - Navigate to edit route
    - Modify fields
    - Save
    - Verify changes reflected
  - Generate "Delete" flow:
    - Navigate to list
    - Click delete on item
    - Verify item removed from list

  **B5. Map User Stories to Custom Flows:**
  - For each user story in spec.md:
    - Extract acceptance criteria
    - Generate flow steps from criteria:
      - "User can [action]" → generate action step
      - "User sees [element]" → generate verify_visible step
      - "System displays [message]" → generate verify_text step
    - Name flow: "${user_story.title} Flow"
    - Set priority based on story priority (primary=critical, secondary=high)
    - Link to user story ID
  - Report: "🤖 Generated ${ai_flow_count} AI flows from feature analysis"

  **C. Merge User-Defined + AI Flows**

  **C1. ID-Based Deduplication:**
  - Create flow map with user-defined flows first
  - For each AI flow:
    - If ID already exists → skip (user override)
    - Else → add to map
  - Report any overrides: "ℹ️ User flow '${id}' overrides AI flow"

  **C2. Semantic Similarity Detection:**
  - For each flow pair in map:
    - Create signature from step actions and targets
    - Compare signatures for similarity > 0.8
    - If similar:
      - Keep user-defined version if present
      - Else keep first AI version
      - Report: "ℹ️ Merged similar flows: '${flow1.id}' and '${flow2.id}'"

  **C3. Priority Sorting:**
  - Sort merged flows by:
    - Priority (critical → high → medium → low)
    - Source (user-defined before ai-generated at same priority)

  **C4. Write Merged Flows:**
  - Use Write tool to create: ${PROJECT_PATH}/.speclabs/validation/flows.json
  - Write array of merged flows with metadata:
    ```json
    [
      {
        "id": "flow-id",
        "name": "Flow Name",
        "description": "What this tests",
        "priority": "critical",
        "user_story": "US1",
        "requires_auth": false,
        "source": "user-defined",
        "steps": [...]
      },
      ...
    ]
    ```

  **D. Flow Execution Summary**
  - Report flow merge summary:
    - "📋 Flow Generation Summary:"
    - "   User-defined flows: ${user_count}"
    - "   AI-generated flows: ${ai_count}"
    - "   Total flows after merge: ${total_count} (${duplicates_removed} duplicates removed)"
    - ""
    - "🎯 Execution Order:"
    - For each flow: "   ${index}. [${priority}] ${name} (${source})"

  **E. Install Playwright:**
  - Install Playwright if not present:
    ```bash
    cd ${PROJECT_PATH} && npx playwright install chromium --with-deps
    ```
  - Report: "✅ Playwright ready"

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

    **Create Flow-Based Playwright Test Script:**
    - Use Write tool to create: ${PROJECT_PATH}/.speclabs/validation/flow-validation-test.js
    - Script content:
      ```javascript
      const { chromium } = require('playwright');
      const fs = require('fs');

      // Load flows from JSON
      const flows = JSON.parse(fs.readFileSync('.speclabs/validation/flows.json', 'utf-8'));

      (async () => {
        const results = {
          flows: [],
          summary: { total: 0, passed: 0, failed: 0 },
          errors: []
        };

        const browser = await chromium.launch({ headless: true });
        const context = await browser.newContext({
          viewport: { width: 1280, height: 720 }
        });

        // Execute each flow
        for (const flow of flows) {
          console.log(\`\n🧪 Running: \${flow.name} (\${flow.source})\`);

          const page = await context.newPage();
          const flowResult = await executeFlow(page, flow);

          results.flows.push(flowResult);
          results.summary.total++;

          if (flowResult.success) {
            results.summary.passed++;
            console.log(\`   ✅ PASSED\`);
          } else {
            results.summary.failed++;
            results.errors.push(...flowResult.errors);
            console.log(\`   ❌ FAILED: \${flowResult.errors[0]?.message}\`);
          }

          await page.close();
        }

        // Save results
        fs.writeFileSync('.speclabs/validation/flow-results.json', JSON.stringify(results, null, 2));

        await browser.close();

        // Exit with appropriate code
        process.exit(results.summary.failed > 0 ? 1 : 0);
      })();

      async function executeFlow(page, flow) {
        const flowResult = {
          id: flow.id,
          name: flow.name,
          source: flow.source,
          success: true,
          errors: [],
          stepResults: []
        };

        // Setup console/page error listeners
        let currentStep = 0;
        page.on('console', msg => {
          if (msg.type() === 'error') {
            flowResult.errors.push({
              type: 'console',
              message: msg.text(),
              location: msg.location(),
              step: currentStep
            });
          }
        });

        page.on('pageerror', exception => {
          flowResult.errors.push({
            type: 'exception',
            message: exception.message,
            stack: exception.stack,
            step: currentStep
          });
        });

        // Execute each step
        for (let i = 0; i < flow.steps.length; i++) {
          const step = flow.steps[i];
          currentStep = i + 1;

          try {
            await executeStep(page, step, flowResult);
            flowResult.stepResults.push({ step: currentStep, success: true });
          } catch (error) {
            flowResult.success = false;
            flowResult.errors.push({
              type: 'step-failure',
              step: currentStep,
              action: step.action,
              message: error.message
            });
            flowResult.stepResults.push({ step: currentStep, success: false, error: error.message });
            break; // Stop flow on first failure
          }
        }

        return flowResult;
      }

      async function executeStep(page, step, flowResult) {
        console.log(\`      \${step.action}: \${step.description}\`);

        switch (step.action) {
          case 'navigate':
            await page.goto('http://localhost:5173' + step.target, { waitUntil: 'networkidle', timeout: 30000 });
            break;

          case 'click':
            await page.click(step.selector);
            break;

          case 'type':
            await page.fill(step.selector, step.text);
            break;

          case 'verify_text':
            const actualText = await page.textContent(step.selector);
            if (actualText !== step.expected) {
              throw new Error(\`Expected "\${step.expected}", got "\${actualText}"\`);
            }
            break;

          case 'verify_visible':
            const isVisible = await page.isVisible(step.selector);
            if (!isVisible) {
              throw new Error(\`Element not visible: \${step.selector}\`);
            }
            break;

          case 'wait_for_selector':
            await page.waitForSelector(step.selector, { timeout: step.timeout || 5000 });
            break;

          case 'screenshot':
            await page.screenshot({
              path: \`.speclabs/validation/screenshots/\${step.filename}.png\`,
              fullPage: true
            });
            break;

          case 'scroll':
            await page.locator(step.selector).scrollIntoViewIfNeeded();
            break;

          case 'hover':
            await page.hover(step.selector);
            break;

          case 'select':
            await page.selectOption(step.selector, step.value);
            break;
        }

        // Wait after step if specified
        if (step.wait) {
          await page.waitForTimeout(step.wait);
        }
      }
      ```

    **Run Flow-Based Validation:**
    - Use Bash tool:
      ```bash
      mkdir -p ${PROJECT_PATH}/.speclabs/validation/screenshots && cd ${PROJECT_PATH} && node .speclabs/validation/flow-validation-test.js 2>&1 | tee .speclabs/validation/test-output-${error_retry_count}.log
      ```
    - Capture exit code to determine if flows passed/failed

    **Monitor Terminal Output:**
    - Use Read tool to read last 100 lines of dev-server.log
    - Look for error patterns:
      - "Error:", "ERROR", "Failed to compile"
      - Stack traces
      - Uncaught exceptions
      - Module not found errors
    - Document any terminal errors found

    **Parse Flow Results:**
    - Use Read tool to read: .speclabs/validation/flow-results.json
    - Extract summary: total_flows, passed_flows, failed_flows
    - Extract all errors from results.errors array
    - Count errors by type (console, exception, step-failure)
    - Count terminal errors from dev-server.log
    - Create total error count (flow errors + terminal errors)

    **Decision Point:**
    - IF all flows passed AND no errors found (browser + terminal clean):
      - Report: "✅ All ${total_flows} interaction flows passed - no errors detected"
      - BREAK out of retry loop
      - Continue to Step 2.5.4

    - IF flows failed OR errors found:
      - Report: "⚠️ Flow validation results (attempt ${error_retry_count + 1}/${max_error_retries}):"
      - Report: "   Flows: ${passed_flows}/${total_flows} passed, ${failed_flows}/${total_flows} failed"
      - Report: "   Errors: ${total_error_count} total"
      - Report error breakdown by type:
        - "      Console errors: ${console_error_count}"
        - "      Uncaught exceptions: ${exception_error_count}"
        - "      Step failures: ${step_failure_count}"
        - "      Terminal errors: ${terminal_error_count}"
      - Create detailed flow-aware error report: .speclabs/validation/error-report-${error_retry_count}.md
      - Include for each failed flow:
        - Flow name, ID, source
        - Failed step number and description
        - Error message and stack trace
        - Console/page errors captured during that flow

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

  ### Step 2.5.5: Flow-Based Validation Summary
  - Create summary report: .speclabs/validation/validation-summary.md
  - Include:
    - **Flow Generation**:
      - User-defined flows: ${user_flow_count}
      - AI-generated flows: ${ai_flow_count}
      - Total flows executed: ${total_flow_count}
      - Detected feature type: ${feature_type}
    - **Execution Results**:
      - Total retry attempts: ${error_retry_count}
      - Flows passed: ${final_passed_flows}/${total_flow_count} (${pass_rate}%)
      - Flows failed: ${final_failed_flows}/${total_flow_count}
      - Errors found initially: ${initial_error_count}
      - Errors fixed: ${fixed_error_count}
      - Errors remaining: ${remaining_error_count}
    - **Artifacts Generated**:
      - Screenshots captured: List all .speclabs/validation/screenshots/*.png files
      - Flow results: flow-results.json
      - Test output logs: test-output-*.log
      - Error reports: error-report-*.md (if errors found)
      - Fix documentation: fixes-applied-*.md (if fixes attempted)
  - Report final status:
    - IF all flows passed AND remaining_error_count = 0:
      - "✅ FLOW-BASED VALIDATION PASSED"
      - "   - Flows executed: ${total_flow_count}"
      - "   - All flows passed: ${total_flow_count}/${total_flow_count}"
      - "   - Browser console: Clean"
      - "   - Terminal output: Clean"
      - "   - Feature type: ${feature_type}"
      - "   - User flows: ${user_flow_count}, AI flows: ${ai_flow_count}"
    - ELSE:
      - "⚠️ Flow validation completed with issues:"
      - "   - Flows passed: ${final_passed_flows}/${total_flow_count} (${pass_rate}%)"
      - "   - Flows failed: ${final_failed_flows}/${total_flow_count}"
      - "   - Errors remaining: ${remaining_error_count}"
      - ""
      - "   Failed flows:"
      - For each failed flow: "      - [${priority}] ${flow_name} (${source})"
      - ""
      - "   See .speclabs/validation/ for:"
      - "   - flow-results.json (complete flow execution data)"
      - "   - error-report-*.md (detailed error analysis with flow context)"
      - "   - screenshots/*.png (visual states at each step)"
      - "   - dev-server.log (terminal output)"
      - "   - fixes-applied-*.md (attempted fixes documentation)"

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
