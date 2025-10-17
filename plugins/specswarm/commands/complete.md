---
description: Complete feature or bugfix workflow and merge to main
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Complete feature or bugfix workflow by cleaning up, validating, committing, and merging to main branch.

**Purpose**: Provide a clean, guided completion process for features and bugfixes developed with SpecSwarm workflows.

**Scope**: Handles cleanup → validation → commit → merge → branch deletion

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
```

---

## Execution Steps

### Step 1: Detect Workflow Context

```bash
echo "🎯 Feature Completion Workflow"
echo "══════════════════════════════════════════"
echo ""

# Detect current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Extract feature/bug number from branch name
# Patterns: NNN-*, feature/NNN-*, bugfix/NNN-*, fix/NNN-*
FEATURE_NUM=$(echo "$CURRENT_BRANCH" | grep -oE '^[0-9]{3}' || \
              echo "$CURRENT_BRANCH" | grep -oE '(feature|bugfix|fix)/([0-9]{3})' | grep -oE '[0-9]{3}' || \
              echo "")

# If no number found, check user arguments
if [ -z "$FEATURE_NUM" ] && [ -n "$ARGUMENTS" ]; then
  # Try to extract number from arguments
  FEATURE_NUM=$(echo "$ARGUMENTS" | grep -oE '\b[0-9]{3}\b' | head -1)
fi

# If still no number, ask user
if [ -z "$FEATURE_NUM" ]; then
  echo "⚠️  Could not detect feature/bug number from branch: $CURRENT_BRANCH"
  echo ""
  read -p "Enter feature or bug number (e.g., 915): " FEATURE_NUM

  if [ -z "$FEATURE_NUM" ]; then
    echo "❌ Error: Feature number required"
    exit 1
  fi

  # Pad to 3 digits
  FEATURE_NUM=$(printf "%03d" $FEATURE_NUM)
fi

# Determine workflow type from branch or directory
if echo "$CURRENT_BRANCH" | grep -qE '^(bugfix|bug|fix)/'; then
  WORKFLOW_TYPE="bugfix"
elif echo "$CURRENT_BRANCH" | grep -qE '^(feature|feat)/'; then
  WORKFLOW_TYPE="feature"
else
  # Check if features directory exists
  if [ -d "features/${FEATURE_NUM}-"* ] 2>/dev/null; then
    WORKFLOW_TYPE="feature"
  else
    # Ask user
    read -p "Is this a feature or bugfix? (feature/bugfix): " WORKFLOW_TYPE
  fi
fi

# Find feature directory
FEATURE_DIR=$(find "$REPO_ROOT/features" -maxdepth 1 -type d -name "${FEATURE_NUM}-*" 2>/dev/null | head -1)

if [ -z "$FEATURE_DIR" ]; then
  echo "⚠️  Warning: Feature directory not found for ${WORKFLOW_TYPE} ${FEATURE_NUM}"
  echo ""
  echo "Continuing without feature artifacts..."
  FEATURE_DIR=""
else
  # Get feature title from spec
  if [ -f "$FEATURE_DIR/spec.md" ]; then
    FEATURE_TITLE=$(grep -m1 '^# Feature' "$FEATURE_DIR/spec.md" | sed 's/^# Feature [0-9]*: //' || echo "Feature $FEATURE_NUM")
  else
    FEATURE_TITLE="Feature $FEATURE_NUM"
  fi
fi

# Display detected context
echo "Detected: $(echo "$WORKFLOW_TYPE" | sed 's/\b\(.\)/\u\1/') $FEATURE_NUM"
if [ -n "$FEATURE_TITLE" ]; then
  echo "Title: $FEATURE_TITLE"
fi
echo "Branch: $CURRENT_BRANCH"
if [ -n "$FEATURE_DIR" ]; then
  echo "Directory: $FEATURE_DIR"
fi
echo ""
```

---

### Step 2: Cleanup Diagnostic Files

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 1: Cleanup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Patterns for diagnostic files
DIAGNOSTIC_PATTERNS=(
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
DIAGNOSTIC_FILES=()
for pattern in "${DIAGNOSTIC_PATTERNS[@]}"; do
  while IFS= read -r file; do
    if [ -f "$file" ]; then
      DIAGNOSTIC_FILES+=("$file")
    fi
  done < <(find "$REPO_ROOT" -maxdepth 1 -name "$pattern" 2>/dev/null)
done

if [ ${#DIAGNOSTIC_FILES[@]} -eq 0 ]; then
  echo "✓ No diagnostic files to clean up"
else
  echo "📂 Diagnostic Files Found:"
  for file in "${DIAGNOSTIC_FILES[@]}"; do
    basename_file=$(basename "$file")
    size=$(du -h "$file" 2>/dev/null | cut -f1 || echo "?")
    echo "  - $basename_file ($size)"
  done
  echo ""

  echo "What should I do with these files?"
  echo "  1. Delete all (recommended)"
  echo "  2. Move to .claude/debug/ (keep for review)"
  echo "  3. Keep as-is (will be committed if staged)"
  echo "  4. Manual selection"
  echo ""
  read -p "Choice (1-4): " cleanup_choice

  case $cleanup_choice in
    1)
      for file in "${DIAGNOSTIC_FILES[@]}"; do
        rm -f "$file"
      done
      echo "✓ Deleted ${#DIAGNOSTIC_FILES[@]} diagnostic files"
      ;;
    2)
      mkdir -p "$REPO_ROOT/.claude/debug"
      for file in "${DIAGNOSTIC_FILES[@]}"; do
        mv "$file" "$REPO_ROOT/.claude/debug/"
      done
      echo "✓ Moved ${#DIAGNOSTIC_FILES[@]} files to .claude/debug/"
      ;;
    3)
      echo "✓ Keeping diagnostic files"
      ;;
    4)
      for file in "${DIAGNOSTIC_FILES[@]}"; do
        read -p "Delete $(basename "$file")? (y/n): " delete_choice
        if [ "$delete_choice" = "y" ]; then
          rm -f "$file"
          echo "  ✓ Deleted"
        else
          echo "  ✓ Kept"
        fi
      done
      ;;
    *)
      echo "✓ Skipping cleanup"
      ;;
  esac
fi

echo ""
```

---

### Step 3: Pre-Merge Validation

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 2: Pre-Merge Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Running validation checks..."
echo ""

VALIDATION_PASSED=true

# Check if package.json exists (indicates Node.js project)
if [ -f "package.json" ]; then
  # Run tests if test script exists
  if grep -q '"test"' package.json; then
    echo "  Running tests..."
    if npm test --silent 2>&1 | grep -qE "(passing|All tests passed)"; then
      TEST_OUTPUT=$(npm test --silent 2>&1 | grep -oE '[0-9]+ passing' | head -1)
      echo "  ✓ Tests passing ($TEST_OUTPUT)"
    else
      echo "  ⚠️  Some tests may have failed (check manually)"
    fi
  fi

  # TypeScript check if tsconfig.json exists
  if [ -f "tsconfig.json" ]; then
    echo "  Checking TypeScript..."
    if npx tsc --noEmit 2>&1 | grep -qE "error TS[0-9]+"; then
      echo "  ❌ TypeScript errors found"
      VALIDATION_PASSED=false
    else
      echo "  ✓ No TypeScript errors"
    fi
  fi

  # Build check if build script exists
  if grep -q '"build"' package.json; then
    echo "  Checking build..."
    if npm run build --silent 2>&1 | grep -qEi "(error|failed)"; then
      echo "  ⚠️  Build may have issues (check manually)"
    else
      echo "  ✓ Build successful"
    fi
  fi
fi

# Feature completion check
if [ -n "$FEATURE_DIR" ] && [ -f "$FEATURE_DIR/tasks.md" ]; then
  TOTAL_TASKS=$(grep -cE '^### T[0-9]{3}:' "$FEATURE_DIR/tasks.md" 2>/dev/null || echo "0")
  COMPLETED_TASKS=$(grep -cE '^### T[0-9]{3}:.*\[x\]' "$FEATURE_DIR/tasks.md" 2>/dev/null || echo "0")
  if [ "$TOTAL_TASKS" -gt "0" ]; then
    echo "  ✓ Feature progress ($COMPLETED_TASKS/$TOTAL_TASKS tasks)"
  fi
fi

# Bug resolution check
if [ -n "$FEATURE_DIR" ] && [ -f "$FEATURE_DIR/bugfix.md" ]; then
  BUG_COUNT=$(grep -cE '^## Bug [0-9]{3}:' "$FEATURE_DIR/bugfix.md" 2>/dev/null || echo "0")
  if [ "$BUG_COUNT" -gt "0" ]; then
    echo "  ✓ Bugs addressed ($BUG_COUNT bugs)"
  fi
fi

echo ""

if [ "$VALIDATION_PASSED" = "false" ]; then
  echo "⚠️  Validation issues detected"
  echo ""
  read -p "Continue anyway? (y/n): " continue_choice
  if [ "$continue_choice" != "y" ]; then
    echo "❌ Completion cancelled"
    echo ""
    echo "Fix the issues above and run /specswarm:complete again"
    exit 1
  fi
  echo ""
fi

echo "Ready to commit and merge!"
echo ""
```

---

### Step 4: Commit Changes

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 3: Commit Changes"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if there are changes to commit
if git diff --quiet && git diff --cached --quiet; then
  echo "✓ No changes to commit (working tree clean)"
  echo ""
  SKIP_COMMIT=true
else
  SKIP_COMMIT=false

  # Show files to be committed
  echo "Files to commit:"
  git status --short | head -20
  echo ""

  # Determine commit type
  if [ "$WORKFLOW_TYPE" = "bugfix" ]; then
    COMMIT_TYPE="fix"
  else
    COMMIT_TYPE="feat"
  fi

  # Generate commit message
  COMMIT_MSG="${COMMIT_TYPE}: ${FEATURE_TITLE}

"

  # Add description from spec if available
  if [ -n "$FEATURE_DIR" ] && [ -f "$FEATURE_DIR/spec.md" ]; then
    DESCRIPTION=$(grep -A 5 '^## Summary' "$FEATURE_DIR/spec.md" 2>/dev/null | tail -n +2 | head -3 | sed '/^$/d' || echo "")
    if [ -n "$DESCRIPTION" ]; then
      COMMIT_MSG+="${DESCRIPTION}

"
    fi
  fi

  # Add bug fixes if any
  if [ -n "$FEATURE_DIR" ] && [ -f "$FEATURE_DIR/bugfix.md" ]; then
    BUG_NUMBERS=$(grep -oE 'Bug [0-9]{3}' "$FEATURE_DIR/bugfix.md" 2>/dev/null | grep -oE '[0-9]{3}' | sort -u || echo "")
    if [ -n "$BUG_NUMBERS" ]; then
      COMMIT_MSG+="Fixes:
"
      while IFS= read -r bug; do
        COMMIT_MSG+="- Bug $bug
"
      done <<< "$BUG_NUMBERS"
      COMMIT_MSG+="
"
    fi
  fi

  # Add generated footer
  COMMIT_MSG+="🤖 Generated with SpecSwarm

Co-Authored-By: Claude <noreply@anthropic.com>"

  # Show commit message
  echo "Suggested commit message:"
  echo "┌────────────────────────────────────────────┐"
  echo "$COMMIT_MSG" | sed 's/^/│ /'
  echo "└────────────────────────────────────────────┘"
  echo ""

  read -p "Edit commit message? (y/n): " edit_choice

  if [ "$edit_choice" = "y" ]; then
    # Create temp file for editing
    TEMP_MSG_FILE=$(mktemp)
    echo "$COMMIT_MSG" > "$TEMP_MSG_FILE"
    ${EDITOR:-nano} "$TEMP_MSG_FILE"
    COMMIT_MSG=$(cat "$TEMP_MSG_FILE")
    rm -f "$TEMP_MSG_FILE"
  fi

  # Stage all changes
  git add -A

  # Commit
  echo "$COMMIT_MSG" | git commit -F -
  echo "✓ Changes committed to feature branch"
  echo ""

  # Push
  read -p "Push to remote? (y/n): " push_choice
  if [ "$push_choice" = "y" ]; then
    git push
    echo "✓ Pushed to remote"
  else
    echo "⚠️  Changes not pushed (you can push manually later)"
  fi
  echo ""
fi
```

---

### Step 5: Merge to Main

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 4: Merge to Main"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Detect main branch name
MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# Check if already on main
if [ "$CURRENT_BRANCH" = "$MAIN_BRANCH" ]; then
  echo "✓ Already on $MAIN_BRANCH branch"
  echo "✓ No merge needed"
  echo ""
  SKIP_MERGE=true
else
  SKIP_MERGE=false

  echo "Ready to merge to $MAIN_BRANCH branch."
  echo ""
  echo "⚠️  IMPORTANT: This will merge your changes to $MAIN_BRANCH."
  echo "    Make sure you've tested the feature thoroughly."
  echo ""
  read -p "Proceed with merge? (y/n): " merge_choice

  if [ "$merge_choice" != "y" ]; then
    echo ""
    echo "❌ Merge cancelled"
    echo ""
    echo "You're still on branch: $CURRENT_BRANCH"
    echo ""
    echo "When ready to merge, run:"
    echo "  /specswarm:complete"
    echo ""
    echo "Or merge manually:"
    echo "  git checkout $MAIN_BRANCH"
    echo "  git merge --no-ff $CURRENT_BRANCH"
    exit 0
  fi

  echo ""
  echo "Checking out $MAIN_BRANCH..."
  git checkout "$MAIN_BRANCH"

  echo "Pulling latest changes..."
  git pull
  echo "✓ $MAIN_BRANCH branch up to date"
  echo ""

  echo "Merging feature branch (no-ff)..."
  MERGE_MSG="Merge ${WORKFLOW_TYPE}: ${FEATURE_TITLE}

Feature $FEATURE_NUM complete

🤖 Generated with SpecSwarm"

  if git merge --no-ff "$CURRENT_BRANCH" -m "$MERGE_MSG"; then
    echo "✓ Merge successful"
  else
    echo "❌ Merge conflicts detected"
    echo ""
    echo "Please resolve conflicts manually:"
    echo "  1. Fix conflicts in your editor"
    echo "  2. git add <resolved-files>"
    echo "  3. git merge --continue"
    echo "  4. /specswarm:complete --continue"
    echo ""
    exit 1
  fi

  echo ""
  read -p "Push to remote? (y/n): " push_main_choice
  if [ "$push_main_choice" = "y" ]; then
    echo "Pushing to remote..."
    git push
    echo "✓ $MAIN_BRANCH branch updated"
  else
    echo "⚠️  Not pushed (you can push manually later)"
  fi
  echo ""
fi
```

---

### Step 6: Branch Cleanup

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 5: Cleanup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$SKIP_MERGE" = "true" ]; then
  echo "✓ No branch cleanup needed (already on $MAIN_BRANCH)"
else
  read -p "Delete feature branch '$CURRENT_BRANCH'? (y/n): " delete_choice

  if [ "$delete_choice" = "y" ]; then
    # Delete local branch
    if git branch -d "$CURRENT_BRANCH" 2>/dev/null; then
      echo "✓ Deleted local branch: $CURRENT_BRANCH"
    else
      echo "⚠️  Could not delete local branch (may have unmerged commits)"
      read -p "Force delete? (y/n): " force_choice
      if [ "$force_choice" = "y" ]; then
        git branch -D "$CURRENT_BRANCH"
        echo "✓ Force deleted local branch: $CURRENT_BRANCH"
      fi
    fi

    # Delete remote branch
    read -p "Delete remote branch? (y/n): " delete_remote_choice
    if [ "$delete_remote_choice" = "y" ]; then
      if git push origin --delete "$CURRENT_BRANCH" 2>/dev/null; then
        echo "✓ Deleted remote branch: origin/$CURRENT_BRANCH"
      else
        echo "⚠️  Could not delete remote branch (may not exist)"
      fi
    fi
  else
    echo "✓ Keeping feature branch"
  fi
fi

# Update feature status
if [ -n "$FEATURE_DIR" ] && [ -f "$FEATURE_DIR/spec.md" ]; then
  sed -i 's/^Status:.*/Status: Complete/' "$FEATURE_DIR/spec.md" 2>/dev/null || true
  echo "✓ Updated feature status: Complete"
fi

echo ""
```

---

## Final Output

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 $(echo "$WORKFLOW_TYPE" | sed 's/\b\(.\)/\u\1/') Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "$(echo "$WORKFLOW_TYPE" | sed 's/\b\(.\)/\u\1/') $FEATURE_NUM: $FEATURE_TITLE"

if [ "$SKIP_COMMIT" = "false" ]; then
  echo "✓ Changes committed"
fi

if [ "$SKIP_MERGE" = "false" ]; then
  echo "✓ Merged to: $MAIN_BRANCH"
  if [ "$delete_choice" = "y" ]; then
    echo "✓ Branch: Deleted"
  fi
fi

if [ -n "$FEATURE_DIR" ]; then
  echo ""
  echo "📂 Feature Archive:"
  echo "  $FEATURE_DIR"
fi

echo ""
echo "🚀 Next Steps:"
if grep -q '"deploy' package.json 2>/dev/null; then
  echo "  - Deploy to staging: npm run deploy"
fi
if grep -q '"test:e2e' package.json 2>/dev/null; then
  echo "  - Run E2E tests: npm run test:e2e"
fi
echo "  - Monitor production for issues"
echo "  - Update project documentation if needed"
echo ""
```

---

## Error Handling

**If not in git repository:**
- Exit with clear error message

**If validation fails:**
- Show issues
- Offer to continue anyway or cancel

**If merge conflicts:**
- Provide clear resolution instructions
- Suggest --continue flag for resume

**If branch deletion fails:**
- Offer force delete option
- Allow keeping branch if user prefers

---

## Operating Principles

1. **User Guidance**: Clear, step-by-step process with explanations
2. **Safety First**: Confirm before destructive operations (merge, delete)
3. **Flexibility**: Allow skipping steps or customizing behavior
4. **Cleanup**: Remove temporary files, update documentation
5. **Validation**: Check tests, build, TypeScript before merging
6. **Transparency**: Show what's being done at each step

---

## Success Criteria

✅ Diagnostic files cleaned up
✅ Pre-merge validation passed (or user acknowledged issues)
✅ Changes committed with proper message
✅ Merged to main branch
✅ Feature branch deleted (optional)
✅ Feature status updated to Complete

---

**Workflow Coverage**: Completes ~100% of feature/bugfix lifecycle
**User Experience**: Guided, safe, transparent completion process
