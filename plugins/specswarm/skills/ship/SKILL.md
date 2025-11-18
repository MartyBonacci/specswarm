---
name: specswarm-ship
description: Ship completed features with quality validation, tests, and merge to parent branch. Use when the user wants to deploy, merge, release, ship, or complete a feature. Trigger words include "ship", "deploy", "merge", "release", "complete", "finish", "done", "push to production". ALWAYS requires explicit user confirmation before executing.
---

# SpecSwarm Ship Workflow

This skill runs the complete SHIP workflow using SpecSwarm's natural language dispatcher.

## 🛡️ CRITICAL SAFETY FEATURE

**SHIP commands detected via natural language will ALWAYS require explicit "yes" confirmation before executing, regardless of confidence level.** This prevents accidental merges, deployments, or releases that could have significant consequences.

The dispatcher will ALWAYS:
- Pause and ask: "Are you sure you want to ship this feature? (yes/no):"
- Require typing "yes" or "y" to proceed
- Cancel if any other input is provided
- Never auto-execute SHIP, even at 100% confidence

## What This Does

When invoked, this skill:
1. Detects SHIP intent from natural language input
2. **ALWAYS asks for explicit confirmation** (safety requirement)
3. Runs the complete `/specswarm:ship` workflow which includes:
   - Run quality checks and validation
   - Ensure all tests pass
   - Verify build succeeds
   - Merge feature branch to parent branch
   - Clean up temporary branches

## How It Works

The skill invokes SpecSwarm's natural language dispatcher which:
- Analyzes the user's input for SHIP patterns
- **Pauses for mandatory confirmation** before any execution
- Only proceeds if user types "yes" or "y"
- Executes `/specswarm:ship` command with full workflow

## Example Triggers

Natural language inputs that activate this skill:
- "Ship the shopping cart feature"
- "Deploy to production"
- "Merge this feature"
- "Release version 2.0"
- "I'm done with this feature, ship it"
- "Complete and merge to main"
- "Push this to production"

## Instructions

When this skill is invoked:

1. **Extract the feature description** from the user's natural language input
2. **Run the natural language dispatcher**:
   ```bash
   bash plugins/specswarm/lib/natural-language-dispatcher.sh "<user input>"
   ```
3. **The dispatcher will**:
   - Detect SHIP intent
   - **ALWAYS ask for confirmation** (no auto-execute)
   - Wait for "yes" or "y" input
   - Cancel if any other response
4. **If confirmed, monitor the workflow** as it:
   - Runs quality validation
   - Executes tests
   - Merges to parent branch

## Notes

- This skill provides natural language convenience for `/specswarm:ship`
- Users can still run `/specswarm:ship` directly if preferred
- **SHIP is the only command that ALWAYS requires confirmation**
- This safety feature cannot be bypassed or disabled
- Designed to prevent accidental production deployments
- The confirmation prompt appears BEFORE any shipping actions occur
