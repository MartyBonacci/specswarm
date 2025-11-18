---
name: specswarm-build
description: Build complete features from specifications through the full SpecSwarm workflow including specification, clarification, planning, task generation, and implementation. Use when the user wants to create, add, implement, develop, or make a new feature, component, or functionality. Trigger words include "build", "create", "add", "implement", "develop", "make", "new feature", "add functionality".
---

# SpecSwarm Build Workflow

This skill runs the complete BUILD workflow using SpecSwarm's natural language dispatcher.

## What This Does

When invoked, this skill:
1. Detects BUILD intent from natural language input
2. Uses confidence scoring to determine execution approach
3. Runs the complete `/specswarm:build` workflow which includes:
   - `/specswarm:specify` - Create feature specification
   - `/specswarm:clarify` - Ask clarifying questions
   - `/specswarm:plan` - Generate implementation plan
   - `/specswarm:tasks` - Create task breakdown
   - `/specswarm:implement` - Execute implementation

## How It Works

The skill invokes SpecSwarm's natural language dispatcher which:
- Analyzes the user's input for BUILD patterns
- Calculates confidence score based on trigger words
- **High confidence (95%+)**: Shows what will run, gives 3-second cancel window
- **Medium confidence (70-94%)**: Asks for confirmation
- **Low confidence (<70%)**: Shows detected intent and asks to confirm
- Executes `/specswarm:build` command with full workflow

## Example Triggers

Natural language inputs that activate this skill:
- "Build a shopping cart feature"
- "Create user authentication"
- "Add dark mode support"
- "Implement search functionality"
- "Develop a new API endpoint"
- "Make a comment system"
- "I want to create a dashboard"

## Instructions

When this skill is invoked:

1. **Extract the feature description** from the user's natural language input
2. **Run the natural language dispatcher**:
   ```bash
   bash plugins/specswarm/lib/natural-language-dispatcher.sh "<user input>"
   ```
3. **Let the dispatcher handle**:
   - Intent confirmation
   - Confidence-based execution
   - Running `/specswarm:build` workflow
4. **Monitor the workflow** as it progresses through all stages

## Notes

- This skill provides natural language convenience for `/specswarm:build`
- Users can still run `/specswarm:build` directly if preferred
- The dispatcher includes safety checks and confirmation prompts
- All BUILD workflows run the complete feature development lifecycle
