# ⚠️ DEPRECATED: project-orchestrator Plugin

**Status**: Deprecated as of 2025-10-15
**Merged Into**: **SpecLabs v1.0.0**

---

## Why Deprecated?

project-orchestrator has been consolidated with debug-coordinate into **SpecLabs**, creating a unified experimental plugin for autonomous development and advanced debugging.

**New Vision**: One experimental plugin for cutting-edge features while keeping SpecSwarm stable and production-ready.

---

## Migration Path

**All project-orchestrator commands are now available in SpecLabs:**

| project-orchestrator Command | SpecLabs Equivalent | Notes |
|----------------------------|-------------------|-------|
| `/project-orchestrator:orchestrate-test` | `/speclabs:orchestrate-test` | Identical - automated test workflow |
| `/project-orchestrator:orchestrate-validate` | `/speclabs:orchestrate-validate` | Identical - validation suite |

**To migrate**: Replace `/project-orchestrator:` with `/speclabs:` in your workflows.

---

## What's in SpecLabs?

**Complete Experimental Toolkit**:

**Autonomous Development** (from project-orchestrator):
- `/speclabs:orchestrate-test` - Automated test workflow with multi-agent coordination
- `/speclabs:orchestrate-validate` - Full validation suite (browser, terminal, visual)

**Advanced Debugging** (from debug-coordinate):
- `/speclabs:coordinate` - Systematic multi-bug debugging with root cause analysis

**All sharing**: Experimental infrastructure for autonomous workflows

---

## Why Consolidate?

✅ **Clear separation** - SpecSwarm (stable) vs. SpecLabs (experimental)
✅ **Natural pairing** - Will use debugging while building orchestrator
✅ **Phase 0 safety** - Experimental bugs isolated from SpecSwarm
✅ **Simpler landscape** - 2 plugins instead of 4
✅ **Development synergy** - Orchestration and debugging work together

---

## Development Status

project-orchestrator was **Phase 0** - very early, high bug risk. By consolidating into SpecLabs:

- Clear experimental status (separate plugin = clear signal)
- Safe iteration without affecting SpecSwarm stability
- Easy to invoke from SpecSwarm when needed
- Can graduate to SpecSwarm once proven stable

---

## Timeline

- **2025-10-15**: project-orchestrator merged into SpecLabs v1.0.0
- **project-orchestrator will not receive updates** - Use SpecLabs instead
- **No removal planned** - project-orchestrator remains available for legacy projects

---

## Questions?

See SpecLabs v1.0 documentation for the complete experimental toolkit.
