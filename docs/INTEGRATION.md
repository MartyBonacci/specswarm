# SpecSwarm ↔ SpecLabs Integration Guide

**Complete lifecycle coverage through production-ready and experimental plugin integration**

> **📜 HISTORICAL DOCUMENT.** SpecLabs was retired; this guide is preserved for provenance only. Everything it envisioned now lives in core SpecSwarm: autonomous chunk execution → `/ss:overnight` (v7.10.0), the single-command full lifecycle → `/ss:go` (v7.17.0), adversarial verification → `/ss:verify` + spec-mentor (v7.4.0). See [WORKFLOW.md](./WORKFLOW.md) and the main [README](../README.md) for current usage.

---

## Overview

SpecSwarm and SpecLabs work together to provide complete software development lifecycle coverage:

- **SpecSwarm v2.0.0** - Production-ready workflows for 95% of development needs
- **SpecLabs v2.0.0 (Phase 2 Complete)** - Autonomous feature orchestration
  - **Vision**: "Give me a feature description Monday evening, wake up Tuesday morning with working, tested, production-ready code."
  - **Current**: ✅ Complete feature lifecycle automation (Phase 2 - Oct 2025)
  - **Future**: Sprint → Project level autonomous development (Phase 3)

This guide explains when and how to use them together effectively, both now and in future phases.

---

## Quick Decision Matrix

| Scenario | Use SpecSwarm | Use SpecLabs | Notes |
|----------|--------------|--------------|-------|
| New feature development | ✅ Primary | ⚠️ Optional (autonomous execution) | SpecLabs can automate testing |
| Bug fixing (1-2 bugs) | ✅ `/ss:bugfix` | ❌ | Simple sequential fixes |
| Bug fixing (3+ bugs) | ⚠️ Each bug individually | ✅ `/speclabs:coordinate` | Systematic multi-bug analysis |
| Code refactoring | ✅ `/ss:refactor` | ❌ | Metrics-driven approach |
| Feature modification | ✅ `/ss:modify` | ❌ | Impact analysis first |
| Emergency hotfix | ✅ `/ss:hotfix` | ❌ | Production-critical |
| Quality validation | ✅ `/ss:analyze-quality` | ❌ | Comprehensive scoring |
| Autonomous testing | ❌ | ✅ `/speclabs:orchestrate` | Experimental only |
| Browser validation | ❌ | ✅ `/speclabs:orchestrate-validate` | Playwright automation |

---

## Integration Patterns

### Pattern 1: Enhanced Feature Development

**Standard SpecSwarm workflow with optional autonomous execution**

```bash
# Phase 1: Specification (SpecSwarm)
/ss:specify "Add user authentication with email/password"

# Phase 2: Planning (SpecSwarm)
/ss:plan

# Phase 3: Task Breakdown (SpecSwarm)
/ss:tasks

# Phase 4: Implementation (SpecSwarm OR SpecLabs)
# Option A - Manual implementation (production-ready)
/ss:implement

# Option B - Autonomous execution (experimental)
# Create workflow.md first, then:
/speclabs:orchestrate features/auth/workflow.md /path/to/project
/speclabs:orchestrate-validate /path/to/project

# Phase 5: Quality Validation (SpecSwarm)
/ss:analyze-quality
```

**When to use Option B (SpecLabs autonomous)**:
- ✅ Non-critical features in development environment
- ✅ Well-defined requirements with clear test workflows
- ✅ Comfortable handling potential agent failures
- ❌ Production-critical features
- ❌ Tight deadlines

---

### Pattern 2: Systematic Multi-Bug Debugging

**Use SpecLabs for analysis, SpecSwarm for fixes**

```bash
# Step 1: Systematic Analysis (SpecLabs)
/speclabs:coordinate "navbar not updating, sign-out broken, like button blank page"

# Creates debug session with:
# - Problem breakdown (3 issues)
# - Logging strategy template
# - Orchestration plan (if 3+ bugs)
# - Analysis templates

# Step 2: Implement logging and gather evidence
# (Manual - follow logging-strategy.md)

# Step 3: Fix Each Bug (SpecSwarm)
/ss:bugfix "Bug #1: Navbar not updating after sign-in"
/ss:bugfix "Bug #2: Sign-out not working"
/ss:bugfix "Bug #3: Like button causes blank page"

# OR: Use orchestration plan from SpecLabs
# (Experimental - coordinate multiple agents)

# Step 4: Verification (SpecSwarm)
/ss:analyze-quality
```

**Benefits of this pattern**:
- SpecLabs provides systematic investigation structure
- SpecSwarm provides proven bug-fixing workflows
- Combines best of both worlds: systematic + stable

---

### Pattern 3: Rapid Prototyping → Production

**Use SpecLabs for rapid iteration, SpecSwarm for production refinement**

```bash
# Prototype Phase (SpecLabs - fast iteration)
/speclabs:orchestrate prototype/feature-1.md /path/to/project
# Review autonomous agent's work
# Identify what works, what needs refinement

# Production Phase (SpecSwarm - quality focus)
/ss:specify "Feature 1 based on prototype learnings"
/ss:plan
/ss:tasks
/ss:implement
/ss:analyze-quality
```

**Use case**: Validating ideas quickly before committing to full spec-driven development.

---

### Pattern 4: Autonomous Feature Orchestration (Phase 2 ✅ NOW AVAILABLE!)

**Natural language → autonomous implementation**

#### Phase 2: Feature-Level Orchestration (COMPLETE - October 2025)

```bash
# Single command replaces entire SpecSwarm workflow!
/speclabs:orchestrate-feature "Add user authentication with email/password" /path/to/project

# Automatically:
# 1. SpecSwarm Planning (specify → clarify → plan → tasks)
# 2. Task conversion (tasks.md → workflow files)
# 3. Implementation (Phase 1b orchestrator for each task)
# 4. Validation (automatic after each task)
# 5. Retry logic (up to 3 retries with refined prompts)
# 6. Bugfix (if needed)
# 7. Comprehensive reporting

# Delivers: Working, tested feature with full audit trail
```

**Timeline**: 50-67% faster than manual approach (2-5 tasks: 20-40 min vs 60-120 min)
**Status**: ✅ **AVAILABLE NOW** - Ready for testing!

---

#### Phase 3a: Sprint-Level Orchestration

```bash
# Complete sprint backlog overnight
/speclabs:orchestrate-sprint sprint-23-backlog.md /path/to/project

# Backlog format:
# - Feature 1: User authentication
# - Feature 2: Profile management
# - Feature 3: Email notifications
# - Feature 4: Admin dashboard

# Automatically:
# 1. Break sprint into features
# 2. Identify dependencies
# 3. Launch parallel agents
# 4. Coordinate integration points
# 5. Validate continuously
# 6. Create checkpoints

# Delivers: Complete sprint ready for deployment
```

**Timeline**: Full sprint in 6-8 hours instead of 2 weeks

---

#### Phase 3b: Project-Level Orchestration

```bash
# Build complete project from specification
/speclabs:orchestrate-project project-spec.md /path/to/new-project

# Project spec:
# - Architecture decisions
# - Tech stack
# - Feature list
# - Quality requirements

# Automatically:
# 1. Setup project architecture
# 2. Implement all features
# 3. Write comprehensive tests
# 4. Generate documentation
# 5. Prepare deployment
# 6. Create handoff materials

# Delivers: Production-ready project
```

**Timeline**: Months of work in days

---

**When these become available**, integration with SpecSwarm:
- SpecSwarm continues for manual control and production-critical work
- SpecLabs orchestration for rapid development and experimentation
- SpecSwarm validation ensures autonomous work meets quality standards

---

## When SpecSwarm Suggests SpecLabs

SpecSwarm includes smart integration points that suggest SpecLabs features when appropriate:

### Suggestion 1: Complex Bug Scenarios

**SpecSwarm detects chain bugs during bugfix workflow**

```bash
/ss:bugfix "Multiple authentication issues"

# SpecSwarm output:
✅ Bug analysis complete
⚠️  Chain bug detected: 3 related issues found

💡 Suggestion: For complex multi-bug scenarios, consider:
   /speclabs:coordinate "auth issues description"

   This provides systematic investigation with:
   - Logging strategy generation
   - Root cause analysis templates
   - Orchestration planning for 3+ bugs

Continue with SpecSwarm bugfix workflow? [y/n]
```

### Suggestion 2: Large Implementation Tasks

**SpecSwarm detects autonomous execution opportunity**

```bash
/ss:implement

# SpecSwarm output during task analysis:
📋 Analyzing tasks for implementation...
   • 12 tasks identified
   • 8 can run in parallel
   • Estimated time: 45-60 minutes

💡 Experimental Option Available:
   Try autonomous execution with SpecLabs:
   /speclabs:orchestrate features/current/workflow.md /path/to/project

   ⚠️  Experimental - Review agent work carefully

Proceed with manual implementation? [y/n]
```

### Suggestion 3: Quality Validation Failures

**SpecSwarm quality validation identifies validation needs**

```bash
/ss:analyze-quality

# SpecSwarm output:
❌ Browser Tests: 0/15 points (no tests found)

💡 Consider automated browser validation:
   /speclabs:orchestrate-validate /path/to/project

   Provides:
   - Playwright browser automation
   - Console/network error capture
   - Screenshot analysis

Continue manual browser testing? [y/n]
```

---

## Common Workflows

### Workflow 1: Feature Development (Production Critical)

**Pure SpecSwarm - No experimental features**

```bash
/ss:specify "Feature description"
/ss:clarify
/ss:plan
/ss:tasks
/ss:implement
/ss:analyze-quality
```

**Timeline**: 45-90 minutes for typical feature
**Risk**: Low - all production-ready workflows
**Quality**: High - comprehensive validation

---

### Workflow 2: Feature Development (Experimental Prototype)

**SpecLabs for speed, SpecSwarm for validation**

```bash
# Rapid prototyping
/speclabs:orchestrate prototype.md /path/to/project
/speclabs:orchestrate-validate /path/to/project

# Production refinement
/ss:specify "Based on prototype..."
/ss:plan
/ss:implement
/ss:analyze-quality
```

**Timeline**: 20-30 minutes prototype + 30-45 minutes production
**Risk**: Medium - experimental phase may fail
**Quality**: High - final validation by SpecSwarm

---

### Workflow 3: Complex Bug Investigation

**SpecLabs for structure, SpecSwarm for execution**

```bash
# Investigation
/speclabs:coordinate "Bug description with multiple issues"

# Analyze and gather evidence
# (Follow logging-strategy.md and analysis-template.md)

# Fix systematically
/ss:bugfix "Issue #1 from analysis"
/ss:bugfix "Issue #2 from analysis"
/ss:bugfix "Issue #3 from analysis"

# Verify
/ss:analyze-quality
```

**Timeline**: 2-4 hours for 3-bug scenario
**Risk**: Low - structured approach reduces missed issues
**Quality**: High - systematic investigation + proven fixes

---

### Workflow 4: Emergency Production Fix

**Pure SpecSwarm - Critical stability needed**

```bash
/ss:hotfix "Production issue description"
```

**Timeline**: <2 hours target
**Risk**: Low - production-ready emergency workflow
**Quality**: High - expedited but validated

**DO NOT use SpecLabs for production emergencies**

---

## Configuration for Integration

### Enable SpecLabs Suggestions in SpecSwarm

Create `.specswarm/integration-preferences.md`:

```markdown
# SpecSwarm ↔ SpecLabs Integration Preferences

## Suggestion Behavior

**Enable SpecLabs Suggestions**: Yes

**Suggest When**:
- 3+ bugs detected in bugfix workflow
- Large parallel task opportunities (8+ tasks)
- Browser validation missing in quality checks

**Auto-Prompt**: No (always ask before suggesting)
**Remember Choice**: Session-only (ask each time)

## Experimental Tolerance

**Comfort Level**: Medium
- Comfortable with autonomous testing in dev environment
- Prefer SpecSwarm for production work
- Open to SpecLabs for multi-bug debugging

## Default Behavior

**Feature Development**: SpecSwarm (manual implementation)
**Bug Fixing (1-2 bugs)**: SpecSwarm only
**Bug Fixing (3+ bugs)**: Suggest SpecLabs coordinate
**Validation**: SpecSwarm (manual browser testing)
```

---

## Best Practices

### DO

✅ **Use SpecSwarm for all production-critical work**
- New features for production
- Production bug fixes
- Production hotfixes
- Code quality validation

✅ **Use SpecLabs for non-critical experimentation**
- Prototyping new ideas
- Development environment testing
- Complex multi-bug investigation structure
- Learning autonomous workflows

✅ **Combine both for complex scenarios**
- SpecLabs for investigation structure (coordinate)
- SpecSwarm for actual fixes (bugfix)
- SpecSwarm for final validation (analyze-quality)

✅ **Review all SpecLabs output carefully**
- Autonomous agents may make mistakes
- Validation may miss subtle issues
- Always verify changes before committing

### DON'T

❌ **Never use SpecLabs for production emergencies**
- Experimental features too risky
- Unpredictable behavior
- Use SpecSwarm:hotfix instead

❌ **Don't skip SpecSwarm validation after SpecLabs**
- Always run `/ss:analyze-quality` after SpecLabs work
- Verify autonomous changes manually
- Run full test suite

❌ **Don't rely solely on SpecLabs validation**
- Phase 0 limitations in visual analysis
- Manual screenshot review still needed
- Complement with SpecSwarm quality checks

❌ **Don't mix plugin commands randomly**
- Follow established patterns
- Complete one plugin's workflow before switching
- Use integration points deliberately

---

## Troubleshooting Integration

### SpecLabs Work Failed, Resume with SpecSwarm

```bash
# SpecLabs autonomous execution failed
/speclabs:orchestrate workflow.md /project
# ❌ Agent encountered blocker

# Resume with SpecSwarm
/ss:specify "Same feature from workflow.md"
/ss:plan
/ss:implement
```

**Lesson**: SpecSwarm is the reliable fallback.

---

### SpecSwarm Too Slow, Try SpecLabs

```bash
# SpecSwarm manual implementation taking too long
/ss:implement
# ⏱️  Estimated 90 minutes for 15 tasks

# Cancel and try SpecLabs (if non-critical)
# Create workflow first
/speclabs:orchestrate workflow.md /project
# ⏱️  Autonomous execution: 15-20 minutes

# Always validate with SpecSwarm after
/ss:analyze-quality
```

**Lesson**: SpecLabs can accelerate non-critical work, but always validate.

---

### Complex Bug, Needs Both

```bash
# Start with systematic investigation
/speclabs:coordinate "navbar, sign-out, and like button all broken"

# Creates debug session with:
# - Problem breakdown
# - Logging strategy
# - Orchestration plan

# Implement logging and gather evidence
# (Follow SpecLabs templates)

# Fix each bug properly
/ss:bugfix "Navbar not updating (root cause: stale cache)"
/ss:bugfix "Sign-out broken (root cause: session handling)"
/ss:bugfix "Like button blank page (root cause: missing error boundary)"

# Final validation
/ss:analyze-quality
```

**Lesson**: SpecLabs provides structure, SpecSwarm provides stability.

---

## Phase Graduation Path

As SpecLabs features mature through phases, they may eventually graduate to SpecSwarm:

### Phase 1a: Components (✅ COMPLETE - October 16, 2025)
**Status**: Production-ready foundation
- ✅ State Manager - Session persistence
- ✅ Decision Maker - Complete/retry/escalate logic
- ✅ Prompt Refiner - Context-injected retries
- ✅ Metrics Tracker - Performance tracking
- ✅ Vision API Mock - Placeholder for future

**Deliverable**: Intelligent orchestration foundation

### Phase 1b: Full Automation (✅ COMPLETE - October 16, 2025)
**Status**: Zero manual steps
- ✅ Automatic agent launch
- ✅ Automatic validation
- ✅ True retry loop (up to 3 retries)
- ✅ Intelligent prompt refinement
- **10x faster than manual approach**

**Deliverable**: Fully automated task orchestration

---

### Phase 2: Feature Workflow Engine (✅ COMPLETE - October 16, 2025)
**Status**: Feature-level automation
- ✅ Feature Orchestrator - Complete lifecycle management
- ✅ Task Converter - Automatic workflow generation
- ✅ SpecSwarm Integration - Planning → execution
- ✅ Per-task validation and retry
- ✅ Feature-level bugfix integration
- **50-67% faster than manual feature implementation**

**Deliverable**: `/speclabs:orchestrate-feature` command

---

### Phase 3: Sprint Orchestration (🔄 NEXT - Q1 2026)
**Goal**: Multi-feature coordination
- Sprint coordinator (multiple features)
- Dependency manager (parallel planning)
- Resource allocator (agent workload)
- Overnight execution support
- Progress monitoring
- Automatic checkpoints

**Deliverable**: `/speclabs:orchestrate-sprint` command

**Timeline**: Q1 2026

---

### Graduation to SpecSwarm (Post-Launch)
**When features proven stable** (>90% success rate, low bug count, real-world validation):
- Mature commands may graduate to SpecSwarm
- Example: `/ss:implement --autonomous` (from orchestrate-feature)
- SpecLabs continues experimental innovation
- Cycle repeats with next generation features

**Timeline**: 9-11 months from Phase 0 to production launch

---

## Support & Feedback

### Report Integration Issues

If you encounter issues using SpecSwarm and SpecLabs together:

1. **Which plugins?** (SpecSwarm v2.0.0 + SpecLabs v2.0.0)
2. **What workflow?** (e.g., Pattern 2: Multi-bug debugging)
3. **What happened?** (actual behavior)
4. **What expected?** (desired integration)
5. **Artifacts?** (debug sessions, quality reports, etc.)

**Repository Issues**: https://github.com/MartyBonacci/specswarm/issues

### Suggest New Integration Patterns

See a better way to use both plugins together? Share your workflow!

---

## Summary

**Golden Rule**: **SpecSwarm for production, SpecLabs for experimentation**

**Integration Philosophy**:
- SpecSwarm provides the stable foundation (95% of needs)
- SpecLabs adds experimental capabilities (5% cutting-edge)
- Together they cover 100% of the development lifecycle
- Use integration points deliberately, not randomly

**Success Pattern**:
1. Default to SpecSwarm for all work
2. Consider SpecLabs only for non-critical scenarios
3. Always validate SpecLabs work with SpecSwarm
4. Learn from experimental failures
5. Provide feedback for improvements

---

**SpecSwarm ↔ SpecLabs** - Complete lifecycle coverage through intelligent integration. 🚀
