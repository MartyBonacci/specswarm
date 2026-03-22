---
description: (shortcut) Check status of background sessions and workflows
hidden: true
effort: low
model: claude-haiku-4-5
args:
  - name: session_id
    description: Session ID to check (optional - lists all if omitted)
    required: false
  - name: flags
    description: Same flags as /specswarm:status (--verbose, --json)
    required: false
---

Use the SlashCommand tool to execute: /specswarm:status $ARGUMENTS
