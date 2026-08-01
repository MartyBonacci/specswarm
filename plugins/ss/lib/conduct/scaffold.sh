#!/usr/bin/env bash
# SpecSwarm Mentor Scaffold (v7.18.0)
#
# Stamps out a mentor directory: the kickoff role file, escalation boundary,
# parking lot, conduct config, and the SessionStart hook that makes the mentor
# role structural (not a paste-after-every-/clear ritual).
#
# Usage:
#   scaffold.sh --project-name <name> --builder-dir <path> [--target <dir>]
#
# Idempotent: existing files are never overwritten (reported as "kept").
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.." && pwd)"
TEMPLATES="${PLUGIN_DIR}/templates/mentor"

PROJECT_NAME=""
BUILDER_DIR=""
TARGET="$PWD"
while [ $# -gt 0 ]; do
  case "$1" in
    --project-name) PROJECT_NAME="$2"; shift 2 ;;
    --builder-dir)  BUILDER_DIR="$2";  shift 2 ;;
    --target)       TARGET="$2";       shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$PROJECT_NAME" ] || [ -z "$BUILDER_DIR" ]; then
  echo "usage: scaffold.sh --project-name <name> --builder-dir <path> [--target <dir>]" >&2
  exit 2
fi
if [ ! -d "$BUILDER_DIR" ] || [ ! -e "$BUILDER_DIR/.git" ]; then
  echo "ERROR: --builder-dir '$BUILDER_DIR' is not an existing git tree" >&2
  exit 2
fi
BUILDER_DIR="$(readlink -f "$BUILDER_DIR")"
mkdir -p "$TARGET"
TARGET="$(readlink -f "$TARGET")"

CREATED=()
KEPT=()

# __stamp <template> <dest> — instantiate a template unless dest exists
__stamp() {
  local tpl="$1" dest="$2"
  if [ -e "$dest" ]; then
    KEPT+=("$dest")
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  sed -e "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" \
      -e "s|{{BUILDER_DIR}}|${BUILDER_DIR}|g" \
      "$tpl" > "$dest"
  CREATED+=("$dest")
}

__stamp "${TEMPLATES}/mentor-kickoff.template.md"      "${TARGET}/MENTOR-KICKOFF.md"
__stamp "${TEMPLATES}/escalation-boundary.template.md" "${TARGET}/process/escalation-boundary.md"
__stamp "${TEMPLATES}/parking-lot.template.md"         "${TARGET}/process/PARKING-LOT.md"
__stamp "${TEMPLATES}/conduct-config.template"         "${TARGET}/.specswarm/conduct/config"
__stamp "${TEMPLATES}/mentor-role-hook.template.sh"    "${TARGET}/.claude/hooks/mentor-role.sh"
chmod +x "${TARGET}/.claude/hooks/mentor-role.sh" 2>/dev/null || true

mkdir -p "${TARGET}/.specswarm/conduct/runs" "${TARGET}/.specswarm/conduct/locks" \
         "${TARGET}/dispatch/prompts"

# ── Wire the SessionStart hook into .claude/settings.json ────────────────────
# Merge, never clobber: python3 preserves whatever hooks/settings already exist
# and is a no-op if our hook command is already registered.
SETTINGS="${TARGET}/.claude/settings.json"
HOOK_RESULT=$(python3 - "$SETTINGS" <<'PYEOF'
import json, os, sys
path = sys.argv[1]
cmd = "$CLAUDE_PROJECT_DIR/.claude/hooks/mentor-role.sh"
data = {}
if os.path.exists(path):
    try:
        with open(path) as f:
            data = json.load(f)
    except Exception:
        print("unparseable")   # never risk clobbering a hand-edited file
        sys.exit(0)
hooks = data.setdefault("hooks", {})
entries = hooks.setdefault("SessionStart", [])
for e in entries:
    for h in e.get("hooks", []):
        if h.get("command") == cmd:
            print("already-wired")
            sys.exit(0)
entries.append({"hooks": [{"type": "command", "command": cmd}]})
with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
print("wired")
PYEOF
)

echo "Mentor scaffold for '${PROJECT_NAME}' → ${TARGET}"
echo "  builder tree: ${BUILDER_DIR}"
for f in "${CREATED[@]:-}"; do [ -n "$f" ] && echo "  created: ${f#"$TARGET"/}"; done
for f in "${KEPT[@]:-}";    do [ -n "$f" ] && echo "  kept:    ${f#"$TARGET"/} (existing, untouched)"; done
case "$HOOK_RESULT" in
  wired)         echo "  hook:    SessionStart mentor-role hook wired into .claude/settings.json" ;;
  already-wired) echo "  hook:    SessionStart mentor-role hook already wired" ;;
  unparseable)   echo "  hook:    ⚠️  .claude/settings.json exists but is not valid JSON — add this hook manually:"
                 echo '           {"hooks":{"SessionStart":[{"hooks":[{"type":"command","command":"$CLAUDE_PROJECT_DIR/.claude/hooks/mentor-role.sh"}]}]}}' ;;
esac
