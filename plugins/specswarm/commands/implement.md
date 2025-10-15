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
   ```bash
   REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
   BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
   FEATURE_NUM=$(echo "$BRANCH" | grep -oE '^[0-9]{3}')
   [ -z "$FEATURE_NUM" ] && FEATURE_NUM=$(ls -1 features/ 2>/dev/null | grep -oE '^[0-9]{3}' | sort -nr | head -1)
   FEATURE_DIR=$(find features -maxdepth 1 -type d -name "${FEATURE_NUM}-*" 2>/dev/null | head -1)
   FEATURE_DIR="${REPO_ROOT}/${FEATURE_DIR}"
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

   1. **Load Tech Stack Compliance Report** from plan.md:
      - Check if "Tech Stack Compliance Report" section exists
      - If it does NOT exist: Skip validation (plan created before SpecSwarm)
      - If it DOES exist: Proceed with validation

   2. **Verify All Conflicts Resolved**:
      ```bash
      if grep -q "⚠️ Conflicting Technologies" "${FEATURE_DIR}/plan.md"; then
        if grep -q "**Your choice**: _\[" "${FEATURE_DIR}/plan.md"; then
          ERROR "Tech stack conflicts still unresolved"
          MESSAGE "Cannot implement until all conflicts in plan.md are resolved"
          HALT
        fi
      fi
      ```

   3. **Verify No Prohibited Technologies in Plan**:
      ```bash
      if grep -q "❌ Prohibited Technologies" "${FEATURE_DIR}/plan.md"; then
        if grep -q "**Cannot proceed**" "${FEATURE_DIR}/plan.md"; then
          ERROR "Prohibited technologies still present in plan.md"
          MESSAGE "Remove or replace prohibited technologies before implementing"
          HALT
        fi
      fi
      ```

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

<!-- ========== QUALITY VALIDATION (SpecSwarm Phase 1) ========== -->
<!-- Added by Marty Bonacci & Claude Code (2025) -->

10. **Quality Validation** (if quality-standards.md exists):

   **Purpose**: Automated quality assurance before merge

   ```bash
   # Load plugin directory
   PLUGIN_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")"

   # Check if quality standards exist
   QUALITY_STANDARDS="${REPO_ROOT}/memory/quality-standards.md"

   if [ ! -f "$QUALITY_STANDARDS" ]; then
     echo ""
     echo "ℹ️  Quality Validation"
     echo "===================="
     echo ""
     echo "No quality standards defined. Skipping automated validation."
     echo ""
     echo "To enable quality gates:"
     echo "  1. Create /memory/quality-standards.md"
     echo "  2. Define minimum coverage and quality score"
     echo "  3. Configure test requirements"
     echo ""
     echo "See: plugins/specswarm/templates/quality-standards-template.md"
     echo ""
     # Continue to git workflow
   else
     echo ""
     echo "🧪 Running Quality Validation"
     echo "============================="
     echo ""

     # Load quality gates library
     source "${PLUGIN_DIR}/lib/quality-gates.sh"
     source "${PLUGIN_DIR}/lib/visual-validation.sh"

     # 1. Run unit tests
     echo "1. Unit Tests"
     echo "============="
     echo ""

     run_unit_tests
     UNIT_RESULT=$?

     echo ""

     # 2. Run integration tests
     echo "2. Integration Tests"
     echo "===================="
     echo ""

     run_integration_tests
     INTEGRATION_RESULT=$?

     echo ""

     # 3. Measure code coverage
     echo "3. Code Coverage"
     echo "================"
     echo ""

     COVERAGE_PCT=$(measure_coverage)

     echo ""

     # 4. Run browser tests (if framework detected)
     BROWSER_FRAMEWORK=$(detect_browser_test_framework)

     if [ "$BROWSER_FRAMEWORK" != "none" ]; then
       echo "4. Browser Tests"
       echo "================"
       echo ""

       run_browser_tests
       BROWSER_RESULT=$?

       echo ""

       # 5. Visual validation (analyze screenshots)
       echo "5. Visual Validation"
       echo "===================="
       echo ""

       # Determine screenshot directory based on browser framework
       case "$BROWSER_FRAMEWORK" in
         playwright)
           SCREENSHOT_DIR="${REPO_ROOT}/test-results/screenshots"
           ;;
         cypress)
           SCREENSHOT_DIR="${REPO_ROOT}/cypress/screenshots"
           ;;
         *)
           SCREENSHOT_DIR="${FEATURE_DIR}/.screenshots"
           ;;
       esac

       # Analyze screenshots against spec
       analyze_screenshots_against_spec \
         "$SCREENSHOT_DIR" \
         "${FEATURE_DIR}/spec.md" \
         "$FEATURE_DIR"

       VISUAL_SCORE=$?
     else
       echo "4. Browser Tests"
       echo "================"
       echo ""
       echo "  ⊘ No browser test framework detected"
       echo "  Skipping browser tests and visual validation"
       echo ""

       BROWSER_RESULT=2  # Skipped
       VISUAL_SCORE=0
     fi

     # 6. Calculate quality score
     QUALITY_SCORE=$(calculate_quality_score \
       "$UNIT_RESULT" \
       "$INTEGRATION_RESULT" \
       "$COVERAGE_PCT" \
       "$BROWSER_RESULT" \
       "$VISUAL_SCORE")

     # 7. Display quality report
     display_quality_report \
       "$UNIT_RESULT" \
       "$INTEGRATION_RESULT" \
       "$COVERAGE_PCT" \
       "$BROWSER_RESULT" \
       "$VISUAL_SCORE" \
       "$QUALITY_SCORE"

     # 8. Check quality gates
     MIN_QUALITY_SCORE=$(grep "min_quality_score:" "$QUALITY_STANDARDS" 2>/dev/null | awk '{print $2}')
     MIN_QUALITY_SCORE=${MIN_QUALITY_SCORE:-80}

     BLOCK_ON_FAILURE=$(grep "block_merge_on_failure:" "$QUALITY_STANDARDS" 2>/dev/null | awk '{print $2}')
     BLOCK_ON_FAILURE=${BLOCK_ON_FAILURE:-false}

     if [ "$QUALITY_SCORE" -lt "$MIN_QUALITY_SCORE" ]; then
       echo "⚠️  Quality score below minimum (${QUALITY_SCORE} < ${MIN_QUALITY_SCORE})"
       echo ""

       if [ "$BLOCK_ON_FAILURE" = "true" ]; then
         echo "❌ Quality gate FAILED - merge blocked"
         echo ""
         echo "Fix quality issues and re-run /specswarm:implement"
         echo ""
         exit 1
       else
         echo "⚠️  Quality gate warning (soft failure)"
         echo ""
         read -p "Continue with merge anyway? (yes/no): " CONTINUE_CHOICE

         if [[ ! "$CONTINUE_CHOICE" =~ ^[Yy] ]]; then
           echo ""
           echo "Halting. Fix issues and re-run /specswarm:implement"
           echo ""
           exit 1
         fi
         echo ""
       fi
     else
       echo "✅ Quality validation passed!"
       echo ""
     fi

     # 9. Save quality metrics
     save_quality_metrics \
       "$FEATURE_NUM" \
       "$QUALITY_SCORE" \
       "$COVERAGE_PCT" \
       "$VISUAL_SCORE" \
       "$UNIT_RESULT" \
       "$INTEGRATION_RESULT" \
       "$BROWSER_RESULT" \
       "$REPO_ROOT"
   fi
   ```

<!-- ========== END QUALITY VALIDATION ========== -->

11. **Git Workflow Completion** (if git repository):

   **Purpose**: Handle feature branch merge and cleanup after successful implementation

   ```bash
   # Check if we're in a git repository
   if git rev-parse --git-dir >/dev/null 2>&1; then
     CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
     MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

     # Only show workflow if on a feature branch
     if [ "$CURRENT_BRANCH" != "$MAIN_BRANCH" ] && [ "$CURRENT_BRANCH" != "master" ]; then
       echo ""
       echo "🌳 Git Workflow"
       echo "==============="
       echo ""
       echo "Current branch: $CURRENT_BRANCH"
       echo "Main branch: $MAIN_BRANCH"
       echo ""
       echo "Feature implementation complete! What would you like to do?"
       echo ""
       echo "  1. Merge to $MAIN_BRANCH and delete feature branch (recommended)"
       echo "  2. Stay on $CURRENT_BRANCH for additional work"
       echo "  3. Switch to $MAIN_BRANCH without merging (keep branch)"
       echo ""
       read -p "Choose (1/2/3): " GIT_CHOICE

       case $GIT_CHOICE in
         1)
           echo ""
           echo "✅ Merging and cleaning up..."
           echo ""

           # Check for uncommitted changes
           if ! git diff-index --quiet HEAD --; then
             echo "⚠️  You have uncommitted changes."
             echo ""
             git status --short
             echo ""
             read -p "Commit these changes first? (yes/no): " COMMIT_CHOICE

             if [[ "$COMMIT_CHOICE" =~ ^[Yy] ]]; then
               read -p "Commit message: " COMMIT_MSG
               git add .
               git commit -m "$COMMIT_MSG"
               echo "✅ Changes committed"
               echo ""
             else
               echo "⚠️  Proceeding with uncommitted changes (they will be carried over)"
               echo ""
             fi
           fi

           # Merge to main
           git checkout "$MAIN_BRANCH"

           # Check if merge will be successful (no conflicts)
           if git merge --no-commit --no-ff "$CURRENT_BRANCH" >/dev/null 2>&1; then
             git merge --abort  # Abort the test merge

             # Do the actual merge with proper commit message
             FEATURE_NAME=$(echo "$CURRENT_BRANCH" | sed 's/^[0-9]*-//')
             git merge "$CURRENT_BRANCH" --no-ff -m "feat: merge $CURRENT_BRANCH - $FEATURE_NAME"

             echo "✅ Merged $CURRENT_BRANCH to $MAIN_BRANCH"
             echo ""

             # Delete the feature branch
             git branch -d "$CURRENT_BRANCH"
             echo "✅ Deleted feature branch $CURRENT_BRANCH"
             echo ""
             echo "🎉 You are now on $MAIN_BRANCH"
           else
             git merge --abort  # Abort the test merge
             echo "❌ Merge conflicts detected!"
             echo ""
             echo "Cannot auto-merge. Please resolve conflicts manually:"
             echo "  1. git checkout $MAIN_BRANCH"
             echo "  2. git merge $CURRENT_BRANCH"
             echo "  3. Resolve conflicts"
             echo "  4. git add . && git commit"
             echo "  5. git branch -d $CURRENT_BRANCH"
             echo ""
             # Stay on feature branch
             git checkout "$CURRENT_BRANCH"
           fi
           ;;

         2)
           echo ""
           echo "✅ Staying on $CURRENT_BRANCH"
           echo ""
           echo "When ready to merge, run:"
           echo "  git checkout $MAIN_BRANCH"
           echo "  git merge $CURRENT_BRANCH"
           echo "  git branch -d $CURRENT_BRANCH"
           echo ""
           ;;

         3)
           echo ""
           echo "✅ Switching to $MAIN_BRANCH (keeping branch)"
           git checkout "$MAIN_BRANCH"
           echo ""
           echo "Feature branch $CURRENT_BRANCH preserved."
           echo "To merge later: git merge $CURRENT_BRANCH"
           echo "To delete later: git branch -d $CURRENT_BRANCH"
           echo ""
           ;;

         *)
           echo ""
           echo "⚠️  Invalid choice. Staying on $CURRENT_BRANCH"
           echo ""
           echo "Git workflow can be completed manually:"
           echo "  • Merge: git checkout $MAIN_BRANCH && git merge $CURRENT_BRANCH"
           echo "  • Switch: git checkout $MAIN_BRANCH"
           echo ""
           ;;
       esac
     else
       echo ""
       echo "ℹ️  Already on main branch ($CURRENT_BRANCH)"
       echo ""
     fi
   fi
   ```

Note: This command assumes a complete task breakdown exists in tasks.md. If tasks are incomplete or missing, suggest running `/tasks` first to regenerate the task list.
