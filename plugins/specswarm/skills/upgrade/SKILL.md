---
name: specswarm-upgrade
description: Upgrade SOFTWARE TECHNOLOGIES, dependencies, frameworks, and libraries with compatibility analysis and migration guidance. Use ONLY when the user clearly wants to update/upgrade/migrate specific software packages or technology stacks. DO NOT trigger on questions about upgrading, meta-discussion, or casual conversational use of "upgrade" or "update".
---

# SpecSwarm Upgrade Workflow

This skill provides natural language access to the `/specswarm:upgrade` command.

## When to Use

**✅ TRIGGER when user clearly wants to UPGRADE SOFTWARE DEPENDENCIES/FRAMEWORKS:**
- "Upgrade React to version 19"
- "Update all dependencies to latest"
- "Migrate from Webpack to Vite"
- "Modernize the build system to use Vite 6"
- "Bump Node version to 20"
- "Update TypeScript to latest version"
- "Migrate from JavaScript to TypeScript"

**❌ DO NOT TRIGGER when:**
- Asking questions: "How does the upgrade command work?"
- Meta-discussion: "We should discuss upgrading someday"
- Casual conversation: "We need to upgrade our approach"
- Planning: "Eventually we should upgrade React"
- General improvements: "Let's upgrade the user experience"

## Critical Safety Check

**Before invoking this skill**, verify:
1. Is the user requesting an **SOFTWARE DEPENDENCY/FRAMEWORK UPGRADE**?
2. Is this a **CLEAR INTENT to execute** (not discuss or question)?
3. If the input is **very short** (< 5 words) or **ambiguous**, ask for confirmation first

**Confirmation for ambiguous cases:**
```
User: "Upgrade that"

Response: "I detected a possible UPGRADE request. What technology or
dependency would you like to upgrade? Please specify which package or
framework and the target version."
```

## Instructions

When this skill is invoked:

1. **Verify clear software upgrade intent** - not questions, discussion, or casual speech
2. **If input is short/ambiguous** (< 5 words), ask for clarification about what to upgrade
3. **Extract the upgrade details** from the user's natural language input
4. **Run the upgrade command** using the SlashCommand tool:
   ```
   /specswarm:upgrade "upgrade description"
   ```
5. **Stop when the command completes** - do not continue with ship/merge/deploy

## What the Upgrade Command Does

The `/specswarm:upgrade` command runs a complete upgrade workflow:
- Analyzes breaking changes and compatibility
- Creates comprehensive upgrade plan
- Generates migration tasks
- Updates dependencies and code
- Runs tests to verify compatibility
- Documents upgrade process

**Important:** The upgrade command stops after the upgrade is complete and verified. It does NOT merge, ship, or deploy.

## Examples

**Clear trigger:**
- User: "Upgrade React from version 18 to version 19"
- Response: Run `/specswarm:upgrade "React from version 18 to version 19"`

**Ambiguous - ask first:**
- User: "Upgrade it"
- Response: "What would you like to upgrade? Please specify the package or framework and the target version."

**Do NOT trigger:**
- User: "How do I upgrade dependencies manually?"
- Response: Answer the question without invoking this skill
- User: "We should upgrade our testing strategy"
- Response: Continue conversation without invoking this skill
