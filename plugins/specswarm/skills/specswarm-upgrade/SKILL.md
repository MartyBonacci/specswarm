---
name: specswarm-upgrade
description: Systematic compatibility analysis, migration guidance, and breaking change detection for dependency/framework upgrades. Auto-executes when user clearly wants to upgrade, update, migrate, or modernize software dependencies, frameworks, packages, or technology stacks.
allowed-tools: AskUserQuestion, SlashCommand
hooks:
  - event: PreToolUse
    tool: SlashCommand
    handler: check-compatibility
    description: Checks dependency compatibility before upgrade commands
  - event: PostToolUse
    tool: SlashCommand
    handler: track-upgrade-progress
    description: Tracks upgrade progress and migration status
---

# SpecSwarm Upgrade Workflow

Provides natural language access to `/specswarm:upgrade` command.

## When to Invoke

Trigger this skill when the user mentions:
- Upgrading or updating dependencies/packages
- Migrating to new frameworks or versions
- Modernizing technology stacks
- Bumping version numbers

**Examples:**
- "Upgrade React to version 19"
- "Update all dependencies"
- "Migrate from Webpack to Vite"
- "Modernize the build system"
- "Bump Node to version 20"

## Instructions

**Skill-Based Routing:**

1. **Detect** that user mentioned upgrading/updating software
2. **Extract** what to upgrade from their message
3. **Route based on intent clarity**:

   **Clear intent** - Execute directly:
   - Clear upgrade requests: "Upgrade React to version 19", "Update all dependencies", "Migrate from Webpack to Vite"
   - Action: Immediately run `/specswarm:upgrade "upgrade description"`

   **Ambiguous intent** - Ask for confirmation:
   - Less specific: "Update the packages", "Make it better"
   - Action: Use AskUserQuestion tool with two options:
     - Option 1 (label: "Run /specswarm:upgrade"): Use SpecSwarm's upgrade workflow with compatibility analysis
     - Option 2 (label: "Process normally"): Handle as regular Claude Code request

4. **If user selects Option 2**, process normally without SpecSwarm
5. **After command completes**, STOP - do not continue with ship/merge

## What the Upgrade Command Does

`/specswarm:upgrade` runs complete workflow:
- Analyzes breaking changes and compatibility
- Creates comprehensive upgrade plan
- Generates migration tasks
- Updates dependencies and code
- Runs tests to verify compatibility
- Documents upgrade process

Stops after upgrade is complete - does NOT merge/ship/deploy.

## Semantic Understanding

This skill should trigger not just on exact keywords, but semantic equivalents:

**Upgrade equivalents**: upgrade, update, migrate, modernize, bump, move to, switch to, adopt
**Target terms**: dependency, package, framework, library, version, technology stack

## Example

```
User: "Upgrade React to version 19"