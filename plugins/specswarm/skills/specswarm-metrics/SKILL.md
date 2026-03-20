---
name: specswarm-metrics
effort: low
description: Show feature metrics and sprint analytics. Triggers on metrics/stats/analytics/how-did-we-do intent.
allowed-tools: AskUserQuestion, SlashCommand
---

# SpecSwarm Metrics

Provides natural language access to `/specswarm:metrics` command.

## When to Invoke

Trigger this skill when the user asks about:
- Feature metrics or analytics
- Sprint statistics
- Build performance data
- Completion rates

**Examples:**
- "Show me the metrics"
- "How did we do on that feature?"
- "Sprint stats"
- "Feature analytics"
- "Show completion rates"

## Instructions

**Auto-execute on clear intent:**

1. **Detect** that user is asking about metrics/analytics
2. **Execute immediately**: Run `/specswarm:metrics`
3. No confirmation needed — this is a read-only operation

## Semantic Understanding

**Metrics equivalents**: metrics, stats, statistics, analytics, performance, numbers, data, completion rates
**Scope terms**: feature, sprint, project, build, overall
