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

## All Commands by Category

### Feature Development
| Command | Description |
|---------|-------------|
| `/sw:specify` | Create feature specification |
| `/sw:clarify` | Ask clarification questions |
| `/sw:plan` | Generate implementation plan |
| `/sw:tasks` | Generate task breakdown |
| `/sw:implement` | Execute all tasks |
| `/sw:checklist` | Generate validation checklist |
| `/sw:analyze` | Analyze feature artifacts |

### Bug Management
| Command | Description |
|---------|-------------|
| `/sw:bugfix` | Fix a specific bug |
| `/sw:hotfix` | Expedited production fix |
| `/sw:coordinate` | Multi-agent debugging |

### Quality & Analysis
| Command | Description |
|---------|-------------|
| `/sw:analyze-quality` | Comprehensive quality report |
| `/sw:impact` | Impact analysis for changes |
| `/sw:suggest` | Workflow recommendations |
| `/sw:validate` | Browser validation (Playwright) |
| `/sw:security-audit` | Security vulnerability scan |

### Maintenance
| Command | Description |
|---------|-------------|
| `/sw:refactor` | Metrics-driven refactoring |
| `/sw:deprecate` | Phased feature sunset |
| `/sw:upgrade` | Dependency/framework upgrade |

### Lifecycle
| Command | Description |
|---------|-------------|
| `/sw:complete` | Merge to parent branch |
| `/sw:release` | Create release with validation |
| `/sw:rollback` | Revert changes safely |

### Configuration
| Command | Description |
|---------|-------------|
| `/sw:constitution` | Create project governance |
| `/sw:metrics` | View workflow analytics |
| `/sw:metrics-export` | Export metrics to CSV |

### Orchestration
| Command | Description |
|---------|-------------|
| `/sw:orchestrate` | Automated workflow |
| `/sw:orchestrate-feature` | Feature-level orchestration |
| `/sw:orchestrate-validate` | Validation orchestration |

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

### Fix Flags
- `--regression-test` - Create failing test first (TDD)
- `--hotfix` - Expedited workflow for production
- `--max-retries N` - Retry attempts (default: 2)

### Ship Flags
- `--force-quality N` - Override quality threshold
- `--skip-tests` - Skip test validation (not recommended)

### Init Flags
- `--minimal` - Use defaults without prompts
- `--skip-detection` - Manual tech stack entry

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
- All 32 commands available

**Update:** Run `/sw:update` to check for new versions.

**Documentation:** https://github.com/MartyBonacci/specswarm
