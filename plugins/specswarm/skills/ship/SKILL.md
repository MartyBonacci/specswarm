---
name: specswarm-ship
description: Ship completed SOFTWARE FEATURES with quality validation and merge to parent branch. Use ONLY when the user explicitly wants to deploy/merge/release a completed feature to production or main branch. DO NOT trigger on casual use of "ship it" as approval/agreement, questions about shipping, or meta-discussion. ALWAYS confirm before executing due to destructive nature (merges branches, deletes feature branches).
---

# SpecSwarm Ship Workflow

This skill provides natural language access to the `/specswarm:ship` command.

## ⚠️ HIGHEST RISK COMMAND - Extra Caution Required

**SHIP is destructive**: It merges to main branch and deletes feature branches.

**"Ship it" is a common casual expression** meaning "that's good enough" or "I approve" in software teams. DO NOT trigger this skill for casual conversational use.

## When to Use

**✅ TRIGGER ONLY when user explicitly wants to MERGE/DEPLOY A COMPLETED FEATURE:**
- "Ship the user authentication feature to production"
- "Deploy the shopping cart to main branch"
- "Merge the payment processing feature"
- "Release version 2.0"
- "I want to complete and merge this feature to main"

**❌ DO NOT TRIGGER when:**
- **Casual approval**: "Ship it!" (meaning "sounds good", "I approve")
- Asking questions: "How does the ship command work?"
- Meta-discussion: "We should talk about shipping"
- Planning: "Let's ship this next week"
- Discussing code: "This code is ready to ship"
- General conversation: "That's shippable quality"

## MANDATORY Safety Check

**ALWAYS confirm before invoking**, especially for short phrases:

**For ANY user input ≤ 10 words, ask:**
```
User: "Ship it"

Response: "⚠️ SHIP CONFIRMATION REQUIRED

I detected 'ship it' - this phrase has two possible meanings:
1. **Casual approval** - "That's good enough" / "I like it" (COMMON)
2. **Execute shipping** - Merge feature to main branch (DESTRUCTIVE)

Which did you mean?

If you want to ship a feature, please say something like:
'Ship the [feature-name] feature to production'

If you were just expressing approval, no action is needed."
```

**For clear feature shipping requests:**
```
User: "Ship the user authentication feature to production"

Response: "I'll run /specswarm:ship to merge your completed feature.

Note: The command itself will show you exactly what will be merged
and ask for final confirmation before executing."
```

## Instructions

When this skill is invoked:

1. **CRITICAL: Verify this is NOT casual "ship it" approval** - check for SOFTWARE FEATURE context
2. **If input is ≤ 10 words**, ALWAYS ask confirmation using the template above
3. **If ambiguous in any way**, ask for clarification
4. **Only proceed if user confirms** they want to merge/deploy a feature
5. **Run the ship command** using the SlashCommand tool:
   ```
   /specswarm:ship
   ```
6. **The command handles its own safety** - it will show merge plan and ask for final confirmation

## What the Ship Command Does

The `/specswarm:ship` command runs a complete shipping workflow:
- Runs quality analysis and validation
- Checks quality threshold (default 80%)
- Shows merge plan with confirmation prompt
- Merges to parent branch
- Cleans up feature branch

**Important:** The `/specswarm:ship` command has built-in safety confirmations. Even after you invoke it, the user will see exactly what will be merged and must confirm.

## Examples

**Ambiguous - ALWAYS ask first:**
- User: "Ship it"
- Response: Use the confirmation template above - ask if they mean casual approval or actual shipping

- User: "Ship it!"
- Response: Use the confirmation template above - likely casual approval

- User: "Ship"
- Response: "What feature would you like to ship? Please specify which feature to merge to production."

**Clear trigger (but still let /ship command confirm):**
- User: "Ship the authentication feature that's on branch 003-user-auth"
- Response: "I'll run /specswarm:ship. The command will show you the merge plan and ask for confirmation."

**Do NOT trigger:**
- User: "That code looks great, ship it!" (casual approval)
- Response: "Glad you like it! Let me know when you're ready to merge the feature to production."

- User: "Is this feature ready to ship?"
- Response: Answer the question without invoking this skill

- User: "Let's discuss the ship workflow"
- Response: Explain the workflow without invoking this skill
