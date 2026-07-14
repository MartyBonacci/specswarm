#!/bin/bash
# SpecSwarm Overnight Resilience (v7.15.0 — AUTO-MAGIC WS6)
#
# Pure, testable functions for headless-run hardening. Single-turn headless
# runs (`claude --print`) die three observed ways:
#   (1) timeout mid-slice — work stranded uncommitted in the tree
#   (2) API/connection error — truncated result
#   (3) yield-await — the run backgrounds its own gates and ends its turn
#       "awaiting completion" that never comes
# This exact recovery protocol (classify → point at in-tree work → order a
# critical self-review of the half-done diff → complete + commit) recovered
# 3/3 real production failures.
#
# Public API:
#   ss_overnight_prompt_clauses
#     Echoes the hardening clauses injected into EVERY dispatched headless
#     prompt (overnight runner AND watchdog --with-verify share this).
#
#   ss_overnight_build_prompt <feature_id> <feature_dir> <feature_num>
#     Echoes the full autonomous prompt (strict rules + clauses + workflow).
#
#   ss_overnight_classify <exit_code> <output_file> <commits_added> <dirty_count>
#     Echoes exactly one failure-mode token:
#       success | partial | timeout-stranded | timeout | api-error |
#       yield-await | blocked
#
#   ss_overnight_is_resumable <mode>
#     Exit 0 for modes the resume protocol can recover
#     (timeout-stranded, api-error, yield-await).
#
#   ss_overnight_build_resume_prompt <mode> <feature_id> <feature_dir> <feature_num> <dirty_count>
#     Echoes the auto-authored resume prompt: names the failure mode, points
#     at the in-tree work, orders a critical self-review of the half-done
#     diff, then complete + commit.

set -e

ss_overnight_prompt_clauses() {
  cat <<'EOF'
EXECUTION DISCIPLINE (these two clauses exist because runs died without them):
- Run EVERY gate (build, lint, tests, verification) SYNCHRONOUSLY inside your
  turn. NEVER background a gate and end your turn "awaiting completion" — in a
  headless run there is no next turn; an awaited background task is a dead run.
- Budget honestly: if you sense you are nearing the turn/time limit, STOP
  starting new tasks, commit all completed work, and print an honest partial
  report (OVERNIGHT_RESULT: partial <what's done / what's left>). Never die
  silent with work stranded uncommitted in the tree.
EOF
}

ss_overnight_build_prompt() {
  local feature_id="$1"
  local feature_dir="$2"
  local feature_num="$3"

  cat <<EOF
You are running an autonomous SpecSwarm overnight chunk for feature ${feature_id}.

Pre-conditions verified by /ss:overnight preflight:
- spec.md, plan.md, tasks.md are present
- decision-sheet.md is locked (read it for any decision you need to make)
- Git working tree is clean (or --allow-dirty acknowledged)

STRICT RULES (read these twice):
1. Do NOT call AskUserQuestion under any circumstances. If a strategic
   decision arises that isn't already locked in
   ${feature_dir}/decision-sheet.md, STOP work, write a short
   summary to ${feature_dir}/overnight-unanswered.md describing what
   couldn't be answered, and exit. The user will resolve it in the morning.

2. Do NOT run /ss:ship. Squash merge requires human sign-off. Leave the
   feature branch ready for /ss:ship.

3. Do NOT push to origin. Commits stay local for morning review.

$(ss_overnight_prompt_clauses)

WORKFLOW (run in order; stop and exit at first failure):
  1. /ss:preflight ${feature_num}       — deterministic checks (any FAIL → exit early)
  2. /ss:implement                      — execute tasks from tasks.md
  3. /ss:verify --all                   — adversarial verification per task
  4. /ss:retrospective ${feature_num}   — distill lessons into memory

At the end, print a single-line summary:
  OVERNIGHT_RESULT: <success|partial|blocked> <one-line notes>

The user has stepped away for the night. They are not watching this run.
EOF
}

ss_overnight_classify() {
  local exit_code="$1"
  local output_file="$2"
  local commits_added="${3:-0}"
  local dirty_count="${4:-0}"

  case "$exit_code" in
    124|143)
      if [ "$dirty_count" -gt 0 ]; then
        echo "timeout-stranded"
      else
        echo "timeout"
      fi
      return 0
      ;;
    0) : ;;
    *)
      echo "api-error"
      return 0
      ;;
  esac

  # exit 0 — read the result line
  local result_line=""
  [ -f "$output_file" ] && result_line=$(grep -E '^OVERNIGHT_RESULT:' "$output_file" 2>/dev/null | tail -n1)

  if echo "$result_line" | grep -q 'success'; then
    echo "success"
  elif echo "$result_line" | grep -q 'partial'; then
    echo "partial"
  elif [ "$commits_added" -gt 0 ]; then
    echo "partial"
  else
    # Exit 0, no result line, zero commits. If the tree is dirty or the output
    # is empty/ends awaiting something, this is the yield-await signature:
    # the run backgrounded its gates and ended its turn.
    local out_size=0
    [ -f "$output_file" ] && out_size=$(wc -c < "$output_file")
    if [ "$dirty_count" -gt 0 ] || [ "$out_size" -lt 200 ] \
       || grep -qiE 'background|running in the background|awaiting|will (check|report) back|once (it|the .*) (completes|finishes)' "$output_file" 2>/dev/null; then
      echo "yield-await"
    else
      echo "blocked"
    fi
  fi
}

ss_overnight_is_resumable() {
  case "$1" in
    timeout-stranded|api-error|yield-await) return 0 ;;
    *) return 1 ;;
  esac
}

ss_overnight_build_resume_prompt() {
  local mode="$1"
  local feature_id="$2"
  local feature_dir="$3"
  local feature_num="$4"
  local dirty_count="${5:-0}"

  local mode_desc
  case "$mode" in
    timeout-stranded) mode_desc="the previous run hit its wall-clock timeout mid-slice, leaving work stranded uncommitted in the tree" ;;
    api-error)        mode_desc="the previous run died on an API/connection error, so its result was truncated" ;;
    yield-await)      mode_desc="the previous run backgrounded its own gates and ended its turn awaiting a completion that never came (yield-await)" ;;
    *)                mode_desc="the previous run ended abnormally (${mode})" ;;
  esac

  cat <<EOF
You are RESUMING an interrupted autonomous SpecSwarm overnight chunk for
feature ${feature_id}. Failure mode: ${mode} — ${mode_desc}.

THE TREE CONTAINS IN-PROGRESS WORK (${dirty_count} uncommitted path(s)).
Run \`git status --porcelain\` and \`git diff\` FIRST — that diff is the
half-done work of a run that died mid-thought. Do not assume it is correct
and do not blindly discard it.

RECOVERY PROTOCOL (this exact protocol recovered 3/3 real failures):
1. Read ${feature_dir}/tasks.md to see which tasks are checked vs not.
2. CRITICALLY REVIEW the in-tree diff against the task it appears to belong
   to and the relevant plan.md/spec.md sections. Treat it as a suspect
   contribution from a stranger: half-applied edits, missing counterparts,
   truncated files are all likely.
3. Complete or repair the half-done work, run the gates SYNCHRONOUSLY
   (never background-and-await — that is how the last run died), and COMMIT.
4. Then continue the normal workflow where it left off:
   /ss:implement remaining tasks → /ss:verify --all → /ss:retrospective ${feature_num}.

$(ss_overnight_prompt_clauses)

STRICT RULES still apply: no AskUserQuestion (decisions are locked in
${feature_dir}/decision-sheet.md; unanswerable → write
${feature_dir}/overnight-unanswered.md and exit), no /ss:ship, no push.

At the end, print: OVERNIGHT_RESULT: <success|partial|blocked> <one-line notes>
EOF
}
