# SpecSwarm v5.1.0

**Complete Software Development Toolkit**

Build, fix, maintain, and analyze your entire software project with one unified plugin.

---

## Overview

SpecSwarm is a comprehensive Claude Code plugin for the complete software development lifecycle across **any language or framework** Claude supports:

- ✅ **Spec-Driven Development** - Specification to implementation
- 🐛 **Bug Management** - Systematic fixing with regression testing
- 🔧 **Code Maintenance** - Refactoring and feature modification
- 📊 **Quality Assurance** - Automated validation (0-100 scoring)
- 🗣️ **Natural Language** - Talk to SpecSwarm like a teammate

**10 Commands** | **Production Ready**

---

## Installation

```bash
# 1. Add the marketplace
/plugin marketplace add MartyBonacci/specswarm

# 2. Install the plugin
/plugin install specswarm@specswarm-marketplace
```

Restart Claude Code to activate the plugin.

---

## Quick Start

### One-Command Workflow

```bash
# Initialize your project
/specswarm:init
```

**That's it!** Now you can use natural language:

```
"Build user authentication with JWT"
"Fix the login button on mobile"
"Change authentication from session to JWT"
"Ship this feature"
```

SpecSwarm automatically runs the right workflow based on your intent.

---

## Core Commands

These 5 commands handle the vast majority of daily development work.

### 1. `/specswarm:init`

**Initialize SpecSwarm in your project**

```bash
/specswarm:init
```

Creates `.specswarm/` directory with:
- `tech-stack.md` - Prevent technology drift
- `quality-standards.md` - Quality gates and budgets
- `constitution.md` - Project governance

**Use when:** First-time project setup, or to refresh tech-stack and constitution after external changes

---

### 2. `/specswarm:build`

**Build new features from specification to implementation**

```bash
/specswarm:build "feature description"
```

**Natural language:**
```
"Build user authentication with JWT"
"Create a payment processing system"
"Add dashboard analytics"
```

**Complete workflow:**
1. Creates specification
2. Asks clarifying questions
3. Generates implementation plan
4. Breaks down into tasks
5. Implements all tasks
6. Validates quality (0-100 score)

**Quick mode** for small tasks:
```bash
/specswarm:build "add loading spinner" --quick
```
Skips clarification, auto-generates micro-spec, and executes immediately.

**Use when:** Building any new feature

---

### 3. `/specswarm:fix`

**Fix bugs with regression testing and auto-retry**

```bash
/specswarm:fix "bug description"
```

**Natural language:**
```
"Fix the login button on mobile"
"Images don't load"
"Tailwind styles not showing up"
```

**Complete workflow:**
1. Creates regression test
2. Analyzes root cause
3. Implements fix
4. Validates with tests
5. Auto-retries on failure (max 2 attempts)

**Use when:** Fixing any bug or broken functionality

---

### 4. `/specswarm:modify`

**Change existing feature behavior with impact analysis**

```bash
/specswarm:modify "modification description"
```

**Natural language:**
```
"Change authentication from session to JWT"
"Add pagination to user list API"
"Update search to use full-text search"
```

**Complete workflow:**
1. Analyzes impact on existing code
2. Identifies breaking changes
3. Creates migration plan
4. Updates specification and plan
5. Implements modifications
6. Validates against regression tests

**Use when:**
- Features that work but need to work differently
- NOT for bugs (use `/specswarm:fix`)
- NOT for code quality (use `/specswarm:modify "..." --refactor`)

---

### 5. `/specswarm:ship`

**Validate quality, merge to parent branch, and complete feature**

```bash
/specswarm:ship
```

**Natural language:**
```
"Ship this feature"  ⚠️ (requires confirmation)
"Deploy to production"  ⚠️ (requires confirmation)
```

**Complete workflow:**
1. Runs comprehensive quality analysis
2. Checks quality threshold (default 80%)
3. Shows merge plan with confirmation
4. Merges to parent branch
5. Deletes feature branch

⚠️ **DESTRUCTIVE OPERATION** - Always requires explicit "yes" confirmation

**Use when:**
- Feature is complete and tested
- Quality score meets threshold
- Ready to merge to main/production

---

## Natural Language Commands

### Just Talk to SpecSwarm

Instead of memorizing slash commands, describe what you want in plain English:

**Build a Feature:**
```
"Build user authentication with JWT"
"Create a payment processing system"
```

**Fix a Bug:**
```
"Fix the login button"
"Images don't load"
"Styles not showing up"
```

**Modify Existing Features:**
```
"Change authentication to use JWT"
"Add pagination to the API"
```

**Ship Features:**
```
"Ship this feature"  ⚠️ (always requires confirmation)
"Merge to main"  ⚠️ (always requires confirmation)
```

### Skill-Based Routing

SpecSwarm uses keyword matching to route natural language to the right workflow:

- **Clear intent** (e.g., "build", "fix", "ship"): Routes directly to the matching command
- **Ambiguous intent**: Asks for clarification before proceeding

### Safety Features

🛡️ **SHIP Protection:** SHIP commands **ALWAYS** require explicit confirmation — destructive operations are never auto-executed

🎯 **Slash Commands Still Work:** All slash commands work exactly as before

---

## Additional Commands

Beyond the 5 core commands, SpecSwarm provides 5 more visible commands for distinct workflows:

| Command | Purpose |
|---------|---------|
| `/specswarm:release` | Version bump + changelog + tag + publish |
| `/specswarm:upgrade` | Dependency/framework upgrades with compatibility analysis |
| `/specswarm:rollback` | Undo a failed feature safely |
| `/specswarm:status` | Check background session progress |
| `/specswarm:metrics` | Feature analytics dashboard (`--export` for CSV) |

### Flags on Core Commands

Many workflows that were previously separate commands are now flags:

| Flag | On Command | Replaces |
|------|-----------|----------|
| `--analyze` | `build` | Cross-artifact consistency analysis |
| `--checklist` | `build` | Requirements validation checklist |
| `--coordinate` | `fix` | Multi-bug orchestrated debugging |
| `--refactor` | `modify` | Behavior-preserving quality improvement |
| `--deprecate` | `modify` | Phased feature sunset |
| `--analyze-only` | `modify` | Impact analysis without implementation |
| `--security-audit` | `ship` | Comprehensive security scan before merge |

### Internal Commands

11 commands are available for re-running individual steps but hidden from the main listing:

`specify`, `clarify`, `plan`, `tasks`, `implement`, `validate`, `analyze-quality`, `bugfix`, `hotfix`, `complete`, `constitution`

**See complete documentation:** [COMMANDS.md](./COMMANDS.md)

### `/ss:` Shortcuts

For faster typing, every visible command has a short alias:

| Shortcut | Equivalent |
|----------|-----------|
| `/ss:build` | `/specswarm:build` |
| `/ss:fix` | `/specswarm:fix` |
| `/ss:modify` | `/specswarm:modify` |
| `/ss:ship` | `/specswarm:ship` |
| `/ss:init` | `/specswarm:init` |
| `/ss:release` | `/specswarm:release` |
| `/ss:upgrade` | `/specswarm:upgrade` |
| `/ss:rollback` | `/specswarm:rollback` |
| `/ss:status` | `/specswarm:status` |
| `/ss:metrics` | `/specswarm:metrics` |

All flags work identically: `/ss:build "feature" --quick`

---

## Key Features

### Quality Validation (0-100 Points)

Automated scoring across 4 dimensions:

- **Unit Tests** (30 pts) - Proportional by pass rate
- **Code Coverage** (30 pts) - Proportional by coverage %
- **Integration Tests** (20 pts) - API/service testing
- **Browser Tests** (20 pts) - E2E user flows

**See details:** [Features: Quality System](./docs/FEATURES.md#quality-validation-system)

### Tech Stack Management

**Drift prevention** through automatic validation:

```markdown
# .specswarm/tech-stack.md
## Core Technologies
- React Router v7
- PostgreSQL 17.x

## Approved Libraries
- Zod v4+ (validation)

## Prohibited
- ❌ Redux (use React Router loaders/actions)
```

SpecSwarm validates at plan, task, and implementation phases.

**See details:** [Features: Tech Stack](./docs/FEATURES.md#tech-stack-management)

### Language Agnostic

SpecSwarm's core workflow (specify, clarify, plan, tasks, implement, ship) works with **any language or framework** Claude can read. There is no language-specific tooling — Claude handles the code understanding and generation.

The quality analysis step includes test runner detection for common frameworks (Vitest, Jest, Pytest, go test, RSpec, PHPUnit, cargo test, JUnit) as a convenience for automated scoring.

---

## Best Practices

1. **Run `/specswarm:init` first** - Sets up proper foundation
2. **Define tech-stack.md early** - Prevents technology drift
3. **Enable quality gates** - Maintain >80% scores
4. **Run quality analysis before shipping** - Catch issues early
5. **Keep bundles <500KB** - Performance matters
6. **Use natural language** - Faster workflows

---

## Documentation

- **[Commands Reference](./COMMANDS.md)** - All 21 commands documented
- **[Setup Guide](./docs/SETUP.md)** - Configuration and troubleshooting
- **[Features Deep-Dive](./docs/FEATURES.md)** - Technical feature details
- **[Documentation Index](./docs/README.md)** - Navigate all docs

---

## Troubleshooting

### Quality Validation Not Running

Create `.specswarm/quality-standards.md` or run `/specswarm:init`

**See more:** [Setup: Troubleshooting](./docs/SETUP.md#troubleshooting)

---

## Version History

### v5.1.0 (2026-03-22) - Audit Fix & Documentation Update 🔧
- **Fixed**: Hardcoded paths in build.md, validate.md, implement.md that broke for all non-author users
- **Fixed**: 7 phantom command references pointing to commands removed in v4.0.0
- **Fixed**: 10 missing lib file sources now wrapped in `if [ -f ]` guards for graceful degradation
- **Fixed**: All stale "speclabs" references replaced with "specswarm"
- **Fixed**: Wrong skill/command counts in docs
- **Added**: Deprecation notice on portable installation
- **Added**: `/ss:` shortcut aliases for all 10 visible commands
- **Added**: `--quick` flag on `/specswarm:build` for small tasks
- **Impact**: Plugin now works correctly for all users, not just the author

### v5.0.0 (2026-03-20) - Effort Frontmatter & 5 New Skills ⭐
- **New**: 5 natural language skills (status, rollback, release, init, metrics) — 10 total
- **New**: Effort frontmatter on all 21 commands for smarter resource allocation
- **New**: Conditional rules for active builds and feature branches
- **New**: Dynamic context injection in build/fix/ship/status skills
- **Changed**: Status and metrics commands use lighter model for faster execution
- **Changed**: Orchestrator agent has guardrails (maxTurns, disallowedTools)
- **Impact**: Better performance, lower cost, same workflow

### v4.0.1 (2026-02-27) - Documentation & State Management Fix 🔧
- **Fixed**: Memory/state management flaws in build loop
- **Fixed**: README documentation discrepancies — honest feature claims, language-agnostic framing
- **Removed**: Overclaimed metrics ("95% drift prevention", unsubstantiated confidence percentages)
- **Removed**: Unimplemented feature placeholders (Chain Bug Detection, SSR Validation, Bundle Size Monitoring)
- **Impact**: README now accurately reflects implemented functionality

**See full history:** [CHANGELOG.md](./CHANGELOG.md)

---

## Attribution

### Inspired By

SpecSwarm is inspired by **GitHub's spec-kit** Spec-Driven Development methodology.

**Attribution Chain:**

1. **Original**: [GitHub spec-kit](https://github.com/github/spec-kit)
   - Copyright (c) GitHub, Inc. | MIT License
   - Spec-Driven Development methodology

2. **Adapted**: SpecKit plugin by Marty Bonacci (2025)
   - Claude Code integration

3. **Enhanced**: SpecSwarm v5.0.0 by Marty Bonacci & Claude Code (2025-2026)
   - Tech stack drift prevention
   - Lifecycle workflows (build, fix, modify, ship, upgrade)
   - Quality validation (0-100 scoring)
   - Natural language commands

---

## Portable Installation (Deprecated)

> **Note:** The portable installation is deprecated and no longer maintained. Use the marketplace plugin above.

For legacy per-project installation:

```bash
curl -fsSL https://raw.githubusercontent.com/MartyBonacci/specswarm/main/portable/install.sh | bash
```

**Important:** Portable version uses a **different command prefix** than the marketplace plugin:
- **Marketplace plugin:** `/specswarm:build`, `/specswarm:fix`, `/specswarm:ship`
- **Portable version:** `/sw:build`, `/sw:fix`, `/sw:ship` (shorter prefix)

**See details:** [portable/LIMITATIONS.md](./portable/LIMITATIONS.md)

---

## License

MIT License - See LICENSE file for details

---

## Support

- **Repository**: https://github.com/MartyBonacci/specswarm
- **Issues**: https://github.com/MartyBonacci/specswarm/issues
- **Documentation**: [docs/README.md](./docs/README.md)

---

**SpecSwarm v5.1.0** - Your complete software development toolkit. 🚀

Build it. Fix it. Modify it. Ship it. All in one place.
