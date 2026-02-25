---
description: SpecSwarm Portable quick reference and workflow guide
---

## SpecSwarm Portable - Quick Reference

Display this help guide with command overview and usage examples.

---

## Core Workflows (95% of daily use)

| Command | Purpose | Example |
|---------|---------|---------|
| `/sw:init` | Initialize project | `/sw:init` |
| `/sw:build` | Build new feature | `/sw:build "user auth"` |
| `/sw:fix` | Fix bugs | `/sw:fix "login broken"` |
| `/sw:modify` | Change existing feature | `/sw:modify "add pagination"` |
| `/sw:ship` | Merge & complete | `/sw:ship` |

---

## Natural Language Routing

Use `/sw:router` to auto-detect the right command:

```
/sw:router "build a payment system"
--> Recommends: /sw:build "payment system"

/sw:router "the login is broken"
--> Recommends: /sw:fix "login is broken"
```

---

## All Commands

### Core Workflow (10 visible commands)

| Command | Description |
|---------|-------------|
| `/sw:init` | Project setup (constitution, tech-stack, quality standards) |
| `/sw:build` | Full feature pipeline (specify→plan→tasks→implement→quality) |
| `/sw:fix` | Bug/hotfix workflow with test-driven approach and auto-retry |
| `/sw:modify` | Feature modification with impact analysis |
| `/sw:ship` | Quality-gated merge to parent branch |
| `/sw:release` | Version bump + changelog + tag + publish |
| `/sw:upgrade` | Dependency/framework upgrades with compatibility analysis |
| `/sw:rollback` | Undo a failed feature safely |
| `/sw:status` | Check background session progress |
| `/sw:metrics` | Feature analytics dashboard (`--export` for CSV) |

### Internal Commands (callable directly for re-running steps)

| Command | Called By |
|---------|-----------|
| `/sw:specify` | `build` (Step 2) |
| `/sw:clarify` | `build` (Step 3) |
| `/sw:plan` | `build` (Step 4) |
| `/sw:tasks` | `build` (Step 5) |
| `/sw:implement` | `build` (Step 6) |
| `/sw:validate` | `build --validate` |
| `/sw:analyze-quality` | `build` (Step 8), `ship` (Step 2) |
| `/sw:bugfix` | `fix` (internal) |
| `/sw:hotfix` | `fix --hotfix` (internal) |
| `/sw:complete` | `ship` (internal) |
| `/sw:constitution` | `init` (internal) |

---

## Project Files

SpecSwarm creates and uses these files:

```
.specswarm/
  constitution.md        # Project governance & principles
  tech-stack.md          # Approved technologies
  quality-standards.md   # Quality gates & thresholds
  features/              # Feature artifacts
    NNN-slug/
      spec.md            # Feature specification
      plan.md            # Implementation plan
      tasks.md           # Task breakdown
```

---

## Getting Started

### New Project
```bash
/sw:init                           # Initialize configuration
/sw:build "your first feature"     # Build something
/sw:ship                           # Merge when ready
```

### Fixing Bugs
```bash
/sw:fix "bug description"          # Standard fix
/sw:fix "bug" --regression-test    # Create test first
/sw:fix "bug" --hotfix             # Production emergency
```

### Modifying Features
```bash
/sw:modify "add pagination to API"
# Impact analysis runs automatically
```

---

## Flags & Options

### Build Flags
- `--validate` - Run browser validation after implementation
- `--quality-gate N` - Set minimum quality score (default: 80)
- `--orchestrate` - Force multi-agent parallel execution
- `--no-orchestrate` - Force sequential execution
- `--analyze` - Run cross-artifact consistency analysis
- `--checklist` - Generate requirements validation checklist
- `--background` - Run in background mode

### Fix Flags
- `--regression-test` - Create failing test first (TDD)
- `--hotfix` - Expedited workflow for production
- `--max-retries N` - Retry attempts (default: 2)
- `--coordinate` - Multi-bug orchestrated debugging
- `--background` - Run in background mode

### Modify Flags
- `--refactor` - Behavior-preserving quality improvement
- `--deprecate` - Phased feature sunset with migration guidance
- `--analyze-only` - Impact analysis without implementation

### Ship Flags
- `--force-quality N` - Override quality threshold
- `--skip-tests` - Skip test validation (not recommended)
- `--security-audit` - Comprehensive security scan before merge

### Init Flags
- `--minimal` - Use defaults without prompts
- `--skip-detection` - Manual tech stack entry

### Metrics Flags
- `--export` - Export metrics to CSV
- `--feature N` - Show details for feature N
- `--sprint NAME` - Sprint aggregate view

---

## Tips

1. **Start with `/sw:init`** to set up project governance
2. **Use `/sw:router`** if unsure which command to use
3. **Quality gates** prevent low-quality code from merging
4. **Feature branches** isolate work automatically
5. **Run `/sw:help`** anytime for this reference

---

## Portable Version Notes

This is SpecSwarm Portable - installed in your project's `.claude/` directory.

**Differences from plugin version:**
- Commands use `/sw:` prefix (shorter)
- No automatic natural language routing (use `/sw:router`)
- 10 visible commands + 11 internal commands available

**Update:** Run `/sw:update` to check for new versions.

**Documentation:** https://github.com/MartyBonacci/specswarm
