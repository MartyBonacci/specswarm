# SpecSwarm Quick Reference Cheat Sheet

**Fast reference for common SpecSwarm commands and workflows.**

**Version**: v3.3.3 | **Commands**: 32 total | **Languages**: 6 supported

---

## Quick Installation

```bash
# Install SpecSwarm (unified plugin - includes all functionality)
/plugin https://github.com/MartyBonacci/specswarm
/plugin install specswarm

# Verify
/plugin list
# Should show: specswarm v3.3.3

# Note: SpecLabs is deprecated - all functionality now in SpecSwarm
```

---

## Visual Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    PROJECT SETUP (Once)                     │
├─────────────────────────────────────────────────────────────┤
│  /init                                                      │
│  Create .specswarm/tech-stack.md                              │
│  Create .specswarm/quality-standards.md                       │
│  /specswarm:constitution                                    │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              FEATURE DEVELOPMENT (Per Feature)              │
├─────────────────────────────────────────────────────────────┤
│  git checkout develop                                       │
│  /specswarm:suggest "feature idea"                          │
│                                                              │
│  ┌──────────────────┬──────────────────────────┐           │
│  │  AUTONOMOUS      │  MANUAL CONTROL          │           │
│  │  (Faster)        │  (More Control)          │           │
│  ├──────────────────┼──────────────────────────┤           │
│  │ /speclabs:       │ /specswarm:specify       │           │
│  │  orchestrate-    │ /specswarm:clarify       │           │
│  │  feature "..."   │ /specswarm:plan          │           │
│  │  --validate      │ /specswarm:tasks         │           │
│  │                  │ /specswarm:implement     │           │
│  └──────────────────┴──────────────────────────┘           │
│                            ↓                                 │
│  Manual Testing (ALWAYS!)                                   │
│  /specswarm:bugfix "Bug: ..." (if needed)                   │
│  /specswarm:analyze-quality                                 │
│  /specswarm:complete                                        │
└─────────────────────────────────────────────────────────────┘
```

---

## Decision Tree

```
┌───────────────────────────────────────────────────────────────┐
│  WHICH WORKFLOW SHOULD I USE?                                │
└───────────────────────────────────────────────────────────────┘
  │
  ├─ New Feature
  │   ├─ Simple, well-defined?          → /speclabs:orchestrate-feature
  │   ├─ Complex, architectural?        → /specswarm:specify
  │   └─ Unsure?                        → /specswarm:suggest
  │
  ├─ Bug Fix
  │   ├─ Production bug?                → /specswarm:hotfix
  │   └─ Regular bug?                   → /specswarm:bugfix
  │
  ├─ Code Improvement
  │   ├─ Changing existing feature?     → /specswarm:modify
  │   ├─ Quality improvement?           → /specswarm:refactor
  │   └─ Removing feature?              → /specswarm:deprecate
  │
  └─ Quality Check
      ├─ Before merge?                  → /specswarm:analyze-quality
      ├─ Impact of change?              → /specswarm:impact
      └─ Performance metrics?           → /specswarm:workflow-metrics
```

---

## Command Quick Reference

### Core Workflow Commands

| Command | Use When | Example |
|---------|----------|---------|
| `/specswarm:suggest` | Starting anything | `/specswarm:suggest "add auth"` |
| `/specswarm:specify` | New feature (manual) | `/specswarm:specify "Add user login"` |
| `/speclabs:orchestrate-feature` | New feature (auto) | `/speclabs:orchestrate-feature "..." --validate` |
| `/specswarm:implement` | Execute tasks | `/specswarm:implement` |
| `/specswarm:complete` | Finish & merge | `/specswarm:complete` |

### Bug & Maintenance Commands

| Command | Use When | Example |
|---------|----------|---------|
| `/specswarm:bugfix` | Fix bugs | `/specswarm:bugfix "Bug: Login fails"` |
| `/specswarm:hotfix` | Emergency fix | `/specswarm:hotfix "API down"` |
| `/specswarm:modify` | Change feature | `/specswarm:modify "Update cart logic"` |
| `/specswarm:refactor` | Improve code | `/specswarm:refactor "Optimize auth"` |
| `/specswarm:deprecate` | Remove feature | `/specswarm:deprecate "Old API v1"` |

### Quality & Analysis Commands

| Command | Use When | Example |
|---------|----------|---------|
| `/specswarm:analyze-quality` | Before merge | `/specswarm:analyze-quality` |
| `/specswarm:impact` | Assess changes | `/specswarm:impact "Update React"` |
| `/specswarm:clarify` | Refine spec | `/specswarm:clarify` |
| `/specswarm:analyze` | Validate artifacts | `/specswarm:analyze` |

### Planning Commands

| Command | Use When | Example |
|---------|----------|---------|
| `/specswarm:plan` | Design implementation | `/specswarm:plan` |
| `/specswarm:tasks` | Generate task list | `/specswarm:tasks` |
| `/specswarm:checklist` | Custom checklists | `/specswarm:checklist` |
| `/specswarm:constitution` | Project governance | `/specswarm:constitution` |

---

## Common Command Patterns

### Pattern 1: Quick Feature (Autonomous)

```bash
git checkout develop
/specswarm:suggest "add contact form"
/speclabs:orchestrate-feature "Add contact form with name, email, message fields, validation, and email sending" --validate
# → Responds to questions
# → Manual testing
/specswarm:analyze-quality
/specswarm:complete
```

### Pattern 2: Complex Feature (Manual)

```bash
git checkout develop
/specswarm:specify "Migrate to React Router v7"
/specswarm:clarify
/specswarm:plan
/specswarm:tasks
/specswarm:implement
# → Manual testing
/specswarm:analyze-quality
/specswarm:complete
```

### Pattern 3: Bug Fix with Regression Test

```bash
git checkout develop
/specswarm:bugfix "Bug: Cart total wrong when discount applied

Console: None
Terminal: None

Expected: $88 total (after discount + tax)
Actual: $90 total (tax before discount)

Steps:
1. Add $100 item
2. Apply 20OFF code
3. Checkout shows $90 instead of $88"

# → Manual testing
/specswarm:complete
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

### SpecLabs orchestrate-feature Flags

```bash
/speclabs:orchestrate-feature "description" [flags]

--validate              # Run Playwright browser testing
--audit                 # Run code audit
--skip-specify          # Skip spec generation
--skip-clarify          # Skip clarification
--skip-plan             # Skip planning
--max-retries N         # Max retries per task (default: 3)
```

**Common combinations**:
```bash
# Full autonomous with validation
/speclabs:orchestrate-feature "..." --validate

# Skip planning (plan.md exists)
/speclabs:orchestrate-feature "..." --skip-plan --validate

# Fast iteration
/speclabs:orchestrate-feature "..." --skip-clarify --validate
```

---

## Git Branch Workflow

```
main
  └─ develop
      └─ sprint-3
          └─ 015-feature-branch  ← You work here

# When complete:
/specswarm:complete
# → Merges 015-feature-branch → sprint-3
# → v3.3.3 shows merge plan BEFORE executing
```

**Important**: Always check out parent branch BEFORE starting feature!

```bash
# Correct:
git checkout sprint-3
/speclabs:orchestrate-feature "..."
# → Creates branch FROM sprint-3
# → Merges BACK TO sprint-3

# Wrong:
git checkout main  # ❌ Don't do this!
/speclabs:orchestrate-feature "..."
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
- Bundle Size: 20 pts
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

### ❌ "Orchestration pauses mid-execution"

```bash
# Fix: Update to v3.3.3+
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
- **[SpecLabs Docs](../plugins/speclabs/README.md)** - Autonomous features
- **[Changelog](../CHANGELOG.md)** - Version history
- **[GitHub Issues](https://github.com/MartyBonacci/specswarm/issues)** - Report bugs

---

## Version Information

This cheat sheet is for:
- **SpecSwarm**: v3.3.3
  - Natural language commands (build, fix, ship, upgrade)
  - Multi-language support (Python, PHP, Go, Ruby, Rust)
  - README.md context reading
  - 32 commands total (4 high-level + 28 granular)
  - Autonomous execution (no mid-phase pausing)
  - Parent branch safety

**Note**: SpecLabs is deprecated - all functionality consolidated into SpecSwarm v3.0+

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
