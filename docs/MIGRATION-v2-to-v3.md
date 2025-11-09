# Migration Guide: SpecSwarm v2.x → v3.0

**TL;DR**: SpecSwarm v3.0 consolidates SpecLabs into SpecSwarm for a unified experience. All your existing commands still work, but we recommend migrating to the new simplified workflow.

---

## What Changed?

### Single Plugin Install

**Before (v2.x)**:
```bash
/plugin install specswarm
/plugin install speclabs  # Experimental features
```

**After (v3.0)**:
```bash
/plugin install specswarm  # Everything included!
```

SpecLabs functionality is now part of SpecSwarm.

### Simplified High-Level Commands

**Before**: 7+ commands for a complete feature
```bash
/specswarm:specify "feature"
/specswarm:clarify
/specswarm:plan
/specswarm:tasks
/specswarm:implement
/specswarm:analyze-quality
/specswarm:complete
```

**After**: 2 commands for the same feature
```bash
/specswarm:build "feature description" --validate
/specswarm:ship
```

**Result**: 70% fewer commands, 85-90% less manual orchestration

### New Capabilities

v3.0 adds powerful new commands:

1. **`/specswarm:upgrade`** - Framework/dependency migrations
   ```bash
   /specswarm:upgrade "React 18 to React 19"
   ```

2. **`/specswarm:fix`** - Bug fixing with automatic retry
   ```bash
   /specswarm:fix "bug description" --regression-test
   ```

3. **`/specswarm:build`** - Complete feature development
   ```bash
   /specswarm:build "feature description" --validate --quality-gate 85
   ```

4. **`/specswarm:ship`** - Quality-gated merge
   ```bash
   /specswarm:ship  # Enforces quality thresholds
   ```

---

## Command Migration Map

### SpecLabs → SpecSwarm

All SpecLabs commands have been moved to SpecSwarm:

| SpecLabs Command (Old) | SpecSwarm Command (New) | Status |
|------------------------|-------------------------|--------|
| `/speclabs:orchestrate-feature` | `/specswarm:orchestrate-feature` or `/specswarm:build` | ✅ Backward compatible |
| `/speclabs:validate-feature` | `/specswarm:validate` | ✅ Backward compatible |
| `/speclabs:feature-metrics` | `/specswarm:metrics` | ✅ Backward compatible |
| `/speclabs:metrics` | `/specswarm:metrics-export` | ✅ Backward compatible |
| `/speclabs:coordinate` | `/specswarm:coordinate` | ✅ Backward compatible |
| `/speclabs:orchestrate` | `/specswarm:orchestrate` | ✅ Backward compatible |
| `/speclabs:orchestrate-validate` | `/specswarm:orchestrate-validate` | ✅ Backward compatible |

**Backward Compatibility**: All `/speclabs:*` commands work as aliases in v3.0 and v3.1, with deprecation warnings. Aliases will be removed in v3.2.0.

### SpecSwarm Commands (Unchanged)

All existing SpecSwarm v2.x commands continue to work unchanged:

- `specify`, `clarify`, `plan`, `tasks`, `implement`
- `bugfix`, `hotfix`, `modify`, `refactor`, `deprecate`
- `complete`, `impact`, `analyze-quality`
- `constitution`, `checklist`, `suggest`

---

## Migration Paths

### Path 1: Do Nothing (Easiest)

**Action Required**: None

All your existing workflows continue to work:
- SpecSwarm v2.x commands: ✅ Work unchanged
- SpecLabs commands: ✅ Work as aliases with warnings

**Recommended For**: Users who want zero disruption

**Timeline**: Migrate before v3.2.0 (when aliases are removed)

### Path 2: Adopt Simplified Workflow (Recommended)

**Action Required**: Update your scripts/workflows to use new commands

**Old Workflow**:
```bash
/specswarm:specify "Add user auth"
/specswarm:clarify
/specswarm:plan
/specswarm:tasks
/specswarm:implement
/specswarm:analyze-quality
/specswarm:complete
```

**New Workflow**:
```bash
/specswarm:build "Add user auth" --validate
/specswarm:ship
```

**Benefits**:
- 70% fewer commands
- 85-90% less manual orchestration
- Built-in quality gates
- Automatic validation (optional)

**Recommended For**: All users (significantly faster)

### Path 3: Update SpecLabs References

**Action Required**: Replace `/speclabs:*` with `/specswarm:*`

Use this find-and-replace mapping:

```bash
# In your scripts, documentation, etc.
/speclabs:orchestrate-feature  →  /specswarm:build
/speclabs:validate-feature     →  /specswarm:validate
/speclabs:feature-metrics      →  /specswarm:metrics
/speclabs:metrics              →  /specswarm:metrics-export
/speclabs:coordinate           →  /specswarm:coordinate
/speclabs:orchestrate          →  /specswarm:orchestrate
/speclabs:orchestrate-validate →  /specswarm:orchestrate-validate
```

**Recommended For**: Current SpecLabs users who want to eliminate deprecation warnings

---

## Step-by-Step Migration

### Step 1: Upgrade SpecSwarm

```bash
# Remove old plugins (if installed)
/plugin uninstall speclabs
/plugin uninstall specswarm

# Reinstall marketplace
/plugin https://github.com/MartyBonacci/specswarm

# Install unified SpecSwarm v3.0
/plugin install specswarm
```

### Step 2: Test Your Workflow

**Option A**: Test with existing commands (no changes needed)
```bash
# Your v2.x commands still work
/specswarm:specify "test feature"
/specswarm:plan
# ... etc
```

**Option B**: Test with new simplified commands
```bash
# Try the new streamlined workflow
/specswarm:build "test feature" --validate
/specswarm:ship
```

### Step 3: Update Your Scripts (Optional)

If you have automation scripts using SpecSwarm/SpecLabs:

1. **Find all command references**:
   ```bash
   grep -r "/speclabs:" .
   grep -r "/specswarm:" .
   ```

2. **Update SpecLabs references**:
   - Replace with SpecSwarm equivalents (see table above)
   - Or keep them (they work as aliases until v3.2.0)

3. **Consider simplifying workflows**:
   - Replace multi-command sequences with `/specswarm:build` + `/specswarm:ship`

### Step 4: Update Documentation

If you have team documentation:

1. Update install instructions (single plugin)
2. Update workflow examples (2-command pattern)
3. Note deprecation timeline for SpecLabs

---

## Breaking Changes

### None for v3.0.0

**Zero breaking changes!** All v2.x functionality works in v3.0.

### Future Breaking Changes (v3.2.0)

**Scheduled for v3.2.0** (2+ releases away):
- ❌ `/speclabs:*` command aliases removed
- ⚠️ SpecLabs plugin will be fully deprecated

**Action Required Before v3.2.0**:
- Migrate from `/speclabs:*` to `/specswarm:*` commands
- Update any scripts/documentation

**Migration Window**: v3.0 → v3.1 → v3.2 (2 full releases)

---

## New Features in v3.0

### 1. Framework/Dependency Upgrades

```bash
# Analyze breaking changes and upgrade automatically
/specswarm:upgrade "React 18 to React 19"

# Output:
# - Breaking change analysis from changelogs
# - Automated code refactoring with codemods
# - Test validation after upgrade
# - Manual migration task guidance
```

**Use Cases**:
- Major framework upgrades (React, Vue, Angular)
- Dependency updates with breaking changes
- Security vulnerability fixes

### 2. Test-Driven Bug Fixing

```bash
# Create failing test first, then fix
/specswarm:fix "Login fails with special chars" --regression-test

# Output:
# - Creates regression test (fails initially)
# - Implements fix
# - Verifies test now passes
# - Automatic retry if fix incomplete (up to N retries)
```

**Benefits**:
- Prevents regression (test ensures bug won't return)
- Automatic retry logic (fixes complex bugs)
- TDD approach built-in

### 3. Quality-Gated Merge

```bash
# Enforce quality thresholds before merge
/specswarm:ship

# Output:
# - Runs quality analysis
# - Checks against threshold (default 80%)
# - Blocks merge if quality too low
# - Clear remediation steps if failing
```

**Configuration** (`/memory/quality-standards.md`):
```yaml
quality_threshold: 85
enforce_gates: true
```

**Benefits**:
- Prevents low-quality code from merging
- Configurable thresholds per project
- Clear quality feedback

### 4. Complete Feature Development

```bash
# One command for entire feature lifecycle
/specswarm:build "Add user dashboard with charts" --validate --quality-gate 85

# Output:
# - Specification generation
# - Interactive clarification (only pause point)
# - Autonomous planning
# - Task generation
# - Implementation
# - Browser validation (optional)
# - Quality analysis
# - Ready to ship
```

**Benefits**:
- 85-90% reduction in manual steps
- Single interactive pause (clarification)
- Built-in validation and quality checks

---

## FAQ

### Do I need to uninstall SpecLabs?

**Optional**. SpecLabs now only provides backward compatibility aliases. You can:
- Keep it installed (no harm, just deprecated warnings)
- Uninstall it once you've migrated (cleaner)

### Will my existing features break?

**No**. All existing feature directories, specifications, and artifacts remain fully compatible. The changes are only to command names and workflow orchestration.

### Can I use both old and new workflows?

**Yes**. You can mix v2.x commands with v3.0 commands freely. For example:
```bash
/specswarm:specify "feature"  # Old
/specswarm:clarify            # Old
/specswarm:build "feature"    # Can't use - already specified
# OR
/specswarm:plan               # Old
/specswarm:implement          # Old
/specswarm:ship               # New!
```

### When should I migrate?

**Recommendation**:
- **Immediately**: If you want faster workflows (use new simplified commands)
- **By v3.1.0**: Update any SpecLabs references to eliminate warnings
- **By v3.2.0**: Must migrate - aliases removed

### What if I find a bug in v3.0?

Report issues at: https://github.com/MartyBonacci/specswarm/issues

Include:
- SpecSwarm version (`/plugin list`)
- Command used
- Expected vs actual behavior
- Error messages

---

## Support

**Documentation**:
- Full workflow guide: [WORKFLOW.md](WORKFLOW.md)
- Command reference: [CHEATSHEET.md](CHEATSHEET.md)
- Changelog: [CHANGELOG.md](../CHANGELOG.md)

**Community**:
- GitHub Issues: https://github.com/MartyBonacci/specswarm/issues
- Discussions: https://github.com/MartyBonacci/specswarm/discussions

---

## Summary

✅ **All v2.x commands work unchanged**
✅ **SpecLabs commands work as aliases (with warnings)**
✅ **New simplified workflow available (build + ship)**
✅ **Zero breaking changes in v3.0**
✅ **2-version grace period before alias removal**

**Recommended Action**: Start using `/specswarm:build` and `/specswarm:ship` for 70% faster workflows.

**Required Action**: Migrate SpecLabs references before v3.2.0.
