# SpecSwarm Portable — DEPRECATED

**Status**: Deprecated as of v5.1.0 (March 2026)

## Why?

The portable version (`/sw:*` commands) was created for Claude Code Web users who can't install plugins. However, the web interface **does not support hooks**, which means:

- Every `/sw:build` requires **6 manual "continue" prompts** — one per phase transition
- The stop hook that enables autonomous multi-phase builds simply doesn't run
- This undermines SpecSwarm's core value: autonomous spec-driven development

Without hooks, the portable version delivers a significantly degraded experience that doesn't represent what SpecSwarm can do.

## What to use instead

**Install the plugin version** via the marketplace:

```bash
claude plugin install specswarm --marketplace https://github.com/MartyBonacci/specswarm
```

The plugin version (`/specswarm:*`) includes:
- Autonomous multi-phase builds via stop hook
- Natural language skill routing (no need for `/sw:router`)
- PostToolUse quality hooks (automatic lint/typecheck)
- Full lifecycle management

**Power users**: Use `/ss:*` as shorthand (e.g., `/ss:build`, `/ss:fix`).

## If Anthropic adds hook support to the web interface

This deprecation can be revisited. The core issue is the lack of hooks, not the web interface itself. If hooks become available in the web interface, the portable version could be revived.

## Existing portable installations

If you have the portable version installed in a project (`.claude/commands/sw/`), it will continue to work but will not receive updates. To uninstall:

```bash
rm -rf .claude/commands/sw
```

Your `.specswarm/` configuration and feature artifacts are preserved.
