# SpecSwarm Consolidation & Simplification Plan

**Goal**: Single plugin with simple, orchestrated commands that hide complexity

**Date**: 2025-11-08
**Status**: Planning Phase
**Target Version**: SpecSwarm v3.0.0

---

## Executive Summary

**Current Problems**:
1. ✗ Users must install 2 plugins (SpecSwarm + SpecLabs)
2. ✗ 25 total commands across both plugins (overwhelming)
3. ✗ Users must manually orchestrate 7+ commands for a single feature
4. ✗ "Experimental" label on SpecLabs despite proven functionality
5. ✗ Confusion about which command to use when

**Solution**:
1. ✓ Consolidate into single SpecSwarm plugin
2. ✓ Create high-level orchestration commands (2-3 commands instead of 7+)
3. ✓ Hide complexity - let users specify intent, not process
4. ✓ Maintain advanced commands for power users
5. ✓ Clear workflow paths for common scenarios

**User Experience Transformation**:

*Before (Current)*:
```bash
/plugin install specswarm
/plugin install speclabs
/specswarm:specify "Add user auth"
/specswarm:clarify
/specswarm:plan
/specswarm:tasks
/specswarm:implement
/specswarm:analyze-quality
/specswarm:complete
```
**8 steps**, 7 commands, 2 plugins

*After (v3.0.0)*:
```bash
/plugin install specswarm
/specswarm:build "Add user authentication with email/password"
# [Interactive clarification, then autonomous execution]
/specswarm:ship
```
**3 steps**, 2 commands, 1 plugin

---

## Phase 1: Consolidation Strategy

### 1.1 Graduate Proven SpecLabs Features to SpecSwarm

| SpecLabs Command | Action | New SpecSwarm Name | Rationale |
|------------------|--------|-------------------|-----------|
| `orchestrate-feature` | **GRADUATE** | Internal (used by high-level commands) | Proven with Feature 015, 100% success |
| `feature-metrics` | **GRADUATE** | `/specswarm:metrics` | Replace workflow-metrics, more useful |
| `validate-feature` | **GRADUATE** | `/specswarm:validate` | Multi-type validation is production-ready |
| `metrics` (task-level) | **KEEP INTERNAL** | - | Used by orchestration, not user-facing |
| `coordinate` | **DEPRECATE** | - | Complex, rarely used, can revisit later |
| `orchestrate` | **DEPRECATE** | - | Too generic, orchestrate-feature better |
| `orchestrate-validate` | **MERGE** | Into `validate` | Consolidate validation |

**Migration Path**:
- Move proven code from `plugins/speclabs/` to `plugins/specswarm/`
- Keep internal libraries (orchestration engine, validators) but hide from users
- Remove SpecLabs plugin entirely from marketplace

### 1.2 Consolidate Existing SpecSwarm Commands

**Keep As-Is** (Advanced/Power User Commands):
- `specify`, `clarify`, `plan`, `tasks`, `implement` - Manual workflow steps
- `bugfix`, `hotfix`, `modify`, `refactor`, `deprecate` - Lifecycle commands
- `complete` - Always needed for final merge
- `impact`, `analyze`, `analyze-quality` - Quality commands
- `constitution`, `checklist` - Setup/validation helpers
- `suggest` - Workflow recommender

**Consolidate/Rename**:
- `workflow-metrics` → **REPLACE** with graduated `feature-metrics`

**Total Advanced Commands**: 17 (down from 18)

---

## Phase 2: High-Level Orchestration Commands

### 2.1 New User-Facing Commands (Simple Mode)

These commands orchestrate multiple steps automatically:

#### `/specswarm:build` - Build New Feature
**Replaces**: specify → clarify → plan → tasks → implement → validate

```bash
/specswarm:build "Add user authentication with email/password"

# Optional flags:
--validate          # Include browser validation (recommended)
--auto-clarify      # Skip interactive clarification (use AI inference)
--quality-gate 85   # Set minimum quality score (default: 80)
```

**What It Does**:
1. Runs `/specswarm:specify` internally
2. Runs `/specswarm:clarify` (interactive - pauses for user input)
3. Runs `/specswarm:plan` internally
4. Runs `/specswarm:tasks` internally
5. Runs `/specswarm:implement` internally
6. If `--validate`: Runs `/specswarm:validate` internally
7. Runs `/specswarm:analyze-quality` internally
8. Reports: "Feature ready for testing. Run /specswarm:ship when ready."

**User Experience**:
- Single command
- Interactive clarification (only pause point)
- Autonomous execution
- Quality validated automatically

---

#### `/specswarm:fix` - Fix Bug with Regression Tests
**Replaces**: Manual bugfix workflow

```bash
/specswarm:fix "Bug: Login fails with special characters in password"

# Optional flags:
--regression-test   # Generate regression test first (recommended)
--hotfix           # Use expedited hotfix workflow for production
```

**What It Does**:
1. Analyzes bug description
2. If `--regression-test`: Creates failing test first
3. Implements fix
4. Validates fix passes new test
5. Runs full test suite
6. Reports: "Bug fixed and tested. Run /specswarm:ship when ready."

**Replaces**: `/specswarm:bugfix` and `/specswarm:hotfix`

---

#### `/specswarm:upgrade` - Upgrade Dependencies/Framework
**NEW** - Addresses migration gap

```bash
/specswarm:upgrade "React 18 to React 19"

# Or:
/specswarm:upgrade --deps          # All dependencies
/specswarm:upgrade --package react # Specific package
```

**What It Does**:
1. Analyzes breaking changes
2. Generates migration plan
3. Updates dependencies
4. Refactors code for breaking changes
5. Runs tests
6. Reports compatibility issues
7. Reports: "Upgrade complete. Test manually, then run /specswarm:ship."

**Addresses Gap**: Dependency management & migration workflows

---

#### `/specswarm:ship` - Final Quality Gate & Merge
**Replaces**: analyze-quality → complete

```bash
/specswarm:ship

# Optional flags:
--force-quality 70  # Override quality gate (default: 80)
--skip-tests       # Skip test validation (not recommended)
```

**What It Does**:
1. Runs `/specswarm:analyze-quality` internally
2. Checks quality score meets threshold
3. If pass: Runs `/specswarm:complete` internally
4. If fail: Reports issues and blocks merge
5. Creates git tag, merges to parent branch

**User Experience**:
- Single command for final merge
- Quality gate enforced
- Clear pass/fail with remediation steps

---

### 2.2 Command Mapping

| User Intent | Simple Command | Advanced Commands (if manual control needed) |
|-------------|----------------|------------------------------------------|
| Build new feature | `/specswarm:build` | specify → clarify → plan → tasks → implement |
| Fix bug | `/specswarm:fix` | bugfix or hotfix |
| Upgrade tech | `/specswarm:upgrade` | modify + manual work |
| Refactor code | `/specswarm:refactor` | refactor (already exists) |
| Final merge | `/specswarm:ship` | analyze-quality → complete |
| Check quality | `/specswarm:quality` | analyze-quality (rename for simplicity) |
| View metrics | `/specswarm:metrics` | Graduated feature-metrics |
| Remove feature | `/specswarm:deprecate` | deprecate (already exists) |

---

## Phase 3: Simplified User Journey

### Beginner Flow (Recommended)
```bash
# One-time setup
/specswarm:init                    # NEW - runs constitution + tech-stack setup

# Per feature
/specswarm:build "feature description" --validate
# [Answer clarification questions]
# [Wait for completion]
# [Manual testing]
/specswarm:ship
```

**Total**: 3 commands (init, build, ship)

### Intermediate Flow (More Control)
```bash
/specswarm:build "feature description" --auto-clarify
# [Runs autonomously]
/specswarm:quality                 # Check before merge
/specswarm:fix "Bug: found issue"  # If needed
/specswarm:ship
```

**Total**: 2-4 commands depending on bugs

### Advanced Flow (Full Control)
```bash
/specswarm:specify "feature"
/specswarm:clarify
/specswarm:plan
/specswarm:tasks
/specswarm:implement
/specswarm:validate
/specswarm:analyze-quality
/specswarm:complete
```

**Total**: 8 commands (available but not recommended for beginners)

---

## Phase 4: Implementation Plan

### Step 1: Create Internal Orchestration Library (Week 1)
**Files**:
- `lib/orchestrator.sh` - High-level orchestration engine
- `lib/quality-gate.sh` - Quality threshold enforcement
- `lib/workflow-runner.sh` - Sequential command execution with state

**Functions**:
```bash
orchestrate_build()        # Runs specify→clarify→plan→tasks→implement→validate
orchestrate_fix()          # Runs bugfix workflow with regression tests
orchestrate_upgrade()      # NEW - Migration/upgrade workflow
orchestrate_ship()         # Runs quality→complete with gates
```

### Step 2: Create High-Level Commands (Week 1-2)
**New Files**:
- `commands/build.md` - Feature building orchestration
- `commands/fix.md` - Bug fixing orchestration
- `commands/upgrade.md` - Upgrade/migration orchestration
- `commands/ship.md` - Quality gate and merge
- `commands/init.md` - One-time project setup
- `commands/quality.md` - Renamed analyze-quality
- `commands/metrics.md` - Graduated feature-metrics

### Step 3: Migrate SpecLabs Code (Week 2)
**Actions**:
1. Copy `orchestrate-feature.md` → `lib/orchestrate-feature-internal.sh`
2. Copy `feature-metrics-collector.sh` → `lib/feature-metrics-collector.sh`
3. Copy `validate-feature` logic → `commands/validate.md`
4. Test all migrations
5. Update marketplace.json to remove speclabs

### Step 4: Update Documentation (Week 2-3)
**Files to Update**:
- `README.md` - New simple workflow
- `CHANGELOG.md` - v3.0.0 breaking changes
- `docs/WORKFLOW.md` - Simplified guide
- `docs/CHEATSHEET.md` - New command reference
- `docs/MIGRATION-v2-to-v3.md` - Migration guide for existing users

### Step 5: Testing & Validation (Week 3)
**Test Cases**:
1. `/specswarm:build` with Feature 016 (React Router v7)
2. `/specswarm:fix` with real bugs from customcult2
3. `/specswarm:ship` quality gate enforcement
4. Backward compatibility (old commands still work)
5. Metrics collection with new workflow

### Step 6: Release & Deprecation (Week 4)
**Actions**:
1. Release SpecSwarm v3.0.0
2. Mark SpecLabs as deprecated in marketplace
3. Provide migration guide for v2.x users
4. Announce simplification to users
5. Update GitHub README with new workflow

---

## Phase 5: Future Additions (Post-v3.0.0)

### Priority 1: Security (v3.1.0)
```bash
/specswarm:security-audit
```
- OWASP Top 10 scanning
- Dependency vulnerability checking
- Secrets detection
- CVE database integration

### Priority 2: Enhanced Upgrade (v3.2.0)
Improve `/specswarm:upgrade`:
- Framework migrations (Laravel → Remix, React 18 → 19)
- Breaking change detection from changelogs
- Codemod integration
- Test-driven migration (TDD for upgrades)

### Priority 3: Code Review (v3.3.0)
```bash
/specswarm:review
```
- Pre-merge AI code review
- Style guide enforcement
- Best practices checking
- Security vulnerability detection

### Priority 4: Rollback Safety (v3.4.0)
```bash
/specswarm:rollback <feature-number>
```
- Safe feature removal
- Dependency cleanup
- Database migration reversal
- Git history preservation

### Priority 5: Performance Profiling (v3.5.0)
```bash
/specswarm:profile
```
- Performance bottleneck detection
- Bundle size analysis
- Runtime profiling integration
- Optimization recommendations

---

## Breaking Changes (v3.0.0)

### Removed
- ❌ SpecLabs plugin entirely (functionality moved to SpecSwarm)
- ❌ `/specswarm:workflow-metrics` (replaced by `/specswarm:metrics`)

### Renamed
- `analyze-quality` → `quality` (shorter, simpler)
- `feature-metrics` (SpecLabs) → `metrics` (SpecSwarm)

### New Commands
- ✅ `/specswarm:build` - High-level feature building
- ✅ `/specswarm:fix` - High-level bug fixing
- ✅ `/specswarm:upgrade` - Dependency/framework upgrades
- ✅ `/specswarm:ship` - Quality gate and merge
- ✅ `/specswarm:init` - One-time project setup
- ✅ `/specswarm:validate` - Multi-type validation (from SpecLabs)

### Backward Compatibility
- ✅ All v2.x commands still work (manual workflow)
- ✅ Existing features can complete normally
- ✅ No data migration required
- ✅ Gradual adoption (users can mix old/new commands)

---

## Migration Guide (v2.x → v3.0.0)

### For Current SpecSwarm Users
**No action required** - All existing commands work.

**Optional**: Adopt new simplified commands:
- Replace `specify→clarify→plan→tasks→implement` with `/specswarm:build`
- Replace `analyze-quality→complete` with `/specswarm:ship`

### For Current SpecLabs Users
**Required**: Uninstall SpecLabs, use SpecSwarm v3.0.0

**Command Mapping**:
- `/speclabs:orchestrate-feature` → `/specswarm:build`
- `/speclabs:feature-metrics` → `/specswarm:metrics`
- `/speclabs:validate-feature` → `/specswarm:validate`

**No data loss**: Feature directories and artifacts remain compatible.

---

## Success Metrics

### User Experience
- ✅ Single plugin installation
- ✅ 2-3 commands for complete workflow (vs 7+)
- ✅ 70% reduction in commands for beginners
- ✅ Maintain power user flexibility

### Technical
- ✅ Zero breaking changes for manual workflow
- ✅ All SpecLabs functionality preserved
- ✅ Quality gates enforced automatically
- ✅ Metrics collection improved

### Adoption
- ✅ 90%+ of users adopt simplified commands within 3 months
- ✅ Support requests decrease (simpler UX)
- ✅ Feature completion time same or better
- ✅ Quality scores maintained or improved

---

## Timeline

| Phase | Duration | Deliverables |
|-------|----------|-------------|
| 1. Orchestration Library | 1 week | Internal libs for build/fix/ship/upgrade |
| 2. High-Level Commands | 1 week | New user-facing commands |
| 3. SpecLabs Migration | 1 week | Move proven features to SpecSwarm |
| 4. Documentation | 1 week | Updated guides and migration docs |
| 5. Testing | 1 week | Feature 016 + real-world validation |
| 6. Release | 1 week | v3.0.0 launch, deprecation notices |

**Total**: 6 weeks to v3.0.0 release

---

## Open Questions

1. **Command Naming**: Are `build`, `fix`, `ship`, `upgrade` the right names?
2. **Quality Gate**: Should `ship` enforce quality threshold or just warn?
3. **SpecLabs Sunset**: Deprecate with notice or remove entirely?
4. **Backward Compat**: Keep all v2.x commands or deprecate some?
5. **Init Command**: What should one-time setup include?

---

## Recommendation

**Start with Phase 1 & 2** using Feature 016 (React Router v7 Upgrade) as the test case:

1. Create `/specswarm:build` command
2. Create `/specswarm:ship` command
3. Test with Feature 016 implementation
4. Validate time savings and UX improvement
5. If successful, proceed with full consolidation

This incremental approach:
- ✅ Validates concept with real feature
- ✅ Reduces risk (can keep both plugins during transition)
- ✅ Gets user feedback early
- ✅ Allows course correction

**Next Action**: Should we build `/specswarm:build` and `/specswarm:ship` first, then test with Feature 016?
