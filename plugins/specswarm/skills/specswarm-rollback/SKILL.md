---
name: specswarm-rollback
effort: low
description: Safely rollback failed features (DESTRUCTIVE). ALWAYS confirms on rollback/undo/revert/abort intent.
allowed-tools: AskUserQuestion, SlashCommand
---

# SpecSwarm Rollback

Provides natural language access to `/specswarm:rollback` command.

## When to Invoke

Trigger this skill when the user mentions:
- Rolling back or reverting changes
- Undoing a feature or build
- Aborting a failed feature
- Cleaning up after a failed build

**Examples:**
- "Roll back the last feature"
- "Undo changes from the build"
- "Revert the feature branch"
- "Abort this feature"
- "Clean up the failed build"

## Instructions

**ALWAYS Confirm (Regardless of Confidence):**

1. **Detect** that user wants to rollback/undo/revert
2. **ALWAYS ask for confirmation** using AskUserQuestion tool:

   **Question**: "ROLLBACK CONFIRMATION - Destructive Operation"

   **Description**: "This will revert your feature branch changes and clean up artifacts. This cannot be easily undone."

   **Options**:
   - **Option 1** (label: "Yes, rollback"): "Rollback feature and clean up artifacts"
   - **Option 2** (label: "No, cancel"): "Cancel - keep current state"

3. **If user selects Option 1**, run: `/specswarm:rollback`
4. **If user selects Option 2**, acknowledge cancellation

## Semantic Understanding

**Rollback equivalents**: rollback, roll back, undo, revert, abort, cancel, clean up, tear down, discard
**Target terms**: feature, build, branch, changes, work
