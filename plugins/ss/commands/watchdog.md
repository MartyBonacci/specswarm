---
description: Background watchdog daemon that monitors a SpecSwarm project for new commits, newly-checked tasks, flagged verifications, and (v7.18.0) mentor→builder conduct runs — pings Marty via ss_notify when something needs attention. Completes the autonomous-execution loop by surviving session restarts and detecting changes even when no Claude Code session is active.
effort: low
args:
  - name: subcommand
    description: One of start, stop, status, logs, once. Default is status if omitted.
    required: false
  - name: --interval
    description: Polling interval in seconds (default 30; minimum 5).
    required: false
  - name: --with-verify
    description: EXPERIMENTAL. On pending verifications, dispatch headless `claude --print` to run /ss:verify. Burns tokens; off by default. May need adjustment per Claude Code version.
    required: false
  - name: --tail
    description: Number of log lines to tail with `logs` subcommand. Default 40.
    required: false
---

# SpecSwarm Watchdog Daemon

Background bash process that polls the project's git + verify-queue state and pings Marty when something needs attention. Completes v7.4.0's verification loop by surviving session restarts — when a Claude session ends with pending verifications, the watchdog notices and surfaces them.

Per-project: each project has its own watchdog (state lives in `.specswarm/watchdog.{pid,log,state}`). Stop one before starting another in the same project.

## Subcommand dispatch

```bash
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${PLUGIN_DIR}/lib/watchdog/state.sh"

# Parse args
SUBCOMMAND="status"
INTERVAL=30
WITH_VERIFY=false
TAIL_LINES=40

while [ $# -gt 0 ]; do
  case "$1" in
    --interval)    INTERVAL="$2";    shift 2 ;;
    --with-verify) WITH_VERIFY=true; shift ;;
    --tail)        TAIL_LINES="$2";  shift 2 ;;
    -h|--help)
      cat <<EOF
Usage: /ss:watchdog [SUBCOMMAND] [options]

Subcommands:
  start    Launch daemon in background (nohup + setsid)
  stop     Send SIGTERM to running daemon; clean up PID file
  status   Show PID, uptime, last check, queue state (default)
  logs     Tail the watchdog log file
  once     Run a single check cycle in the foreground (debugging)

Options:
  --interval N      Polling interval in seconds (default 30; min 5)
  --with-verify     EXPERIMENTAL — dispatch headless \`claude --print\` on
                    pending verifications. Burns tokens; off by default.
  --tail N          Lines to tail with the logs subcommand (default 40)

State lives at: .specswarm/watchdog.{pid,log,state}

Examples:
  /ss:watchdog start
  /ss:watchdog start --interval 60
  /ss:watchdog start --with-verify
  /ss:watchdog status
  /ss:watchdog logs --tail 100
  /ss:watchdog once   # foreground test
  /ss:watchdog stop
EOF
      exit 0
      ;;
    start|stop|status|logs|once)
      SUBCOMMAND="$1"
      shift
      ;;
    *)
      echo "❌ Unknown argument: $1 (try /ss:watchdog --help)" >&2
      exit 2
      ;;
  esac
done

# Enforce minimum interval
if [ "$INTERVAL" -lt 5 ]; then
  echo "❌ --interval must be ≥5 seconds (got $INTERVAL)" >&2
  exit 2
fi

PID_FILE=$(ss_watchdog_pid_file)
LOG_FILE=$(ss_watchdog_log_file)
STATE_FILE=$(ss_watchdog_state_file)
RUN_SCRIPT="${PLUGIN_DIR}/lib/watchdog/run.sh"
CHECK_SCRIPT="${PLUGIN_DIR}/lib/watchdog/check-cycle.sh"
```

## `start` — launch the daemon

```bash
case "$SUBCOMMAND" in
  start)
    if ss_watchdog_is_running; then
      EXISTING_PID=$(cat "$PID_FILE" 2>/dev/null)
      echo "⚠️  Watchdog already running (pid=${EXISTING_PID})."
      echo "    Run \`/ss:watchdog stop\` first to restart with different options."
      exit 1
    fi

    # Initialize state file with current options
    ss_watchdog_state_init "$INTERVAL" "$WITH_VERIFY"

    # Launch detached. nohup + setsid + disown ensures survival across:
    #   - Terminal close (nohup ignores SIGHUP)
    #   - Session leader changes (setsid)
    #   - Shell exit (disown removes from shell's job table)
    nohup setsid bash "$RUN_SCRIPT" </dev/null >> "$LOG_FILE" 2>&1 &
    NEW_PID=$!
    disown 2>/dev/null || true

    # Give the daemon a moment to write its PID
    sleep 0.5

    if ss_watchdog_is_running; then
      echo "✅ Watchdog started"
      echo "   pid:          $(cat "$PID_FILE")"
      echo "   interval:     ${INTERVAL}s"
      echo "   with_verify:  ${WITH_VERIFY}"
      echo "   log:          ${LOG_FILE}"
      echo ""
      echo "Tail the log with: /ss:watchdog logs"
      echo "Stop with:         /ss:watchdog stop"
    else
      echo "❌ Watchdog failed to start. Check ${LOG_FILE}"
      exit 1
    fi
    ;;
```

## `stop` — graceful shutdown

```bash
  stop)
    if ! ss_watchdog_is_running; then
      echo "ℹ️  No watchdog running (no PID file or stale)."
      exit 0
    fi
    PID=$(cat "$PID_FILE")
    echo "Stopping watchdog (pid=${PID})..."
    kill "$PID" 2>/dev/null || true

    # Wait up to 3s for clean exit
    for _ in 1 2 3 4 5 6; do
      if ! kill -0 "$PID" 2>/dev/null; then
        break
      fi
      sleep 0.5
    done

    if kill -0 "$PID" 2>/dev/null; then
      echo "⚠️  Daemon didn't exit cleanly; sending SIGKILL"
      kill -9 "$PID" 2>/dev/null || true
    fi

    rm -f "$PID_FILE" 2>/dev/null || true
    echo "✅ Watchdog stopped"
    ;;
```

## `status` — show current state

```bash
  status)
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "SpecSwarm watchdog status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if ss_watchdog_is_running; then
      PID=$(cat "$PID_FILE")
      echo "  state:       🟢 running"
      echo "  pid:         ${PID}"
    else
      echo "  state:       ⚫ stopped"
    fi
    echo "  pid_file:    ${PID_FILE}"
    echo "  log_file:    ${LOG_FILE}"
    echo "  state_file:  ${STATE_FILE}"
    echo ""

    if [ -f "$STATE_FILE" ]; then
      echo "Persisted state:"
      while IFS='=' read -r k v; do
        [ -z "$k" ] && continue
        printf "  %-22s %s\n" "$k" "$v"
      done < "$STATE_FILE"
    else
      echo "(no state file yet — daemon hasn't run a cycle)"
    fi
    ;;
```

## `logs` — tail the log

```bash
  logs)
    if [ ! -f "$LOG_FILE" ]; then
      echo "(no log file at ${LOG_FILE})"
      exit 0
    fi
    tail -n "$TAIL_LINES" "$LOG_FILE"
    ;;
```

## `once` — single foreground check (debugging)

```bash
  once)
    echo "Running one check cycle (foreground)..."
    bash "$CHECK_SCRIPT"
    echo ""
    echo "Done. See ${LOG_FILE} for any events logged."
    ;;
esac
```

## How the watchdog integrates with the v7 toolchain

| Stage | Signal source | Watchdog action |
|---|---|---|
| New commit lands | `git rev-parse HEAD` differs | log; if `tasks.md` touched, auto-enqueue via detect-completion |
| Task flipped to `[X]` | tasks.md commit + detect-completion | `.specswarm/verify-queue/T###.pending` written |
| Pending grows | queue file count | log; ss_notify info on growth |
| Flagged appears | `.specswarm/verify-queue/*.flagged` | **ss_notify urgent** (this is the high-signal Marty cares about) |
| `--with-verify` on + pending exists | (above) plus opt-in | **headless `claude --print` dispatch of /ss:verify** (experimental) |
| Conduct run finishes | `runs/<ts>-<name>/exit-code` appears | ss_notify success (exit 0 + result) / **urgent** (died, or clean-exit-empty-result — the uncommitted-work tell) |
| Orphan listener, no run active | `WATCH_PORTS` in conduct config | **ss_notify urgent** — leftover server from a killed builder |

**Conduct monitoring (v7.18.0)** is zero-config: it activates whenever `.specswarm/conduct/` exists in the watchdog's directory (created by `/ss:mentor-init`, used by `/ss:conduct`). On first start in an established mentor dir it seeds silently from prior runs — no history replay. This is the push status surface that answers "do we have a background process running?" before the human asks.

The watchdog completes v7.4.0's verification loop by handling the "Claude session ended; nothing pending was processed" case. It surfaces accumulating work even when nothing's actively building.

## Operational considerations

- **One daemon per project.** PID-file check prevents duplicates within a project. Different projects can each run their own watchdog.
- **Log rotation.** Auto-truncates at 1 MB. Keeps last 1 MB.
- **Polling interval.** Default 30s. Minimum 5s. For most projects 30s is fine — git polling is cheap.
- **Resource use.** The daemon mostly sleeps. Each check cycle runs in milliseconds unless `--with-verify` dispatches headless Claude.
- **Surviving system restart.** v7.9.0 doesn't auto-restart on reboot. Re-run `/ss:watchdog start` after restart. (A systemd unit template could land in a future version.)
- **`--with-verify` is experimental.** It assumes the `claude` CLI is in PATH and supports `--print`. If your Claude Code version differs, the dispatch may fail silently (logged but not fatal).

## Project-agnostic guarantees

- No hardcoded paths (state lives under repo root's `.specswarm/`)
- Skips silently if not in a git repo (`git rev-parse HEAD` returns empty)
- All hook integrations are optional — watchdog works even if no verify-queue exists yet
- ss_notify graceful fallback (notifier plugin → notify-send → osascript → bell)
- Works on Linux + macOS (bash + git + sleep + nohup + setsid)
