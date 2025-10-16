# ⚠️ DEPRECATED: SpecLab Plugin

**Status**: Deprecated as of 2025-10-15
**Merged Into**: **SpecSwarm v2.0.0**

---

## Why Deprecated?

SpecLab was created as a specialized plugin for lifecycle workflows (bugfix, refactor, hotfix). It has been **merged into SpecSwarm** to create one unified toolkit.

**Original Vision**: One complete plugin with everything needed to build, improve, modify, and fix software projects.

**Result**: SpecSwarm v2.0.0 now includes all SpecLab functionality.

---

## Migration Path

**All SpecLab commands are now available in SpecSwarm:**

| SpecLab Command | SpecSwarm v2.0 Equivalent | Notes |
|-----------------|--------------------------|-------|
| `/speclab:bugfix` | `/specswarm:bugfix` | Identical |
| `/speclab:modify` | `/specswarm:modify` | Identical |
| `/speclab:refactor` | `/specswarm:refactor` | Identical |
| `/speclab:hotfix` | `/specswarm:hotfix` | Identical |
| `/speclab:deprecate` | `/specswarm:deprecate` | Identical |
| `/speclab:impact` | `/specswarm:impact` | Identical |
| `/speclab:suggest` | `/specswarm:suggest` | Identical |
| `/speclab:analyze-quality` | `/specswarm:analyze-quality` | Identical |
| `/speclab:workflow-metrics` | `/specswarm:workflow-metrics` | Identical |

**To migrate**: Simply replace `/speclab:` with `/specswarm:` in your workflows.

---

## What's Now in SpecSwarm?

**Complete Unified Toolkit**:

**New Feature Workflows**:
- `/specswarm:specify` → `/specswarm:plan` → `/specswarm:tasks` → `/specswarm:implement`

**Lifecycle Workflows** (from SpecLab):
- `/specswarm:bugfix` - Regression-test-first bug fixing
- `/specswarm:modify` - Feature modification with impact analysis
- `/specswarm:refactor` - Metrics-driven code quality improvement
- `/specswarm:hotfix` - Emergency production issue response
- `/specswarm:deprecate` - Phased feature sunset

**Analysis Tools** (from SpecLab):
- `/specswarm:analyze-quality` - Comprehensive codebase quality analysis
- `/specswarm:impact` - Standalone impact analysis
- `/specswarm:suggest` - AI workflow recommendation
- `/specswarm:workflow-metrics` - Cross-workflow analytics

**Quality Validation** (from SpecSwarm):
- Multi-framework test detection
- SSR pattern validation
- Bundle size monitoring
- Performance budget enforcement
- Chain bug detection

**All shared utilities** (lib/):
- chain-bug-detector.sh
- bundle-size-monitor.sh
- performance-budget-enforcer.sh
- orchestrator-detection.sh
- ssr-validator.sh
- test-framework-detector.sh
- quality-gates.sh
- visual-validation.sh

---

## Timeline

- **2025-10-15**: SpecLab merged into SpecSwarm v2.0.0
- **SpecLab will not receive updates** - Use SpecSwarm instead
- **No removal planned** - SpecLab remains available for legacy projects

---

## Benefits of Consolidation

✅ **Single plugin** - No confusion about which to use
✅ **Complete toolkit** - Build, fix, and maintain all in one place
✅ **Shared utilities** - All quality validation works across workflows
✅ **Consistent experience** - Same patterns throughout
✅ **Easier maintenance** - One codebase to improve

---

## Questions?

See SpecSwarm v2.0 documentation for the complete unified toolkit.
