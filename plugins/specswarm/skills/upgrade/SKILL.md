---
name: specswarm-upgrade
description: Upgrade technologies, dependencies, frameworks, and libraries with compatibility analysis and migration guidance. Use when the user wants to update, upgrade, migrate, or modernize packages, dependencies, frameworks, or technology stacks. Trigger words include "upgrade", "update", "migrate", "modernize", "bump version", "update dependencies".
---

# SpecSwarm Upgrade Workflow

This skill provides natural language access to the `/specswarm:upgrade` command.

## When to Use

Activate this skill when the user wants to upgrade technologies, such as:
- "Upgrade React to version 18"
- "Update all dependencies"
- "Migrate from Webpack to Vite"
- "Modernize the build system"
- "Bump Node version to 20"
- "Update TypeScript to latest"
- "Migrate from JavaScript to TypeScript"

## Instructions

When this skill is invoked:

1. **Extract the upgrade details** from the user's natural language input
2. **Run the upgrade command** using the SlashCommand tool:
   ```
   /specswarm:upgrade "upgrade description"
   ```
3. **Let the command handle everything** - do not add extra steps or workflows
4. **Stop when the command completes** - do not continue with ship/merge/deploy

## What the Upgrade Command Does

The `/specswarm:upgrade` command runs a complete upgrade workflow:
- Analyzes breaking changes and compatibility
- Creates comprehensive upgrade plan
- Generates migration tasks
- Updates dependencies and code
- Runs tests to verify compatibility
- Documents upgrade process

**Important:** The upgrade command stops after the upgrade is complete and verified. It does NOT merge, ship, or deploy. That's a separate step the user will initiate with "ship it" or `/specswarm:ship`.

## Examples

**User input:** "Upgrade to React 19"

**Your response:** Run `/specswarm:upgrade "React 19"` and let it execute the complete workflow.
