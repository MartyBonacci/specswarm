# SpecSwarm Quick Reference Cheat Sheet

**Fast reference for common SpecSwarm commands and workflows.**

**Version**: v7.17.0 | **Commands**: 21 visible + 11 internal = 32 total | **Language-Agnostic**

**TL;DR (v7.17.0):** `/ss:init` once, then `/ss:go "<feature>"` — the full ladder runs itself, pausing only for the assumptions review, the batched decision sheet, sighted gates, and the ship blessing (`/ss:ship`).

---

## Quick Installation

```bash
# Add the marketplace
/plugin marketplace add MartyBonacci/specswarm

# Install the plugin
/plugin install ss@specswarm-marketplace

# Verify
/plugin list
# Should show: ss v7.17.0
```

---

## Visual Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    PROJECT SETUP (Once)                     │
├─────────────────────────────────────────────────────────────┤
│  /ss:init                                            │
│  Create .specswarm/tech-stack.md                            │
│  Create .specswarm/quality-standards.md                     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              DEVELOPMENT WORKFLOWS                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  PROJECT SETUP: /ss:init                             │
│  FEATURE DEV:   /ss:build "feature"  (or NL)        │
│  BUG FIX:       /ss:fix "bug"                        │
│  MODIFICATION:  /ss:modify "change"                  │
│  SHIP:          /ss:ship                             │
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
  ├─ New Feature       → /ss:build "feature"
  │
  ├─ Bug Fix           → /ss:fix "bug"
  │   └─ Production?   → /ss:fix "bug" --hotfix
  │
  ├─ Code Improvement  → /ss:modify "change"
  │   ├─ Quality?      → /ss:modify "change" --refactor
  │   └─ Sunset?       → /ss:modify "change" --deprecate
  │
  ├─ Impact Analysis   → /ss:modify "change" --analyze-only
  │
  └─ Quality Check     → /ss:ship (includes quality gate)
```

---

## Command Quick Reference

### Core Commands (5)

| Command | Use When | Example |
|---------|----------|---------|
| `/ss:init` | Project setup | `/ss:init` |
| `/ss:build` | New feature | `/ss:build "Add user login"` |
| `/ss:fix` | Bug fix | `/ss:fix "Login fails on mobile"` |
| `/ss:modify` | Change feature | `/ss:modify "Update cart logic"` |
| `/ss:ship` | Finish & merge | `/ss:ship` |

### Core Variants (with flags)

| Command | Use When | Example |
|---------|----------|---------|
| `/ss:fix --hotfix` | Emergency fix | `/ss:fix "API down" --hotfix` |
| `/ss:modify --refactor` | Improve code | `/ss:modify "Optimize auth" --refactor` |
| `/ss:modify --deprecate` | Remove feature | `/ss:modify "Old API v1" --deprecate` |
| `/ss:modify --analyze-only` | Assess changes | `/ss:modify "Update React" --analyze-only` |
| `/ss:analyze-quality` | Quality check | `/ss:analyze-quality` |

### Autonomous Loop (v7.1.0–v7.17.0)

| Command | Since | Use When | Example |
|---------|-------|----------|---------|
| `/ss:go` | v7.17.0 | **Default entry point** — full ladder, ≤4 touchpoints | `/ss:go "Add contact form"` |
| `/ss:preflight` | v7.1.0 | Before `/ss:implement` — validate plan.md (7 checks) | `/ss:preflight` |
| `/ss:notify` | v7.2.0 | Fire a notification from any context | `/ss:notify --urgent "build broke"` |
| `/ss:intervention` | v7.3.0 | Capture "something feels off" moment | `/ss:intervention "plan says 43, spec says 47"` |
| `/ss:verify` | v7.4.0 | Adversarial verify a completed task | `/ss:verify T011` |
| `/ss:verify --sighted` | v7.14.0 | Human sign-off on a visual (NEEDS-SIGHTED) slice | `/ss:verify --sighted T012` |
| `/ss:retrospective` | v7.5.0 | Distill chunk lessons before /ss:ship | `/ss:retrospective` |
| `/ss:decisions` | v7.6.0 | Pre-batch strategic decisions | `/ss:decisions` |
| `/ss:dry-run` | v7.8.0 | Predict the chunk without running it | `/ss:dry-run` |
| `/ss:watchdog` | v7.9.0 | Background out-of-session monitor | `/ss:watchdog start` |
| `/ss:overnight` | v7.10.0 | Autonomous unattended chunk run | `/ss:overnight check` |
| `/ss:bakeoff` | v7.16.0 | Taste-heavy choice → N candidates → pinned winner | `/ss:bakeoff "hero palette" --candidates 3` |

**Env knobs (v7.13.0+):** `SPECSWARM_SLICE_GATES=block|warn|off` (per-task build+lint gate, default `block`) · `SPECSWARM_VERIFY_QUEUE_LIST_MAX` (Stop-hook list threshold, default 8)

---

## Common Command Patterns

### Pattern 0: The Full Ladder (v7.17.0 — recommended default)

```bash
/ss:go "Add contact form with name, email, message fields, validation, and email sending"
# → specify → assume-first clarify → plan → decisions → tasks → preflight
#   → implement (build+lint per task, verify queue drains) → retrospective
# You touch it exactly 4 times: kickoff, assumptions review + decision sheet
# (one sitting), sighted sign-off on visual slices, and:
/ss:ship   # ship blessing (batch-reviews any NEEDS-SIGHTED items)
# Abort the ladder any time: rm .specswarm/go-loop.state
```

### Pattern 1: Feature Development (pre-v7.17 ladder; still supported)

```bash
/ss:build "Add contact form with name, email, message fields, validation, and email sending"
# → Creates branch, specs, plans, implements, tests
# → Manual testing
/ss:ship
```

### Pattern 2: Bug Fix with Regression Test

```bash
/ss:fix "Bug: Cart total wrong when discount applied

Console: None
Terminal: None

Expected: $88 total (after discount + tax)
Actual: $90 total (tax before discount)

Steps:
1. Add $100 item
2. Apply 20OFF code
3. Checkout shows $90 instead of $88"

# → Manual testing
/ss:ship
```

### Pattern 3: Code Modification

```bash
/ss:modify "Migrate auth from session to JWT"
# → Manual testing
/ss:ship
```

### Pattern 4: Quality Check Before PR

```bash
# Before creating pull request
/ss:analyze-quality

# If score < 85, fix issues:
# - Add missing tests
# - Fix failing tests
# - Reduce bundle size

# Re-check
/ss:analyze-quality
```

### Pattern 5: Unattended Overnight Chunk (v7.10.0)

```bash
# Pre-batch decisions at 9pm
/ss:decisions

# Optional safety net
/ss:watchdog start

# Schedule via cron — /ss:overnight schedule prints snippets
# 0 22 * * 1-5  cd <repo> && bash lib/overnight/run.sh --allow-dirty

# Wake to phone notification; check verdict
/ss:overnight status
/ss:ship  # human sign-off + merge
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
/ss:build "description" [flags]

--validate              # Run Playwright browser testing
--audit                 # Run code audit
--skip-specify          # Skip spec generation
--skip-clarify          # Skip clarification
--skip-plan             # Skip planning
--max-retries N         # Max retries per task (default: 3)
```

### Fix Flags

```bash
/ss:fix "description" [flags]

--hotfix                # Emergency production fix (bypasses normal flow)
```

### Modify Flags

```bash
/ss:modify "description" [flags]

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
/ss:ship
# → Merges 015-feature-branch → sprint-3
# → Shows merge plan BEFORE executing
```

**Important**: Always check out parent branch BEFORE starting feature!

```bash
# Correct:
git checkout sprint-3
/ss:build "..."
# → Creates branch FROM sprint-3
# → Merges BACK TO sprint-3

# Wrong:
git checkout main
/ss:build "..."
# → Merges to main (bypasses sprint-3)
```

---

## Quality Score Guide

```
┌──────────────────────────────────────────────────────────┐
│  /ss:analyze-quality Score Interpretation         │
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
# Run /ss:complete again
```

### ❌ "Quality score too low"

```bash
# Fix: Check what's failing
/ss:analyze-quality

# Common fixes:
# - Add unit tests
# - Fix failing tests
# - Reduce bundle size (code splitting)
# - Fix TypeScript errors
```

### "Orchestration pauses mid-execution"

```bash
# Fix: Update to v7.0.0 or later
/plugin update ss

# Autonomous execution has been the default since v3.0;
# v7.6.0 added /ss:decisions to front-load any remaining
# strategic-decision interrupts into a single batch.
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
- **SpecSwarm**: v7.17.0
  - **32 commands** (21 visible + 11 internal)
  - **6 multi-agent subagents** with v7.7.0 explicit model assignments (5 opus, 1 haiku)
  - Natural language core (`build`, `fix`, `ship`, `modify`)
  - Language-agnostic
  - Autonomous execution (no mid-phase pausing)
  - Parent branch safety
  - External Reference Corpus consultation — v6.1.0
  - Memory-Driven Principle Import — v6.2.0
  - Constitution Severity Levels (warn | block) — v6.3.0
  - `/ss:init` reconciliation refactor — v6.4.0
  - Subagent-Driven Foundation File Generation — v7.0.0
  - **Autonomous Chunk Loop (v7.1.0–v7.10.0):** preflight, notify, intervention, verify (+ spec-mentor), retrospective (+ chunk-retrospective), decisions (+ decision-miner), dry-run (+ dry-run-simulator), watchdog daemon, overnight (cron/systemd/launchd)
  - **AUTO-MAGIC Epic (v7.13.0–v7.17.0):** taste model (distilled rulings that accrete automatically), assume-first clarify (provenance-cited `## Assumptions` ledger), per-task build+lint slice gates, NEEDS-SIGHTED gate on visual slices, ruling distiller (chunk N's catch fires in chunk N+1), overnight auto-resume, `/ss:bakeoff` calibration loop, `[DECIDED-BY-DATA]` markers, and `/ss:go` — the single entry point (≤4 human touchpoints per chunk)

Check your version:
```bash
/plugin list
```

Update plugin:
```bash
/plugin update ss
```

---

**Happy coding! Print this cheat sheet or keep it open in a tab.** 📋✨
