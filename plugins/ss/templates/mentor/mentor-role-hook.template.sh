#!/bin/bash
# SessionStart hook — injects the mentor role into every session (installed by
# /ss:mentor-init). Role drift after /clear was a persistent pilot problem: the
# "implement directly" instinct kept out-weighing softer signals, so the full
# kickoff text rides in as session context, structurally, every time.
KICKOFF="$(cd "$(dirname "$0")/../.." && pwd)/MENTOR-KICKOFF.md"
if [ -f "$KICKOFF" ]; then
  cat "$KICKOFF"
fi
exit 0
