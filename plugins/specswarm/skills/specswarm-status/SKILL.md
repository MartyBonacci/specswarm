---
name: specswarm-status
effort: low
description: Check build progress and session status. Triggers on progress/status/done/how's-the-build intent.
allowed-tools: AskUserQuestion, SlashCommand
---

# SpecSwarm Status Check

Provides natural language access to `/specswarm:status` command.

## Dynamic Context

Current build state:
`!cat .specswarm/build-loop.state 2>/dev/null || echo "No active build"`

## When to Invoke

Trigger this skill when the user asks about:
- Build progress or status
- Whether something is done or still running
- Background session status
- "How's the build going?"

**Examples:**
- "How's the build going?"
- "Is it done yet?"
- "Check progress"
- "What's the status?"
- "Show me background sessions"

## Instructions

**Auto-execute on clear intent:**

1. **Detect** that user is asking about build/session status
2. **Execute immediately**: Run `/specswarm:status`
3. No confirmation needed — this is a read-only operation

## Semantic Understanding

**Status equivalents**: status, progress, check, how's it going, is it done, still running, background, sessions
