# ⚠️ DEPRECATED: SpecKit Plugin

**Status**: Deprecated as of 2025-10-15
**Replacement**: Use **SpecSwarm** instead

---

## Why Deprecated?

SpecKit was the original baseline plugin, adapted from GitHub's spec-kit. It has been superseded by **SpecSwarm**, which includes all SpecKit functionality plus:

✅ Tech stack management and drift prevention
✅ Quality validation with multi-framework support
✅ SSR pattern validation
✅ Lifecycle workflows (bugfix, refactor, hotfix)
✅ Chain bug detection
✅ Bundle size monitoring
✅ Performance budget enforcement
✅ Project-aware git staging

---

## Migration Path

**All SpecKit commands are available in SpecSwarm with the same names:**

| SpecKit Command | SpecSwarm Equivalent | Notes |
|----------------|---------------------|-------|
| `/speckit:specify` | `/specswarm:specify` | Identical |
| `/speckit:plan` | `/specswarm:plan` | Enhanced with tech stack validation |
| `/speckit:tasks` | `/specswarm:tasks` | Identical |
| `/speckit:implement` | `/specswarm:implement` | Enhanced with quality validation |
| `/speckit:clarify` | `/specswarm:clarify` | Identical |
| `/speckit:checklist` | `/specswarm:checklist` | Identical |
| `/speckit:analyze` | `/specswarm:analyze` | Identical |
| `/speckit:constitution` | `/specswarm:constitution` | Identical |

**To migrate**: Simply replace `/speckit:` with `/specswarm:` in your workflows.

---

## What's Different in SpecSwarm?

**New Features Not in SpecKit**:
1. Tech stack compliance validation
2. Quality scoring (0-100 points)
3. Multi-framework test detection (Vitest, Jest, Mocha, Pytest, etc.)
4. SSR architecture validation
5. Lifecycle workflows (bugfix, modify, refactor, hotfix, deprecate)
6. Comprehensive quality analysis
7. Performance monitoring

**Backwards Compatible**: SpecSwarm maintains 100% compatibility with SpecKit workflows.

---

## Timeline

- **2025-10-15**: SpecKit marked as deprecated
- **SpecKit will not receive updates** - All improvements go to SpecSwarm
- **No removal planned** - SpecKit remains available for legacy projects

---

## Questions?

See SpecSwarm documentation for the complete feature set and migration guide.
