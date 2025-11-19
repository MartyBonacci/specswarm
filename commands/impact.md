---
description: Standalone impact analysis for any feature or change
---

## User Input

```text
$ARGUMENTS
```

## Goal

Perform standalone impact analysis for any feature or change to identify affected components, dependencies, and risks.

**Use Cases**:
- Pre-planning impact assessment
- Architecture review
- Risk analysis before major changes
- Dependency mapping
- Used by `/speclab:modify` workflow

---

## Execution Steps

### 1. Parse Target

```bash
TARGET=$ARGUMENTS

if [ -z "$TARGET" ]; then
  echo "🔍 Impact Analysis"
  echo ""
  echo "What feature/component do you want to analyze?"
  echo "Examples:"
  echo "  - Feature number: 018"
  echo "  - File/module: app/models/user.ts"
  echo "  - API endpoint: /api/v1/users"
  read -p "Target: " TARGET
fi

echo "🔍 Analyzing Impact for: ${TARGET}"
```

---

### 2. Analyze Dependencies

```bash
# Search codebase for references
echo "Scanning codebase..."

# Find direct references
# - Import statements
# - Function calls
# - Type usage
# - API endpoint calls

# Find indirect references
# - Components using direct dependencies
# - Services consuming APIs

# Generate dependency graph
echo "Building dependency graph..."
```

---

### 3. Generate Impact Report

```markdown
# Impact Analysis: ${TARGET}

**Analysis Date**: YYYY-MM-DD
**Scope**: [Feature/Module/API/Component]

---

## Target Summary

**Type**: [Feature/API/Module/Component]
**Location**: [path]
**Current Purpose**: [description]

---

## Direct Dependencies

Components that directly depend on this target:

| Component | Type | Usage Pattern | Impact Level |
|-----------|------|---------------|--------------|
| [Component 1] | [Service/UI/API] | [How it's used] | [High/Med/Low] |
| [Component 2] | [Service/UI/API] | [How it's used] | [High/Med/Low] |

**Total Direct Dependencies**: [N]

---

## Indirect Dependencies

Components that depend on direct dependencies:

| Component | Via | Impact Level |
|-----------|-----|--------------|
| [Component 1] | [Direct Dep] | [High/Med/Low] |

**Total Indirect Dependencies**: [N]

---

## Dependency Graph

```
[Target]
├── Direct Dep 1
│   ├── Indirect Dep 1a
│   └── Indirect Dep 1b
├── Direct Dep 2
│   └── Indirect Dep 2a
└── Direct Dep 3
```

---

## Risk Assessment

### Change Impact Level: [Low/Medium/High/Critical]

**Risk Factors**:
| Factor | Level | Rationale |
|--------|-------|-----------|
| Number of Dependencies | [High/Med/Low] | [N direct, M indirect] |
| Criticality | [High/Med/Low] | [Critical systems affected?] |
| Test Coverage | [High/Med/Low] | [Coverage %] |
| Change Complexity | [High/Med/Low] | [Simple/Complex] |

**Overall Risk Score**: [N/10]

---

## Recommendations

### If Modifying This Target:

1. **Review all [N] dependencies** before making changes
2. **Test strategy**: [recommendation]
3. **Communication**: [notify teams owning dependent systems]
4. **Rollout**: [Big bang / Phased / Feature flag]

### Consideration for Breaking Changes:

- **Compatibility layer**: [Yes - recommended / Not needed]
- **Migration plan**: [Required / Not required]
- **Deprecation timeline**: [timeframe]

---

## Next Steps

Based on this analysis:

- **For modifications**: Use `/speclab:modify ${TARGET}`
- **For bugfixes**: Use `/speclab:bugfix` if issues found
- **For refactoring**: Use `/speclab:refactor ${TARGET}` if quality issues
- **For deprecation**: Use `/speclab:deprecate ${TARGET}` if sunset planned
```

---

### 4. Output Report

```
🔍 Impact Analysis Complete

📊 Analysis Results:
- Target: ${TARGET}
- Direct dependencies: [N]
- Indirect dependencies: [M]
- Risk level: [Low/Medium/High/Critical]

📋 Full report available (above)

📈 Recommended Next Steps:
- [Recommendation based on findings]
```

---

## Success Criteria

✅ Target identified and analyzed
✅ All direct dependencies mapped
✅ Indirect dependencies identified
✅ Risk level assessed
✅ Recommendations provided
