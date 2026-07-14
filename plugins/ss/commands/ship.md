---
description: "[migrating to /ss:ship] Quality-gated merge to parent branch"
effort: high
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

# Initialize audit logging
PLUGIN_DIR="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
if [ -f "${PLUGIN_DIR}/lib/audit-logger.sh" ]; then
  source "${PLUGIN_DIR}/lib/audit-logger.sh"
fi
```

---

## Execution Steps

### Step 1: Display Banner

```bash
echo "🚢 SpecSwarm Ship - Quality-Gated Merge"
echo "══════════════════════════════════════════"
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
echo "📍 Current branch: $CURRENT_BRANCH"
echo ""
```

---

### Step 1.5: Security Audit (Optional)

**IF --security-audit flag was provided, run comprehensive security scan:**

```bash
if [ "$RUN_SECURITY_AUDIT" = true ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔒 Security Audit"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Running comprehensive security scan before merge..."
  echo ""
  echo "Checks:"
  echo "  • Dependency vulnerabilities (npm/yarn/pnpm audit)"
  echo "  • Hardcoded secrets and credentials"
  echo "  • OWASP Top 10 code patterns (XSS, SQLi, etc.)"
  echo "  • Security configuration (CORS, headers, .env)"
  echo ""
fi
```

**IF RUN_SECURITY_AUDIT = true:**

Perform a security scan of the codebase:

1. **Dependency scan**: Run `npm audit` (or yarn/pnpm equivalent) and capture vulnerability counts
2. **Secret detection**: Scan git-tracked source files for hardcoded API keys, tokens, passwords, and private keys using regex patterns
3. **Code vulnerability scan**: Check source files for OWASP Top 10 patterns (SQL injection, XSS via innerHTML/dangerouslySetInnerHTML, command injection via exec/spawn, eval usage, path traversal)
4. **Configuration check**: Verify .env is gitignored, check for security middleware (helmet), check CORS configuration

**Calculate risk score**: (CRITICAL × 10) + (HIGH × 5) + (MEDIUM × 2) + (LOW × 1)

**IF any CRITICAL findings exist, BLOCK the merge:**

```bash
if [ "$RUN_SECURITY_AUDIT" = true ]; then
  if [ "$CRITICAL_SECURITY_COUNT" -gt 0 ]; then
    echo "❌ Security audit FAILED - $CRITICAL_SECURITY_COUNT critical findings"
    echo ""
    echo "Critical security issues must be resolved before merging."
    echo "Review the findings above and fix all CRITICAL issues."
    echo ""
    echo "Then re-run: /ss:ship --security-audit"
    exit 1
  else
    echo "✅ Security audit passed (Risk Score: $RISK_SCORE)"
    echo ""
  fi
fi
```

Generate security audit report: `security-audit-YYYY-MM-DD.md`

---

### Step 1.7: Verify-Queue Precondition Check (v7.11.0)

**Purpose**: Catch the silent-failure case where a chunk shipped without per-task adversarial verification ever running. This is the end-of-chunk catch-net for the verify-queue (complements the `/ss:implement` drain step). Project-agnostic — reads only `.specswarm/verify-queue/` and the feature's `tasks.md`.

```bash
PLUGIN_DIR="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/verify/queue.sh"

PENDING=$(ss_verify_queue_count pending)
VERIFIED=$(ss_verify_queue_count verified)
FLAGGED=$(ss_verify_queue_count flagged)
NEEDS_SIGHTED=$(ss_verify_queue_count needs-sighted)

# Count completed task checkboxes across the current feature's tasks.md.
# Canonical format: "- [X] T### …" (see /ss:tasks Canonical Task Line Format).
COMPLETED_TASKS=0
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
FEATURE_NUM=$(echo "$CURRENT_BRANCH" | grep -oE '^[0-9]{3}' || true)
if [ -n "$FEATURE_NUM" ]; then
  # shellcheck disable=SC1091
  source "${PLUGIN_DIR}/lib/features-location.sh" 2>/dev/null || true
  if declare -f find_feature_dir >/dev/null 2>&1 && find_feature_dir "$FEATURE_NUM" "$REPO_ROOT" 2>/dev/null; then
    TASKS_MD="${FEATURE_DIR}/tasks.md"
    if [ -f "$TASKS_MD" ]; then
      COMPLETED_TASKS=$(grep -cE '^[[:space:]]*-[[:space:]]+\[[xX]\][[:space:]]+T[0-9]+' "$TASKS_MD" 2>/dev/null || echo 0)
    fi
  fi
fi

echo "🔍 Verify-queue: pending=${PENDING}, verified=${VERIFIED}, flagged=${FLAGGED}, needs-sighted=${NEEDS_SIGHTED}; completed tasks=${COMPLETED_TASKS}"

# NEEDS-SIGHTED markers BLOCK the ship (v7.14.0 — AUTO-MAGIC WS5, decision D3).
# Origin lesson: every false-green that reached the product owner was a visual
# slice — correct DOM + green suites, visually wrong result. Unlike the WARNs
# below, this gate cannot be scrolled past; it is resolved by the batch sighted
# review (next step) or per-task /ss:verify --sighted, never by ignoring it.
if [ "$NEEDS_SIGHTED" -gt 0 ]; then
  echo "🛑 ${NEEDS_SIGHTED} task(s) NEED SIGHTED REVIEW — /ss:ship is blocked until each has explicit human sign-off:"
  find "$(ss_verify_queue_dir)" -maxdepth 1 -type f -name '*.needs-sighted' 2>/dev/null \
    | while IFS= read -r f; do echo "    • $(basename "$f" .needs-sighted)"; done
  echo "    Proceeding to the batch sighted review below."
fi

# FLAGGED markers must be reviewed before shipping.
if [ "$FLAGGED" -gt 0 ]; then
  echo "⚠️  ${FLAGGED} task(s) FLAGGED by spec-mentor (DRIFT / NEEDS-MARTY) — review before merge:"
  find "$(ss_verify_queue_dir)" -maxdepth 1 -type f -name '*.flagged' 2>/dev/null \
    | while IFS= read -r f; do echo "    • $(basename "$f" .flagged)"; done
  echo "    Run /ss:verify --queue for details. Resolve or explicitly accept before /ss:ship."
fi

# PENDING markers were never drained — drain them first.
if [ "$PENDING" -gt 0 ]; then
  echo "⚠️  ${PENDING} verification marker(s) still PENDING — auto-verification did not finish."
  echo "    Recommended: run /ss:verify --drain before shipping."
fi

# WARN-on-zero: tasks were completed but the queue is empty → auto-verification never ran.
if [ "$COMPLETED_TASKS" -gt 0 ] && [ "$PENDING" -eq 0 ] && [ "$VERIFIED" -eq 0 ] && [ "$FLAGGED" -eq 0 ]; then
  echo "⚠️  ${COMPLETED_TASKS} completed task(s) but verify-queue is EMPTY — per-task adversarial"
  echo "    verification never ran. Likely tasks.md was not in canonical '- [ ] T###' checkbox"
  echo "    format, or the tasks-completion-detector hook was inactive. This chunk is shipping"
  echo "    under local-gates-only verification. Confirm a whole-chunk spec-mentor review was done."
fi
```

The flagged/pending findings are **non-blocking** (WARNs) so the user makes an informed merge decision; quality-threshold blocking remains the job of Step 3. **NEEDS-SIGHTED markers are the exception: they BLOCK.**

### Step 1.8: Batch Sighted Review (v7.14.0 — runs only when needs-sighted > 0)

**Claude — resolve every `.needs-sighted` marker before any merge step runs:**

1. For each needs-sighted task, load its marker (task_desc, details) and diff summary; prepare a one-line "what changed visually, where to look" per task. If a browser MCP is available, offer screenshots of each surface (and ALWAYS read the browser console — console errors are part of the review).
2. Capture verdicts in batched AskUserQuestion calls (≤4 per call), one question per task:
   - question: "Sighted review of <tid>: <what changed>. Does it look right?"
   - header: "Sighted <tid>"
   - options: "Looks right" / "Wrong — needs fixes (describe in notes)" / "Right + note a ruling"
3. Resolve each marker (`source ${PLUGIN_DIR}/lib/verify/queue.sh`):
   - approve → `ss_verify_queue_resolve <tid> SIGHTED-PASS "ship-time sighted sign-off"`
   - reject  → `ss_verify_queue_resolve <tid> SIGHTED-REJECT "<what's wrong>"` — then **HALT the ship**: the rejects become the immediate fix list; re-run /ss:ship after fixes re-verify.
4. Distill reusable visual rulings into the taste model (`ss_taste_add … judgment "sighted-gate verdict <tid> …"`) per the v7.13.0 rule.
5. Re-check: `ss_verify_queue_count needs-sighted` must be 0 before continuing to Step 2. No flag bypasses this gate.

---

### Step 2: Run Quality Analysis

**MCP Enhancement (automatic — no action needed):**
If MCP servers are configured:
- **playwright**: Run a quick browser smoke test before merging

**YOU MUST NOW run the quality analysis using the SlashCommand tool:**

```
Use the SlashCommand tool to execute: /ss:analyze-quality
```

Wait for the quality analysis to complete and extract the quality score from the output.

**Expected Output Pattern**: Look for quality score in output (e.g., "Overall Quality: 85%")

Store the quality score as QUALITY_SCORE.

---

<!-- ========== MULTI-AGENT REVIEW PIPELINE (SpecSwarm 5.3.0) ========== -->
<!-- Added by Marty Bonacci & Claude Code (2026) — invisible quality gate -->

### Step 2.5: Multi-Agent Review Pipeline

**Purpose**: Pre-merge parallel review by specialized agents (silent-failure-hunter, code-reviewer, type-design-analyzer, comment-analyzer). Catches issues the single-pass quality score misses. Runs only if `pr-review-toolkit` is installed; degrades gracefully otherwise.

**YOU MUST run this review when QUALITY_SCORE is computed and BEFORE the threshold check:**

1. **Determine which review agents are available** by checking for `pr-review-toolkit:*` subagents. Build a list of available reviewers from this set:
   - `pr-review-toolkit:silent-failure-hunter`
   - `pr-review-toolkit:code-reviewer`
   - `pr-review-toolkit:type-design-analyzer`
   - `pr-review-toolkit:comment-analyzer`

   If **none are available**, log skip and proceed to Step 3 (existing quality threshold check is sufficient):
   ```bash
   source "$PLUGIN_DIR/lib/audit-logger.sh"
   audit_log "multi_agent_review" feature="$FEATURE_NUM" status="skipped" reason="no_agents_available"
   ```
   Skip the rest of this step.

2. **Compute the merge diff** using Bash:
   ```bash
   PARENT_BRANCH=$(jq -r '.parent_branch // "main"' .specswarm/build-loop.state 2>/dev/null || echo "main")
   git fetch origin "$PARENT_BRANCH" 2>/dev/null || true
   MERGE_DIFF_FILES=$(git diff --name-only "${PARENT_BRANCH}"...HEAD 2>/dev/null || echo "")
   ```

3. **Locate spec.md and plan.md** for context (already known via FEATURE_DIR/build state).

4. **Dispatch all available agents IN PARALLEL** via the Task tool. Send a single message with multiple Task tool calls — one per available agent. Each call gets:
   - `subagent_type`: the agent name (e.g., `pr-review-toolkit:silent-failure-hunter`)
   - `description`: 3-5 word description (e.g., `Pre-merge code review`)
   - `prompt`: A focused brief tailored to that agent's specialty, including:
     - The merge diff (`git diff ${PARENT_BRANCH}...HEAD`) — truncate to first 1000 lines if huge
     - The path to `spec.md` and `plan.md` for authoritative context
     - Instruction to report findings as JSON-ish lines: `[SEVERITY] file:line — description` where severity is `BLOCKER|HIGH|MEDIUM|LOW`
     - Instruction to keep total response under 400 words

5. **Hard cap: 60 seconds total** for the parallel review block. If any agent has not returned by then, mark its result as "timed out" and proceed without it. Log:
   ```bash
   audit_log "multi_agent_review" feature="$FEATURE_NUM" status="partial_timeout" timed_out="<count>"
   ```
   Timeouts never block the merge.

6. **Aggregate findings** from all returned agents. Categorize by severity:
   - **BLOCKER** findings → display them clearly to the user, ask once: `Continue with merge despite blockers? (yes/no)`. If user declines, exit without merging. Audit log:
     ```bash
     audit_log "multi_agent_review" feature="$FEATURE_NUM" status="blocked_user_review" blocker_count="$N"
     ```
   - **HIGH/MEDIUM/LOW** findings → display as warnings inline; do not block. Audit log status="warnings_surfaced".
   - **No findings** → display a single line: `🤝 Multi-agent review: clean (<N> agents).` Audit log status="clean".

7. **Display format** for findings (regardless of decision):
   ```
   🤝 Multi-Agent Review (parent: <PARENT_BRANCH>)
   ===============================================
   Agents run: silent-failure-hunter, code-reviewer, type-design-analyzer
   Duration:   <seconds>s

   <findings grouped by severity, BLOCKER first>
   ```

**Important**:
- Never block on agent dispatch errors or timeouts; only block on confirmed BLOCKER findings, and only after user confirmation.
- The existing quality threshold check (Step 3) still runs after this, so this is purely additive.
- Always log a `multi_agent_review` audit event so users can later audit which finds were surfaced.

<!-- ========== END MULTI-AGENT REVIEW PIPELINE ========== -->

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
  echo "  3. Run /ss:analyze-quality again to verify improvements"
  echo "  4. Run /ss:ship again when quality improves"
  echo ""
  echo "💡 Alternatively:"
  echo "  - Override threshold: /ss:ship --force-quality 70"
  echo "  - Note: Overriding quality gates is not recommended for production code"
  echo ""
  exit 1
fi
```

---

### Step 4: Merge to Parent Branch

**Quality gate passed! YOU MUST NOW merge using the SlashCommand tool:**

```
Use the SlashCommand tool to execute: /ss:complete
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
if [ "$RUN_SECURITY_AUDIT" = true ]; then
echo "✅ Security audit passed"
fi
echo "✅ Quality gate passed (${QUALITY_SCORE}%)"
echo "✅ Merged to parent branch"
echo "✅ Feature/bugfix complete"

# Log ship event to audit
FEATURE_NUM=$(git rev-parse --abbrev-ref HEAD 2>/dev/null | grep -oE '^[0-9]{3}' || echo "000")
if type audit_ship &>/dev/null 2>&1; then
  audit_ship "$FEATURE_NUM" "success" "${QUALITY_SCORE:-0}"
fi
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
