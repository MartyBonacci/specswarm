---
description: Quality-gated merge to parent branch - validates code quality before allowing merge
natural_language_enabled: true
nl_triggers: ship, deploy, merge, complete, finish, done, ready
nl_safety_confirmation: required
nl_examples:
  - "Ship this feature"
  - "Deploy to production"
  - "Merge to main"
  - "I'm done with this"
args:
  - name: --force-quality
    description: Override quality threshold (e.g., --force-quality 70)
    required: false
  - name: --skip-tests
    description: Skip test validation (not recommended)
    required: false
---

## Natural Language Support (v3.3.0+)

This command can be triggered via **natural language** - but it **ALWAYS requires confirmation** for safety!

**Natural Language Examples:**
- "Ship this feature" ⚠️ (requires confirmation)
- "Deploy to production" ⚠️ (requires confirmation)
- "Merge to main" ⚠️ (requires confirmation)
- "I'm done with this" ⚠️ (requires confirmation)

**🛡️ CRITICAL SAFETY FEATURE:**
SHIP commands detected via natural language will ALWAYS ask for explicit "yes" confirmation before executing. This prevents accidental merges or deployments that could have significant consequences:
- Premature feature deployment
- Incomplete code in production
- Merge conflicts
- Breaking main branch

**What This Command Does:**
Runs the entire SHIP workflow with quality gates:
1. Runs quality analysis (`/specswarm:analyze-quality`)
2. Checks quality threshold (default 80%)
3. Merges to parent branch (`/specswarm:complete`)
4. Cleans up feature branch

**Slash Command (Precise):**
```bash
/specswarm:ship [--force-quality N] [--skip-tests]
```

Both methods work identically, with mandatory safety confirmation for natural language triggers.

---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Execute final quality gate validation and merge to parent branch.

**Purpose**: Enforce quality standards before merging features/bugfixes, preventing low-quality code from entering the codebase.

**Workflow**: Quality Analysis → Threshold Check → Merge (if passing)

**Quality Gates**:
- Default threshold: 80% quality score
- Configurable via `--force-quality` flag
- Reads `.specswarm/quality-standards.md` for project-specific thresholds

---

## Pre-Flight Checks

```bash
# Ensure we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "❌ Error: Not in a git repository"
  echo ""
  echo "This command must be run from within a git repository."
  exit 1
fi

# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

# Parse arguments
FORCE_QUALITY=""
SKIP_TESTS=false

for arg in $ARGUMENTS; do
  case "$arg" in
    --force-quality)
      shift
      FORCE_QUALITY="$1"
      ;;
    --skip-tests)
      SKIP_TESTS=true
      ;;
  esac
done
```

---

## Execution Steps

### Step 1: Display Banner

```bash
echo "🚢 SpecSwarm Ship - Quality-Gated Merge"
echo "══════════════════════════════════════════"
echo ""
echo "This command enforces quality standards before merge:"
echo "  1. Runs comprehensive quality analysis"
echo "  2. Checks quality score meets threshold"
echo "  3. If passing: merges to parent branch"
echo "  4. If failing: reports issues and blocks merge"
echo ""

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "📍 Current branch: $CURRENT_BRANCH"
echo ""
```

---

### Step 2: Run Quality Analysis

**YOU MUST NOW run the quality analysis using the SlashCommand tool:**

```
Use the SlashCommand tool to execute: /specswarm:analyze-quality
```

Wait for the quality analysis to complete and extract the quality score from the output.

**Expected Output Pattern**: Look for quality score in output (e.g., "Overall Quality: 85%")

Store the quality score as QUALITY_SCORE.

---

### Step 3: Check Quality Threshold

**YOU MUST NOW check if quality meets threshold:**

```bash
# Determine threshold
DEFAULT_THRESHOLD=80

# Check for project-specific threshold in .specswarm/quality-standards.md
THRESHOLD=$DEFAULT_THRESHOLD

if [ -f ".specswarm/quality-standards.md" ]; then
  # Try to extract threshold from quality standards file
  PROJECT_THRESHOLD=$(grep -i "^quality_threshold:" .specswarm/quality-standards.md | grep -oE '[0-9]+' || echo "")
  if [ -n "$PROJECT_THRESHOLD" ]; then
    THRESHOLD=$PROJECT_THRESHOLD
    echo "📋 Using project quality threshold: ${THRESHOLD}%"
  fi
fi

# Override with --force-quality if provided
if [ -n "$FORCE_QUALITY" ]; then
  THRESHOLD=$FORCE_QUALITY
  echo "⚠️  Quality threshold overridden: ${THRESHOLD}%"
fi

echo ""
echo "🎯 Quality Threshold: ${THRESHOLD}%"
echo "📊 Actual Quality Score: ${QUALITY_SCORE}%"
echo ""
```

**Decision Logic**:

IF QUALITY_SCORE >= THRESHOLD:
  - ✅ Quality gate PASSED
  - Proceed to Step 4 (Merge)
ELSE:
  - ❌ Quality gate FAILED
  - Display failure message
  - List top issues from analysis
  - Suggest fixes
  - EXIT without merging

```bash
if [ "$QUALITY_SCORE" -ge "$THRESHOLD" ]; then
  echo "✅ Quality gate PASSED (${QUALITY_SCORE}% >= ${THRESHOLD}%)"
  echo ""
else
  echo "❌ Quality gate FAILED (${QUALITY_SCORE}% < ${THRESHOLD}%)"
  echo ""
  echo "The code quality does not meet the required threshold."
  echo ""
  echo "🔧 Recommended Actions:"
  echo "  1. Review the quality analysis output above"
  echo "  2. Address critical and high-priority issues"
  echo "  3. Run /specswarm:analyze-quality again to verify improvements"
  echo "  4. Run /specswarm:ship again when quality improves"
  echo ""
  echo "💡 Alternatively:"
  echo "  - Override threshold: /specswarm:ship --force-quality 70"
  echo "  - Note: Overriding quality gates is not recommended for production code"
  echo ""
  exit 1
fi
```

---

### Step 4: Merge to Parent Branch

**Quality gate passed! YOU MUST NOW merge using the SlashCommand tool:**

```
Use the SlashCommand tool to execute: /specswarm:complete
```

Wait for the merge to complete.

---

### Step 5: Success Report

**After successful merge, display:**

```bash
echo ""
echo "══════════════════════════════════════════"
echo "🎉 SHIP SUCCESSFUL"
echo "══════════════════════════════════════════"
echo ""
echo "✅ Quality gate passed (${QUALITY_SCORE}%)"
echo "✅ Merged to parent branch"
echo "✅ Feature/bugfix complete"
echo ""
echo "📝 Next Steps:"
echo "  - Pull latest changes in other branches"
echo "  - Consider creating a release tag if ready"
echo "  - Update project documentation if needed"
echo ""
```

---

## Error Handling

If any step fails:

1. **Quality analysis fails**: Report error and suggest checking logs
2. **Quality threshold not met**: Display issues and exit (see Step 3)
3. **Merge fails**: Report git errors and suggest manual resolution

**All errors should EXIT with clear remediation steps.**

---

## Notes

**Design Philosophy**:
- Quality gates prevent technical debt accumulation
- Encourages addressing issues before merge (not after)
- Configurable thresholds balance strictness with pragmatism
- Override flag available but discouraged for production code

**Quality Standards File** (`.specswarm/quality-standards.md`):
```yaml
---
quality_threshold: 85
enforce_gates: true
---

# Project Quality Standards

Minimum quality threshold: 85%
...
```

If `enforce_gates: false`, ship will warn but not block merge.
