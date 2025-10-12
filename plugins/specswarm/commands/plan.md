---
description: Execute the implementation planning workflow using the plan template to generate design artifacts.
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
   - Check for `/memory/tech-stack.md`
   - Load plan template from `templates/plan-template.md` or use embedded template

<!-- ========== TECH STACK MANAGEMENT (SpecSwarm Enhancement) ========== -->
<!-- Added by Marty Bonacci & Claude Code (2025) -->

2a. **Tech Stack File Initialization** (first-time setup):

   **Check if tech stack file exists**:
   ```bash
   if [ ! -f "${REPO_ROOT}/memory/tech-stack.md" ]; then
     FIRST_FEATURE=true
   else
     FIRST_FEATURE=false
   fi
   ```

   **If FIRST_FEATURE=true** (no tech-stack.md exists):

   1. **Detect project technologies** (scan existing files):
      ```bash
      # Check for package managers and extract dependencies
      if [ -f "${REPO_ROOT}/package.json" ]; then
        # Node.js/TypeScript project
        LANGUAGE=$(grep -q "typescript" "${REPO_ROOT}/package.json" && echo "TypeScript" || echo "JavaScript")
        RUNTIME="Node.js"
        # Extract frameworks and libraries from dependencies
      elif [ -f "${REPO_ROOT}/composer.json" ]; then
        # PHP project
        LANGUAGE="PHP"
      elif [ -f "${REPO_ROOT}/requirements.txt" ] || [ -f "${REPO_ROOT}/pyproject.toml" ]; then
        # Python project
        LANGUAGE="Python"
      elif [ -f "${REPO_ROOT}/go.mod" ]; then
        # Go project
        LANGUAGE="Go"
      elif [ -f "${REPO_ROOT}/Gemfile" ]; then
        # Ruby project
        LANGUAGE="Ruby"
      fi
      ```

   2. **Generate tech-stack.md** using template:
      - Use `/templates/tech-stack-template.md` if exists
      - Otherwise use embedded template with detected technologies
      - Populate Core Technologies section from detection
      - Populate Standard Libraries from package files
      - Leave Prohibited Technologies section with TODO marker and common examples

   3. **Present to user for confirmation**:
      ```
      🎯 TECH STACK FILE CREATED

      This is your FIRST feature using SpecSwarm. I've created `/memory/tech-stack.md`
      based on your project files and plan.md Technical Context.

      **Detected Stack:**
      - Language: {detected_language}
      - Framework: {detected_framework}
      - Database: {detected_database}
      - Key Libraries: {detected_libraries}

      **Action Required:**
      1. Review `/memory/tech-stack.md`
      2. Add any PROHIBITED technologies (important for drift prevention!)
      3. Confirm accuracy of detected stack

      ⚠️ This file will be used to validate ALL future features.

      **Options:**
      - Type "continue" to accept and proceed with planning
      - Type "edit" to pause while you refine tech-stack.md
      - Provide corrections: "Language should be JavaScript, not TypeScript"
      ```

   4. **Wait for user response**:
      - If "continue": Proceed to section 2b (Tech Stack Validation)
      - If "edit": PAUSE with message "Run `/specswarm:plan` again when ready"
      - If corrections provided: Update tech-stack.md, show updated version, ask for confirmation again

   5. **Add reminder to constitution** (if constitution exists):
      - Append note to constitution.md suggesting Principle 5 formalization
      - Message: "💡 Consider running `/specswarm:constitution` to formalize tech stack enforcement as Principle 5"

   **If FIRST_FEATURE=false** (tech-stack.md already exists):
   - Skip initialization entirely
   - Proceed directly to section 2b (Tech Stack Validation)

   **If auto-detection fails** (no package files found):
   - Prompt user for manual input:
     ```
     🎯 TECH STACK FILE NEEDED

     Cannot auto-detect technologies. Please provide:
     1. Programming language and version (e.g., "TypeScript 5.x")
     2. Main framework (e.g., "React Router v7")
     3. Database (e.g., "PostgreSQL 17")
     4. 3-5 key libraries

     Example: "TypeScript 5, React Router v7, PostgreSQL 17, Drizzle ORM, Zod"
     ```
   - Wait for response, generate tech-stack.md from input

2b. **Tech Stack Validation** (runs for all features after first):

   **If tech-stack.md does NOT exist**:
   - Skip validation (handled by section 2a above)

   **If tech-stack.md exists**:

   1. **Extract technologies from plan.md Technical Context**:
      - Parse all mentioned libraries, frameworks, tools from Technical Context section
      - Create list: NEW_TECHNOLOGIES[] (technologies mentioned in current plan)
      - Read and parse: APPROVED_STACK[] (from tech-stack.md approved sections)
      - Read and parse: PROHIBITED_STACK[] (from tech-stack.md prohibited section)

   2. **Classify each NEW technology**:
      ```bash
      for TECH in "${NEW_TECHNOLOGIES[@]}"; do
        # Check 1: Is it PROHIBITED?
        if grep -qi "❌.*${TECH}" "${REPO_ROOT}/memory/tech-stack.md"; then
          TECH_STATUS[$TECH]="PROHIBITED"
          CONFLICTS_WITH[$TECH]=$(grep "❌.*${TECH}" "${REPO_ROOT}/memory/tech-stack.md" | sed 's/.*use \(.*\) instead.*/\1/')
          continue
        fi

        # Check 2: Is it already APPROVED?
        if grep -qi "${TECH}" "${REPO_ROOT}/memory/tech-stack.md" | grep -v "❌"; then
          TECH_STATUS[$TECH]="APPROVED"
          continue
        fi

        # Check 3: Does it CONFLICT with existing tech?
        # Extract PURPOSE tag from tech-stack.md for conflict detection
        TECH_PURPOSE=$(get_library_purpose "${TECH}")

        if [ -n "$TECH_PURPOSE" ]; then
          EXISTING_WITH_PURPOSE=$(grep -i "PURPOSE:${TECH_PURPOSE}" "${REPO_ROOT}/memory/tech-stack.md" | grep -v "❌" | head -1)
          if [ -n "$EXISTING_WITH_PURPOSE" ]; then
            TECH_STATUS[$TECH]="CONFLICT"
            CONFLICTS_WITH[$TECH]="${EXISTING_WITH_PURPOSE}"
            continue
          fi
        fi

        # Check 4: No conflict = AUTO_ADD candidate
        TECH_STATUS[$TECH]="AUTO_ADD"
      done
      ```

   3. **Generate Tech Stack Compliance Report** in plan.md:

      Create a new section in the plan.md file:

      ```markdown
      ## Tech Stack Compliance Report
      <!-- Auto-generated by SpecSwarm tech stack validation -->

      ### ✅ Approved Technologies (already in stack)
      {list of technologies with APPROVED status}

      ### ➕ New Technologies (auto-added)
      {list of technologies with AUTO_ADD status}
      For each:
      - **{Technology Name}**
        - Purpose: {detected_purpose}
        - No conflicts detected
        - Added to: {section_name}
        - Version updated: {old_version} → {new_version}

      ### ⚠️ Conflicting Technologies (require approval)
      {list of technologies with CONFLICT status}
      For each:
      - **{Technology Name}**
        - Purpose: {detected_purpose}
        - ❌ CONFLICT: Project uses `{existing_tech}` ({purpose})
        - **Action Required**: Choose one:

          | Option | Choice | Implications |
          |--------|--------|--------------|
          | A | Use {existing_tech} (keep existing) | Remove {new_tech} from plan, update Technical Context |
          | B | Replace {existing_tech} with {new_tech} | Update tech-stack.md (MAJOR version), refactor existing code |
          | C | Use both (justify overlap) | Document why both needed in research.md, add note to tech-stack.md |

        **Your choice**: _[Wait for user response]_

      ### ❌ Prohibited Technologies (cannot use)
      {list of technologies with PROHIBITED status}
      For each:
      - **{Technology Name}**
        - ❌ PROHIBITED in tech-stack.md
        - Reason: "{reason from tech-stack.md}"
        - **Must use**: {approved_alternative}
        - **Cannot proceed** until plan.md updated
      ```

   4. **Handle Each Status**:

      **APPROVED** → Continue silently (no action needed)

      **AUTO_ADD** →
      ```bash
      # For each AUTO_ADD technology:
      1. Determine appropriate section (Data Layer, UI Layer, Utilities, etc.)
      2. Add entry to tech-stack.md:
         - {Technology} v{version} ({purpose}) <!-- Auto-added: Feature {FEATURE_NUM}, {DATE} -->
      3. Bump tech-stack.md MINOR version:
         OLD_VERSION=$(grep "^\*\*Version\*\*:" "${REPO_ROOT}/memory/tech-stack.md" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
         MAJOR=$(echo $OLD_VERSION | cut -d. -f1)
         MINOR=$(echo $OLD_VERSION | cut -d. -f2)
         PATCH=$(echo $OLD_VERSION | cut -d. -f3)
         NEW_MINOR=$((MINOR + 1))
         NEW_VERSION="${MAJOR}.${NEW_MINOR}.0"
         sed -i "s/\*\*Version\*\*: ${OLD_VERSION}/\*\*Version\*\*: ${NEW_VERSION}/" "${REPO_ROOT}/memory/tech-stack.md"
      4. Update version history section
      5. Notify user in compliance report
      6. Continue with plan generation
      ```

      **CONFLICT** →
      ```bash
      1. STOP planning process
      2. Show conflict details with options table (see report format above)
      3. WAIT for user response (A, B, or C)
      4. Based on choice:
         Option A (keep existing):
           - Remove conflicting tech from plan.md Technical Context
           - Continue with plan generation
         Option B (replace):
           - Remove existing tech from tech-stack.md
           - Add new tech to tech-stack.md
           - Bump MAJOR version (breaking change)
           - Add to research.md: justification for replacement
           - Continue with plan generation
         Option C (use both):
           - Require research.md justification section
           - Add new tech to tech-stack.md with overlap note
           - Bump MINOR version
           - Continue with plan generation
      5. Document decision in plan.md under "Tech Stack Compliance"
      ```

      **PROHIBITED** →
      ```bash
      1. ERROR: Cannot proceed with planning
      2. Show prohibited tech details and approved alternative
      3. Show amendment process:
         ```
         To use prohibited technology:
         1. Document compelling business justification in research.md
         2. Update /memory/constitution.md (requires constitutional amendment)
         3. Remove from Prohibited section in tech-stack.md
         4. Add to Approved section with justification comment
         5. Bump tech-stack.md MAJOR version (breaking constitutional change)
         6. Re-run /specswarm:plan
         ```
      4. HALT planning until issue resolved
      ```

   5. **Update tech-stack.md file** (for AUTO_ADD technologies):
      - Automatically write changes to tech-stack.md
      - Update version and version history
      - Add auto-generated comment with feature number and date

<!-- ========== END TECH STACK MANAGEMENT ========== -->

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

   c. **Update Agent Context File** (Enhanced by SpecSwarm):
   <!-- Tech stack enforcement added by Marty Bonacci & Claude Code (2025) -->
   - Read existing CONTEXT_FILE (if exists)
   - **Read `/memory/tech-stack.md` if exists** (SpecSwarm enhancement)
   - Look for markers like `<!-- AUTO-GENERATED-START -->` and `<!-- AUTO-GENERATED-END -->`
   - Replace content between markers with enhanced format:
   - If no markers exist, append new section
   - Preserve all manual edits outside markers
   - **Enhanced format** (includes CRITICAL CONSTRAINTS from tech-stack.md):
   ```markdown
   <!-- AUTO-GENERATED-START -->
   ## Tech Stack (from plan.md)
   - **Language**: {language}
   - **Framework**: {framework}
   - **Database**: {database}
   - **Key Libraries**: {libraries}

   ## CRITICAL CONSTRAINTS (from tech-stack.md)
   ⚠️ **BEFORE suggesting ANY library, framework, or pattern:**
   1. Read `/memory/tech-stack.md`
   2. Verify your suggestion is APPROVED
   3. If PROHIBITED, suggest approved alternative
   4. If UNAPPROVED, warn user and require justification

   **Prohibited Technologies** (NEVER suggest these):
   {list of ❌ technologies from tech-stack.md with approved alternatives}
   Example format:
   - ❌ Axios → Use: fetch API
   - ❌ Class components → Use: Functional components
   - ❌ Redux → Use: React Router loaders/actions

   **Violation = Constitution violation** (see `/memory/constitution.md` Principle 5)

   **Auto-Addition:** Non-conflicting new libraries will be auto-added during `/specswarm:plan`
   <!-- AUTO-GENERATED-END -->
   ```

**Output**: data-model.md, /contracts/*, quickstart.md, (optional) agent context file

## Key rules

- Use absolute paths
- ERROR on gate failures or unresolved clarifications
