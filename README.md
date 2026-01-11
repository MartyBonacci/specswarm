# SpecSwarm v3.7.2

**Complete Software Development Toolkit**

Build, fix, maintain, and analyze your entire software project with one unified plugin.

---

## Overview

SpecSwarm is a comprehensive Claude Code plugin for the complete software development lifecycle across **6 languages** (JavaScript/TypeScript, Python, PHP, Go, Ruby, Rust):

- ✅ **Spec-Driven Development** - Specification to implementation
- 🐛 **Bug Management** - Systematic fixing with regression testing
- 🔧 **Code Maintenance** - Refactoring and feature modification
- 📊 **Quality Assurance** - Automated validation (0-100 scoring)
- 🚀 **Performance Monitoring** - Bundle size tracking and budgets
- 🌐 **Multi-Language Support** - Auto-detection for 6 languages
- 🗣️ **Natural Language** - Talk to SpecSwarm like a teammate

**5 Core Commands** + **27 Advanced** | **Production Ready**

---

## Installation

```bash
/plugin install MartyBonacci/specswarm
```

Restart Claude Code to activate the plugin.

### Portable Installation (Claude Code Web)

For Claude Code Web or per-project installation **without the marketplace plugin**:

```bash
curl -fsSL https://raw.githubusercontent.com/MartyBonacci/specswarm/main/portable/install.sh | bash
```

**Important:** Portable version uses a **different command prefix** than the marketplace plugin:
- **Marketplace plugin:** `/specswarm:build`, `/specswarm:fix`, `/specswarm:ship`
- **Portable version:** `/sw:build`, `/sw:fix`, `/sw:ship` (shorter prefix)

You use **one OR the other**, not both simultaneously.

**See details:** [portable/README.md](./portable/README.md)

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

These 5 commands handle **95% of daily development work**.

### 1. `/specswarm:init`

**Initialize SpecSwarm in your project**

```bash
/specswarm:init
```

Creates `.specswarm/` directory with:
- `tech-stack.md` - Prevent technology drift (95% effective)
- `quality-standards.md` - Quality gates and budgets
- `constitution.md` - Project governance

**Use when:** First-time project setup

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
5. Detects chain bugs
6. Auto-retries on failure (max 2 attempts)

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
- NOT for code quality (use `/specswarm:refactor`)

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

### Confidence-Based Execution

SpecSwarm analyzes your request and acts accordingly:

- **High Confidence (95%+):** Auto-executes with 3-second cancel window
- **Medium Confidence (70-94%):** Asks for confirmation first
- **Low Confidence (<70%):** Shows options to choose from

### Safety Features

🛡️ **SHIP Protection:** SHIP commands **ALWAYS** require explicit confirmation, regardless of confidence

⚡ **3-Second Cancel:** High-confidence commands show 3s cancel window (press Ctrl+C)

🎯 **Slash Commands Still Work:** All slash commands work exactly as before

---

## Advanced Commands (27)

For power users and specialized workflows.

**See complete documentation:** [COMMANDS.md](./COMMANDS.md)

**Quick reference:**

- **New Features**: `/specswarm:specify`, `/specswarm:plan`, `/specswarm:tasks`, `/specswarm:implement`, `/specswarm:clarify`, `/specswarm:checklist`, `/specswarm:analyze`, `/specswarm:constitution`

- **Bug Management**: `/specswarm:bugfix`, `/specswarm:hotfix`, `/specswarm:coordinate`

- **Maintenance**: `/specswarm:refactor`, `/specswarm:deprecate`

- **Quality & Analysis**: `/specswarm:analyze-quality`, `/specswarm:impact`, `/specswarm:suggest`, `/specswarm:metrics`, `/specswarm:metrics-export`, `/specswarm:validate`

- **Lifecycle**: `/specswarm:release`, `/specswarm:security-audit`, `/specswarm:rollback`, `/specswarm:upgrade`, `/specswarm:complete`

- **Orchestration**: `/specswarm:orchestrate`, `/specswarm:orchestrate-feature`, `/specswarm:orchestrate-validate`

---

## Key Features

### Quality Validation (0-100 Points)

Automated scoring across 6 dimensions:

- **Unit Tests** (25 pts) - Proportional by pass rate
- **Code Coverage** (25 pts) - Proportional by coverage %
- **Integration Tests** (15 pts) - API/service testing
- **Browser Tests** (15 pts) - E2E user flows
- **Bundle Size** (20 pts) - Performance budgets
- **Visual Alignment** (15 pts) - Future

**See details:** [Features: Quality System](./docs/FEATURES.md#quality-validation-system)

### Tech Stack Management

**95% drift prevention** through automatic validation:

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

### SSR Pattern Validation

Detects production failures before deployment:

- Hardcoded URLs in loaders/actions
- Relative URLs in SSR contexts
- Browser-only APIs on server
- React Router v7 / Remix / Next.js support

**See details:** [Features: SSR Patterns](./docs/FEATURES.md#ssr-pattern-validation)

### Chain Bug Detection

Prevents cascading failures by comparing test counts before/after fixes:

- Detects new test failures
- Flags new SSR issues
- Catches TypeScript errors
- Stops Bug 912→913 scenarios

**See details:** [Features: Chain Bugs](./docs/FEATURES.md#chain-bug-detection)

### Bundle Size Monitoring

Automatic performance tracking:

- Analyzes production bundles
- Calculates size score (0-20 points)
- Enforces configurable budgets
- Supports Vite, Webpack, Rollup, esbuild, Parcel

**See details:** [Features: Bundle Size](./docs/FEATURES.md#bundle-size-monitoring)

### Multi-Language Support

Supports **6 languages** with auto-detection:

- JavaScript/TypeScript (Vitest, Jest, Mocha, Jasmine)
- Python (Pytest, unittest)
- Go (go test)
- Ruby (RSpec)
- PHP (PHPUnit)
- Rust (cargo test)
- Java (JUnit)

**See details:** [Features: Multi-Language](./docs/FEATURES.md#multi-language-support)

---

## Configuration

### Recommended: Use `/specswarm:init`

The easiest way to configure SpecSwarm with interactive prompts.

### Manual Configuration

Create these files in your project:

**Tech Stack (`.specswarm/tech-stack.md`):**
```markdown
## Core Technologies
- Your framework here

## Approved Libraries
- Your libraries here

## Prohibited
- ❌ Things to avoid (with reasons)
```

**Quality Standards (`.specswarm/quality-standards.md`):**
```yaml
---
min_test_coverage: 85
min_quality_score: 80
enforce_budgets: true
max_bundle_size: 500  # KB
---
```

**See details:** [Setup Guide](./docs/SETUP.md)

---

## Optional: Chrome DevTools MCP

For **web projects** only (React, Vue, Next.js, etc.):

```bash
claude mcp add ChromeDevTools/chrome-devtools-mcp
```

**Benefits:**
- ✅ Real-time console monitoring
- ✅ Network request inspection
- ✅ Saves ~200MB (no Chromium download)

**Auto-detected** - SpecSwarm uses it automatically when available.

**See details:** [Setup: Chrome DevTools](./docs/SETUP.md#optional-integrations)

---

## Best Practices

1. **Run `/specswarm:init` first** - Sets up proper foundation
2. **Define tech-stack.md early** - Prevents 95% of drift
3. **Enable quality gates** - Maintain >80% scores
4. **Run `/specswarm:analyze-quality` before shipping** - Catch issues early
5. **Keep bundles <500KB** - Performance matters
6. **Use natural language** - Faster workflows

---

## Documentation

- **[Commands Reference](./COMMANDS.md)** - All 32 commands documented
- **[Setup Guide](./docs/SETUP.md)** - Configuration and troubleshooting
- **[Features Deep-Dive](./docs/FEATURES.md)** - Technical feature details
- **[Documentation Index](./docs/README.md)** - Navigate all docs

---

## Troubleshooting

### Quality Validation Not Running

Create `.specswarm/quality-standards.md` or run `/specswarm:init`

### SSR Validation Fails

Use environment-aware helper:

```typescript
export function getApiUrl(path: string): string {
  const base = typeof window !== 'undefined'
    ? ''
    : process.env.API_BASE_URL || 'http://localhost:3000';
  return `${base}${path}`;
}
```

### Bundle Size Exceeds Budget

1. Implement code splitting
2. Use dynamic imports
3. Analyze: `npx vite-bundle-visualizer`
4. Remove unused dependencies

**See more:** [Setup: Troubleshooting](./docs/SETUP.md#troubleshooting)

---

## Version History

### v3.7.2 (2026-01-11) - Plugin Installation Fix 🔧
- **Fixed**: Plugin installation error `Plugin 'specswarm' not found in marketplace 'specswarm-marketplace'`
- **Fixed**: Removed circular `marketplace.json` configuration (SpecSwarm is a standalone plugin)
- **Added**: `hooks/hooks.json` manifest for proper stop hook registration
- **Impact**: Plugin now installs correctly via `/plugin install MartyBonacci/specswarm`

### v3.7.1 (2026-01-08) - Build Pause Fix 🔧
- **Fixed**: `/specswarm:build` pausing between phases despite stop hook
- **Fixed**: Build would complete specify → clarify → plan → tasks, then pause instead of continuing
- **Added**: "CRITICAL EXECUTION RULE" section enforcing continuous execution
- **Added**: Explicit "DO NOT PAUSE" directives after each SlashCommand execution
- **Impact**: Build now runs continuously from start to finish (except clarify questions)
- **Impact**: No more unexpected pauses requiring manual "continue" prompting
- **Impact**: Fully autonomous execution as originally designed in v3.7.0

### v3.7.0 (2026-01-07) - Continuous Execution + Clarify UX ⭐
- **New**: SpecSwarm Stop Hook for autonomous build execution
- **New**: `/specswarm:build` now executes continuously without pauses
- **New**: Automatic phase progression based on artifact detection
- **New**: Self-correcting quality loop (retries until threshold met)
- **Improved**: Clarify command now uses AskUserQuestion tool
- **Improved**: Reduced keystrokes from ~10 to 1-2 per clarification question
- **Improved**: Professional structured UI with arrow key navigation
- **Impact**: Zero manual intervention for build workflow (except clarify questions)
- **Impact**: 80-90% faster question answering
- **Inspiration**: Based on Ralph Wiggum plugin's autonomous loop pattern

### v3.5.0 (2025-11-19) - 5th Core Workflow ⭐
- **New**: `/specswarm:modify` natural language skill (5th core workflow)
- **New**: Modify skill for changing working features (not bugs, not refactors)
- **Improved**: Documentation restructure - README simplified from 670 to 400 lines
- **New**: COMMANDS.md - Complete 32-command reference
- **New**: docs/SETUP.md - Technical setup and configuration guide
- **New**: docs/FEATURES.md - Technical features deep-dive
- **New**: docs/README.md - Documentation index
- **Impact**: Completes 5-core-command vision (init, build, fix, modify, ship)
- **UX**: Reduced cognitive load for new users (40% fewer lines in README)
- **DX**: Advanced features discoverable via separate documentation

### v3.4.0 (2025-11-18) - Confidence-Based Execution ⭐
- **New**: Confidence-based auto-execution for build/fix/upgrade (95%+ = auto-execute)
- **New**: Expanded fix skill triggers ("not showing up", "not appearing", etc.)
- **Enhanced**: SHIP always confirms with crystal clear destructive operation warning
- **Improved**: Semantic understanding - triggers on intent, not just keywords
- **UX**: 3-second cancel window for high-confidence commands
- **Safety**: Ship protection - ALWAYS requires explicit confirmation regardless of confidence

### v3.3.9 (2025-11-18) - MANDATORY/ALWAYS Directive Descriptions
- **Fixed**: Description language - removed conflicting MANDATORY + ALWAYS directives
- **Changed**: Authoritative descriptions without override conflicts
- **Impact**: Skills now properly respect confirmation instructions

### v3.3.8 (2025-11-18) - Directory Name Matching
- **CRITICAL FIX**: Renamed skill directories to match skill names exactly
- **Changed**: `skills/build/` → `skills/specswarm-build/`
- **Impact**: Skills now load and trigger correctly

### v3.3.1 (2025-11-18) - Natural Language Bug Fix 🔧
- **Fixed**: Natural language commands now work via Skills architecture
- **Added**: Skills directory with build/fix/ship/upgrade SKILL.md files
- **Impact**: Natural language actually works - "build auth" triggers `/specswarm:build`

### v2.1.2 (2025-11-04) - Git Workflow Safety ⭐
- **New**: Branch confirmation prompts during feature creation
- **Enhanced**: Parent branch detection with robust fallback
- **Safety**: Prevents accidental merges to wrong branches

### v2.0.0 (2025-10-15) - Major Consolidation
- Merged SpecLab lifecycle workflows
- Added chain bug detection
- Added bundle size monitoring
- Complete lifecycle coverage

**See full history:** [README: Version History](./README.md#version-history)

---

## Attribution

### Forked From

SpecSwarm builds upon **SpecKit**, which adapted **GitHub's spec-kit** for Claude Code.

**Attribution Chain:**

1. **Original**: [GitHub spec-kit](https://github.com/github/spec-kit)
   - Copyright (c) GitHub, Inc. | MIT License
   - Spec-Driven Development methodology

2. **Adapted**: SpecKit plugin by Marty Bonacci (2025)
   - Claude Code integration

3. **Enhanced**: SpecSwarm v3.7.2 by Marty Bonacci & Claude Code (2025-2026)
   - Tech stack management (95% drift prevention)
   - Lifecycle workflows (build, fix, modify, ship, upgrade)
   - Quality validation (0-100 scoring)
   - Natural language commands
   - Chain bug detection
   - Bundle size monitoring

---

## License

MIT License - See LICENSE file for details

---

## Support

- **Repository**: https://github.com/MartyBonacci/specswarm
- **Issues**: https://github.com/MartyBonacci/specswarm/issues
- **Documentation**: [docs/README.md](./docs/README.md)

---

**SpecSwarm v3.7.2** - Your complete software development toolkit. 🚀

Build it. Fix it. Modify it. Ship it. All in one place.
