---
name: specswarm-modify
description: Impact-analysis-first modification workflow with backward compatibility, breaking change detection, refactoring, and deprecation. Auto-executes when user clearly wants to modify, change, update, adjust, enhance, extend, alter, refactor, or deprecate existing feature behavior (not fixing bugs, not building new features). For features that work but need to work differently, or code that needs quality improvement.
allowed-tools: AskUserQuestion, SlashCommand
hooks:
  - event: PreToolUse
    tool: SlashCommand
    handler: ensure-impact-analysis
    description: Ensures impact analysis is completed before modification commands
  - event: PostToolUse
    tool: SlashCommand
    handler: track-modification-progress
    description: Tracks modification progress and breaking change detection
---

# SpecSwarm Modify Workflow

Provides natural language access to `/specswarm:modify` command.

## When to Invoke

Trigger this skill when the user mentions:
- Modifying, changing, or updating existing feature behavior
- Enhancing or extending working features
- Altering how something works (that currently works)
- Making features work differently than they do now
- Refactoring code for quality improvement (without changing behavior)
- Deprecating or sunsetting features

**Examples:**
- "Change authentication from session to JWT"
- "Add pagination to the user list API"
- "Update search to use full-text search"
- "Modify the dashboard to show real-time data"
- "Extend the API to support filtering"
- "Refactor this module to reduce complexity" → uses `--refactor`
- "Deprecate the v1 API" → uses `--deprecate`
- "What's the impact of changing the user model?" → uses `--analyze-only`

**NOT for this skill:**
- Fixing bugs (use specswarm-fix)
- Building new features (use specswarm-build)

## Instructions

**Confidence-Based Execution:**

1. **Detect** that user mentioned modifying/changing existing functionality
2. **Extract** the modification description from their message
3. **Assess confidence and execute accordingly**:

   **High Confidence (95%+)** - Auto-execute immediately:
   - Clear modification requests: "Change authentication from session to JWT", "Add pagination to user list API", "Update search algorithm to use full-text search"
   - Clear refactor requests: "Refactor this module to reduce complexity", "Clean up the utils to reduce duplication"
   - Clear deprecation requests: "Deprecate the v1 API", "Sunset the legacy auth system"
   - Action: Immediately run the appropriate command:
     - Standard modify: `/specswarm:modify "modification description"`
     - Refactor: `/specswarm:modify "target" --refactor`
     - Deprecate: `/specswarm:modify "target" --deprecate`
     - Impact analysis only: `/specswarm:modify "target" --analyze-only`
   - Show brief notification: "🎯 Running /specswarm:modify... (press Ctrl+C within 3s to cancel)"

   **Medium Confidence (70-94%)** - Ask for confirmation:
   - Less specific: "Update the authentication", "Modify the search", "Improve code quality"
   - Action: Use AskUserQuestion tool with two options:
     - Option 1 (label: "Run /specswarm:modify"): Use SpecSwarm's workflow
     - Option 2 (label: "Process normally"): Handle as regular Claude Code request

   **Low Confidence (<70%)** - Always ask:
   - Vague: "Make the feature better", "Improve the UI"
   - Action: Use AskUserQuestion as above

4. **If user cancels (Ctrl+C) or selects Option 2**, process normally without SpecSwarm
5. **After command completes**, STOP - do not continue with ship/merge

## What the Modify Command Does

`/specswarm:modify` runs complete workflow:
- Analyzes impact and backward compatibility
- Identifies breaking changes
- Creates migration plan if needed
- Updates specification and plan
- Generates modification tasks
- Implements changes
- Validates against regression tests

Stops after modification is complete - does NOT merge/ship/deploy.

## Semantic Understanding

This skill should trigger not just on exact keywords, but semantic equivalents:

**Modify equivalents**: modify, change, update, adjust, enhance, extend, alter, revise, adapt, transform, convert
**Refactor equivalents**: refactor, clean up, reorganize, simplify, reduce complexity, eliminate duplication, improve naming, optimize structure
**Deprecate equivalents**: deprecate, sunset, retire, phase out, remove feature, end-of-life
**Impact analysis equivalents**: what's the impact, analyze impact, dependency analysis, blast radius
**Target terms**: feature, functionality, behavior, workflow, process, mechanism, system, module, component

**Distinguish from:**
- **Fix** (broken/not working things): "fix", "repair", "resolve", "debug"
- **Build** (new things): "build", "create", "add", "implement new"

## Example

```
User: "Change authentication from session to JWT"

Claude: 🎯 Running /specswarm:modify... (press Ctrl+C within 3s to cancel)

[Executes /specswarm:modify "Change authentication from session to JWT"]
```

```
User: "Refactor the utils module to reduce complexity"

Claude: 🎯 Running /specswarm:modify --refactor... (press Ctrl+C within 3s to cancel)

[Executes /specswarm:modify "utils module" --refactor]
```

```
User: "Deprecate the v1 API"

Claude: 🎯 Running /specswarm:modify --deprecate... (press Ctrl+C within 3s to cancel)

[Executes /specswarm:modify "v1 API" --deprecate]
```

```
User: "What would be the impact of changing the user model?"

Claude: 🎯 Running /specswarm:modify --analyze-only...

[Executes /specswarm:modify "user model" --analyze-only]
```

```
User: "Update the authentication"

Claude: [Shows AskUserQuestion]
1. Run /specswarm:modify - Use SpecSwarm's workflow
2. Process normally - Handle as regular Claude Code request

User selects Option 1
```
