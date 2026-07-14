---
description: Assume-first gap resolution for the current feature spec (v7.13.0). Auto-fills gaps resolvable from the taste model, spec corpus, or codebase precedent — recorded as provenance-cited entries in the spec's ASSUMPTIONS section — and asks only genuine forks, batched. Reviewing assumptions is ~5× faster for a human than answering questions.
hidden: true
effort: high
---

<!--
ATTRIBUTION CHAIN:
1. Original: GitHub spec-kit (https://github.com/github/spec-kit)
   Copyright (c) GitHub, Inc. | MIT License
2. Adapted: SpecKit plugin by Marty Bonacci (2025)
3. Forked: SpecSwarm plugin with tech stack management
   by Marty Bonacci & Claude Code (2025)
-->


## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Goal: Detect and reduce ambiguity or missing decision points in the active feature specification and record the clarifications directly in the spec file.

**Assume-first principle (v7.13.0):** every detected gap is classified three ways before it is allowed to become a question:

- **(a) Resolvable from the taste model** (distilled `feedback_*.md` rulings in the memory dirs) → AUTO-FILL, cite the entry by name.
- **(b) Resolvable from the spec corpus or codebase precedent** → AUTO-FILL, cite the corpus section or `file:line` of the precedent.
- **(c) Genuine fork** — no precedent, materially different outcomes → question, batched with the other forks.

Auto-fills are recorded in the spec's `## Assumptions` section with per-entry provenance, reviewable like a diff. Only class (c) reaches the user. Origin lesson: reviewing assumptions is ~5× faster than answering questions; a 10-gap spec with a populated taste model should yield ≤3 questions.

Note: This clarification workflow is expected to run (and be completed) BEFORE invoking `/speckit.plan`. If the user explicitly states they are skipping clarification (e.g., exploratory spike), you may proceed, but must warn that downstream rework risk increases.

Execution steps:

1. **Discover Feature Context**:
   ```bash
   REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

   # Source features location helper
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
   source "$PLUGIN_DIR/lib/features-location.sh"

   # Initialize features directory
   get_features_dir "$REPO_ROOT"

   BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
   FEATURE_NUM=$(echo "$BRANCH" | grep -oE '^[0-9]{3}')
   [ -z "$FEATURE_NUM" ] && FEATURE_NUM=$(list_features "$REPO_ROOT" | grep -oE '^[0-9]{3}' | sort -nr | head -1)

   find_feature_dir "$FEATURE_NUM" "$REPO_ROOT"
   # FEATURE_DIR is now set by find_feature_dir
   FEATURE_SPEC="${FEATURE_DIR}/spec.md"
   ```

   Validate: If FEATURE_SPEC doesn't exist, ERROR: "No spec found. Run `/specify` first."

2. Load the current spec file. Perform a structured ambiguity & coverage scan using this taxonomy. For each category, mark status: Clear / Partial / Missing. Produce an internal coverage map used for prioritization (do not output raw map unless no questions will be asked).

   Functional Scope & Behavior:
   - Core user goals & success criteria
   - Explicit out-of-scope declarations
   - User roles / personas differentiation

   Domain & Data Model:
   - Entities, attributes, relationships
   - Identity & uniqueness rules
   - Lifecycle/state transitions
   - Data volume / scale assumptions

   Interaction & UX Flow:
   - Critical user journeys / sequences
   - Error/empty/loading states
   - Accessibility or localization notes

   Non-Functional Quality Attributes:
   - Performance (latency, throughput targets)
   - Scalability (horizontal/vertical, limits)
   - Reliability & availability (uptime, recovery expectations)
   - Observability (logging, metrics, tracing signals)
   - Security & privacy (authN/Z, data protection, threat assumptions)
   - Compliance / regulatory constraints (if any)

   Integration & External Dependencies:
   - External services/APIs and failure modes
   - Data import/export formats
   - Protocol/versioning assumptions

   Edge Cases & Failure Handling:
   - Negative scenarios
   - Rate limiting / throttling
   - Conflict resolution (e.g., concurrent edits)

   Constraints & Tradeoffs:
   - Technical constraints (language, storage, hosting)
   - Explicit tradeoffs or rejected alternatives

   Terminology & Consistency:
   - Canonical glossary terms
   - Avoided synonyms / deprecated terms

   Completion Signals:
   - Acceptance criteria testability
   - Measurable Definition of Done style indicators

   Misc / Placeholders:
   - TODO markers / unresolved decisions
   - Ambiguous adjectives ("robust", "intuitive") lacking quantification

   For each category with Partial or Missing status, add a candidate question opportunity unless:
   - Clarification would not materially change implementation or validation strategy
   - Information is better deferred to planning phase (note internally)

2.5. **Cross-Check Against External References** (NEW in v6.1.0):

   Before generating the question queue, check whether each candidate question is already answered in the project's external references. The point of clarification is to *resolve* ambiguity — not to re-ask decisions the corpus has already locked in. For projects with substantial spec corpora and decision logs (Marty's customcult-v3 has 379+ [OPEN] markers, most with explicit corpus-side resolutions), this filter dramatically reduces noise.

   ```bash
   REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
   PLUGIN_DIR_SS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
   LOADER="${PLUGIN_DIR_SS}/lib/references-loader.sh"

   REFERENCES_AVAILABLE=false
   SPEC_CORPUS_PATHS=()
   MEMORY_DIRS=()
   PRIOR_REFS_CONSULTED=()

   if [ -f "$LOADER" ]; then
     # shellcheck disable=SC1090
     source "$LOADER"

     if ss_references_exist; then
       REFERENCES_AVAILABLE=true

       while IFS= read -r path; do
         [ -z "$path" ] && continue
         abs=$(ss_references_resolve_path "$path")
         [ -f "$abs" ] && SPEC_CORPUS_PATHS+=("$abs")
       done < <(ss_references_spec_corpus_paths)

       while IFS= read -r path; do
         [ -z "$path" ] && continue
         [ -d "$path" ] && MEMORY_DIRS+=("$path")
       done < <(ss_references_memory_dirs)
     fi
   fi

   # Read references_consulted from spec.md frontmatter (set by /ss:specify in v6.1.0+)
   if [ -f "$FEATURE_SPEC" ]; then
     # Extract YAML frontmatter; parse 'references_consulted:' list
     # (Awk-only — no yq dependency)
     while IFS= read -r line; do
       [ -z "$line" ] && continue
       PRIOR_REFS_CONSULTED+=("$line")
     done < <(awk '
       /^---$/ { fm = !fm; next }
       fm && /^references_consulted:/ { in_list=1; next }
       fm && in_list && /^[[:space:]]*-[[:space:]]/ {
         sub(/^[[:space:]]*-[[:space:]]*/, "")
         sub(/[[:space:]]*#.*$/, "")
         sub(/[[:space:]]*$/, "")
         print
       }
       fm && in_list && /^[^[:space:]-]/ { in_list=0 }
     ' "$FEATURE_SPEC" 2>/dev/null)
   fi

   if [ "$REFERENCES_AVAILABLE" = true ]; then
     echo ""
     echo "🔗 Cross-checking candidate questions against external references:"
     for p in "${SPEC_CORPUS_PATHS[@]}"; do
       echo "   📄 $p"
     done
     for d in "${MEMORY_DIRS[@]}"; do
       echo "   🧠 $d"
     done
     if [ "${#PRIOR_REFS_CONSULTED[@]}" -gt 0 ]; then
       echo ""
       echo "   ↳ Spec.md frontmatter notes these refs were already consulted at /ss:specify time:"
       for r in "${PRIOR_REFS_CONSULTED[@]}"; do
         echo "     - $r"
       done
     fi
     echo ""
   fi
   ```

   **If `REFERENCES_AVAILABLE = true`, you (Claude) MUST do the following BEFORE generating the question queue in Step 3:**

   a. **Read each spec corpus path** in `SPEC_CORPUS_PATHS[@]` using the `Read` tool. Prioritize sections most likely to contain decisions:
   - Decision logs (typically `## Decision Log` or files with dated entries)
   - Schema definitions (data model sections)
   - Authoritative-source pointers (e.g., a builder kickoff doc that names which doc owns which topic)

   b. **Scan memory dirs** in `MEMORY_DIRS[@]` for `feedback_*.md` (the taste model — distilled rulings with `check-type:` frontmatter, WHY, and HOW-TO-APPLY) and `project_*.md` (state/context) files. These often encode decisions that aren't in the formal corpus. Taste entries are the HIGHEST-precedence resolution source: they are compressed user rulings, so an on-point entry decides the gap outright.

   c. **For EACH candidate question from Step 2's ambiguity scan**, run the assume-first ladder — stop at the first rung that resolves:
   - **TASTE-RESOLVED** — a `feedback_*.md` entry decides the gap. Drop the question; record an assumption citing `taste:<entry-name>` (Step 2.6). Apply the entry's HOW-TO-APPLY guidance when injecting the answer into the spec body.
   - **CORPUS-RESOLVED** — corpus contains an explicit decision; drop the question and instead inject the corpus answer directly into the spec with a citation, plus an assumption citing `corpus:<file §section>`. Note this in the report (Step 8).
   - **CONVENTION-RESOLVED** — the codebase itself sets the precedent. Search the project source (Grep/Glob: sibling components, existing patterns, config) for how this decision was made before. If a consistent precedent exists and the gap is not a deliberate departure, drop the question; record an assumption citing `codebase:<path:line>`. Examples: naming schemes, error-handling shape, existing auth middleware, test-file placement.
   - **CORPUS-PARTIAL** — sources have related context but don't decide; keep the question, but PRE-LOAD the candidate answers from that context. AskUserQuestion options should reflect what the sources have hinted at, plus any genuine alternatives.
   - **CORPUS-SILENT** — nothing decides and outcomes materially differ; this is a **genuine fork (class c)** — question proceeds, batched.
   - **CORPUS-CONFLICT** — corpus says X but the spec says Y. Surface this as a special blocking question: "The corpus (`{path}`) says X. Spec says Y. Which is canonical?" — answers feed back to spec.md.

   **Defer-to-data escape (v7.16.0):** a genuine fork whose answer depends on real usage data may be deferred instead of asked — write the cheap default into the spec plus a `[DECIDED-BY-DATA: <metric>, <review-when>]` marker (tracked by `/ss:metrics` and the watchdog). Use sparingly: only when data would actually decide it, and name a real observable metric.

   **Auto-fill discipline:** an auto-fill must be a *resolution*, not a guess. If two taste entries conflict, or the codebase shows two competing precedents, that is a genuine fork — ask. Never auto-fill a gap whose wrong resolution would be expensive to unwind (schema identity, security posture, money handling) unless the resolving source is explicit and on-point.

   d. **Skip-question accounting**: keep an internal count of CORPUS-RESOLVED questions skipped. The Step 3 question budget (max 5) MAY be increased proportionally — if 3 questions were skipped because the corpus answered them, you have effectively 5 + 0 = 5 remaining (don't pad the queue with low-value questions just because budget exists). Lower-impact questions you previously held back can now surface if needed, but it's better to ask 2 high-impact questions than to pad to 5.

   e. **Citation discipline**: any candidate-question answer drawn from the corpus must cite the source in the spec update (per Step 5: Integration). Same format as /ss:specify Sources:
   ```markdown
   ### Q3: Authentication method (auto-resolved from corpus)

   **Answer**: OAuth-first signup (Google + Apple primary; email/password fallback)
   **Source**: `INTERACTION-FLOWS.md` Section 5.11.5.1 + `feedback_share_strategy.md` (Share Encouragement Strategy SE.4)
   **Decision date**: 2026-04-30 per CREATING-THE-STRATEGY.md decision log
   ```

   **If `REFERENCES_AVAILABLE = false`** (no references.md, or empty), skip the taste/corpus rungs of the ladder — but the **CONVENTION-RESOLVED rung still applies** (codebase precedent needs no references.md). Candidates that no codebase precedent resolves flow into the prioritized queue.

2.6. **Record every auto-fill in the spec's `## Assumptions` section** (NEW in v7.13.0):

   Ensure the spec has a `## Assumptions` section (the /ss:specify template provides one; create it after the overview section if missing). Convert any pre-existing prose assumptions to the structured form, then append one entry per auto-fill:

   ```markdown
   ## Assumptions

   <!-- Auto-filled by assume-first clarify. Review like a diff: each entry cites its
        provenance. To override, edit the entry (or tell Claude) — set status: overridden
        and the correction is distilled back into the taste model. -->

   - A1: Sessions auto-extend on activity (30-min idle timeout) — *source:* taste:session-timeout-ux — *status:* auto-filled
   - A2: OAuth-first signup, email/password fallback — *source:* corpus:INTERACTION-FLOWS.md §5.11.5.1 — *status:* auto-filled
   - A3: Form errors render inline below fields, no toast — *source:* codebase:app/components/ContactForm.tsx:88 — *status:* auto-filled
   ```

   Rules:
   - Sequential `A<n>` IDs, never reused within a spec.
   - `*source:*` prefix MUST be one of `taste:`, `corpus:`, `codebase:`, `convention:` followed by the citation (entry name / file §section / path:line / industry-standard rationale). `convention:` is reserved for /ss:specify-time reasonable defaults with no repo source; clarify auto-fills always have one of the other three.
   - `*status:*` ∈ `auto-filled` (machine-resolved, unreviewed), `confirmed` (human reviewed and kept), `overridden` (human corrected — keep the entry, strike the old text, record the correction; then distill the correction into the taste model via Step 5's distillation rule).
   - The spec body still gets the substantive update (Step 5 integration); the Assumptions entry is the provenance ledger, not the only record.

3. Generate (internally) a prioritized queue of candidate clarification questions (maximum 5). Do NOT output them all at once. Apply these constraints:
    - Maximum of 10 total questions across the whole session.
    - Each question must be answerable with EITHER:
       * A short multiple‑choice selection (2–5 distinct, mutually exclusive options), OR
       * A one-word / short‑phrase answer (explicitly constrain: "Answer in <=5 words").
   - Only include questions whose answers materially impact architecture, data modeling, task decomposition, test design, UX behavior, operational readiness, or compliance validation.
   - Ensure category coverage balance: attempt to cover the highest impact unresolved categories first; avoid asking two low-impact questions when a single high-impact area (e.g., security posture) is unresolved.
   - Exclude questions already answered, trivial stylistic preferences, or plan-level execution details (unless blocking correctness).
   - Favor clarifications that reduce downstream rework risk or prevent misaligned acceptance tests.
   - If more than 5 categories remain unresolved, select the top 5 by (Impact * Uncertainty) heuristic.

4. Batched questioning (v7.13.0 — genuine forks only, no drip-feed):
    - Only class (c) genuine forks and CORPUS-CONFLICT items reach this step. All of them are presented in ONE batched pass (the same batching contract /ss:decisions uses):
       * 0 forks → skip this step entirely.
       * 1–4 forks → ONE AskUserQuestion call with all of them.
       * 5+ forks → consecutive AskUserQuestion calls of ≤4, back-to-back with no work in between (a second call is a smell — recheck whether the overflow questions are truly forks before asking).
    - Per question:
       * `header`: short topic chip (≤12 chars), e.g. "Auth", "Data shape" — NOT a progress counter.
       * 2–4 mutually exclusive options with concise labels (1–5 words) and trade-off descriptions. Pre-load option content from CORPUS-PARTIAL context where available.
       * If one option is clearly favored by adjacent precedent, put it first and mark "(Recommended)".
       * The tool provides "Other" automatically; do not add your own.

    **Example (one batched call, two forks):**
    ```
    Q1 header "Auth": "What authentication method should we use?"
      - "JWT tokens" / "OAuth 2.0" / "Session-based" (+ descriptions)
    Q2 header "Retention": "How long do we keep soft-deleted records?"
      - "30 days (Recommended)" / "90 days" / "Forever"
    ```

    - After the batch returns:
       * Record every answer in working memory (Step 5 integrates them one by one).
       * If an answer is a free-form "Other", treat its text as the final answer.
    - If no valid questions exist at start, immediately report: gaps were auto-filled as assumptions (point to the section), no forks required input.

5. Integration after EACH accepted answer (incremental update approach):
    - Maintain in-memory representation of the spec (loaded once at start) plus the raw file contents.
    - For the first integrated answer in this session:
       * Ensure a `## Clarifications` section exists (create it just after the highest-level contextual/overview section per the spec template if missing).
       * Under it, create (if not present) a `### Session YYYY-MM-DD` subheading for today.
    - Append a bullet line immediately after acceptance: `- Q: <question> → A: <final answer>`.
    - Then immediately apply the clarification to the most appropriate section(s):
       * Functional ambiguity → Update or add a bullet in Functional Requirements.
       * User interaction / actor distinction → Update User Stories or Actors subsection (if present) with clarified role, constraint, or scenario.
       * Data shape / entities → Update Data Model (add fields, types, relationships) preserving ordering; note added constraints succinctly.
       * Non-functional constraint → Add/modify measurable criteria in Non-Functional / Quality Attributes section (convert vague adjective to metric or explicit target).
       * Edge case / negative flow → Add a new bullet under Edge Cases / Error Handling (or create such subsection if template provides placeholder for it).
       * Terminology conflict → Normalize term across spec; retain original only if necessary by adding `(formerly referred to as "X")` once.
    - If the clarification invalidates an earlier ambiguous statement, replace that statement instead of duplicating; leave no obsolete contradictory text.
    - Save the spec file AFTER each integration to minimize risk of context loss (atomic overwrite).
    - Preserve formatting: do not reorder unrelated sections; keep heading hierarchy intact.
    - Keep each inserted clarification minimal and testable (avoid narrative drift).

    **Distill reusable rulings into the taste model (NEW in v7.13.0):** after integrating each fork answer, classify it:
    - **Reusable ruling** — the answer expresses a preference/policy that will recur beyond this feature ("always OAuth-first", "soft-deletes kept 30 days", "errors inline, never toasts"). Distill it:
      ```bash
      source "${PLUGIN_DIR_SS}/lib/taste.sh"
      ss_taste_add "<kebab-slug>" "<deterministic|judgment>" \
        "AskUserQuestion /ss:clarify Q<n> feature ${FEATURE_NUM}" \
        "<the rule, one or two sentences>" \
        "<why — cite what prompted the question>" \
        "<how to apply next time>"
      ```
      `check-type`: `deterministic` if a grep/glob/command could enforce it mechanically; `judgment` if it needs a judging mind. Duplicates are skipped automatically — do not pre-check.
      For `deterministic` rules, pass the optional 8th arg — a machine-enforceable `<!-- specswarm-rule: no-pattern|required-pattern|required-pair -->` block (constitution grammar: path-glob + pattern(s) + summary + severity) — and `ss_taste_add` generates the edit-time hook immediately (v7.15.0): today's ruling is enforced on the very next file write.
    - **One-off scope choice** — specific to this feature ("include the export button in v1") → do NOT distill; the spec records it.
    - Same rule applies to `overridden` assumptions from Step 2.6: a human correcting an auto-fill is the strongest taste signal there is — always distill the correction.

6. Validation (performed after EACH write plus final pass):
   - Clarifications session contains exactly one bullet per accepted answer (no duplicates).
   - Total asked (accepted) questions ≤ 5.
   - Updated sections contain no lingering vague placeholders the new answer was meant to resolve.
   - No contradictory earlier statement remains (scan for now-invalid alternative choices removed).
   - Markdown structure valid; only allowed new headings: `## Clarifications`, `### Session YYYY-MM-DD`, `## Assumptions`.
   - Every `## Assumptions` entry carries a `*source:*` with a `taste:`/`corpus:`/`codebase:` prefix and a `*status:*` (the `assumptions-provenance` preflight check enforces this later — don't ship malformed entries).
   - Terminology consistency: same canonical term used across all updated sections.

7. Write the updated spec back to `FEATURE_SPEC`.

8. Report completion (after questioning loop ends or early termination):
   - Number of questions asked & answered.
   - **The assumptions ledger (v7.13.0)** — the primary reviewable artifact. List every auto-filled assumption with its provenance, grouped by source type, and explicitly invite review:
     ```
     Auto-filled 7 assumptions (review like a diff — say "A3 is wrong, use X" to override):
       taste (3):
         • A1: Sessions auto-extend on activity → taste:session-timeout-ux
         ...
       corpus (2):
         • A4: OAuth-first signup → corpus:INTERACTION-FLOWS.md §5.11.5.1
         ...
       codebase (2):
         • A6: Inline form errors → codebase:app/components/ContactForm.tsx:88
         ...
     ```
   - Number of taste-model rulings distilled from this session's answers (list entry names).
   - **Number of CORPUS-CONFLICT questions surfaced (if any)** — these block proceeding to /ss:plan.
   - Path to updated spec.
   - Sections touched (list names).
   - Coverage summary table listing each taxonomy category with Status: Resolved (was Partial/Missing and addressed by user OR by corpus auto-resolution), Deferred (exceeds question quota or better suited for planning), Clear (already sufficient), Outstanding (still Partial/Missing but low impact).
   - If any Outstanding or Deferred remain, recommend whether to proceed to `/speckit.plan` or run `/speckit.clarify` again later post-plan.
   - Suggested next command.

Behavior rules:
- If no meaningful ambiguities found (or all potential questions would be low-impact), respond: "No critical ambiguities detected worth formal clarification." and suggest proceeding.
- If spec file missing, instruct user to run `/speckit.specify` first (do not create a new spec here).
- Never exceed 5 total asked questions (clarification retries for a single question do not count as new questions).
- Avoid speculative tech stack questions unless the absence blocks functional clarity.
- Respect user early termination signals ("stop", "done", "proceed").
 - If no questions asked due to full coverage, output a compact coverage summary (all categories Clear) then suggest advancing.
 - If quota reached with unresolved high-impact categories remaining, explicitly flag them under Deferred with rationale.

Context for prioritization: {ARGS}
