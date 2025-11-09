---
description: '⚠️ DEPRECATED - Use /specswarm:metrics-export instead. This alias will be removed in v3.2.0'
---

## ⚠️ DEPRECATION NOTICE

**This command has been moved to SpecSwarm v3.0.0+**

```
Old command: /speclabs:metrics
New command: /specswarm:metrics-export
```

**Note**: This command has been renamed to `metrics-export` to avoid confusion with the feature-level metrics command (now `/specswarm:metrics`).

**Why?** SpecLabs has been consolidated into SpecSwarm for a unified developer experience. All metrics capabilities are now part of the main SpecSwarm plugin.

**Migration Timeline**:
- **v3.0.0** (Current): Aliases work, deprecation warnings shown
- **v3.1.0**: Aliases continue to work with warnings
- **v3.2.0**: Aliases removed - use SpecSwarm commands only

---

## Automatic Redirect

**YOU MUST NOW redirect to the SpecSwarm command:**

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  DEPRECATED COMMAND"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This command has been moved to SpecSwarm v3.0.0+"
echo ""
echo "Old: /speclabs:metrics"
echo "New: /specswarm:metrics-export"
echo ""
echo "This alias will be removed in v3.2.0."
echo "Please update your workflows to use /specswarm:metrics-export"
echo ""
echo "Redirecting to SpecSwarm command..."
echo ""
```

**Use the SlashCommand tool to execute:**

```
/specswarm:metrics-export $ARGUMENTS
```

Pass through all arguments exactly as provided to this command.
