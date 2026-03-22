---
description: (shortcut) Upgrade dependencies or frameworks with breaking change analysis
hidden: true
effort: high
args:
  - name: upgrade_target
    description: What to upgrade (e.g., "React 18 to React 19", "all dependencies")
    required: true
  - name: flags
    description: Same flags as /specswarm:upgrade (--deps, --package, --dry-run)
    required: false
---

Use the SlashCommand tool to execute: /specswarm:upgrade $ARGUMENTS
