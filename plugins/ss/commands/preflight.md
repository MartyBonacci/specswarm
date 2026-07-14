---
description: Run deterministic preflight checks against a feature's plan.md before /ss:implement. Catches hallucinated versions, missing memory files, spec drift, ambiguous grep patterns, heading typos, and uncited spec assumptions in <5 seconds.
effort: low
args:
  - name: target
    description: Path to plan.md (or any markdown file) to check. Defaults to the most recent feature's plan.md.
    required: false
  - name: --feature
    description: Feature number to check (e.g., --feature 002). Mutually exclusive with positional target.
    required: false
  - name: --json
    description: Emit results as JSON instead of human-readable output.
    required: false
  - name: --quiet
    description: Suppress per-check detail lines (show only summary lines).
    required: false
---

# SpecSwarm Preflight

Runs 6 deterministic checks against the current feature's `plan.md` and surfaces issues that would otherwise be caught by manual review (or worse, slip through to `/ss:implement`).

**Project-agnostic** — every check discovers project context via existing SpecSwarm infrastructure (`.specswarm/references.md`, lockfiles, git root). No project-specific configuration required.

## Run Preflight

```bash
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="${PLUGIN_DIR}/lib/preflight/run.sh"

if [ ! -x "$RUNNER" ]; then
  echo "❌ Preflight runner not found or not executable: $RUNNER"
  exit 2
fi

"$RUNNER" "$@"
```

## Checks Performed

| Check | What it catches | Skip condition (clean PASS) |
|---|---|---|
| **version-currency** | Hallucinated, typo'd, or yanked package versions | No package manager / lockfile detected |
| **memory-coverage** | References to missing memory files; orphan files not in MEMORY.md | No memory dirs declared in references.md |
| **spec-section-existence** | `§X.Y` refs that don't resolve to any spec corpus heading | No spec corpus declared in references.md |
| **grep-word-boundary** | Short literal grep patterns prone to false positives | (none — always applicable) |
| **heading-fidelity** | Quoted headings whose text doesn't match the source | No spec corpus declared in references.md |
| **assumptions-provenance** (v7.13.0) | Spec `## Assumptions` entries without a `taste:`/`corpus:`/`codebase:`/`convention:` citation or valid status — an uncited assumption is a guess, not a reviewable ledger entry | No spec.md sibling, or spec has no `## Assumptions` section (pre-v7.13 spec) |

Each check independently emits `PASS`, `WARN`, or `FAIL`. The overall exit code is the worst result:

- **0** — all PASS (or a check skipped because its subsystem isn't configured)
- **1** — at least one WARN, no FAIL
- **2** — at least one FAIL (`/ss:implement` should not run until resolved)

**WARN-on-zero (v7.11.0):** A check whose subsystem *is* configured but which then
extracts **zero items** from `plan.md` (0 version pins, 0 memory refs, 0 `§` refs,
0 grep invocations, 0 quoted headings) now emits a **WARN** rather than a silent PASS.
A green check should mean "I verified N>0 items," not "I found nothing to check." A
0/0 PASS previously masked real silent failures — e.g. memory citations written in a
`` `backtick` `` style the extractor didn't recognise. WARN is non-blocking; it asks
"is this expected?" instead of gating `/ss:implement`. The pure not-configured case
(no package manager, no declared corpus/memory dirs) stays a clean PASS-skip, so
docs-only or unconfigured projects aren't spammed.

## How Project-Agnostic Discovery Works

1. **Package manager** — detected from lockfiles in this priority order: `pnpm-lock.yaml`, `bun.lock(b)`, `yarn.lock`, `package-lock.json`, `poetry.lock`, `uv.lock`, `Pipfile.lock`, `Cargo.lock`, `Gemfile.lock`, `go.sum`. Falls back to manifest files (`package.json`, `pyproject.toml`, etc.) if no lockfile present. Maps to public registries: npm / PyPI / crates.io / proxy.golang.org / rubygems.org.

2. **Spec corpus** — read from `.specswarm/references.md` under the `## Spec corpus` section. Glob patterns supported. Relative paths resolve against the repo root.

3. **Memory directories** — read from `.specswarm/references.md` under the `## Memory directories` section. Tilde expansion supported. Both Claude Code's auto-memory path (`~/.claude/projects/.../memory/`) and project-local dirs work.

4. **Feature location** — uses SpecSwarm's standard `.specswarm/features/NNN-name/plan.md` convention. The runner auto-discovers the most recent feature unless `--feature NUM` or a path is given.

If a piece of project context is missing (e.g., no `references.md` exists yet, or no lockfile), the affected check **skips silently** and the overall preflight still runs.

## Usage

```bash
# Auto-discover most recent feature's plan.md
/ss:preflight

# Specific feature
/ss:preflight --feature 002

# Arbitrary file (e.g., a draft outside .specswarm/features/)
/ss:preflight ./drafts/migration-plan.md

# JSON output for CI integration
/ss:preflight --json

# Suppress per-finding detail lines (summary only)
/ss:preflight --quiet
```

## Recommended Workflow Integration

Run `/ss:preflight` immediately after `/ss:plan` completes and before `/ss:tasks`. This is the cheapest possible insurance against the most common failure modes catalogued in real-world SpecSwarm chunks:

- Version-anchor incidents (4× in customcult-v3 P1.1+P1.2)
- Memory file gaps (7× in P1.1)
- npm/pnpm substring grep traps
- Spec corpus drift between `BUILDER-GUIDE.md` and source docs
- Heading-text drift between plan and spec

Each of these used to require a separate "mentor session" or human reviewer to catch. Preflight catches them in <5 seconds with zero LLM cost.

## Cache

Version-currency results are cached at `~/.cache/specswarm/version-check/<registry>/<pkg>@<ver>` with a 24h TTL. Delete that directory to force re-verification.
