# SpecSwarm Portable - Limitations

This document explains the differences between SpecSwarm Portable and the full marketplace plugin version.

## Why These Limitations Exist

SpecSwarm Portable runs from your project's `.claude/commands/` directory, which provides slash command functionality but lacks the plugin infrastructure for advanced features.

The Claude Code plugin system provides:
- Skill-based natural language routing
- Confidence-based auto-execution
- Tool restrictions per skill
- Plugin detection and integration

These features require the marketplace plugin system and cannot be replicated in standalone `.claude/commands/` installations.

## Feature Comparison

| Feature | Plugin | Portable | Notes |
|---------|--------|----------|-------|
| **All 32+ Commands** | Yes | Yes | Full feature parity |
| **SlashCommand Chaining** | Yes | Yes | Commands can invoke other commands |
| **YAML Frontmatter Args** | Yes | Yes | Arguments work identically |
| **`$ARGUMENTS` Placeholder** | Yes | Yes | Same argument passing |
| **Natural Language Auto-Routing** | Yes | No | Use `/sw:router` instead |
| **Confidence-Based Execution** | Yes | No | Manual confirmation |
| **Skill Allowed-Tools** | Yes | No | All tools available |
| **Plugin Detection** | Yes | No | Cannot detect other plugins |
| **Semantic Keyword Matching** | Yes | No | Explicit commands only |

## Workarounds

### Natural Language Routing

**Plugin Version:**
```
User: "Build user authentication"
[Claude automatically detects intent and runs /specswarm:build]
```

**Portable Version:**
```bash
# Option 1: Use router command
/sw:router "build user authentication"
# [Router analyzes intent and suggests /sw:build]

# Option 2: Use command directly
/sw:build "user authentication"
```

### Skill-Based Safety

**Plugin Version:**
Skills have `allowed-tools` restrictions. For example, the ship skill can only use `AskUserQuestion` and `SlashCommand`, preventing accidental destructive operations.

**Portable Version:**
No automatic tool restrictions. Be careful with destructive commands. The `/sw:ship` command includes manual confirmation steps.

### Plugin Integration

**Plugin Version:**
Commands can detect other installed plugins:
```bash
SPECTEST_INSTALLED=$(claude plugin list | grep -q "spectest" && echo "true" || echo "false")
```

**Portable Version:**
This detection doesn't work. Orchestration features that depend on other plugins will run in "basic mode" without enhanced capabilities.

## Features That Work Identically

### Command Execution
All 32 original commands work exactly the same. The workflow logic, task generation, quality analysis, and all core functionality is preserved.

### Feature Artifacts
The `.specswarm/` directory structure is identical:
- `constitution.md`
- `tech-stack.md`
- `quality-standards.md`
- `features/NNN-slug/` directories

### Quality Gates
The `/sw:ship` command enforces the same quality thresholds as the plugin version.

### SlashCommand Chaining
Complex workflows like `/sw:build` that chain multiple commands work correctly:
```
/sw:build → /sw:specify → /sw:clarify → /sw:plan → /sw:tasks → /sw:implement → /sw:analyze-quality
```

## Limited Features

### Orchestration Commands
These commands have reduced functionality without Chrome DevTools MCP or Playwright:

- `/sw:orchestrate` - Runs in basic mode
- `/sw:orchestrate-feature` - Requires Playwright
- `/sw:orchestrate-validate` - Requires browser automation
- `/sw:validate` - Requires Chrome DevTools MCP

They will still execute but with limited browser automation capabilities.

### Plugin Detection Logic
Commands that check for other plugins will skip those features:

```bash
# This check won't work in portable mode
if [ "$SPECTEST_INSTALLED" = "true" ]; then
  # Enhanced parallel execution
else
  # Basic sequential execution (this path runs in portable)
fi
```

## Migration from Plugin

If you previously used the plugin version (`/specswarm:*`), here's what changes:

1. **Command prefix**: `/specswarm:` → `/sw:`
2. **Natural language**: No longer automatic, use `/sw:router`
3. **Skill triggers**: No auto-execution, use explicit commands

Your existing `.specswarm/` configuration and feature artifacts are fully compatible.

## When to Use Plugin vs Portable

**Use the Plugin** when:
- You want automatic natural language routing
- You need tool restrictions for safety
- You're using Claude Code CLI regularly
- You want plugin integration features

**Use Portable** when:
- Using Claude Code Web interface
- Need per-project installation
- Can't install marketplace plugins
- Want shorter command prefix (`/sw:` vs `/specswarm:`)
- Sharing projects with team members who don't have the plugin

## Questions?

- Documentation: https://github.com/MartyBonacci/specswarm
- Issues: https://github.com/MartyBonacci/specswarm/issues
