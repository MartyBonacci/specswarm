---
name: specswarm-upgrade
description: Use when the user wants to upgrade, update, migrate, or modernize software dependencies, frameworks, packages, or technology stacks. Trigger on ANY request to upgrade versions, update dependencies, or migrate to newer technologies.
allowed-tools: AskUserQuestion, SlashCommand
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

**ALWAYS follow this flow:**

1. **Detect** that user mentioned upgrading/updating software
2. **Extract** what to upgrade from their message
3. **ALWAYS ask for confirmation** using AskUserQuestion tool with two options:
   - **Option 1** (label: "Run /specswarm:upgrade"): Use SpecSwarm's upgrade workflow with compatibility analysis
   - **Option 2** (label: "Process normally"): Handle as regular Claude Code request
4. **If user selects Option 1**, run: `/specswarm:upgrade "upgrade description"`
5. **If user selects Option 2**, process normally without SpecSwarm
6. **After command completes**, STOP - do not continue with ship/merge

## What the Upgrade Command Does

`/specswarm:upgrade` runs complete workflow:
- Analyzes breaking changes and compatibility
- Creates comprehensive upgrade plan
- Generates migration tasks
- Updates dependencies and code
- Runs tests to verify compatibility
- Documents upgrade process

Stops after upgrade is complete - does NOT merge/ship/deploy.

## Example

```
User: "Upgrade React to version 19"