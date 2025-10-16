---
description: Run automated test workflow with agent execution and validation
---

<!--
ATTRIBUTION:
Project Orchestrator Plugin
by Marty Bonacci & Claude Code (2025)
Based on learnings from Test 4A and Test Orchestrator Agent concept
-->

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Execute autonomous test orchestration workflow:
1. **Parse Test Workflow** - Read test specification
2. **Generate Comprehensive Prompt** - Create detailed agent instructions
3. **Launch Agent** - Use Task tool to execute in target project
4. **Validate Results** - Run validation suite
5. **Report Outcome** - Summarize results and next steps

**Usage**: `/project-orchestrator:orchestrate-test <test-workflow-file> <project-path>`

**Example**:
```bash
/project-orchestrator:orchestrate-test features/001-fix-bug/test-workflow.md /home/marty/code-projects/tweeter-spectest
```

---

## Pre-Orchestration Hook

```bash
echo "🎯 Project Orchestrator - Test Workflow"
echo ""
echo "Phase 0: Research & De-Risk"
echo "Testing: Prompt generation + Agent execution + Validation"
echo ""

# Record start time
ORCHESTRATION_START_TIME=$(date +%s)
```

---

## Execution Steps

### Step 1: Parse Arguments

```bash
# Get arguments
ARGS="$ARGUMENTS"

# Parse test workflow file (required)
TEST_WORKFLOW=$(echo "$ARGS" | awk '{print $1}')

# Parse project path (required)
PROJECT_PATH=$(echo "$ARGS" | awk '{print $2}')

# Validate arguments
if [ -z "$TEST_WORKFLOW" ] || [ -z "$PROJECT_PATH" ]; then
  echo "❌ Error: Missing required arguments"
  echo ""
  echo "Usage: /project-orchestrator:orchestrate-test <test-workflow-file> <project-path>"
  echo ""
  echo "Example:"
  echo "/project-orchestrator:orchestrate-test features/001-fix-bug/test-workflow.md /home/marty/code-projects/tweeter-spectest"
  exit 1
fi

# Check files exist
if [ ! -f "$TEST_WORKFLOW" ]; then
  echo "❌ Error: Test workflow file not found: $TEST_WORKFLOW"
  exit 1
fi

if [ ! -d "$PROJECT_PATH" ]; then
  echo "❌ Error: Project path does not exist: $PROJECT_PATH"
  exit 1
fi

echo "📋 Test Workflow: $TEST_WORKFLOW"
echo "📁 Project: $PROJECT_PATH"
echo ""
```

---

### Step 2: Parse Test Workflow

Read the test workflow file and extract:
- Task description
- Files to modify
- Expected outcome
- Validation criteria

**Test Workflow Format** (Markdown):
```markdown
# Test: [Task Name]

## Description
[What needs to be done]

## Files to Modify
- path/to/file1.ts
- path/to/file2.ts

## Changes Required
[Detailed description of changes]

## Expected Outcome
[What should happen after changes]

## Validation
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Test URL
http://localhost:5173/[path]
```

```bash
echo "📖 Parsing Test Workflow..."
echo ""

# Read workflow file
WORKFLOW_CONTENT=$(cat "$TEST_WORKFLOW")

# Extract task name (first heading)
TASK_NAME=$(echo "$WORKFLOW_CONTENT" | grep "^# Test:" | head -1 | sed 's/^# Test: //')

if [ -z "$TASK_NAME" ]; then
  echo "❌ Error: Invalid workflow format (missing '# Test:' heading)"
  exit 1
fi

echo "✅ Task: $TASK_NAME"
echo ""
```

---

### Step 3: Generate Comprehensive Prompt

This is the CORE of Project Orchestrator - generating effective prompts for agents.

**Prompt Template**:
```markdown
# Task: [TASK_NAME]

## Context
You are working on project: [PROJECT_PATH]

This is an autonomous development task executed by Project Orchestrator (Phase 0).

## Your Mission
[TASK_DESCRIPTION from workflow]

## Files to Modify
[FILES_LIST from workflow]

## Detailed Requirements
[CHANGES_REQUIRED from workflow]

## Success Criteria
[VALIDATION_CRITERIA from workflow]

## Technical Guidelines
- Make ALL changes in [PROJECT_PATH] directory
- Follow existing code patterns and conventions
- Ensure all changes are complete and functional
- Run tests if applicable
- Report any blockers or issues

## Validation
After completing your work, the orchestrator will:
1. Run browser validation with Playwright
2. Check console for errors
3. Analyze UI with Claude Vision API
4. Verify success criteria

## Execution Instructions
1. Read the workflow file to understand requirements
2. Analyze existing code in target files
3. Make necessary changes
4. Verify changes work correctly
5. Report completion with summary

Work autonomously. Only escalate if you encounter blockers that prevent completion.

---

**Test Workflow File**: [WORKFLOW_FILE_PATH]

Please read this file first to understand the full requirements, then proceed with implementation.
```

Generate the actual prompt:

```bash
echo "✍️  Generating comprehensive prompt..."
echo ""

# Create prompt (simplified for Phase 0 - just reference the workflow file)
AGENT_PROMPT="# Task: ${TASK_NAME}

## Context
You are working on project: ${PROJECT_PATH}

This is an autonomous development task executed by Project Orchestrator (Phase 0 POC).

## Your Mission
Read and execute the test workflow specified in: ${TEST_WORKFLOW}

## Technical Guidelines
- Make ALL changes in ${PROJECT_PATH} directory
- Follow existing code patterns and conventions
- Ensure all changes are complete and functional
- Run tests if applicable
- Report any blockers or issues

## Execution Instructions
1. Read the workflow file: ${TEST_WORKFLOW}
2. Understand all requirements and validation criteria
3. Analyze existing code in target files
4. Make necessary changes
5. Verify changes work correctly
6. Report completion with summary

Work autonomously. Only escalate if you encounter blockers that prevent completion.

---

**IMPORTANT**: All file operations must be in the ${PROJECT_PATH} directory.
"

echo "✅ Prompt generated ($(echo "$AGENT_PROMPT" | wc -w) words)"
echo ""
```

---

### Step 4: Launch Agent

Use Claude Code's native Task tool to execute the work in the target project.

**This is where the magic happens** - we launch a fresh Claude instance that works autonomously in the target project directory!

```markdown
ACTION REQUIRED: Launch agent using Task tool

Use the Task tool with:
- **subagent_type**: "general-purpose"
- **description**: "${TASK_NAME}"
- **prompt**: "${AGENT_PROMPT}"

The agent will work in the ${PROJECT_PATH} directory and complete the task autonomously.

Wait for agent completion, then proceed to Step 5.
```

---

### Step 5: Validate Results

After agent completes, run validation suite:

```bash
echo ""
echo "✅ Agent completed task"
echo ""
echo "🔍 Running Validation Suite..."
echo ""

# Run validation using orchestrate-validate command
# (In Phase 0, we'll prompt user to run this manually)

echo "ACTION REQUIRED: Run validation"
echo ""
echo "Execute: /project-orchestrator:orchestrate-validate ${PROJECT_PATH}"
echo ""
echo "Or manually check:"
echo "1. Navigate to project: cd ${PROJECT_PATH}"
echo "2. Start dev server: npm run dev"
echo "3. Open browser and verify functionality"
echo "4. Check console for errors"
echo ""
```

---

### Step 6: Generate Orchestration Report

```bash
echo "📊 Orchestration Report"
echo "======================="
echo ""
echo "Task: $TASK_NAME"
echo "Project: $PROJECT_PATH"
echo "Workflow: $TEST_WORKFLOW"
echo ""
echo "✅ Agent Execution: COMPLETED"
echo "⏳ Validation: PENDING (run orchestrate-validate)"
echo ""

# Calculate duration
ORCHESTRATION_END_TIME=$(date +%s)
ORCHESTRATION_DURATION=$((ORCHESTRATION_END_TIME - ORCHESTRATION_START_TIME))
ORCHESTRATION_MINUTES=$((ORCHESTRATION_DURATION / 60))

echo "⏱️  Duration: ${ORCHESTRATION_MINUTES}m ${ORCHESTRATION_DURATION}s"
echo ""
```

---

## Post-Orchestration Hook

```bash
echo "🎣 Post-Orchestration Hook"
echo ""

echo "✅ Orchestration Complete"
echo ""
echo "📈 Next Steps:"
echo "1. Review agent's changes in: ${PROJECT_PATH}"
echo "2. Run validation: /project-orchestrator:orchestrate-validate ${PROJECT_PATH}"
echo "3. Manually test in browser"
echo "4. Document results for Phase 0 evaluation"
echo ""
echo "📝 Phase 0 Metrics to Track:"
echo "- Did agent understand the task?"
echo "- Did agent complete successfully?"
echo "- Quality of agent's implementation?"
echo "- Did validation catch any issues?"
echo "- Total time vs manual estimate?"
echo ""
```

---

## Error Handling

**If workflow file is invalid**:
- Display error message with format requirements
- Exit with error

**If agent fails to complete**:
- Capture agent's error/blocker message
- Display summary
- Suggest manual intervention

**If validation fails**:
- Display validation errors
- Suggest fixes or retry

---

## Success Criteria

✅ Test workflow parsed successfully
✅ Comprehensive prompt generated
✅ Agent launched in target project
✅ Agent completed task
✅ Validation suite ready to run
✅ Orchestration report generated

---

## Phase 0 Learning Objectives

**Questions to Answer**:
1. Can we parse test workflows effectively?
2. Can we generate prompts that agents understand?
3. Do agents complete tasks successfully in target projects?
4. Is validation effective at catching issues?
5. What's the success rate (first try)?
6. What's the time savings vs manual?
7. Where do agents get stuck?
8. What prompt improvements are needed?

**Metrics to Track**:
- Prompt generation time
- Agent execution time
- Validation time
- Total time vs manual estimate
- Success rate (pass/fail)
- Iteration count (retries needed)
- Human intervention count

---

## Phase 1 Enhancements

**Planned Improvements**:
- Automated validation integration (no manual step)
- Retry logic with prompt refinement
- Decision maker (continue/retry/escalate)
- Human escalation handling
- Metrics persistence to /memory/
- Multiple test workflow support
- Parallel agent execution
