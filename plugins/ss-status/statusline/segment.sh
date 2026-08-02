#!/bin/bash
# ss-status segment — background-builder status for SpecSwarm conduct dispatches.
#
# Reads the statusline JSON on stdin (uses workspace.current_dir), inspects the
# project's .specswarm/conduct/{locks,runs}, and prints ONE short line:
#
#   🔨 building: ff2 12m            a dispatch is running (lock held)
#   💀 last build DIED: ff2 (124)   most recent run exited non-zero
#   ✓ builders idle — safe to close conduct dir exists, nothing running, last run ok
#   (empty)                         no conduct dir here — stay silent
#
# Designed to be cheap (<20ms): file stats + one flock probe per lock. Safe to
# run every refreshInterval tick. Composable: call it from any statusline.
set -u

input=$(cat 2>/dev/null || true)

# cwd from the statusline JSON (jq if present, grep fallback), else $PWD
cwd=""
if command -v jq >/dev/null 2>&1; then
  cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty' 2>/dev/null)
else
  cwd=$(printf '%s' "$input" | grep -o '"current_dir"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
fi
[ -z "$cwd" ] && cwd="$PWD"

CONDUCT="$cwd/.specswarm/conduct"
[ -d "$CONDUCT" ] || exit 0

C() { printf '\033[%sm' "$1"; }
RST=$(printf '\033[0m')

# ── Running? A held lock is the ground truth (flock -n fails ⇒ a dispatch owns it)
running=""
if [ -d "$CONDUCT/locks" ]; then
  for lock in "$CONDUCT"/locks/*.lock; do
    [ -f "$lock" ] || continue
    if ! flock -n -x "$lock" -c true 2>/dev/null < "$lock"; then
      name=$(grep -o 'name=[^ ]*' "$lock" 2>/dev/null | head -1 | cut -d= -f2)
      started=$(grep -o 'started=[^ ]*' "$lock" 2>/dev/null | head -1 | cut -d= -f2)
      mins=""
      if [ -n "$started" ]; then
        s=$(date -d "$started" +%s 2>/dev/null || echo "")
        [ -n "$s" ] && mins=" $(( ($(date +%s) - s) / 60 ))m"
      fi
      running="${running:+$running, }${name:-?}${mins}"
    fi
  done
fi

if [ -n "$running" ]; then
  printf '🔨 %sbuilding: %s%s' "$(C '38;5;215')" "$running" "$RST"   # peach — do NOT close
  exit 0
fi

# ── Idle: report the most recent finalized run's outcome
latest=""
if [ -d "$CONDUCT/runs" ]; then
  latest=$(ls -td "$CONDUCT"/runs/*/ 2>/dev/null | head -1)
fi
if [ -n "$latest" ] && [ -f "$latest/exit-code" ]; then
  ec=$(cat "$latest/exit-code" 2>/dev/null)
  if [ "$ec" != "0" ]; then
    rname=$(basename "$latest" | sed 's/^[0-9]\{8\}-[0-9]\{6\}-//')
    printf '💀 %slast build DIED: %s (exit %s) — check the tree%s' "$(C '38;5;203')" "$rname" "$ec" "$RST"
    exit 0
  fi
fi

printf '✓ %sbuilders idle — safe to close%s' "$(C '38;5;158')" "$RST"   # mint green
