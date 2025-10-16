# Git Workflow Automation for Orchestrator

**Status:** 📋 Planned for Phase 2.1
**Priority:** High (improves developer experience)
**Related:** Phase 2 Feature Workflow Engine

---

## Current Problem

When the orchestrator completes a feature, it leaves all changes uncommitted:
- Work is not saved to git
- No automatic tracking
- User must manually commit and merge
- Defeats the "full automation" goal

### Current Behavior

```bash
# After orchestrator completes:
$ git status
On branch 914-add-profile-image-upload-...
Changes not staged for commit:
  modified: app/pages/ProfileEdit.tsx
  ...
Untracked files:
  app/components/ImageUploadField.tsx
  ...
```

User must:
1. Manually `git add -A`
2. Manually `git commit -m "..."`
3. Manually `git push`
4. Manually test the feature
5. Manually merge to main

**This is tedious and error-prone.**

---

## Proposed Workflow

**User's Request:**
> "I would like future features to be committed to the feature branch,
> then to be offered to manually test the feature, then offered to
> approve for the system to merge it for me."

### New Automated Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Orchestrator Completes Feature                          │
│    - Code generated                                         │
│    - Validation passed                                      │
│    - Quality score: 78/100                                  │
└─────────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. AUTO-COMMIT to Feature Branch                           │
│    ✅ git add -A                                            │
│    ✅ git commit -m "feat: [feature description]"           │
│    ✅ git push -u origin [branch-name]                      │
│                                                             │
│    Commit message includes:                                 │
│    - Feature description                                    │
│    - Files changed                                          │
│    - Quality score                                          │
│    - Validation results                                     │
│    - Warning about manual testing                           │
└─────────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. PAUSE: Offer Manual Testing                             │
│    ⚠️  Feature committed to branch [branch-name]            │
│                                                             │
│    📋 Please test the feature manually:                     │
│    - [ ] Feature works as expected                          │
│    - [ ] External integrations tested (if any)              │
│    - [ ] No runtime errors                                  │
│                                                             │
│    ❓ Ready to merge to main? (y/n)                         │
└─────────────────────────────────────────────────────────────┘
                         ↓
                    User tests...
                         ↓
┌─────────────────────────────────────────────────────────────┐
│ 4a. User Approves (y)                                       │
│    ✅ AUTO-MERGE to Main                                    │
│    ✅ git checkout main                                     │
│    ✅ git merge [branch-name] --no-ff                       │
│    ✅ git push                                              │
│    ✅ git branch -d [branch-name]                           │
│                                                             │
│    🎉 Feature merged to main!                               │
└─────────────────────────────────────────────────────────────┘

OR

┌─────────────────────────────────────────────────────────────┐
│ 4b. User Declines (n)                                       │
│    ⚠️  Merge cancelled                                      │
│                                                             │
│    Options:                                                 │
│    1. Fix issues manually and merge later                   │
│    2. Run bugfix workflow                                   │
│    3. Abandon feature branch                                │
│                                                             │
│    Branch remains: [branch-name]                            │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation Plan

### Step 1: Auto-Commit After Validation

**Location:** `plugins/speclabs/commands/orchestrate-feature.md` (after validation)

**Code:**
```bash
# After validation passes and feature is complete
if [ "$FEATURE_SUCCESS" = "true" ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "💾 Committing changes to feature branch..."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Get current branch name
  CURRENT_BRANCH=$(git branch --show-current)

  # Stage all changes
  git add -A

  # Create commit message
  COMMIT_MSG="feat: ${FEATURE_DESC}

Generated by SpecLabs Phase 2 Feature Workflow Engine
Quality Score: ${QUALITY_SCORE}/100

Files Changed:
$(git status --short | head -20)

⚠️ IMPORTANT: Manual testing required before merging.
Phase 2 validation is structural only - runtime behavior not tested.

Testing Checklist:
- [ ] Feature works as expected
- [ ] External integrations tested (Cloudinary, Stripe, etc.)
- [ ] No runtime errors in server console
- [ ] UI/UX is acceptable

See orchestrator report: ${REPORT_FILE}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

  # Commit
  git commit -m "$COMMIT_MSG"

  # Push to remote
  git push -u origin "$CURRENT_BRANCH"

  echo "✅ Changes committed to branch: $CURRENT_BRANCH"
  echo "✅ Branch pushed to remote"
fi
```

### Step 2: Offer Manual Testing

**Code:**
```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Manual Testing Phase"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Feature committed to branch: $CURRENT_BRANCH"
echo ""
echo "📋 Testing Checklist:"
echo "  - [ ] Feature works as expected"
echo "  - [ ] External integrations tested (if any)"
echo "  - [ ] No runtime errors in console"
echo "  - [ ] UI/UX is acceptable"
echo ""
echo "⚠️  Reminder: Phase 2 validation only checks code structure."
echo "   Always test runtime behavior manually before merging."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### Step 3: Offer Auto-Merge

**Code:**
```bash
# Ask user if ready to merge
read -p "❓ Feature tested and ready to merge to main? (y/n): " MERGE_APPROVAL

if [ "$MERGE_APPROVAL" = "y" ] || [ "$MERGE_APPROVAL" = "Y" ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔀 Merging feature to main..."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Get main branch name (could be 'main' or 'master')
  MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

  # Checkout main
  git checkout "$MAIN_BRANCH"

  # Merge feature branch (no fast-forward to preserve history)
  git merge "$CURRENT_BRANCH" --no-ff -m "Merge feature: $FEATURE_DESC

Feature tested and approved for merge.
See branch $CURRENT_BRANCH for implementation details."

  # Push to remote
  git push

  # Delete local feature branch
  git branch -d "$CURRENT_BRANCH"

  echo "✅ Feature merged to $MAIN_BRANCH"
  echo "✅ Local feature branch deleted"
  echo ""
  echo "🎉 Feature complete and merged!"

else
  echo ""
  echo "⚠️  Merge cancelled"
  echo ""
  echo "Your feature branch remains: $CURRENT_BRANCH"
  echo ""
  echo "Options:"
  echo "  1. Fix issues manually and merge later"
  echo "  2. Run bugfix workflow: /specswarm:bugfix"
  echo "  3. Abandon feature: git branch -D $CURRENT_BRANCH"
fi
```

---

## Benefits

### 1. Work is Never Lost
- ✅ All changes committed immediately after validation
- ✅ Feature branch pushed to remote
- ✅ Can recover if local environment fails

### 2. Clear Review Points
- ✅ Commit message includes validation results
- ✅ User has explicit checkpoint to test
- ✅ Merge requires conscious approval

### 3. Safety with Convenience
- ✅ Auto-commit is safe (on feature branch)
- ✅ Manual testing before merge (safety checkpoint)
- ✅ User controls when code reaches main

### 4. Better Developer Experience
- ✅ No manual git commands needed
- ✅ Clear prompts guide the workflow
- ✅ Can still fix issues before merging

### 5. Audit Trail
- ✅ Feature branch preserved in git history
- ✅ Merge commits show when features were approved
- ✅ Can trace back to orchestrator session

---

## Edge Cases

### Case 1: User wants to fix issues before commit

**Solution:** Add `--no-commit` flag
```bash
/speclabs:orchestrate-feature "..." /project --no-commit
# Skips auto-commit, leaves changes uncommitted
```

### Case 2: User wants to create PR instead of direct merge

**Solution:** Add `--pr` flag
```bash
/speclabs:orchestrate-feature "..." /project --pr
# After commit, creates PR with gh CLI instead of merging
```

**Implementation:**
```bash
if [ "$CREATE_PR" = "true" ]; then
  gh pr create \
    --title "feat: $FEATURE_DESC" \
    --body "$(cat <<EOF
## Orchestrator Summary
- Quality Score: $QUALITY_SCORE/100
- Validation: PASSED
- Files Generated: $FILE_COUNT

## Testing Required
⚠️ This feature was generated by Phase 2 orchestrator.
Please test manually before merging:
- [ ] Feature works as expected
- [ ] External integrations tested
- [ ] No runtime errors

See orchestrator report: $REPORT_FILE
EOF
)"

  echo "✅ Pull request created"
  echo "   Review and merge at: [PR URL]"
fi
```

### Case 3: Merge conflict during auto-merge

**Solution:** Graceful handling
```bash
if ! git merge "$CURRENT_BRANCH" --no-ff -m "..."; then
  echo "❌ Merge conflict detected!"
  echo ""
  echo "Main branch has conflicting changes."
  echo ""
  echo "Options:"
  echo "  1. Resolve conflicts manually:"
  echo "     git checkout $MAIN_BRANCH"
  echo "     git merge $CURRENT_BRANCH"
  echo "     [resolve conflicts]"
  echo "     git commit"
  echo ""
  echo "  2. Create PR for review:"
  echo "     gh pr create ..."

  # Return to feature branch
  git checkout "$CURRENT_BRANCH"
  exit 1
fi
```

---

## Success Metrics

**Before (Manual):**
- 5-10 minutes of manual git commands
- Risk of uncommitted work
- Easy to forget to push
- No structured testing checkpoint

**After (Automated):**
- 0 minutes of manual git commands
- Work always saved
- Always pushed to remote
- Clear testing checkpoint with approval gate

**User Satisfaction:**
- Less tedious manual work
- Clear workflow guidance
- Safety with convenience
- Professional git history

---

## Migration Path

### Phase 2.1 (Immediate)
1. Add auto-commit after validation passes
2. Add manual testing checkpoint
3. Add auto-merge with approval

### Phase 2.2 (Enhancement)
1. Add `--no-commit` flag for manual control
2. Add `--pr` flag for PR creation
3. Add conflict detection and handling
4. Add branch naming customization

### Phase 3.0 (Future)
1. Integrate with functional testing
2. Auto-merge only if functional tests pass
3. Skip manual testing checkpoint if tests pass
4. Full CI/CD integration

---

## Testing Plan

### Test 1: Happy Path
```bash
/speclabs:orchestrate-feature "Add contact form" /project
# Verify: Auto-commit works
# Verify: Testing prompt appears
# Approve merge (y)
# Verify: Feature merged to main
# Verify: Branch cleaned up
```

### Test 2: Decline Merge
```bash
/speclabs:orchestrate-feature "Add feature X" /project
# Verify: Auto-commit works
# Decline merge (n)
# Verify: Feature branch remains
# Verify: Can fix and merge manually
```

### Test 3: PR Creation
```bash
/speclabs:orchestrate-feature "Add feature Y" /project --pr
# Verify: Auto-commit works
# Verify: PR created on GitHub
# Verify: PR description includes orchestrator report
```

---

## Related Documentation

- `docs/PHASE-2-COMPLETE.md` - Phase 2 implementation
- `docs/PHASE-3-REQUIREMENTS.md` - Future testing integration
- `docs/learnings/PHASE-2-FAILURE-ANALYSIS-001.md` - Why manual testing is critical

---

## Example: Complete Flow

```bash
$ /speclabs:orchestrate-feature "Add profile image upload" /home/marty/tweeter

[... orchestrator runs ...]
[... generates code ...]
[... validates ...]

✅ Feature Orchestration Complete!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💾 Committing changes to feature branch...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[main 797e2be] feat: Add profile image upload
 38 files changed, 5941 insertions(+), 213 deletions(-)
 ...

✅ Changes committed to branch: 914-add-profile-image-upload-...
✅ Branch pushed to remote

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧪 Manual Testing Phase
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Feature committed to branch: 914-add-profile-image-upload-...

📋 Testing Checklist:
  - [ ] Feature works as expected
  - [ ] External integrations tested (if any)
  - [ ] No runtime errors in console
  - [ ] UI/UX is acceptable

⚠️  Reminder: Phase 2 validation only checks code structure.
   Always test runtime behavior manually before merging.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[User tests the feature... finds Cloudinary bug... fixes it]

❓ Feature tested and ready to merge to main? (y/n): y

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔀 Merging feature to main...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Switched to branch 'main'
Merge made by the 'ort' strategy.
 38 files changed, 5941 insertions(+), 213 deletions(-)
 ...

✅ Feature merged to main
✅ Local feature branch deleted

🎉 Feature complete and merged!
```

---

## Conclusion

This git workflow automation:
- ✅ Preserves user control (manual testing + approval)
- ✅ Eliminates tedious manual git commands
- ✅ Ensures work is never lost
- ✅ Provides clear review checkpoint
- ✅ Maintains professional git history

**Next Step:** Implement in Phase 2.1 update to orchestrate-feature command.

---

**Document Version:** 1.0
**Status:** Approved for Phase 2.1 Implementation
**Author:** Based on user feedback and Phase 2 testing experience
