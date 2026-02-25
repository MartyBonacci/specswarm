---
description: Quality-gated merge to parent branch - validates code quality before allowing merge
args:
  - name: --force-quality
    description: Override quality threshold (e.g., --force-quality 70)
    required: false
  - name: --skip-tests
    description: Skip test validation (not recommended)
    required: false
  - name: --security-audit
    description: Run comprehensive security scan before merge
    required: false
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
  echo "Error: Not in a git repository"
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
RUN_SECURITY_AUDIT=false

for arg in $ARGUMENTS; do
  case "$arg" in
    --force-quality)
      shift
      FORCE_QUALITY="$1"
      ;;
    --skip-tests)
      SKIP_TESTS=true
      ;;
    --security-audit)
      RUN_SECURITY_AUDIT=true
      ;;
  esac
done
```

---

## Execution Steps

### Step 1: Display Banner

```bash
echo "SpecSwarm Ship - Quality-Gated Merge"
echo "=============================================="
echo ""
echo "This command enforces quality standards before merge:"
if [ "$RUN_SECURITY_AUDIT" = true ]; then
echo "  1. Runs comprehensive security audit"
echo "  2. Runs comprehensive quality analysis"
echo "  3. Checks quality score meets threshold"
echo "  4. If passing: merges to parent branch"
echo "  5. If failing: reports issues and blocks merge"
else
echo "  1. Runs comprehensive quality analysis"
echo "  2. Checks quality score meets threshold"
echo "  3. If passing: merges to parent branch"
echo "  4. If failing: reports issues and blocks merge"
fi
echo ""

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch: $CURRENT_BRANCH"
echo ""
```

---

### Step 1.5: Security Audit (Optional)

**IF --security-audit flag was provided, run comprehensive security scan:**

```bash
if [ "$RUN_SECURITY_AUDIT" = true ]; then
  echo "----------------------------------------"
  echo "Security Audit"
  echo "----------------------------------------"
  echo ""
  echo "Running comprehensive security scan before merge..."
  echo ""
  echo "Checks:"
  echo "  - Dependency vulnerabilities (npm/yarn/pnpm audit)"
  echo "  - Hardcoded secrets and credentials"
  echo "  - OWASP Top 10 code patterns (XSS, SQLi, etc.)"
  echo "  - Security configuration (CORS, headers, .env)"
  echo ""
fi
```

**IF RUN_SECURITY_AUDIT = true:**

Perform a security scan of the codebase:

1. **Dependency scan**: Run `npm audit` (or yarn/pnpm equivalent) and capture vulnerability counts
2. **Secret detection**: Scan git-tracked source files for hardcoded API keys, tokens, passwords, and private keys using regex patterns
3. **Code vulnerability scan**: Check source files for OWASP Top 10 patterns (SQL injection, XSS via innerHTML/dangerouslySetInnerHTML, command injection via exec/spawn, eval usage, path traversal)
4. **Configuration check**: Verify .env is gitignored, check for security middleware (helmet), check CORS configuration

**Calculate risk score**: (CRITICAL x 10) + (HIGH x 5) + (MEDIUM x 2) + (LOW x 1)

**IF any CRITICAL findings exist, BLOCK the merge:**

```bash
if [ "$RUN_SECURITY_AUDIT" = true ]; then
  if [ "$CRITICAL_SECURITY_COUNT" -gt 0 ]; then
    echo "Security audit FAILED - $CRITICAL_SECURITY_COUNT critical findings"
    echo ""
    echo "Critical security issues must be resolved before merging."
    echo "Review the findings above and fix all CRITICAL issues."
    echo ""
    echo "Then re-run: /sw:ship --security-audit"
    exit 1
  else
    echo "Security audit passed (Risk Score: $RISK_SCORE)"
    echo ""
  fi
fi
```

Generate security audit report: `security-audit-YYYY-MM-DD.md`

---

### Step 2: Run Quality Analysis

**YOU MUST NOW run the quality analysis using the SlashCommand tool:**

```
Use the SlashCommand tool to execute: /sw:analyze-quality
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
    echo "Using project quality threshold: ${THRESHOLD}%"
  fi
fi

# Override with --force-quality if provided
if [ -n "$FORCE_QUALITY" ]; then
  THRESHOLD=$FORCE_QUALITY
  echo "WARNING: Quality threshold overridden: ${THRESHOLD}%"
fi

echo ""
echo "Quality Threshold: ${THRESHOLD}%"
echo "Actual Quality Score: ${QUALITY_SCORE}%"
echo ""
```

**Decision Logic**:

IF QUALITY_SCORE >= THRESHOLD:
  - Quality gate PASSED
  - Proceed to Step 4 (Merge)
ELSE:
  - Quality gate FAILED
  - Display failure message
  - List top issues from analysis
  - Suggest fixes
  - EXIT without merging

```bash
if [ "$QUALITY_SCORE" -ge "$THRESHOLD" ]; then
  echo "Quality gate PASSED (${QUALITY_SCORE}% >= ${THRESHOLD}%)"
  echo ""
else
  echo "Quality gate FAILED (${QUALITY_SCORE}% < ${THRESHOLD}%)"
  echo ""
  echo "The code quality does not meet the required threshold."
  echo ""
  echo "Recommended Actions:"
  echo "  1. Review the quality analysis output above"
  echo "  2. Address critical and high-priority issues"
  echo "  3. Run /sw:analyze-quality again to verify improvements"
  echo "  4. Run /sw:ship again when quality improves"
  echo ""
  echo "Alternatively:"
  echo "  - Override threshold: /sw:ship --force-quality 70"
  echo "  - Note: Overriding quality gates is not recommended for production code"
  echo ""
  exit 1
fi
```

---

### Step 4: Merge to Parent Branch

**Quality gate passed! YOU MUST NOW merge using the SlashCommand tool:**

```
Use the SlashCommand tool to execute: /sw:complete
```

Wait for the merge to complete.

---

### Step 5: Success Report

**After successful merge, display:**

```bash
echo ""
echo "=============================================="
echo "SHIP SUCCESSFUL"
echo "=============================================="
echo ""
if [ "$RUN_SECURITY_AUDIT" = true ]; then
echo "- Security audit passed"
fi
echo "- Quality gate passed (${QUALITY_SCORE}%)"
echo "- Merged to parent branch"
echo "- Feature/bugfix complete"
echo ""
echo "Next Steps:"
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
