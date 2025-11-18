---
name: specswarm-build
description: Build complete SOFTWARE FEATURES from specifications using SpecSwarm workflows. Use ONLY when the user is clearly requesting development of a new software feature, component, or functionality. DO NOT trigger on questions about commands, meta-discussion, or casual conversational use of the word "build".
---

# SpecSwarm Build Workflow

This skill provides natural language access to the `/specswarm:build` command.

## When to Use

**✅ TRIGGER when user clearly wants to BUILD A SOFTWARE FEATURE:**
- "Build user authentication with JWT"
- "Create a payment processing system"
- "Add dashboard analytics"
- "Implement shopping cart functionality"
- "Develop a new API endpoint"
- "Make a comment system"

**❌ DO NOT TRIGGER when:**
- Asking questions: "How does the build command work?"
- Meta-discussion: "Let's talk about the build workflow"
- Casual conversation: "Let me build on that idea"
- General tasks: "Build a summary of the code"
- Planning: "We should build that eventually"

## Critical Safety Check

**Before invoking this skill**, verify:
1. Is the user requesting development of a **SOFTWARE FEATURE**?
2. Is this a **CLEAR INTENT to execute** (not discuss or question)?
3. If the input is **very short** (< 5 words) or **ambiguous**, ask for confirmation first

**Confirmation for ambiguous cases:**
```
User: "Build that"

Response: "I detected a possible BUILD request. Did you want me to run
/specswarm:build to create a new software feature, or were you using
'build' conversationally?

If you want to build a feature, please describe what feature to build."
```

## Instructions

When this skill is invoked:

1. **Verify clear software development intent** - not questions, discussion, or casual speech
2. **If input is short/ambiguous** (< 5 words), ask for confirmation or clarification
3. **Extract the feature description** from the user's natural language input
4. **Run the build command** using the SlashCommand tool:
   ```
   /specswarm:build "feature description"
   ```
5. **Stop when the command completes** - do not continue with ship/merge/deploy

## What the Build Command Does

The `/specswarm:build` command runs a complete workflow:
- Creates specification
- Asks clarifying questions
- Generates implementation plan
- Breaks down into tasks
- Implements all tasks
- Validates quality

**Important:** The build command stops after implementation and quality validation. It does NOT merge, ship, or deploy.

## Examples

**Clear trigger:**
- User: "Build a user authentication system with email and password"
- Response: Run `/specswarm:build "user authentication system with email and password"`

**Ambiguous - ask first:**
- User: "Build that"
- Response: "What feature would you like me to build? Please describe the feature."

**Do NOT trigger:**
- User: "How does build work?"
- Response: Answer the question without invoking this skill
