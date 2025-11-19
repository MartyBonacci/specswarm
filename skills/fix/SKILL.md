---
name: specswarm-fix
description: Use when the user reports ANY problem with software functionality, describes things not working correctly, or asks to fix/debug/resolve issues. Trigger on problems described as broken, not working, failing, errors, bugs, issues, doesn't load, not loading, etc.
---

# SpecSwarm Fix Workflow

Provides natural language access to `/specswarm:fix` command.

## When to Invoke

Trigger this skill when the user describes ANY software problem:
- Things not working or broken
- Errors, bugs, or failures
- Features not loading or functioning
- Requests to fix, debug, or resolve issues
- ANY report of unexpected behavior

**Examples:**
- "Please fix that the images don't load"
- "Images don't load"
- "Fix the login bug"
- "The checkout is broken"
- "There's an error when submitting forms"
- "Authentication doesn't work"
- "Payment processing fails"
- "The search isn't working"

## Instructions

**ALWAYS follow this flow:**

1. **Detect** that user described a software problem
2. **Extract** the problem description from their message
3. **ALWAYS ask for confirmation** using AskUserQuestion tool with two options:
   - **Option 1** (label: "Run /specswarm:fix"): Use SpecSwarm's systematic bugfix workflow
   - **Option 2** (label: "Process normally"): Handle as regular Claude Code request
4. **If user selects Option 1**, run: `/specswarm:fix "problem description"`
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