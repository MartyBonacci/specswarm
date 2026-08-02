# SpecSwarm Roadmap

Ranked future improvements with implementation sketches. Captured from the 2026-05-08/10 mentor-session SpecSwarm design discussion. Each improvement was scored on (a) impact on building real projects, (b) generalizability to future SS users, (c) implementation tractability.

The architectural principle: **lean core, optional plugins on top**. The core (`ss`) provides primitives — config schema, hook framework, build orchestration, agent generation. Specialized opinionated workflows belong in companion plugins.

## Shipped

### ✅ #1 External Reference Corpus → v6.1.0 (2026-05-10)

When `.specswarm/references.md` is populated, `/ss:specify` consults declared spec corpus paths + reference codebases + memory dirs before generating spec content. `/ss:clarify` skips questions already answered in the corpus. SessionStart hook verifies reference codebases. Zero behavior change when references.md is absent.

### ✅ #2 Memory-Driven Principle Import → v6.2.0 (2026-05-10)

`/ss:init` Step 4.5 scans memory dirs (per references.md), classifies files (`feedback_*` / `project_*` / `reference_*` / `user_*`), proposes constitution principles in the mechanical hook format, asks user to accept/reject each. Accepted principles append to constitution.md and trigger PostToolUse warning hook regeneration. Decision-log auto-import was DROPPED from #2 scope — decision logs are already consumed via #1's spec corpus consultation.

### ❌ #2.1 Grandparent Discovery → v6.2.1 → REVERTED

Patch attempted to scan grandparent dir for siblings + spec docs + parent-workspace memory key. Turned out to be dual-directory-pattern-specific (Marty's mentor + build layout) rather than generally useful. Reverted at d8e7218 because most SS users don't build inside a mentor workspace and the patch added machinery that benefits no one in the typical single-repo case. **Lesson:** auto-discovery additions need to validate against the typical single-repo case before shipping.

### ✅ #4 Constitution Severity Levels → v6.3.0 (2026-05-10)

`constitution.md` rule blocks now accept an optional `severity: warn | block` field (default warn). Block-severity hooks emit a `🚫` marker on violation; the dispatcher routes to `{decision: "block", reason: ...}` so Claude reverts/fixes instead of just receiving a warning. v6.2.0's memory-driven principles now have the enforcement teeth their motivating examples (trade-secret leakage, audit-log compliance) actually require. Backward-compatible — every existing warn-only rule generates byte-identical output to v6.2.0.

Shipped ahead of #3 because #4 is what completes the v6.2.0 arc (see-encode-enforce). Two pre-existing bugs surfaced during dogfooding and were fixed in the same release:

1. **v5.3.0 path-glob bug** — hook templates compared the path-glob against the absolute `FILE_PATH` the dispatcher prepended REPO_ROOT to. No relative-form glob ever matched in production; no warning had ever fired. Templates now normalize against REPO_ROOT first.
2. **v6.2.0 Step 4.5 example syntax** — example rule blocks used `<!-- specswarm:rule type=... -->` syntax that the parser doesn't accept. Memory-imported principles drafted from those examples would have been logged as `principle_unhandled` and silently dropped. Corrected to the parser-accepted form.

**Lesson:** v6.2.0's "smoke-tested" claim was hollow — the smoke test never actually exercised the dispatcher end-to-end. Going forward, "smoke-tested" should mean "synthetic constitution.md → generated hook → dispatcher JSON → expected decision route," not just "loader function returned non-empty."

### ✅ #5 /ss:init Reconciliation Refactor → v6.4.0 (2026-05-11)

Step 4/5/6 reconciliation pass: drift detection between declared foundation values and re-runs against the corpus; sufficiency checks (does the project have enough corpus to make foundation files meaningful?); user-additions block preservation across re-runs. See [CHANGELOG.md](./CHANGELOG.md) for details.

### ✅ #6 Subagent-Driven Foundation File Generation → v7.0.0 (2026-05-19)

`/ss:init` now reads the project's existing spec corpus (Strategy docs, RULES.md, decision logs, memory files) and proposes foundation-file content automatically via discovery + extractor subagents dispatched in parallel. Projects with rich spec corpora skip ~80% of the interactive prompts they faced in v6.4.0. Backward-compatible — thin projects (just README + package.json) see the v6.4.0 flow. See [CHANGELOG.md](./CHANGELOG.md) for the multi-subagent architecture.

### ✅ Autonomous Chunk Loop → v7.1.0–v7.10.0 (2026-05-20)

Ten incremental releases implementing the full autonomous-chunk vision from `AUTOMATION-IDEAS.md`:

- **v7.1.0 `/ss:preflight`** — deterministic 5-check `plan.md` validator (Idea 1)
- **v7.2.0 `/ss:notify`** — cascading-fallback notification helper (Idea 9)
- **v7.3.0 `/ss:intervention`** — capture "feels off" moments as training data (Idea 5)
- **v7.4.0 `/ss:verify` + `spec-mentor`** — adversarial verification, PostToolUse auto-queue (Idea 3)
- **v7.5.0 `/ss:retrospective` + `chunk-retrospective`** — auto-distill chunk lessons to memory (Idea 4)
- **v7.6.0 `/ss:decisions` + `decision-miner`** — pre-batch strategic decisions (Idea 2)
- **v7.7.0** — explicit subagent model assignments (4 opus, 1 haiku) (W1)
- **v7.8.0 `/ss:dry-run` + `dry-run-simulator`** — predict before commit (W7)
- **v7.9.0 `/ss:watchdog`** — background daemon, out-of-session monitor (W5)
- **v7.10.0 `/ss:overnight`** — autonomous chunk execution via cron/systemd/launchd (W2)

Closes the autonomous loop. Dual mentor↔builder session pattern is now fully optional. See [CHANGELOG.md](./CHANGELOG.md) for per-version detail.

**Wild bets deliberately deferred:**
- **W3 (self-modifying BUILDER-GUIDE)** — agent auto-edits canonical docs; ship-risk too high without real-chunk validation
- **W4 (vector-indexed spec corpus)** — requires Python deps; breaks bash-only design; current corpus sizes don't justify
- **W6 (MCP-based orchestrator)** — overkill at current scale; SpecSwarm has 6 agents working without a server layer

### ✅ AUTO-MAGIC Epic → v7.13.0–v7.17.0 (2026-07-13)

Five releases in one day turning months of hand-run production loops (Custom Cult v3, 50+ shipped slices) into first-class machinery. Design compass: mind-reading = four loops (distilled taste memory, assume-with-provenance, adversarial verification, calibration). North star: **median ≤4 human touchpoints per shipped chunk**. Full audit map + locked decisions in [docs/designs/automagic-epic-plan.md](./docs/designs/automagic-epic-plan.md).

- **v7.13.0 — taste model + assume-first clarify (WS1+WS2).** `lib/taste.sh` is the ONE writer for distilled rulings (`check-type: deterministic|judgment` + provenance); decisions/clarify/verify answers accrete instead of dying in artifacts. Clarify inverted: auto-fill from taste/corpus/codebase-precedent into a provenance-cited `## Assumptions` ledger; only genuine forks asked, batched.
- **v7.14.0 — deterministic slice gates + sighted classification (WS4+WS5).** Real `test-framework-detector.sh`/`quality-gates.sh` (referenced since Phase 1, never existed); blocking per-task build+lint (`SPECSWARM_SLICE_GATES`); verify-time diff screeners (geometry/round-trip/fixture-shape/test-globs); `NEEDS-SIGHTED` queue state hard-blocks `/ss:ship`.
- **v7.15.0 — ruling distiller + overnight resilience (WS3+WS6).** Deterministic rulings embed `specswarm-rule` blocks → edit-time hooks generated immediately (chunk N's catch fires in chunk N+1); spec-mentor finally receives judgment taste rules; headless dispatches carry sync-gate + budget clauses; work-tree-aware failure classification + one-shot auto-resume.
- **v7.16.0 — bakeoff + decided-by-data (WS7+WS8).** `/ss:bakeoff` calibration loop (candidates → contact sheet → verdict → pinned winner → distilled ruling); `[DECIDED-BY-DATA: metric, review-when]` fork-deferral markers tracked by metrics + watchdog; `ground-truth-bias` preflight guard.
- **v7.17.0 — `/ss:go` (WS9).** The single default entry point walking the full ladder via a dedicated Stop hook; pauses only at the 4 touchpoints; `/ss:build` untouched (deprecate once /ss:go is proven).

**Lessons:** (a) the audit found two silent no-ops (ghost libs, dead `/ss:analyze` call) — a gate that silently skips reads as "covered"; (b) every new check shipped with a violating fixture proving it FIRES (152 assertions across 5 suites); (c) applying the epic's own assume-first philosophy to its decision sheet worked — 4 questions covered 9 workstreams.

**Post-epic follow-ups:** run a real chunk through `/ss:go` (the prompt-level acceptance test); expect a sighted-classifier tuning pass after the first false-positive holds; consider `/ss:build` deprecation after /ss:go proves out.

### ✅ v7.18.0 — CONDUCT: the four-minds extraction (2026-08-01)

The mentor→builder loop that ran the Custom Cult v3 rebuild (~500 audited dispatches over 7 weeks, ~6/day) extracted into first-class machinery — the `/ss:conduct` extraction originally slated in the 2026-06-13 pilot record, finally landed.

- **`/ss:conduct` + `lib/conduct/dispatch.sh`** — hardened dispatch (per-tree flock, process-group timeout kill, survivor + orphan-listener sweeps, opus pinning, audit runs) + the loop's discipline: prompt grammar, independent verification protocol, six failure modes with resume recipes.
- **`/ss:mentor-init` + `templates/mentor/`** — mentor-directory scaffold; SessionStart hook makes the role structural (role drift after /clear was the pilot's most persistent meta-problem).
- **Watchdog conduct monitoring** — push notifications for run completion/death/orphan-servers; zero-config.

**Follow-up — conduct/overnight convergence:** both dispatch headless builders and share failure-mode DNA (`lib/overnight/resilience.sh` clauses), but serve different topologies (self-driving chunk vs. mentor-driven slices). Candidate v8 work: overnight's runner adopts `lib/conduct/dispatch.sh` as its execution substrate so the hardening lives in exactly one place.

### ✅ v7.19.0 — ss-status plugin: the statusline is the status surface (2026-08-02)

Day-one v7.18.0 usage exposed a meant-vs-asked question mismatch: "any background processes?" meant "safe to shut down?" — a glance question, not an event question. New separate `ss-status` plugin: rich statusline + real-time builder segment (lock-probe ground truth, `refreshInterval`, wraps any existing statusline with a 60s base cache). Watchdog demoted to its between-sessions niche.

**Design rule banked:** when a human asks the same status question repeatedly, capture the WHY before automating the answer — remove the question (ambient surface) rather than answering it louder (notifications). **Watchdog follow-up:** a systemd/launchd unit template remains worthwhile for the overnight niche where a daemon is genuinely required.

## Pending — Core SS

### #3 Project-Level Phases (medium-high impact, medium implementation)

**Gap:** SS is feature-oriented (one branch per `/ss:build`). Real projects beyond ~5 features have implicit phases. No tracking primitive for "Phase 2 must complete before Phase 3" or "this feature contributes to which phase."

**Implementation sketch:**
- `.specswarm/phases.md` — markdown config defining phase boundaries, acceptance criteria, prerequisites
- `.specswarm/phases-state.json` — tracks which features belong to which phase
- `/ss:phase status` — shows current phase, features in flight, gates pending
- `/ss:phase advance` — closes current phase (requires acceptance criteria met), opens next
- `/ss:build "feature description" --phase 2` — attributes feature to phase 2
- Stop hook extension: when feature build completes, check if it satisfies any phase acceptance criteria

**Versioning:** v6.4.0 minor (backward-compatible — projects without phases.md behave as today).

**Process note:** #3 is the right moment for SS to dogfood SS — design it through `/ss:specify` → `/ss:clarify` → `/ss:plan` → `/ss:tasks` end-to-end before writing code. That surfaces design questions (strict-DAG vs tag-style phases, feature-number vs branch-name references, free-form vs checklist acceptance criteria) and validates the corpus-consultation pipeline at the same time.

## Pending — Companion Plugins (don't bloat core)

### `ss-tdd-strict`

Adds a test-first phase between `/ss:tasks` and `/ss:implement`. Quality gate requires test/source file pairs. New constitutional-hook template: `test-exists-for-source` (warns if `app/foo.ts` has no `test/foo.test.ts`). Useful but opinionated — plugin, not core.

### `ss-perf`

Lighthouse CI integration. Chrome DevTools MCP wired into `/ss:validate`. Web Vitals quality gate addition. Per-route LCP/TBT/CLS budget enforcement. Web-only; not all SS users build web. Plugin, not core.

### `ss-security-review`

Runs `silent-failure-hunter` + secret scanner (gitleaks, truffleHog) + dependency audit (npm audit, pip audit) on every `/ss:ship`. Ops-heavy projects benefit; small projects don't need it. Plugin, not core.

### `ss-mentor-builder`

Formalizes the dual-workspace pattern (mentor doc + builder code in separate sessions, sync command). Useful for spec-heavy projects with parent-dir-living spec corpus. Specifically what v6.2.1 attempted in core; should be a plugin instead so the core stays unbiased.

## Architectural principles for future work

1. **Validate auto-discovery against single-repo case before shipping.** v6.2.1 violated this — the dual-directory bias wasn't caught until dogfooding.
2. **Opt-in over opt-out.** New features should be guarded by config-file presence (references.md, phases.md) so they're invisible to users who don't configure them.
3. **LLM-driven steps are fine but make the bash boundary clean.** /ss:init Step 3.5 and Step 4.5 are LLM-heavy in the middle (AskUserQuestion loops, principle drafting) but have crisp bash discovery at the start and crisp bash write at the end. Future steps should follow this shape.
4. **Schema in markdown.** Constitution, tech-stack, quality-standards, references — all markdown with key:value bullet lists. Consistent. Don't introduce YAML/TOML/JSON config files for new features.
5. **Lean core, optional companion plugins.** Don't bloat `ss` with workflow opinions that only some users want.
6. **"Smoke-tested" means end-to-end.** v6.3.0 surfaced two bugs (path-glob, Step 4.5 examples) that prior "smoke-tested" claims missed because the tests exercised a single layer in isolation. A real smoke test crosses every boundary the production code crosses — for constitutional hooks, that means synthetic constitution.md → generated hook → dispatcher → JSON envelope.

## Validation criteria for each pending improvement

Before shipping #3, validate against three real projects:
- A typical single-repo project (e.g., a small SaaS)
- A monorepo (e.g., a workspace with packages/)
- A spec-heavy enterprise project (e.g., Marty's customcult-v3)

If a feature helps the first two and is neutral for the third, ship. If it only helps the third, build it as a companion plugin instead.
