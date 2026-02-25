---
description: Feature modification workflow with impact analysis and backward compatibility assessment
args:
  - name: modification_description
    description: Natural language description of the modification
    required: false
  - name: --refactor
    description: Behavior-preserving quality improvement (metrics-driven refactoring)
    required: false
  - name: --deprecate
    description: Phased feature sunset with migration guidance
    required: false
  - name: --analyze-only
    description: Run impact analysis only without implementing changes
    required: false
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Flag Parsing

```bash
# Parse flags from arguments
MODIFY_DESC=""
REFACTOR_MODE=false
DEPRECATE_MODE=false
ANALYZE_ONLY=false

for arg in $ARGUMENTS; do
  if [ "${arg:0:2}" != "--" ] && [ -z "$MODIFY_DESC" ]; then
    MODIFY_DESC="$arg"
  elif [ "$arg" = "--refactor" ]; then
    REFACTOR_MODE=true
  elif [ "$arg" = "--deprecate" ]; then
    DEPRECATE_MODE=true
  elif [ "$arg" = "--analyze-only" ]; then
    ANALYZE_ONLY=true
  fi
done
```

## Mode Routing

**IF --refactor flag is set**, execute metrics-driven behavior-preserving refactoring workflow:

```bash
if [ "$REFACTOR_MODE" = true ]; then
  echo "SpecSwarm Modify --refactor"
  echo "=============================================="
  echo ""
  echo "Mode: Behavior-Preserving Quality Improvement"
  echo ""
  echo "This workflow will:"
  echo "  1. Establish baseline metrics (complexity, duplication, coverage)"
  echo "  2. Create refactoring specification"
  echo "  3. Execute incremental refactoring steps"
  echo "  4. Verify behavior preservation after each step (test suite)"
  echo "  5. Measure final metrics and compare improvement"
  echo ""
  echo "Key principles:"
  echo "  - No functional changes - behavior must be identical"
  echo "  - Metrics-driven - quantify improvements"
  echo "  - Incremental - small, safe refactoring steps"
  echo "  - Testable - verify identical behavior before/after"
  echo ""
fi
```

**IF REFACTOR_MODE = true**: Execute the refactoring workflow:
1. Discover refactor context (find feature directory)
2. Establish baseline metrics (complexity, duplication, coverage, maintainability)
3. Create refactor specification documenting target, approach, and expected improvements
4. Generate incremental refactoring tasks (each followed by test verification)
5. Execute tasks: refactor step -> run tests -> verify identical results -> repeat
6. Measure final metrics and generate before/after comparison report

**After refactoring completes, STOP. Do not continue to the standard modify workflow.**

---

**IF --deprecate flag is set**, execute phased feature sunset workflow:

```bash
if [ "$DEPRECATE_MODE" = true ]; then
  echo "SpecSwarm Modify --deprecate"
  echo "=============================================="
  echo ""
  echo "Mode: Phased Feature Sunset"
  echo ""
  echo "This workflow will:"
  echo "  1. Identify feature to deprecate and replacement"
  echo "  2. Analyze current usage and dependencies"
  echo "  3. Create deprecation specification with timeline"
  echo "  4. Generate migration guide for users"
  echo "  5. Plan phased removal (Announce -> Migrate -> Remove)"
  echo ""
fi
```

**IF DEPRECATE_MODE = true**: Execute the deprecation workflow:
1. Identify feature to deprecate and its replacement/alternative
2. Analyze current usage patterns and dependent systems
3. Create deprecation specification with phased timeline (Announce -> Migrate -> Remove)
4. Generate migration guide with before/after code examples
5. Create tasks for each phase: add deprecation warnings, publish guide, monitor adoption, remove code
6. Execute Phase 1 (announcement) tasks immediately; Phase 2-3 are tracked for future execution

**After deprecation plan is created, STOP. Do not continue to the standard modify workflow.**

---

**IF --analyze-only flag is set**, run impact analysis without implementing changes:

```bash
if [ "$ANALYZE_ONLY" = true ]; then
  echo "SpecSwarm Modify --analyze-only"
  echo "=============================================="
  echo ""
  echo "Mode: Impact Analysis Only (no implementation)"
  echo ""
fi
```

**IF ANALYZE_ONLY = true**: Execute only the impact analysis steps (Steps 1-5 of the standard workflow below), generate the impact analysis report, and STOP before task generation or implementation. Output the report and recommendations.

---

**IF no mode flags are set**, continue with the standard modify workflow below.

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
  echo "Modify Workflow"
  echo ""
  echo "No modify branch detected. Please provide feature number to modify:"
  echo "Example: 018 (for modify/018-api-pagination)"
  # Wait for user input
  read -p "Feature number: " FEATURE_NUM

  # Validate
  if [ -z "$FEATURE_NUM" ]; then
    echo "Error: Feature number required"
    exit 1
  fi

  # Pad to 3 digits
  FEATURE_NUM=$(printf "%03d" $FEATURE_NUM)
fi

# Get features directory
FEATURES_DIR="$REPO_ROOT/features"
if [ -d "$REPO_ROOT/.specswarm/features" ]; then
  FEATURES_DIR="$REPO_ROOT/.specswarm/features"
fi

# Find feature directory
FEATURE_DIR=$(find "$FEATURES_DIR" -maxdepth 1 -type d -name "${FEATURE_NUM}-*" 2>/dev/null | head -1)

if [ -z "$FEATURE_DIR" ]; then
  echo "Error: Feature ${FEATURE_NUM} not found"
  echo ""
  echo "Modification requires existing feature specification."
  echo "Available features:"
  ls -1 "$FEATURES_DIR" 2>/dev/null | head -10
  exit 1
fi

# Check if spec.md exists (required for modification)
ORIGINAL_SPEC="${FEATURE_DIR}/spec.md"
if [ ! -f "$ORIGINAL_SPEC" ]; then
  echo "Error: No spec.md found for feature ${FEATURE_NUM}"
  echo "Modification requires existing feature specification."
  exit 1
fi

MODIFY_SPEC="${FEATURE_DIR}/modify.md"
IMPACT_ANALYSIS="${FEATURE_DIR}/impact-analysis.md"
TASKS_FILE="${FEATURE_DIR}/tasks.md"
```

Output to user:
```
Modify Workflow - Feature ${FEATURE_NUM}
- Branch detected: ${CURRENT_BRANCH}
- Feature directory: ${FEATURE_DIR}
- Original spec found: ${ORIGINAL_SPEC}
```

---

### 2. Load Existing Feature Specification

Read `$ORIGINAL_SPEC` to understand current feature implementation:

```bash
# Extract key information from spec
echo "Analyzing Existing Feature..."
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
Existing Feature Analysis
- Feature: [Feature Name]
- Requirements: [N functional requirements]
- Data Model: [Key entities]
- Current Implementation: [Brief summary]
```

---

### 3. Gather Modification Requirements

Prompt user for modification details:

```
Modification Details

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
Analyzing Impact...
```

**Search for Dependencies:**
1. Find all files referencing feature components
2. Identify API consumers (if API changes)
3. Find database queries (if data model changes)
4. Locate UI components (if behavior changes)

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

Create `$IMPACT_ANALYSIS` with detailed analysis including:

- Proposed changes
- Affected components (direct and indirect)
- Breaking changes assessment
- Backward compatibility strategy
- Migration requirements
- Risk assessment
- Testing requirements
- Rollout strategy

---

### 6. Create Modification Specification

Create `$MODIFY_SPEC` documenting the planned modification including:

- Modification summary and rationale
- Current state vs proposed changes
- Functional, data model, and API changes
- Backward compatibility strategy
- Migration plan
- Testing strategy
- Rollout plan
- Success metrics
- Risks and mitigation
- Alternative approaches considered

---

### 7. Generate Tasks

**YOU MUST NOW run the tasks command using the SlashCommand tool:**

```
Use the SlashCommand tool to execute: /sw:tasks
```

This will generate implementation tasks for the modification.

---

### 8. Execute Workflow

Execute tasks to implement the modification:

**YOU MUST NOW run the implement command using the SlashCommand tool:**

```
Use the SlashCommand tool to execute: /sw:implement
```

---

## Final Output

```
Modify Workflow Complete - Feature ${FEATURE_NUM}

Artifacts Created:
- ${MODIFY_SPEC}
- ${IMPACT_ANALYSIS}
- ${TASKS_FILE}

Results:
- Modification implemented successfully
- Breaking changes: [Y/N]
  - [If Y] Backward compatibility maintained via [strategy]
- Dependencies validated: [N] systems tested
- Migration executed: [Y/N]

Next Steps:
1. Review artifacts in: ${FEATURE_DIR}
2. Run tests to verify changes
3. Ship when ready: /sw:ship
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

---

## Success Criteria

- Impact analysis identifies all affected systems
- Breaking changes assessed and mitigated
- Modification specification documents all changes
- Backward compatibility strategy implemented
- Migration plan executed (if needed)
- All tests passing (regression + new functionality)
- Dependent systems validated
