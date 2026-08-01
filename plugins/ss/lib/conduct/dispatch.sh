#!/usr/bin/env bash
# SpecSwarm Conduct Dispatcher (v7.18.0)
#
# Mentor→builder headless dispatch: sends a prompt (stdin) to a headless
# `claude --print` run inside the builder repo, capturing everything for audit.
#
# Extracted from the Custom Cult v3 mentor pilot (2026-06-10 → 2026-08-01,
# ~500 audited dispatches). Every hardening mechanism below exists because a
# real incident demanded it — the WHY comments are the incident record. Do not
# simplify them away without re-reading the failure-modes section of
# commands/conduct.md.
#
# Usage:
#   dispatch.sh <name> [--dir <tree>] [--resume <session_id>] [--timeout <secs>]
#               [--model <m>] [--perm <mode>] [--config <file>] < prompt.md
#
# Config file (default: $PWD/.specswarm/conduct/config, KEY=VALUE):
#   BUILDER_DIR=/abs/path/to/builder/repo   (required unless --dir given)
#   MODEL=opus                              (default opus)
#   PERM_MODE=bypassPermissions             (default bypassPermissions)
#   TIMEOUT=3600                            (default 3600)
#   WATCH_PORTS=3000 3100 3200              (optional; orphan-listener sweep)
#
# Output dir: .specswarm/conduct/runs/<ts>-<name>/
#   {prompt.md, output.json, result.md, stderr.log, tree.txt, meta, exit-code}
# The `meta` + `exit-code` files are the watchdog's completion signal.
#
# Exit codes: builder's exit (0 ok), 124 timeout, 2 usage/config, 3 tree busy.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.." && pwd)"
CONDUCT_ROOT="${SS_CONDUCT_ROOT:-$PWD/.specswarm/conduct}"
CONFIG_FILE="${CONDUCT_ROOT}/config"

# Optional notification on terminal states (graceful no-op if lib absent)
# shellcheck disable=SC1091
[ -f "${PLUGIN_DIR}/lib/notify.sh" ] && source "${PLUGIN_DIR}/lib/notify.sh"

NAME="${1:?usage: dispatch.sh <name> [--dir tree] [--resume id] [--timeout secs] [--model m] [--perm mode] < prompt.md}"
shift

__cfg() {
  # __cfg KEY — read a key from the config file (empty if missing)
  [ -f "$CONFIG_FILE" ] || return 0
  grep -E "^${1}=" "$CONFIG_FILE" 2>/dev/null | head -n1 | cut -d= -f2-
}

BUILDER_DIR=""
RESUME=""
TIMEOUT=""
MODEL=""
PERM_MODE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --dir)     BUILDER_DIR="$2"; shift 2 ;;
    --resume)  RESUME="$2";      shift 2 ;;
    --timeout) TIMEOUT="$2";     shift 2 ;;
    --model)   MODEL="$2";       shift 2 ;;
    --perm)    PERM_MODE="$2";   shift 2 ;;
    --config)  CONFIG_FILE="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

# Flag > config > default. MODEL is PINNED to opus by default so the headless
# builder never inherits a session's roaming /model default (a session-only
# model alias was inaccessible headless in the pilot, 2026-06). PERM_MODE
# defaults to bypassPermissions: builders need git commit/branch/push + package
# managers + db headlessly; acceptEdits only covers file writes (gated git).
BUILDER_DIR="${BUILDER_DIR:-$(__cfg BUILDER_DIR)}"
MODEL="${MODEL:-$(__cfg MODEL)}";         MODEL="${MODEL:-opus}"
PERM_MODE="${PERM_MODE:-$(__cfg PERM_MODE)}"; PERM_MODE="${PERM_MODE:-bypassPermissions}"
TIMEOUT="${TIMEOUT:-$(__cfg TIMEOUT)}";   TIMEOUT="${TIMEOUT:-3600}"
WATCH_PORTS="$(__cfg WATCH_PORTS)"

if [ -z "$BUILDER_DIR" ]; then
  echo "ERROR: no builder dir — pass --dir or set BUILDER_DIR in ${CONFIG_FILE} (run /ss:mentor-init)" >&2
  exit 2
fi
# --dir sanity: must be an existing git tree (plain repo or worktree — .git may
# be a dir or a file).
if [ ! -d "$BUILDER_DIR" ] || [ ! -e "$BUILDER_DIR/.git" ]; then
  echo "ERROR: builder dir '$BUILDER_DIR' is not an existing git tree" >&2
  exit 2
fi
BUILDER_DIR="$(readlink -f "$BUILDER_DIR")"

# ── Per-tree lock (one builder per tree, mechanically enforced) ──────────────
# WHY: two builders in one tree race each other's git state. The pilot's AM10f
# incident: a zombie builder's `git stash -u … stash pop` wiped the tree out
# from under the next dispatch mid-review. flock makes the standing rule
# structural: a second dispatch into the SAME tree fails fast, naming the holder.
LOCK_DIR="${CONDUCT_ROOT}/locks"
mkdir -p "$LOCK_DIR"
LOCK_FILE="${LOCK_DIR}/$(basename "$BUILDER_DIR")-$(printf '%s' "$BUILDER_DIR" | md5sum | cut -c1-8).lock"
exec 9>>"$LOCK_FILE"
if ! flock -n 9; then
  echo "ERROR: tree busy — another dispatch holds ${LOCK_FILE}:" >&2
  cat "$LOCK_FILE" >&2 || true
  exit 3
fi
# We own the lock: record the holder (truncate via a fresh write; fd 9 stays the lock).
printf 'tree=%s name=%s pid=%s started=%s\n' "$BUILDER_DIR" "$NAME" "$$" "$(date -Is)" > "$LOCK_FILE"

TS=$(date +%Y%m%d-%H%M%S)
RUN_DIR="${CONDUCT_ROOT}/runs/${TS}-${NAME}"
mkdir -p "$RUN_DIR"
cat > "$RUN_DIR/prompt.md"   # prompt arrives on stdin
printf 'builder_dir: %s\n' "$BUILDER_DIR" > "$RUN_DIR/tree.txt"
{
  printf 'name=%s\n'       "$NAME"
  printf 'tree=%s\n'       "$BUILDER_DIR"
  printf 'model=%s\n'      "$MODEL"
  printf 'perm_mode=%s\n'  "$PERM_MODE"
  printf 'timeout=%s\n'    "$TIMEOUT"
  printf 'started_at=%s\n' "$(date -Is)"
} > "$RUN_DIR/meta"

ARGS=(--print --output-format json --model "$MODEL")
[ -n "$RESUME" ]    && ARGS+=(--resume "$RESUME")
[ -n "$PERM_MODE" ] && ARGS+=(--permission-mode "$PERM_MODE")

cd "$BUILDER_DIR"
set +e
# Run the builder as its own PROCESS-GROUP leader (set -m) so a timeout can
# reap the WHOLE tree. WHY: `timeout --signal=TERM claude` only signals the
# claude process itself; in the pilot its node children survived a timeout and
# kept mutating the repo for ~20 more minutes, racing the next dispatch on the
# same tree. Group-kill closes that hole.
set -m
claude "${ARGS[@]}" \
  < "$RUN_DIR/prompt.md" > "$RUN_DIR/output.json" 2> "$RUN_DIR/stderr.log" &
BUILDER_PID=$!
set +m
WAITED=0
while kill -0 "$BUILDER_PID" 2>/dev/null && [ "$WAITED" -lt "$TIMEOUT" ]; do
  sleep 5
  WAITED=$((WAITED + 5))
done
if kill -0 "$BUILDER_PID" 2>/dev/null; then
  echo "timeout after ${TIMEOUT}s — TERM then KILL to process group $BUILDER_PID" >> "$RUN_DIR/stderr.log"
  kill -TERM -- "-$BUILDER_PID" 2>/dev/null
  sleep 20
  kill -KILL -- "-$BUILDER_PID" 2>/dev/null
  EXIT=124
else
  wait "$BUILDER_PID"
  EXIT=$?
fi

# ── Survivor sweep ───────────────────────────────────────────────────────────
# Warn about any process still running with CWD inside THIS builder tree
# (claude children that escaped the group by making their own session — never
# auto-kill; the invoking mentor session itself would match a broad pkill).
# Exclude this script's own ancestor chain (the invoking shell quotes claude/
# dispatch paths in its cmdline and would false-positive). Escaped zombies are
# never our ancestors. Linux-only (/proc walk); skipped elsewhere.
SURVIVORS=""
if [ -d /proc ]; then
  ANCESTORS=" $$ "
  _p=$$
  while [ "$_p" -gt 1 ]; do
    _p=$(awk '{print $4}' "/proc/$_p/stat" 2>/dev/null) || break
    [ -n "$_p" ] || break
    ANCESTORS="${ANCESTORS}${_p} "
  done
  SURVIVORS=$(for p in /proc/[0-9]*; do
    pid="${p#/proc/}"
    case "$ANCESTORS" in *" $pid "*) continue ;; esac
    cwd_path=$(readlink -f "$p/cwd" 2>/dev/null) || cwd_path=""
    case "$cwd_path" in
      "$BUILDER_DIR"*)
        # Only builder-shaped processes (headless claude + its node/tsx/vitest
        # children) — the mentor session's own shells also sit in this cwd and
        # must not trip the warning.
        grep -qaE 'claude.*(--print|[^-]-p)|vitest|tsx|node' "$p/cmdline" 2>/dev/null && echo "$pid"
        ;;
    esac
  done)
  if [ -n "$SURVIVORS" ]; then
    echo "WARNING: processes still alive with CWD in builder tree: $SURVIVORS" | tee -a "$RUN_DIR/stderr.log"
    # shellcheck disable=SC2086
    ps -o pid,ppid,etime,cmd -p $SURVIVORS 2>/dev/null | tee -a "$RUN_DIR/stderr.log"
  fi
fi

# ── Orphan-listener sweep (v7.18.0) ──────────────────────────────────────────
# WHY: timeout-killed builders orphan their e2e webservers; the pilot found
# live listeners squatting test ports after 3 consecutive gate-phase timeouts,
# poisoning the next e2e run. Warn (never auto-kill — the port may be the
# user's own dev server).
if [ -n "$WATCH_PORTS" ]; then
  for port in $WATCH_PORTS; do
    LISTENER=""
    if command -v ss >/dev/null 2>&1; then
      LISTENER=$(ss -tlnp 2>/dev/null | grep -E ":${port}[[:space:]]" || true)
    elif command -v lsof >/dev/null 2>&1; then
      LISTENER=$(lsof -iTCP:"$port" -sTCP:LISTEN 2>/dev/null | tail -n +2 || true)
    fi
    if [ -n "$LISTENER" ]; then
      echo "WARNING: listener still on port ${port} after run:" | tee -a "$RUN_DIR/stderr.log"
      echo "$LISTENER" | tee -a "$RUN_DIR/stderr.log"
    fi
  done
fi
set -e

python3 - "$RUN_DIR" <<'PYEOF'
import json, sys, os
run = sys.argv[1]
try:
    d = json.load(open(os.path.join(run, "output.json")))
    with open(os.path.join(run, "result.md"), "w") as f:
        f.write(d.get("result", "") or "")
    print("session_id:", d.get("session_id"))
    print("turns:", d.get("num_turns"), "| cost_usd:", round(d.get("total_cost_usd", 0) or 0, 4))
    print("is_error:", d.get("is_error"))
except Exception as e:
    print("parse-error:", e)
PYEOF

# Watchdog completion signal — written LAST so exit-code's existence means
# "run fully finalized" (result.md already extracted).
printf 'finished_at=%s\n' "$(date -Is)" >> "$RUN_DIR/meta"
echo "$EXIT" > "$RUN_DIR/exit-code"

if declare -f ss_notify >/dev/null 2>&1; then
  if [ "$EXIT" -eq 0 ] && [ -s "$RUN_DIR/result.md" ]; then
    ss_notify success "SpecSwarm conduct: ${NAME}" "builder run completed — verify before trusting (run: ${RUN_DIR##*/})" || true
  else
    ss_notify urgent "SpecSwarm conduct: ${NAME}" "builder run ended abnormally (exit ${EXIT}) — check the tree for uncommitted work" || true
  fi
fi

echo "exit: $EXIT"
echo "run_dir: $RUN_DIR"
exit "$EXIT"
