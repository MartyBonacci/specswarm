---
name: specswarm-fix
description: Fix SOFTWARE BUGS and issues systematically using regression tests and retry logic. Use ONLY when the user is clearly reporting a broken feature, error, or malfunction in software. DO NOT trigger on questions about commands, meta-discussion, or casual conversational use of the word "fix" (like "this will fix the problem" in general discussion).
---

# SpecSwarm Fix Workflow

This skill provides natural language access to the `/specswarm:fix` command.

## When to Use

**✅ TRIGGER when user clearly reports a SOFTWARE BUG:**
- "Fix the login button on mobile"
- "There's a bug in the checkout process"
- "Authentication doesn't work"
- "Getting an error when submitting the form"
- "The search is broken"
- "Debug the payment processing failure"

**❌ DO NOT TRIGGER when:**
- Asking questions: "How does the fix command work?"
- Meta-discussion: "Tell me about the fix workflow"
- Casual conversation: "This approach will fix the problem"
- General solutions: "We can fix this by refactoring"
- Planning: "We should fix that eventually"

## Critical Safety Check

**Before invoking this skill**, verify:
1. Is the user reporting a **SOFTWARE BUG or MALFUNCTION**?
2. Is this a **CLEAR INTENT to debug/fix** (not discuss or question)?
3. If the input is **very short** (< 5 words) or **ambiguous**, ask for confirmation first

**Confirmation for ambiguous cases:**
```
User: "Fix it"

Response: "I detected a possible FIX request. What bug or issue would you
like me to fix? Please describe the broken behavior or error you're seeing."
```

## Instructions

When this skill is invoked:

1. **Verify clear software bug report** - not questions, discussion, or casual speech
2. **If input is short/ambiguous** (< 5 words), ask for clarification about what's broken
3. **Extract the bug description** from the user's natural language input
4. **Run the fix command** using the SlashCommand tool:
   ```
   /specswarm:fix "bug description"
   ```
5. **Stop when the command completes** - do not continue with ship/merge/deploy

## What the Fix Command Does

The `/specswarm:fix` command runs a complete bugfix workflow:
- Creates regression tests to reproduce the bug
- Implements the fix
- Verifies the fix works
- Re-runs tests to catch new failures
- Auto-retries up to 2 times if needed

**Important:** The fix command stops after the bug is fixed and verified. It does NOT merge, ship, or deploy.

## Examples

**Clear trigger:**
- User: "Fix the login bug - users can't log in with special characters in passwords"
- Response: Run `/specswarm:fix "login bug - users can't log in with special characters in passwords"`

**Ambiguous - ask first:**
- User: "Fix that"
- Response: "What bug or issue would you like me to fix? Please describe what's broken."

**Do NOT trigger:**
- User: "How do I fix this manually?"
- Response: Answer the question without invoking this skill
- User: "This refactoring will fix the performance issue"
- Response: Continue conversation without invoking this skill
