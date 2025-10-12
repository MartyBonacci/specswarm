---
description: Generate an actionable, dependency-ordered tasks.md for the feature based on available design artifacts.
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

2. **Load design documents**: Read from FEATURE_DIR:
   - **Required**: plan.md (tech stack, libraries, structure), spec.md (user stories with priorities)
   - **Optional**: data-model.md (entities), contracts/ (API endpoints), research.md (decisions), quickstart.md (test scenarios)
   - **Load `/memory/tech-stack.md` for validation** (if exists)
   - Note: Not all projects have all documents. Generate tasks based on what's available.

<!-- ========== TECH STACK VALIDATION (SpecSwarm Enhancement) ========== -->
<!-- Added by Marty Bonacci & Claude Code (2025) -->

2b. **Tech Stack Validation** (if tech-stack.md exists):

   **Purpose**: Validate that no tasks introduce unapproved or prohibited technologies

   1. **Read Tech Stack Compliance Report** from plan.md:
      - Check if "Tech Stack Compliance Report" section exists
      - If it does NOT exist: Skip validation (plan.md was created before SpecSwarm)
      - If it DOES exist: Proceed with validation

   2. **Verify Compliance Report is Resolved**:
      ```bash
      # Check for unresolved conflicts or prohibitions
      if grep -q "⚠️ Conflicting Technologies" "${FEATURE_DIR}/plan.md"; then
        # Check if there are still pending choices
        if grep -q "**Your choice**: _\[" "${FEATURE_DIR}/plan.md"; then
          ERROR "Tech stack conflicts unresolved in plan.md"
          MESSAGE "Please resolve conflicting technology choices in plan.md before generating tasks"
          MESSAGE "Run /specswarm:plan again to address conflicts"
          HALT
        fi
      fi

      if grep -q "❌ Prohibited Technologies" "${FEATURE_DIR}/plan.md"; then
        if grep -q "**Cannot proceed**" "${FEATURE_DIR}/plan.md"; then
          ERROR "Prohibited technologies found in plan.md"
          MESSAGE "Remove prohibited technologies from plan.md Technical Context"
          MESSAGE "See /memory/tech-stack.md for approved alternatives"
          HALT
        fi
      fi
      ```

   3. **Scan Task Descriptions for Technology References**:
      Before finalizing tasks.md, scan all task descriptions for library/framework names:
      ```bash
      # Extract task descriptions (before they're written to tasks.md)
      for TASK in "${ALL_TASKS[@]}"; do
        TASK_DESC=$(echo "$TASK" | grep -oE 'Install.*|Add.*|Use.*|Import.*')

        # Check against prohibited list
        for PROHIBITED in $(grep "❌" "${REPO_ROOT}/memory/tech-stack.md" | sed 's/.*❌ \([^ ]*\).*/\1/'); do
          if echo "$TASK_DESC" | grep -qi "$PROHIBITED"; then
            WARNING "Task references prohibited technology: $PROHIBITED"
            MESSAGE "Task: $TASK_DESC"
            APPROVED_ALT=$(grep "❌.*${PROHIBITED}" "${REPO_ROOT}/memory/tech-stack.md" | sed 's/.*use \(.*\) instead.*/\1/')
            MESSAGE "Replace with approved alternative: $APPROVED_ALT"
            # Auto-correct task description
            TASK_DESC=$(echo "$TASK_DESC" | sed -i "s/${PROHIBITED}/${APPROVED_ALT}/gi")
          fi
        done

        # Check against unapproved list (warn but allow)
        if ! grep -qi "$TECH_MENTIONED" "${REPO_ROOT}/memory/tech-stack.md" 2>/dev/null; then
          INFO "Task mentions unapproved technology: $TECH_MENTIONED"
          INFO "This will be validated during /specswarm:implement"
        fi
      done
      ```

   4. **Validation Summary**:
      Add validation summary to tasks.md header:
      ```markdown
      <!-- Tech Stack Validation: PASSED -->
      <!-- Validated against: /memory/tech-stack.md v{version} -->
      <!-- No prohibited technologies found -->
      <!-- {N} unapproved technologies require runtime validation -->
      ```

<!-- ========== END TECH STACK VALIDATION ========== -->

3. **Execute task generation workflow** (follow the template structure):
   - Load plan.md and extract tech stack, libraries, project structure
   - **Load spec.md and extract user stories with their priorities (P1, P2, P3, etc.)**
   - If data-model.md exists: Extract entities → map to user stories
   - If contracts/ exists: Each file → map endpoints to user stories
   - If research.md exists: Extract decisions → generate setup tasks
   - **Generate tasks ORGANIZED BY USER STORY**:
     - Setup tasks (shared infrastructure needed by all stories)
     - **Foundational tasks (prerequisites that must complete before ANY user story can start)**
     - For each user story (in priority order P1, P2, P3...):
       - Group all tasks needed to complete JUST that story
       - Include models, services, endpoints, UI components specific to that story
       - Mark which tasks are [P] parallelizable
       - If tests requested: Include tests specific to that story
     - Polish/Integration tasks (cross-cutting concerns)
   - **Tests are OPTIONAL**: Only generate test tasks if explicitly requested in the feature spec or user asks for TDD approach
   - Apply task rules:
     - Different files = mark [P] for parallel
     - Same file = sequential (no [P])
     - If tests requested: Tests before implementation (TDD order)
   - Number tasks sequentially (T001, T002...)
   - Generate dependency graph showing user story completion order
   - Create parallel execution examples per user story
   - Validate task completeness (each user story has all needed tasks, independently testable)

4. **Generate tasks.md**: Use `.specify/templates/tasks-template.md` as structure, fill with:
   - Correct feature name from plan.md
   - Phase 1: Setup tasks (project initialization)
   - Phase 2: Foundational tasks (blocking prerequisites for all user stories)
   - Phase 3+: One phase per user story (in priority order from spec.md)
     - Each phase includes: story goal, independent test criteria, tests (if requested), implementation tasks
     - Clear [Story] labels (US1, US2, US3...) for each task
     - [P] markers for parallelizable tasks within each story
     - Checkpoint markers after each story phase
   - Final Phase: Polish & cross-cutting concerns
   - Numbered tasks (T001, T002...) in execution order
   - Clear file paths for each task
   - Dependencies section showing story completion order
   - Parallel execution examples per story
   - Implementation strategy section (MVP first, incremental delivery)

5. **Report**: Output path to generated tasks.md and summary:
   - Total task count
   - Task count per user story
   - Parallel opportunities identified
   - Independent test criteria for each story
   - Suggested MVP scope (typically just User Story 1)

Context for task generation: {ARGS}

The tasks.md should be immediately executable - each task must be specific enough that an LLM can complete it without additional context.

## Task Generation Rules

**IMPORTANT**: Tests are optional. Only generate test tasks if the user explicitly requested testing or TDD approach in the feature specification.

**CRITICAL**: Tasks MUST be organized by user story to enable independent implementation and testing.

1. **From User Stories (spec.md)** - PRIMARY ORGANIZATION:
   - Each user story (P1, P2, P3...) gets its own phase
   - Map all related components to their story:
     - Models needed for that story
     - Services needed for that story
     - Endpoints/UI needed for that story
     - If tests requested: Tests specific to that story
   - Mark story dependencies (most stories should be independent)
   
2. **From Contracts**:
   - Map each contract/endpoint → to the user story it serves
   - If tests requested: Each contract → contract test task [P] before implementation in that story's phase
   
3. **From Data Model**:
   - Map each entity → to the user story(ies) that need it
   - If entity serves multiple stories: Put in earliest story or Setup phase
   - Relationships → service layer tasks in appropriate story phase
   
4. **From Setup/Infrastructure**:
   - Shared infrastructure → Setup phase (Phase 1)
   - Foundational/blocking tasks → Foundational phase (Phase 2)
     - Examples: Database schema setup, authentication framework, core libraries, base configurations
     - These MUST complete before any user story can be implemented
   - Story-specific setup → within that story's phase

5. **Ordering**:
   - Phase 1: Setup (project initialization)
   - Phase 2: Foundational (blocking prerequisites - must complete before user stories)
   - Phase 3+: User Stories in priority order (P1, P2, P3...)
     - Within each story: Tests (if requested) → Models → Services → Endpoints → Integration
   - Final Phase: Polish & Cross-Cutting Concerns
   - Each user story phase should be a complete, independently testable increment

