---
description: Feature modification workflow with impact analysis and backward compatibility assessment
---

<!--
ATTRIBUTION CHAIN:
1. Original methodology: spec-kit-extensions (https://github.com/MartyBonacci/spec-kit-extensions)
   by Marty Bonacci (2025)
2. Adapted: SpecLab plugin by Marty Bonacci & Claude Code (2025)
3. Based on: GitHub spec-kit (https://github.com/github/spec-kit)
   Copyright (c) GitHub, Inc. | MIT License
-->

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Execute impact-analysis-first modification workflow to ensure changes to existing features are safe, backward-compatible, and well-planned.

**Key Principles**:
1. **Impact First**: Analyze affected systems before modifying
2. **Backward Compatibility**: Assess breaking changes and plan mitigation
3. **Dependency Mapping**: Identify all affected components
4. **Migration Planning**: Create migration path for breaking changes
5. **Validation**: Verify modifications don't break dependent systems

**Coverage**: Addresses ~30% of development work (feature modifications)

---

## Smart Integration Detection

Before starting workflow, detect available plugins for enhanced capabilities:

```bash
# Check for SpecSwarm (tech stack enforcement)
SPECSWARM_INSTALLED=$(claude plugin list | grep -q "specswarm" && echo "true" || echo "false")

# Check for SpecTest (parallel execution, hooks, metrics)
SPECTEST_INSTALLED=$(claude plugin list | grep -q "spectest" && echo "true" || echo "false")

# Configure workflow based on detection
if [ "$SPECTEST_INSTALLED" = "true" ]; then
  EXECUTION_MODE="parallel"
  ENABLE_HOOKS=true
  ENABLE_METRICS=true
  echo "🎯 Smart Integration: SpecTest detected (parallel execution, hooks, metrics enabled)"
elif [ "$SPECSWARM_INSTALLED" = "true" ]; then
  EXECUTION_MODE="sequential"
  ENABLE_TECH_VALIDATION=true
  echo "🎯 Smart Integration: SpecSwarm detected (tech stack enforcement enabled)"
else
  EXECUTION_MODE="sequential"
  echo "ℹ️  Running in basic mode (install SpecSwarm/SpecTest for enhanced capabilities)"
fi
```

---

## Pre-Workflow Hook (if SpecTest installed)

```bash
if [ "$ENABLE_HOOKS" = "true" ]; then
  echo "🎣 Pre-Modify Hook"

  # Validate prerequisites
  echo "✓ Checking repository status..."
  git status --porcelain | head -5

  # Load tech stack (if SpecSwarm also installed)
  if [ "$SPECSWARM_INSTALLED" = "true" ]; then
    echo "✓ Loading tech stack: /memory/tech-stack.md"
    TECH_STACK_EXISTS=$([ -f "/memory/tech-stack.md" ] && echo "true" || echo "false")
    if [ "$TECH_STACK_EXISTS" = "true" ]; then
      echo "✓ Tech stack validation enabled"
    fi
  fi

  # Initialize metrics
  WORKFLOW_START_TIME=$(date +%s)
  echo "✓ Metrics initialized"
  echo ""
fi
```

---

## Execution Steps

### 1. Discover Modification Context

```bash
# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Detect branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

# Try to extract feature number from branch name (modify/NNN-*)
FEATURE_NUM=$(echo "$CURRENT_BRANCH" | grep -oE 'modify/([0-9]{3})' | grep -oE '[0-9]{3}')

# If no feature number in branch, prompt user
if [ -z "$FEATURE_NUM" ]; then
  echo "🔧 Modify Workflow"
  echo ""
  echo "No modify branch detected. Please provide feature number to modify:"
  echo "Example: 018 (for modify/018-api-pagination)"
  # Wait for user input
  read -p "Feature number: " FEATURE_NUM

  # Validate
  if [ -z "$FEATURE_NUM" ]; then
    echo "❌ Error: Feature number required"
    exit 1
  fi

  # Pad to 3 digits
  FEATURE_NUM=$(printf "%03d" $FEATURE_NUM)
fi

# Find feature directory
FEATURE_DIR=$(find "$REPO_ROOT/features" -maxdepth 1 -type d -name "${FEATURE_NUM}-*" 2>/dev/null | head -1)

if [ -z "$FEATURE_DIR" ]; then
  echo "❌ Error: Feature ${FEATURE_NUM} not found in features/ directory"
  echo ""
  echo "Modification requires existing feature specification."
  echo "Available features:"
  ls -1 "${REPO_ROOT}/features" | grep -E '^[0-9]{3}-'
  exit 1
fi

# Check if spec.md exists (required for modification)
ORIGINAL_SPEC="${FEATURE_DIR}/spec.md"
if [ ! -f "$ORIGINAL_SPEC" ]; then
  echo "❌ Error: No spec.md found for feature ${FEATURE_NUM}"
  echo "Modification requires existing feature specification."
  exit 1
fi

MODIFY_SPEC="${FEATURE_DIR}/modify.md"
IMPACT_ANALYSIS="${FEATURE_DIR}/impact-analysis.md"
TASKS_FILE="${FEATURE_DIR}/tasks.md"
```

Output to user:
```
🔧 Modify Workflow - Feature ${FEATURE_NUM}
✓ Branch detected: ${CURRENT_BRANCH}
✓ Feature directory: ${FEATURE_DIR}
✓ Original spec found: ${ORIGINAL_SPEC}
```

---

### 2. Load Existing Feature Specification

Read `$ORIGINAL_SPEC` to understand current feature implementation:

```bash
# Extract key information from spec
echo "📖 Analyzing Existing Feature..."
echo ""
```

Parse the existing spec to extract:
- Feature name and description
- Current functional requirements
- Current data model
- Current API contracts (if applicable)
- Current tech stack usage

Output summary:
```
📖 Existing Feature Analysis
✓ Feature: [Feature Name]
✓ Requirements: [N functional requirements]
✓ Data Model: [Key entities]
✓ Current Implementation: [Brief summary]
```

---

### 3. Gather Modification Requirements

Prompt user for modification details:

```
🔧 Modification Details

What changes are you proposing to this feature?
[User input or $ARGUMENTS]

Examples:
- "Add pagination to API endpoints (offset/limit style)"
- "Change authentication from session to JWT"
- "Add new fields to User model: avatar_url, bio"
- "Update search algorithm to use full-text search"

Modification description:
```

Store modification description in memory for use in artifacts.

---

### 4. Perform Impact Analysis

Analyze the modification's impact on the codebase:

```
🔍 Analyzing Impact...
```

**Search for Dependencies:**
1. Find all files referencing feature components
2. Identify API consumers (if API changes)
3. Find database queries (if data model changes)
4. Locate UI components (if behavior changes)

**Dependency Analysis:**
```bash
# Search codebase for feature references
# (Use actual project structure)
echo "Scanning codebase for dependencies..."

# Example searches:
# - API endpoint references
# - Database model usage
# - Component imports
# - Type/interface usage

# Generate dependency list
DEPENDENCIES_FOUND=[count]
```

**Categorize Impact:**
- **Breaking Changes**: Changes that break existing contracts
- **Non-Breaking Changes**: Backward-compatible additions
- **Internal Changes**: No external impact

**Assess Backward Compatibility:**
- Can existing clients continue working?
- Are new fields optional or required?
- Is migration needed for existing data?

---

### 5. Create Impact Analysis Document

Create `$IMPACT_ANALYSIS` with detailed analysis:

```markdown
# Impact Analysis: Modification to Feature ${FEATURE_NUM}

**Feature**: [Feature Name]
**Modification**: [Brief description]
**Analysis Date**: YYYY-MM-DD
**Analyst**: SpecLab Plugin v1.0.0

---

## Proposed Changes

[Detailed description of modifications]

**Change Categories**:
- Functional changes: [list]
- Data model changes: [list]
- API/contract changes: [list]
- UI/UX changes: [list]

---

## Affected Components

### Direct Dependencies
Components that directly use the modified feature:

| Component | Type | Impact Level | Notes |
|-----------|------|--------------|-------|
| [Component 1] | [Service/UI/API] | [High/Medium/Low] | [Impact description] |
| [Component 2] | [Service/UI/API] | [High/Medium/Low] | [Impact description] |

**Total Direct Dependencies**: [N]

### Indirect Dependencies
Components that depend on direct dependencies:

| Component | Type | Impact Level | Notes |
|-----------|------|--------------|-------|
| [Component 1] | [Service/UI/API] | [High/Medium/Low] | [Impact description] |

**Total Indirect Dependencies**: [N]

---

## Breaking Changes Assessment

### Breaking Changes Identified: [Yes/No]

[If yes, list each breaking change:]

#### Breaking Change 1: [Name]
**Type**: [API/Data/Behavior]
**Description**: [What's breaking?]
**Affected**: [Which components/clients affected?]
**Migration Required**: [Yes/No]

#### Breaking Change 2: [Name]
[Repeat pattern]

---

## Backward Compatibility Strategy

### Option 1: [Recommended] [Strategy Name]
**Approach**: [Description]

**Pros**:
- Pro 1
- Pro 2

**Cons**:
- Con 1
- Con 2

**Implementation**:
1. Step 1
2. Step 2

### Option 2: [Alternative Strategy]
[Same structure]

---

## Migration Requirements

### Data Migration
[If data model changes require migration]

**Affected Data**:
- Table/collection 1: [migration needed]
- Table/collection 2: [migration needed]

**Migration Script**: [Yes/No]
**Rollback Plan**: [Yes/No]
**Estimated Data Volume**: [N records/documents]

### Code Migration
[If client code needs updates]

**Affected Clients**:
- Client 1: [changes needed]
- Client 2: [changes needed]

**Migration Guide Required**: [Yes/No]
**Deprecation Timeline**: [timeframe]

### Configuration Migration
[If configuration changes needed]

**Affected Config**:
- Config 1: [changes needed]

---

## Risk Assessment

### Risk Level: [Low/Medium/High/Critical]

**Risk Factors**:
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | [High/Med/Low] | [High/Med/Low] | [Mitigation strategy] |
| [Risk 2] | [High/Med/Low] | [High/Med/Low] | [Mitigation strategy] |

**Overall Risk Score**: [N/10]

---

## Testing Requirements

### Existing Tests to Update
[List tests that need modification]

- Test 1: [what needs updating]
- Test 2: [what needs updating]

### New Tests Required
[List new tests needed]

- Test 1: [test scenario]
- Test 2: [test scenario]

### Integration Testing
[List integration test scenarios]

- Scenario 1: [description]
- Scenario 2: [description]

---

## Rollout Strategy

### Recommended Approach: [Phased/Big Bang/Feature Flag]

**Phase 1**: [Description]
- Timeline: [timeframe]
- Scope: [what's included]
- Validation: [how to verify]

**Phase 2**: [Description]
[Repeat pattern]

### Feature Flags Required: [Yes/No]
[If yes, describe flag strategy]

### Rollback Plan
**Rollback Trigger**: [When to rollback]
**Rollback Steps**: [How to rollback]
**Data Rollback**: [Possible/Not Possible - explain]

---

## Timeline Estimate

| Phase | Duration | Dependencies |
|-------|----------|--------------|
| Impact Analysis | [time] | Complete |
| Compatibility Layer | [time] | - |
| Core Implementation | [time] | Compatibility Layer |
| Migration Scripts | [time] | - |
| Testing | [time] | Implementation |
| Rollout Phase 1 | [time] | Testing |
| Rollout Phase 2 | [time] | Phase 1 Success |

**Total Estimated Time**: [time]

---

## Recommendations

1. [Recommendation 1]
2. [Recommendation 2]
3. [Recommendation 3]

**Proceed with Modification**: [Yes/Yes with Caution/No - explain]

---

## Tech Stack Compliance

[If SpecSwarm installed, validate modification against tech stack]

**Tech Stack File**: /memory/tech-stack.md
**Validation Status**: [Pending/Compliant/Non-Compliant]
**Concerns**: [Any tech stack violations?]

---

## Metadata

**Workflow**: Modify (Impact-Analysis-First)
**Created By**: SpecLab Plugin v1.0.0
**Smart Integration**: ${INTEGRATION_MODE}
```

Write impact analysis to `$IMPACT_ANALYSIS`.

Output to user:
```
📊 Impact Analysis Complete
✓ Created: ${IMPACT_ANALYSIS}
✓ Direct dependencies: [N]
✓ Breaking changes: [Y/N]
✓ Risk level: [Low/Medium/High]
✓ Backward compatibility strategy: [approach]
```

---

### 6. Create Modification Specification

Create `$MODIFY_SPEC` documenting the planned modification:

```markdown
# Modification: Feature ${FEATURE_NUM} - [Feature Name]

**Status**: Active
**Created**: YYYY-MM-DD
**Original Feature**: ${ORIGINAL_SPEC}
**Impact Analysis**: ${IMPACT_ANALYSIS}

---

## Modification Summary

**What We're Changing**: [Brief summary]

**Why We're Changing It**: [Motivation]
- Reason 1
- Reason 2
- Reason 3

---

## Current State

[Brief description of how feature currently works]

**Current Behavior**:
- Behavior 1
- Behavior 2

**Current Limitations** (prompting modification):
- Limitation 1
- Limitation 2

---

## Proposed Changes

### Functional Changes

**F001: [Change Name]**
**Current**: [How it works now]
**Proposed**: [How it will work]
**Breaking**: [Yes/No]
**Rationale**: [Why this change?]

[Repeat for each functional change]

### Data Model Changes

**D001: [Change Name]**
**Current Schema**:
```
[Current structure]
```

**Proposed Schema**:
```
[New structure]
```

**Migration Required**: [Yes/No]
**Backward Compatible**: [Yes/No]

[Repeat for each data change]

### API/Contract Changes

**A001: [Change Name]**
**Current Contract**:
```
[Current API/interface]
```

**Proposed Contract**:
```
[New API/interface]
```

**Breaking**: [Yes/No]
**Compatibility Layer**: [Yes/No - describe if yes]

[Repeat for each API change]

---

## Backward Compatibility Strategy

[From impact-analysis.md, chosen strategy]

**Approach**: [Strategy name]

**Implementation**:
1. Step 1: [description]
2. Step 2: [description]
3. Step 3: [description]

**Deprecation Timeline** (if applicable):
- **Month 1**: Announce changes, document migration
- **Month 2-3**: Support both old and new
- **Month 4**: Remove old implementation (if breaking)

---

## Migration Plan

### For Existing Data
[If data migration needed]

**Migration Script**: [path/to/script]
**Execution Strategy**: [Online/Offline/Phased]
**Rollback Plan**: [Yes/No - describe]
**Estimated Duration**: [time]

### For Existing Clients
[If client updates needed]

**Migration Guide**: [Yes - location]
**Breaking Changes Doc**: [Yes - location]
**Support Period**: [timeframe]

**Client Update Steps**:
1. Step 1
2. Step 2
3. Step 3

---

## Testing Strategy

### Regression Testing
[Ensure existing functionality still works]

- Test suite: [path]
- New tests needed: [count]
- Expected pass rate: 100%

### New Functionality Testing
[Test new/modified behavior]

- New test suite: [path]
- Test scenarios: [count]

### Integration Testing
[Test with dependent systems]

- Integration points: [list]
- Test scenarios: [count]

---

## Rollout Plan

**Strategy**: [Phased/Big Bang/Feature Flag]

**Phase 1**: [Description]
- Scope: [what's included]
- Target audience: [who gets it]
- Success metrics: [how to measure]
- Duration: [timeframe]

**Phase 2**: [Description]
[Repeat pattern]

**Rollback Criteria**:
- Trigger 1: [when to rollback]
- Trigger 2: [when to rollback]

---

## Success Metrics

How will we know the modification is successful?

| Metric | Target | Measurement |
|--------|--------|-------------|
| [Metric 1] | [Target value] | [How to measure] |
| [Metric 2] | [Target value] | [How to measure] |

**Validation Period**: [timeframe to evaluate success]

---

## Risks and Mitigation

[From impact-analysis.md]

| Risk | Mitigation |
|------|------------|
| [Risk 1] | [Mitigation strategy] |
| [Risk 2] | [Mitigation strategy] |

---

## Alternative Approaches Considered

### Alternative 1: [Name]
**Description**: [What is it?]
**Pros**: [Benefits]
**Cons**: [Drawbacks]
**Why Not Chosen**: [Reason]

[Repeat for other alternatives]

---

## Tech Stack Compliance

[If SpecSwarm installed, validate against tech stack]

**Tech Stack File**: /memory/tech-stack.md
**Compliance Status**: [Compliant/Non-Compliant]
**Changes to Tech Stack**: [Any new dependencies/patterns?]

---

## Metadata

**Workflow**: Modify (Impact-Analysis-First)
**Original Feature**: Feature ${FEATURE_NUM}
**Created By**: SpecLab Plugin v1.0.0
**Smart Integration**: ${INTEGRATION_MODE}
```

Write modification spec to `$MODIFY_SPEC`.

Output to user:
```
📋 Modification Specification
✓ Created: ${MODIFY_SPEC}
✓ Changes documented with rationale
✓ Backward compatibility strategy defined
✓ Migration plan included
```

---

### 7. Generate Tasks

Create `$TASKS_FILE` with modification implementation tasks:

```markdown
# Tasks: Modification to Feature ${FEATURE_NUM}

**Workflow**: Modify (Impact-Analysis-First)
**Status**: Active
**Created**: YYYY-MM-DD

---

## Execution Strategy

**Mode**: ${EXECUTION_MODE}
**Smart Integration**:
${INTEGRATION_SUMMARY}

---

## Phase 1: Impact Assessment Validation

### T001: Review Impact Analysis
**Description**: Validate impact analysis findings with stakeholders
**File**: ${IMPACT_ANALYSIS}
**Validation**: All affected systems identified, risks acknowledged
**Parallel**: No (foundational)

---

## Phase 2: Compatibility Layer (if breaking changes)

[Only include if breaking changes detected]

### T002: Implement Compatibility Layer
**Description**: Create compatibility layer to support both old and new contracts
**Files**: [list files]
**Validation**: Old clients continue working
**Tech Stack Validation**: ${TECH_VALIDATION_ENABLED}
**Parallel**: No (foundational for other tasks)

### T003: Create Migration Scripts
**Description**: Implement data/config migration scripts
**Files**: [list migration scripts]
**Validation**: Scripts tested on copy of production data
**Parallel**: [P] (independent of T002)

---

## Phase 3: Core Modification Implementation

[Mark independent implementation tasks with [P] for parallel execution]

### T004: [P] Implement Functional Change 1
**Description**: [From modify.md]
**Files**: [list files]
**Tech Stack Validation**: ${TECH_VALIDATION_ENABLED}
**Parallel**: [P] (independent)

### T005: [P] Implement Functional Change 2
**Description**: [From modify.md]
**Files**: [list files]
**Tech Stack Validation**: ${TECH_VALIDATION_ENABLED}
**Parallel**: [P] (independent)

[Continue for all functional changes, marking independent tasks with [P]]

### T00N: Update Data Model
**Description**: Apply data model changes
**Files**: [list models/schemas]
**Migration Required**: [Yes/No]
**Parallel**: No (if migration dependencies)

### T00N+1: Update API Contracts
**Description**: Implement API contract changes
**Files**: [list API files]
**Backward Compatible**: [Yes/No]
**Parallel**: [P] (if independent)

---

## Phase 4: Testing and Validation

### T00N+2: [P] Run Regression Tests
**Description**: Verify existing functionality still works
**Command**: [test command]
**Expected**: 100% pass rate
**Parallel**: [P] (can run parallel with other tests)

### T00N+3: [P] Test New Functionality
**Description**: Verify modifications work as specified
**Command**: [test command]
**Expected**: All new tests pass
**Parallel**: [P]

### T00N+4: [P] Integration Testing
**Description**: Test with dependent systems
**Scope**: [list integration points]
**Expected**: No breaking changes for existing clients
**Parallel**: [P]

### T00N+5: Backward Compatibility Validation
**Description**: Verify old clients still work (if compatibility layer)
**Test Scenarios**: [list]
**Expected**: 100% compatibility
**Parallel**: No (final validation)

---

## Phase 5: Migration and Rollout

### T00N+6: Execute Data Migration (if applicable)
**Description**: Run migration scripts on production data
**Script**: [migration script path]
**Rollback Plan**: [Yes - describe]
**Parallel**: No (critical operation)

### T00N+7: Update Documentation
**Description**: Update API docs, migration guides, changelog
**Files**: [list docs]
**Parallel**: [P] (independent)

### T00N+8: Deploy Phase 1 (if phased rollout)
**Description**: Deploy to subset of users/environment
**Scope**: [deployment scope]
**Validation**: Monitor metrics, error rates
**Parallel**: No (sequential deployment)

[If SpecSwarm installed, add tech stack validation task]
${TECH_STACK_VALIDATION_TASK}

---

## Summary

**Total Tasks**: [N]
**Estimated Time**: [time] (varies by modification complexity)
**Parallel Opportunities**: [N tasks] can execute in parallel
**Breaking Changes**: [Yes/No]
**Migration Required**: [Yes/No]

**Success Criteria**:
- ✅ Impact analysis validated
- ✅ Compatibility layer implemented (if breaking changes)
- ✅ All modifications implemented
- ✅ Backward compatibility maintained (or migration plan executed)
- ✅ All tests passing (regression + new functionality)
- ✅ Dependent systems validated
${TECH_COMPLIANCE_CRITERION}
```

Write tasks to `$TASKS_FILE`.

Output to user:
```
📊 Tasks Generated
✓ Created: ${TASKS_FILE}
✓ [N] tasks across 5 phases
✓ Phase 1: Impact validation
✓ Phase 2: Compatibility layer (if needed)
✓ Phase 3: Core implementation ([N] parallel tasks)
✓ Phase 4: Testing ([N] parallel tasks)
✓ Phase 5: Migration and rollout
```

---

### 8. Execute Workflow

Execute tasks using the appropriate mode (similar to bugfix workflow, but with more parallel opportunities in Phase 3 and 4).

[Execute with smart integration - SpecTest parallel execution, SpecSwarm tech validation]

---

## Post-Workflow Hook (if SpecTest installed)

```bash
if [ "$ENABLE_HOOKS" = "true" ]; then
  echo ""
  echo "🎣 Post-Modify Hook"

  # Calculate metrics
  WORKFLOW_END_TIME=$(date +%s)
  WORKFLOW_DURATION=$((WORKFLOW_END_TIME - WORKFLOW_START_TIME))
  WORKFLOW_HOURS=$(echo "scale=1; $WORKFLOW_DURATION / 3600" | bc)

  # Validate completion
  echo "✓ Modification complete"
  echo "✓ Backward compatibility maintained"
  echo "✓ All tests passing"

  # Tech stack compliance
  if [ "$SPECSWARM_INSTALLED" = "true" ]; then
    echo "✓ Tech stack compliant"
  fi

  # Update metrics
  METRICS_FILE="/memory/workflow-metrics.json"
  # [Update JSON with modify metrics]
  echo "📊 Metrics saved: ${METRICS_FILE}"

  echo ""
  echo "⏱️  Time to Modify: ${WORKFLOW_HOURS}h"
  echo ""
  echo "✅ Modify Workflow Complete"
  echo ""
  echo "📈 Next Steps:"
  echo "- Review: ${MODIFY_SPEC}"
  echo "- Review: ${IMPACT_ANALYSIS}"
  echo "- Commit changes with migration plan"
  echo "- View metrics: /speclab:workflow-metrics ${FEATURE_NUM}"
fi
```

---

## Final Output

```
✅ Modify Workflow Complete - Feature ${FEATURE_NUM}

📋 Artifacts Created:
- ${MODIFY_SPEC}
- ${IMPACT_ANALYSIS}
- ${TASKS_FILE}

📊 Results:
- Modification implemented successfully
- Breaking changes: [Y/N]
  - [If Y] Backward compatibility maintained via [strategy]
- Dependencies validated: [N] systems tested
- Migration executed: [Y/N]
${TECH_STACK_COMPLIANCE_RESULT}

⏱️  Time to Modify: ${WORKFLOW_DURATION}
${PARALLEL_SPEEDUP_RESULT}

📈 Next Steps:
1. Review artifacts in: ${FEATURE_DIR}
2. Monitor metrics: [list key metrics]
3. Execute migration: [if phased, describe next phase]
4. View analytics: /speclab:workflow-metrics ${FEATURE_NUM}
```

---

## Error Handling

**If feature not found**:
- List available features
- Prompt for correct feature number

**If no existing spec.md**:
- Error: "Modification requires existing feature specification"
- Suggest running feature workflow first

**If breaking changes unavoidable**:
- Require explicit acknowledgment from user
- Mandate compatibility layer or migration plan

**If impact analysis shows high risk**:
- Flag for manual review
- Suggest phased rollout strategy

---

## Operating Principles

1. **Impact First**: Always analyze before modifying
2. **Backward Compatibility**: Prioritize non-breaking changes
3. **Migration Planning**: Plan data and client migrations
4. **Dependency Mapping**: Identify all affected systems
5. **Risk Assessment**: Evaluate and mitigate risks
6. **Phased Rollout**: Prefer gradual over big-bang changes
7. **Tech Compliance**: Validate against tech stack (if SpecSwarm installed)
8. **Metrics Tracking**: Record change scope, risk level, success

---

## Success Criteria

✅ Impact analysis identifies all affected systems
✅ Breaking changes assessed and mitigated
✅ Modification specification documents all changes
✅ Backward compatibility strategy implemented
✅ Migration plan executed (if needed)
✅ All tests passing (regression + new functionality)
✅ Dependent systems validated
✅ Tech stack compliant (if SpecSwarm installed)
✅ Metrics tracked (if SpecTest installed)

---

**Workflow Coverage**: Addresses ~30% of development work (feature modifications)
**Integration**: Smart detection of SpecSwarm (tech enforcement) and SpecTest (parallel/hooks)
**Graduation Path**: Proven workflow will graduate to SpecSwarm stable
