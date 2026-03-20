---
name: specswarm-init
effort: low
description: Initialize SpecSwarm for a project with constitution and standards. Triggers on setup/initialize/configure intent.
allowed-tools: AskUserQuestion, SlashCommand
---

# SpecSwarm Init

Provides natural language access to `/specswarm:init` command.

## When to Invoke

Trigger this skill when the user mentions:
- Setting up SpecSwarm for a project
- Initializing project configuration
- Creating project constitution or standards
- First-time SpecSwarm setup

**Examples:**
- "Set up SpecSwarm"
- "Initialize this project"
- "Configure SpecSwarm for my repo"
- "Create project constitution"

## Instructions

**Auto-execute on clear intent:**

1. **Detect** that user wants to initialize/set up SpecSwarm
2. **Execute immediately**: Run `/specswarm:init`
3. The init command is interactive — it will ask its own questions

## Semantic Understanding

**Init equivalents**: initialize, init, set up, setup, configure, bootstrap, onboard, get started
**Target terms**: project, repo, repository, codebase, workspace
