---
name: specswarm-fix
description: Fix software bugs and issues using SpecSwarm's systematic workflow (regression tests, implementation, verification, retry logic). Use when the user mentions fixing bugs, errors, broken functionality, or issues.
---

# SpecSwarm Fix Workflow

Provides natural language access to `/specswarm:fix` command.

## When to Invoke

Trigger this skill when the user mentions:
- Fixing bugs or errors
- Something is broken or not working
- Issues, failures, or malfunctions
- Debugging problems
- Any report of broken software functionality

**Examples:**
- "Fix the login bug"
- "Images don't load"
- "Please fix that the checkout is broken"
- "There's an error when submitting forms"
- "Debug the authentication failure"

## Instructions

**ALWAYS follow this flow:**

1. **Detect** that user mentioned a bug/error/broken functionality
2. **Extract** the bug description from their message
3. **ALWAYS ask for confirmation** using AskUserQuestion tool with two options:
   - **Option 1** (label: "Run /specswarm:fix"): Use SpecSwarm's systematic bugfix workflow
   - **Option 2** (label: "Process normally"): Handle as regular Claude Code request
4. **If user selects Option 1**, run: `/specswarm:fix "bug description"`
5. **If user selects Option 2**, process normally without SpecSwarm
6. **After command completes**, STOP - do not continue with ship/merge

## What the Fix Command Does

`/specswarm:fix` runs complete workflow:
- Creates regression tests to reproduce bug
- Implements the fix
- Verifies fix works
- Re-runs tests to catch new failures
- Auto-retries up to 2 times if needed

Stops after bug is fixed - does NOT merge/ship/deploy.

## Example

```
User: "Please fix that the images don't load"