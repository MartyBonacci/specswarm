---
description: One-time install of the SpecSwarm status line. Preserves and wraps your existing statusline if you have one (it becomes the cached base), adds the real-time background-builder segment (🔨 building / 💀 died / ✓ safe to close), and sets a refreshInterval so status updates even while the session is idle. Fully reversible with /ss-status:uninstall.
effort: low
args:
  - name: --refresh
    description: Refresh interval in seconds (default 5, minimum 1). How often the statusline re-renders while idle.
    required: false
---

# ss-status install

Run the installer, then explain what happened:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/lib/install.sh" install
```

(Pass `--refresh N` through if the user gave it.)

Then tell the user, briefly:

- **What they'll see:** their statusline exactly as before, plus one extra line in SpecSwarm conduct projects — `🔨 building: <name> <elapsed>` while a builder dispatch runs, `💀 last build DIED (exit N)` if the most recent run failed, `✓ builders idle — safe to close` otherwise. In projects with no `.specswarm/conduct/`, nothing changes at all.
- **The point:** "is it safe to shut down or close this session?" is now answered at a glance, in real time — no daemon, nothing to restart after a reboot.
- **How it stays cheap:** the wrapper re-renders their (potentially heavy) base statusline at most once per minute from cache, while the builder segment — a few file checks — refreshes every tick.
- **Reversal:** `/ss-status:uninstall` restores their exact previous configuration.

If the installer reported "wrapped existing statusline", confirm which script is now the base so the user knows nothing was lost.
