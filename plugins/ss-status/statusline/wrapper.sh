#!/bin/bash
# ss-status wrapper — composes the user's base statusline with the SpecSwarm
# background-builder segment, cheaply enough to run on a refreshInterval tick.
#
# The trick: base statuslines are often expensive (ccusage, npm version checks,
# transcript reads), so the base output is CACHED and re-rendered at most every
# BASE_MAX_AGE seconds — while the segment (a few file stats) recomputes every
# tick. Net effect: real-time builder status, no increase in heavy-tool load.
#
# Installed by /ss-status:install to ~/.claude/ss-status/wrapper.sh.
# The base command lives in ~/.claude/ss-status/base-cmd (one line).
set -u

SS_HOME="$HOME/.claude/ss-status"
BASE_CMD_FILE="$SS_HOME/base-cmd"
BASE_MAX_AGE="${SS_STATUS_BASE_MAX_AGE:-60}"

input=$(cat 2>/dev/null || true)

# Per-session cache so parallel sessions don't cross-render each other's base
sid=$(printf '%s' "$input" | grep -o '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
CACHE="$SS_HOME/base-cache-${sid:-default}"

# ── Base statusline (cached) ────────────────────────────────────────────────
base=""
if [ -f "$BASE_CMD_FILE" ]; then
  base_cmd=$(cat "$BASE_CMD_FILE")
  age=99999
  if [ -f "$CACHE" ]; then
    mod=$(stat -c %Y "$CACHE" 2>/dev/null || stat -f %m "$CACHE" 2>/dev/null || echo 0)
    age=$(( $(date +%s) - mod ))
  fi
  if [ "$age" -ge "$BASE_MAX_AGE" ]; then
    printf '%s' "$input" | eval "$base_cmd" > "$CACHE.tmp" 2>/dev/null \
      && mv "$CACHE.tmp" "$CACHE" 2>/dev/null \
      || rm -f "$CACHE.tmp" 2>/dev/null
  fi
  [ -f "$CACHE" ] && base=$(cat "$CACHE")
fi

# ── SpecSwarm segment (always fresh) ────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
segment=$(printf '%s' "$input" | bash "$SCRIPT_DIR/segment.sh" 2>/dev/null || true)

# ── Compose ─────────────────────────────────────────────────────────────────
if [ -n "$base" ]; then
  printf '%s' "$base"
  [ -n "$segment" ] && printf '\n%s' "$segment"
  printf '\n'
elif [ -n "$segment" ]; then
  printf '%s\n' "$segment"
fi
