---
name: specswarm-ship
description: Ship completed features with quality validation and merge to parent branch. Use when the user wants to deploy, merge, release, ship, or complete a feature. Trigger words include "ship", "deploy", "merge", "release", "complete", "finish", "done", "push to production".
---

# SpecSwarm Ship Workflow

This skill provides natural language access to the `/specswarm:ship` command.

## When to Use

Activate this skill when the user wants to ship/deploy a completed feature, such as:
- "Ship this feature"
- "Deploy to production"
- "Merge to main"
- "Release version 2.0"
- "I'm done with this feature"
- "Complete and merge"

## Instructions

When this skill is invoked:

1. **Confirm the user wants to ship** - this is a critical operation
2. **Run the ship command** using the SlashCommand tool:
   ```
   /specswarm:ship
   ```
3. **Let the command handle everything** - it includes built-in safety confirmations
4. **Do not add extra steps** - the command handles quality validation and merge

## What the Ship Command Does

The `/specswarm:ship` command runs a complete shipping workflow:
- Runs quality analysis and validation
- Checks quality threshold (default 80%)
- Shows merge plan with confirmation prompt
- Merges to parent branch
- Cleans up feature branch

**Important:** The `/specswarm:ship` command has built-in safety confirmations. It will show exactly what it's going to do and ask the user to confirm before merging. You don't need to add additional confirmation prompts.

## Examples

**User input:** "Ship this feature"

**Your response:** Run `/specswarm:ship` and let it show the merge plan and confirmation prompt.
