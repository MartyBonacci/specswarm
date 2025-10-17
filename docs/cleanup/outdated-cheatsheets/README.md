# Outdated Cheatsheets

**Status**: DEPRECATED (October 16, 2025)

These cheatsheets reference the old plugin architecture before the major v2.0.0 consolidation.

## What Changed

### Deprecated Plugins (Removed)
- SpecKit → Merged into SpecSwarm
- SpecTest → Merged into SpecSwarm
- SpecLab (singular) → Merged into SpecSwarm
- debug-coordinate → Merged into SpecLabs
- project-orchestrator → Merged into SpecLabs

### Current Plugins (Active)
- **SpecSwarm v2.0.0** - Complete software development toolkit (18 commands)
  - Feature development (specify, plan, tasks, implement)
  - Lifecycle workflows (bugfix, modify, hotfix, refactor, deprecate)
  - Quality analysis (analyze-quality, suggest, workflow-metrics)

- **SpecLabs v2.0.0** - Experimental autonomous development (4 commands)
  - Feature orchestration (orchestrate-feature)
  - Task orchestration (orchestrate)
  - Validation (orchestrate-validate)
  - Advanced debugging (coordinate)

## Migration

### Old → New Command Mapping

**Feature Development**:
- `/speckit:*` → `/specswarm:*`
- `/spectest:*` → `/specswarm:*`

**Lifecycle Workflows**:
- `/speclab:bugfix` → `/specswarm:bugfix`
- `/speclab:modify` → `/specswarm:modify`
- `/speclab:hotfix` → `/specswarm:hotfix`
- `/speclab:refactor` → `/specswarm:refactor`
- `/speclab:deprecate` → `/specswarm:deprecate`
- `/speclab:suggest` → `/specswarm:suggest`
- `/speclab:workflow-metrics` → `/specswarm:workflow-metrics`

**Experimental Features**:
- `/debug-coordinate:coordinate` → `/speclabs:coordinate`
- `/project-orchestrator:*` → `/speclabs:orchestrate*`

## Current Documentation

See the up-to-date documentation:
- `/plugins/specswarm/README.md` - SpecSwarm plugin
- `/plugins/speclabs/README.md` - SpecLabs plugin
- `/README.md` - Repository overview

## Why These Were Archived

These cheatsheets were created when we had 7 separate plugins. The consolidation to 2 plugins makes them misleading and confusing. They're preserved here for historical reference only.

**Do not use these cheatsheets** - they reference commands and plugins that no longer exist.
