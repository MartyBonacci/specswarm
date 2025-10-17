---
description: AI-powered workflow recommendation based on context analysis
---

## User Input

```text
$ARGUMENTS
```

## Goal

Analyze current context (branch name, commits, file changes, user description) and recommend the most appropriate workflow.

---

## Execution Steps

### 1. Gather Context

```bash
echo "🤖 Workflow Suggestion - Analyzing Context..."

# Branch name
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

# Recent commits
RECENT_COMMITS=$(git log -5 --oneline 2>/dev/null)

# Changed files
CHANGED_FILES=$(git diff --name-only HEAD~5..HEAD 2>/dev/null)

# Uncommitted changes
UNCOMMITTED=$(git status --porcelain 2>/dev/null | head -10)

# User description (if provided)
USER_DESCRIPTION=$ARGUMENTS
```

---

### 2. Analyze Patterns

**Branch Name Analysis:**
```bash
if [[ "$CURRENT_BRANCH" =~ ^feature/ ]]; then
  PATTERN_SCORE["feature"]=5
elif [[ "$CURRENT_BRANCH" =~ ^bugfix/ ]]; then
  PATTERN_SCORE["bugfix"]=10
elif [[ "$CURRENT_BRANCH" =~ ^modify/ ]]; then
  PATTERN_SCORE["modify"]=10
elif [[ "$CURRENT_BRANCH" =~ ^hotfix/ ]]; then
  PATTERN_SCORE["hotfix"]=10
elif [[ "$CURRENT_BRANCH" =~ ^refactor/ ]]; then
  PATTERN_SCORE["refactor"]=10
elif [[ "$CURRENT_BRANCH" =~ ^deprecate/ ]]; then
  PATTERN_SCORE["deprecate"]=10
fi
```

**Commit Message Analysis:**
```bash
# Look for keywords in commits
if echo "$RECENT_COMMITS" | grep -qi "fix\|bug\|issue"; then
  PATTERN_SCORE["bugfix"]+=3
fi

if echo "$RECENT_COMMITS" | grep -qi "refactor\|cleanup\|improve"; then
  PATTERN_SCORE["refactor"]+=3
fi

if echo "$RECENT_COMMITS" | grep -qi "hotfix\|emergency\|critical"; then
  PATTERN_SCORE["hotfix"]+=5
fi

if echo "$RECENT_COMMITS" | grep -qi "deprecate\|remove\|sunset"; then
  PATTERN_SCORE["deprecate"]+=3
fi

if echo "$RECENT_COMMITS" | grep -qi "modify\|update\|change"; then
  PATTERN_SCORE["modify"]+=2
fi
```

**File Change Analysis:**
```bash
# Analyze changed files
FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l)

if [ "$FILE_COUNT" -gt 10 ]; then
  # Many files changed - likely refactor or major modify
  PATTERN_SCORE["refactor"]+=2
  PATTERN_SCORE["modify"]+=2
fi

# Check for test file changes
if echo "$CHANGED_FILES" | grep -qi "test\|spec"; then
  PATTERN_SCORE["bugfix"]+=1  # Tests often accompany bug fixes
fi
```

**User Description Analysis:**
```bash
if [ -n "$USER_DESCRIPTION" ]; then
  # Analyze user description for keywords
  if echo "$USER_DESCRIPTION" | grep -qi "bug\|fix\|broken\|not working"; then
    PATTERN_SCORE["bugfix"]+=5
  fi

  if echo "$USER_DESCRIPTION" | grep -qi "emergency\|critical\|urgent\|hotfix\|down"; then
    PATTERN_SCORE["hotfix"]+=7
  fi

  if echo "$USER_DESCRIPTION" | grep -qi "refactor\|clean\|improve quality"; then
    PATTERN_SCORE["refactor"]+=5
  fi

  if echo "$USER_DESCRIPTION" | grep -qi "modify\|change\|update\|add to"; then
    PATTERN_SCORE["modify"]+=5
  fi

  if echo "$USER_DESCRIPTION" | grep -qi "deprecate\|remove\|sunset\|phase out"; then
    PATTERN_SCORE["deprecate"]+=5
  fi
fi
```

---

### 3. Generate Recommendations

```markdown
# Workflow Recommendation

**Analysis Date**: YYYY-MM-DD

---

## Context Analysis

**Branch**: ${CURRENT_BRANCH}

**Recent Activity**:
- Commits analyzed: [N]
- Files changed: [N]
- Keywords found: [list]

**User Description**: ${USER_DESCRIPTION}

---

## Pattern Scores

| Workflow | Score | Confidence |
|----------|-------|------------|
| Bugfix | [N] | [High/Med/Low] |
| Modify | [N] | [High/Med/Low] |
| Hotfix | [N] | [High/Med/Low] |
| Refactor | [N] | [High/Med/Low] |
| Deprecate | [N] | [High/Med/Low] |
| Feature (SpecSwarm/SpecTest) | [N] | [High/Med/Low] |

---

## Recommendation

### 🎯 Primary Recommendation: `/specswarm:[workflow]`

**Confidence**: [High/Medium/Low]

**Reasoning**:
1. [Reason 1 - evidence from branch/commits/files]
2. [Reason 2]
3. [Reason 3]

**Why This Workflow**:
[Description of why this workflow fits]

**Expected Outcome**:
- [Outcome 1]
- [Outcome 2]

---

## Alternative Workflows

### Alternative 1: `/specswarm:[workflow2]`
**Confidence**: [Medium/Low]
**When to Use**: [Scenario where this would be better]

### Alternative 2: `/specswarm:[workflow3]`
**Confidence**: [Medium/Low]
**When to Use**: [Scenario where this would be better]

---

## Not Recommended

**Feature Development** → Use `/specswarm:*` workflows
**Reason**: [If feature development detected, redirect to appropriate plugin]

---

## Next Steps

1. **Review recommendation** above
2. **Run recommended workflow**: `/specswarm:[workflow]`
3. **If uncertain**, provide more context: `/specswarm:suggest "more details here"`

**Command to run**:
```
/specswarm:[recommended_workflow]
```
```

---

### 4. Output Recommendation

```
🤖 Workflow Suggestion Complete

🎯 Recommended Workflow: /specswarm:[workflow]
Confidence: [High/Medium/Low]

📊 Analysis:
- Branch pattern: [detected pattern]
- Commit keywords: [list]
- Files changed: [N]
- User signals: [description analysis]

📋 Full analysis (above)

⚡ Quick Start:
/specswarm:[recommended_workflow]
```

---

## Example Output

```
🤖 Workflow Suggestion Complete

🎯 Recommended Workflow: /specswarm:bugfix
Confidence: High

📊 Analysis:
- Branch pattern: bugfix/042-login-timeout
- Commit keywords: "fix", "bug", "timeout issue"
- Files changed: 3 (auth, tests)
- User signals: "login not working"

Reasoning:
1. Branch name explicitly indicates bugfix
2. Commit messages contain bug-fix keywords
3. User description indicates broken functionality
4. Test files modified (typical of bugfix workflow)

⚡ Quick Start:
/speclab:bugfix
```

---

## Decision Logic

**High Confidence (score ≥ 10)**:
- Clear indicators from multiple sources
- Strong pattern match
- Recommend with confidence

**Medium Confidence (score 5-9)**:
- Some indicators present
- Moderate pattern match
- Offer alternatives

**Low Confidence (score < 5)**:
- Weak or conflicting signals
- Suggest multiple options
- Ask for more context

---

## Success Criteria

✅ Context gathered from git history
✅ Patterns analyzed (branch, commits, files, description)
✅ Scores calculated for each workflow
✅ Primary recommendation provided
✅ Alternative workflows suggested
✅ Next steps clear
