# Escalation Boundary — when work involves the human vs. self-resolves

**Purpose:** minimize human relay steps. Reserve the human for genuine human judgment; route verification / discipline checks to fresh-context subagents; self-resolve the mechanical. The human's steps are the bottleneck — every item moved out of Lane 3 is latency removed from their critical path.

## Three lanes

At every "should I check this?" moment, classify into ONE lane:

### Lane 1 — Self-resolve (no escalation)
- Mechanical actions within a Standing Authorization (below).
- Anything covered by a known project fact or a *validated* discipline → apply it, cite it, move on.
- Routine implementation choices with a consistent-with-existing-patterns default.

### Lane 2 — Fresh-context subagent (no human)
Dispatch an adversarial subagent (e.g. `ss:spec-mentor`) for:
- Verifying a ship / green-gate / "it's done" claim → it reads git + runs tests read-only, adversarially.
- Diagnosing a failure/flake *before* choosing a remedy (clean-base repro).
- Pressure-testing a premise against the actual code before it drives a decision.
- Bounding emergent work (in-scope vs. tracked deferral).

Outcome → **VERIFIED** (proceed) / **ISSUE** (fix, loop) / **NEEDS-HUMAN** (promote to Lane 3).

### Lane 3 — Escalate to the human (genuine human decision ONLY)
1. **Risk acceptance** — adopting a security/quality posture with tradeoffs.
2. **Product / UX judgment** — subjective calls ("does this feel right").
3. **Scope / priority tradeoffs** — what ships vs. defers.
4. **Outward / irreversible action** not covered by a Standing Authorization.
5. **Spec contradiction / genuine ambiguity** with no consistent default (flag, don't pick silently).
6. **Novel risk outside the known disciplines** — a "this feels off" a subagent can't resolve.

Each escalation is ONE well-formed message: the decision · the options · the recommendation + why · the risk being accepted. (One good escalation beats many round-trips.)

## Standing Authorizations (the human sets these once → they never escalate)
<!-- Edit this list with your human. Safe-by-default: free movement at the leaf, -->
<!-- NEVER upward without a blessing. -->
- Builder MAY commit locally, freely.
- Builder MAY push freely to the **current feature/slice branch only** (the leaf it was dispatched onto).
- Builder MAY run gates, tests, and read-only git/inspection freely.
- Builder MAY **NEVER on its own initiative** push to or merge into any shared or protected branch (`main`, `dev`, `sprint/*`, or their equivalents). Shared-branch operations happen ONLY inside an explicit **ship dispatch** — a prompt the mentor authors after the human's blessing, naming the exact merge (`<leaf> → <parent>`). The builder executes it (the builder is the hands for ALL repo writes, merges included — the mentor never writes the repo); the human→mentor→dispatch chain is the authorization. No verification result, green gate, or standing rule substitutes for that chain.
- Builder MAY NOT touch external services, deploy, or take destructive/irreversible actions without a Lane-3 escalation.

**Branch hierarchy note:** this model composes with any layering (e.g. `main ← dev ← sprint ← feature`): builders live at the leaf; each arrow is a separate blessing. Define your hierarchy here so every dispatch prompt can name its leaf:

> Hierarchy: `main ← ______ ← ______` &nbsp;·&nbsp; builders push to: *the current leaf feature branch*

## Anti-patterns (these are Lane 1/2 — do NOT relay to the human)
- "Is the gate really green?" → subagent verifies.
- "Is this flake mine?" → clean-base repro.
- "Should I commit this verified thing?" → standing-authorized.
- "Did the push land?" → fetch and check; never assert-then-relay.
