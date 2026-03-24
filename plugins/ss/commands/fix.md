---
description: (shortcut) Fix bugs with test-driven approach and retry
effort: max
args:
  - name: bug_description
    description: Natural language description of the bug to fix
    required: true
  - name: flags
    description: Same flags as /specswarm:fix (--regression-test, --hotfix, --max-retries, etc.)
    required: false
---

Use the SlashCommand tool to execute: /specswarm:fix $ARGUMENTS
