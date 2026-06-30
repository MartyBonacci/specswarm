# CLAUDE.md — SpecSwarm

## Overview

SpecSwarm is a Claude Code plugin providing spec-driven development workflows: Build, Modify, Fix, Ship. As of v6.0.0, all functionality lives in the `ss` plugin and is invoked via `/ss:*` commands (19 visible + 11 internal/hidden = 30 total — v7.1.0 `/ss:preflight`, v7.2.0 `/ss:notify`, v7.3.0 `/ss:intervention`, v7.4.0 `/ss:verify`, v7.5.0 `/ss:retrospective`, v7.6.0 `/ss:decisions`, v7.8.0 `/ss:dry-run`, v7.9.0 `/ss:watchdog`, v7.10.0 `/ss:overnight`). v7.11.0 hardens the verification loop (WARN-on-zero preflight gates, canonical-checkbox `/ss:tasks`, verify-queue drain in `/ss:implement`, ship verify-queue precondition, decision-miner prior-commitments input). v7.12.0 collapses the verify-queue Stop hook into a per-feature summary when pending > `SPECSWARM_VERIFY_QUEUE_LIST_MAX` (default 8), so large queues stop flooding the conversation. Includes 10 natural-language skills, 6 multi-agent orchestration agents with v7.7.0 explicit model assignments (5 on opus, 1 on haiku), and the `.specswarm/` per-project state directory (directory name preserves the SpecSwarm brand).

The legacy `specswarm` plugin remains as a deprecation stub (no commands/skills/hooks) so users who installed it see a clear migration message. Slated for full removal in v7.0.0.

## Subagent Model Specialization (v7.7.0)

Each subagent's `model:` frontmatter is set explicitly based on the cognitive workload of its job. This overrides Claude Code's default of inheriting the parent session's model — because an agent's model affinity is a *design property*, not a user preference.

| Agent | Model | Why |
|---|---|---|
| `orchestrator` | `opus` | Multi-task dependency analysis with `maxTurns: 50`; reasoning depth matters |
| `spec-mentor` | `opus` | Adversarial verification — false PASS on real DRIFT is the bug class to prevent |
| `chunk-retrospective` | `opus` | Synthesis + classification + concise writing of memory entries that compound |
| `decision-miner` | `opus` | Triage scanner candidates (high recall, low precision); rejection requires judgment |
| `task-router` | `haiku` | Pure keyword pattern-match against a fixed rule table; speed/cost dominates |

**Cost implications by parent-session model:**
- Parent on opus → marginal decrease (task-router cheaper, judgment agents same)
- Parent on sonnet → judgment agents go up, task-router down — net depends on which agents fire most often during your chunks
- Parent on haiku → judgment agents go up substantially; this is the scenario where v7.7.0 spends real money to recover quality

**To override** for cost-control or experimentation, edit the `model:` line in any `plugins/ss/agents/*.md` file. Use shorthand (`opus`/`sonnet`/`haiku`) for forward-compatibility with future Claude model releases.

## Development

### Plugin Validation (required before commits)

```bash
claude plugin validate plugins/ss/
claude plugin validate plugins/specswarm/   # deprecation stub
```

Run this after any change to command/skill/agent frontmatter or plugin.json. It catches YAML typos that would silently fail at runtime.

### Version Bumping

Three files must be bumped in sync:
1. `plugins/ss/.claude-plugin/plugin.json` — `version`
2. `plugins/specswarm/.claude-plugin/plugin.json` — `version` (kept in sync even though it's a stub)
3. `.claude-plugin/marketplace.json` — both `plugins[].version` entries

### Testing After Changes

1. Restart Claude Code (skill prompts are cached per session)
2. Run `/skills` to verify all 10 `ss-*` skills appear
3. Test a low-effort command (`/ss:status`) vs high-effort (`/ss:build`)

## Project Structure

```
plugins/ss/
├── commands/        # 30 slash commands (19 visible + 11 internal/hidden)
│                    # v7.1.0: /ss:preflight     v7.2.0: /ss:notify
│                    # v7.3.0: /ss:intervention  v7.4.0: /ss:verify
│                    # v7.5.0: /ss:retrospective v7.6.0: /ss:decisions
│                    # v7.8.0: /ss:dry-run       v7.9.0: /ss:watchdog
│                    # v7.10.0: /ss:overnight
├── skills/          # 10 ss-* skills (ss-build, ss-fix, ss-init, ss-metrics, ss-modify, ss-release, ss-rollback, ss-ship, ss-status, ss-upgrade)
├── agents/          # 6 agents (v7.7.0: explicit model assignments)
│                    # — orchestrator         [opus]   multi-task dependency analysis
│                    # — task-router          [haiku]  keyword routing (mechanical)
│                    # — spec-mentor          [opus]   adversarial verification (v7.4.0)
│                    # — chunk-retrospective  [opus]   memory synthesis (v7.5.0)
│                    # — decision-miner       [opus]   decision polishing (v7.6.0)
│                    # — dry-run-simulator    [opus]   pre-commit prediction (v7.8.0)
├── hooks/           # SessionStart orientation, Setup auto-init,
│                    # PostToolUse (quality + constitution dispatcher + tasks-completion-detector [v7.4.0]),
│                    # Stop (loop control + verify-queue-prompt [v7.4.0])
├── lib/             # Shared shell helpers (audit-logger, agent-generator, constitution-parser, orchestrator-utils, …)
│   ├── notify.sh        # v7.2.0: ss_notify with notifier-plugin → notify-send → osascript → bell fallbacks
│   ├── intervention.sh  # v7.3.0: ss_intervention_* helpers (reused by v7.5.0 retrospective)
│   ├── preflight/       # v7.1.0: deterministic checks (run.sh + checks/*.sh + package-manager-detector.sh)
│   ├── verify/          # v7.4.0: adversarial verification (queue.sh, task-context.sh, detect-completion.sh)
│   └── decisions/       # v7.6.0: decision pre-batching scanner (scan-plan.sh)
├── rules/           # Project-level rule references (specswarm-active-build, specswarm-feature-branch)
├── templates/       # Spec/plan/task templates, agent template, constitutional-hook templates
│                    # v7.3.0 adds intervention.template.md
└── .claude-plugin/  # plugin.json (name: "ss", version: "7.6.0")

plugins/specswarm/
└── .claude-plugin/
    └── plugin.json  # DEPRECATION STUB — points users to ss@specswarm-marketplace
```

## Recommended Project-Level Rules

When using SpecSwarm in a project, consider adding these rules to `.claude/rules/`:

**`.claude/rules/specswarm-active-build.md`** (glob: `.specswarm/build-loop.state`):
- Check build state before starting new builds
- Don't create new feature branches during active builds

**`.claude/rules/specswarm-feature-branch.md`** (glob: `.specswarm/features/**`):
- Reference spec.md and plan.md when editing feature files
- Follow tasks.md task breakdown, mark tasks complete when done

(The rule template files now live in `plugins/ss/rules/` and can be copied into a user repo's `.claude/rules/` to enable.)
