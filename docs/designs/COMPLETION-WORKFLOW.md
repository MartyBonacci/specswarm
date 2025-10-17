# Completion Workflow Design - `/specswarm:complete`

**Status:** Design Proposal
**Phase:** 2.2
**Priority:** High
**Created:** 2025-10-16

---

## Problem Statement

After feature development or bugfix, users are left with:
- Uncommitted changes on feature branch
- Diagnostic files to clean up
- No clear process to merge to main
- No completion verification

**Current user question:** "Now what? How do I finish this?"

---

## Solution: `/specswarm:complete` Command

**Purpose:** Complete feature/bugfix workflow and merge to main

**Scope:** Handles cleanup, commit, testing, and merge

---

## User Experience

### Invocation

```bash
# Auto-detect from current branch
/specswarm:complete

# Or specify feature number
/specswarm:complete 915

# Or provide description
/specswarm:complete "Password reset feature"
```

### Expected Flow

```
🎯 Feature Completion Workflow
══════════════════════════════════════════

Detected: Feature 915 (password-reset-flow)
Branch: 915-add-password-reset-flow-with-email-token-verification...
Type: Feature implementation + bugfix

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phase 1: Cleanup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 Diagnostic Files Found:
  - check-tokens.ts (debugging script)
  - diagnose-password-reset.ts (investigation)
  - check_tokens.js (temp file)

What should I do with these files?
  1. Delete all (recommended)
  2. Move to .claude/debug/ (keep for review)
  3. Keep as-is (commit them)
  4. Manual selection

Choice (1-4): 1

✓ Deleted 3 diagnostic files
✓ Cleaned up temporary files

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phase 2: Pre-Merge Validation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Running validation checks...

✓ All tests passing (127/127)
✓ No TypeScript errors
✓ No ESLint warnings
✓ Build successful
✓ Feature complete (17/17 tasks)
✓ All bugs resolved (916, 917, 918)

Quality Score: 95/100

Ready to commit and merge!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phase 3: Commit Changes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Files to commit:
  M src/routes/auth.ts (7 property name fixes)
  M app/pages/ResetPassword.tsx (cache headers)
  A features/915-password-reset-flow.../bugfix.md
  A features/918-camelcase-property-access/bug-chain.md

Suggested commit message:
┌────────────────────────────────────────────┐
│ feat: password reset flow with email      │
│ token verification                         │
│                                            │
│ Implements password reset with:           │
│ - Email token generation                  │
│ - Token verification endpoint             │
│ - Password reset completion               │
│ - Mailgun email integration               │
│                                            │
│ Fixes:                                     │
│ - Bug 916: Multiple tokens per user       │
│ - Bug 918: Property name mismatch          │
│                                            │
│ 🤖 Generated with SpecSwarm                │
│ Quality Score: 95/100                      │
│                                            │
│ Co-Authored-By: Claude <noreply@...>      │
└────────────────────────────────────────────┘

Edit commit message? (y/n): n

✓ Changes committed to feature branch
✓ Pushed to remote

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phase 4: Merge to Main
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Ready to merge feature to main branch.

⚠️  IMPORTANT: This will merge your changes to main.
    Make sure you've tested the feature thoroughly.

Proceed with merge? (y/n): y

Checking out main...
Pulling latest changes...
✓ Main branch up to date

Merging feature branch (no-ff)...
✓ Merge successful

Pushing to remote...
✓ Main branch updated

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phase 5: Cleanup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Delete feature branch? (y/n): y

✓ Deleted local branch: 915-add-password-reset-flow...
✓ Deleted remote branch: origin/915-add-password-reset-flow...
✓ Updated feature status: Complete

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 Feature Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Feature 915: Password Reset Flow
✓ Implementation: Complete (17 tasks)
✓ Bugs Fixed: 3 (916, 917, 918)
✓ Quality Score: 95/100
✓ Merged to: main
✓ Branch: Deleted

📊 Final Metrics:
  Time to Completion: 3.5 hours
  Files Changed: 24
  Lines Added: 1,847
  Tests Added: 12

📂 Feature Archive:
  features/915-add-password-reset-flow.../
    - spec.md (feature specification)
    - plan.md (implementation plan)
    - tasks.md (28 tasks)
    - bugfix.md (bugs 916, 918)
    - bug-chain.md (debugging timeline)

🚀 Next Steps:
  - Deploy to staging: npm run deploy:staging
  - Run smoke tests: npm run test:e2e
  - Monitor production: Check error rates

───────────────────────────────────────────
```

---

## Command Design

### Detection Logic

```bash
# Step 1: Detect current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Step 2: Extract feature/bug number
FEATURE_NUM=$(echo "$CURRENT_BRANCH" | grep -oE '^[0-9]{3}' || \
              echo "$CURRENT_BRANCH" | grep -oE 'feature/([0-9]{3})' | grep -oE '[0-9]{3}' || \
              echo "$CURRENT_BRANCH" | grep -oE 'bugfix/([0-9]{3})' | grep -oE '[0-9]{3}')

# Step 3: Determine workflow type
if echo "$CURRENT_BRANCH" | grep -qE '^(bugfix|bug|fix)/'; then
  WORKFLOW_TYPE="bugfix"
elif echo "$CURRENT_BRANCH" | grep -qE '^(feature|feat)/'; then
  WORKFLOW_TYPE="feature"
elif echo "$CURRENT_BRANCH" | grep -qE '^[0-9]{3}-'; then
  WORKFLOW_TYPE="feature"  # Direct feature number branch
else
  # Ask user
  echo "Unable to detect workflow type from branch: $CURRENT_BRANCH"
  read -p "Is this a feature or bugfix? (feature/bugfix): " WORKFLOW_TYPE
fi

# Step 4: Find feature directory
FEATURE_DIR=$(find features -maxdepth 1 -type d -name "${FEATURE_NUM}-*" | head -1)
```

### Phase 1: Cleanup

```bash
cleanup_diagnostic_files() {
  local feature_num=$1
  local repo_root=$2

  # Patterns for diagnostic files
  local patterns=(
    "check-*.ts"
    "check-*.js"
    "check_*.ts"
    "check_*.js"
    "diagnose-*.ts"
    "diagnose-*.js"
    "debug-*.ts"
    "debug-*.js"
    "temp-*.ts"
    "temp-*.js"
  )

  # Find matching files
  local diagnostic_files=()
  for pattern in "${patterns[@]}"; do
    while IFS= read -r file; do
      diagnostic_files+=("$file")
    done < <(find "$repo_root" -maxdepth 1 -name "$pattern" 2>/dev/null)
  done

  if [ ${#diagnostic_files[@]} -eq 0 ]; then
    echo "✓ No diagnostic files to clean up"
    return 0
  fi

  # Show files and ask what to do
  echo ""
  echo "📂 Diagnostic Files Found:"
  for file in "${diagnostic_files[@]}"; do
    local basename=$(basename "$file")
    local size=$(du -h "$file" | cut -f1)
    echo "  - $basename ($size)"
  done
  echo ""

  echo "What should I do with these files?"
  echo "  1. Delete all (recommended)"
  echo "  2. Move to .claude/debug/ (keep for review)"
  echo "  3. Keep as-is (will be committed)"
  echo "  4. Manual selection"
  echo ""
  read -p "Choice (1-4): " cleanup_choice

  case $cleanup_choice in
    1)
      for file in "${diagnostic_files[@]}"; do
        rm -f "$file"
      done
      echo "✓ Deleted ${#diagnostic_files[@]} diagnostic files"
      ;;
    2)
      mkdir -p .claude/debug
      for file in "${diagnostic_files[@]}"; do
        mv "$file" .claude/debug/
      done
      echo "✓ Moved ${#diagnostic_files[@]} files to .claude/debug/"
      ;;
    3)
      echo "✓ Keeping diagnostic files"
      ;;
    4)
      for file in "${diagnostic_files[@]}"; do
        read -p "Delete $(basename "$file")? (y/n): " delete_choice
        if [ "$delete_choice" = "y" ]; then
          rm -f "$file"
          echo "  ✓ Deleted"
        else
          echo "  ✓ Kept"
        fi
      done
      ;;
  esac
}
```

### Phase 2: Pre-Merge Validation

```bash
validate_before_merge() {
  local feature_dir=$1

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Phase 2: Pre-Merge Validation"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Running validation checks..."
  echo ""

  # Run tests
  echo "  Running tests..."
  if npm test --silent 2>&1 | grep -q "passing"; then
    test_count=$(npm test --silent 2>&1 | grep -oE '[0-9]+ passing' | grep -oE '[0-9]+')
    echo "  ✓ All tests passing ($test_count/$test_count)"
  else
    echo "  ❌ Tests failing"
    echo ""
    echo "Cannot merge with failing tests. Fix tests first."
    return 1
  fi

  # TypeScript check
  echo "  Checking TypeScript..."
  if npx tsc --noEmit 2>&1 | grep -q "error"; then
    echo "  ❌ TypeScript errors found"
    echo ""
    echo "Cannot merge with TypeScript errors. Fix errors first."
    return 1
  else
    echo "  ✓ No TypeScript errors"
  fi

  # Build check
  echo "  Running build..."
  if npm run build --silent 2>&1 | grep -qE "(error|Error|ERROR)"; then
    echo "  ❌ Build failed"
    echo ""
    echo "Cannot merge with build errors. Fix build first."
    return 1
  else
    echo "  ✓ Build successful"
  fi

  # Feature completion check
  if [ -f "$feature_dir/tasks.md" ]; then
    total_tasks=$(grep -cE '^### T[0-9]{3}:' "$feature_dir/tasks.md")
    completed_tasks=$(grep -cE '^### T[0-9]{3}:.*\[x\]' "$feature_dir/tasks.md" || echo 0)
    echo "  ✓ Feature complete ($completed_tasks/$total_tasks tasks)"
  fi

  # Bug resolution check
  if [ -f "$feature_dir/bugfix.md" ]; then
    bug_count=$(grep -cE '^## Bug [0-9]{3}:' "$feature_dir/bugfix.md" || echo 0)
    echo "  ✓ All bugs resolved ($bug_count bugs)"
  fi

  echo ""
  echo "Ready to commit and merge!"
  echo ""

  return 0
}
```

### Phase 3: Commit Changes

```bash
commit_feature_changes() {
  local feature_num=$1
  local feature_dir=$2
  local workflow_type=$3

  # Get feature description from spec
  if [ -f "$feature_dir/spec.md" ]; then
    feature_title=$(grep -m1 '^# Feature' "$feature_dir/spec.md" | sed 's/^# Feature [0-9]*: //')
  else
    feature_title="Feature $feature_num"
  fi

  # Collect bug numbers if bugfix
  local bug_numbers=()
  if [ -f "$feature_dir/bugfix.md" ]; then
    while IFS= read -r bug; do
      bug_numbers+=("$bug")
    done < <(grep -oE 'Bug [0-9]{3}' "$feature_dir/bugfix.md" | grep -oE '[0-9]{3}' | sort -u)
  fi

  # Generate commit message
  local commit_type
  if [ "$workflow_type" = "bugfix" ]; then
    commit_type="fix"
  else
    commit_type="feat"
  fi

  local commit_msg="$commit_type: $feature_title

"

  # Add description from spec
  if [ -f "$feature_dir/spec.md" ]; then
    description=$(grep -A 5 '^## Summary' "$feature_dir/spec.md" | tail -n +2 | head -3)
    commit_msg+="$description

"
  fi

  # Add bug fixes if any
  if [ ${#bug_numbers[@]} -gt 0 ]; then
    commit_msg+="Fixes:
"
    for bug in "${bug_numbers[@]}"; do
      commit_msg+="- Bug $bug
"
    done
    commit_msg+="
"
  fi

  # Add generated footer
  commit_msg+="🤖 Generated with SpecSwarm
Quality Score: $QUALITY_SCORE/100

Co-Authored-By: Claude <noreply@anthropic.com>"

  # Show commit message
  echo ""
  echo "Suggested commit message:"
  echo "┌────────────────────────────────────────────┐"
  echo "$commit_msg" | sed 's/^/│ /'
  echo "└────────────────────────────────────────────┘"
  echo ""

  read -p "Edit commit message? (y/n): " edit_choice

  if [ "$edit_choice" = "y" ]; then
    # Open editor
    echo "$commit_msg" > /tmp/commit-msg.txt
    ${EDITOR:-nano} /tmp/commit-msg.txt
    commit_msg=$(cat /tmp/commit-msg.txt)
    rm /tmp/commit-msg.txt
  fi

  # Commit
  git add -A
  git commit -m "$commit_msg"

  echo "✓ Changes committed to feature branch"

  # Push
  git push
  echo "✓ Pushed to remote"
  echo ""
}
```

### Phase 4: Merge to Main

```bash
merge_to_main() {
  local feature_branch=$1

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Phase 4: Merge to Main"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Ready to merge feature to main branch."
  echo ""
  echo "⚠️  IMPORTANT: This will merge your changes to main."
  echo "    Make sure you've tested the feature thoroughly."
  echo ""
  read -p "Proceed with merge? (y/n): " merge_choice

  if [ "$merge_choice" != "y" ]; then
    echo ""
    echo "❌ Merge cancelled"
    echo "You're still on branch: $feature_branch"
    echo "Run /specswarm:complete again when ready"
    exit 0
  fi

  # Detect main branch name
  main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

  echo ""
  echo "Checking out $main_branch..."
  git checkout "$main_branch"

  echo "Pulling latest changes..."
  git pull
  echo "✓ $main_branch branch up to date"
  echo ""

  echo "Merging feature branch (no-ff)..."
  if git merge --no-ff "$feature_branch" -m "Merge feature: $feature_branch"; then
    echo "✓ Merge successful"
  else
    echo "❌ Merge conflicts detected"
    echo ""
    echo "Please resolve conflicts manually, then run:"
    echo "  git merge --continue"
    echo "  /specswarm:complete --continue"
    exit 1
  fi

  echo ""
  echo "Pushing to remote..."
  git push
  echo "✓ $main_branch branch updated"
  echo ""
}
```

### Phase 5: Branch Cleanup

```bash
cleanup_feature_branch() {
  local feature_branch=$1
  local feature_num=$2
  local feature_dir=$3

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Phase 5: Cleanup"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  read -p "Delete feature branch? (y/n): " delete_choice

  if [ "$delete_choice" = "y" ]; then
    # Delete local branch
    git branch -d "$feature_branch"
    echo "✓ Deleted local branch: $feature_branch"

    # Delete remote branch
    git push origin --delete "$feature_branch" 2>/dev/null
    echo "✓ Deleted remote branch: origin/$feature_branch"
  else
    echo "✓ Keeping feature branch"
  fi

  # Update feature status
  if [ -f "$feature_dir/spec.md" ]; then
    sed -i 's/^Status:.*/Status: Complete/' "$feature_dir/spec.md"
    echo "✓ Updated feature status: Complete"
  fi

  echo ""
}
```

---

## Error Handling

### Validation Failures

```bash
if ! validate_before_merge "$FEATURE_DIR"; then
  echo ""
  echo "❌ Pre-merge validation failed"
  echo ""
  echo "Please fix the issues above and run /specswarm:complete again"
  exit 1
fi
```

### Merge Conflicts

```bash
if ! git merge --no-ff "$FEATURE_BRANCH"; then
  echo "❌ Merge conflicts detected"
  echo ""
  echo "Please resolve conflicts manually:"
  echo "  1. Fix conflicts in your editor"
  echo "  2. git add <resolved-files>"
  echo "  3. git merge --continue"
  echo "  4. /specswarm:complete --continue"
  exit 1
fi
```

### Uncommitted Changes on Main

```bash
if [ -n "$(git status --porcelain)" ]; then
  echo "⚠️  Warning: Uncommitted changes on main branch"
  echo ""
  read -p "Stash changes and continue? (y/n): " stash_choice
  if [ "$stash_choice" = "y" ]; then
    git stash
    echo "✓ Changes stashed"
  else
    echo "❌ Cannot merge with uncommitted changes"
    exit 1
  fi
fi
```

---

## Success Output

```
🎉 Feature Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Feature 915: Password Reset Flow
✓ Implementation: Complete (17 tasks)
✓ Bugs Fixed: 3 (916, 917, 918)
✓ Quality Score: 95/100
✓ Merged to: main
✓ Branch: Deleted

📊 Final Metrics:
  Time to Completion: 3.5 hours
  Files Changed: 24
  Lines Added: 1,847
  Tests Added: 12

📂 Feature Archive:
  features/915-add-password-reset-flow.../

🚀 Next Steps:
  - Deploy to staging
  - Run smoke tests
  - Monitor production
```

---

## Implementation Checklist

- [ ] Create `plugins/specswarm/commands/complete.md`
- [ ] Implement detection logic
- [ ] Implement cleanup phase
- [ ] Implement validation phase
- [ ] Implement commit phase
- [ ] Implement merge phase
- [ ] Implement branch cleanup
- [ ] Add error handling
- [ ] Add `--continue` flag for conflict resolution
- [ ] Test with feature branch
- [ ] Test with bugfix branch
- [ ] Document in README

---

## Related Documents

- `docs/learnings/PHASE-2-LEARNINGS-SUMMARY.md`
- `docs/improvements/GIT-WORKFLOW-AUTOMATION.md`

---

**Status:** Design Complete - Ready for Implementation
**Approval:** Pending
**Implementation:** Phase 2.2
