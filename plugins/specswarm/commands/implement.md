---
description: Execute the implementation plan by processing and executing all tasks defined in tasks.md
---

<!--
ATTRIBUTION CHAIN:
1. Original: GitHub spec-kit (https://github.com/github/spec-kit)
   Copyright (c) GitHub, Inc. | MIT License
2. Adapted: SpecKit plugin by Marty Bonacci (2025)
3. Forked: SpecSwarm plugin with tech stack management
   by Marty Bonacci & Claude Code (2025)
-->


## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. **Discover Feature Context**:

   **YOU MUST NOW discover the feature context using the Bash tool:**

   a. **Get repository root** by executing:
      ```bash
      git rev-parse --show-toplevel 2>/dev/null || pwd
      ```
      Store the result as REPO_ROOT.

   b. **Get current branch name** by executing:
      ```bash
      git rev-parse --abbrev-ref HEAD 2>/dev/null
      ```
      Store the result as BRANCH.

   c. **Extract feature number from branch name** by executing:
      ```bash
      echo "$BRANCH" | grep -oE '^[0-9]{3}'
      ```
      Store the result as FEATURE_NUM.

   d. **If feature number is empty, find latest feature** by executing:
      ```bash
      ls -1 features/ 2>/dev/null | grep -oE '^[0-9]{3}' | sort -nr | head -1
      ```
      Store the result as FEATURE_NUM.

   e. **Find feature directory** by executing:
      ```bash
      find features -maxdepth 1 -type d -name "${FEATURE_NUM}-*" 2>/dev/null | head -1
      ```
      Combine with REPO_ROOT to get full path as FEATURE_DIR.

   f. **Display to user:**
      ```
      📁 Feature Context
      ✓ Repository: {REPO_ROOT}
      ✓ Branch: {BRANCH}
      ✓ Feature: {FEATURE_NUM}
      ✓ Directory: {FEATURE_DIR}
      ```

2. **Check checklists status** (if FEATURE_DIR/checklists/ exists):
   - Scan all checklist files in the checklists/ directory
   - For each checklist, count:
     * Total items: All lines matching `- [ ]` or `- [X]` or `- [x]`
     * Completed items: Lines matching `- [X]` or `- [x]`
     * Incomplete items: Lines matching `- [ ]`
   - Create a status table:
     ```
     | Checklist | Total | Completed | Incomplete | Status |
     |-----------|-------|-----------|------------|--------|
     | ux.md     | 12    | 12        | 0          | ✓ PASS |
     | test.md   | 8     | 5         | 3          | ✗ FAIL |
     | security.md | 6   | 6         | 0          | ✓ PASS |
     ```
   - Calculate overall status:
     * **PASS**: All checklists have 0 incomplete items
     * **FAIL**: One or more checklists have incomplete items
   
   - **If any checklist is incomplete**:
     * Display the table with incomplete item counts
     * **STOP** and ask: "Some checklists are incomplete. Do you want to proceed with implementation anyway? (yes/no)"
     * Wait for user response before continuing
     * If user says "no" or "wait" or "stop", halt execution
     * If user says "yes" or "proceed" or "continue", proceed to step 3
   
   - **If all checklists are complete**:
     * Display the table showing all checklists passed
     * Automatically proceed to step 3

3. Load and analyze the implementation context:
   - **REQUIRED**: Read tasks.md for the complete task list and execution plan
   - **REQUIRED**: Read plan.md for tech stack, architecture, and file structure
   - **IF EXISTS**: Read data-model.md for entities and relationships
   - **IF EXISTS**: Read contracts/ for API specifications and test requirements
   - **IF EXISTS**: Read research.md for technical decisions and constraints
   - **IF EXISTS**: Read quickstart.md for integration scenarios
   - **IF EXISTS**: Read `/memory/tech-stack.md` for runtime validation (SpecSwarm)

<!-- ========== TECH STACK VALIDATION (SpecSwarm Enhancement) ========== -->
<!-- Added by Marty Bonacci & Claude Code (2025) -->

3b. **Pre-Implementation Tech Stack Validation** (if tech-stack.md exists):

   **Purpose**: Runtime validation before writing any code or imports

   **YOU MUST NOW perform tech stack validation using these steps:**

   1. **Check if tech-stack.md exists** using the Read tool:
      - Try to read `/memory/tech-stack.md`
      - If file doesn't exist: Skip this entire section (3b)
      - If file exists: Continue with validation

   2. **Load Tech Stack Compliance Report** from plan.md using the Read tool:
      - Read `${FEATURE_DIR}/plan.md`
      - Search for "Tech Stack Compliance Report" section
      - If section does NOT exist: Skip validation (plan created before SpecSwarm)
      - If section DOES exist: Continue to step 3

   3. **Verify All Conflicts Resolved** using the Grep tool:

      a. Search for conflicts:
         ```bash
         grep -q "⚠️ Conflicting Technologies" "${FEATURE_DIR}/plan.md"
         ```

      b. If conflicts found, check if unresolved:
         ```bash
         grep -q "**Your choice**: _\[" "${FEATURE_DIR}/plan.md"
         ```

      c. If unresolved choices found:
         - **HALT** implementation
         - Display error: "❌ Tech stack conflicts still unresolved"
         - Display message: "Cannot implement until all conflicts in plan.md are resolved"
         - Stop execution

   4. **Verify No Prohibited Technologies in Plan** using the Grep tool:

      a. Search for prohibited techs:
         ```bash
         grep -q "❌ Prohibited Technologies" "${FEATURE_DIR}/plan.md"
         ```

      b. If found, check if blocking:
         ```bash
         grep -q "**Cannot proceed**" "${FEATURE_DIR}/plan.md"
         ```

      c. If blocking issues found:
         - **HALT** implementation
         - Display error: "❌ Prohibited technologies still present in plan.md"
         - Display message: "Remove or replace prohibited technologies before implementing"
         - Stop execution

   4. **Load Prohibited Technologies List**:
      ```bash
      # Extract all prohibited technologies from tech-stack.md
      PROHIBITED_TECHS=()
      APPROVED_ALTERNATIVES=()

      while IFS= read -r line; do
        if [[ $line =~ ^-\ ❌\ (.*)\ \(use\ (.*)\ instead\) ]]; then
          PROHIBITED_TECHS+=("${BASH_REMATCH[1]}")
          APPROVED_ALTERNATIVES+=("${BASH_REMATCH[2]}")
        fi
      done < <(grep "❌" "${REPO_ROOT}/memory/tech-stack.md")
      ```

   5. **Runtime Import/Dependency Validation**:

      **BEFORE writing ANY file that contains imports or dependencies:**

      ```bash
      # For each import statement or dependency about to be written:
      check_technology_compliance() {
        local TECH_NAME="$1"
        local FILE_PATH="$2"
        local LINE_CONTENT="$3"

        # Check if technology is prohibited
        for i in "${!PROHIBITED_TECHS[@]}"; do
          PROHIBITED="${PROHIBITED_TECHS[$i]}"
          APPROVED="${APPROVED_ALTERNATIVES[$i]}"

          if echo "$TECH_NAME" | grep -qi "$PROHIBITED"; then
            ERROR "Prohibited technology detected: $PROHIBITED"
            MESSAGE "File: $FILE_PATH"
            MESSAGE "Line: $LINE_CONTENT"
            MESSAGE "❌ Cannot use: $PROHIBITED"
            MESSAGE "✅ Must use: $APPROVED"
            MESSAGE "See /memory/tech-stack.md for details"
            HALT
          fi
        done

        # Check if technology is unapproved (warn but allow)
        if ! grep -qi "$TECH_NAME" "${REPO_ROOT}/memory/tech-stack.md" 2>/dev/null; then
          WARNING "Unapproved technology: $TECH_NAME"
          MESSAGE "File: $FILE_PATH"
          MESSAGE "This library is not in tech-stack.md"
          PROMPT "Continue anyway? (yes/no)"
          read -r RESPONSE
          if [[ ! "$RESPONSE" =~ ^[Yy] ]]; then
            MESSAGE "Halting. Please add $TECH_NAME to tech-stack.md or choose approved alternative"
            HALT
          fi
        fi
      }
      ```

   6. **Validation Triggers**:

      **JavaScript/TypeScript**:
      - Before writing: `import ... from '...'`
      - Before writing: `require('...')`
      - Before writing: `npm install ...` or `yarn add ...`
      - Extract library name and validate

      **Python**:
      - Before writing: `import ...` or `from ... import ...`
      - Before writing: `pip install ...`
      - Extract module name and validate

      **Go**:
      - Before writing: `import "..."`
      - Before executing: `go get ...`
      - Extract package name and validate

      **General**:
      - Before writing any `package.json` dependencies
      - Before writing any `requirements.txt` entries
      - Before writing any `go.mod` require statements
      - Before writing any `composer.json` dependencies

   7. **Pattern Validation**:

      Check for prohibited patterns (not just libraries):
      ```bash
      validate_code_pattern() {
        local FILE_CONTENT="$1"
        local FILE_PATH="$2"

        # Check for prohibited patterns from tech-stack.md
        # Example: "Class components" prohibited
        if echo "$FILE_CONTENT" | grep -q "class.*extends React.Component"; then
          ERROR "Prohibited pattern: Class components"
          MESSAGE "File: $FILE_PATH"
          MESSAGE "Use functional components instead"
          HALT
        fi

        # Example: "Redux" prohibited
        if echo "$FILE_CONTENT" | grep -qi "createStore\|configureStore.*@reduxjs"; then
          ERROR "Prohibited library: Redux"
          MESSAGE "File: $FILE_PATH"
          MESSAGE "Use React Router loaders/actions instead"
          HALT
        fi
      }
      ```

   8. **Continuous Validation**:
      - Run validation before EVERY file write operation
      - Run validation before EVERY package manager command
      - Run validation before EVERY import statement
      - Accumulate violations and report at end if in batch mode

<!-- ========== END TECH STACK VALIDATION ========== -->

4. **Project Setup Verification**:
   - **REQUIRED**: Create/verify ignore files based on actual project setup:
   
   **Detection & Creation Logic**:
   - Check if the following command succeeds to determine if the repository is a git repo (create/verify .gitignore if so):

     ```sh
     git rev-parse --git-dir 2>/dev/null
     ```
   - Check if Dockerfile* exists or Docker in plan.md → create/verify .dockerignore
   - Check if .eslintrc* or eslint.config.* exists → create/verify .eslintignore
   - Check if .prettierrc* exists → create/verify .prettierignore
   - Check if .npmrc or package.json exists → create/verify .npmignore (if publishing)
   - Check if terraform files (*.tf) exist → create/verify .terraformignore
   - Check if .helmignore needed (helm charts present) → create/verify .helmignore
   
   **If ignore file already exists**: Verify it contains essential patterns, append missing critical patterns only
   **If ignore file missing**: Create with full pattern set for detected technology
   
   **Common Patterns by Technology** (from plan.md tech stack):
   - **Node.js/JavaScript**: `node_modules/`, `dist/`, `build/`, `*.log`, `.env*`
   - **Python**: `__pycache__/`, `*.pyc`, `.venv/`, `venv/`, `dist/`, `*.egg-info/`
   - **Java**: `target/`, `*.class`, `*.jar`, `.gradle/`, `build/`
   - **C#/.NET**: `bin/`, `obj/`, `*.user`, `*.suo`, `packages/`
   - **Go**: `*.exe`, `*.test`, `vendor/`, `*.out`
   - **Universal**: `.DS_Store`, `Thumbs.db`, `*.tmp`, `*.swp`, `.vscode/`, `.idea/`
   
   **Tool-Specific Patterns**:
   - **Docker**: `node_modules/`, `.git/`, `Dockerfile*`, `.dockerignore`, `*.log*`, `.env*`, `coverage/`
   - **ESLint**: `node_modules/`, `dist/`, `build/`, `coverage/`, `*.min.js`
   - **Prettier**: `node_modules/`, `dist/`, `build/`, `coverage/`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
   - **Terraform**: `.terraform/`, `*.tfstate*`, `*.tfvars`, `.terraform.lock.hcl`

5. Parse tasks.md structure and extract:
   - **Task phases**: Setup, Tests, Core, Integration, Polish
   - **Task dependencies**: Sequential vs parallel execution rules
   - **Task details**: ID, description, file paths, parallel markers [P]
   - **Execution flow**: Order and dependency requirements

6. Execute implementation following the task plan:
   - **Phase-by-phase execution**: Complete each phase before moving to the next
   - **Respect dependencies**: Run sequential tasks in order, parallel tasks [P] can run together  
   - **Follow TDD approach**: Execute test tasks before their corresponding implementation tasks
   - **File-based coordination**: Tasks affecting the same files must run sequentially
   - **Validation checkpoints**: Verify each phase completion before proceeding

7. Implementation execution rules:
   - **Setup first**: Initialize project structure, dependencies, configuration
   - **Tests before code**: If you need to write tests for contracts, entities, and integration scenarios
   - **Core development**: Implement models, services, CLI commands, endpoints
   - **Integration work**: Database connections, middleware, logging, external services
   - **Polish and validation**: Unit tests, performance optimization, documentation

8. Progress tracking and error handling:
   - Report progress after each completed task
   - Halt execution if any non-parallel task fails
   - For parallel tasks [P], continue with successful tasks, report failed ones
   - Provide clear error messages with context for debugging
   - Suggest next steps if implementation cannot proceed
   - **IMPORTANT** For completed tasks, make sure to mark the task off as [X] in the tasks file.

9. Completion validation:
   - Verify all required tasks are completed
   - Check that implemented features match the original specification
   - Validate that tests pass and coverage meets requirements
   - Confirm the implementation follows the technical plan
   - Report final status with summary of completed work

<!-- ========== SSR PATTERN VALIDATION ========== -->
<!-- Added by Marty Bonacci & Claude Code (2025-10-15) -->

9b. **SSR Architecture Validation** - Prevent Bug 913-type issues:

   **Purpose**: Detect hardcoded URLs and relative URLs in server-side rendering contexts

   **YOU MUST NOW run SSR pattern validation using the Bash tool:**

   1. **Execute SSR validator:**
      ```bash
      cd ${REPO_ROOT} && bash ~/.claude/plugins/marketplaces/specswarm-marketplace/plugins/specswarm/lib/ssr-validator.sh
      ```

   2. **Parse validation results:**
      - Exit code 0: No issues found (✓ PASS)
      - Exit code 1: Issues detected (⚠️ FAIL)

   3. **If issues detected:**

      a. **Display issue summary** from validator output

      b. **Ask user for action:**
         ```
         ⚠️  SSR Pattern Issues Detected
         ================================

         Would you like me to:
         1. Auto-fix common issues (create getApiUrl helper, update imports)
         2. Show detailed issues and fix manually
         3. Skip (continue anyway - NOT RECOMMENDED)

         Choose (1/2/3):
         ```

      c. **If user chooses option 1 (Auto-fix):**
         - Check if app/utils/api.ts exists
         - If not, create it with getApiUrl() helper:
           ```typescript
           export function getApiUrl(path: string): string {
             const base = typeof window !== 'undefined'
               ? ''
               : process.env.API_BASE_URL || 'http://localhost:3000';
             return `${base}${path}`;
           }
           ```
         - Scan all files with hardcoded URLs using Grep tool
         - For each file:
           * Add import: `import { getApiUrl } from '../utils/api';`
           * Replace `fetch('http://localhost:3000/api/...')` with `fetch(getApiUrl('/api/...'))`
           * Replace `fetch('/api/...')` in loaders/actions with `fetch(getApiUrl('/api/...'))`
         - Re-run SSR validator to confirm fixes
         - Display: "✅ Auto-fix complete. All SSR patterns corrected."

      d. **If user chooses option 2 (Manual fix):**
         - Display detailed issue list from validator
         - Display recommendations
         - Wait for user to fix manually
         - Offer to re-run validator: "Type 'validate' to re-check or 'continue' to proceed"

      e. **If user chooses option 3 (Skip):**
         - Display warning: "⚠️ Skipping SSR validation. Production deployment may fail."
         - Continue to next step

   4. **If no issues found:**
      - Display: "✅ SSR patterns validated - No architectural issues detected"
      - Continue to next step

   **IMPORTANT**: This validation prevents production failures from Bug 913-type issues (relative URLs in SSR contexts).

<!-- ========== END SSR PATTERN VALIDATION ========== -->

<!-- ========== QUALITY VALIDATION (SpecSwarm Phase 1) ========== -->
<!-- Added by Marty Bonacci & Claude Code (2025) -->

10. **Quality Validation** - CRITICAL STEP, MUST EXECUTE:

   **Purpose**: Automated quality assurance before merge

   **YOU MUST NOW CHECK FOR AND RUN QUALITY VALIDATION:**

   1. **First**, check if quality standards file exists by reading the file at `${REPO_ROOT}/memory/quality-standards.md` using the Read tool.

   2. **If the file does NOT exist:**
      - Display this message to the user:
        ```
        ℹ️  Quality Validation
        ====================

        No quality standards defined. Skipping automated validation.

        To enable quality gates:
          1. Create /memory/quality-standards.md
          2. Define minimum coverage and quality score
          3. Configure test requirements

        See: plugins/specswarm/templates/quality-standards-template.md
        ```
      - Then proceed directly to Step 11 (Git Workflow)

   3. **If the file EXISTS, you MUST execute the full quality validation workflow using the Bash tool:**

      a. **Display header** by outputting directly to the user:
         ```
         🧪 Running Quality Validation
         =============================
         ```

      b. **Detect test frameworks** using the Bash tool:
         ```bash
         cd ${REPO_ROOT} && bash ~/.claude/plugins/marketplaces/specswarm-marketplace/plugins/specswarm/lib/test-framework-detector.sh
         ```
         Parse the JSON output to extract:
         - List of all detected frameworks
         - Primary framework (highest priority)
         - Framework count
         Store primary framework for use in tests.

      c. **Run unit tests** using the detected framework:

         **YOU MUST NOW run tests using the Bash tool:**

         1. **Source the test detector library:**
            ```bash
            source ~/.claude/plugins/marketplaces/specswarm-marketplace/plugins/specswarm/lib/test-framework-detector.sh
            ```

         2. **Run tests for primary framework:**
            ```bash
            run_tests "{PRIMARY_FRAMEWORK}" ${REPO_ROOT}
            ```

         3. **Parse test results:**
            ```bash
            parse_test_results "{PRIMARY_FRAMEWORK}" "{TEST_OUTPUT}"
            ```
            Extract: total, passed, failed, skipped counts

         4. **Display results to user:**
            ```
            1. Unit Tests ({FRAMEWORK_NAME})
            ✓ Total: {TOTAL}
            ✓ Passed: {PASSED} ({PASS_RATE}%)
            ✗ Failed: {FAILED}
            ⊘ Skipped: {SKIPPED}
            ```

      d. **Measure code coverage** (if coverage tool available):

         **YOU MUST NOW measure coverage using the Bash tool:**

         1. **Check for coverage tool:**
            ```bash
            source ~/.claude/plugins/marketplaces/specswarm-marketplace/plugins/specswarm/lib/test-framework-detector.sh
            detect_coverage_tool "{PRIMARY_FRAMEWORK}" ${REPO_ROOT}
            ```

         2. **If coverage tool detected, run coverage:**
            ```bash
            run_coverage "{PRIMARY_FRAMEWORK}" ${REPO_ROOT}
            ```
            Parse coverage percentage from output.

         3. **Calculate proportional coverage score (Phase 2 Enhancement):**
            - Read min_coverage from quality-standards.md (default 80%)
            - Calculate score using proportional formula:
              * Coverage >= 90%: 25 points (full credit)
              * Coverage 80-89%: 20-24 points (proportional)
              * Coverage 70-79%: 15-19 points (proportional)
              * Coverage 60-69%: 10-14 points (proportional)
              * Coverage 50-59%: 5-9 points (proportional)
              * Coverage < 50%: 0-4 points (proportional)

            Formula: `score = min(25, (coverage / 90) * 25)`

         4. **Display results to user:**
            ```
            3. Code Coverage
            Coverage: {COVERAGE}%
            Target: {TARGET}%
            Score: {SCORE}/25 points
            Status: {EXCELLENT/GOOD/ACCEPTABLE/NEEDS IMPROVEMENT/INSUFFICIENT}
            ```

         5. **If no coverage tool:**
            - Display: "Coverage measurement not configured (0 points)"
            - Score: 0 points

      e. **Detect browser test framework**:
         ```bash
         cd ${REPO_ROOT} && source ~/.claude/plugins/marketplaces/specswarm-marketplace/plugins/specswarm/lib/quality-gates.sh && detect_browser_test_framework
         ```

      f. **Run browser tests** (if Playwright/Cypress detected):
         - For Playwright: `npx playwright test 2>&1 | tail -30`
         - For Cypress: `npx cypress run 2>&1 | tail -30`
         - Parse results (passed/failed/total)
         - Display with "4. Browser Tests" header
         - If no browser framework: Display "No browser test framework detected - Skipping"

      f2. **Analyze bundle sizes** (Phase 3 Enhancement):

         **YOU MUST NOW analyze bundle sizes using the Bash tool:**

         1. **Run bundle size monitor:**
            ```bash
            cd ${REPO_ROOT} && bash ~/.claude/plugins/marketplaces/specswarm-marketplace/plugins/speclabs/lib/bundle-size-monitor.sh
            ```

         2. **Parse bundle analysis results:**
            - Exit code 0: All bundles within budget (✓ PASS)
            - Exit code 1: Large bundles detected (⚠️ WARNING)
            - Exit code 2: Critical bundle size exceeded (🔴 CRITICAL)

         3. **Extract bundle metrics:**
            - Total bundle size (in KB)
            - Number of large bundles (>500KB)
            - Number of critical bundles (>1MB)
            - List of top 5 largest bundles

         4. **Calculate bundle size score:**
            - < 500KB total: 20 points (excellent)
            - 500-750KB: 15 points (good)
            - 750-1000KB: 10 points (acceptable)
            - 1000-2000KB: 5 points (poor)
            - > 2000KB: 0 points (critical)

         5. **Display results to user:**
            ```
            5. Bundle Size Performance
            Total Size: {TOTAL_SIZE}
            Largest Bundle: {LARGEST_BUNDLE}
            Score: {SCORE}/20 points
            Status: {EXCELLENT/GOOD/ACCEPTABLE/POOR/CRITICAL}
            ```

         6. **If no build directory found:**
            - Display: "No build artifacts found - Run build first (0 points)"
            - Score: 0 points
            - Note: Bundle size analysis requires a production build

         7. **Track bundle size in metrics:**
            - Add bundle_size_kb to metrics.json
            - Enables bundle size tracking over time

      f3. **Enforce performance budgets** (Phase 3 Enhancement - Optional):

         **YOU MUST NOW check if performance budgets are defined:**

         1. **Check for budget configuration:**
            - Read quality-standards.md using Read tool
            - Look for budget settings:
              * max_bundle_size (KB)
              * max_initial_load (KB)
              * enforce_budgets (true/false)

         2. **If enforce_budgets is true, run enforcement:**
            ```bash
            cd ${REPO_ROOT} && bash ~/.claude/plugins/marketplaces/specswarm-marketplace/plugins/speclabs/lib/performance-budget-enforcer.sh
            ```

         3. **Parse enforcement results:**
            - Exit code 0: All budgets met (✓ PASS)
            - Exit code 1: Budgets violated (❌ FAIL)

         4. **If budgets violated:**
            a. **Display violations** from enforcer output
            b. **Check block_merge setting:**
               - If block_merge_on_budget_violation is true: HALT
               - If false: Warn and ask user "Continue anyway? (yes/no)"

         5. **Display budget status:**
            ```
            ⚡ Performance Budget Status
            - Bundle Size: {PASS/FAIL}
            - Initial Load: {PASS/FAIL}
            Overall: {PASS/FAIL}
            ```

         6. **If no budgets configured:**
            - Skip enforcement
            - Note: "Performance budgets not configured (optional)"

      g. **Calculate quality score** using proportional scoring (Phase 2 & 3 Enhancement):

         **YOU MUST NOW calculate scores for each component:**

         1. **Unit Tests** (0-25 points - proportional by pass rate):
            - 100% passing: 25 points
            - 90-99% passing: 20-24 points (proportional)
            - 80-89% passing: 15-19 points (proportional)
            - 70-79% passing: 10-14 points (proportional)
            - 60-69% passing: 5-9 points (proportional)
            - <60% passing: 0-4 points (proportional)

            Formula: `score = min(25, (pass_rate / 100) * 25)`

         2. **Code Coverage** (0-25 points - proportional by coverage %):
            - >=90% coverage: 25 points
            - 80-89% coverage: 20-24 points (proportional)
            - 70-79% coverage: 15-19 points (proportional)
            - 60-69% coverage: 10-14 points (proportional)
            - 50-59% coverage: 5-9 points (proportional)
            - <50% coverage: 0-4 points (proportional)

            Formula: `score = min(25, (coverage / 90) * 25)`

         3. **Integration Tests** (0-15 points - proportional):
            - 100% passing: 15 points
            - Proportional for <100%
            - 0 points if not detected

            Formula: `score = min(15, (pass_rate / 100) * 15)`

         4. **Browser Tests** (0-15 points - proportional):
            - 100% passing: 15 points
            - Proportional for <100%
            - 0 points if not detected

            Formula: `score = min(15, (pass_rate / 100) * 15)`

         5. **Bundle Size** (0-20 points - Phase 3 feature):
            - < 500KB total: 20 points
            - 500-750KB: 15 points
            - 750-1000KB: 10 points
            - 1000-2000KB: 5 points
            - > 2000KB: 0 points
            - No build found: 0 points

         6. **Visual Alignment** (0-15 points - Phase 3 future):
            - Set to 0 for now (screenshot analysis not yet implemented)

         **Total possible: 115 points** (but scaled to 100 for display)

         **Scoring Note**: When Visual Alignment is implemented, adjust other components to maintain 100-point scale.

         **Example Calculation:**
         - Unit Tests: 106/119 passing (89%) → 22.25 points
         - Coverage: 75% → 20.83 points
         - Integration Tests: Not detected → 0 points
         - Browser Tests: Not configured → 0 points
         - Bundle Size: 450KB → 20 points
         - Visual Alignment: Not implemented → 0 points
         - **Total: 63.08/115 points** (scaled to ~55/100)

      h. **Display quality report** with proportional scoring details:
         ```
         Quality Validation Results
         ==========================

         1. Unit Tests ({FRAMEWORK}): {SCORE}/25 points
            ✓ Passed: {PASSED}/{TOTAL} ({PASS_RATE}%)
            ✗ Failed: {FAILED}
            Status: {EXCELLENT/GOOD/ACCEPTABLE/NEEDS IMPROVEMENT}

         2. Code Coverage: {SCORE}/25 points
            Coverage: {COVERAGE}% (target: {TARGET}%)
            Status: {EXCELLENT/GOOD/ACCEPTABLE/NEEDS IMPROVEMENT/INSUFFICIENT}

         3. Integration Tests: {SCORE}/15 points
            {DETAILS or "Not detected"}

         4. Browser Tests: {SCORE}/15 points
            {DETAILS or "Not configured"}

         5. Bundle Size: {SCORE}/20 points
            Total: {TOTAL_SIZE} | Largest: {LARGEST_BUNDLE}
            Status: {EXCELLENT/GOOD/ACCEPTABLE/POOR/CRITICAL}

         6. Visual Alignment: 0/15 points
            Status: Not yet implemented (Phase 3 future)

         ════════════════════════════════════════
         Raw Score: {RAW_SCORE}/115 points
         Scaled Score: {SCALED_SCORE}/100 points
         ════════════════════════════════════════

         Status: {PASS/FAIL} (threshold: {THRESHOLD}/100)

         Score Breakdown:
         ████████████████░░░░░░░░ {SCALED_SCORE}% ({VISUAL_BAR})

         Note: Score scaled from 115-point system to 100-point display
         ```

      i. **Check quality gates** from quality-standards.md:
         - Read min_quality_score (default 80)
         - Read block_merge_on_failure (default false)
         - If score < minimum:
           - If block_merge_on_failure is true: HALT and show error
           - If block_merge_on_failure is false: Show warning and ask user "Continue with merge anyway? (yes/no)"
         - If score >= minimum: Display "✅ Quality validation passed!"

      j. **Save quality metrics** by updating `${REPO_ROOT}/memory/metrics.json`:
         - Add entry for current feature number
         - Include quality score, coverage, test results
         - Use Write tool to update the JSON file

   **IMPORTANT**: You MUST execute this step if quality-standards.md exists. Do NOT skip it. Use the Bash tool to run all commands and parse the results.

   4. **Proactive Quality Improvements** - If quality score < 80/100:

      **YOU MUST NOW offer to improve the quality score:**

      a. **Check for missing coverage tool:**
         - If Vitest was detected but coverage measurement showed 0% or "not configured":
           - Display to user:
             ```
             ⚡ Coverage Tool Not Installed
             =============================

             Installing @vitest/coverage-v8 would add +25 points to your quality score.

             Current: {CURRENT_SCORE}/100
             With coverage: {CURRENT_SCORE + 25}/100

             Would you like me to:
             1. Install coverage tool and re-run validation
             2. Skip (continue without coverage)

             Choose (1 or 2):
             ```
           - If user chooses 1:
             - Run: `npm install --save-dev @vitest/coverage-v8`
             - Check if vitest.config.ts exists using Read tool
             - If exists, update it to add coverage configuration
             - If not exists, create vitest.config.ts with coverage config
             - Re-run quality validation (step 3 above)
             - Display new score

      b. **Check for missing E2E tests:**
         - If Playwright was detected but no tests were found:
           - Display to user:
             ```
             ⚡ No E2E Tests Found
             =====================

             Writing basic E2E tests would add +15 points to your quality score.

             Current: {CURRENT_SCORE}/100
             With E2E tests: {CURRENT_SCORE + 15}/100

             Would you like me to:
             1. Generate basic Playwright test templates
             2. Skip (continue without E2E tests)

             Choose (1 or 2):
             ```
           - If user chooses 1:
             - Create tests/e2e/ directory if not exists
             - Generate basic test file with:
               * Login flow test (if authentication exists)
               * Main feature flow test (based on spec.md)
               * Basic smoke test
             - Run: `npx playwright test`
             - Re-run quality validation
             - Display new score

      c. **Display final improvement summary:**
         ```
         📊 Quality Score Improvement
         ============================

         Before improvements: {ORIGINAL_SCORE}/100
         After improvements:  {FINAL_SCORE}/100
         Increase: +{INCREASE} points

         {STATUS_EMOJI} Quality Status: {PASS/FAIL}
         ```

   **Note**: This proactive improvement step can increase quality scores from 25/100 to 65/100+ automatically.

<!-- ========== END QUALITY VALIDATION ========== -->

11. **Git Workflow Completion** (if git repository):

   **Purpose**: Handle feature branch merge and cleanup after successful implementation

   **INSTRUCTIONS FOR CLAUDE:**

   1. **Check if in a git repository** using Bash tool:
      ```bash
      git rev-parse --git-dir 2>/dev/null
      ```
      If this fails, skip git workflow entirely.

   2. **Get current and main branch names** using Bash:
      ```bash
      git rev-parse --abbrev-ref HEAD
      git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
      ```

   3. **Only proceed if on a feature branch** (not main/master). If already on main, display "Already on main branch" and stop.

   4. **Display git workflow options** to the user:
      ```
      🌳 Git Workflow
      ===============

      Current branch: {CURRENT_BRANCH}
      Main branch: {MAIN_BRANCH}

      Feature implementation complete! What would you like to do?

        1. Merge to {MAIN_BRANCH} and delete feature branch (recommended)
        2. Stay on {CURRENT_BRANCH} for additional work
        3. Switch to {MAIN_BRANCH} without merging (keep branch)

      Choose (1/2/3):
      ```

   5. **Wait for user choice** and proceed based on their selection.

   **OPTION 1: Merge and Delete Branch**

   a. **Check for uncommitted changes** using Bash:
      ```bash
      git diff-index --quiet HEAD --
      ```
      If exit code is non-zero, there are uncommitted changes.

   b. **If there are uncommitted changes:**
      - Display: `git status --short` to show changes
      - Ask user: "Commit these changes first? (yes/no)"

   c. **If user wants to commit, intelligently stage ONLY source files:**

      **CRITICAL - Smart Git Staging (Project-Aware):**

      **YOU MUST NOW perform smart file staging using these steps:**

      1. **Detect project type** by checking for files:
         - Read package.json using Read tool
         - Check for framework indicators:
           * Vite: `vite.config.ts` or `"vite"` in package.json
           * Next.js: `next.config.js` or `"next"` in package.json
           * Remix: `remix.config.js` or `"@remix-run"` in package.json
           * Create React App: `react-scripts` in package.json
           * Node.js generic: package.json exists but no specific framework
         - Store detected type for use in exclusions

      2. **Build exclusion patterns based on project type:**

         a. **Base exclusions (all projects):**
            ```
            ':!node_modules/' ':!.pnpm-store/' ':!.yarn/'
            ':!*.log' ':!coverage/' ':!.nyc_output/'
            ```

         b. **Project-specific exclusions:**
            - Vite: `':!dist/' ':!build/'`
            - Next.js: `':!.next/' ':!out/'`
            - Remix: `':!build/' ':!public/build/'`
            - CRA: `':!build/'`

         c. **Parse .gitignore** using Read tool:
            - Read .gitignore if it exists
            - Extract patterns (lines not starting with #)
            - Convert to pathspec format: `:!{pattern}`
            - Add to exclusion list

      3. **Check for large files** using Bash:
         ```bash
         git status --porcelain | cut -c4- | while read file; do
           if [ -f "$file" ] && [ $(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null) -gt 1048576 ]; then
             echo "$file ($(du -h "$file" | cut -f1))"
           fi
         done
         ```

         a. **If large files found:**
            - Display warning:
              ```
              ⚠️ Large Files Detected
              ======================

              The following files are >1MB:
              - {file1} ({size1})
              - {file2} ({size2})

              These may not belong in git. Add to .gitignore?
              1. Add to .gitignore and skip
              2. Commit anyway
              3. Cancel commit

              Choose (1/2/3):
              ```

            - If option 1: Append to .gitignore, exclude from staging
            - If option 2: Include in staging
            - If option 3: Cancel commit, return to main flow

      4. **Stage files with exclusions** using Bash:
         ```bash
         git add . {BASE_EXCLUSIONS} {PROJECT_EXCLUSIONS} {GITIGNORE_EXCLUSIONS}
         ```

         Example for Vite project:
         ```bash
         git add . ':!node_modules/' ':!dist/' ':!build/' ':!*.log' ':!coverage/'
         ```

      5. **Verify staging** using Bash:
         ```bash
         git diff --cached --name-only
         ```

         a. **Check if any excluded patterns appear:**
            - If `dist/`, `build/`, `.next/`, etc. appear in staged files
            - Display error: "❌ Build artifacts detected in staging"
            - Ask user: "Unstage and retry? (yes/no)"
            - If yes: `git reset` and retry with stricter patterns

      6. **Commit with message** using Bash:
         ```bash
         git commit -m "{USER_PROVIDED_MESSAGE}"
         ```

      **IMPORTANT**: This project-aware staging prevents build artifacts and large files from being committed.

   d. **Merge to main branch:**
      - Test merge first (dry run): `git merge --no-commit --no-ff {CURRENT_BRANCH}`
      - If successful: abort test, do real merge with message
      - If conflicts: abort, show manual resolution steps, stay on feature branch

   e. **Delete feature branch** if merge succeeded:
      ```bash
      git branch -d {CURRENT_BRANCH}
      ```

   **OPTION 2: Stay on Current Branch**
   - Display message about when/how to merge later
   - No git commands needed

   **OPTION 3: Switch to Main (Keep Branch)**
   - Switch to main: `git checkout {MAIN_BRANCH}`
   - Keep feature branch for later

   **IMPORTANT**: When staging files for commit, NEVER use `git add .` - always filter out build artifacts!

Note: This command assumes a complete task breakdown exists in tasks.md. If tasks are incomplete or missing, suggest running `/tasks` first to regenerate the task list.
