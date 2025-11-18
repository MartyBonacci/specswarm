---
name: specswarm-ship
description: Ship completed features with quality validation and merge to parent branch. Use when the user mentions shipping, deploying, merging, releasing, or completing features. Note - "ship it" is commonly used as casual approval, so always confirm first.
---

# SpecSwarm Ship Workflow

Provides natural language access to `/specswarm:ship` command.

## When to Invoke

Trigger this skill when the user mentions:
- Shipping, deploying, or releasing features
- Merging to main/production
- Completing or finishing features
- "Ship it" (common casual phrase - ALWAYS confirm)

**Examples:**
- "Ship the authentication feature"
- "Deploy to production"
- "Merge this to main"
- "Ship it" ← Ambiguous - might be casual approval
- "Release version 2.0"

## Instructions

**ALWAYS follow this flow:**

1. **Detect** that user mentioned shipping/deploying/merging
2. **Extract** context about what to ship (if provided)
3. **ALWAYS ask for confirmation** using AskUserQuestion tool with two options:
   - **Option 1** (label: "Run /specswarm:ship"): ⚠️ Merge feature to parent branch (DESTRUCTIVE - merges branches, deletes feature branch)
   - **Option 2** (label: "Process normally"): Handle as regular Claude Code request (or if this was just casual "ship it" approval)
4. **If user selects Option 1**, run: `/specswarm:ship`
5. **If user selects Option 2**, process normally without SpecSwarm
6. **The `/specswarm:ship` command has its own confirmation** - it will show merge plan and ask again

## What the Ship Command Does

`/specswarm:ship` runs complete workflow:
- Runs quality analysis and validation
- Checks quality threshold (default 80%)
- **Shows merge plan with confirmation prompt**
- Merges to parent branch
- Cleans up feature branch

**Important:** This is DESTRUCTIVE - it merges and deletes branches. The command itself has built-in confirmation as a second safety layer.

## Example

```
User: "Ship it"

Claude: [Shows AskUserQuestion]
1. Run /specswarm:ship - ⚠️ Merge feature to parent branch (DESTRUCTIVE)
2. Process normally - Handle as regular request

User selects Option 2 (it was casual approval, not actual shipping request)
```