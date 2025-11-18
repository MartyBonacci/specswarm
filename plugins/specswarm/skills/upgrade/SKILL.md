---
name: specswarm-upgrade
description: Upgrade technologies, dependencies, frameworks, and libraries with compatibility analysis and migration guidance. Use when the user wants to update, upgrade, migrate, or modernize packages, dependencies, frameworks, or technology stacks. Trigger words include "upgrade", "update", "migrate", "modernize", "bump version", "update dependencies".
---

# SpecSwarm Upgrade Workflow

This skill runs the complete UPGRADE workflow using SpecSwarm's natural language dispatcher.

## What This Does

When invoked, this skill:
1. Detects UPGRADE intent from natural language input
2. Uses confidence scoring to determine execution approach
3. Runs the complete `/specswarm:upgrade` workflow which includes:
   - Analyze breaking changes and compatibility
   - Create comprehensive upgrade plan
   - Generate migration tasks
   - Update dependencies and code
   - Run tests to verify compatibility
   - Document upgrade process

## How It Works

The skill invokes SpecSwarm's natural language dispatcher which:
- Analyzes the user's input for UPGRADE patterns
- Calculates confidence score based on trigger words
- **High confidence (95%+)**: Shows what will run, gives 3-second cancel window
- **Medium confidence (70-94%)**: Asks for confirmation
- **Low confidence (<70%)**: Shows detected intent and asks to confirm
- Executes `/specswarm:upgrade` command with full workflow

## Example Triggers

Natural language inputs that activate this skill:
- "Upgrade React to version 18"
- "Update all dependencies"
- "Migrate from Webpack to Vite"
- "Modernize the build system"
- "Bump Node version to 20"
- "Update TypeScript to latest"
- "Migrate from JavaScript to TypeScript"
- "Upgrade to the latest framework version"

## Instructions

When this skill is invoked:

1. **Extract the upgrade details** from the user's natural language input
2. **Run the natural language dispatcher**:
   ```bash
   bash plugins/specswarm/lib/natural-language-dispatcher.sh "<user input>"
   ```
3. **Let the dispatcher handle**:
   - Intent confirmation
   - Confidence-based execution
   - Running `/specswarm:upgrade` workflow
4. **Monitor the upgrade workflow** as it:
   - Analyzes breaking changes
   - Creates migration plan
   - Updates code and dependencies
   - Verifies with tests

## Notes

- This skill provides natural language convenience for `/specswarm:upgrade`
- Users can still run `/specswarm:upgrade` directly if preferred
- The UPGRADE workflow includes compatibility analysis
- Breaking changes are documented in the upgrade plan
- Tests verify the upgrade doesn't break functionality
- Migration guidance helps with manual code updates
