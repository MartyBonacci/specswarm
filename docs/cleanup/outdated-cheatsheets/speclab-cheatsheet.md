# SpecLab Workflow Cheatsheet

**Purpose**: Lifecycle workflows for bugfix, modify, hotfix, refactor, and deprecate workflows

**Install**: `claude plugin install speclab`

**Prerequisites**: Works standalone or with SpecSwarm/SpecTest for enhanced features

---

## 🎯 Which Workflow Should I Use?

| Situation | Command | Time | Outcome |
|-----------|---------|------|---------|
| Bug to fix | `/speclab:bugfix` | ~2h | Regression test + fix |
| Feature to modify | `/speclab:modify` | ~4h | Impact analysis + change |
| Production emergency | `/speclab:hotfix` | <2h | Quick fix + rollback plan |
| Code quality issue | `/speclab:refactor` | ~3h | Metrics improvement |
| Feature to remove | `/speclab:deprecate` | Weeks | Phased migration + removal |
| Not sure? | `/speclab:suggest` | 1min | AI recommendation |

---

## 🐛 Bugfix Workflow

**When to Use:**
- Found a bug that needs fixing
- Want to prevent regressions
- Need test coverage for the fix

**Quick Start:**
```bash
# 1. Create bugfix branch
git checkout -b bugfix/042-login-timeout

# 2. Run workflow
/speclab:bugfix

# 3. Follow prompts - Claude guides you through regression-test-first workflow
```

**What Happens:**
1. Creates `features/042-login-timeout/bugfix.md` (bug documentation)
2. Creates `features/042-login-timeout/regression-test.md` (test spec)
3. Creates `features/042-login-timeout/tasks.md` (fix tasks)
4. Executes regression-test-first workflow:
   - ✅ Write regression test
   - ✅ Verify test fails (proves bug exists)
   - ✅ Implement fix
   - ✅ Verify test passes (proves fix works)
   - ✅ Validate no new regressions

**Expected Time**: 1-3 hours (varies by bug complexity)

**Success Criteria:**
- ✅ Regression test created
- ✅ Test failed before fix (proved bug exists)
- ✅ Test passed after fix (proved solution works)
- ✅ No new regressions introduced
- ✅ Tech stack compliant (if SpecSwarm installed)

**Common Issues:**

| Issue | Solution |
|-------|----------|
| "No bugfix branch detected" | Create branch: `git checkout -b bugfix/NNN-description` or provide bug number when prompted |
| "Test doesn't fail before fix" | Review test - it must reproduce the bug. Adjust test or bug specification |
| "Test still fails after fix" | Fix is incomplete or test is incorrect. Review both |
| "New regressions detected" | Revert fix, analyze impact on other components, adjust approach |

---

## 🔧 Modify Workflow

**When to Use:**
- Changing existing feature behavior
- Adding functionality to existing features
- Refactoring with functional changes

**Quick Start:**
```bash
# 1. Create modify branch
git checkout -b modify/018-api-pagination

# 2. Run workflow
/speclab:modify

# 3. Review impact analysis, implement with backward compatibility
```

**What Happens:**
1. Loads existing feature specification
2. Analyzes proposed modification
3. Creates `features/018-api-pagination/impact-analysis.md`
4. Creates `features/018-api-pagination/modify.md`
5. Creates `features/018-api-pagination/tasks.md`
6. Executes impact-analysis-first workflow:
   - ✅ Impact analysis (dependencies, breaking changes)
   - ✅ Backward compatibility strategy
   - ✅ Implementation with validation
   - ✅ Migration tasks (if needed)

**Expected Time**: 2-6 hours (varies by modification complexity)

**Success Criteria:**
- ✅ Impact analysis complete (all dependencies identified)
- ✅ Breaking changes assessed and mitigated
- ✅ Backward compatibility maintained (or migration plan executed)
- ✅ All tests passing (regression + new functionality)
- ✅ Dependent systems validated

**Common Issues:**

| Issue | Solution |
|-------|----------|
| "Feature not found" | Ensure feature number exists in `features/` directory |
| "No existing spec.md" | Modification requires existing feature. Create feature first |
| "Breaking changes detected" | Implement compatibility layer or migration plan. Get stakeholder approval |
| "High risk assessment" | Consider phased rollout, add feature flags, increase test coverage |

---

## 🚨 Hotfix Workflow

**When to Use:**
- Production emergency (service down, critical bug, security issue)
- Need immediate resolution (<2h)
- Normal process too slow

**Quick Start:**
```bash
# 1. Create hotfix branch
git checkout -b hotfix/099-critical-outage

# 2. Run EMERGENCY workflow
/speclab:hotfix

# 3. Minimal process, maximum speed, rollback plan mandatory
```

**What Happens:**
1. Creates minimal `features/099-critical-outage/hotfix.md`
2. Creates emergency `tasks.md` (4 emergency tasks only)
3. Executes expedited workflow:
   - ⚡ Implement minimal fix
   - ⚡ Essential testing only
   - ⚡ Deploy to production
   - ⚡ Monitor post-deployment
4. Schedules post-emergency tasks:
   - Root cause analysis
   - Permanent fix (if hotfix is temporary)
   - Post-mortem

**Expected Time**: <2 hours for emergency resolution

**Success Criteria:**
- ✅ Emergency resolved quickly
- ✅ Service restored
- ✅ Rollback plan ready (if deployment fails)
- ✅ Post-emergency tasks scheduled

**Important Notes:**
- ⚠️ **Speed prioritized over completeness**
- ⚠️ Tech validation optional (time permitting)
- ⚠️ Post-mortem **mandatory** after fire out
- ⚠️ Consider permanent fix using `/speclab:bugfix` later

**Common Issues:**

| Issue | Solution |
|-------|----------|
| "Hotfix failed" | Execute rollback plan immediately. Escalate to senior engineer |
| "Rollback also failed" | CRITICAL - manual intervention required. Alert on-call |
| "Emergency worsens" | Stop hotfix attempt. Consider service shutdown/maintenance mode |

---

## ♻️ Refactor Workflow

**When to Use:**
- Code quality issues (high complexity, duplication)
- Performance optimization
- No functional changes allowed

**Quick Start:**
```bash
# 1. Create refactor branch
git checkout -b refactor/025-reduce-complexity

# 2. Run workflow
/speclab:refactor

# 3. Establish baseline, refactor incrementally, measure improvements
```

**What Happens:**
1. Establishes baseline metrics (complexity, duplication, etc.)
2. Creates `features/025-refactor/baseline-metrics.md`
3. Creates `features/025-refactor/refactor.md`
4. Creates `features/025-refactor/tasks.md`
5. Executes metrics-driven workflow:
   - ✅ Establish baseline (run tests, capture metrics)
   - ✅ Incremental refactoring steps
   - ✅ Test after each step (verify identical behavior)
   - ✅ Measure final metrics
   - ✅ Compare before/after

**Expected Time**: 2-4 hours (varies by refactoring scope)

**Success Criteria:**
- ✅ Baseline metrics established
- ✅ All tests pass (before and after) with identical results
- ✅ Measurable metrics improvement (complexity, duplication, etc.)
- ✅ No functional changes (behavior preservation)
- ✅ No performance regression

**Common Issues:**

| Issue | Solution |
|-------|----------|
| "Tests fail after refactor" | Behavior not preserved. Revert and try smaller incremental steps |
| "Metrics not improved" | Refactoring ineffective. Review baseline and refactoring strategy |
| "Performance regression" | Profile and optimize. Consider reverting if regression significant |

---

## 📉 Deprecate Workflow

**When to Use:**
- Removing legacy feature
- Sunsetting old API version
- Phased migration to new solution

**Quick Start:**
```bash
# 1. Create deprecate branch
git checkout -b deprecate/030-old-api

# 2. Run workflow
/speclab:deprecate

# 3. Announce → Migrate users → Remove (phased approach)
```

**What Happens:**
1. Identifies feature to deprecate
2. Creates `features/030-deprecate/deprecate.md` (timeline, strategy)
3. Creates `features/030-deprecate/migration-guide.md` (user guidance)
4. Creates `features/030-deprecate/tasks.md` (phased tasks)
5. Executes phased workflow:
   - **Phase 1 (Announce)**: Add warnings, publish guide
   - **Phase 2 (Migrate)**: Support users, track adoption
   - **Phase 3 (Remove)**: Disable feature, remove code

**Expected Time**: Weeks to months (phased timeline)

**Success Criteria:**
- ✅ Deprecation announced to all users
- ✅ Migration guide published
- ✅ ≥90% users migrated to alternative
- ✅ Feature removed safely
- ✅ Documentation updated

**Common Issues:**

| Issue | Solution |
|-------|----------|
| "Low migration rate" | Extend timeline, improve migration guide, provide direct support |
| "Migration blockers" | Identify and resolve blockers. May need to adjust alternative |
| "User complaints" | Provide migration support. Ensure alternative is sufficient |

---

## 🔧 Utility Commands

### `/speclab:impact <feature>`

**Purpose**: Analyze impact of changes before modifying

**Usage:**
```bash
/speclab:impact 018    # Analyze feature 018
```

**Output:**
- Dependency graph (direct and indirect dependencies)
- Risk assessment (Low/Medium/High/Critical)
- Affected components
- Recommendations

**When to Use:**
- Before running `/speclab:modify`
- Architecture review
- Pre-planning risk assessment

---

### `/speclab:suggest`

**Purpose**: Get AI workflow recommendation based on context

**Usage:**
```bash
/speclab:suggest                          # Analyzes branch, commits, files
/speclab:suggest "login is broken"        # Provide description
```

**Output:**
- Primary recommendation with confidence level
- Alternative workflows
- Reasoning based on analysis
- Quick start command

**When to Use:**
- Unsure which workflow to use
- Want AI assistance with workflow selection
- New to SpecLab workflows

---

### `/speclab:workflow-metrics [feature]`

**Purpose**: View performance analytics across workflows

**Usage:**
```bash
/speclab:workflow-metrics              # Dashboard for all workflows
/speclab:workflow-metrics 042          # Detail for feature 042
```

**Output:**
- Workflow breakdown by type
- Time to resolution trends
- Quality metrics
- Success rates
- Insights and recommendations

**Requirements:**
- SpecTest plugin installed (for metrics tracking)

**When to Use:**
- Track workflow efficiency
- Identify bottlenecks
- Report to stakeholders
- Optimize development process

---

## 🤝 Integration with Other Plugins

### Standalone Mode (SpecLab only)
✅ All workflows functional
✅ Basic sequential execution
❌ No tech stack validation
❌ No parallel execution
❌ No metrics tracking

### With SpecSwarm
✅ All workflows functional
✅ **Tech stack enforcement** on all workflows
✅ Validates fixes/changes against tech stack
✅ Prevents drift during maintenance
❌ No parallel execution
❌ No metrics tracking

### With SpecTest
✅ All workflows functional
✅ **Parallel execution** where applicable
✅ **Pre/post hooks** for validation
✅ **Metrics tracking** and dashboard
❌ No tech stack enforcement (unless SpecSwarm also installed)

### With SpecSwarm + SpecTest (Recommended)
✅ All workflows functional
✅ **Tech stack enforcement**
✅ **Parallel execution** (2-4x faster)
✅ **Pre/post hooks**
✅ **Metrics tracking** and dashboard
✅ **Best experience** - all features enabled

**Setup:**
```bash
# Install all three for maximum power
claude plugin install specswarm  # Tech enforcement
claude plugin install spectest   # Parallel + metrics
claude plugin install speclab    # Lifecycle workflows

# Result: Complete development lifecycle coverage
```

---

## 📊 Common Scenarios

### Scenario 1: User Reports Login Bug

```bash
# 1. Create bugfix branch
git checkout -b bugfix/042-login-timeout

# 2. Run bugfix workflow
/speclab:bugfix

# Expected output:
🐛 Bugfix Workflow - Feature 042
✓ Branch detected: bugfix/042-login-timeout
✓ Creating bugfix specification...
✓ Creating regression test specification...
✓ Generating tasks...

📋 Tasks Generated (5 tasks):
T001: Write regression test
T002: Verify test fails (proves bug exists)
T003: Implement fix
T004: Verify test passes (proves fix works)
T005: Run full test suite (no regressions)

# 3. Claude executes workflow
# 4. Commit fix
git add . && git commit -m "fix: login timeout issue (bug 042)"
```

**Timeline**: ~2 hours
**Result**: Bug fixed with regression test preventing future occurrences

---

### Scenario 2: Add Pagination to Existing API

```bash
# 1. First, analyze impact
/speclab:impact 018

# Output shows:
📊 Impact Analysis:
- Direct dependencies: 12 API consumers
- Breaking changes: Yes (response format change)
- Risk level: High
- Recommendation: Use /speclab:modify with compatibility layer

# 2. Create modify branch
git checkout -b modify/018-api-pagination

# 3. Run modify workflow
/speclab:modify

# Expected output:
🔧 Modify Workflow - Feature 018
✓ Loading existing specification...
✓ Analyzing impact...

📊 Impact Analysis:
Breaking Changes Detected:
- Response format changes (pagination wrapper)
- Query parameter changes (page → offset/limit)

Backward Compatibility Strategy:
- Add v2 endpoints with new pagination
- Maintain v1 endpoints with legacy format
- Deprecation timeline: 6 months

📋 Tasks Generated (12 tasks):
Phase 1: Compatibility Layer (3 tasks)
Phase 2: Implementation (5 tasks - parallel)
Phase 3: Migration (4 tasks)

# 4. Claude executes workflow with compatibility layer
# 5. Commit changes
git add . && git commit -m "feat: add pagination to API (modify 018)"
```

**Timeline**: ~4 hours
**Result**: Feature modified with backward compatibility maintained

---

### Scenario 3: Production Outage - Critical Bug

```bash
# 1. Create hotfix branch immediately
git checkout -b hotfix/099-critical-outage

# 2. Run EMERGENCY hotfix workflow
/speclab:hotfix

# Expected output:
🚨 Hotfix Workflow - EMERGENCY MODE - Hotfix 099
⚡ Expedited process active (minimal overhead)

📋 Emergency Tasks (4 tasks):
T001: Implement hotfix
T002: Essential testing
T003: Deploy to production
T004: Monitor post-deployment

Post-Emergency Tasks (3 tasks):
T005: Root cause analysis (within 24-48h)
T006: Permanent fix (if hotfix is temporary)
T007: Post-mortem (within 1 week)

# 3. Claude executes emergency tasks (<2h)
# 4. Emergency resolved, service restored

✅ EMERGENCY RESOLVED
⏱️  Time to Resolution: 52 minutes

# 5. Schedule post-emergency tasks
# Use /speclab:bugfix later for permanent fix if hotfix is temporary
```

**Timeline**: <2 hours for emergency resolution
**Result**: Service restored, post-mortem scheduled

---

### Scenario 4: Code Quality Improvement

```bash
# 1. Create refactor branch
git checkout -b refactor/025-reduce-complexity

# 2. Run refactor workflow
/speclab:refactor

# Expected output:
♻️  Refactor Workflow - Feature 025

📊 Baseline Metrics:
- Cyclomatic Complexity: 45 (target: <10)
- Duplication: 12% (target: <3%)
- Maintainability: 52/100 (target: >65)

📋 Refactoring Opportunities:
1. Extract function: processUserData
2. Eliminate duplication: validation logic
3. Reduce nesting: conditional chains

📋 Tasks Generated:
Phase 1: Baseline (2 tasks)
Phase 2: Refactoring Steps (6 incremental tasks)
Phase 3: Validation (3 tasks)

# 3. Claude executes incremental refactoring
# 4. Tests after each step (behavior preservation)

✅ Refactor Complete
📊 Metrics Improvement:
- Complexity: 45 → 12 (73% improvement) ✅
- Duplication: 12% → 2% (83% improvement) ✅
- Maintainability: 52 → 78 (50% improvement) ✅
✅ All tests passed (behavior preserved)

# 5. Commit improvements
git add . && git commit -m "refactor: reduce complexity in user processing"
```

**Timeline**: ~3 hours
**Result**: Code quality measurably improved, behavior preserved

---

### Scenario 5: Remove Legacy Feature

```bash
# 1. Create deprecate branch
git checkout -b deprecate/030-old-api

# 2. Run deprecate workflow
/speclab:deprecate

# Expected output:
📉 Deprecate Workflow - Feature 030

📅 Deprecation Timeline:
Month 1: Announcement Phase
Month 2-3: Migration Support Phase
Month 4: Removal Phase

📋 Migration Guide Created:
- Alternative recommended: New API v2
- Migration steps documented
- Support resources listed

📋 Tasks Generated:
Phase 1: Announcement (4 tasks - parallel)
  - Add deprecation warnings
  - Publish migration guide
  - Update documentation
  - Announce deprecation

Phase 2: Migration Support (3 tasks - ongoing)
  - Monitor adoption
  - Provide user support
  - Send reminders

Phase 3: Removal (6 tasks)
  - Final migration check (≥90% migrated)
  - Disable feature
  - Remove code
  - Cleanup docs

# 3. Execute Phase 1 (Month 1)
# 4. Monitor migration (Months 2-3)
# 5. Remove feature (Month 4, after ≥90% migration)

✅ Deprecation Complete
📊 Migration Success:
- Users migrated: 91%
- Timeline: Completed on schedule
- User complaints: 2 (both resolved)
```

**Timeline**: 3-4 months (phased)
**Result**: Feature safely removed, users successfully migrated

---

## 🆘 Troubleshooting

### General Issues

| Problem | Solution |
|---------|----------|
| "No branch detected" | Use branch naming: `bugfix/NNN-*`, `modify/NNN-*`, etc. or provide number when prompted |
| "Feature directory not found" | Check `features/` directory or create with correct number |
| "Metrics not available" | Install SpecTest: `claude plugin install spectest` |
| "Tech validation not working" | Install SpecSwarm: `claude plugin install specswarm` |

### Workflow-Specific Issues

**Bugfix:**
- Test doesn't fail → Review test specification
- Test still fails after fix → Fix incomplete or test incorrect
- New regressions → Revert, analyze impact, adjust

**Modify:**
- High risk assessment → Consider phased rollout, feature flags
- Breaking changes → Implement compatibility layer or migration plan
- Impact analysis incomplete → Run `/speclab:impact` first

**Hotfix:**
- Hotfix failed → Execute rollback immediately
- Rollback failed → CRITICAL - manual intervention required
- Emergency worsens → Stop attempt, consider maintenance mode

**Refactor:**
- Tests fail → Behavior not preserved, revert and try smaller steps
- Metrics not improved → Review refactoring strategy
- Performance regression → Profile and optimize or revert

**Deprecate:**
- Low migration rate → Extend timeline, improve guide, provide support
- Migration blockers → Identify and resolve, may need to adjust alternative
- User complaints → Provide support, ensure alternative sufficient

---

## 💡 Best Practices

### 1. Use Branch Naming Conventions

**Auto-detection works with proper naming:**
```bash
bugfix/042-description    # Auto-detected as bugfix
modify/018-description    # Auto-detected as modify
hotfix/099-description    # Auto-detected as hotfix
refactor/025-description  # Auto-detected as refactor
deprecate/030-description # Auto-detected as deprecate
```

### 2. Let `/speclab:suggest` Help

**When unsure:**
```bash
/speclab:suggest "login is broken"
# AI analyzes context and recommends workflow
```

### 3. Install All Three Plugins

**For best experience:**
```bash
claude plugin install specswarm  # Tech enforcement
claude plugin install spectest   # Parallel + metrics
claude plugin install speclab    # Lifecycle workflows

# Result: Complete coverage with all enhancements
```

### 4. Review Impact Before Modifying

**Always analyze first:**
```bash
/speclab:impact 018              # Before modification
# Then: /speclab:modify            # After understanding impact
```

### 5. Track Metrics to Improve

**Monitor performance:**
```bash
/speclab:workflow-metrics        # View dashboard regularly
# Identify bottlenecks and optimize
```

### 6. Post-Mortems Are Mandatory

**After hotfixes:**
- Root cause analysis required
- Document learnings
- Prevent future emergencies
- Consider permanent fix

### 7. Phased Approach for Deprecations

**Don't rush removals:**
- Announce early (Month 1)
- Support migration (Months 2-3)
- Only remove after ≥90% migrated (Month 4+)

---

## 📚 Learn More

- [Full SpecLab Documentation](../../plugins/speclab/README.md)
- [SpecSwarm Integration](../../plugins/specswarm/README.md)
- [SpecTest Performance](../../plugins/spectest/README.md)
- [Complete Workflow Guide](complete-workflow-guide.md)
- [Bugfix Example](../examples/bugfix-example.md)
- [Modification Example](../examples/modification-example.md)
- [spec-kit-extensions](https://github.com/MartyBonacci/spec-kit-extensions) - Original methodologies

---

**Quick Reference Card:**

```
NEW FEATURE    → /spectest:* or /specswarm:*
BUG FIX        → /speclab:bugfix
MODIFICATION   → /speclab:modify
EMERGENCY      → /speclab:hotfix
QUALITY        → /speclab:refactor
SUNSET         → /speclab:deprecate
NOT SURE?      → /speclab:suggest
```

**Coverage**: SpecSwarm + SpecTest + SpecLab = ~95% of development lifecycle
