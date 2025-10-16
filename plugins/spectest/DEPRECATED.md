# ⚠️ DEPRECATED: SpecTest Plugin

**Status**: Deprecated as of 2025-10-15
**Replacement**: Use **SpecSwarm** instead

---

## Why Deprecated?

SpecTest was an experimental testing ground for new features before stabilizing them into SpecSwarm. All successful experiments have been merged into **SpecSwarm v2.0.0**.

---

## What Was Experimental in SpecTest?

SpecTest included:
- ✅ Parallel task execution (not yet stabilized)
- ✅ Lifecycle hooks (not yet stabilized)
- ✅ `/spectest:metrics` workflow timing dashboard (not critical)
- ✅ Performance metrics tracking (not essential)

**Decision**: These features were interesting but not essential for the core workflow. Quality validation (tests, coverage, bundle size) is more important than workflow timing.

---

## Migration Path

**All essential SpecTest features are now in SpecSwarm:**

| SpecTest Feature | SpecSwarm v2.0 Status | Notes |
|-----------------|---------------------|-------|
| Core workflows | ✅ Included | specify, plan, tasks, implement |
| Quality validation | ✅ Enhanced | Multi-framework, proportional scoring |
| Tech stack validation | ✅ Included | Drift prevention |
| SSR validation | ✅ Included | Production failure prevention |
| Lifecycle workflows | ✅ Included | bugfix, refactor, hotfix, etc. |
| Bundle monitoring | ✅ Included | Phase 3 feature |
| Workflow timing metrics | ❌ Not included | Nice-to-have, not critical |
| Parallel execution | ❌ Not included | Experimental, not yet stable |

**To migrate**: Use `/specswarm:` commands instead of `/spectest:` commands.

---

## What About /spectest:metrics?

The workflow timing dashboard (`/spectest:metrics`) is **not included** in SpecSwarm v2.0.

**Why?** We prioritized quality metrics over workflow timing:
- ✅ **Quality metrics** (test coverage, bundle size, quality score) → **Essential**
- ❌ **Workflow timing** (parallel speedup, phase duration) → **Nice-to-have**

If you need workflow timing, SpecTest remains available but will not receive updates.

---

## What About Parallel Execution?

Parallel task execution is experimental and not yet stable enough for production. It may be added to SpecSwarm in a future release once proven reliable.

**Current recommendation**: Sequential execution with quality validation is more reliable.

---

## Timeline

- **2025-10-15**: SpecTest marked as deprecated
- **SpecTest will not receive updates** - All improvements go to SpecSwarm
- **No removal planned** - SpecTest remains available for experiments

---

## Questions?

See SpecSwarm v2.0 documentation for the complete unified toolkit.
