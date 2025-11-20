---
description: Safely rollback a failed or unwanted feature with automatic artifact cleanup
visibility: internal
args:
  - name: --dry-run
    description: Show what would be rolled back without executing
    required: false
  - name: --keep-artifacts
    description: Backup artifacts instead of deleting them
    required: false
  - name: --force
    description: Skip confirmation prompts (dangerous!)
    required: false
---

## User Input

```text
$ARGUMENTS
```

## Goal

Safely rollback a feature that failed or is no longer wanted, including:
1. Reverting all code changes since branch creation
2. Cleaning up feature artifacts (spec.md, plan.md, tasks.md)
3. Optionally deleting the feature branch
4. Switching back to the parent branch

Provides two rollback strategies with comprehensive safety checks.

---

## Execution Steps

### Step 1: Safety Checks

```bash
echo "🔍 Performing safety checks..."
echo ""

# Check 1: Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

if [ -z "$CURRENT_BRANCH" ]; then
  echo "❌ Error: Not in a git repository"
  exit 1
fi

# Check 2: Prevent rollback of main/master/develop
PROTECTED_BRANCHES=("main" "master" "develop" "production")

for protected in "${PROTECTED_BRANCHES[@]}"; do
  if [ "$CURRENT_BRANCH" = "$protected" ]; then
    echo "❌ Error: Cannot rollback protected branch '$CURRENT_BRANCH'"
    echo ""
    echo "💡 Rollback is designed for feature branches only."
    echo "   If you need to revert changes on $CURRENT_BRANCH, use:"
    echo "   git revert <commit-hash>"
    exit 1
  fi
done

# Check 3: Check for uncommitted changes
DIRTY=$(git status --porcelain 2>/dev/null)

if [ -n "$DIRTY" ]; then
  echo "❌ Error: Uncommitted changes detected"
  echo ""
  echo "You have uncommitted changes. Please commit or stash them first:"
  git status --short
  echo ""
  echo "To commit:"
  echo "  git add ."
  echo "  git commit -m \"WIP: save before rollback\""
  echo ""
  echo "To stash:"
  echo "  git stash push -m \"Before rollback\""
  exit 1
fi

# Check 4: Detect parent branch
# First try git config
PARENT_BRANCH=$(git config "branch.$CURRENT_BRANCH.parent" 2>/dev/null)

# Fallback to common parent branches
if [ -z "$PARENT_BRANCH" ]; then
  for candidate in "develop" "development" "dev" "main" "master"; do
    if git show-ref --verify --quiet "refs/heads/$candidate"; then
      PARENT_BRANCH="$candidate"
      break
    fi
  done
fi

# Last resort: ask user
if [ -z "$PARENT_BRANCH" ]; then
  echo "⚠️  Could not auto-detect parent branch"
  PARENT_BRANCH="main"  # default
fi

echo "✅ Safety checks passed"
echo ""
```

---

### Step 2: Gather Rollback Information

```bash
echo "📊 Analyzing feature branch: $CURRENT_BRANCH"
echo ""

# Find divergence point from parent
DIVERGE_POINT=$(git merge-base "$CURRENT_BRANCH" "$PARENT_BRANCH" 2>/dev/null)

if [ -z "$DIVERGE_POINT" ]; then
  echo "❌ Error: Could not find divergence point with $PARENT_BRANCH"
  echo "   Please specify the correct parent branch."
  exit 1
fi

# Count commits to rollback
COMMIT_COUNT=$(git rev-list --count "$DIVERGE_POINT..$CURRENT_BRANCH" 2>/dev/null)
COMMITS=$(git log --oneline "$DIVERGE_POINT..$CURRENT_BRANCH" 2>/dev/null)

# Check if already merged to parent
MERGED=$(git branch --merged "$PARENT_BRANCH" | grep -w "$CURRENT_BRANCH" || true)

# Check for feature artifacts
FEATURE_DIR=".feature"
ARTIFACTS_FOUND=false
ARTIFACT_LIST=()

if [ -d "$FEATURE_DIR" ]; then
  if [ -f "$FEATURE_DIR/spec.md" ]; then
    ARTIFACTS_FOUND=true
    ARTIFACT_LIST+=("spec.md ($(wc -l < "$FEATURE_DIR/spec.md" 2>/dev/null || echo "0") lines)")
  fi
  if [ -f "$FEATURE_DIR/plan.md" ]; then
    ARTIFACTS_FOUND=true
    ARTIFACT_LIST+=("plan.md ($(wc -l < "$FEATURE_DIR/plan.md" 2>/dev/null || echo "0") lines)")
  fi
  if [ -f "$FEATURE_DIR/tasks.md" ]; then
    ARTIFACTS_FOUND=true
    TASK_COUNT=$(grep -c "^-" "$FEATURE_DIR/tasks.md" 2>/dev/null || echo "0")
    TASK_COMPLETE=$(grep -c "^- \[x\]" "$FEATURE_DIR/tasks.md" 2>/dev/null || echo "0")
    ARTIFACT_LIST+=("tasks.md ($TASK_COUNT tasks, $TASK_COMPLETE completed)")
  fi
fi

# Check remote tracking
REMOTE_TRACKING=$(git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null || echo "")

# Display information
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ROLLBACK ANALYSIS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Branch Information:"
echo "  Current Branch:  $CURRENT_BRANCH"
echo "  Parent Branch:   $PARENT_BRANCH"
echo "  Commits:         $COMMIT_COUNT"
echo "  Merged Status:   $([[ -n "$MERGED" ]] && echo "Already merged to $PARENT_BRANCH" || echo "Not merged")"
echo "  Remote Tracking: ${REMOTE_TRACKING:-"None (local only)"}"
echo ""

if [ "$COMMIT_COUNT" -gt 0 ]; then
  echo "Commits to Rollback:"
  echo "$COMMITS" | head -5
  if [ "$COMMIT_COUNT" -gt 5 ]; then
    echo "  ... and $((COMMIT_COUNT - 5)) more"
  fi
  echo ""
fi

if [ "$ARTIFACTS_FOUND" = true ]; then
  echo "Feature Artifacts Found:"
  for artifact in "${ARTIFACT_LIST[@]}"; do
    echo "  ✓ $artifact"
  done
  echo ""
fi

if [ -n "$MERGED" ]; then
  echo "⚠️  WARNING: This branch has already been merged to $PARENT_BRANCH"
  echo "   Rollback will create revert commits on $PARENT_BRANCH"
  echo ""
fi

if [ -n "$REMOTE_TRACKING" ]; then
  echo "⚠️  WARNING: This branch is pushed to remote ($REMOTE_TRACKING)"
  echo "   Other collaborators may have checked out this branch"
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
```

---

### Step 3: Dry Run Mode

**If `--dry-run` flag is present, show what would happen and exit:**

```bash
if echo "$ARGUMENTS" | grep -q "\-\-dry-run"; then
  echo "🔍 DRY RUN MODE - No changes will be made"
  echo ""
  echo "The following actions WOULD be performed:"
  echo ""
  echo "1. Rollback Strategy: (User would choose)"
  echo "   Option A: Soft rollback (create $COMMIT_COUNT revert commits)"
  echo "   Option B: Hard rollback (reset to $PARENT_BRANCH)"
  echo ""
  echo "2. Artifact Cleanup:"
  if [ "$ARTIFACTS_FOUND" = true ]; then
    echo "   - Delete or backup: ${ARTIFACT_LIST[*]}"
  else
    echo "   - No artifacts to clean up"
  fi
  echo ""
  echo "3. Branch Cleanup:"
  echo "   - Optionally delete branch: $CURRENT_BRANCH"
  echo ""
  echo "4. Final State:"
  echo "   - Switch to: $PARENT_BRANCH"
  echo ""
  echo "Run without --dry-run to execute rollback."
  exit 0
fi
```

---

### Step 4: Interactive Rollback Configuration (if not --force)

**Skip if `--force` flag is present (use soft rollback defaults).**

Use **AskUserQuestion** tool:

```
Question 1: "Choose rollback strategy"
Header: "Strategy"
Options:
  1. "Soft rollback (revert commits)"
     Description: "Creates revert commits, preserves history (RECOMMENDED)"
  2. "Hard rollback (reset to parent)"
     Description: "Deletes all commits, rewrites history (DANGEROUS)"
  3. "Cancel rollback"
     Description: "Abort and keep current state"
```

Store in `$ROLLBACK_STRATEGY`.

If `$ROLLBACK_STRATEGY` == "Cancel rollback", exit with message.

```
Question 2: "Delete feature branch after rollback?"
Header: "Branch Cleanup"
Options:
  1. "Yes, delete branch"
     Description: "Remove $CURRENT_BRANCH completely"
  2. "No, keep branch"
     Description: "Keep branch for reference (can delete later)"
```

Store in `$DELETE_BRANCH`.

```
Question 3 (if ARTIFACTS_FOUND=true): "What should we do with feature artifacts?"
Header: "Artifacts"
Options:
  1. "Delete artifacts"
     Description: "Remove spec.md, plan.md, tasks.md permanently"
  2. "Backup artifacts"
     Description: "Move to .feature.backup/$(date +%Y%m%d-%H%M%S)/"
  3. "Keep artifacts"
     Description: "Leave artifacts in place (not recommended)"
```

Store in `$ARTIFACT_ACTION`.

```
Question 4: "Final confirmation - Type 'rollback' to proceed"
Header: "Confirm"
Options:
  - Text input required
  - Must type exactly "rollback" (case-sensitive)
```

Store in `$CONFIRMATION`.

```bash
if [ "$CONFIRMATION" != "rollback" ]; then
  echo "❌ Rollback cancelled - confirmation text did not match"
  echo "   You must type exactly: rollback"
  exit 1
fi
```

---

### Step 5: Execute Rollback

```bash
echo ""
echo "🔄 Executing rollback..."
echo ""

# Step 5a: Handle artifacts first (before git operations)
if [ "$ARTIFACTS_FOUND" = true ]; then
  case "$ARTIFACT_ACTION" in
    "Delete artifacts")
      echo "🗑️  Deleting feature artifacts..."
      rm -rf "$FEATURE_DIR"
      echo "✅ Deleted artifacts"
      ;;
    "Backup artifacts")
      BACKUP_DIR=".feature.backup/$(date +%Y%m%d-%H%M%S)"
      echo "💾 Backing up artifacts to $BACKUP_DIR..."
      mkdir -p "$BACKUP_DIR"
      cp -r "$FEATURE_DIR"/* "$BACKUP_DIR/" 2>/dev/null
      rm -rf "$FEATURE_DIR"
      echo "✅ Artifacts backed up to $BACKUP_DIR"
      ;;
    "Keep artifacts")
      echo "ℹ️  Keeping artifacts in place"
      ;;
  esac
  echo ""
fi

# Step 5b: Execute rollback strategy
case "$ROLLBACK_STRATEGY" in
  "Soft rollback (revert commits)")
    echo "🔄 Creating revert commits..."

    if [ "$COMMIT_COUNT" -gt 0 ]; then
      # Create revert commits in reverse order
      git revert --no-edit "$DIVERGE_POINT..$CURRENT_BRANCH" 2>&1 || {
        echo ""
        echo "⚠️  Revert encountered conflicts"
        echo "   Conflicts must be resolved manually:"
        echo "   1. Fix conflicts in the listed files"
        echo "   2. git add <resolved-files>"
        echo "   3. git revert --continue"
        echo ""
        echo "   Or to abort:"
        echo "   git revert --abort"
        exit 1
      }

      echo "✅ Created $COMMIT_COUNT revert commits"
    else
      echo "ℹ️  No commits to revert"
    fi

    # Stay on current branch for soft rollback
    SWITCH_BRANCH=false
    ;;

  "Hard rollback (reset to parent)")
    echo "⚠️  WARNING: Performing hard rollback (history will be lost)"
    echo ""

    # Switch to parent branch
    echo "🔀 Switching to $PARENT_BRANCH..."
    git checkout "$PARENT_BRANCH" 2>&1 || {
      echo "❌ Failed to switch to $PARENT_BRANCH"
      exit 1
    }

    echo "✅ Switched to $PARENT_BRANCH"

    SWITCH_BRANCH=true
    ;;
esac

echo ""

# Step 5c: Branch cleanup
if [ "$DELETE_BRANCH" = "Yes, delete branch" ] && [ "$SWITCH_BRANCH" = false ]; then
  # For soft rollback, need to switch before deleting
  echo "🔀 Switching to $PARENT_BRANCH before branch deletion..."
  git checkout "$PARENT_BRANCH" 2>&1 || {
    echo "❌ Failed to switch to $PARENT_BRANCH"
    exit 1
  }
  SWITCH_BRANCH=true
fi

if [ "$DELETE_BRANCH" = "Yes, delete branch" ]; then
  echo "🗑️  Deleting branch $CURRENT_BRANCH..."

  # Check if branch has unmerged changes
  UNMERGED=$(git branch --no-merged "$PARENT_BRANCH" | grep -w "$CURRENT_BRANCH" || true)

  if [ -n "$UNMERGED" ] && [ "$ROLLBACK_STRATEGY" != "Hard rollback (reset to parent)" ]; then
    # Force delete for unmerged branches
    git branch -D "$CURRENT_BRANCH" 2>&1 || {
      echo "❌ Failed to delete branch $CURRENT_BRANCH"
      exit 1
    }
  else
    git branch -d "$CURRENT_BRANCH" 2>&1 || {
      # Try force delete if normal delete fails
      git branch -D "$CURRENT_BRANCH" 2>&1 || {
        echo "❌ Failed to delete branch $CURRENT_BRANCH"
        exit 1
      }
    }
  fi

  echo "✅ Deleted branch $CURRENT_BRANCH"

  # Delete remote branch if exists
  if [ -n "$REMOTE_TRACKING" ]; then
    REMOTE_NAME=$(echo "$REMOTE_TRACKING" | cut -d'/' -f1)
    echo ""
    echo "⚠️  Remote branch exists: $REMOTE_TRACKING"
    echo "   To delete remote branch, run:"
    echo "   git push $REMOTE_NAME --delete $CURRENT_BRANCH"
  fi
fi

echo ""
```

---

### Step 6: Summary and Final State

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "       ✅ ROLLBACK COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Summary:"
echo "  Strategy:     $ROLLBACK_STRATEGY"
if [ "$COMMIT_COUNT" -gt 0 ]; then
  if [ "$ROLLBACK_STRATEGY" = "Soft rollback (revert commits)" ]; then
    echo "  Commits:      $COMMIT_COUNT reverted"
  else
    echo "  Commits:      $COMMIT_COUNT removed"
  fi
fi
if [ "$ARTIFACTS_FOUND" = true ]; then
  echo "  Artifacts:    $ARTIFACT_ACTION"
fi
if [ "$DELETE_BRANCH" = "Yes, delete branch" ]; then
  echo "  Branch:       $CURRENT_BRANCH deleted"
else
  echo "  Branch:       $CURRENT_BRANCH kept"
fi
echo "  Current:      $(git rev-parse --abbrev-ref HEAD)"
echo ""

if [ "$ROLLBACK_STRATEGY" = "Soft rollback (revert commits)" ] && [ "$SWITCH_BRANCH" = false ]; then
  echo "💡 Next Steps:"
  echo "   1. Review the revert commits: git log"
  echo "   2. Push to remote if needed: git push"
  echo "   3. Merge to parent: /specswarm:complete"
  echo ""
elif [ "$SWITCH_BRANCH" = true ]; then
  echo "💡 Next Steps:"
  echo "   1. Review current state: git status"
  echo "   2. Start a new feature: /specswarm:build \"feature\""
  echo ""
fi

if [ -d ".feature.backup" ]; then
  echo "📦 Backups:"
  echo "   Feature artifacts backed up to:"
  ls -1d .feature.backup/*/ 2>/dev/null | tail -1
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

---

## Important Notes

### Safety Features

1. **Protected Branch Prevention**: Cannot rollback main/master/develop/production
2. **Uncommitted Changes Check**: Requires clean working tree
3. **Confirmation Required**: Must type "rollback" to proceed (unless --force)
4. **Artifact Backup**: Option to backup before deletion
5. **Dry Run**: Preview changes before executing

### Rollback Strategies

**Soft Rollback (Recommended)**:
- Creates revert commits for each commit since divergence
- Preserves complete history
- Safe for shared/pushed branches
- Can be undone by reverting the reverts

**Hard Rollback (Dangerous)**:
- Resets to parent branch state
- Deletes all commits permanently
- Only safe for local-only branches
- Cannot be undone easily

### When to Use Each Strategy

**Use Soft Rollback when**:
- Branch has been pushed to remote
- Other developers may have based work on this branch
- You want to preserve history
- You're unsure if you might need the code later

**Use Hard Rollback when**:
- Branch is local-only (never pushed)
- You're absolutely certain code should be deleted
- You want a clean slate

### Remote Branch Handling

If branch is tracked remotely:
- Local branch can be deleted safely
- Remote branch deletion must be done manually:
  ```bash
  git push origin --delete feature-branch-name
  ```
- Provides command at end of rollback

### Merged Branch Rollback

If branch is already merged to parent:
- Soft rollback creates revert commits on current branch
- These reverts must then be merged to parent
- Hard rollback switches to parent (no changes to parent)
- Consider using `/specswarm:deprecate` for features in production

---

## Example Usage

### Basic Rollback (Interactive)
```bash
/specswarm:rollback
# Guided through strategy selection
# Confirms with "rollback" text
```

### Preview Rollback (Dry Run)
```bash
/specswarm:rollback --dry-run
# Shows what would happen without executing
```

### Quick Rollback with Defaults
```bash
/specswarm:rollback --force
# Uses soft rollback, no confirmation
# NOT RECOMMENDED unless you know what you're doing
```

### Rollback with Artifact Backup
```bash
/specswarm:rollback --keep-artifacts
# Backs up artifacts automatically
```

### Undo a Rollback (if soft rollback was used)
```bash
# Find the revert commits
git log --oneline | grep "Revert"

# Revert the reverts to restore original state
git revert <revert-commit-hash>
```
