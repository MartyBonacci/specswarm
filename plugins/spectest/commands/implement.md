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
4. Enhanced: SpecTest plugin with parallel execution, hooks, metrics
   by Marty Bonacci & Claude Code (2025)
-->


## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

<!-- ========== PRE-IMPLEMENT HOOK (SpecTest Enhancement) ========== -->

## 🎣 Pre-Implement Hook

**Purpose**: Validate prerequisites and initialize metrics before implementation

Execute the following checks before proceeding with implementation:

1. **Display Hook Banner**:
   ```
   🎣 Pre-Implement Hook
   ```

2. **Repository Context Check**:
   - Verify git repository exists
   - Confirm feature directory structure
   - Check that all required files exist (tasks.md, plan.md)

3. **Checklist Validation** (step 2 below will handle this):
   - Preview checklist status
   - Note: Full validation happens in step 2

4. **Tech Stack Compliance** (step 3b below will handle this):
   - Preview tech-stack.md status
   - Note: Full validation happens in step 3b

5. **Metrics Initialization**:
   - Record implementation start time
   - Initialize metrics structure for this phase
   - Prepare `/memory/metrics.json` for updates

6. **Display Readiness Status**:
   ```
   ✓ Repository ready
   ✓ Feature files validated
   ✓ Tech stack compliance pending verification
   ✓ Metrics initialized
   ✓ Ready to implement
   ```

7. **Proceed to main implementation outline**

<!-- ========== END PRE-IMPLEMENT HOOK ========== -->

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

<!-- ========== PARALLEL EXECUTION (SpecTest Enhancement) ========== -->

6. **Parallel Task Detection and Grouping**:

   **Purpose**: Identify and batch parallel tasks for simultaneous execution

   For each phase in tasks.md:

   a. **Scan for Parallel Markers**:
      ```
      - Look for tasks marked with [P]
      - Example: "T005: [P] Create user model (app/models/user.ts)"
      ```

   b. **Group Consecutive Parallel Tasks**:
      ```
      Group tasks that:
      - Are marked with [P]
      - Are in the same phase
      - Are consecutive in the task list
      - Don't have file path conflicts
      ```

   c. **Verify File Independence**:
      ```
      For each group of parallel tasks:
      - Extract file paths from task descriptions
      - Verify no two tasks modify the same file
      - If conflict detected: Remove from parallel group, mark sequential
      ```

   d. **Create Execution Plan**:
      ```
      Phase 1: Setup
        Sequential Group 1: [T001, T002] (non-parallel)

      Phase 2: Models
        Parallel Batch 1: [T003, T004, T005, T006] (all [P], different files)
        Sequential Group 2: [T007] (depends on batch 1)

      Phase 3: Services
        Parallel Batch 2: [T008, T009, T010] (all [P], different files)
      ```

   e. **Display Execution Strategy**:
      ```
      📋 Execution Plan Generated

      Total Tasks: 24
      Sequential Tasks: 12
      Parallel Batches: 3 (with 12 tasks total)
      Estimated Time Savings: ~8-12 minutes
      ```

<!-- ========== END PARALLEL EXECUTION DETECTION ========== -->

7. Execute implementation following the task plan:
   - **Phase-by-phase execution**: Complete each phase before moving to the next
   - **Respect dependencies**: Run sequential tasks in order
   - **Parallel execution**: For parallel batches, execute ALL tasks in a single message with multiple Task tool calls
   - **Follow TDD approach**: Execute test tasks before their corresponding implementation tasks
   - **File-based coordination**: Tasks affecting the same files must run sequentially
   - **Validation checkpoints**: Verify each phase completion before proceeding

   **Parallel Execution Pattern**:
   ```
   When encountering a parallel batch:

   1. Display: "⚡ Executing N tasks in parallel..."
   2. Create N Task tool calls in a SINGLE message
   3. Wait for ALL tasks to complete
   4. Aggregate results
   5. Display: "✓ Batch complete (Xm Ys)"
   6. Mark all completed tasks as [X] in tasks.md
   7. Continue to next group
   ```

8. Implementation execution rules:
   - **Setup first**: Initialize project structure, dependencies, configuration
   - **Tests before code**: If you need to write tests for contracts, entities, and integration scenarios
   - **Core development**: Implement models, services, CLI commands, endpoints
   - **Integration work**: Database connections, middleware, logging, external services
   - **Polish and validation**: Unit tests, performance optimization, documentation

9. Progress tracking and error handling:
   - Report progress after each completed task
   - Halt execution if any non-parallel task fails
   - For parallel tasks [P], continue with successful tasks, report failed ones
   - Provide clear error messages with context for debugging
   - Suggest next steps if implementation cannot proceed
   - **IMPORTANT** For completed tasks, make sure to mark the task off as [X] in the tasks file.
   - **Track metrics**: Record completion times for each phase and batch

10. Completion validation:
   - Verify all required tasks are completed
   - Check that implemented features match the original specification
   - Validate that tests pass and coverage meets requirements
   - Confirm the implementation follows the technical plan
   - Report final status with summary of completed work

<!-- ========== POST-IMPLEMENT HOOK (SpecTest Enhancement) ========== -->

## 🎣 Post-Implement Hook

**Purpose**: Validate implementation quality and save performance metrics

Execute the following after all tasks are completed:

1. **Display Hook Banner**:
   ```
   🎣 Post-Implement Hook
   ```

2. **Implementation Quality Checks**:
   - Verify all tasks marked as [X] in tasks.md
   - Count: Total tasks, completed, skipped, failed
   - Validate no tech stack violations occurred

3. **Metrics Collection**:
   - Calculate total implementation duration
   - Count parallel batches executed
   - Calculate time savings (estimated sequential time - actual time)
   - Determine speedup factor (e.g., 2.8x faster)

4. **Save Metrics to /memory/metrics.json**:
   ```json
   {
     "features": {
       "{FEATURE_NUM}-{FEATURE_NAME}": {
         "phases": {
           "implement": {
             "duration_seconds": 375,
             "start_time": "2025-10-11T10:30:00Z",
             "end_time": "2025-10-11T10:36:15Z",
             "parallel_batches": 3,
             "tasks_executed": 24,
             "tasks_sequential": 12,
             "tasks_parallel": 12,
             "violations": 0,
             "speedup_factor": 2.9,
             "estimated_sequential_time": 1087,
             "time_saved": 712
           }
         },
         "status": "completed"
       }
     }
   }
   ```

5. **Display Performance Summary**:
   ```
   ✓ All 24 tasks completed
   ✓ No tech stack violations
   ✓ Tests passing (if applicable)
   📊 Metrics saved to /memory/metrics.json

   ⚡ Performance Summary:
   • Total time: 6m 15s
   • Parallel batches: 3
   • Sequential equivalent: ~18m 7s
   • Time saved: ~11m 52s
   • Speedup: 2.9x faster

   ✅ Feature implementation complete!
   ```

6. **Suggest Next Steps**:
   ```
   📊 View detailed metrics: /spectest:metrics {FEATURE_NUM}
   📝 Review implementation: Check modified files
   🧪 Run tests: Execute test suite
   📋 Analyze quality: /spectest:analyze
   ```

<!-- ========== QUALITY VALIDATION (SpecTest Phase 1) ========== -->

7. **Quality Validation** (if quality-standards.md exists):

   **Purpose**: Automated quality assurance before merge

   See SpecSwarm quality validation implementation (same code)

   This step runs automated tests, measures coverage, executes browser tests,
   analyzes screenshots, and validates against quality gates.

   [IMPLEMENTATION NOTE: Use identical logic from SpecSwarm Step 10]

<!-- ========== END QUALITY VALIDATION ========== -->

8. **Git Workflow Completion** (if git repository):

   **Purpose**: Handle feature branch merge and cleanup

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

<!-- ========== END POST-IMPLEMENT HOOK ========== -->

Note: This command assumes a complete task breakdown exists in tasks.md. If tasks are incomplete or missing, suggest running `/spectest:tasks` first to regenerate the task list.
