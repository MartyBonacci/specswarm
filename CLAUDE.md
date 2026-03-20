# CLAUDE.md — SpecSwarm

## Overview

SpecSwarm is a Claude Code plugin providing spec-driven development workflows: Build, Modify, Fix, Ship. It includes 21 commands, 10 natural language skills, and 2 agents for multi-agent orchestration.

## Development

### Plugin Validation (required before commits)

```bash
claude plugin validate plugins/specswarm/
```

Run this after any change to command/skill/agent frontmatter or plugin.json. It catches YAML typos that would silently fail at runtime.

### Version Bumping

Both files must be bumped in sync:
1. `plugins/specswarm/.claude-plugin/plugin.json` — `version`
2. `marketplace.json` — `plugins[0].version`

### Testing After Changes

1. Restart Claude Code (skill prompts are cached per session)
2. Run `/skills` to verify all 10 skills appear
3. Test a low-effort command (`/specswarm:status`) vs high-effort (`/specswarm:build`)

## Project Structure

```
plugins/specswarm/
├── commands/        # 21 slash commands (.md)
├── skills/          # 10 natural language skills (SKILL.md)
├── agents/          # 2 agents (orchestrator, task-router)
├── hooks/           # Setup and stop hooks (bash)
├── lib/             # Shared shell helpers
├── templates/       # Spec/plan/task templates
└── .claude-plugin/  # Plugin metadata (plugin.json)
```

## Recommended Project-Level Rules

When using SpecSwarm in a project, consider adding these rules to `.claude/rules/`:

**`.claude/rules/specswarm-active-build.md`** (glob: `.specswarm/build-loop.state`):
- Check build state before starting new builds
- Don't create new feature branches during active builds

**`.claude/rules/specswarm-feature-branch.md`** (glob: `.specswarm/features/**`):
- Reference spec.md and plan.md when editing feature files
- Follow tasks.md task breakdown, mark tasks complete when done
