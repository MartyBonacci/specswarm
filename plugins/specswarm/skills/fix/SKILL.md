---
name: specswarm-fix
description: Fix bugs and issues systematically using regression tests and retry logic. Use when the user reports something is broken, not working, has errors, needs debugging, or mentions bugs, issues, failures, or errors. Trigger words include "fix", "bug", "broken", "doesn't work", "not working", "error", "issue", "failing", "debug".
---

# SpecSwarm Fix Workflow

This skill runs the complete FIX workflow using SpecSwarm's natural language dispatcher.

## What This Does

When invoked, this skill:
1. Detects FIX intent from natural language input
2. Uses confidence scoring to determine execution approach
3. Runs the complete `/specswarm:fix` workflow which includes:
   - Create regression tests to reproduce the bug
   - Run `/specswarm:bugfix` to implement the fix
   - Verify the fix with regression tests
   - Retry up to 2 times if the fix doesn't work
   - Ensure all tests pass before completing

## How It Works

The skill invokes SpecSwarm's natural language dispatcher which:
- Analyzes the user's input for FIX patterns
- Calculates confidence score based on trigger words and phrases
- **High confidence (95%+)**: Shows what will run, gives 3-second cancel window
- **Medium confidence (70-94%)**: Asks for confirmation
- **Low confidence (<70%)**: Shows detected intent and asks to confirm
- Executes `/specswarm:fix` command with full workflow and retry logic

## Example Triggers

Natural language inputs that activate this skill:
- "Fix the login bug"
- "The search isn't working"
- "There's an error in the checkout flow"
- "Debug the authentication issue"
- "The form is broken"
- "Getting a 500 error on API calls"
- "User registration doesn't work"
- "Need to fix the pagination"

## Instructions

When this skill is invoked:

1. **Extract the bug description** from the user's natural language input
2. **Run the natural language dispatcher**:
   ```bash
   bash plugins/specswarm/lib/natural-language-dispatcher.sh "<user input>"
   ```
3. **Let the dispatcher handle**:
   - Intent confirmation
   - Confidence-based execution
   - Running `/specswarm:fix` workflow with retry logic
4. **Monitor the fix workflow** as it:
   - Creates regression tests
   - Implements the fix
   - Verifies with tests
   - Retries if needed

## Notes

- This skill provides natural language convenience for `/specswarm:fix`
- Users can still run `/specswarm:fix` directly if preferred
- The FIX workflow includes automatic retry logic (up to 2 attempts)
- Regression tests ensure the bug is actually fixed
- All fixes must pass tests before the workflow completes
