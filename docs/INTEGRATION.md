# SpecSwarm ↔ SpecLabs Integration Guide

**Complete lifecycle coverage through production-ready and experimental plugin integration**

---

## Overview

SpecSwarm and SpecLabs work together to provide complete software development lifecycle coverage:

- **SpecSwarm v2.0.0** - Production-ready workflows for 95% of development needs
- **SpecLabs v1.0.0** - Experimental autonomous features for cutting-edge capabilities

This guide explains when and how to use them together effectively.

---

## Quick Decision Matrix

| Scenario | Use SpecSwarm | Use SpecLabs | Notes |
|----------|--------------|--------------|-------|
| New feature development | ✅ Primary | ⚠️ Optional (autonomous execution) | SpecLabs can automate testing |
| Bug fixing (1-2 bugs) | ✅ `/specswarm:bugfix` | ❌ | Simple sequential fixes |
| Bug fixing (3+ bugs) | ⚠️ Each bug individually | ✅ `/speclabs:coordinate` | Systematic multi-bug analysis |
| Code refactoring | ✅ `/specswarm:refactor` | ❌ | Metrics-driven approach |
| Feature modification | ✅ `/specswarm:modify` | ❌ | Impact analysis first |
| Emergency hotfix | ✅ `/specswarm:hotfix` | ❌ | Production-critical |
| Quality validation | ✅ `/specswarm:analyze-quality` | ❌ | Comprehensive scoring |
| Autonomous testing | ❌ | ✅ `/speclabs:orchestrate-test` | Experimental only |
| Browser validation | ❌ | ✅ `/speclabs:orchestrate-validate` | Playwright automation |

---

## Integration Patterns

### Pattern 1: Enhanced Feature Development

**Standard SpecSwarm workflow with optional autonomous execution**

```bash
# Phase 1: Specification (SpecSwarm)
/specswarm:specify "Add user authentication with email/password"

# Phase 2: Planning (SpecSwarm)
/specswarm:plan

# Phase 3: Task Breakdown (SpecSwarm)
/specswarm:tasks

# Phase 4: Implementation (SpecSwarm OR SpecLabs)
# Option A - Manual implementation (production-ready)
/specswarm:implement

# Option B - Autonomous execution (experimental)
# Create test-workflow.md first, then:
/speclabs:orchestrate-test features/auth/test-workflow.md /path/to/project
/speclabs:orchestrate-validate /path/to/project

# Phase 5: Quality Validation (SpecSwarm)
/specswarm:analyze-quality
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
/specswarm:bugfix "Bug #1: Navbar not updating after sign-in"
/specswarm:bugfix "Bug #2: Sign-out not working"
/specswarm:bugfix "Bug #3: Like button causes blank page"

# OR: Use orchestration plan from SpecLabs
# (Experimental - coordinate multiple agents)

# Step 4: Verification (SpecSwarm)
/specswarm:analyze-quality
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
/speclabs:orchestrate-test prototype/feature-1.md /path/to/project
# Review autonomous agent's work
# Identify what works, what needs refinement

# Production Phase (SpecSwarm - quality focus)
/specswarm:specify "Feature 1 based on prototype learnings"
/specswarm:plan
/specswarm:tasks
/specswarm:implement
/specswarm:analyze-quality
```

**Use case**: Validating ideas quickly before committing to full spec-driven development.

---

## When SpecSwarm Suggests SpecLabs

SpecSwarm includes smart integration points that suggest SpecLabs features when appropriate:

### Suggestion 1: Complex Bug Scenarios

**SpecSwarm detects chain bugs during bugfix workflow**

```bash
/specswarm:bugfix "Multiple authentication issues"

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
/specswarm:implement

# SpecSwarm output during task analysis:
📋 Analyzing tasks for implementation...
   • 12 tasks identified
   • 8 can run in parallel
   • Estimated time: 45-60 minutes

💡 Experimental Option Available:
   Try autonomous execution with SpecLabs:
   /speclabs:orchestrate-test features/current/test-workflow.md /path/to/project

   ⚠️  Experimental - Review agent work carefully

Proceed with manual implementation? [y/n]
```

### Suggestion 3: Quality Validation Failures

**SpecSwarm quality validation identifies validation needs**

```bash
/specswarm:analyze-quality

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
/specswarm:specify "Feature description"
/specswarm:clarify
/specswarm:plan
/specswarm:tasks
/specswarm:implement
/specswarm:analyze-quality
```

**Timeline**: 45-90 minutes for typical feature
**Risk**: Low - all production-ready workflows
**Quality**: High - comprehensive validation

---

### Workflow 2: Feature Development (Experimental Prototype)

**SpecLabs for speed, SpecSwarm for validation**

```bash
# Rapid prototyping
/speclabs:orchestrate-test prototype.md /path/to/project
/speclabs:orchestrate-validate /path/to/project

# Production refinement
/specswarm:specify "Based on prototype..."
/specswarm:plan
/specswarm:implement
/specswarm:analyze-quality
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
/specswarm:bugfix "Issue #1 from analysis"
/specswarm:bugfix "Issue #2 from analysis"
/specswarm:bugfix "Issue #3 from analysis"

# Verify
/specswarm:analyze-quality
```

**Timeline**: 2-4 hours for 3-bug scenario
**Risk**: Low - structured approach reduces missed issues
**Quality**: High - systematic investigation + proven fixes

---

### Workflow 4: Emergency Production Fix

**Pure SpecSwarm - Critical stability needed**

```bash
/specswarm:hotfix "Production issue description"
```

**Timeline**: <2 hours target
**Risk**: Low - production-ready emergency workflow
**Quality**: High - expedited but validated

**DO NOT use SpecLabs for production emergencies**

---

## Configuration for Integration

### Enable SpecLabs Suggestions in SpecSwarm

Create `/memory/integration-preferences.md`:

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
- Always run `/specswarm:analyze-quality` after SpecLabs work
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
/speclabs:orchestrate-test workflow.md /project
# ❌ Agent encountered blocker

# Resume with SpecSwarm
/specswarm:specify "Same feature from workflow.md"
/specswarm:plan
/specswarm:implement
```

**Lesson**: SpecSwarm is the reliable fallback.

---

### SpecSwarm Too Slow, Try SpecLabs

```bash
# SpecSwarm manual implementation taking too long
/specswarm:implement
# ⏱️  Estimated 90 minutes for 15 tasks

# Cancel and try SpecLabs (if non-critical)
# Create test workflow first
/speclabs:orchestrate-test workflow.md /project
# ⏱️  Autonomous execution: 15-20 minutes

# Always validate with SpecSwarm after
/specswarm:analyze-quality
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
/specswarm:bugfix "Navbar not updating (root cause: stale cache)"
/specswarm:bugfix "Sign-out broken (root cause: session handling)"
/specswarm:bugfix "Like button blank page (root cause: missing error boundary)"

# Final validation
/specswarm:analyze-quality
```

**Lesson**: SpecLabs provides structure, SpecSwarm provides stability.

---

## Phase Graduation Path

As SpecLabs features mature, they may graduate to SpecSwarm:

### Phase 0 → Phase 1 (SpecLabs)
**Current Status**: Early experimentation
- High bug risk
- Manual visual analysis
- Basic error handling
- No retry logic

### Phase 1 → Phase 2 (SpecLabs)
**Future**: Automated improvements
- Claude Vision API integration
- Retry logic with refinement
- Better error recovery
- Metrics persistence

### Phase 2 → SpecSwarm (Graduation)
**Future**: Production-ready features
- Proven success rate (>90%)
- Low bug count
- Comprehensive error handling
- Real-world validation

**Example**: If SpecLabs orchestrate-test achieves >90% success rate and low bug count, it could graduate to SpecSwarm as `/specswarm:implement --autonomous`

---

## Support & Feedback

### Report Integration Issues

If you encounter issues using SpecSwarm and SpecLabs together:

1. **Which plugins?** (SpecSwarm v2.0.0 + SpecLabs v1.0.0)
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
