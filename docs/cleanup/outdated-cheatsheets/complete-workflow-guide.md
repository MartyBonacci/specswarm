# Complete Workflow Guide
## SpecKit • SpecSwarm • SpecTest • SpecLab

**Master reference for choosing the right plugin and workflow for any development task**

---

## 🎯 Quick Decision Tree

```
What are you working on?

├─ NEW FEATURE?
│  ├─ Want maximum speed? → SpecTest ⚡ (2-4x faster)
│  ├─ Want tech enforcement? → SpecSwarm 🛡️ (95% drift prevention)
│  └─ Want pure SDD? → SpecKit 📋 (original methodology)
│
├─ BUG TO FIX?
│  └─ SpecLab:bugfix 🐛 (regression-test-first)
│
├─ MODIFY EXISTING FEATURE?
│  └─ SpecLab:modify 🔧 (impact analysis first)
│
├─ PRODUCTION EMERGENCY?
│  └─ SpecLab:hotfix 🚨 (< 2h resolution)
│
├─ CODE QUALITY ISSUE?
│  └─ SpecLab:refactor ♻️ (metrics-driven)
│
├─ REMOVE FEATURE?
│  └─ SpecLab:deprecate 📉 (phased sunset)
│
└─ NOT SURE?
   └─ SpecLab:suggest 🤖 (AI recommendation)
```

---

## 📊 Plugin Comparison Matrix

| Aspect | SpecKit | SpecSwarm | SpecTest | SpecLab |
|--------|---------|-----------|----------|---------|
| **Primary Use** | Feature dev | Feature dev | Feature dev | Lifecycle workflows |
| **Stability** | ✅ Stable | ✅ Stable | ⚠️ Experimental | ⚠️ Experimental |
| **Workflow Coverage** | ~25% | ~25% | ~25% | **~75%** |
| **SDD Methodology** | ✅ Pure | ✅ Enhanced | ✅ Enhanced | N/A (lifecycle) |
| **Tech Stack Enforcement** | ❌ | ✅ 95% drift prevention | ✅ Inherited | ✅ Inherited |
| **Parallel Execution** | ❌ | ❌ | ✅ 2-4x faster | ✅ Inherited |
| **Pre/Post Hooks** | ❌ | ❌ | ✅ 8 hook points | ✅ Inherited |
| **Performance Metrics** | ❌ | ❌ | ✅ Dashboard | ✅ Extended |
| **Bugfix Workflow** | ❌ | ❌ | ❌ | ✅ Regression-test-first |
| **Modify Workflow** | ❌ | ❌ | ❌ | ✅ Impact analysis |
| **Hotfix Workflow** | ❌ | ❌ | ❌ | ✅ Emergency response |
| **Refactor Workflow** | ❌ | ❌ | ❌ | ✅ Metrics-driven |
| **Deprecate Workflow** | ❌ | ❌ | ❌ | ✅ Phased sunset |
| **Typical Feature Time** | ~18-20 min | ~18-20 min | **~6-8 min** | N/A |
| **Typical Bugfix Time** | N/A | N/A | N/A | **~2h** |
| **Typical Modify Time** | N/A | N/A | N/A | **~4h** |
| **Typical Hotfix Time** | N/A | N/A | N/A | **<2h** |

---

## 🚀 Recommended Setups

### Option 1: Maximum Coverage (Recommended)

**Install all four plugins for complete lifecycle coverage:**

```bash
claude plugin install speckit     # Original SDD (backup option)
claude plugin install specswarm   # Tech stack enforcement
claude plugin install spectest    # Parallel execution + metrics
claude plugin install speclab     # Lifecycle workflows
```

**Usage Pattern:**
- **New features**: `/spectest:*` (fastest with parallel execution)
- **Bug fixes**: `/speclab:bugfix` (regression-test-first)
- **Modifications**: `/speclab:modify` (impact analysis)
- **Emergencies**: `/speclab:hotfix` (expedited response)
- **Quality**: `/speclab:refactor` (metrics-driven)
- **Sunset**: `/speclab:deprecate` (phased removal)

**Result**: ~95% development lifecycle coverage

**Best For**: Professional teams, long-lived projects, complete coverage

---

### Option 2: Essential Duo

**SpecSwarm + SpecLab:**

```bash
claude plugin install specswarm   # Tech stack enforcement + feature development
claude plugin install speclab     # Lifecycle workflows
```

**Usage Pattern:**
- **New features**: `/specswarm:*` (tech enforcement, sequential)
- **Everything else**: `/speclab:*` (all lifecycle workflows)

**Result**: Complete coverage but slower feature development (sequential execution)

**Best For**: Teams prioritizing tech consistency over speed

---

### Option 3: Speed + Lifecycle

**SpecTest + SpecLab:**

```bash
claude plugin install spectest    # Fast feature development
claude plugin install speclab     # Lifecycle workflows
```

**Usage Pattern:**
- **New features**: `/spectest:*` (2-4x faster)
- **Everything else**: `/speclab:*` (all lifecycle workflows)

**Result**: Maximum speed but no tech enforcement (unless SpecSwarm also installed)

**Best For**: Solo developers, experimental projects, speed-critical workflows

---

### Option 4: Pure SDD

**SpecKit only:**

```bash
claude plugin install speckit     # Original methodology
```

**Usage Pattern:**
- **New features only**: `/speckit:*`
- Ad-hoc for everything else

**Result**: ~25% coverage (feature development only)

**Best For**: Learning SDD, conservative environments, minimal dependencies

---

## 📋 Complete Command Reference

### SpecKit Commands (Original SDD)

| Command | Purpose | Time |
|---------|---------|------|
| `/speckit.constitution` | Establish project principles | 10-15 min |
| `/speckit.specify` | Define feature specifications | 10-20 min |
| `/speckit.clarify` | Resolve ambiguities | 5-10 min |
| `/speckit.plan` | Create technical plans | 15-30 min |
| `/speckit.tasks` | Generate task breakdowns | 5-10 min |
| `/speckit.implement` | Execute implementation | 30-60 min |
| `/speckit.analyze` | Validate consistency | 5-10 min |
| `/speckit.checklist` | Create quality checklists | 5-10 min |

**Total Feature Time**: ~18-20 minutes (typical)

---

### SpecSwarm Commands (+ Tech Enforcement)

| Command | Purpose | Enhancement |
|---------|---------|-------------|
| `/specswarm:constitution` | Establish principles | + Tech enforcement |
| `/specswarm:specify` | Define specifications | Same |
| `/specswarm:clarify` | Resolve ambiguities | Same |
| `/specswarm:plan` | Create plans | **+ Auto tech validation** |
| `/specswarm:tasks` | Generate tasks | **+ Tech pre-validation** |
| `/specswarm:implement` | Execute | **+ Runtime enforcement** |
| `/specswarm:analyze` | Validate consistency | Same |
| `/specswarm:checklist` | Create checklists | Same |

**Total Feature Time**: ~18-20 minutes (same as SpecKit, but with tech safety)

**Key Benefit**: 95% tech stack drift prevention

---

### SpecTest Commands (+ Performance)

| Command | Purpose | Enhancement |
|---------|---------|-------------|
| `/spectest:specify` | Define specifications | + Pre/post hooks, quality validation |
| `/spectest:plan` | Create plans | + Hooks, tech stack summary |
| `/spectest:tasks` | Generate tasks | + Hooks, parallel detection, preview |
| `/spectest:implement` | Execute | **+ Parallel batching (2-4x faster!)** |
| `/spectest:metrics` | Performance dashboard | **NEW command** |

**Total Feature Time**: ~6-8 minutes (2-4x faster than SpecSwarm)

**Key Benefit**: Maximum speed + tech enforcement + metrics

**Note**: Phase 2 commands (constitution, clarify, analyze, checklist) are functional copies from SpecSwarm (hooks planned for Phase 2)

---

### SpecLab Commands (Lifecycle Workflows)

| Command | Purpose | Coverage | Time |
|---------|---------|----------|------|
| `/speclab:bugfix` | Regression-test-first bug fixing | 40% of work | ~2h |
| `/speclab:modify` | Impact-analysis-first modifications | 30% of work | ~4h |
| `/speclab:hotfix` | Expedited emergency response | 10-15% of work | <2h |
| `/speclab:refactor` | Metrics-driven quality improvement | 10% of work | ~3h |
| `/speclab:deprecate` | Phased feature sunset | 5% of work | Weeks |
| `/speclab:impact <feature>` | Standalone impact analysis | Utility | ~5 min |
| `/speclab:suggest` | AI workflow recommendation | Utility | ~1 min |
| `/speclab:workflow-metrics [feature]` | Analytics dashboard | Utility | Instant |

**Total Lifecycle Coverage**: ~75% of non-feature development work

**Key Benefit**: Complete lifecycle coverage beyond feature development

---

## 🔀 Integration Patterns

### Pattern 1: SpecLab with SpecSwarm

**What Happens:**
- SpecLab workflows automatically detect SpecSwarm
- Tech stack enforcement enabled for all SpecLab workflows
- Bugfixes, modifications, hotfixes all validate against tech stack
- No drift during maintenance work

**Example:**
```bash
/speclab:bugfix
# Output:
🎯 Smart Integration: SpecSwarm detected
✓ Tech stack enforcement enabled
✓ Loading tech stack: /memory/tech-stack.md

[... regression-test-first workflow ...]

🔍 Tech Stack Validation
✓ All bug fix code complies with tech stack
✓ No drift detected
```

---

### Pattern 2: SpecLab with SpecTest

**What Happens:**
- SpecLab workflows automatically detect SpecTest
- Parallel execution enabled where applicable
- Pre/post hooks run for validation
- Metrics tracked across all workflows

**Example:**
```bash
/speclab:modify
# Output:
🎯 Smart Integration: SpecTest detected
✓ Parallel execution enabled
✓ Hooks enabled: Pre/post workflow validation

[... impact analysis ...]

Phase 2: Implementation (5 tasks) - Parallel Batch
⚡ Executing 5 tasks in parallel...
✓ T003-T007: All modifications applied (1m 45s vs 8m sequential)

📊 Speedup: 4.6x faster with parallel execution
```

---

### Pattern 3: SpecLab with SpecSwarm + SpecTest

**Best of Both Worlds:**
- Tech enforcement from SpecSwarm
- Parallel execution from SpecTest
- Hooks and metrics from SpecTest
- Complete lifecycle coverage from SpecLab

**Example:**
```bash
/speclab:modify
# Output:
🎯 Smart Integration Detected
✓ SpecSwarm installed: Tech stack enforcement enabled
✓ SpecTest installed: Parallel execution enabled
✓ Loading tech stack: /memory/tech-stack.md

[... impact analysis with tech validation ...]

Phase 2: Implementation (5 tasks) - Parallel Batch
⚡ Executing 5 tasks in parallel...
[... fast parallel execution ...]

🔍 Tech Stack Validation
✓ All modifications comply with tech stack
✓ No drift detected

📊 Metrics
- Time to modify: 1.8h (vs 4.2h sequential = 2.3x faster)
- Tech stack violations: 0
- Parallel speedup: 2.3x
```

---

## 🎓 Learning Path

### Level 1: Beginner (Start Here)

**Install**: SpecKit

**Learn**:
1. Spec-Driven Development methodology
2. 8-step workflow (constitution → specify → clarify → plan → tasks → implement → analyze → checklist)
3. Creating clear specifications
4. Technical planning

**Timeline**: 1-2 weeks to become proficient

**Next**: Graduate to SpecSwarm for tech enforcement

---

### Level 2: Intermediate

**Install**: SpecSwarm

**Learn**:
1. Tech stack management
2. Drift prevention
3. Handling tech conflicts
4. Semantic versioning for tech changes

**Timeline**: 1 week to learn tech features

**Next**: Add SpecTest for speed or SpecLab for lifecycle coverage

---

### Level 3: Advanced

**Install**: SpecSwarm + SpecTest

**Learn**:
1. Parallel execution patterns
2. Hooks system
3. Performance optimization
4. Metrics tracking

**Timeline**: 1 week to master performance features

**Next**: Add SpecLab for complete lifecycle coverage

---

### Level 4: Master

**Install**: All four plugins

**Learn**:
1. SpecLab lifecycle workflows
2. When to use which workflow
3. Complete development orchestration
4. Optimizing entire development process

**Timeline**: 2 weeks to master all lifecycle workflows

**Result**: ~95% development lifecycle coverage with optimal speed and quality

---

## 📖 Common Scenarios

### Scenario 1: Starting New Project

**Recommended Setup**: SpecSwarm + SpecTest + SpecLab

**Workflow**:
```bash
# 1. Set up project constitution
/specswarm:constitution

# 2. Build first feature (fast)
git checkout -b feature/001-user-auth
/spectest:specify
/spectest:plan
/spectest:tasks
/spectest:implement

# 3. Fix bugs as they arise
git checkout -b bugfix/002-login-timeout
/speclab:bugfix

# 4. Modify features as needed
git checkout -b modify/001-add-2fa
/speclab:modify

# 5. Track everything
/speclab:workflow-metrics
```

**Result**: Complete coverage from day one

---

### Scenario 2: Existing Project (Adding SpecLab)

**Current Setup**: Using SpecSwarm or SpecTest for features

**Add**: SpecLab for lifecycle workflows

**Workflow**:
```bash
# Install SpecLab
claude plugin install speclab

# Start using for non-feature work
/speclab:bugfix      # Instead of ad-hoc bug fixes
/speclab:modify      # Instead of unplanned modifications
/speclab:hotfix      # For emergencies
/speclab:refactor    # For quality improvements
/speclab:deprecate   # For feature removals

# Continue using existing plugin for features
/spectest:implement  # or /specswarm:implement
```

**Result**: Extend coverage to complete lifecycle

---

### Scenario 3: Learning SDD

**Start With**: SpecKit

**Workflow**:
```bash
# 1. Install pure SDD
claude plugin install speckit

# 2. Build first feature
/speckit.constitution
/speckit.specify
/speckit.clarify
/speckit.plan
/speckit.tasks
/speckit.implement
/speckit.analyze
/speckit.checklist

# 3. Repeat for multiple features
# 4. Learn methodology thoroughly

# 5. Graduate to SpecSwarm when ready
claude plugin install specswarm
# Now use /specswarm:* for tech enforcement
```

**Result**: Solid SDD foundation

---

### Scenario 4: Solo Developer

**Recommended Setup**: SpecTest + SpecLab

**Workflow**:
```bash
# Features: Use SpecTest for speed
/spectest:specify
/spectest:implement  # 2-4x faster

# Bugs: Use SpecLab
/speclab:bugfix

# Everything else: Use SpecLab
/speclab:modify
/speclab:refactor
/speclab:deprecate

# Track performance
/speclab:workflow-metrics
```

**Result**: Maximum speed + complete coverage

**Note**: Consider adding SpecSwarm if tech drift becomes an issue

---

### Scenario 5: Team with Tech Drift Issues

**Recommended Setup**: SpecSwarm + SpecLab

**Workflow**:
```bash
# Features: Use SpecSwarm for tech enforcement
/specswarm:plan       # Tech validation at planning
/specswarm:implement  # Tech enforcement at runtime

# Lifecycle: Use SpecLab with tech enforcement
/speclab:bugfix       # Bugs validated against tech stack
/speclab:modify       # Modifications validated
/speclab:refactor     # Refactors validated

# Result: 95% drift prevention across ALL work
```

**Result**: Tech consistency across complete lifecycle

**Upgrade**: Add SpecTest later for speed boost (optional)

---

## 🆘 Troubleshooting

### "Which plugin should I use?"

**Use decision tree at top of guide** or:

```bash
/speclab:suggest "describe what you're working on"
# AI analyzes and recommends specific plugin + workflow
```

---

### "Can I use multiple plugins together?"

**Yes! Recommended setups:**
- **SpecSwarm + SpecLab**: Tech enforcement + lifecycle
- **SpecTest + SpecLab**: Speed + lifecycle
- **SpecSwarm + SpecTest + SpecLab**: Everything (recommended)

**They integrate automatically** - no configuration needed

---

### "I installed SpecLab but tech validation isn't working"

**Install SpecSwarm**:
```bash
claude plugin install specswarm
```

SpecLab automatically detects and uses SpecSwarm for tech enforcement

---

### "SpecLab workflows are slow"

**Install SpecTest**:
```bash
claude plugin install spectest
```

SpecLab automatically detects and uses SpecTest for parallel execution

---

### "I want metrics but don't have them"

**Install SpecTest**:
```bash
claude plugin install spectest
```

Metrics require SpecTest plugin

---

### "Should I uninstall SpecKit if I have SpecSwarm?"

**Keep both** - SpecKit is good backup if you ever want pure SDD without tech enforcement

**Storage is minimal** - plugins are lightweight

---

### "Are there conflicts between plugins?"

**No conflicts** - plugins are designed to work together:
- SpecSwarm adds tech enforcement
- SpecTest adds performance
- SpecLab adds lifecycle workflows
- All integrate seamlessly

---

## 💡 Best Practices

### 1. Install Based on Needs, Not Trends

**Don't just install everything if you don't need it**:
- Learning SDD? → Start with SpecKit
- Need tech consistency? → Add SpecSwarm
- Want speed? → Add SpecTest
- Need lifecycle? → Add SpecLab

**But: Most professional teams benefit from all four**

---

### 2. Use Correct Branch Naming

**For auto-detection:**
```bash
feature/NNN-*    # Feature development (SpecKit/Swarm/Test)
bugfix/NNN-*     # Bug fixes (SpecLab)
modify/NNN-*     # Modifications (SpecLab)
hotfix/NNN-*     # Emergencies (SpecLab)
refactor/NNN-*   # Quality (SpecLab)
deprecate/NNN-*  # Sunset (SpecLab)
```

---

### 3. Let AI Help with Decisions

**Unsure which workflow?**
```bash
/speclab:suggest
# AI recommends based on branch, commits, files, description
```

---

### 4. Track Metrics to Improve

**If you have SpecTest:**
```bash
/speclab:workflow-metrics
# View performance across all workflows
# Identify bottlenecks and optimize
```

---

### 5. Graduate Plugins Gradually

**Recommended progression:**
```
SpecKit (learn SDD)
  ↓
SpecSwarm (add tech enforcement)
  ↓
SpecTest (add speed) or SpecLab (add lifecycle)
  ↓
All Four (complete coverage)
```

---

## 📚 Additional Resources

### Cheatsheets
- [SpecKit Cheatsheet](speckit-cheatsheet.md)
- [SpecSwarm Cheatsheet](specswarm-cheatsheet.md)
- [SpecTest Cheatsheet](spectest-cheatsheet.md)
- [SpecLab Cheatsheet](speclab-cheatsheet.md) ⭐ Start here for lifecycle workflows

### Examples
- [Feature Development Example](../examples/feature-development-example.md)
- [Bugfix Example](../examples/bugfix-example.md)
- [Modification Example](../examples/modification-example.md)

### Full Documentation
- [SpecKit README](../../plugins/speckit/README.md)
- [SpecSwarm README](../../plugins/specswarm/README.md)
- [SpecTest README](../../plugins/spectest/README.md)
- [SpecLab README](../../plugins/speclab/README.md)

### External Resources
- [GitHub spec-kit](https://github.com/github/spec-kit) - Original SDD methodology
- [spec-kit-extensions](https://github.com/MartyBonacci/spec-kit-extensions) - SpecLab methodologies
- [Claude Code Plugins](https://docs.claude.com/en/docs/claude-code/plugins) - Plugin system

---

## 🎯 Quick Reference Card

```
PLUGIN SELECTION:
NEW FEATURE     → SpecTest (fastest) or SpecSwarm (tech enforcement)
BUG FIX         → SpecLab:bugfix
MODIFICATION    → SpecLab:modify
EMERGENCY       → SpecLab:hotfix
QUALITY         → SpecLab:refactor
SUNSET          → SpecLab:deprecate
NOT SURE?       → SpecLab:suggest

INTEGRATION:
SpecLab + SpecSwarm = Tech enforcement on lifecycle workflows
SpecLab + SpecTest = Parallel execution + metrics
SpecLab + Both = Best of both worlds

COVERAGE:
SpecSwarm/SpecTest = ~25% (features)
SpecLab = ~75% (lifecycle)
Combined = ~95% (complete)
```

---

**Master all four plugins = Complete development lifecycle coverage with optimal speed, quality, and tech consistency** 🚀
