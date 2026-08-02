---
description: Restore the statusline configuration exactly as it was before /ss-status:install — the saved original statusLine settings entry is put back (or removed, if none existed before).
effort: low
---

# ss-status uninstall

```bash
bash "${CLAUDE_PLUGIN_ROOT}/lib/install.sh" uninstall
```

Confirm to the user what was restored. The helper scripts remain in `~/.claude/ss-status/` (harmless, unreferenced); mention they can delete that directory if they want a full cleanup.
