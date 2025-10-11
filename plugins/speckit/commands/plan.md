---
description: Execute the implementation planning workflow using the plan template to generate design artifacts.
---

<!--
Adapted from GitHub spec-kit: https://github.com/github/spec-kit
Original work Copyright (c) GitHub, Inc.
Licensed under MIT License
Adapted for Claude Code by Marty Bonacci
-->

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. **Discover Feature Context**:

   a. **Find Repository Root**:
   ```bash
   REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
   ```

   b. **Get Current Feature**:
   ```bash
   BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
   FEATURE_NUM=$(echo "$BRANCH" | grep -oE '^[0-9]{3}')

   # Fallback for non-git
   if [ -z "$FEATURE_NUM" ]; then
     FEATURE_NUM=$(ls -1 features/ 2>/dev/null | grep -oE '^[0-9]{3}' | sort -nr | head -1)
   fi
   ```

   c. **Locate Feature Directory**:
   ```bash
   FEATURE_DIR=$(find features -maxdepth 1 -type d -name "${FEATURE_NUM}-*" 2>/dev/null | head -1)
   FEATURE_DIR="${REPO_ROOT}/${FEATURE_DIR}"
   ```

   d. **Set Path Variables**:
   ```bash
   FEATURE_SPEC="${FEATURE_DIR}/spec.md"
   IMPL_PLAN="${FEATURE_DIR}/plan.md"
   RESEARCH_FILE="${FEATURE_DIR}/research.md"
   DATA_MODEL_FILE="${FEATURE_DIR}/data-model.md"
   CONTRACTS_DIR="${FEATURE_DIR}/contracts"
   ```

   e. **Validate Prerequisites**:
   - Check that `spec.md` exists
   - If missing: ERROR "No specification found. Run `/specify` first."

2. **Load context**:
   - Read FEATURE_SPEC (spec.md)
   - Read `/memory/constitution.md` if it exists
   - Load plan template from `templates/plan-template.md` or use embedded template

3. **Execute plan workflow**: Follow the structure in IMPL_PLAN template to:
   - Fill Technical Context (mark unknowns as "NEEDS CLARIFICATION")
   - Fill Constitution Check section from constitution
   - Evaluate gates (ERROR if violations unjustified)
   - Phase 0: Generate research.md (resolve all NEEDS CLARIFICATION)
   - Phase 1: Generate data-model.md, contracts/, quickstart.md
   - Phase 1: Update agent context by running the agent script
   - Re-evaluate Constitution Check post-design

4. **Stop and report**: Command ends after Phase 2 planning. Report branch, IMPL_PLAN path, and generated artifacts.

## Phases

### Phase 0: Outline & Research

1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:
   ```
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

### Phase 1: Design & Contracts

**Prerequisites:** `research.md` complete

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Agent context update** (optional):

   a. **Detect Agent Type**:
   ```bash
   # Check which agent context files exist
   if [ -d "${REPO_ROOT}/.claude" ]; then
     AGENT="claude"
     CONTEXT_FILE=".claude/context.md"
   elif [ -f "${REPO_ROOT}/.cursorrules" ]; then
     AGENT="cursor"
     CONTEXT_FILE=".cursorrules"
   elif [ -f "${REPO_ROOT}/.github/copilot-instructions.md" ]; then
     AGENT="copilot"
     CONTEXT_FILE=".github/copilot-instructions.md"
   else
     # No agent context file found - skip this step
     AGENT="none"
   fi
   ```

   b. **Extract Tech Stack from plan.md**:
   - Language (e.g., Python, TypeScript, Go)
   - Framework (e.g., React, FastAPI, Express)
   - Database (e.g., PostgreSQL, MongoDB)
   - Key libraries and tools

   c. **Update Agent Context File**:
   - Read existing CONTEXT_FILE (if exists)
   - Look for markers like `<!-- AUTO-GENERATED-START -->` and `<!-- AUTO-GENERATED-END -->`
   - Replace content between markers with new tech stack info
   - If no markers exist, append new section
   - Preserve all manual edits outside markers
   - Example format:
   ```markdown
   <!-- AUTO-GENERATED-START -->
   ## Tech Stack (from plan.md)
   - **Language**: {language}
   - **Framework**: {framework}
   - **Database**: {database}
   - **Key Libraries**: {libraries}
   <!-- AUTO-GENERATED-END -->
   ```

**Output**: data-model.md, /contracts/*, quickstart.md, (optional) agent context file

## Key rules

- Use absolute paths
- ERROR on gate failures or unresolved clarifications
