---
description: '⚠️ DEPRECATED - Use /specswarm:orchestrate-feature instead. This alias will be removed in v3.2.0'
args:
  - name: feature_description
    description: Natural language description of the feature to build
    required: true
  - name: project_path
    description: Path to the target project (defaults to current working directory)
    required: false
  - name: --skip-specify
    description: Skip the specify phase (spec.md already exists)
    required: false
  - name: --skip-clarify
    description: Skip the clarify phase
    required: false
  - name: --skip-plan
    description: Skip the plan phase (plan.md already exists)
    required: false
  - name: --max-retries
    description: Maximum retries per task (default 3)
    required: false
  - name: --audit
    description: Run comprehensive code audit phase after implementation
    required: false
  - name: --validate
    description: Run AI-powered interaction flow validation with Playwright
    required: false
---

## ⚠️ DEPRECATION NOTICE

**This command has been moved to SpecSwarm v3.0.0+**

```
Old command: /speclabs:orchestrate-feature
New command: /specswarm:orchestrate-feature
```

**Why?** SpecLabs has been consolidated into SpecSwarm for a unified developer experience. All orchestration capabilities are now part of the main SpecSwarm plugin.

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
echo "Old: /speclabs:orchestrate-feature"
echo "New: /specswarm:orchestrate-feature"
echo ""
echo "This alias will be removed in v3.2.0."
echo "Please update your workflows to use /specswarm:orchestrate-feature"
echo ""
echo "Redirecting to SpecSwarm command..."
echo ""
```

**Use the SlashCommand tool to execute:**

```
/specswarm:orchestrate-feature $ARGUMENTS
```

Pass through all arguments exactly as provided to this command.
