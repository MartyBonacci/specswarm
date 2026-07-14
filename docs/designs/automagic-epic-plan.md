# AUTO-MAGIC Upgrade Epic — Audit Map, Locked Decisions, Phased Plan

**Status:** Phase 1 complete (audit + decision sheet + plan) — 2026-07-13
**Design compass:** mind-reading = 4 loops (distilled taste memory, assume-with-provenance,
adversarial verification, calibration loops). North star: median ≤4 human touchpoints per chunk
(kickoff, batched decision sheet + assumptions review, sighted gate, ship blessing).

---

## 1. Audit Map (component → verdict)

| WS | Requirement | Verdict | Evidence / existing substrate |
|---|---|---|---|
| WS1 | Taste-entry format (name/desc/rule/WHY/HOW-TO-APPLY, compressed) | **VERIFY-ONLY** | `feedback_*.md` convention is a near-exact match: frontmatter + rule-first body + `**Why:**`/`**How to apply:**`, ≤25 lines, "never transcripts" (agents/chunk-retrospective.md:104-108; lib/references-loader.sh:181-217) |
| WS1 | Accretion: /ss:intervention | VERIFY-ONLY (manual) | lib/intervention.sh:128-216 |
| WS1 | Accretion: retrospective | VERIFY-ONLY (batch) | chunk-retrospective agent writes memory files directly |
| WS1 | Accretion: AskUserQuestion answers | **MISSING** | clarify/decisions answers land in spec.md / decision-sheet.md, never the memory corpus |
| WS1 | Accretion: sighted/verify verdicts | **MISSING** | "sighted" concept absent; verify verdicts die in `.specswarm/verify-queue/*` unless human runs retrospective |
| WS2 | Three-way gap classification | **EXTEND** | clarify.md:112-214 already has 4-way corpus filter (CORPUS-RESOLVED/PARTIAL/SILENT/CONFLICT) w/ citations; missing: codebase-convention branch + batching (currently 1-at-a-time, clarify.md:228) |
| WS2 | First-class ASSUMPTIONS section w/ provenance | **EXTEND** | `## Assumptions` exists in spec template (specify.md:152) but prose-only, no per-assumption provenance schema |
| WS3 | Rules are EXECUTED, not just written | **EXTEND/MISSING** | Only execution path: human-run `/ss:init` Step 4.0 → `specswarm-rule:` blocks → generated PostToolUse hooks (init.md:1055,1200-1276). memory-coverage.sh is integrity-lint only. **spec-mentor memory loading is aspirational: verify.md context bundle (verify.md:174-192) omits memory paths entirely.** No deterministic-vs-judgment tag in memory frontmatter. |
| WS4 | Build+lint per slice | **MISSING** | No production-build gate anywhere. quality-check.sh lints single file, never blocks. **Live bug: implement.md:537,551,581,617 references `lib/test-framework-detector.sh` + `lib/quality-gates.sh` which DO NOT EXIST — quality block silently no-ops.** |
| WS4 | Test-glob derivation from repo reality | **MISSING** | nothing enumerates test roots or validates sweep globs |
| WS4 | Asymmetric-fixture / round-trip / fixture-shape checks | **MISSING** | note: preflight receives only plan.md, **no diff input** — diff-triggered checks must live at verify-time |
| WS5 | NEEDS-SIGHTED queue state + ship block | **EXTEND** | queue has 3 states (.pending/.verified/.flagged); insertion: queue.sh:104-108 verdict case + hardcoded rm-lists at queue.sh:59,127. ship.md Step 1.7 gate is **explicitly non-blocking** (ship.md:222). Diff-path classifier precedent: constitution path-glob engine. verify.md:168-172 already computes per-task diff. |
| WS6 | Sync-gate + budget prompt clauses | **MISSING** | overnight prompt (lib/overnight/run.sh:121-152) has neither; watchdog's `--with-verify` dispatch (check-cycle.sh:155) also bare |
| WS6 | Work-tree inspection + auto-resume | **MISSING** | run.sh checks commit-count only (run.sh:166-167), never `git status --porcelain`; every failure branch = finalize+exit, zero re-dispatch. Structural gap: stop-hook keys on `build-loop.state` only → no-op during overnight (yield-await unprotected). |
| WS7 | Bakeoff primitive | **MISSING** | substrates to reuse: decisions.md ≤4-per-batch AskUserQuestion loop (decisions.md:220-232), chunk-retrospective memory writes, validate.md screenshot capture |
| WS8 | DECIDED-BY-DATA markers + ground-truth-bias guard | **MISSING** | hosts to extend: watchdog check-cycle.sh:74-112 (greps changed artifacts already), metrics.md (outcome counts only) |
| WS9 | Single full-ladder entry point | **EXTEND** | build.md chains specify→clarify→plan→tasks→implement→(validate)→analyze-quality via SlashCommand + stop-hook state machine (stop-hook.sh:93-214); calls NONE of decisions/preflight/verify/retrospective. Stop-hook must learn new phase values (unknown phase → approve/exit at stop-hook.sh:186-189). Dead `/ss:analyze` call at build.md:706. status.md/build.md state-schema mismatch (`.status` vs `.active`). |

## 2. Locked Decisions (decision sheet, answered 2026-07-13)

| # | Decision | Ruling |
|---|---|---|
| D1 | Taste model home | **Memory corpus IS the taste model.** Extend `feedback_*.md` frontmatter with `check-type: deterministic\|judgment` + provenance fields. Wire missing accretion sources to write there. No new artifact. |
| D2 | WS9 entry point | **New command `/ss:go`.** Full ladder, pauses only at the 4 gates. `/ss:build` untouched; deprecate later once proven. |
| D3 | Sighted sign-off UX | **Both paths.** `/ss:verify --sighted <task>` guided walkthrough (incl. reading browser console) any time, AND `/ss:ship` batch-reviews remaining needs-sighted items via AskUserQuestion. Ship BLOCKS while any remain. |
| D4 | Slice gates placement | **Blocking at implement, per task.** Build+lint run synchronously after each task; failure halts → fix task. Env knob `SPECSWARM_SLICE_GATES=block\|warn\|off`, default `block`. (The one default-changing behavior in the epic — explicitly sanctioned here.) |

## 3. Assumptions (auto-filled, review like a diff)

| # | Assumption | Provenance |
|---|---|---|
| A1 | One minor version per phase: v7.13.0 (Ph2) → v7.17.0 (Ph6) | CHANGELOG per-version convention; backwards-compat constraint rules out v8 |
| A2 | WS3 deterministic-rule format = existing `specswarm-rule:` grammar (no-pattern/required-pattern/required-pair) + generated-hook pipeline; add auto-distillation, don't invent a format | init.md:1233-1276; epic rule "extend rather than duplicate" |
| A3 | Missing `test-framework-detector.sh` / `quality-gates.sh` get authored for real in Phase 3 (WS4) | audit finding; implement.md references them |
| A4 | Assumptions review = its own pause, placed back-to-back with the decision sheet (both front-loaded) | WS9's list of 4 allowed pauses names them separately |
| A5 | WS7 contact sheet = markdown/HTML side-by-side artifact in feature dir; PNG screenshots only when browser MCP detected | validate.md screenshot substrate; project-agnostic constraint |
| A6 | Taste-model discovery keeps the `references.md` memory-dirs mechanism; no new directory | D1 + references-loader.sh:133-143 |
| A7 | All new preflight-style checks follow STATUS-first-line + WARN-on-zero contract; every check ships a violating-fixture test in `test-fixtures/vX.Y-*.sh` | v7.11 convention; epic falsifiability constraint |
| A8 | Sighted classifier = deterministic diff-path/extension/pattern globs, runs at verify-time (where per-task diff exists), not preflight | WS5 audit; preflight lacks diff input |
| A9 | WS4.3/4.4/4.5 (asymmetric-fixture, round-trip-greenwash, fixture-shape) = verify-time deterministic *screeners* that flag applicability + inject a judgment clause into spec-mentor's context; the judgment half lives in spec-mentor | preflight lacks diff; spec-mentor is the judgment engine |
| A10 | Watchdog + overnight prompt-clause injection shares one lib function so both dispatch sites stay in sync | check-cycle.sh:155 + run.sh:158 are the only two headless dispatch sites |

## 4. Phased Plan

Every slice: violating-fixture test + `claude plugin validate plugins/ss/` + version-trio bump + CHANGELOG entry (`*Source:*` origin lesson, `*Verified by:*` test line) before commit.

### Phase 2 → v7.13.0 — WS1 + WS2 (mind-reading core)
- **S2.1** `lib/taste.sh`: `ss_taste_add <name> <type> <check-type> <source> <rule> <why> <how>` — writes a well-formed `feedback_*.md` (frontmatter incl. `check-type:`, provenance) + MEMORY.md index line; dedup-by-name guard. Test: v7.13-taste-accretion.sh (format lint, dedup, index, WARN on malformed).
- **S2.2** Accretion wiring: decisions.md Phase 6 + clarify.md answer-encoding gain a distillation step — each reusable ruling (not one-off scope choice) → `ss_taste_add` with provenance `AskUserQuestion <cmd> D<n>/Q<n> feature <num>`. verify.md DRIFT resolutions → optional distill prompt.
- **S2.3** Assume-first clarify: extend the corpus filter to the three-way ladder — (a) taste-model AUTO-FILL (extends CORPUS-RESOLVED, cites entry name), (b) NEW codebase-convention AUTO-FILL (cite file:line precedent), (c) genuine fork → **batched** AskUserQuestion (adopt decisions.md ≤4/call loop). Auto-fills write to structured `## Assumptions`.
- **S2.4** Structured ASSUMPTIONS schema in specify.md template + clarify writer: `- A<n>: <assumption> — *source:* <taste:entry-name | codebase:file:line | convention:...> — *status:* auto-filled|confirmed|overridden`.
- **S2.5** New preflight check `assumptions-provenance.sh`: every A-entry has a source; applicable-but-zero → WARN (WARN-on-zero rule). Registered in run.sh CHECKS array. Violating-fixture test.
- **Acceptance:** 3 corrections in a chunk → 3 distilled entries a fresh session can apply; 10-gap spec + populated taste model → ≤3 questions, rest auto-filled with provenance.

### Phase 3 → v7.14.0 — WS4 + WS5 (deterministic trust)
- **S3.1** Author the missing libs for real: `lib/test-framework-detector.sh` (enumerate test roots/configs from repo reality — jest/vitest/pytest/go/cargo configs + `test/`, `tests/`, `__tests__` dirs) + `lib/quality-gates.sh` (resolve build/lint commands per stack: package.json scripts, Makefile, cargo, go). Fixes the silent no-op in implement.md.
- **S3.2** Slice gates in implement.md per D4: after each task, run build+lint synchronously; fail → halt + fix task. `SPECSWARM_SLICE_GATES=block|warn|off` (default block). Ship also runs full build (belt+braces).
- **S3.3** Test-glob reality check: preflight + verify-time check that any targeted sweep's globs cover every detected test root containing files relevant to the diff. Origin lesson comment: stale glob missed `tests/` root, two verification rounds lost.
- **S3.4** Verify-time screeners (A9): diff-pattern classifiers for coordinate/orientation/mirror logic (→ require asymmetric fixture + flip test), encode/decode-transform tests (→ require off-module truth assertion), fixture files touched (→ fixture-shape-mirrors-writer clause). Each WARNs deterministically + injects its judgment clause into spec-mentor's context bundle.
- **S3.5** NEEDS-SIGHTED: queue.sh new suffix (verdict case + both rm-lists), deterministic UI/visual/3D diff-path classifier at verify-time, ship.md Step 1.7 flips WARN→BLOCK for needs-sighted + batch sign-off UX per D3 (`/ss:verify --sighted` walkthrough incl. browser console read; verdicts distill via `ss_taste_add`).
- **Acceptance:** each check fires on a violating fixture; ship blocked with unsigned sighted items; build break caught same-task.

### Phase 4 → v7.15.0 — WS3 + WS6
- **S4.1** Ruling distiller: retrospective/intervention distillation classifies each rule `check-type: deterministic|judgment`; deterministic ones auto-emit `specswarm-rule:` blocks → generated hooks (reuse init extractor logic, factored into a lib callable outside `/ss:init`); judgment ones get loaded into spec-mentor.
- **S4.2** Close the spec-mentor gap: verify.md context bundle gains memory paths (judgment-rule entries relevant to the diff); task-context.sh extended. Intervention captured in chunk N fires automatically in chunk N+1.
- **S4.3** Overnight prompt hardening: shared `lib/overnight/prompt-clauses.sh` injecting sync-gate + budget clauses into BOTH dispatch sites (run.sh heredoc + watchdog check-cycle).
- **S4.4** Resume protocol: post-run work-tree inspection (`git status --porcelain` + diff), failure-mode classification (timeout / API-error / yield-await), auto-authored resume prompt (names failure mode, points at in-tree work, orders critical self-review of half-done diff → complete + commit), bounded re-dispatch (1 retry). Slots in BEFORE finalize.
- **Acceptance:** intervention→automatic-catch loop demonstrated on fixture; resume prompt generated for all three simulated failure modes.

### Phase 5 → v7.16.0 — WS7 + WS8
- **S5.1** `/ss:bakeoff`: N candidates → contact-sheet artifact (A5) → per-candidate verdicts via ≤4-batch AskUserQuestion → winner pinned with regression test → verdicts distilled via `ss_taste_add`.
- **S5.2** `[DECIDED-BY-DATA: <metric>, <review-when>]` marker: written by specify/decisions as a legal fork-deferral; scanned by metrics + watchdog check-cycle (notify when review-when trips).
- **S5.3** Ground-truth-bias guard: when an eval/calibration references acceptance data, WARN unless ground truth is segmented/excluded from self-generated suggestions. Origin lesson: 22/26 "user-accepted" items were the scorer's own suggestions.
- **Acceptance:** bakeoff round-trips on a text-variant fixture; marker tracked end-to-end; bias guard fires on a self-generated-truth fixture.

### Phase 6 → v7.17.0 — WS9 `/ss:go`
- **S6.1** New command walking: specify → assume-first clarify → decisions (+assumptions review pause) → plan → tasks → preflight → implement(+slice gates+verify drain) → retrospective → ship blessing pause. Stop-hook learns new `current_phase` values (decisions, preflight, verify, retrospective); state file remains build-loop.state-compatible.
- **S6.2** Cleanups en route: dead `/ss:analyze` call in build.md, status.md schema mismatch.
- **Acceptance:** small feature ships end-to-end with ≤4 touchpoints; all existing commands still work as escape hatches.

## 5. Conventions checklist (every phase)
1. `claude plugin validate plugins/ss/` + `plugins/specswarm/`
2. Version trio: `plugins/ss/.claude-plugin/plugin.json`, `plugins/specswarm/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` (both entries)
3. Test suite `plugins/ss/test-fixtures/vX.Y-<slug>.sh` (synthetic, stack-agnostic, PASS/FAIL counters, exit 0/1)
4. CHANGELOG entry w/ `*Source:*`, `*Generalized from:*`, `*Verified by:*` lines; README + COMMANDS.md rows w/ one-line origin lesson
5. Project-agnostic (detect, don't assume) + backwards compatible (opt-in until proven; sole exception D4)
