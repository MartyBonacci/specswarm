---
description: Build complete feature from specification to implementation - simplified workflow
args:
  - name: feature_description
    description: Natural language description of the feature to build
    required: true
  - name: --validate
    description: Run browser validation with Playwright after implementation
    required: false
  - name: --quality-gate
    description: Set minimum quality score (default 80)
    required: false
  - name: --background
    description: Run build in background, return session ID for tracking
    required: false
  - name: --notify
    description: Play sound when complete (requires notifier plugin)
    required: false
  - name: --orchestrate
    description: Force multi-agent orchestration with parallel task execution and specialist routing
    required: false
  - name: --no-orchestrate
    description: Force sequential execution (disable auto-orchestration)
    required: false
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Build a complete feature from natural language description through implementation and quality validation.

**Purpose**: Simplify feature development by orchestrating the complete workflow in a single command.

**Workflow**: Specify → Clarify → Plan → Tasks → Implement → (Validate) → Quality Analysis

**User Experience**:
- Single command instead of 7+ manual steps
- Interactive clarification (only pause point)
- Autonomous execution through implementation
- Quality validated automatically
- Ready for final merge with `/specswarm:ship`

---

## Pre-Flight Checks

```bash
# Parse arguments
FEATURE_DESC=""
RUN_VALIDATE=false
QUALITY_GATE=80
BACKGROUND_MODE=false
NOTIFY_ON_COMPLETE=false
ORCHESTRATE_FLAG=""  # "", "force", or "disable"

# Extract feature description (first non-flag argument)
for arg in $ARGUMENTS; do
  if [ "${arg:0:2}" != "--" ] && [ -z "$FEATURE_DESC" ]; then
    FEATURE_DESC="$arg"
  elif [ "$arg" = "--validate" ]; then
    RUN_VALIDATE=true
  elif [ "$arg" = "--quality-gate" ]; then
    shift
    QUALITY_GATE="$1"
  elif [ "$arg" = "--background" ]; then
    BACKGROUND_MODE=true
  elif [ "$arg" = "--notify" ]; then
    NOTIFY_ON_COMPLETE=true
  elif [ "$arg" = "--orchestrate" ]; then
    ORCHESTRATE_FLAG="force"
  elif [ "$arg" = "--no-orchestrate" ]; then
    ORCHESTRATE_FLAG="disable"
  fi
done

# Validate feature description
if [ -z "$FEATURE_DESC" ]; then
  echo "❌ Error: Feature description required"
  echo ""
  echo "Usage: /specswarm:build \"feature description\" [options]"
  echo ""
  echo "Options:"
  echo "  --validate        Run browser validation after implementation"
  echo "  --quality-gate N  Set minimum quality score (default 80)"
  echo "  --orchestrate     Force multi-agent parallel execution"
  echo "  --no-orchestrate  Force sequential execution"
  echo "  --background      Run in background mode"
  echo ""
  echo "Examples:"
  echo "  /specswarm:build \"Add user authentication with email/password\""
  echo "  /specswarm:build \"Implement dark mode toggle\" --validate"
  echo "  /specswarm:build \"Add shopping cart\" --orchestrate"
  echo "  /specswarm:build \"Add dashboard\" --validate --quality-gate 85"
  exit 1
fi

# Get project root
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "❌ Error: Not in a git repository"
  echo ""
  echo "SpecSwarm requires an existing git repository to manage feature branches."
  echo ""
  echo "If you're starting a new project, scaffold it first:"
  echo ""
  echo "  # React + Vite"
  echo "  npm create vite@latest my-app -- --template react-ts"
  echo ""
  echo "  # Next.js"
  echo "  npx create-next-app@latest"
  echo ""
  echo "  # Astro"
  echo "  npm create astro@latest"
  echo ""
  echo "  # Vue"
  echo "  npm create vue@latest"
  echo ""
  echo "Then initialize git and SpecSwarm:"
  echo "  cd my-app"
  echo "  git init"
  echo "  git add ."
  echo "  git commit -m \"Initial project scaffold\""
  echo "  /specswarm:init"
  echo ""
  echo "For existing projects, initialize git:"
  echo "  git init"
  echo "  git add ."
  echo "  git commit -m \"Initial commit\""
  echo ""
  exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

# Create build state for stop hook
FEATURE_NUM=$(printf "%03d" $(( $(find features/ .specswarm/features/ -maxdepth 1 -type d -name "[0-9][0-9][0-9]-*" 2>/dev/null | wc -l) + 1 )))

# Create slug from feature description
SLUG=$(echo "$FEATURE_DESC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
BRANCH_NAME="${FEATURE_NUM}-${SLUG}"

# Capture parent branch BEFORE creating feature branch
PARENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Create and switch to feature branch
echo ""
echo "Creating feature branch: $BRANCH_NAME (from $PARENT_BRANCH)"
git checkout -b "$BRANCH_NAME"
echo ""

mkdir -p .specswarm
mkdir -p .specswarm/sessions

# Generate session ID for tracking
SESSION_ID="build-$(date +%Y%m%d-%H%M%S)-${FEATURE_NUM}"

cat > .specswarm/build-loop.state << EOF
{
  "active": true,
  "feature_description": "$FEATURE_DESC",
  "feature_num": "$FEATURE_NUM",
  "parent_branch": "$PARENT_BRANCH",
  "branch_name": "$BRANCH_NAME",
  "session_id": "$SESSION_ID",
  "started_at": "$(date -Iseconds 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S%z")",
  "current_phase": "specify",
  "phases_complete": [],
  "quality_threshold": $QUALITY_GATE,
  "run_validate": $RUN_VALIDATE,
  "background_mode": $BACKGROUND_MODE,
  "notify_on_complete": $NOTIFY_ON_COMPLETE,
  "orchestrate_flag": "$ORCHESTRATE_FLAG",
  "use_orchestration": false
}
EOF

# Also save session for status tracking
cp .specswarm/build-loop.state ".specswarm/sessions/${SESSION_ID}.json"

# If background mode, return session info and exit
if [ "$BACKGROUND_MODE" = true ]; then
  echo ""
  echo "🔄 Build started in background mode"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Session ID: $SESSION_ID"
  echo "Feature: $FEATURE_DESC"
  echo ""
  echo "Track progress with:"
  echo "  /specswarm:status $SESSION_ID"
  echo ""
  echo "The build will continue in the background."
  if [ "$NOTIFY_ON_COMPLETE" = true ]; then
    echo "You will be notified when complete."
  fi
  echo ""
  # Note: Claude Code handles background execution automatically
  # The command continues normally but in background context
fi
```

---

## Execution Steps

## CRITICAL EXECUTION RULE

**YOU MUST execute all steps continuously without pausing to report progress.**

After each SlashCommand completes, immediately proceed to the next step. Do NOT stop to provide status updates or ask if the user wants to continue. The only exception is Step 3 (Clarification) which requires user input.

Execute Steps 2-8 as a single continuous workflow.

---

### Step 1: Display Welcome Banner

```bash
echo "🏗️  SpecSwarm Build - Complete Feature Development"
echo "══════════════════════════════════════════"
echo ""
echo "Feature: $FEATURE_DESC"
echo ""
echo "This workflow will:"
echo "  1. Create detailed specification"
echo "  2. Ask clarification questions (interactive)"
echo "  3. Generate implementation plan"
echo "  4. Generate task breakdown"
echo "  5. Implement all tasks"
if [ "$ORCHESTRATE_FLAG" = "force" ]; then
echo "     └─ Using multi-agent orchestration (--orchestrate)"
elif [ "$ORCHESTRATE_FLAG" = "disable" ]; then
echo "     └─ Using sequential execution (--no-orchestrate)"
else
echo "     └─ Auto-detect: orchestration if 4+ parallelizable tasks"
fi
if [ "$RUN_VALIDATE" = true ]; then
echo "  6. Run browser validation (Playwright)"
echo "  7. Analyze code quality"
else
echo "  6. Analyze code quality"
fi
echo ""
echo "You'll only be prompted during Step 2 (clarification)."
echo "All other steps run automatically."
echo ""
read -p "Press Enter to start, or Ctrl+C to cancel..."
echo ""
```

---

### Step 2: Phase 1 - Specification

**YOU MUST NOW run the specify command using the SlashCommand tool:**

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Phase 1: Creating Specification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
```

```
Use the SlashCommand tool to execute: /specswarm:specify "$FEATURE_DESC"
```

**DO NOT PAUSE. DO NOT REPORT STATUS. Immediately proceed to Step 3.**

```bash
echo ""
echo "✅ Specification created"
echo ""
```

---

### Step 3: Phase 2 - Clarification (INTERACTIVE)

**YOU MUST NOW run the clarify command using the SlashCommand tool:**

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "❓ Phase 2: Clarification Questions"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  INTERACTIVE: Please answer the clarification questions."
echo ""
```

```
Use the SlashCommand tool to execute: /specswarm:clarify
```

**IMPORTANT**: This step is interactive. Answer the clarification questions, then **immediately proceed to Step 4 without pausing**.

```bash
echo ""
echo "✅ Clarification complete"
echo ""
```

---

### Step 4: Phase 3 - Planning

**YOU MUST NOW run the plan command using the SlashCommand tool:**

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🗺️  Phase 3: Generating Implementation Plan"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
```

```
Use the SlashCommand tool to execute: /specswarm:plan
```

**DO NOT PAUSE. DO NOT REPORT STATUS. Immediately proceed to Step 5.**

```bash
echo ""
echo "✅ Implementation plan created"
echo ""
```

---

### Step 5: Phase 4 - Task Generation

**YOU MUST NOW run the tasks command using the SlashCommand tool:**

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Phase 4: Generating Task Breakdown"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
```

```
Use the SlashCommand tool to execute: /specswarm:tasks
```

**DO NOT PAUSE. DO NOT REPORT STATUS. Immediately proceed to Step 6.**

```bash
# Count tasks
TASK_COUNT=$(grep -c '^###[[:space:]]*T[0-9]' tasks.md 2>/dev/null || echo "0")

echo ""
echo "✅ Task breakdown created ($TASK_COUNT tasks)"
echo ""
```

---

### Step 5.5: Orchestration Analysis (Smart Detection)

**Determine if multi-agent orchestration should be used:**

```bash
# Source orchestrator utilities
SPECSWARM_DIR="/home/marty/code-projects/specswarm/plugins/specswarm"
if [ -f "${SPECSWARM_DIR}/lib/orchestrator-utils.sh" ]; then
  source "${SPECSWARM_DIR}/lib/orchestrator-utils.sh"
fi

# Find the tasks.md file
FEATURE_DIR=$(find features/ .specswarm/features/ -maxdepth 2 -type d -name "[0-9][0-9][0-9]-*" 2>/dev/null | head -1)
TASKS_FILE="${FEATURE_DIR}/tasks.md"

# Determine orchestration mode
USE_ORCHESTRATION=false
ORCHESTRATION_REASON=""

if [ "$ORCHESTRATE_FLAG" = "force" ]; then
  USE_ORCHESTRATION=true
  ORCHESTRATION_REASON="--orchestrate flag specified"
elif [ "$ORCHESTRATE_FLAG" = "disable" ]; then
  USE_ORCHESTRATION=false
  ORCHESTRATION_REASON="--no-orchestrate flag specified"
elif [ "$TASK_COUNT" -ge 4 ]; then
  # Smart detection: use orchestration for 4+ tasks
  # Check if tasks have parallelization potential
  if type analyze_task_dependencies &> /dev/null && [ -f "$TASKS_FILE" ]; then
    TASK_ANALYSIS=$(analyze_task_dependencies "$TASKS_FILE" 2>/dev/null)
    MAX_PARALLEL=$(echo "$TASK_ANALYSIS" | jq -r '.statistics.max_parallel // 1' 2>/dev/null || echo "1")
    if [ "$MAX_PARALLEL" -ge 2 ]; then
      USE_ORCHESTRATION=true
      ORCHESTRATION_REASON="Auto-detected: $TASK_COUNT tasks with parallelization potential (max $MAX_PARALLEL parallel)"
    fi
  fi
fi

# Update state file with orchestration decision
if command -v jq &> /dev/null; then
  jq --argjson use_orch "$USE_ORCHESTRATION" '.use_orchestration = $use_orch' .specswarm/build-loop.state > .specswarm/build-loop.state.tmp
  mv .specswarm/build-loop.state.tmp .specswarm/build-loop.state
fi

if [ "$USE_ORCHESTRATION" = true ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🎭 Multi-Agent Orchestration: ENABLED"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Reason: $ORCHESTRATION_REASON"
  echo ""
  echo "Benefits:"
  echo "  • Parallel execution of independent tasks"
  echo "  • Specialist agents for different task types"
  echo "  • MANIFEST.md for execution traceability"
  echo ""
fi
```

**IF USE_ORCHESTRATION = true, prepare orchestration context:**

```bash
if [ "$USE_ORCHESTRATION" = true ] && [ -f "$TASKS_FILE" ]; then
  echo "Analyzing task dependencies..."

  # Generate full task analysis with routing
  TASK_ANALYSIS=$(analyze_task_dependencies "$TASKS_FILE")
  TASK_ROUTING=$(route_all_tasks "$TASK_ANALYSIS" 2>/dev/null || echo "[]")

  # Save orchestration context
  ORCH_CONTEXT="${FEATURE_DIR}/.orchestration-context.json"
  echo "$TASK_ANALYSIS" | jq --argjson routing "$TASK_ROUTING" \
    '. + {routing: $routing, orchestration_mode: true}' > "$ORCH_CONTEXT" 2>/dev/null

  # Display execution plan
  STREAM_COUNT=$(echo "$TASK_ANALYSIS" | jq -r '.statistics.total_streams // 1' 2>/dev/null || echo "1")
  echo ""
  echo "Execution Plan:"
  echo "  • $TASK_COUNT tasks in $STREAM_COUNT execution streams"
  echo "  • Max parallel: $MAX_PARALLEL tasks"
  echo ""
fi
```

---

### Step 6: Phase 5 - Implementation

**Implementation mode depends on orchestration decision from Step 5.5:**

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  Phase 5: Implementing Feature"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
if [ "$USE_ORCHESTRATION" = true ]; then
  echo "Mode: Multi-Agent Orchestration (parallel execution)"
else
  echo "Mode: Sequential Execution"
fi
echo "Tasks: $TASK_COUNT"
echo ""
```

**IF USE_ORCHESTRATION = false (Sequential Mode):**

Use the SlashCommand tool to execute: `/specswarm:implement`

**IF USE_ORCHESTRATION = true (Orchestration Mode):**

Execute tasks using multi-agent orchestration with parallel streams:

1. **Read orchestration context:**
   ```bash
   ORCH_CONTEXT="${FEATURE_DIR}/.orchestration-context.json"
   cat "$ORCH_CONTEXT"
   ```

2. **Execute tasks by stream using the Task tool:**

   For each execution stream in the orchestration context:
   - Launch ALL tasks in the stream in PARALLEL using multiple Task tool calls in a single message
   - Use the routed agent type for each task (from routing in context):
     - Frontend tasks → `react-typescript-specialist`
     - Architecture tasks → `system-architect`
     - Design tasks → `ui-designer`
     - Functional tasks → `functional-patterns`
     - Default → `general-purpose`
   - Wait for all tasks in the stream to complete before proceeding to next stream

   **Example for Stream with T001 (frontend) and T002 (utility):**
   - Launch Task tool with subagent_type="react-typescript-specialist" for T001
   - Launch Task tool with subagent_type="general-purpose" for T002
   - Both in the SAME message for parallel execution

   **Task prompt template:**
   ```
   Execute task {TASK_ID} for feature "{FEATURE_DESC}" in {PROJECT_PATH}

   Task details from tasks.md:
   {TASK_CONTENT}

   Feature context:
   - Spec: {FEATURE_DIR}/spec.md
   - Plan: {FEATURE_DIR}/plan.md

   Instructions:
   1. Read the spec.md and plan.md for full context
   2. Implement the task as specified
   3. Write clean, well-documented code
   4. Follow existing code patterns in the project
   5. Report files created/modified when complete
   ```

3. **Track execution results:**
   - Note success/failure for each task
   - Record agent type used
   - Track output files created

4. **Generate MANIFEST.md:**
   After all streams complete, create `{FEATURE_DIR}/MANIFEST.md`:

   ```markdown
   # Implementation Manifest

   ## Orchestration Summary
   - **Feature**: {FEATURE_DESC}
   - **Total Tasks**: {TASK_COUNT}
   - **Execution Streams**: {STREAM_COUNT}
   - **Agents Used**: [list unique agents]

   ## Task Execution Log

   | Task | Agent Type | Stream | Status | Output Files |
   |------|------------|--------|--------|--------------|
   | T001 | react-typescript-specialist | 1 | completed | src/... |
   ...

   ## Files Modified
   - [Complete list of all files created/modified]
   ```

**DO NOT PAUSE. DO NOT REPORT STATUS. Immediately proceed to Step 7.**

```bash
echo ""
echo "✅ Implementation complete"
if [ "$USE_ORCHESTRATION" = true ] && [ -f "${FEATURE_DIR}/MANIFEST.md" ]; then
  echo "   MANIFEST.md created with execution details"
fi
echo ""
```

---

### Step 7: Phase 6 - Browser Validation (Optional)

**IF --validate flag was provided, run validation:**

```bash
if [ "$RUN_VALIDATE" = true ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🌐 Phase 6: Browser Validation"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Running AI-powered interaction flow validation with Playwright..."
  echo ""
fi
```

**IF RUN_VALIDATE = true, use the SlashCommand tool:**

```
Use the SlashCommand tool to execute: /specswarm:validate
```

```bash
if [ "$RUN_VALIDATE" = true ]; then
  echo ""
  echo "✅ Validation complete"
  echo ""
fi
```

---

### Step 8: Phase 7 - Quality Analysis

**YOU MUST NOW run the quality analysis using the SlashCommand tool:**

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Phase 7: Code Quality Analysis"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
```

```
Use the SlashCommand tool to execute: /specswarm:analyze-quality
```

The stop hook will check the quality score and complete the build if it meets the threshold.

Store quality score as QUALITY_SCORE.

---

### Step 9: Final Report

**Display completion summary:**

```bash
echo ""
echo "══════════════════════════════════════════"
echo "🎉 FEATURE BUILD COMPLETE"
echo "══════════════════════════════════════════"
echo ""
echo "Feature: $FEATURE_DESC"
echo ""
echo "✅ Specification created"
echo "✅ Clarification completed"
echo "✅ Plan generated"
echo "✅ Tasks generated ($TASK_COUNT tasks)"
echo "✅ Implementation complete"
if [ "$RUN_VALIDATE" = true ]; then
echo "✅ Browser validation passed"
fi
echo "✅ Quality analyzed (Score: ${QUALITY_SCORE}%)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 NEXT STEPS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. 🧪 Manual Testing"
echo "   - Test the feature in your browser/app"
echo "   - Verify all functionality works as expected"
echo "   - Check edge cases and error handling"
echo ""
echo "2. 🔍 Code Review (Optional)"
echo "   - Review generated code for best practices"
echo "   - Check for security issues"
echo "   - Verify tech stack compliance"
echo ""
echo "3. 🚢 Ship When Ready"
echo "   Run: /specswarm:ship"
echo ""
echo "   This will:"
echo "   - Validate quality meets threshold ($QUALITY_GATE%)"
echo "   - Merge to parent branch if passing"
echo "   - Complete the feature workflow"
echo ""

if [ "$QUALITY_SCORE" -lt "$QUALITY_GATE" ]; then
  echo "⚠️  WARNING: Quality score (${QUALITY_SCORE}%) below threshold (${QUALITY_GATE}%)"
  echo "   Consider addressing quality issues before shipping."
  echo "   Review the quality analysis output above for specific improvements."
  echo ""
fi

echo "══════════════════════════════════════════"
```

---

## Error Handling

If any phase fails:

1. **Specify fails**: Display error, suggest checking feature description clarity
2. **Clarify fails**: Display error, suggest re-running clarify separately
3. **Plan fails**: Display error, suggest reviewing spec.md for completeness
4. **Tasks fails**: Display error, suggest reviewing plan.md
5. **Implement fails**: Display error, suggest re-running implement or using bugfix
6. **Validate fails**: Display validation errors, suggest fixing and re-validating
7. **Quality analysis fails**: Display error, continue (quality optional for build)

**All errors should report clearly and suggest remediation.**

**Cleanup on error:**

```bash
# If any critical error occurs, clean up the state file
rm -f .specswarm/build-loop.state
```

---

## Design Philosophy

**Simplicity**: 1 command instead of 7+ manual steps

**Efficiency**: Autonomous execution except for clarification (user only pauses once)

**Quality**: Built-in quality analysis ensures code standards

**Flexibility**: Optional validation and configurable quality gates

**User Experience**: Clear progress indicators and final next steps

---

## Comparison to Manual Workflow

**Before** (Manual):
```bash
/specswarm:specify "feature description"
/specswarm:clarify
/specswarm:plan
/specswarm:tasks
/specswarm:implement
/specswarm:analyze-quality
/specswarm:complete
```
**7 commands**, ~5 minutes of manual orchestration

**After** (Build):
```bash
/specswarm:build "feature description" --validate
# [Answer clarification questions]
# [Wait for completion]
/specswarm:ship
```
**2 commands**, 1 interactive pause, fully automated execution

**With Orchestration** (4+ parallelizable tasks):
```bash
/specswarm:build "feature description" --orchestrate
# [Answer clarification questions]
# [Parallel task execution with specialist agents]
# [MANIFEST.md generated]
/specswarm:ship
```
**Benefits**: Faster execution, specialist routing, execution traceability

**Time Savings**: 85-90% reduction in manual orchestration overhead
