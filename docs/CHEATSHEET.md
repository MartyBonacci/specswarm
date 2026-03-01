# SpecSwarm Quick Reference Cheat Sheet

**Fast reference for common SpecSwarm commands and workflows.**

**Version**: v4.0.1 | **Commands**: 10 visible + 11 internal | **Language-Agnostic**

---

## Quick Installation

```bash
# Add the marketplace
/plugin marketplace add MartyBonacci/specswarm

# Install the plugin
/plugin install specswarm@specswarm-marketplace

# Verify
/plugin list
# Should show: specswarm v4.0.1
```

---

## Visual Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    PROJECT SETUP (Once)                     │
├─────────────────────────────────────────────────────────────┤
│  /specswarm:init                                            │
│  Create .specswarm/tech-stack.md                            │
│  Create .specswarm/quality-standards.md                     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              DEVELOPMENT WORKFLOWS                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  PROJECT SETUP: /specswarm:init                             │
│  FEATURE DEV:   /specswarm:build "feature"  (or NL)        │
│  BUG FIX:       /specswarm:fix "bug"                        │
│  MODIFICATION:  /specswarm:modify "change"                  │
│  SHIP:          /specswarm:ship                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Decision Tree

```
┌───────────────────────────────────────────────────────────────┐
│  WHICH WORKFLOW SHOULD I USE?                                │
└───────────────────────────────────────────────────────────────┘
  │
  ├─ New Feature       → /specswarm:build "feature"
  │
  ├─ Bug Fix           → /specswarm:fix "bug"
  │   └─ Production?   → /specswarm:fix "bug" --hotfix
  │
  ├─ Code Improvement  → /specswarm:modify "change"
  │   ├─ Quality?      → /specswarm:modify "change" --refactor
  │   └─ Sunset?       → /specswarm:modify "change" --deprecate
  │
  ├─ Impact Analysis   → /specswarm:modify "change" --analyze-only
  │
  └─ Quality Check     → /specswarm:ship (includes quality gate)
```

---

## Command Quick Reference

### Visible Commands (10)

| Command | Use When | Example |
|---------|----------|---------|
| `/specswarm:init` | Project setup | `/specswarm:init` |
| `/specswarm:build` | New feature | `/specswarm:build "Add user login"` |
| `/specswarm:fix` | Bug fix | `/specswarm:fix "Login fails on mobile"` |
| `/specswarm:modify` | Change feature | `/specswarm:modify "Update cart logic"` |
| `/specswarm:ship` | Finish & merge | `/specswarm:ship` |
| `/specswarm:fix --hotfix` | Emergency fix | `/specswarm:fix "API down" --hotfix` |
| `/specswarm:modify --refactor` | Improve code | `/specswarm:modify "Optimize auth" --refactor` |
| `/specswarm:modify --deprecate` | Remove feature | `/specswarm:modify "Old API v1" --deprecate` |
| `/specswarm:modify --analyze-only` | Assess changes | `/specswarm:modify "Update React" --analyze-only` |
| `/specswarm:analyze-quality` | Quality check | `/specswarm:analyze-quality` |

---

## Common Command Patterns

### Pattern 1: Feature Development

```bash
/specswarm:build "Add contact form with name, email, message fields, validation, and email sending"
# → Creates branch, specs, plans, implements, tests
# → Manual testing
/specswarm:ship
```

### Pattern 2: Bug Fix with Regression Test

```bash
/specswarm:fix "Bug: Cart total wrong when discount applied

Console: None
Terminal: None

Expected: $88 total (after discount + tax)
Actual: $90 total (tax before discount)

Steps:
1. Add $100 item
2. Apply 20OFF code
3. Checkout shows $90 instead of $88"

# → Manual testing
/specswarm:ship
```

### Pattern 3: Code Modification

```bash
/specswarm:modify "Migrate auth from session to JWT"
# → Manual testing
/specswarm:ship
```

### Pattern 4: Quality Check Before PR

```bash
# Before creating pull request
/specswarm:analyze-quality

# If score < 85, fix issues:
# - Add missing tests
# - Fix failing tests
# - Reduce bundle size

# Re-check
/specswarm:analyze-quality
```

---

## Configuration Templates

### .specswarm/tech-stack.md Template

```markdown
# Tech Stack v1.0.0

## Core Technologies
- React 19.x (functional components only)
- React Router v7 (framework mode)
- TypeScript 5.x

## Approved Libraries
- Zod v4+ (validation)
- Tailwind CSS (styling)
- Drizzle ORM (database)

## Prohibited
- ❌ Redux (use React Router loaders/actions)
- ❌ Class components (use functional)
- ❌ PropTypes (use TypeScript)
```

### .specswarm/quality-standards.md Template

```yaml
# Quality Gates
min_test_coverage: 80
min_quality_score: 85
block_merge_on_failure: false

# Performance Budgets
enforce_budgets: true
max_bundle_size: 500      # KB
max_initial_load: 1000    # KB

# Code Quality
max_complexity: 10
max_file_lines: 300
```

---

## Flag Reference

### Build Flags

```bash
/specswarm:build "description" [flags]

--validate              # Run Playwright browser testing
--audit                 # Run code audit
--skip-specify          # Skip spec generation
--skip-clarify          # Skip clarification
--skip-plan             # Skip planning
--max-retries N         # Max retries per task (default: 3)
```

### Fix Flags

```bash
/specswarm:fix "description" [flags]

--hotfix                # Emergency production fix (bypasses normal flow)
```

### Modify Flags

```bash
/specswarm:modify "description" [flags]

--refactor              # Quality/code improvement
--deprecate             # Sunset/remove feature
--analyze-only          # Impact analysis without making changes
```

---

## Git Branch Workflow

```
main
  └─ develop
      └─ sprint-3
          └─ 015-feature-branch  ← You work here

# When complete:
/specswarm:ship
# → Merges 015-feature-branch → sprint-3
# → Shows merge plan BEFORE executing
```

**Important**: Always check out parent branch BEFORE starting feature!

```bash
# Correct:
git checkout sprint-3
/specswarm:build "..."
# → Creates branch FROM sprint-3
# → Merges BACK TO sprint-3

# Wrong:
git checkout main
/specswarm:build "..."
# → Merges to main (bypasses sprint-3)
```

---

## Quality Score Guide

```
┌──────────────────────────────────────────────────────────┐
│  /specswarm:analyze-quality Score Interpretation         │
├──────────────────────────────────────────────────────────┤
│  90-100  │ ✅ Excellent  │ Ship with confidence          │
│  80-89   │ ✅ Good       │ Minor issues, safe to merge   │
│  70-79   │ ⚠️  Fair      │ Review before merging         │
│  <70     │ ❌ Needs Work │ Fix issues before merge       │
└──────────────────────────────────────────────────────────┘

Score Breakdown:
- Unit Tests: 25 pts
- Code Coverage: 25 pts
- Integration Tests: 15 pts
- Browser Tests: 15 pts
- Bundle Size: 20 pts (planned)
- Visual Alignment: 15 pts (planned)
```

---

## Troubleshooting Quick Fixes

### ❌ "Tech stack conflict detected"

```bash
# Fix: Update tech-stack.md
# Edit .specswarm/tech-stack.md
# Add approved technology or use alternative
```

### ❌ "Parent branch wrong in /complete"

```bash
# Fix: Check spec.md
cat features/015-*/spec.md | grep parent_branch

# If wrong, press 'n' when asked to merge
# Edit spec.md frontmatter manually
# Run /specswarm:complete again
```

### ❌ "Quality score too low"

```bash
# Fix: Check what's failing
/specswarm:analyze-quality

# Common fixes:
# - Add unit tests
# - Fix failing tests
# - Reduce bundle size (code splitting)
# - Fix TypeScript errors
```

### "Orchestration pauses mid-execution"

```bash
# Fix: Update to v4.0.1+
/plugin update specswarm

# v3.0+ eliminated all mid-phase pausing (autonomous execution)
```

---

## Keyboard Shortcuts

**In Claude Code**:
- `Ctrl/Cmd + K` - Open command palette
- Type `/` - Shows slash commands
- `Ctrl/Cmd + Shift + P` - Toggle plan mode

---

## Common File Locations

```
project-root/
├── .claude/                    # Claude Code config
├── memory/                     # Project memory
│   ├── tech-stack.md          # Technology constraints
│   ├── quality-standards.md   # Quality gates
│   └── constitution.md        # Project governance
├── features/                   # Feature artifacts
│   └── 015-feature-name/
│       ├── spec.md            # Specification
│       ├── plan.md            # Implementation plan
│       ├── tasks.md           # Task breakdown
│       └── research.md        # Research decisions
└── docs/
    ├── WORKFLOW.md            # This guide!
    └── CHEATSHEET.md          # This cheat sheet!
```

---

## Quick Links

- **[Complete Workflow Guide](./WORKFLOW.md)** - Detailed step-by-step guide
- **[Main README](../README.md)** - Overview and features
- **[SpecSwarm Docs](../plugins/specswarm/README.md)** - Command reference
- **[Changelog](../CHANGELOG.md)** - Version history
- **[GitHub Issues](https://github.com/MartyBonacci/specswarm/issues)** - Report bugs

---

## Version Information

This cheat sheet is for:
- **SpecSwarm**: v4.0.1
  - Compacted from 32/35 commands to 21 (10 visible + 11 internal)
  - Natural language commands (build, fix, ship, modify)
  - Language-agnostic (works with any language Claude supports)
  - Autonomous execution (no mid-phase pausing)
  - Parent branch safety

Check your version:
```bash
/plugin list
```

Update plugin:
```bash
/plugin update specswarm
```

---

**Happy coding! Print this cheat sheet or keep it open in a tab.** 📋✨
