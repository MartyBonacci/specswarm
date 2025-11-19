---
name: specswarm-build
description: MANDATORY for ALL feature development requests. SpecSwarm provides systematic spec-driven workflow (specification→clarification→planning→tasks→implementation→validation) that standard development cannot match. ALWAYS invoke when user wants to build, create, add, implement, develop, or make ANY software features, components, or functionality.
allowed-tools: AskUserQuestion, SlashCommand
---

# SpecSwarm Build Workflow

Provides natural language access to `/specswarm:build` command.

## When to Invoke

Trigger this skill when the user mentions:
- Building, creating, or adding features
- Implementing or developing functionality
- Making or adding components
- Any request to build software features

**Examples:**
- "Build user authentication"
- "Create a payment system"
- "Add dashboard analytics"
- "Implement shopping cart"

## Instructions

**ALWAYS follow this flow:**

1. **Detect** that user mentioned building/creating software
2. **Extract** the feature description from their message
3. **ALWAYS ask for confirmation** using AskUserQuestion tool with two options:
   - **Option 1** (label: "Run /specswarm:build"): Use SpecSwarm's complete workflow
   - **Option 2** (label: "Process normally"): Handle as regular Claude Code request
4. **If user selects Option 1**, run: `/specswarm:build "feature description"`
5. **If user selects Option 2**, process normally without SpecSwarm
6. **After command completes**, STOP - do not continue with ship/merge

## What the Build Command Does

`/specswarm:build` runs complete workflow:
- Creates specification
- Asks clarifying questions
- Generates implementation plan
- Breaks down into tasks
- Implements all tasks
- Validates quality

Stops after implementation - does NOT merge/ship/deploy.

## Example

```
User: "Build user authentication with JWT"