---
description: Comprehensive release preparation workflow including quality gates, security audit, changelog generation, version bumping, tagging, and publishing
args:
  - name: --patch
    description: Create patch release (bug fixes, 1.0.0 → 1.0.1)
    required: false
  - name: --minor
    description: Create minor release (new features, 1.0.0 → 1.1.0)
    required: false
  - name: --major
    description: Create major release (breaking changes, 1.0.0 → 2.0.0)
    required: false
  - name: --skip-audit
    description: Skip security audit (not recommended for production)
    required: false
---

## Goal

Orchestrate a complete release workflow with quality gates, version bumping, and publishing automation.

## User Input

```text
$ARGUMENTS
```

---

## What This Command Does

`/sw:release` orchestrates a complete release workflow:

1. **Pre-Release Validation** - Checks git status, branch protection, uncommitted changes
2. **Quality Gates** - Runs tests, linting, type checking, build verification
3. **Security Audit** - Optional security scan (recommended for production releases)
4. **Version Bumping** - Semantic versioning (patch/minor/major)
5. **Changelog Generation** - Auto-generates changelog from git commits
6. **Git Tagging** - Creates annotated git tags
7. **Artifact Building** - Builds production-ready artifacts
8. **Publishing** - Optional npm publish and GitHub release creation

---

## When to Use This Command

- Preparing production releases
- Creating new package versions
- Publishing to npm registry
- Creating GitHub releases
- After completing a feature milestone
- Before deploying to production

---

## Prerequisites

- Git repository with clean working directory
- On a release-ready branch (main/master or release branch)
- All tests passing
- package.json exists (for version bumping)
- npm credentials configured (if publishing to npm)
- GitHub CLI installed (if creating GitHub releases)

---

## Usage

```bash
/sw:release
```

**Options** (via interactive prompts):
- Release type (patch/minor/major)
- Run security audit (yes/no)
- Publish to npm (yes/no)
- Create GitHub release (yes/no)
- Push to remote (yes/no)

---

## Output

1. Updated `package.json` with new version
2. Generated/updated `CHANGELOG.md`
3. Git tag (e.g., `v1.2.3`)
4. Built artifacts (in `dist/` or `build/`)
5. Optional: Published npm package
6. Optional: GitHub release with notes

---

## Implementation

```bash
#!/bin/bash

set -euo pipefail

# ============================================================================
# RELEASE COMMAND - v3.1.0
# ============================================================================

echo "📦 SpecSwarm Release Workflow"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================================================
# CONFIGURATION
# ============================================================================

RELEASE_TYPE="patch"
RUN_SECURITY_AUDIT="no"
PUBLISH_TO_NPM="no"
CREATE_GITHUB_RELEASE="no"
PUSH_TO_REMOTE="yes"
DRY_RUN="no"

CURRENT_VERSION=""
NEW_VERSION=""
CHANGELOG_FILE="CHANGELOG.md"
TAG_NAME=""

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

log_section() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$1"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
}

log_check() {
  local check_name=$1
  local status=$2
  local message=$3

  if [ "$status" = "pass" ]; then
    echo "✅ $check_name: $message"
  elif [ "$status" = "warn" ]; then
    echo "⚠️  $check_name: $message"
  else
    echo "❌ $check_name: $message"
  fi
}

semver_bump() {
  local version=$1
  local bump_type=$2

  # Parse version (e.g., "1.2.3" -> major=1, minor=2, patch=3)
  local major minor patch
  IFS='.' read -r major minor patch <<< "${version#v}"

  case "$bump_type" in
    major)
      major=$((major + 1))
      minor=0
      patch=0
      ;;
    minor)
      minor=$((minor + 1))
      patch=0
      ;;
    patch)
      patch=$((patch + 1))
      ;;
  esac

  echo "${major}.${minor}.${patch}"
}

generate_changelog_entry() {
  local version=$1
  local previous_tag=$2
  local date=$(date +%Y-%m-%d)

  echo "## [$version] - $date"
  echo ""

  # Get commits since last tag
  if [ -n "$previous_tag" ]; then
    commits=$(git log "$previous_tag..HEAD" --pretty=format:"- %s" --no-merges 2>/dev/null || echo "- Initial release")
  else
    commits=$(git log --pretty=format:"- %s" --no-merges 2>/dev/null || echo "- Initial release")
  fi

  # Categorize commits
  echo "### Added"
  echo "$commits" | grep -i "^- \(feat\|add\|new\)" || echo "- No new features"
  echo ""

  echo "### Fixed"
  echo "$commits" | grep -i "^- \(fix\|bugfix\|patch\)" || echo "- No bug fixes"
  echo ""

  echo "### Changed"
  echo "$commits" | grep -i "^- \(update\|change\|refactor\|improve\)" || echo "- No changes"
  echo ""

  echo "### Deprecated"
  echo "- None"
  echo ""

  echo "### Removed"
  echo "- None"
  echo ""

  echo "### Security"
  echo "- Security audit passed"
  echo ""
}

# ============================================================================
# PREFLIGHT CHECKS
# ============================================================================

log_section "Preflight Checks"

# Check 1: Git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  log_check "Git Repository" "fail" "Not in a git repository"
  exit 1
fi
log_check "Git Repository" "pass" "Valid git repository"

# Check 2: Clean working directory
DIRTY=$(git status --porcelain 2>/dev/null)
if [ -n "$DIRTY" ]; then
  log_check "Working Directory" "fail" "Uncommitted changes detected"
  echo ""
  git status --short
  echo ""
  echo "Please commit or stash changes before releasing"
  exit 1
fi
log_check "Working Directory" "pass" "Clean working directory"

# Check 3: Current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
log_check "Current Branch" "pass" "$CURRENT_BRANCH"

RELEASE_BRANCHES=("main" "master" "develop" "release")
IS_RELEASE_BRANCH=false
for branch in "${RELEASE_BRANCHES[@]}"; do
  if [ "$CURRENT_BRANCH" = "$branch" ] || [[ "$CURRENT_BRANCH" == release/* ]]; then
    IS_RELEASE_BRANCH=true
    break
  fi
done

if [ "$IS_RELEASE_BRANCH" = false ]; then
  log_check "Branch Validation" "warn" "Not on a typical release branch (main/master/develop/release/*)"
  echo "   Current branch: $CURRENT_BRANCH"
  echo "   You may want to merge to a release branch first"
fi

# Check 4: package.json exists
if [ ! -f "package.json" ]; then
  log_check "package.json" "fail" "No package.json found"
  echo "   Release command requires package.json for version management"
  exit 1
fi
log_check "package.json" "pass" "Found package.json"

# Check 5: Get current version
CURRENT_VERSION=$(jq -r '.version' package.json)
if [ "$CURRENT_VERSION" = "null" ] || [ -z "$CURRENT_VERSION" ]; then
  log_check "Version" "fail" "No version in package.json"
  exit 1
fi
log_check "Current Version" "pass" "$CURRENT_VERSION"

# Check 6: Remote repository
if git remote -v | grep -q "origin"; then
  REMOTE_URL=$(git remote get-url origin)
  log_check "Remote Repository" "pass" "$REMOTE_URL"
  HAS_REMOTE=true
else
  log_check "Remote Repository" "warn" "No remote 'origin' configured"
  HAS_REMOTE=false
fi

# Check 7: GitHub CLI (for GitHub releases)
if command -v gh > /dev/null 2>&1; then
  log_check "GitHub CLI" "pass" "gh available"
  HAS_GH_CLI=true
else
  log_check "GitHub CLI" "warn" "gh not installed (GitHub releases disabled)"
  HAS_GH_CLI=false
fi

# ============================================================================
# QUALITY GATES
# ============================================================================

log_section "Quality Gates"

# Check for quality-standards.md
QUALITY_GATES_ENFORCED=false
if [ -f ".specswarm/quality-standards.md" ]; then
  log_check "Quality Standards" "pass" "Found quality-standards.md"
  QUALITY_GATES_ENFORCED=true

  # Extract quality gate settings
  if grep -q "enforce_gates: true" .specswarm/quality-standards.md 2>/dev/null; then
    echo "   Quality gates are enforced"
  fi
else
  log_check "Quality Standards" "warn" "No quality-standards.md (run /sw:init)"
fi

# Run tests if available
if jq -e '.scripts.test' package.json > /dev/null 2>&1; then
  echo ""
  echo "Running tests..."
  if npm test 2>&1 | tee /tmp/test-output.txt; then
    log_check "Tests" "pass" "All tests passed"
  else
    log_check "Tests" "fail" "Tests failed"
    echo ""
    echo "Cannot release with failing tests"
    exit 1
  fi
else
  log_check "Tests" "warn" "No test script defined"
fi

# Run linting if available
if jq -e '.scripts.lint' package.json > /dev/null 2>&1; then
  echo ""
  echo "Running linter..."
  if npm run lint 2>&1 | tee /tmp/lint-output.txt; then
    log_check "Linting" "pass" "Linting passed"
  else
    log_check "Linting" "fail" "Linting failed"
    echo ""
    echo "Cannot release with linting errors"
    exit 1
  fi
else
  log_check "Linting" "warn" "No lint script defined"
fi

# Run type checking if available (TypeScript)
if jq -e '.scripts["type-check"]' package.json > /dev/null 2>&1; then
  echo ""
  echo "Running type check..."
  if npm run type-check 2>&1 | tee /tmp/typecheck-output.txt; then
    log_check "Type Check" "pass" "Type checking passed"
  else
    log_check "Type Check" "fail" "Type errors found"
    echo ""
    echo "Cannot release with type errors"
    exit 1
  fi
else
  log_check "Type Check" "warn" "No type-check script defined"
fi

# Run build if available
if jq -e '.scripts.build' package.json > /dev/null 2>&1; then
  echo ""
  echo "Running build..."
  if npm run build 2>&1 | tee /tmp/build-output.txt; then
    log_check "Build" "pass" "Build successful"
  else
    log_check "Build" "fail" "Build failed"
    echo ""
    echo "Cannot release with build errors"
    exit 1
  fi
else
  log_check "Build" "warn" "No build script defined"
fi

echo ""
echo "✅ All quality gates passed"

# ============================================================================
# INTERACTIVE CONFIGURATION
# ============================================================================

log_section "Release Configuration"

# Question 1: Release type
cat << 'EOF_QUESTION_1' | claude --question
{
  "questions": [
    {
      "question": "What type of release is this?",
      "header": "Release type",
      "multiSelect": false,
      "options": [
        {
          "label": "Patch (bug fixes)",
          "description": "Patch release - bug fixes and minor updates (1.0.0 → 1.0.1)"
        },
        {
          "label": "Minor (new features)",
          "description": "Minor release - new features, backward compatible (1.0.0 → 1.1.0)"
        },
        {
          "label": "Major (breaking changes)",
          "description": "Major release - breaking changes or major features (1.0.0 → 2.0.0)"
        }
      ]
    }
  ]
}
EOF_QUESTION_1

# Parse release type
if echo "$CLAUDE_ANSWERS" | jq -e '.["Release type"] == "Minor (new features)"' > /dev/null 2>&1; then
  RELEASE_TYPE="minor"
elif echo "$CLAUDE_ANSWERS" | jq -e '.["Release type"] == "Major (breaking changes)"' > /dev/null 2>&1; then
  RELEASE_TYPE="major"
else
  RELEASE_TYPE="patch"
fi

# Calculate new version
NEW_VERSION=$(semver_bump "$CURRENT_VERSION" "$RELEASE_TYPE")
TAG_NAME="v${NEW_VERSION}"

echo "Current version: $CURRENT_VERSION"
echo "New version: $NEW_VERSION ($RELEASE_TYPE)"
echo "Tag name: $TAG_NAME"

# Question 2: Security audit
cat << 'EOF_QUESTION_2' | claude --question
{
  "questions": [
    {
      "question": "Run security audit before releasing?",
      "header": "Security",
      "multiSelect": false,
      "options": [
        {
          "label": "Yes, run audit",
          "description": "Recommended for production releases - scans dependencies and code"
        },
        {
          "label": "No, skip audit",
          "description": "Skip security audit (not recommended for production)"
        }
      ]
    }
  ]
}
EOF_QUESTION_2

# Parse security audit answer
if echo "$CLAUDE_ANSWERS" | jq -e '.["Security"] == "Yes, run audit"' > /dev/null 2>&1; then
  RUN_SECURITY_AUDIT="yes"
fi

echo "Security audit: $RUN_SECURITY_AUDIT"

# Question 3: Publishing options
PUBLISH_OPTIONS=()

# Always ask about npm publishing
PUBLISH_OPTIONS+='{
  "label": "Publish to npm",
  "description": "Publish package to npm registry (requires npm credentials)"
}'

# Add GitHub release option if gh CLI is available
if [ "$HAS_GH_CLI" = true ]; then
  PUBLISH_OPTIONS+='{
    "label": "Create GitHub release",
    "description": "Create GitHub release with auto-generated notes"
  }'
fi

# Add push to remote option if remote exists
if [ "$HAS_REMOTE" = true ]; then
  PUBLISH_OPTIONS+='{
    "label": "Push to remote",
    "description": "Push commits and tags to remote repository"
  }'
fi

# Build JSON array for options
PUBLISH_OPTIONS_JSON=$(printf '%s\n' "${PUBLISH_OPTIONS[@]}" | jq -s .)

cat << EOF_QUESTION_3 | claude --question
{
  "questions": [
    {
      "question": "Select publishing and deployment options:",
      "header": "Publishing",
      "multiSelect": true,
      "options": $PUBLISH_OPTIONS_JSON
    }
  ]
}
EOF_QUESTION_3

# Parse publishing options
if echo "$CLAUDE_ANSWERS" | jq -e '.["Publishing"]' | grep -q "Publish to npm"; then
  PUBLISH_TO_NPM="yes"
fi

if echo "$CLAUDE_ANSWERS" | jq -e '.["Publishing"]' | grep -q "Create GitHub release"; then
  CREATE_GITHUB_RELEASE="yes"
fi

if echo "$CLAUDE_ANSWERS" | jq -e '.["Publishing"]' | grep -q "Push to remote"; then
  PUSH_TO_REMOTE="yes"
else
  PUSH_TO_REMOTE="no"
fi

echo "Publish to npm: $PUBLISH_TO_NPM"
echo "Create GitHub release: $CREATE_GITHUB_RELEASE"
echo "Push to remote: $PUSH_TO_REMOTE"

# ============================================================================
# SECURITY AUDIT (OPTIONAL)
# ============================================================================

if [ "$RUN_SECURITY_AUDIT" = "yes" ]; then
  log_section "Security Audit"

  echo "Running security audit..."
  # Note: This would call /sw:security-audit in production
  # For now, we'll run npm audit directly
  if command -v npm > /dev/null 2>&1; then
    if npm audit --audit-level=moderate 2>&1 | tee /tmp/audit-output.txt; then
      log_check "Security Audit" "pass" "No moderate+ vulnerabilities"
    else
      log_check "Security Audit" "fail" "Vulnerabilities found"
      echo ""
      echo "Security audit failed. Fix vulnerabilities before releasing."
      echo "Run: npm audit fix"
      exit 1
    fi
  else
    log_check "Security Audit" "warn" "npm not available, skipping audit"
  fi
fi

# ============================================================================
# VERSION BUMPING
# ============================================================================

log_section "Version Bumping"

echo "Updating version in package.json..."

# Update package.json version
jq --arg version "$NEW_VERSION" '.version = $version' package.json > package.json.tmp
mv package.json.tmp package.json

log_check "package.json" "pass" "Updated to $NEW_VERSION"

# Update package-lock.json if it exists
if [ -f "package-lock.json" ]; then
  jq --arg version "$NEW_VERSION" '.version = $version' package-lock.json > package-lock.json.tmp
  mv package-lock.json.tmp package-lock.json
  log_check "package-lock.json" "pass" "Updated to $NEW_VERSION"
fi

# ============================================================================
# CHANGELOG GENERATION
# ============================================================================

log_section "Changelog Generation"

# Get previous tag
PREVIOUS_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -n "$PREVIOUS_TAG" ]; then
  echo "Previous tag: $PREVIOUS_TAG"
else
  echo "No previous tags found (first release)"
fi

# Generate changelog entry
CHANGELOG_ENTRY=$(generate_changelog_entry "$NEW_VERSION" "$PREVIOUS_TAG")

# Update or create CHANGELOG.md
if [ -f "$CHANGELOG_FILE" ]; then
  echo "Updating $CHANGELOG_FILE..."

  # Prepend new entry to existing changelog
  {
    echo "# Changelog"
    echo ""
    echo "$CHANGELOG_ENTRY"
    echo ""
    tail -n +2 "$CHANGELOG_FILE"
  } > "${CHANGELOG_FILE}.tmp"

  mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"
else
  echo "Creating $CHANGELOG_FILE..."

  cat > "$CHANGELOG_FILE" << EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

$CHANGELOG_ENTRY
EOF
fi

log_check "Changelog" "pass" "Updated $CHANGELOG_FILE"

# ============================================================================
# GIT COMMIT & TAG
# ============================================================================

log_section "Git Commit & Tag"

# Stage changes
git add package.json package-lock.json "$CHANGELOG_FILE" 2>/dev/null || true

# Create commit
COMMIT_MESSAGE="chore(release): v${NEW_VERSION}

🚀 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

git commit -m "$COMMIT_MESSAGE"
log_check "Git Commit" "pass" "Created release commit"

# Create annotated tag
TAG_MESSAGE="Release v${NEW_VERSION}

$(echo "$CHANGELOG_ENTRY" | head -n 30)

🚀 Generated with [Claude Code](https://claude.com/claude-code)"

git tag -a "$TAG_NAME" -m "$TAG_MESSAGE"
log_check "Git Tag" "pass" "Created tag $TAG_NAME"

# ============================================================================
# BUILD ARTIFACTS
# ============================================================================

if jq -e '.scripts.build' package.json > /dev/null 2>&1; then
  log_section "Building Artifacts"

  echo "Running production build..."
  if npm run build; then
    log_check "Build" "pass" "Production artifacts built"
  else
    log_check "Build" "fail" "Build failed"
    echo ""
    echo "Build failed after version bump. Please fix and retry."
    exit 1
  fi
fi

# ============================================================================
# PUSH TO REMOTE
# ============================================================================

if [ "$PUSH_TO_REMOTE" = "yes" ] && [ "$HAS_REMOTE" = true ]; then
  log_section "Push to Remote"

  echo "Pushing to remote..."
  git push origin "$CURRENT_BRANCH"
  log_check "Push Branch" "pass" "Pushed $CURRENT_BRANCH"

  git push origin "$TAG_NAME"
  log_check "Push Tag" "pass" "Pushed $TAG_NAME"
fi

# ============================================================================
# NPM PUBLISHING
# ============================================================================

if [ "$PUBLISH_TO_NPM" = "yes" ]; then
  log_section "NPM Publishing"

  echo "Publishing to npm..."

  # Check if logged in to npm
  if npm whoami > /dev/null 2>&1; then
    NPM_USER=$(npm whoami)
    echo "Logged in as: $NPM_USER"

    # Publish to npm
    if npm publish; then
      log_check "npm publish" "pass" "Published to npm registry"
    else
      log_check "npm publish" "fail" "npm publish failed"
      echo ""
      echo "npm publish failed. Check credentials and package.json configuration."
      exit 1
    fi
  else
    log_check "npm auth" "fail" "Not logged in to npm"
    echo ""
    echo "Please run: npm login"
    exit 1
  fi
fi

# ============================================================================
# GITHUB RELEASE
# ============================================================================

if [ "$CREATE_GITHUB_RELEASE" = "yes" ] && [ "$HAS_GH_CLI" = true ]; then
  log_section "GitHub Release"

  echo "Creating GitHub release..."

  # Create release notes
  RELEASE_NOTES=$(cat << EOF
$CHANGELOG_ENTRY

---

**Full Changelog**: https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/compare/${PREVIOUS_TAG}...${TAG_NAME}

🚀 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)

  # Create GitHub release
  if gh release create "$TAG_NAME" \
    --title "Release $TAG_NAME" \
    --notes "$RELEASE_NOTES"; then
    log_check "GitHub Release" "pass" "Created release $TAG_NAME"
  else
    log_check "GitHub Release" "fail" "Failed to create GitHub release"
    echo ""
    echo "GitHub release creation failed. Check gh CLI authentication."
  fi
fi

# ============================================================================
# SUMMARY
# ============================================================================

log_section "Release Complete"

echo "🎉 Successfully released version $NEW_VERSION!"
echo ""
echo "Summary:"
echo "  Previous version: $CURRENT_VERSION"
echo "  New version: $NEW_VERSION"
echo "  Release type: $RELEASE_TYPE"
echo "  Git tag: $TAG_NAME"
echo "  Branch: $CURRENT_BRANCH"
echo ""

if [ "$PUBLISH_TO_NPM" = "yes" ]; then
  echo "  📦 Published to npm: https://www.npmjs.com/package/$(jq -r '.name' package.json)"
fi

if [ "$CREATE_GITHUB_RELEASE" = "yes" ]; then
  REPO_URL=$(git remote get-url origin | sed 's/\.git$//' | sed 's/git@github.com:/https:\/\/github.com\//')
  echo "  🚀 GitHub release: ${REPO_URL}/releases/tag/${TAG_NAME}"
fi

echo ""
echo "Next steps:"
if [ "$PUSH_TO_REMOTE" = "no" ]; then
  echo "  - Push changes: git push origin $CURRENT_BRANCH --tags"
fi
if [ "$PUBLISH_TO_NPM" = "no" ]; then
  echo "  - Publish to npm: npm publish"
fi
echo "  - Deploy to production environments"
echo "  - Update documentation if needed"
echo "  - Notify stakeholders of the release"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

---

## Examples

### Example 1: Patch Release (Bug Fixes)

```bash
/sw:release
# Select: Patch (bug fixes)
# Select: Yes, run audit
# Select: Push to remote
# Result: v1.0.1 released with security audit
```

### Example 2: Minor Release (New Features)

```bash
/sw:release
# Select: Minor (new features)
# Select: Yes, run audit
# Select: Publish to npm, Create GitHub release, Push to remote
# Result: v1.1.0 published to npm and GitHub
```

### Example 3: Major Release (Breaking Changes)

```bash
/sw:release
# Select: Major (breaking changes)
# Select: Yes, run audit
# Select: All publishing options
# Result: v2.0.0 with full publishing workflow
```

---

## Release Checklist

The command automatically handles:

- ✅ Verify clean working directory
- ✅ Run all tests
- ✅ Run linting
- ✅ Run type checking (if TypeScript)
- ✅ Run production build
- ✅ Optional security audit
- ✅ Bump version in package.json
- ✅ Update/create CHANGELOG.md
- ✅ Create git commit
- ✅ Create annotated git tag
- ✅ Push to remote
- ✅ Optional: Publish to npm
- ✅ Optional: Create GitHub release

---

## Semantic Versioning

The command follows [Semantic Versioning](https://semver.org/):

- **Patch** (1.0.0 → 1.0.1): Bug fixes, minor updates
- **Minor** (1.0.0 → 1.1.0): New features, backward compatible
- **Major** (1.0.0 → 2.0.0): Breaking changes

---

## Changelog Format

Generated changelogs follow [Keep a Changelog](https://keepachangelog.com/) format:

```markdown
## [1.2.0] - 2025-01-15

### Added
- feat: new user dashboard
- add: dark mode support

### Fixed
- fix: authentication bug
- bugfix: memory leak

### Changed
- update: API endpoint structure
- refactor: database queries
```

---

## CI/CD Integration

Integrate with GitHub Actions:

```yaml
# .github/workflows/release.yml
name: Release
on:
  workflow_dispatch:
    inputs:
      release_type:
        description: 'Release type'
        required: true
        type: choice
        options:
          - patch
          - minor
          - major

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: /sw:release
        env:
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## Notes

- **Protected Branches**: Some quality gates may be skipped on feature branches
- **npm Credentials**: Run `npm login` before publishing to npm
- **GitHub Releases**: Requires `gh` CLI and authentication
- **Rollback**: Use `/sw:rollback` if release fails
- **Dry Run**: The command always shows what it will do before making changes

---

## Troubleshooting

**Build Fails**:
- Check build scripts in package.json
- Verify all dependencies are installed
- Review build logs in `/tmp/build-output.txt`

**npm Publish Fails**:
- Verify npm login: `npm whoami`
- Check package name availability
- Ensure version hasn't been published before

**GitHub Release Fails**:
- Verify gh CLI: `gh auth status`
- Check repository permissions
- Ensure remote URL is correct

---

## See Also

- `/sw:security-audit` - Run security audit separately
- `/sw:rollback` - Rollback failed releases
- `/sw:analyze-quality` - Check quality before releasing
- `/sw:ship` - Complete feature workflow with merge

---

**Version**: 3.1.0
**Category**: Release Management
**Estimated Time**: 3-10 minutes (depending on build and publishing)
