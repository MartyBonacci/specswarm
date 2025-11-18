---
name: specswarm-fix
description: Fix bugs and issues systematically using regression tests and retry logic. Use when the user reports something is broken, not working, has errors, needs debugging, or mentions bugs, issues, failures, or errors. Trigger words include "fix", "bug", "broken", "doesn't work", "not working", "error", "issue", "failing", "debug".
---

# SpecSwarm Fix Workflow

This skill provides natural language access to the `/specswarm:fix` command.

## When to Use

Activate this skill when the user reports a bug or issue, such as:
- "Fix the login button on mobile"
- "There's a bug in the checkout process"
- "Authentication doesn't work"
- "Getting an error when submitting the form"
- "The search is broken"
- "Debug the payment processing"

## Instructions

When this skill is invoked:

1. **Extract the bug description** from the user's natural language input
2. **Run the fix command** using the SlashCommand tool:
   ```
   /specswarm:fix "bug description"
   ```
3. **Let the command handle everything** - do not add extra steps or workflows
4. **Stop when the command completes** - do not continue with ship/merge/deploy

## What the Fix Command Does

The `/specswarm:fix` command runs a complete bugfix workflow:
- Creates regression tests to reproduce the bug
- Implements the fix
- Verifies the fix works
- Re-runs tests to catch new failures
- Auto-retries up to 2 times if needed

**Important:** The fix command stops after the bug is fixed and verified. It does NOT merge, ship, or deploy. That's a separate step the user will initiate with "ship it" or `/specswarm:ship`.

## Examples

**User input:** "Fix the login bug on mobile"

**Your response:** Run `/specswarm:fix "login bug on mobile"` and let it execute the complete workflow.
