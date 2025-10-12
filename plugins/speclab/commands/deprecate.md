---
description: Phased feature sunset workflow with migration guidance
---

<!--
ATTRIBUTION CHAIN:
1. Original methodology: spec-kit-extensions by Marty Bonacci (2025)
2. Adapted: SpecLab plugin by Marty Bonacci & Claude Code (2025)
3. Based on: GitHub spec-kit | MIT License
-->

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Execute phased deprecation workflow to safely sunset features while providing migration guidance to users.

**Key Principles**:
1. **Phased Approach**: Announce → Migrate → Remove
2. **Migration Guidance**: Provide clear alternatives
3. **User Support**: Help users migrate
4. **Track Adoption**: Monitor migration progress
5. **Safe Removal**: Only remove when migration complete

**Phases**: Announce deprecation, user migration support, feature removal

**Coverage**: Addresses ~5% of development work (feature evolution)

---

## Smart Integration

```bash
SPECSWARM_INSTALLED=$(claude plugin list | grep -q "specswarm" && echo "true" || echo "false")
SPECTEST_INSTALLED=$(claude plugin list | grep -q "spectest" && echo "true" || echo "false")

if [ "$SPECTEST_INSTALLED" = "true" ]; then
  ENABLE_HOOKS=true
  ENABLE_METRICS=true
fi
```

---

## Execution Steps

### 1. Discover Deprecation Context

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
DEPRECATE_NUM=$(echo "$CURRENT_BRANCH" | grep -oE 'deprecate/([0-9]{3})' | grep -oE '[0-9]{3}')

if [ -z "$DEPRECATE_NUM" ]; then
  echo "📉 Deprecate Workflow"
  echo "Provide deprecation number:"
  read -p "Deprecation number: " DEPRECATE_NUM
  DEPRECATE_NUM=$(printf "%03d" $DEPRECATE_NUM)
fi

FEATURE_DIR="${REPO_ROOT}/features/${DEPRECATE_NUM}-deprecate"
mkdir -p "$FEATURE_DIR"

DEPRECATE_SPEC="${FEATURE_DIR}/deprecate.md"
MIGRATION_GUIDE="${FEATURE_DIR}/migration-guide.md"
TASKS_FILE="${FEATURE_DIR}/tasks.md"
```

---

### 2. Identify Feature to Deprecate

```
📉 Feature Deprecation

Which feature are you deprecating?
[User input or scan codebase]

Feature to deprecate: [name]
Reason for deprecation: [reason]
Alternative/replacement: [what users should use instead]
```

---

### 3. Create Deprecation Specification

```markdown
# Deprecation ${DEPRECATE_NUM}: [Feature Name]

**Status**: Active
**Created**: YYYY-MM-DD
**Feature**: [Feature to deprecate]
**Replacement**: [Alternative feature/approach]

---

## Deprecation Rationale

**Why Deprecating**:
- Reason 1
- Reason 2
- Reason 3

**Timeline Decision**: [Why now?]

---

## Current Usage Analysis

**Users Affected**: [Estimated N users/systems]
**Usage Patterns**: [How is it currently used?]

**Dependencies**:
| Dependent System | Usage Level | Migration Complexity |
|------------------|-------------|----------------------|
| [System 1] | [High/Med/Low] | [High/Med/Low] |

---

## Replacement Strategy

**Recommended Alternative**: [Feature/approach]

**Why Better**:
- Benefit 1
- Benefit 2

**Migration Effort**: [Low/Medium/High]
**Migration Time Estimate**: [timeframe per user]

---

## Deprecation Timeline

### Phase 1: Announcement (Month 1)
**Duration**: [timeframe]
**Activities**:
- [ ] Announce deprecation publicly
- [ ] Add deprecation warnings to feature
- [ ] Publish migration guide
- [ ] Email affected users
- [ ] Update documentation

**Deliverables**:
- Deprecation announcement
- Migration guide
- Updated docs

---

### Phase 2: Migration Support (Months 2-3)
**Duration**: [timeframe]
**Activities**:
- [ ] Monitor adoption of alternative
- [ ] Provide migration support to users
- [ ] Track usage of deprecated feature
- [ ] Address migration blockers
- [ ] Send migration reminders

**Success Criteria**:
- ≥80% of users migrated to alternative
- No critical dependencies remaining

---

### Phase 3: Removal (Month 4+)
**Duration**: [timeframe]
**Activities**:
- [ ] Final migration reminder (2 weeks notice)
- [ ] Disable feature in production
- [ ] Remove code
- [ ] Cleanup tests and documentation
- [ ] Archive feature artifacts

**Prerequisites**:
- ≥90% user migration
- All critical dependencies resolved
- Stakeholder approval

---

## Migration Blockers

**Known Blockers**:
| Blocker | Impact | Resolution Plan |
|---------|--------|-----------------|
| [Blocker 1] | [High/Med/Low] | [How to resolve] |

---

## Communication Plan

**Channels**:
- [ ] Blog post / changelog
- [ ] Email to affected users
- [ ] In-app deprecation warning
- [ ] Documentation update
- [ ] Support ticket template

**Messaging**:
- Clear deprecation timeline
- Migration guide link
- Support resources
- Benefits of alternative

---

## Rollback Plan

**If Migration Fails**:
- Extend timeline
- Provide additional support resources
- Reconsider deprecation if alternative insufficient

---

## Success Metrics

| Metric | Target | Current |
|--------|--------|---------|
| User Migration Rate | ≥90% | [%] |
| Alternative Adoption | ≥80% | [%] |
| Support Tickets | <10 | [N] |
| Migration Blockers | 0 | [N] |

---

## Metadata

**Workflow**: Deprecate (Phased Sunset)
**Created By**: SpecLab Plugin v1.0.0
```

Write to `$DEPRECATE_SPEC`.

---

### 4. Create Migration Guide

```markdown
# Migration Guide: Deprecation ${DEPRECATE_NUM}

**Feature Deprecated**: [Feature name]
**Recommended Alternative**: [Alternative]
**Migration Deadline**: [Date]

---

## Why This Change?

[Brief explanation of deprecation rationale]

**Benefits of Migration**:
- Benefit 1
- Benefit 2

---

## Migration Steps

### Step 1: [Action]
**What**: [Description]

**Before** (deprecated):
```
[Code example using old feature]
```

**After** (recommended):
```
[Code example using alternative]
```

### Step 2: [Action]
[Repeat pattern for each migration step]

---

## Migration Checklist

- [ ] Update code to use alternative
- [ ] Update tests
- [ ] Update documentation
- [ ] Test in development
- [ ] Deploy to production
- [ ] Verify functionality
- [ ] Remove deprecated feature usage

---

## Common Migration Scenarios

### Scenario 1: [Use Case]
**Old Approach**:
```
[Code]
```

**New Approach**:
```
[Code]
```

[Repeat for common scenarios]

---

## Troubleshooting

### Issue 1: [Common Problem]
**Symptom**: [What users see]
**Solution**: [How to fix]

[Repeat for common issues]

---

## Support Resources

- Migration guide: [link]
- API documentation: [link]
- Support channel: [link]
- Example migration: [link to example code]

**Need Help?**
- Email: [support email]
- Slack: [support channel]
- Office hours: [time]

---

## Timeline

- **Now**: Feature deprecated, warnings active
- **[Date]**: Migration support ends
- **[Date]**: Feature removed from production

**Don't wait! Migrate today.**
```

Write to `$MIGRATION_GUIDE`.

---

### 5. Generate Tasks

```markdown
# Tasks: Deprecation ${DEPRECATE_NUM}

**Workflow**: Deprecate (Phased Sunset)

---

## Phase 1: Announcement Tasks

### T001: Add Deprecation Warnings
**Description**: Add warnings to deprecated feature code
**Files**: [list]
**Warning Message**: "This feature is deprecated. Migrate to [alternative]. See [migration guide link]."

### T002: [P] Publish Migration Guide
**Description**: Publish migration guide
**Output**: ${MIGRATION_GUIDE}
**Parallel**: [P]

### T003: [P] Update Documentation
**Description**: Mark feature as deprecated in docs
**Files**: [doc files]
**Parallel**: [P]

### T004: [P] Announce Deprecation
**Description**: Communicate deprecation via all channels
**Channels**: Blog, email, in-app
**Parallel**: [P]

---

## Phase 2: Migration Support Tasks

### T005: Monitor Adoption
**Description**: Track usage of deprecated vs alternative
**Metrics**: [usage metrics]
**Frequency**: Weekly
**Duration**: [Phase 2 duration]

### T006: Provide User Support
**Description**: Help users migrate
**Activities**: Answer questions, resolve blockers
**Duration**: [Phase 2 duration]

### T007: Send Migration Reminders
**Description**: Remind users to migrate
**Schedule**: [reminder schedule]
**Content**: Progress update, deadline reminder

---

## Phase 3: Removal Tasks

### T008: Final Migration Check
**Description**: Verify ≥90% user migration
**Validation**: Usage metrics, stakeholder approval

### T009: Disable Feature
**Description**: Turn off deprecated feature in production
**Rollback Plan**: [how to re-enable if needed]

### T010: Remove Code
**Description**: Delete deprecated feature code
**Files**: [list all files to remove]
**Validation**: Tests still pass

### T011: [P] Cleanup Tests
**Description**: Remove tests for deprecated feature
**Files**: [test files]
**Parallel**: [P]

### T012: [P] Cleanup Documentation
**Description**: Remove deprecated feature from docs
**Files**: [doc files]
**Parallel**: [P]

### T013: Archive Artifacts
**Description**: Archive feature artifacts for historical reference
**Location**: [archive location]

---

## Summary

**Total Tasks**: 13
**Phase 1 (Announce)**: T001-T004 (4 tasks, [N] parallel)
**Phase 2 (Migrate)**: T005-T007 (3 tasks, ongoing)
**Phase 3 (Remove)**: T008-T013 (6 tasks, [N] parallel)

**Total Timeline**: [estimated timeline]

**Success Criteria**:
- ✅ Deprecation announced to all users
- ✅ Migration guide published
- ✅ ≥90% users migrated
- ✅ Feature removed safely
- ✅ Documentation updated
```

Write to `$TASKS_FILE`.

---

### 6. Execute Phased Deprecation

Execute across three phases:

```
📉 Executing Deprecation Workflow

Phase 1: Announcement (Month 1)
T001: Add Deprecation Warnings
  ✓ Warnings added to code

T002-T004: [Parallel] Publish Migration Guide, Update Docs, Announce
  ⚡ Executing 3 tasks in parallel...
  ✓ Migration guide published
  ✓ Documentation updated
  ✓ Deprecation announced

Phase 2: Migration Support (Months 2-3)
T005: Monitor Adoption
  Week 1: 15% migrated
  Week 2: 32% migrated
  Week 4: 58% migrated
  Week 6: 78% migrated
  Week 8: 91% migrated ✅

T006: Provide User Support
  ✓ 12 support tickets resolved
  ✓ 3 migration blockers fixed

T007: Send Migration Reminders
  ✓ Weekly reminders sent

Phase 3: Removal (Month 4)
T008: Final Migration Check
  ✓ 91% users migrated
  ✓ Stakeholder approval received

T009: Disable Feature
  ✓ Feature disabled in production
  ✓ No issues reported

T010-T012: [Parallel] Remove Code, Cleanup Tests, Cleanup Docs
  ⚡ Executing 3 tasks in parallel...
  ✓ All cleanup tasks complete

T013: Archive Artifacts
  ✓ Artifacts archived
```

---

## Final Output

```
✅ Deprecation Workflow Complete - Deprecation ${DEPRECATE_NUM}

📊 Deprecation Results:
- Users migrated: 91% ✅
- Alternative adopted: 87% ✅
- Support tickets: 12 (all resolved) ✅
- Timeline: Completed on schedule ✅

📋 Artifacts:
- ${DEPRECATE_SPEC}
- ${MIGRATION_GUIDE}
- ${TASKS_FILE}

⏱️  Total Timeline: [duration]

✅ Feature Safely Removed:
- Code deleted and archived
- Documentation updated
- Users successfully migrated

📈 Next Steps:
- Monitor alternative feature adoption
- Archive learnings for future deprecations
```

---

## Operating Principles

1. **Phased Approach**: Announce → Migrate → Remove
2. **User-Centric**: Help users migrate successfully
3. **Communication**: Over-communicate timeline and alternatives
4. **Track Progress**: Monitor migration adoption
5. **Safe Removal**: Only remove when migration complete

---

## Success Criteria

✅ Deprecation announced to all affected users
✅ Migration guide published and accessible
✅ ≥90% user migration achieved
✅ Migration blockers resolved
✅ Feature removed safely
✅ Documentation and code cleanup complete
✅ Artifacts archived

---

**Workflow Coverage**: Addresses ~5% of development work (feature evolution)
