#!/bin/bash
# ss-status installer — deterministic, idempotent, reversible.
#
# install:   copy scripts to ~/.claude/ss-status/ (stable path that survives
#            plugin version bumps), preserve the user's existing statusLine as
#            the wrapped base, point settings.json at the wrapper with a
#            refreshInterval so the builder segment updates while idle.
# uninstall: restore the exact statusLine config that was saved at install.
#
# Usage: install.sh install [--refresh N] | install.sh uninstall
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
SS_HOME="$HOME/.claude/ss-status"
SETTINGS="$HOME/.claude/settings.json"
MODE="${1:?usage: install.sh install [--refresh N] | install.sh uninstall}"
shift || true
REFRESH=5
while [ $# -gt 0 ]; do
  case "$1" in
    --refresh) REFRESH="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

case "$MODE" in
  install)
    mkdir -p "$SS_HOME"
    cp "$PLUGIN_DIR/statusline/wrapper.sh"  "$SS_HOME/wrapper.sh"
    cp "$PLUGIN_DIR/statusline/segment.sh"  "$SS_HOME/segment.sh"
    cp "$PLUGIN_DIR/statusline/base-statusline.sh" "$SS_HOME/base-statusline.sh"
    chmod +x "$SS_HOME"/*.sh

    python3 - "$SETTINGS" "$SS_HOME" "$REFRESH" <<'PYEOF'
import json, os, sys
settings_path, ss_home, refresh = sys.argv[1], sys.argv[2], int(sys.argv[3])
wrapper = os.path.join(ss_home, "wrapper.sh")

data = {}
if os.path.exists(settings_path):
    with open(settings_path) as f:
        data = json.load(f)          # invalid JSON aborts loudly — never clobber

current = data.get("statusLine")
saved_path = os.path.join(ss_home, "saved-statusline.json")

if current and current.get("command") != wrapper:
    # Preserve the user's statusline: it becomes the wrapped base
    with open(saved_path, "w") as f:
        json.dump(current, f, indent=2)
    with open(os.path.join(ss_home, "base-cmd"), "w") as f:
        f.write(current.get("command", "") + "\n")
    print(f"wrapped existing statusline: {current.get('command')}")
elif not current:
    # No statusline yet: the plugin's bundled full statusline becomes the base
    with open(os.path.join(ss_home, "base-cmd"), "w") as f:
        f.write(os.path.join(ss_home, "base-statusline.sh") + "\n")
    if os.path.exists(saved_path):
        os.remove(saved_path)
    print("no existing statusline — installed the bundled base")
else:
    print("already installed — refreshed scripts and settings")

new_line = {"type": "command", "command": wrapper, "refreshInterval": refresh}
if current and "padding" in current:
    new_line["padding"] = current["padding"]
data["statusLine"] = new_line
with open(settings_path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
print(f"statusLine → {wrapper} (refreshInterval: {refresh}s)")
PYEOF
    echo "✅ ss-status installed. Takes effect immediately (next statusline tick)."
    ;;

  uninstall)
    python3 - "$SETTINGS" "$SS_HOME" <<'PYEOF'
import json, os, sys
settings_path, ss_home = sys.argv[1], sys.argv[2]
saved_path = os.path.join(ss_home, "saved-statusline.json")

with open(settings_path) as f:
    data = json.load(f)

if os.path.exists(saved_path):
    with open(saved_path) as f:
        data["statusLine"] = json.load(f)
    print("restored the pre-install statusline")
else:
    data.pop("statusLine", None)
    print("removed statusLine (none existed before install)")

with open(settings_path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PYEOF
    echo "✅ ss-status uninstalled (scripts left in $SS_HOME; delete manually if desired)."
    ;;

  *) echo "unknown mode: $MODE" >&2; exit 2 ;;
esac
