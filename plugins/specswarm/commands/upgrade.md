---
description: Upgrade dependencies or frameworks with breaking change analysis and automated refactoring
natural_language_enabled: true
nl_triggers: upgrade, update, migrate, modernize, refactor to, switch to
nl_examples:
  - "Upgrade to React 19"
  - "Migrate from Redux to Zustand"
  - "Update to the latest PostgreSQL"
  - "Modernize the authentication system"
args:
  - name: upgrade_target
    description: What to upgrade (e.g., "React 18 to React 19", "all dependencies", "react", "@latest")
    required: true
  - name: --deps
    description: Upgrade all dependencies to latest (alternative to specifying target)
    required: false
  - name: --package
    description: Upgrade specific package (e.g., --package react)
    required: false
  - name: --dry-run
    description: Analyze breaking changes without making changes
    required: false
---

## Natural Language Support (v3.3.0+)

This command can be triggered via **natural language** - just describe the technology upgrade!

**Natural Language Examples:**
- "Upgrade to React 19"
- "Migrate from Redux to Zustand"
- "Update to the latest PostgreSQL"
- "Modernize the authentication system"
- "Switch to TypeScript 5.x"

**Slash Command (Precise):**
```bash
/specswarm:upgrade "upgrade description"
```

Both methods work identically. Natural language provides convenience, while the slash command offers precision.

---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Upgrade dependencies or frameworks with automated breaking change analysis and code refactoring.

**Purpose**: Streamline complex upgrade processes by automating dependency updates, breaking change detection, and code refactoring.

**Workflow**: Analyze → Plan → Update → Refactor → Test → Report

**Scope**:
- Framework upgrades (React 18→19, Vue 2→3, Next.js 13→14, etc.)
- Dependency upgrades (specific packages or all dependencies)
- Breaking change detection from changelogs
- Automated code refactoring for breaking changes
- Test validation after upgrade

**User Experience**:
- Single command handles complex multi-step upgrades
- Automatic breaking change detection
- Guided refactoring with codemod suggestions
- Test-driven validation
- Clear migration report with manual tasks

---

## Pre-Flight Checks

```bash
# Parse arguments
UPGRADE_TARGET=""
UPGRADE_ALL_DEPS=false
PACKAGE_NAME=""
DRY_RUN=false

# Extract upgrade target (first non-flag argument)
for arg in $ARGUMENTS; do
  if [ "${arg:0:2}" != "--" ] && [ -z "$UPGRADE_TARGET" ]; then
    UPGRADE_TARGET="$arg"
  elif [ "$arg" = "--deps" ]; then
    UPGRADE_ALL_DEPS=true
  elif [ "$arg" = "--package" ]; then
    shift
    PACKAGE_NAME="$1"
  elif [ "$arg" = "--dry-run" ]; then
    DRY_RUN=true
  fi
done

# Validate upgrade target
if [ -z "$UPGRADE_TARGET" ] && [ "$UPGRADE_ALL_DEPS" = false ] && [ -z "$PACKAGE_NAME" ]; then
  echo "❌ Error: Upgrade target required"
  echo ""
  echo "Usage: /specswarm:upgrade \"target\" [--deps] [--package name] [--dry-run]"
  echo ""
  echo "Examples:"
  echo "  /specswarm:upgrade \"React 18 to React 19\""
  echo "  /specswarm:upgrade \"Next.js 14 to Next.js 15\""
  echo "  /specswarm:upgrade --deps                    # All dependencies"
  echo "  /specswarm:upgrade --package react           # Specific package"
  echo "  /specswarm:upgrade \"Vue 2 to Vue 3\" --dry-run"
  exit 1
fi

# Normalize upgrade target
if [ "$UPGRADE_ALL_DEPS" = true ]; then
  UPGRADE_TARGET="all dependencies"
elif [ -n "$PACKAGE_NAME" ]; then
  UPGRADE_TARGET="$PACKAGE_NAME to latest"
fi

# Get project root
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "❌ Error: Not in a git repository"
  exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

# Check for package.json
if [ ! -f "package.json" ]; then
  echo "❌ Error: package.json not found"
  echo "   This command currently supports Node.js/npm projects."
  exit 1
fi
```

---

## Execution Steps

### Step 1: Display Welcome Banner

```bash
if [ "$DRY_RUN" = true ]; then
  echo "🔍 SpecSwarm Upgrade - Analysis Mode (Dry Run)"
else
  echo "⬆️  SpecSwarm Upgrade - Dependency & Framework Migration"
fi
echo "══════════════════════════════════════════"
echo ""
echo "Upgrade: $UPGRADE_TARGET"
echo ""

if [ "$DRY_RUN" = true ]; then
  echo "🔍 DRY RUN MODE: Analyzing only, no changes will be made"
  echo ""
  echo "This analysis will:"
  echo "  1. Detect current versions"
  echo "  2. Identify latest available versions"
  echo "  3. Analyze breaking changes from changelogs"
  echo "  4. Estimate refactoring impact"
  echo "  5. Generate migration plan"
  echo ""
else
  echo "This workflow will:"
  echo "  1. Analyze breaking changes"
  echo "  2. Generate migration plan"
  echo "  3. Update dependencies"
  echo "  4. Refactor code for breaking changes"
  echo "  5. Run tests to verify compatibility"
  echo "  6. Report manual migration tasks"
  echo ""
fi

read -p "Press Enter to start, or Ctrl+C to cancel..."
echo ""
```

---

### Step 2: Phase 1 - Analyze Current State

**YOU MUST NOW analyze the current dependency state:**

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Phase 1: Analyzing Current Dependencies"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
```

**Analysis steps:**

1. Read package.json to get current dependencies
2. Identify the packages to upgrade:
   - If UPGRADE_ALL_DEPS: all dependencies + devDependencies
   - If PACKAGE_NAME: specific package
   - If upgrade target like "React 18 to React 19": extract package names (react, react-dom, etc.)

3. For each package, detect:
   - Current version (from package.json)
   - Latest version (from npm registry)
   - Installed version (from package-lock.json or node_modules)

4. Check for framework-specific packages:
   - React: react, react-dom, @types/react
   - Vue: vue, @vue/*, vue-router
   - Next.js: next, react, react-dom
   - Remix: @remix-run/*
   - Angular: @angular/*

```bash
# Example analysis output
echo "📦 Current Versions:"
echo "   react: 18.2.0"
echo "   react-dom: 18.2.0"
echo "   @types/react: 18.0.28"
echo ""
echo "📦 Target Versions:"
echo "   react: 19.0.0"
echo "   react-dom: 19.0.0"
echo "   @types/react: 19.0.0"
echo ""
```

Store:
- PACKAGES_TO_UPGRADE (array of package names)
- CURRENT_VERSIONS (map of package → version)
- TARGET_VERSIONS (map of package → version)

---

### Step 3: Phase 2 - Breaking Change Analysis

**YOU MUST NOW analyze breaking changes:**

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Phase 2: Analyzing Breaking Changes"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Fetching changelogs and release notes..."
echo ""
```

**For each package being upgraded:**

1. **Fetch changelog/release notes:**
   - Check GitHub releases (if repository URL in package.json)
   - Check npm package page
   - Use WebFetch tool to get changelog content

2. **Extract breaking changes:**
   - Look for "BREAKING CHANGE", "Breaking Changes", "⚠️", "❗" sections
   - Extract version-specific breaking changes (between current and target)
   - Parse common patterns:
     - "Removed X"
     - "X is now Y"
     - "X has been deprecated"
     - "X no longer supports Y"

3. **Categorize breaking changes:**
   - **API changes**: Function signature changes, removed methods
   - **Behavior changes**: Default behavior modifications
   - **Deprecations**: Deprecated but still working
   - **Removals**: Features completely removed
   - **Configuration**: Config file format changes

4. **Assess impact on codebase:**
   - Search codebase for usage of affected APIs
   - Estimate files requiring manual changes
   - Identify automated refactoring opportunities

```bash
echo "🔍 Breaking Changes Detected:"
echo ""
echo "React 18 → 19:"
echo "  ⚠️  ReactDOM.render removed (use createRoot)"
echo "  ⚠️  Legacy Context API deprecated"
echo "  ⚠️  PropTypes moved to separate package"
echo "  ✅ Automatic migration available for 2/3 changes"
echo ""
echo "Impact Analysis:"
echo "  📁 3 files use ReactDOM.render"
echo "  📁 1 file uses Legacy Context"
echo "  📁 0 files use PropTypes"
echo ""
```

Store:
- BREAKING_CHANGES (array of change descriptions)
- AFFECTED_FILES (map of change → files)
- AUTO_FIXABLE (array of changes with codemods available)

---

### Step 4: Phase 3 - Generate Migration Plan

**YOU MUST NOW generate a detailed migration plan:**

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Phase 3: Generating Migration Plan"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
```

**Create a migration plan that includes:**

1. **Dependency Update Steps:**
   ```
   npm install react@19 react-dom@19 @types/react@19
   ```

2. **Automated Refactoring Steps:**
   - For each auto-fixable breaking change
   - Codemod command or manual find/replace pattern
   - Example: `npx react-codemod create-root src/`

3. **Manual Migration Tasks:**
   - For each non-auto-fixable breaking change
   - Which files need manual updates
   - What changes to make
   - Code examples (before/after)

4. **Test Validation:**
   - Test commands to run after changes
   - Expected test results

5. **Risk Assessment:**
   - Low/Medium/High risk rating
   - Estimated time
   - Recommended approach (all at once vs incremental)

```bash
echo "Migration Plan Generated:"
echo ""
echo "1. Update Dependencies (automated)"
echo "   └─ npm install react@19 react-dom@19"
echo ""
echo "2. Automated Refactoring (3 codemods)"
echo "   └─ ReactDOM.render → createRoot"
echo "   └─ Legacy Context → New Context API"
echo "   └─ Update TypeScript types"
echo ""
echo "3. Manual Tasks (1 required)"
echo "   └─ Review and test Legacy Context migration in src/contexts/ThemeContext.tsx"
echo ""
echo "4. Test Validation"
echo "   └─ npm test (all tests must pass)"
echo ""
echo "Risk Assessment: MEDIUM"
echo "Estimated Time: 15-30 minutes"
echo ""
```

IF DRY_RUN = true:
  - Stop here, display plan, exit
  - Do NOT make any changes

---

### Step 5: Phase 4 - Update Dependencies

**IF NOT dry run, YOU MUST NOW update dependencies:**

```bash
if [ "$DRY_RUN" = false ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📦 Phase 4: Updating Dependencies"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
fi
```

**Use Bash tool to run npm install:**

```bash
# Build install command
INSTALL_CMD="npm install"

for package in "${PACKAGES_TO_UPGRADE[@]}"; do
  target_version="${TARGET_VERSIONS[$package]}"
  INSTALL_CMD="$INSTALL_CMD $package@$target_version"
done

echo "Running: $INSTALL_CMD"
echo ""

# Execute
$INSTALL_CMD

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Dependencies updated successfully"
  echo ""
else
  echo ""
  echo "❌ Dependency update failed"
  echo "   Check npm output above for errors"
  exit 1
fi
```

---

### Step 6: Phase 5 - Automated Refactoring

**IF NOT dry run, YOU MUST NOW apply automated refactorings:**

```bash
if [ "$DRY_RUN" = false ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔧 Phase 5: Automated Refactoring"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
fi
```

**For each auto-fixable breaking change:**

1. **Apply codemod** (if available):
   - React: `npx react-codemod <codemod-name> <path>`
   - Vue: `npx vue-codemod <codemod-name> <path>`
   - Other: Custom find/replace using Edit tool

2. **Apply manual refactoring patterns:**
   - Use Grep tool to find affected code
   - Use Edit tool to make changes
   - Log each change for rollback if needed

3. **Verify changes:**
   - Check syntax (bash -n for shell, tsc --noEmit for TypeScript)
   - Quick validation that files parse correctly

```bash
echo "Applying refactoring 1/3: ReactDOM.render → createRoot"
# Apply codemod or manual refactoring
echo "✅ Refactored 3 files"
echo ""

echo "Applying refactoring 2/3: Legacy Context → New Context API"
# Apply codemod or manual refactoring
echo "✅ Refactored 1 file"
echo ""

echo "Applying refactoring 3/3: Update TypeScript types"
# Apply codemod or manual refactoring
echo "✅ Updated type definitions"
echo ""
```

---

### Step 7: Phase 6 - Test Validation

**IF NOT dry run, YOU MUST NOW run tests:**

```bash
if [ "$DRY_RUN" = false ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✓ Phase 6: Testing Compatibility"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
fi
```

**Run test suite:**

1. Detect test command (package.json scripts.test)
2. Run tests with Bash tool
3. Capture results
4. Report pass/fail

```bash
echo "Running test suite..."
echo ""

npm test

TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
  echo ""
  echo "✅ All tests passing after upgrade!"
  echo ""
  TESTS_PASSING=true
else
  echo ""
  echo "⚠️  Some tests failing after upgrade"
  echo "   This may be expected for breaking changes requiring manual migration"
  echo ""
  TESTS_PASSING=false
fi
```

---

### Step 8: Final Report

**Display completion summary:**

```bash
echo ""
echo "══════════════════════════════════════════"

if [ "$DRY_RUN" = true ]; then
  echo "🔍 UPGRADE ANALYSIS COMPLETE (DRY RUN)"
  echo "══════════════════════════════════════════"
  echo ""
  echo "Upgrade: $UPGRADE_TARGET"
  echo ""
  echo "📋 Migration Plan Ready"
  echo "📊 Risk Assessment: [RISK_LEVEL]"
  echo "⏱️  Estimated Time: [TIME_ESTIMATE]"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📝 NEXT STEPS"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "1. Review migration plan above"
  echo "2. If acceptable, run actual upgrade:"
  echo "   /specswarm:upgrade \"$UPGRADE_TARGET\""
  echo ""
  echo "3. Or handle migration manually using plan as guide"
  echo ""
else
  echo "🎉 UPGRADE COMPLETE"
  echo "══════════════════════════════════════════"
  echo ""
  echo "Upgrade: $UPGRADE_TARGET"
  echo ""
  echo "✅ Dependencies updated"
  echo "✅ Automated refactoring applied"

  if [ "$TESTS_PASSING" = true ]; then
    echo "✅ All tests passing"
  else
    echo "⚠️  Tests require attention (see output above)"
  fi

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📝 MANUAL TASKS REMAINING"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # List manual tasks from migration plan
  echo "The following tasks require manual intervention:"
  echo ""
  for task in "${MANUAL_TASKS[@]}"; do
    echo "  ⚠️  $task"
  done

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🧪 RECOMMENDED TESTING"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "1. 🔍 Review Changes"
  echo "   git diff"
  echo ""
  echo "2. 🧪 Manual Testing"
  echo "   - Start development server"
  echo "   - Test critical user flows"
  echo "   - Verify no console errors"
  echo "   - Check for visual regressions"
  echo ""
  echo "3. 📊 Performance Check"
  echo "   - Compare bundle size (if applicable)"
  echo "   - Verify no performance degradation"
  echo ""

  if [ "$TESTS_PASSING" = true ]; then
    echo "4. 🚢 Ship When Ready"
    echo "   /specswarm:ship"
    echo ""
    echo "   All tests passing - ready to merge after manual verification"
  else
    echo "4. 🔧 Fix Failing Tests"
    echo "   - Address test failures"
    echo "   - Complete manual migration tasks above"
    echo "   - Re-run: npm test"
    echo ""
    echo "5. 🚢 Ship When Tests Pass"
    echo "   /specswarm:ship"
  fi

  echo ""
fi

echo "══════════════════════════════════════════"
```

---

## Error Handling

If any step fails:

1. **Changelog fetch fails**: Continue with generic breaking change warnings
2. **Dependency update fails**: Display npm errors, suggest manual resolution
3. **Refactoring fails**: Roll back changes, report errors
4. **Tests fail**: Report as warning, not error (expected for breaking changes)

**All errors should report clearly and suggest remediation.**

---

## Design Philosophy

**Automated Where Possible**: Codemods and refactoring patterns reduce manual work

**Transparent Process**: Clear breaking change analysis before making changes

**Safety First**: Dry run mode for risk assessment, test validation after changes

**Guidance**: Manual tasks clearly documented with examples

**Realistic**: Acknowledges that some migrations require manual intervention

---

## Use Cases

**Framework Upgrades:**
- React 18 → 19
- Vue 2 → 3
- Next.js 14 → 15
- Angular major versions

**Dependency Upgrades:**
- All dependencies to latest
- Specific package upgrades
- Security vulnerability fixes

**Breaking Change Migrations:**
- API removals
- Configuration format changes
- Behavior modifications

---

## Limitations

**Current Support:**
- ✅ Node.js/npm projects (package.json)
- ✅ React framework upgrades
- ✅ Common JavaScript libraries

**Future Enhancements:**
- Python (pip, requirements.txt)
- Ruby (Gemfile)
- Rust (Cargo.toml)
- More framework-specific codemods
- Automated rollback on test failure
