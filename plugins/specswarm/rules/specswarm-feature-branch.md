---
description: Follow SpecSwarm artifacts when working on feature branches
globs:
  - .specswarm/features/**
---

# Feature Branch Context

When editing files within `.specswarm/features/`, you are working on a SpecSwarm-managed feature.

## Rules

1. **Reference `spec.md`** for requirements before making changes — don't deviate from the specification
2. **Reference `plan.md`** for architecture decisions — follow the planned approach
3. **Follow `tasks.md`** task breakdown — implement tasks in dependency order
4. **Mark tasks complete** in `tasks.md` when done (change `[ ]` to `[x]`)
5. **Don't skip validation** — run quality checks before considering a task complete
