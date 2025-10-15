# Orchestrator Detection System - Design Specification

**Date:** October 14, 2025
**Status:** Design Phase
**Purpose:** Auto-detect when to use Orchestrator for complex debugging/development workflows

---

## Overview

Based on learnings from the [2025-10-14-orchestrator-missed-opportunity.md](2025-10-14-orchestrator-missed-opportunity.md) document, we need a systematic way to detect when Orchestrator should be used instead of sequential debugging.

**Key Insight:** Even plugin developers miss orchestration opportunities. We need automated detection.

---

## Architecture

### Component Structure

```
plugins/
├── speclab/
│   ├── commands/
│   │   ├── bugfix.md (ENHANCED with detection)
│   │   └── ... (other commands)
│   └── lib/
│       └── orchestrator-detection.sh (NEW - shared detection logic)
│
├── debug-coordinate/ (NEW PLUGIN)
│   ├── commands/
│   │   ├── coordinate.md
│   │   └── analyze-logs.md
│   └── .claude-plugin/
│       └── description.md
│
└── project-orchestrator/
    ├── commands/
    │   └── ... (existing commands)
    └── templates/
        ├── debug-mode-template.md (NEW)
        └── ... (existing templates)
```

---

## Detection Heuristics Module

### Location
`plugins/speclab/lib/orchestrator-detection.sh`

### Interface

```bash
#!/bin/bash

# Orchestrator Detection Heuristics
# Usage: source this file and call should_use_orchestrator

# Function: should_use_orchestrator
# Returns: 0 (true) if orchestrator should be used, 1 (false) otherwise
# Outputs: Recommendation message to stdout

should_use_orchestrator() {
    local bug_count="${1:-0}"
    local file_list="${2:-}"
    local context_info="${3:-}"

    # Calculate signals
    local domain_count=0
    local recommendation="no"
    local reason=""
    local confidence="low"

    # Signal 1: Multiple bugs (>= 3)
    local multi_bug_signal=0
    if [ "$bug_count" -ge 3 ]; then
        multi_bug_signal=1
    fi

    # Signal 2: Multiple domains (>= 3)
    local multi_domain_signal=0
    if [ -n "$file_list" ]; then
        domain_count=$(detect_domains "$file_list")
        if [ "$domain_count" -ge 3 ]; then
            multi_domain_signal=1
        fi
    fi

    # Signal 3: High context (from context_info)
    local high_context_signal=0
    if echo "$context_info" | grep -q "high_token_usage"; then
        high_context_signal=1
    fi

    # Signal 4: Complex coordination (from context_info)
    local complex_coordination_signal=0
    if echo "$context_info" | grep -q "requires_server_restarts\|requires_logging"; then
        complex_coordination_signal=1
    fi

    # Decision logic
    local signal_count=$((multi_bug_signal + multi_domain_signal + high_context_signal + complex_coordination_signal))

    if [ "$signal_count" -ge 3 ]; then
        recommendation="yes"
        confidence="high"
        reason="Multiple bugs ($bug_count) across different domains ($domain_count) with complex coordination"
    elif [ "$signal_count" -ge 2 ] && [ "$multi_bug_signal" -eq 1 ] && [ "$multi_domain_signal" -eq 1 ]; then
        recommendation="yes"
        confidence="medium"
        reason="$bug_count bugs across $domain_count domains (core criteria met)"
    elif [ "$signal_count" -ge 2 ]; then
        recommendation="consider"
        confidence="medium"
        reason="Significant complexity detected ($signal_count signals)"
    fi

    # Output recommendation
    if [ "$recommendation" = "yes" ]; then
        cat <<EOF
{
  "recommendation": "orchestrator",
  "confidence": "$confidence",
  "reason": "$reason",
  "signals": {
    "bug_count": $bug_count,
    "domain_count": $domain_count,
    "multi_bug": $multi_bug_signal,
    "multi_domain": $multi_domain_signal,
    "high_context": $high_context_signal,
    "complex_coordination": $complex_coordination_signal
  },
  "estimated_time_savings": "40-60%"
}
EOF
        return 0
    elif [ "$recommendation" = "consider" ]; then
        cat <<EOF
{
  "recommendation": "consider_orchestrator",
  "confidence": "$confidence",
  "reason": "$reason",
  "signals": {
    "bug_count": $bug_count,
    "domain_count": $domain_count,
    "multi_bug": $multi_bug_signal,
    "multi_domain": $multi_domain_signal,
    "high_context": $high_context_signal,
    "complex_coordination": $complex_coordination_signal
  }
}
EOF
        return 0
    else
        return 1
    fi
}

# Helper: Detect unique domains from file list
detect_domains() {
    local files="$1"

    # Extract file extensions and categorize into domains
    local domains=""

    # Backend indicators
    if echo "$files" | grep -qE '\.(ts|js).*server|src/server|api/|middleware/'; then
        domains="$domains backend"
    fi

    # Frontend indicators
    if echo "$files" | grep -qE 'app/|components/|pages/|\.tsx|\.jsx'; then
        domains="$domains frontend"
    fi

    # Database indicators
    if echo "$files" | grep -qE 'types/.*\.ts|schema|migrations/|db/'; then
        domains="$domains database"
    fi

    # Testing indicators
    if echo "$files" | grep -qE 'test/|spec\.|\.test\.|\.spec\.'; then
        domains="$domains testing"
    fi

    # Config indicators
    if echo "$files" | grep -qE 'vite\.config|tsconfig|package\.json|\.env'; then
        domains="$domains config"
    fi

    # Count unique domains
    echo "$domains" | tr ' ' '\n' | sort -u | wc -l
}

# Export functions
export -f should_use_orchestrator
export -f detect_domains
```

---

## Integration Points

### 1. SpecLab Bugfix Command

**File:** `plugins/speclab/commands/bugfix.md`

**Integration Location:** After Step 2 (Create Bugfix Specification)

```markdown
### 2.5. Orchestrator Detection (NEW)

After creating the bugfix specification, analyze whether this is an orchestration opportunity:

```bash
# Load detection library
source "$(dirname $0)/../lib/orchestrator-detection.sh"

# Count bugs in specification
BUG_COUNT=$(grep -c "^### Bug #" "$BUGFIX_SPEC" || echo "1")

# Get list of affected files
AFFECTED_FILES=$(grep -A 10 "^## Files to Modify" "$BUGFIX_SPEC" | grep "^-" | sed 's/^- //' || echo "")

# Build context info
CONTEXT_INFO=""
if grep -q "logging" "$BUGFIX_SPEC"; then
    CONTEXT_INFO="${CONTEXT_INFO} requires_logging"
fi
if grep -q "restart" "$BUGFIX_SPEC"; then
    CONTEXT_INFO="${CONTEXT_INFO} requires_server_restarts"
fi

# Check if orchestrator should be used
DETECTION_RESULT=$(should_use_orchestrator "$BUG_COUNT" "$AFFECTED_FILES" "$CONTEXT_INFO")

if [ $? -eq 0 ]; then
    echo ""
    echo "🎯 Orchestrator Detection"
    echo "========================"
    echo ""
    echo "$DETECTION_RESULT" | jq -r '.reason'
    echo ""

    RECOMMENDATION=$(echo "$DETECTION_RESULT" | jq -r '.recommendation')

    if [ "$RECOMMENDATION" = "orchestrator" ]; then
        echo "💡 RECOMMENDATION: Use Project Orchestrator for parallel investigation"
        echo ""
        echo "Benefits:"
        echo "  • Estimated time savings: 40-60%"
        echo "  • Parallel bug investigation"
        echo "  • Better context management"
        echo "  • Coordinated server restarts"
        echo ""
        echo "Would you like to:"
        echo "  1. Continue with sequential bugfix workflow"
        echo "  2. Switch to Orchestrator debug mode"
        echo ""
        read -p "Choose (1/2): " WORKFLOW_CHOICE

        if [ "$WORKFLOW_CHOICE" = "2" ]; then
            echo ""
            echo "✅ Switching to Orchestrator debug mode..."
            echo ""
            echo "Run: /project-orchestrator:debug --spec=$BUGFIX_SPEC"
            exit 0
        fi
    elif [ "$RECOMMENDATION" = "consider_orchestrator" ]; then
        echo "💭 SUGGESTION: Orchestrator may help with this workflow"
        echo ""
        echo "Signals detected: $(echo "$DETECTION_RESULT" | jq -r '.signals | to_entries | map("\(.key)") | join(", ")')"
        echo ""
        echo "Consider using /project-orchestrator:debug if workflow becomes complex"
        echo ""
    fi
fi
```

Continue with normal workflow...
\```
```

### 2. Debug Coordinate Plugin

**New Plugin:** `plugins/debug-coordinate/`

**Purpose:** Systematic debugging coordination with logging, monitoring, and agent spawning

**Command:** `/debug:coordinate <problem-description>`

**Workflow:**
1. **Discovery Phase**
   - Add comprehensive logging across suspected files
   - Set up monitoring for server output
   - Collect baseline data

2. **Analysis Phase**
   - Run application and collect logs
   - Correlate log patterns with code
   - Identify root causes
   - Categorize issues by domain

3. **Orchestration Phase**
   - Generate orchestration plan
   - Spawn specialist agents per domain
   - Coordinate parallel fixes
   - Manage server restart timing

4. **Integration Phase**
   - Verify fixes work together
   - Run integration tests
   - Document learnings

### 3. Orchestrator Debug Mode Template

**File:** `plugins/project-orchestrator/templates/debug-mode-template.md`

**Purpose:** Specialized orchestration template for debugging scenarios

**Phases:**
1. **Discovery** - Logging and data collection
2. **Analysis** - Root cause identification
3. **Parallel Fixing** - Domain specialist agents
4. **Integration** - Verification and testing

---

## Detection Signals Reference

From the learning document, here are the key signals:

### Complexity Signals
- ☑️ User reports multiple distinct issues (>2)
- ☑️ Investigation reveals >3 different bugs
- ☑️ Issues span >3 different domains/file types
- ☑️ Requires iterative logging → restart → test cycles
- ☑️ Context is growing rapidly (>50K tokens)

### Workflow Signals
- ☑️ Need parallel investigation tracks
- ☑️ Multiple specialists needed simultaneously
- ☑️ Complex coordination between fixes
- ☑️ Long server startup/restart times
- ☑️ Cross-cutting concerns (auth, state, DB, UI)

### Code Pattern Signals
- ☑️ Debug loop detected (log → restart → check → fix → repeat)
- ☑️ Field name mismatches (DB snake_case vs code camelCase)
- ☑️ Cookie/Auth cascading issues

---

## User Experience

### Sequential Workflow (Current)
```
User: "Fix these 5 bugs"
  → Bugfix #1 (20 min)
  → Bugfix #2 (15 min)
  → Bugfix #3 (30 min)
  → Bugfix #4 (10 min)
  → Bugfix #5 (10 min)
Total: 85 minutes
```

### With Orchestrator Detection (Improved)
```
User: "Fix these 5 bugs"
  → SpecLab analyzes bugs
  → Detection: "5 bugs across 4 domains detected"
  → Prompt: "Use Orchestrator? (40-60% time savings)"
  → User: "Yes"
  → Orchestrator spawns 4 parallel agents
  → Total: ~35 minutes (60% reduction)
```

---

## Success Metrics

### Detection Accuracy
- **True Positive**: Correctly suggests Orchestrator when it would help
- **False Positive**: Suggests Orchestrator when not needed (user wastes time)
- **True Negative**: Doesn't suggest when not needed
- **False Negative**: Misses opportunity (like the original scenario!)

**Target**: >80% true positive rate, <10% false positive rate

### Time Savings
- Track actual time with Orchestrator vs sequential estimate
- Target: 40-60% time savings on multi-bug scenarios

### User Adoption
- % of users who accept Orchestrator recommendation
- % of users who manually request Orchestrator
- Target: >60% adoption rate

---

## Implementation Phases

### Phase 1: Detection System (This PR)
- ✅ Create orchestrator-detection.sh library
- ✅ Integrate into SpecLab bugfix command
- ✅ Add user prompts for workflow choice
- ✅ Document decision logic

### Phase 2: Debug Coordinate Plugin
- ✅ Create plugin structure
- ✅ Implement coordinate command
- ✅ Build logging strategy automation
- ✅ Add monitoring capabilities

### Phase 3: Orchestrator Debug Mode
- ✅ Create debug-mode template
- ✅ Integrate with detection system
- ✅ Test end-to-end workflow

### Phase 4: Refinement & Metrics
- Track usage and outcomes
- Refine detection thresholds
- Add more sophisticated domain detection
- Improve prompts based on user feedback

---

## Testing Strategy

### Test Scenarios

**Scenario 1: Multi-Bug Detection (from learning doc)**
- 5 bugs across backend, frontend, DB, testing
- **Expected**: Strongly recommend Orchestrator (high confidence)

**Scenario 2: Single Bug**
- 1 bug in single file
- **Expected**: No recommendation

**Scenario 3: Edge Case - 2 Bugs, 2 Domains**
- Just below threshold
- **Expected**: No strong recommendation (maybe "consider")

**Scenario 4: Complex Single Bug**
- 1 bug but requires extensive logging + restarts
- **Expected**: Consider recommendation

### Validation Tests
- Create test cases for each scenario
- Verify detection output matches expectations
- Test user experience flow
- Measure time savings on real bugs

---

## Documentation Requirements

### User-Facing
- Update SpecLab README with Orchestrator detection
- Add examples of when Orchestrator is suggested
- Document how to override suggestion

### Developer-Facing
- Document detection algorithm
- Explain threshold tuning
- Provide examples of adding new signals
- Testing guide for detection logic

---

## Future Enhancements

### Smart Context Tracking
- Track token usage during session
- Detect when context is growing rapidly
- Suggest compaction or orchestration

### Pattern Recognition
- Build library of common multi-bug patterns
- Auto-categorize by domain
- Suggest specific agent types

### Learning System
- Track user choices (accept/reject recommendations)
- Refine thresholds based on outcomes
- Personalize recommendations

### IDE Integration
- Visual indicators in editor when threshold crossed
- Quick actions to launch Orchestrator
- Real-time signal monitoring

---

## Conclusion

This detection system addresses the core problem identified in the learning document: **even experts miss orchestration opportunities**.

By automating detection and providing clear recommendations, we:
1. ✅ Reduce time-to-fix for multi-bug scenarios (40-60%)
2. ✅ Improve context management
3. ✅ Enable parallel investigation
4. ✅ Educate users on when to orchestrate
5. ✅ Build toward autonomous debugging

**Next Step**: Implement Phase 1 (Detection System) and validate with real-world bugs.
