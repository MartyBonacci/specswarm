---
name: specswarm-build
description: Build complete features from specifications using SpecSwarm workflows. Use when the user wants to create, add, implement, develop, or make a new feature, component, or functionality. Trigger words include "build", "create", "add", "implement", "develop", "make", "new feature".
---

# SpecSwarm Build Workflow

This skill provides natural language access to the `/specswarm:build` command.

## When to Use

Activate this skill when the user wants to build a new feature, such as:
- "Build user authentication with JWT"
- "Create a payment processing system"
- "Add dashboard analytics"
- "Implement shopping cart functionality"
- "Develop a new API endpoint"

## Instructions

When this skill is invoked:

1. **Extract the feature description** from the user's natural language input
2. **Run the build command** using the SlashCommand tool:
   ```
   /specswarm:build "feature description"
   ```
3. **Let the command handle everything** - do not add extra steps or workflows
4. **Stop when the command completes** - do not continue with ship/merge/deploy

## What the Build Command Does

The `/specswarm:build` command runs a complete workflow:
- Creates specification
- Asks clarifying questions
- Generates implementation plan
- Breaks down into tasks
- Implements all tasks
- Validates quality

**Important:** The build command stops after implementation and quality validation. It does NOT merge, ship, or deploy. That's a separate step the user will initiate with "ship it" or `/specswarm:ship`.

## Examples

**User input:** "Build a user authentication system"

**Your response:** Run `/specswarm:build "user authentication system"` and let it execute the complete workflow.
