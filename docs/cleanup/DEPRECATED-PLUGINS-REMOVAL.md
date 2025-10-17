# Deprecated Plugins Removal

**Date:** 2025-10-16
**Action:** Remove deprecated plugins from repository

---

## Plugins to Remove

### 1. debug-coordinate
- **Status:** Deprecated 2025-10-15
- **Merged Into:** SpecLabs v1.0.0 → v2.0.0
- **Migration:** `/debug-coordinate:coordinate` → `/speclabs:coordinate`
- **Reason:** Consolidated into SpecLabs experimental plugin

### 2. project-orchestrator
- **Status:** Deprecated 2025-10-15
- **Merged Into:** SpecLabs v1.0.0 → v2.0.0
- **Migration:** `/project-orchestrator:*` → `/speclabs:*`
- **Reason:** Consolidated into SpecLabs experimental plugin

### 3. speclab (singular)
- **Status:** Deprecated (older version)
- **Replaced By:** SpecLabs v2.0.0 (plural)
- **Migration:** `/speclab:*` → `/speclabs:*` or `/specswarm:*`
- **Reason:** Renamed to SpecLabs (plural), features merged to appropriate plugins

### 4. speckit
- **Status:** Deprecated (original plugin)
- **Replaced By:** SpecSwarm v2.0.0
- **Migration:** All spec-driven workflows now in SpecSwarm
- **Reason:** Original plugin, functionality superseded by SpecSwarm

### 5. spectest
- **Status:** Deprecated (experimental enhanced version)
- **Replaced By:** SpecSwarm v2.0.0
- **Migration:** `/spectest:*` → `/specswarm:*`
- **Reason:** Experimental features graduated to SpecSwarm stable

---

## Active Plugins (Keep)

### SpecSwarm v2.0.0
- **Purpose:** Complete stable software development toolkit
- **Commands:** specify, clarify, plan, tasks, implement, bugfix, refactor, etc.
- **Status:** Production-ready, actively maintained

### SpecLabs v2.0.0
- **Purpose:** Experimental laboratory for autonomous development
- **Commands:** coordinate, orchestrate-test, orchestrate-validate, orchestrate-feature
- **Status:** Experimental, actively developed

---

## References to Update

### In SpecSwarm Commands

**Files with deprecated plugin references:**
1. `plugins/specswarm/commands/bugfix.md`
   - Line references to `/speclab:*` (singular)
   - Line references to `/debug-coordinate:coordinate`
   - Line references to `/project-orchestrator:debug`
   - Path references: `~/.claude/plugins/.../speclab/lib/`

2. `plugins/specswarm/commands/implement.md`
   - Path references: `~/.claude/plugins/.../speclab/lib/`

3. `plugins/specswarm/commands/analyze-quality.md`
   - Path references: `~/.claude/plugins/.../speclab/lib/`
   - Command references to `/speclab:*`

4. `plugins/specswarm/commands/suggest.md`
   - Command references to `/speclab:*`
   - Command references to `/spectest:*`

5. `plugins/specswarm/commands/deprecate.md`
   - Reference to spectest plugin check

### Replacement Strategy

**Old References → New References:**
- `/speclab:*` → `/speclabs:*` or `/specswarm:*` (depending on command)
- `/debug-coordinate:coordinate` → `/speclabs:coordinate`
- `/project-orchestrator:*` → `/speclabs:*`
- `/spectest:*` → `/specswarm:*`
- `~/.claude/plugins/.../speclab/lib/` → `~/.claude/plugins/.../speclabs/lib/`

---

## Cleanup Actions

### 1. Remove Plugin Directories
```bash
rm -rf plugins/debug-coordinate/
rm -rf plugins/project-orchestrator/
rm -rf plugins/speclab/
rm -rf plugins/speckit/
rm -rf plugins/spectest/
```

### 2. Update SpecSwarm Command References

**bugfix.md:**
- Change `/speclab:analyze-quality` → `/specswarm:analyze-quality`
- Change `/debug-coordinate:coordinate` → `/speclabs:coordinate`
- Change `/project-orchestrator:debug` → `/speclabs:coordinate`
- Change `speclab/lib/` → `speclabs/lib/`
- Remove spectest plugin detection

**implement.md:**
- Change `speclab/lib/` → `speclabs/lib/`

**analyze-quality.md:**
- Change `speclab/lib/` → `speclabs/lib/`
- Change `/speclab:analyze-quality` → (remove self-reference)

**suggest.md:**
- Change `/speclab:*` → `/speclabs:*` or `/specswarm:*`
- Remove `/spectest:*` references

**deprecate.md:**
- Remove spectest detection

### 3. Verify No Breaking Changes

Check that all lib files exist in speclabs:
- `bundle-size-monitor.sh`
- `performance-budget-enforcer.sh`
- `chain-bug-detector.sh`

---

## Migration Guide for Users

**If you were using deprecated plugins:**

### debug-coordinate Users
```bash
# Old
/debug-coordinate:coordinate

# New
/speclabs:coordinate
```

### project-orchestrator Users
```bash
# Old
/project-orchestrator:orchestrate-test
/project-orchestrator:orchestrate-validate

# New
/speclabs:orchestrate-test
/speclabs:orchestrate-validate
```

### speclab Users
```bash
# Old
/speclab:analyze-quality

# New
/specswarm:analyze-quality
```

### speckit Users
```bash
# Old
/speckit:specify
/speckit:plan

# New
/specswarm:specify
/specswarm:plan
```

### spectest Users
```bash
# Old
/spectest:implement

# New
/specswarm:implement
```

---

## Verification Steps

After cleanup:

1. ✅ Check no broken imports in active plugins
2. ✅ Verify all lib files exist in speclabs
3. ✅ Test key workflows still work
4. ✅ Update .claude-plugin/marketplace.json if needed

---

## Timeline

- **2025-10-16**: Remove deprecated plugins
- **Active plugins:** SpecSwarm v2.0.0, SpecLabs v2.0.0

---

**Reason for Cleanup:**
Simplify plugin landscape, remove confusion, ensure all references point to active plugins.

**Impact:** None (deprecated plugins not in active use, merged into SpecSwarm/SpecLabs)
