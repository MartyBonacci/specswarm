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

# ── Session shells: work running INSIDE this session (gate suites, batteries).
# These are children of this session's claude process and DIE WITH IT — so
# "safe to close" must be false while any exist. The builder-lock check alone
# missed this: 2026-08-02, the mentor's verification suite ran in a background
# shell while the segment said "safe to close". Ancestry walk finds our claude
# process; any OTHER descendant shell of it is live session work. Linux /proc
# only (degrades gracefully elsewhere; deliberately detached processes —
# setsid batteries — escape ancestry and correctly don't count).
session_shells=0
if [ -d /proc ]; then
  ANC=" $$ "; claude_pid=""; _p=$$
  while [ "${_p:-1}" -gt 1 ]; do
    _p=$(awk '{print $4}' "/proc/$_p/stat" 2>/dev/null) || break
    [ -n "$_p" ] || break
    ANC="${ANC}${_p} "
    # Match the claude BINARY itself (comm or argv0 basename) — matching the
    # word "claude" anywhere in cmdline would false-match our own wrapper's
    # ~/.claude/... path and root the walk at the wrong process.
    if [ -z "$claude_pid" ]; then
      _comm=$(cat "/proc/$_p/comm" 2>/dev/null)
      _arg0=$(tr '\0' '\n' < "/proc/$_p/cmdline" 2>/dev/null | head -1)
      case "${_comm}:${_arg0##*/}" in
        claude:*|*:claude) claude_pid="$_p" ;;
      esac
    fi
  done
  if [ -n "$claude_pid" ]; then
    # self_root = OUR branch's top-level pid directly under claude. Excluding
    # its whole SUBTREE (not just the ancestor chain) keeps the statusline's
    # own wrapper/segment/pipeline subshells from counting themselves.
    self_root=""
    for a in $ANC; do
      appid=$(awk '{print $4}' "/proc/$a/stat" 2>/dev/null)
      [ "$appid" = "$claude_pid" ] && { self_root="$a"; break; }
    done
    # Real Bash-tool shells carry a precise fingerprint: they source
    # ~/.claude/shell-snapshots/snapshot-*. Persistent MCP server wrappers
    # (sh -c "...-mcp") and other machinery don't — this is what separates
    # "work in flight" from session plumbing.
    session_shells=$(ps -eo pid=,ppid=,args= 2>/dev/null | awk -v root="$claude_pid" -v selfroot="$self_root" '
      { pid=$1; par=$2; ppid[pid]=par; if (index($0, "shell-snapshots/snapshot-")) snap[pid]=1 }
      END {
        n=0
        for (p in snap) {
          q=p; d=0
          while ((q in ppid) && d < 50) {
            if (q == selfroot && selfroot != "") break   # our own subtree
            q=ppid[q]; d++
            if (q == root) { n++; break }
          }
        }
        print n
      }')
  fi
fi
if [ "${session_shells:-0}" -gt 0 ]; then
  if [ "$session_shells" -gt 1 ]; then
    printf '⚙ %s%s session shells running — closing kills them%s' "$(C '38;5;222')" "$session_shells" "$RST"   # gold
  else
    printf '⚙ %ssession work running — closing kills it%s' "$(C '38;5;222')" "$RST"
  fi
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
