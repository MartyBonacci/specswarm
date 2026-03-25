---
description: Modify feature with impact analysis
effort: high
args:
  - name: modification_description
    description: Natural language description of the modification
    required: false
  - name: flags
    description: Same flags as /specswarm:modify (--refactor, --deprecate, --analyze-only)
    required: false
---

Use the SlashCommand tool to execute: /specswarm:modify $ARGUMENTS
