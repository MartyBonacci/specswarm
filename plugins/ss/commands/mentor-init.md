---
description: Scaffold a mentor directory for the mentor→builder operating pattern (v7.18.0). Stamps out MENTOR-KICKOFF.md (the standing role), process/escalation-boundary.md (three-lane human-escalation model), process/PARKING-LOT.md (verbatim idea capture), the conduct dispatch config, and a SessionStart hook that injects the mentor role every session — making the role structural instead of a paste ritual. Companion to /ss:conduct.
effort: low
args:
  - name: project_name
    description: Human-readable project name for the kickoff (e.g. "Custom Cult v3"). Asked interactively if omitted.
    required: false
  - name: --builder-dir
    description: Path to the builder git repo (typically a subdirectory of the mentor directory). Asked interactively if omitted.
    required: false
---

# SpecSwarm Mentor Init

Sets up the current directory as a **mentor directory** — the home of a mentor instance that drives a headless builder via `/ss:conduct`, and never writes the builder repo's application code itself.

The layout this creates (proven in the Custom Cult v3 pilot, ~500 dispatches):

```
<mentor-dir>/
├── MENTOR-KICKOFF.md          # the standing role — SessionStart hook injects it every session
├── process/
│   ├── escalation-boundary.md # what self-resolves vs subagent-verifies vs goes to the human
│   └── PARKING-LOT.md         # verbatim idea capture — the human never holds a mental note
├── dispatch/prompts/          # your authored slice prompts live here
├── .specswarm/conduct/
│   ├── config                 # BUILDER_DIR, MODEL, TIMEOUT, WATCH_PORTS
│   ├── runs/                  # every dispatch's audit trail
│   └── locks/                 # one-builder-per-tree, mechanically enforced
└── .claude/
    ├── settings.json          # SessionStart hook wired (merged, never clobbered)
    └── hooks/mentor-role.sh   # cats MENTOR-KICKOFF.md into session context
```

## Steps

1. **Resolve inputs.** If `project_name` or `--builder-dir` was not provided, ask the user (AskUserQuestion or plain prompt). The builder dir must be an existing git repo — typically the project checked out *inside* this mentor directory (e.g. `./my-app`). If the intended builder repo doesn't exist yet, stop and have the user clone/create it first.

2. **Run the scaffold** (idempotent — existing files are kept, never overwritten):

```bash
bash "${CLAUDE_PLUGIN_ROOT}/lib/conduct/scaffold.sh" \
  --project-name "<project_name>" \
  --builder-dir "<builder-dir>"
```

3. **Review with the user, then hand off.** Walk them through what was created, then tell them:
   - **Edit `MENTOR-KICKOFF.md`** to taste — it's the live role text, read by the hook on every session start.
   - **Confirm the Standing Authorizations** in `process/escalation-boundary.md` (especially the push-without-approval checkbox — that's their call, not yours).
   - **Set `WATCH_PORTS`** in `.specswarm/conduct/config` if the project runs dev/e2e webservers.
   - **Restart the Claude Code session** in this directory so the SessionStart hook fires — from then on, every session opens already knowing it's the mentor.
   - First dispatch: `/ss:conduct` (it walks the prompt grammar).
   - Recommended: install the **`ss-status` plugin** from this marketplace and run `/ss-status:install` once — the statusline then shows background-builder state in real time (`🔨 building` / `✓ safe to close`), answering "is anything running?" at a glance with no daemon to manage.

## Why the hook matters

Role drift was the pilot's most persistent meta-problem: after every `/clear`, softer signals (memory, handoff files) kept getting out-weighed by the default "implement directly" instinct, forcing a manual kickoff paste as "the strongest signal." The SessionStart hook makes the role load-bearing infrastructure instead of human ceremony — the strongest signal, delivered automatically, every time.
