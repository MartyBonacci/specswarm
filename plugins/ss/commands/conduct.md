---
description: Mentor→builder headless dispatch loop (v7.18.0). Author a slice prompt in the proven grammar, dispatch it to a headless builder in the target repo (opus-pinned, per-tree locked, group-killed on timeout, fully audited), then run the INDEPENDENT verification protocol — commit-hash check, real-diff read, targeted gates — never trusting the builder's self-report. Extracted from the Custom Cult v3 mentor pilot (~500 audited dispatches; every rule below is incident-tested).
effort: medium
args:
  - name: name
    description: Short slug for this dispatch (becomes .specswarm/conduct/runs/<ts>-<name>). Omit to get loop guidance / status.
    required: false
  - name: --prompt-file
    description: Path to the authored slice prompt. If omitted, this command walks you through authoring one first.
    required: false
  - name: --dir
    description: Alternate builder git tree (worktree lane). Default is BUILDER_DIR from .specswarm/conduct/config.
    required: false
  - name: --resume
    description: Builder session_id to resume (from a prior run's output.json) — the recovery path for died runs.
    required: false
  - name: --timeout
    description: Wall-clock budget in seconds. Default 3600. e2e-heavy slices need ≥4500 (75 min) or a TARGETED gate set.
    required: false
  - name: --model
    description: Model for the headless builder. Default opus (pinned — headless cannot inherit the session's roaming model).
    required: false
---

# SpecSwarm Conduct — the mentor→builder dispatch loop

You are operating as a **mentor**: you make decisions, author builder prompts, and verify results. **You do not write the builder repo's application code yourself** — all repo writes route through headless builder dispatches. This separation exists because the verifier must not be the brain that wrote the code.

The loop: **author prompt → dispatch → independent verify → (spec-mentor adversarial pass) → human sighted gate**. The pilot's measured shape: ~9-10 verification commands per dispatch. That ratio is not overhead; it is the load-bearing wall.

## 0. Preconditions

```bash
CONDUCT_ROOT="$PWD/.specswarm/conduct"
if [ ! -f "$CONDUCT_ROOT/config" ]; then
  echo "❌ No conduct config. Run /ss:mentor-init first (scaffolds config + mentor kit)."
  exit 1
fi
cat "$CONDUCT_ROOT/config"
BUILDER_DIR=$(grep -E '^BUILDER_DIR=' "$CONDUCT_ROOT/config" | cut -d= -f2-)

# Tree state BEFORE dispatching — record base commit + branch; you will check
# the builder's report against these.
git -C "$BUILDER_DIR" symbolic-ref -q HEAD
git -C "$BUILDER_DIR" log --oneline -1
git -C "$BUILDER_DIR" status --short

# One builder per tree — if a lock is held, WAIT (never dispatch into a busy tree)
ls "$CONDUCT_ROOT/locks/" 2>/dev/null && cat "$CONDUCT_ROOT"/locks/*.lock 2>/dev/null
```

## 1. Author the prompt (the proven grammar)

Write the prompt to a file (e.g. `dispatch/prompts/<name>.md` or a scratch path) with these sections, in this order. Slices that skip a section earn the failure that section prevents.

1. **Header** — slice name, repo/branch, expected base commit, and verbatim: *"Single-turn run — run every gate SYNCHRONOUSLY in your turn; NEVER background a gate and await its notification (headless runs get no later turns)."*
2. **§0 PRECONDITIONS — verify, don't trust this prompt.** List the facts the builder must confirm against the tree before writing code (base commit, branch, the specific functions/files this slice builds on). *"The mentor believes them true; you prove them — if one fails, STOP and report the mismatch instead of building on sand."*
3. **THE SLICE** — one narrow, completable goal. What exists after this run that didn't before.
4. **RULINGS** — numbered decisions (D1, D2…) made *for* this slice, each with its trap called out explicitly ("TRAP: nothing may depend on X"). End with: *"decided within the blessed spec; flag disagreements, don't silently deviate."*
5. **SCOPE FENCE — what this slice is NOT.** Name adjacent work and forbid it. Emergent findings get LEDGERED in the report, not fixed.
6. **TESTS** — RED-first where a defect is claimable; name the exact suites/configs.
7. **GATES — a TARGETED set.** Name each gate command. Wide sweeps belong to YOUR verification pass, not the builder's budget.
8. **BUDGET + COMMIT DISCIPLINE** — wall-clock budget, then verbatim: *"Commit PER COMPLETED ITEM. If you near the budget: COMMIT everything verified, write an honest partial report naming exactly what is un-run, and end — never die silent, never background-and-await."* If the builder may push, name the exact leaf branch: pushes go to **the feature branch named in the header only — never to a shared branch** (`main`/`dev`/`sprint`) on the builder's own initiative. Promotion up the hierarchy is always a separate **ship dispatch** you author after the human's blessing, naming the exact merge (`<leaf> → <parent>`) — the builder executes that merge too (it is the hands for all repo writes); the blessing chain is the authorization.
9. **REPORT** — require: commit hashes per item (*"a report without hashes is an unfinished report"*), gate outputs verbatim (counts, not adjectives), honest limits, and a final `DISPATCH_RESULT: <ok|blocked|partial> …` sentinel line. If decisions surfaced that need the human: 2-4 options each + recommended default, written so AskUserQuestion can present them verbatim.

## 2. Dispatch

```bash
# Run in the BACKGROUND (run_in_background: true) — a dispatch takes minutes to
# hours. You will be re-invoked when it finishes; author the next slice's
# prompt or triage the parking lot while you wait.
bash "${CLAUDE_PLUGIN_ROOT}/lib/conduct/dispatch.sh" <name> --timeout <secs> < <prompt-file>
```

Exit 3 = tree busy (another dispatch holds the lock — wait, never force). The run lands in `.specswarm/conduct/runs/<ts>-<name>/` with `prompt.md`, `output.json`, `result.md`, `stderr.log`, `meta`, `exit-code`. The printed `session_id` is your `--resume` handle.

## 3. Independent verification (NON-NEGOTIABLE)

The builder's `result.md` is a *claim*, not a fact. The pilot caught a builder that finished all work, reported "everything green," and exited with the **entire diff uncommitted** — the tell was a report listing files but no commit hashes. Verify yourself, in this order:

```bash
set -o pipefail   # FIRST. A gate piped through tail/grep without pipefail
                  # SWALLOWS its exit code — the pilot once dispatched the next
                  # slice over a RED suite because `… | tail -1` exited 0.

RUN=.specswarm/conduct/runs/<ts>-<name>
cat "$RUN/result.md"                      # read the claim
git -C "$BUILDER_DIR" symbolic-ref -q HEAD    # detached HEAD = restore branch FIRST
git -C "$BUILDER_DIR" log --oneline <base>..HEAD   # commits ACTUALLY landed?
git -C "$BUILDER_DIR" status --short          # uncommitted leftovers?
git -C "$BUILDER_DIR" diff --stat <base>..HEAD    # read the REAL diff, then git show the load-bearing hunks
# …then re-run the targeted gates YOURSELF in the builder tree.
```

A run is **VERIFIED** only when: commits match the report's hashes · the diff does what the report claims · your own gate run is green. Then (if the project uses the verify queue) dispatch the `ss:spec-mentor` adversarial pass on the diff — an external fresh-context read; builder self-audit PASS is structurally worthless (same brain that wrote the code).

## 4. Failure modes + resume protocol (all incident-tested, all recoverable)

**Recoveries are cheap because git is the durable record** — every observed death left committed work intact in the tree.

| # | Mode | Tell | Recovery |
|---|---|---|---|
| 1 | Timeout mid-slice | exit 124, uncommitted lines, no report | Resume-dispatch (below) |
| 2 | API death mid-response | truncated result.md containing the API error text | Resume-dispatch |
| 3 | **Yield-await** | result.md is one orphan sentence "awaiting the completion notification" | Resume-dispatch; the prompt's sync clause pre-empts this |
| 4 | Zombie survives timeout | survivor-sweep WARNING in stderr.log; tree mutates after exit | Group-kill already closed the main hole; never dispatch until survivors are gone |
| 5 | **Verified-but-uncommitted clean exit** | report lists FILES but no commit hashes; `git log <base>..HEAD` empty while gates pass | Tiny commit-first dispatch (the mentor never commits the builder repo) |
| 6 | Killed mid-checkout → detached HEAD | `git symbolic-ref -q HEAD` empty; tree serves stale code, gates test the wrong tree | `git checkout <branch>` BEFORE any gate run |

**After ANY builder death, run the checklist:** `git symbolic-ref -q HEAD` (detached?) → `git status` + `git log` (uncommitted/unreported work in the tree?) → orphan-listener check on WATCH_PORTS → only then decide fresh vs resume.

**Resume prompt shape (proven repeatedly):** state the failure mode verbatim → point at the in-tree work → order a critical self-review of the half-done diff against the appended original spec → complete + commit. Include: *"commit rescued work IMMEDIATELY to put it beyond stash/reset reach"* and the budget clause. Dispatch with `--resume <session_id>` when the session is resumable, fresh otherwise.

## 5. Budget calibration

- Default 3600s fits implement-and-unit-test slices.
- **e2e-heavy slices: ≥75-minute budgets OR a targeted gate set** — the pilot had 3 consecutive timeout-deaths, all with complete implementations, all dying in the gate phase.
- Never bundle heavy gate phases with anything else (ship prep, doc sweeps) — overrun risk.
- Probe/battery scripts in prompts must require explicit `process.exit(0)` / pool `.end()` — a held DB pool keeps node alive forever and reads as a silent hang.

## 6. Status / runs

```bash
ls -t "$PWD"/.specswarm/conduct/runs/ | head -10
for r in "$PWD"/.specswarm/conduct/runs/*/; do
  [ -f "$r/exit-code" ] || { echo "RUNNING: $(basename "$r")"; continue; }
done
```

**Status surface (v7.19.0): the `ss-status` statusline plugin** — install it once (`/ss-status:install`) and the statusline itself answers "is anything running / safe to close?" in real time: `🔨 building: <name> <elapsed>` while a dispatch runs, `💀 last build DIED` on a failed run, `✓ builders idle — safe to close` otherwise. No daemon, nothing to restart after reboots. (The `/ss:watchdog` daemon can also monitor this runs directory, but that's only worth it for out-of-session scenarios; for a live mentor session the statusline is the right surface.)
