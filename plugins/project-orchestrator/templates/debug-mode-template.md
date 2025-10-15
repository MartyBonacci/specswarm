# Debug Mode Orchestration Template

**Purpose**: Specialized orchestration for multi-bug debugging scenarios
**Based on**: [2025-10-14-orchestrator-missed-opportunity.md](../../../docs/learnings/2025-10-14-orchestrator-missed-opportunity.md)

---

## Overview

This template orchestrates parallel debugging when 3+ bugs span multiple domains.

**Key Phases**:
1. **Discovery** - Logging and data collection
2. **Analysis** - Root cause identification
3. **Parallel Fixing** - Domain specialist agents
4. **Integration** - Verification and testing

---

## Input Requirements

Before using this template, you should have:
- [ ] Problem description with multiple distinct bugs (3+)
- [ ] Debug session directory from `/debug:coordinate`
- [ ] Completed analysis with root causes identified
- [ ] Orchestration plan specifying agent assignments

**Typical Source**: `.debug-sessions/YYYYMMDD-HHMMSS/orchestration-plan.md`

---

## Phase 1: Discovery (Pre-Orchestration)

*This phase should be completed before launching orchestrator*

### Logging Strategy
**Status**: Should be completed ✅
**Artifacts**:
- `logging-strategy.md` - Where to add instrumentation
- Logging implemented in suspected files
- Application running with debug logs

### Initial Analysis
**Status**: Should be completed ✅
**Artifacts**:
- `analysis-template.md` - Root causes identified
- Logs captured and analyzed
- Domains categorized

**Critical**: Do not launch orchestrator without root cause analysis!

---

## Phase 2: Agent Planning & Assignment

### Agent Configuration

Based on the analysis, determine agent assignments:

```yaml
agents:
  - id: backend-auth
    domain: backend
    responsibility: Authentication & authorization fixes
    bugs: [1, 2]
    files:
      - src/server/app.ts
      - src/server/middleware/auth.ts
    changes:
      - Fix ESM require() → import
      - Fix cookie forwarding in response

  - id: frontend-ux
    domain: frontend
    responsibility: User experience fixes
    bugs: [3, 4]
    files:
      - app/components/LikeButton.tsx
      - app/actions/likes.ts
    changes:
      - Use useFetcher() for non-navigating actions
      - Ensure errors always redirect (no blank pages)

  - id: data-layer
    domain: database
    responsibility: Data type and schema fixes
    bugs: [5]
    files:
      - src/types/tweet.ts
      - src/db/queries.ts
    changes:
      - Fix field name casing (snake_case vs camelCase)
      - Update type definitions

  - id: test-automation
    domain: testing
    responsibility: Regression test creation
    bugs: [ALL]
    files:
      - tests/bug-XXX-multi-fix.spec.ts
    changes:
      - Create comprehensive test suite
      - Verify all fixes
      - Check for regressions
```

### Dependency Graph

Identify which agents can run in parallel:

```
Phase 2A (Parallel):
├── Agent: backend-auth (independent)
├── Agent: frontend-ux (independent)
└── Agent: data-layer (independent)

Phase 2B (Sequential):
└── Agent: test-automation (depends on all fixes)
```

---

## Phase 3: Parallel Execution

### Launch Agents

**For each agent in Phase 2A, use Task tool**:

```markdown
# Agent: backend-auth

## Mission
Fix authentication and authorization bugs in the backend.

## Bugs to Fix
1. **Bug #1**: ESM require() error in server
   - File: `src/server/app.ts:64`
   - Root cause: `require('jsonwebtoken')` in ES module
   - Fix: Convert to `import` at top of file

2. **Bug #2**: Sign-out cookie not clearing
   - File: `app/pages/Signout.tsx`
   - Root cause: Set-Cookie header not forwarded with redirect()
   - Fix: Use `new Response()` to forward headers

## Files to Modify
- src/server/app.ts
- app/pages/Signout.tsx

## Verification
- [ ] Server starts without ESM errors
- [ ] Sign-out clears cookies properly
- [ ] Navbar updates after sign-out

## Context
Working directory: [PROJECT_PATH]
Debug session: [DEBUG_SESSION_DIR]

## Execution
1. Read root cause analysis from debug session
2. Implement fixes as specified
3. Test changes locally
4. Report completion with summary
```

**Similarly for other agents** (frontend-ux, data-layer)

### Coordination Points

**Server Restart Management**:
- After backend-auth completes → restart server once
- Frontend/data changes may not require restart
- Batch restarts when possible

**Progress Tracking**:
- Monitor each agent's progress
- Identify any blockers
- Coordinate if dependencies discovered

---

## Phase 4: Integration Testing

After all Phase 2A agents complete, launch test-automation agent:

```markdown
# Agent: test-automation

## Mission
Create comprehensive regression test suite to verify all fixes.

## Test Requirements
1. Test all 5 bugs are fixed:
   - Navbar updates after sign-in
   - Sign-out works and clears cookies
   - Like button doesn't show blank page
   - Scroll doesn't jump after like
   - Likes display correctly (no NaN)

2. Verify no regressions:
   - Existing tests pass
   - No new console errors
   - Performance not degraded

## Test File
- Path: `tests/bug-XXX-comprehensive.spec.ts`
- Framework: [Playwright/Jest/etc based on project]

## Test Structure
```typescript
describe('Bug Fixes - Comprehensive Suite', () => {
  test('Bug #1: Navbar updates after sign-in', async () => {
    // Test implementation
  })

  test('Bug #2: Sign-out clears cookies', async () => {
    // Test implementation
  })

  // ... tests for all bugs
})
```

## Success Criteria
- [ ] All new tests pass
- [ ] All existing tests pass
- [ ] No console errors
- [ ] Manual verification successful
```

---

## Phase 5: Final Verification

### Verification Checklist

**Agent Completion**:
- [ ] backend-auth: COMPLETE
- [ ] frontend-ux: COMPLETE
- [ ] data-layer: COMPLETE
- [ ] test-automation: COMPLETE

**Bug Verification**:
- [ ] Bug #1: Navbar updates after sign-in ✅
- [ ] Bug #2: Sign-out works properly ✅
- [ ] Bug #3: Like button no blank page ✅
- [ ] Bug #4: Scroll doesn't jump ✅
- [ ] Bug #5: Likes display correctly ✅

**Quality Gates**:
- [ ] All tests pass
- [ ] No new console errors
- [ ] No regressions detected
- [ ] Manual testing confirms fixes
- [ ] Performance acceptable

**Cleanup**:
- [ ] Remove temporary debug logging
- [ ] Document learnings
- [ ] Update documentation
- [ ] Commit all changes

---

## Metrics Capture

**Record these metrics after completion**:

```yaml
debug_session:
  id: YYYYMMDD-HHMMSS
  strategy: orchestrated

bugs:
  total: 5
  domains: [backend, frontend, database]

agents:
  count: 4
  parallel: 3
  sequential: 1

timing:
  discovery_phase: X minutes
  analysis_phase: X minutes
  parallel_fixing: X minutes
  integration_testing: X minutes
  total: X minutes

  sequential_estimate: 85 minutes
  time_savings: X% (target: 40-60%)

coordination:
  server_restarts: X (vs 15+ sequential)
  human_interventions: X

quality:
  tests_created: X
  bugs_fixed: 5
  regressions: 0
  quality_score: X/10
```

---

## Decision Points

### When to Continue vs Escalate

**Continue** if:
- ✅ Agents completing successfully
- ✅ Fixes verified individually
- ✅ No unexpected dependencies found

**Escalate to Human** if:
- ❌ Agent blocked (missing info, unclear spec)
- ❌ Fixes conflict with each other
- ❌ New bugs discovered during fixing
- ❌ Integration tests failing

### Retry Logic

If agent fails:
1. Review failure reason
2. Refine agent prompt with missing context
3. Retry once
4. If still failing → escalate to human

---

## Success Criteria

### Must Have ✅
- [ ] All root causes addressed
- [ ] All agents completed successfully
- [ ] Integration tests pass
- [ ] No new regressions
- [ ] Time savings achieved (vs sequential)

### Should Have 📋
- [ ] Comprehensive test coverage
- [ ] Documentation updated
- [ ] Learnings captured
- [ ] Clean commit history

### Nice to Have 🎁
- [ ] Performance improvements noted
- [ ] Code quality improvements
- [ ] Additional bugs found and fixed

---

## Example: The 5-Bug Scenario

**Real-world example from learning document**:

```yaml
bugs:
  1:
    description: "Navbar not updating after sign-in"
    file: "src/server/app.ts:64"
    root_cause: "ESM require() error"
    domain: backend

  2:
    description: "Sign-out button not working"
    file: "app/pages/Signout.tsx"
    root_cause: "Cookies not forwarded"
    domain: backend

  3:
    description: "Like button blank page"
    file: "app/actions/likes.ts"
    root_cause: "Error response not handled"
    domain: frontend

  4:
    description: "Scroll jumps after like"
    file: "app/components/LikeButton.tsx"
    root_cause: "Form navigation"
    domain: frontend

  5:
    description: "Likes showing NaN"
    file: "src/types/tweet.ts"
    root_cause: "Field name casing mismatch"
    domain: database

agent_assignments:
  backend-auth: [bug-1, bug-2]
  frontend-ux: [bug-3, bug-4]
  data-layer: [bug-5]
  test-automation: [all]

result:
  sequential_time: 85 minutes
  orchestrated_time: 35 minutes
  savings: 60%
```

---

## Template Variables

When using this template, replace:

- `[PROJECT_PATH]` - Target project directory
- `[DEBUG_SESSION_DIR]` - Debug session from /debug:coordinate
- `[BUG_COUNT]` - Number of bugs (typically 3+)
- `[DOMAIN_LIST]` - List of domains affected
- `[AGENT_ASSIGNMENTS]` - Specific agent → bug mappings
- `[ORCHESTRATION_PLAN]` - Path to orchestration-plan.md

---

## Integration with Debug Coordinate

**Workflow**:
```
/debug:coordinate "bug descriptions"
  ↓
Discovery phase (logging)
  ↓
Analysis phase (root causes)
  ↓
Generates orchestration-plan.md
  ↓
/project-orchestrator:debug --plan=orchestration-plan.md
  ↓
Uses this template to orchestrate agents
  ↓
Parallel fixing
  ↓
Integration testing
  ↓
Verification
  ↓
Done!
```

---

## Lessons from Real-World Usage

Based on [2025-10-14-orchestrator-missed-opportunity.md](../../../docs/learnings/2025-10-14-orchestrator-missed-opportunity.md):

### What Works ✅
- Parallel investigation of independent bugs
- Domain-based agent assignment
- Coordinated server restarts
- Fresh context for each agent
- Systematic verification

### What to Avoid ❌
- Launching without root cause analysis
- Over-orchestrating simple bugs (1-2)
- Starting fixes before logging/analysis
- Random debugging (even with orchestrator!)
- Skipping verification checklist

### Key Insights 💡
- **Detection matters**: Even experts miss orchestration opportunities
- **Logging first**: Never fix without data
- **Clear specs**: Agents need precise root cause info
- **Test automation**: Create tests in parallel with fixes
- **Document everything**: Learnings prevent repeat bugs

---

## Future Enhancements

Planned improvements:
- Auto-detect dependencies between agents
- Dynamic agent scaling (more bugs → more agents)
- Real-time progress dashboard
- Automatic metrics collection
- Learning from past orchestrations

---

**This template transforms multi-bug chaos into orchestrated efficiency.**

**Usage**: Copy this template when creating debug orchestration plans, then customize agent assignments based on your specific bugs and domains.
