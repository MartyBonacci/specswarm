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

# Extract feature description (first non-flag argument)
for arg in $ARGUMENTS; do
  if [ "${arg:0:2}" != "--" ] && [ -z "$FEATURE_DESC" ]; then
    FEATURE_DESC="$arg"
  elif [ "$arg" = "--validate" ]; then
    RUN_VALIDATE=true
  elif [ "$arg" = "--quality-gate" ]; then
    shift
    QUALITY_GATE="$1"
  fi
done

# Validate feature description
if [ -z "$FEATURE_DESC" ]; then
  echo "❌ Error: Feature description required"
  echo ""
  echo "Usage: /specswarm:build \"feature description\" [--validate] [--quality-gate N]"
  echo ""
  echo "Examples:"
  echo "  /specswarm:build \"Add user authentication with email/password\""
  echo "  /specswarm:build \"Implement dark mode toggle\" --validate"
  echo "  /specswarm:build \"Add shopping cart\" --validate --quality-gate 85"
  exit 1
fi

# Get project root
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "❌ Error: Not in a git repository"
  exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"
```

---

## Execution Steps

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

Wait for completion. Verify spec.md was created.

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

**IMPORTANT**: This step is interactive. Wait for user to answer questions.

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

Wait for plan.md to be generated.

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

Wait for tasks.md to be generated.

```bash
# Count tasks
TASK_COUNT=$(grep -c '^###[[:space:]]*T[0-9]' tasks.md 2>/dev/null || echo "0")

echo ""
echo "✅ Task breakdown created ($TASK_COUNT tasks)"
echo ""
```

---

### Step 6: Phase 5 - Implementation

**YOU MUST NOW run the implement command using the SlashCommand tool:**

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  Phase 5: Implementing Feature"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This will execute all $TASK_COUNT tasks automatically."
echo "Estimated time: 2-5 minutes per task"
echo ""
```

```
Use the SlashCommand tool to execute: /specswarm:implement
```

Wait for implementation to complete.

```bash
echo ""
echo "✅ Implementation complete"
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

Wait for quality analysis to complete. Extract the quality score.

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

**Time Savings**: 85-90% reduction in manual orchestration overhead
