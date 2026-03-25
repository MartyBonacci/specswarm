---
description: Build complete feature from spec to implementation
effort: high
args:
  - name: feature_description
    description: Natural language description of the feature to build
    required: true
  - name: flags
    description: Same flags as /specswarm:build (--validate, --quality-gate, --quick, --orchestrate, etc.)
    required: false
---

Use the SlashCommand tool to execute: /specswarm:build $ARGUMENTS
