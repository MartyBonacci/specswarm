# Phase 1a Implementation Plan: Test Orchestrator Foundation

**Goal**: Build production-ready test orchestration with reliability, retry logic, and automated validation

**Timeline**: 3-4 weeks
**Status**: Planning → Implementation
**Date Started**: 2025-10-16

---

## Executive Summary

Phase 1a transforms our Phase 0 POC into a **production-ready test orchestration system** by adding:
1. **State Management** - Track progress, persist state, resume on failure
2. **Retry Logic** - Handle failures gracefully with intelligent retries
3. **Decision Maker** - Automated continue/retry/escalate decisions
4. **Vision API Integration** - Automated visual validation
5. **Metrics Tracking** - Learn from executions, improve over time

**Deliverable**: `/speclabs:orchestrate` command that works reliably in production with automated recovery and validation.

---

## Phase 0 → Phase 1a Transformation

### What Changes

| Component | Phase 0 (Current) | Phase 1a (Goal) |
|-----------|-------------------|-----------------|
| **State** | ❌ None (lost on exit) | ✅ Persistent to `/memory/orchestrator/` |
| **Failures** | ❌ Agent fails → game over | ✅ Auto-retry with refined prompt (3x) |
| **Validation** | ⚠️ Manual screenshot review | ✅ Automated with Vision API |
| **Metrics** | ❌ No tracking | ✅ All executions tracked, analyzed |
| **Recovery** | ❌ Start from scratch | ✅ Resume from checkpoints |
| **Success Rate** | ~70% (estimated) | 90%+ (with retries) |

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│  /speclabs:orchestrate <workflow> <project>            │
└─────────────┬───────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────┐
│  ORCHESTRATION COORDINATOR                                   │
│  - Manages execution flow                                    │
│  - Delegates to specialized managers                         │
│  - Tracks overall state                                      │
└─────────────┬───────────────────────────────────────────────┘
              │
              ├──> STATE MANAGER
              │    ├─ Create session
              │    ├─ Track progress
              │    ├─ Persist state to /memory/
              │    └─ Handle resume
              │
              ├──> WORKFLOW PARSER
              │    ├─ Parse test-workflow.md
              │    ├─ Extract requirements
              │    ├─ Validate format
              │    └─ Build execution plan
              │
              ├──> PROMPT GENERATOR
              │    ├─ Generate comprehensive prompt
              │    ├─ Include context
              │    ├─ Add constraints
              │    └─ Learn from past failures
              │
              ├──> AGENT LAUNCHER
              │    ├─ Launch Task tool agent
              │    ├─ Monitor execution
              │    ├─ Capture output
              │    └─ Detect failures
              │
              ├──> VALIDATION COORDINATOR
              │    ├─ Run Playwright validation
              │    ├─ Call Vision API
              │    ├─ Analyze results
              │    └─ Return pass/fail + details
              │
              ├──> DECISION MAKER
              │    ├─ Analyze results
              │    ├─ Decide: continue | retry | escalate
              │    ├─ Generate retry strategy
              │    └─ Trigger appropriate action
              │
              └──> METRICS TRACKER
                   ├─ Log all executions
                   ├─ Track success rates
                   ├─ Identify patterns
                   └─ Persist to /memory/orchestrator-metrics/
```

---

## Component Specifications

### 1. State Manager

**Purpose**: Track orchestration progress, persist state, enable resume

**Location**: `plugins/speclabs/lib/state-manager.sh`

**State Schema**:
```json
{
  "session_id": "orch-20251016-143022",
  "status": "in_progress",
  "created_at": "2025-10-16T14:30:22Z",
  "updated_at": "2025-10-16T14:45:10Z",

  "workflow": {
    "file": "features/001-fix/test-workflow.md",
    "task_name": "Fix Vite Config",
    "project_path": "/home/marty/code-projects/tweeter-spectest"
  },

  "agent": {
    "id": "agent-abc123",
    "status": "completed",
    "started_at": "2025-10-16T14:30:30Z",
    "completed_at": "2025-10-16T14:45:00Z",
    "error": null,
    "output_summary": "Completed successfully"
  },

  "validation": {
    "status": "passed",
    "playwright": {
      "console_errors": 0,
      "network_errors": 0,
      "screenshot": "/tmp/orch-session-123-screenshot.png"
    },
    "vision_api": {
      "analysis": "All elements present and correct",
      "issues_found": [],
      "score": 95
    }
  },

  "retries": {
    "count": 0,
    "max": 3,
    "history": []
  },

  "decision": {
    "action": "complete",
    "reason": "Agent succeeded, validation passed",
    "timestamp": "2025-10-16T14:45:10Z"
  },

  "metrics": {
    "total_time_seconds": 900,
    "agent_time_seconds": 870,
    "validation_time_seconds": 30
  }
}
```

**Functions**:
```bash
# Create new session
state_create_session() {
  local workflow_file="$1"
  local project_path="$2"
  local session_id="orch-$(date +%Y%m%d-%H%M%S)"

  # Create state directory
  mkdir -p "/memory/orchestrator/sessions/$session_id"

  # Initialize state file
  cat > "/memory/orchestrator/sessions/$session_id/state.json" <<EOF
{
  "session_id": "$session_id",
  "status": "in_progress",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "workflow": {
    "file": "$workflow_file",
    "project_path": "$project_path"
  },
  "retries": {
    "count": 0,
    "max": 3,
    "history": []
  }
}
EOF

  echo "$session_id"
}

# Update state
state_update() {
  local session_id="$1"
  local key="$2"
  local value="$3"

  # Use jq to update JSON
  local state_file="/memory/orchestrator/sessions/$session_id/state.json"
  jq ".$key = $value" "$state_file" > "${state_file}.tmp"
  mv "${state_file}.tmp" "$state_file"
}

# Get state value
state_get() {
  local session_id="$1"
  local key="$2"

  local state_file="/memory/orchestrator/sessions/$session_id/state.json"
  jq -r ".$key" "$state_file"
}

# Mark session complete
state_complete() {
  local session_id="$1"
  local final_status="$2"  # success | failure | escalated

  state_update "$session_id" "status" "\"$final_status\""
  state_update "$session_id" "completed_at" "\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
}

# Resume session (for retry)
state_resume() {
  local session_id="$1"

  # Check if session exists
  if [ ! -f "/memory/orchestrator/sessions/$session_id/state.json" ]; then
    echo "ERROR: Session $session_id not found"
    return 1
  fi

  # Increment retry count
  local retry_count=$(state_get "$session_id" "retries.count")
  state_update "$session_id" "retries.count" "$((retry_count + 1))"

  echo "Resuming session $session_id (retry $((retry_count + 1)))"
}
```

**Storage Location**: `/memory/orchestrator/sessions/<session-id>/state.json`

---

### 2. Decision Maker

**Purpose**: Analyze results and decide next action

**Location**: `plugins/speclabs/lib/decision-maker.sh`

**Decision Flow**:
```
┌─────────────────┐
│ Agent Result +  │
│ Validation      │
└────────┬────────┘
         │
         ▼
    ┌─────────┐
    │ Analyze │
    └────┬────┘
         │
         ▼
   ╔═══════════════════╗
   ║ Decision Tree     ║
   ╚═══════════════════╝
         │
    ┌────┴──────┬──────────┬─────────────┐
    ▼           ▼          ▼             ▼
┌────────┐  ┌──────┐  ┌─────────┐  ┌─────────┐
│SUCCESS │  │RETRY │  │ESCALATE │  │UNKNOWN  │
└────────┘  └──────┘  └─────────┘  └─────────┘
```

**Decision Logic**:
```bash
decision_make() {
  local session_id="$1"

  # Get current state
  local agent_status=$(state_get "$session_id" "agent.status")
  local validation_status=$(state_get "$session_id" "validation.status")
  local retry_count=$(state_get "$session_id" "retries.count")
  local max_retries=$(state_get "$session_id" "retries.max")

  # Decision: SUCCESS
  if [ "$agent_status" == "completed" ] && [ "$validation_status" == "passed" ]; then
    echo "complete"
    return 0
  fi

  # Decision: RETRY (within limit)
  if [ "$retry_count" -lt "$max_retries" ]; then
    # Agent failed OR validation failed
    if [ "$agent_status" == "failed" ] || [ "$validation_status" == "failed" ]; then
      echo "retry"
      return 0
    fi
  fi

  # Decision: ESCALATE (max retries exceeded)
  if [ "$retry_count" -ge "$max_retries" ]; then
    echo "escalate"
    return 0
  fi

  # Decision: UNKNOWN (shouldn't happen)
  echo "unknown"
  return 1
}

# Generate retry strategy based on failure analysis
decision_generate_retry_strategy() {
  local session_id="$1"

  # Analyze failure
  local agent_error=$(state_get "$session_id" "agent.error")
  local validation_issues=$(state_get "$session_id" "validation.vision_api.issues_found")

  # Generate retry strategy
  local strategy=""

  if echo "$agent_error" | grep -q "file not found"; then
    strategy="RETRY: Agent couldn't find files. Refine prompt with explicit file paths."
  elif echo "$agent_error" | grep -q "permission denied"; then
    strategy="RETRY: Permission issue. Check project path and file permissions."
  elif echo "$validation_issues" | grep -q "missing element"; then
    strategy="RETRY: UI elements missing. Refine requirements to be more specific."
  else
    strategy="RETRY: General failure. Add more context and examples to prompt."
  fi

  echo "$strategy"
}
```

**Outputs**:
- Decision: `complete | retry | escalate | unknown`
- Retry strategy (if retry)
- Escalation details (if escalate)

---

### 3. Prompt Refiner

**Purpose**: Learn from failures and improve prompts on retry

**Location**: `plugins/speclabs/lib/prompt-refiner.sh`

**Refinement Strategy**:
```bash
prompt_refine() {
  local session_id="$1"
  local original_prompt="$2"

  # Get failure details
  local agent_error=$(state_get "$session_id" "agent.error")
  local retry_count=$(state_get "$session_id" "retries.count")
  local validation_issues=$(state_get "$session_id" "validation.vision_api.issues_found")

  # Build refinements
  local refinements=""

  # Add failure context
  refinements="$refinements

## IMPORTANT: Previous Attempt Failed
**Retry #$retry_count**

**Previous Error**: $agent_error

**Validation Issues**: $validation_issues

## Refinements for This Attempt
"

  # File not found error → Add explicit paths
  if echo "$agent_error" | grep -q "file not found"; then
    refinements="$refinements
- **File Paths**: Use absolute paths. Project is at: $(state_get "$session_id" "workflow.project_path")
- **Verify Files Exist**: Use ls or find before modifying files
- **Check Working Directory**: Ensure you're in the correct directory
"
  fi

  # UI elements missing → More specific requirements
  if echo "$validation_issues" | grep -q "missing"; then
    refinements="$refinements
- **UI Elements**: Previous attempt missed some UI elements
- **Be More Explicit**: Create ALL elements specified in workflow
- **Verify Rendering**: Ensure components are imported and rendered
- **Check Styling**: Verify Tailwind classes are applied correctly
"
  fi

  # Add examples from successful executions
  if [ "$retry_count" -eq 1 ]; then
    refinements="$refinements
## Example of Successful Pattern
$(get_successful_pattern_example)
"
  fi

  # Combine original + refinements
  echo "$original_prompt

$refinements

## Your Mission (Retry #$retry_count)
Please carefully review the failure details above and adjust your approach accordingly.
"
}

# Get example from past successful execution
get_successful_pattern_example() {
  # Query metrics for similar successful tasks
  # Return relevant code snippet or pattern
  echo "Example: Successful file modification pattern..."
}
```

**Learning Sources**:
1. **Failure Analysis** - Parse error messages
2. **Validation Results** - Understand what was missing
3. **Metrics History** - Find similar successful executions
4. **Pattern Library** - Common solutions to common problems

---

### 4. Vision API Integration

**Purpose**: Automated visual validation using Claude Vision API

**Location**: `plugins/speclabs/lib/vision-validator.sh`

**Validation Flow**:
```
Screenshot → Vision API → Analysis → Pass/Fail + Details
```

**Implementation**:
```bash
vision_validate() {
  local session_id="$1"
  local screenshot_path="$2"
  local expected_elements="$3"  # JSON array from workflow

  echo "🔍 Analyzing screenshot with Vision API..."

  # Build Vision API prompt
  local vision_prompt="Analyze this screenshot of a web application.

## Expected Elements
$expected_elements

## Tasks
1. Check if all expected elements are present
2. Verify visual quality (styling, layout, spacing)
3. Detect any issues (broken layouts, missing text, errors)
4. Rate overall quality (0-100)

## Response Format (JSON)
{
  \"elements_present\": true/false,
  \"missing_elements\": [],
  \"visual_quality\": 0-100,
  \"issues_found\": [],
  \"suggestions\": []
}
"

  # Call Claude API with Vision
  local response=$(curl -s https://api.anthropic.com/v1/messages \
    -H "Content-Type: application/json" \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -d @- <<EOF
{
  "model": "claude-3-5-sonnet-20241022",
  "max_tokens": 1024,
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "image",
          "source": {
            "type": "base64",
            "media_type": "image/png",
            "data": "$(base64 -w 0 "$screenshot_path")"
          }
        },
        {
          "type": "text",
          "text": "$vision_prompt"
        }
      ]
    }
  ]
}
EOF
  )

  # Parse response
  local analysis=$(echo "$response" | jq -r '.content[0].text')

  # Save to state
  state_update "$session_id" "validation.vision_api" "$analysis"

  # Determine pass/fail
  local elements_present=$(echo "$analysis" | jq -r '.elements_present')
  local visual_quality=$(echo "$analysis" | jq -r '.visual_quality')

  if [ "$elements_present" == "true" ] && [ "$visual_quality" -ge 70 ]; then
    state_update "$session_id" "validation.status" '"passed"'
    echo "✅ Vision validation: PASSED (quality: $visual_quality)"
  else
    state_update "$session_id" "validation.status" '"failed"'
    echo "❌ Vision validation: FAILED (quality: $visual_quality)"
  fi
}
```

**API Key Setup**:
```bash
# User sets in environment or .env
export ANTHROPIC_API_KEY="sk-ant-..."

# Or read from ~/.config/claude-code/anthropic-api-key
```

**Validation Criteria**:
- All expected elements present: ✅/❌
- Visual quality score: 0-100
- Issues found: List
- Suggestions: List

---

### 5. Metrics Tracker

**Purpose**: Learn from executions, identify patterns, improve over time

**Location**: `plugins/speclabs/lib/metrics-tracker.sh`

**Metrics Schema**:
```json
{
  "session_id": "orch-20251016-143022",
  "timestamp": "2025-10-16T14:45:10Z",

  "task": {
    "name": "Fix Vite Config",
    "complexity": "simple",
    "workflow_file": "features/001-fix/test-workflow.md"
  },

  "execution": {
    "total_time_seconds": 900,
    "agent_time_seconds": 870,
    "validation_time_seconds": 30,
    "retry_count": 0
  },

  "results": {
    "agent_success": true,
    "validation_passed": true,
    "final_status": "success",
    "vision_quality_score": 95
  },

  "prompt": {
    "length_words": 247,
    "included_examples": false,
    "included_constraints": true,
    "effectiveness_score": 10
  }
}
```

**Functions**:
```bash
# Record execution metrics
metrics_record() {
  local session_id="$1"

  # Extract metrics from state
  local metrics=$(cat <<EOF
{
  "session_id": "$session_id",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "task": $(state_get "$session_id" "workflow"),
  "execution": $(state_get "$session_id" "metrics"),
  "results": {
    "agent_success": $(state_get "$session_id" "agent.status" | jq -r '. == "completed"'),
    "validation_passed": $(state_get "$session_id" "validation.status" | jq -r '. == "passed"'),
    "final_status": "$(state_get "$session_id" "status")"
  }
}
EOF
  )

  # Save to metrics database
  local metrics_file="/memory/orchestrator-metrics/$(date +%Y-%m).json"

  # Append to monthly metrics file
  if [ ! -f "$metrics_file" ]; then
    echo "[]" > "$metrics_file"
  fi

  jq ". += [$metrics]" "$metrics_file" > "${metrics_file}.tmp"
  mv "${metrics_file}.tmp" "$metrics_file"
}

# Analyze success patterns
metrics_analyze_success_patterns() {
  local task_type="$1"

  # Query last 30 days of metrics
  local recent_metrics=$(find /memory/orchestrator-metrics/ -name "*.json" -mtime -30 -exec cat {} \;)

  # Calculate success rate
  local total=$(echo "$recent_metrics" | jq '[.[].results.final_status] | length')
  local successes=$(echo "$recent_metrics" | jq '[.[].results.final_status] | map(select(. == "success")) | length')
  local success_rate=$(awk "BEGIN {print ($successes/$total)*100}")

  echo "Success Rate (30 days): $success_rate%"

  # Identify patterns in successful executions
  local avg_retries=$(echo "$recent_metrics" | jq '[.[].execution.retry_count] | add / length')
  local avg_time=$(echo "$recent_metrics" | jq '[.[].execution.total_time_seconds] | add / length')

  echo "Average Retries: $avg_retries"
  echo "Average Time: $avg_time seconds"
}

# Get recommendations based on history
metrics_get_recommendations() {
  local task_complexity="$1"

  # Query similar past executions
  # Return insights like:
  # - "Simple tasks succeed 95% on first try"
  # - "Complex tasks typically need 1-2 retries"
  # - "Including examples improves success rate by 15%"
}
```

**Storage**: `/memory/orchestrator-metrics/YYYY-MM.json`

**Analytics**:
- Success rates over time
- Average retry counts
- Time to completion trends
- Prompt effectiveness patterns
- Common failure modes

---

## Implementation Order

### Week 1: Foundation

**Days 1-2**: State Manager
- Create `/memory/orchestrator/` directory structure
- Implement state-manager.sh
- Test state persistence and retrieval
- Test session resume

**Days 3-4**: Decision Maker
- Implement decision-maker.sh
- Build decision tree logic
- Test all decision paths
- Test edge cases

**Day 5**: Integration
- Integrate State Manager into orchestrate-test.md
- Integrate Decision Maker into orchestrate-test.md
- Test basic retry flow
- End-to-end test

---

### Week 2: Intelligence

**Days 1-2**: Prompt Refiner
- Implement prompt-refiner.sh
- Build failure analysis logic
- Create refinement strategies
- Test with real failure scenarios

**Days 3-4**: Vision API Integration
- Implement vision-validator.sh
- Set up API key management
- Build Vision API caller
- Test screenshot analysis

**Day 5**: Metrics Tracker
- Implement metrics-tracker.sh
- Build metrics recording
- Create analytics functions
- Test metrics persistence

---

### Week 3: Integration & Testing

**Days 1-2**: Full Integration
- Wire all components together
- Update orchestrate-test.md command
- Create orchestration-coordinator.sh
- Test full flow

**Days 3-4**: Real-World Testing
- Test on tweeter-spectest project
- Test with intentional failures
- Test retry logic
- Test Vision API validation

**Day 5**: Documentation & Polish
- Update README.md
- Create user guide
- Document configuration
- Create examples

---

### Week 4 (Optional): Phase 1b Prep

**Dogfooding**: Use orchestrator for real SpecSwarm development tasks
**Bug Fixes**: Address issues found in testing
**Refinements**: Improve based on real-world usage
**Metrics Analysis**: Review success patterns

---

## Success Criteria

### Functional Requirements

- ✅ State persists to `/memory/orchestrator/`
- ✅ Sessions can be resumed after failure
- ✅ Failed agent executions trigger retry (up to 3x)
- ✅ Prompts are refined on retry
- ✅ Vision API automatically analyzes screenshots
- ✅ Metrics are tracked for all executions
- ✅ Decision maker correctly chooses action
- ✅ Human escalation triggers when max retries exceeded

### Quality Requirements

- ✅ Success rate: 90%+ (with retries)
- ✅ Retry success rate: 70%+ (2nd attempt succeeds)
- ✅ Vision API accuracy: 95%+ (vs manual review)
- ✅ State persistence: 100% reliable
- ✅ No data loss on crashes

### Performance Requirements

- ✅ State operations: <100ms
- ✅ Vision API calls: <10 seconds
- ✅ Decision making: <1 second
- ✅ Metrics recording: <100ms
- ✅ Total orchestration overhead: <30 seconds

---

## Testing Strategy

### Unit Tests

**State Manager**:
- Create session
- Update state
- Get state
- Resume session
- Handle missing sessions

**Decision Maker**:
- Success scenario
- Retry scenario (within limit)
- Escalate scenario (max retries)
- Edge cases (unknown states)

**Prompt Refiner**:
- File not found error → Path refinements
- UI missing error → Specificity refinements
- General error → Context refinements

**Vision Validator**:
- All elements present → Pass
- Missing elements → Fail
- Poor quality → Fail
- API errors → Handle gracefully

**Metrics Tracker**:
- Record metrics
- Query metrics
- Analyze patterns
- Generate recommendations

---

### Integration Tests

**Scenario 1: First-Try Success**
```
Test: Simple task that succeeds on first try
Expected: No retries, state=success, metrics recorded
```

**Scenario 2: Retry Success**
```
Test: Task that fails first, succeeds on retry
Expected: 1 retry, refined prompt used, state=success
```

**Scenario 3: Max Retries Escalation**
```
Test: Task that fails 3 times
Expected: 3 retries, state=escalated, human notified
```

**Scenario 4: Vision Validation Failure**
```
Test: Agent succeeds but UI has issues
Expected: Retry triggered, visual issues addressed
```

**Scenario 5: Resume After Crash**
```
Test: Orchestrator crashes mid-execution
Expected: State preserved, can resume session
```

---

### Real-World Tests

Use tweeter-spectest project:
1. Simple component creation (should succeed first try)
2. Complex feature (may need retry)
3. Intentionally broken workflow (should escalate)
4. Multiple sequential tasks (state management)

---

## Configuration

### Environment Variables

```bash
# Required
export ANTHROPIC_API_KEY="sk-ant-..."

# Optional (with defaults)
export ORCHESTRATOR_MAX_RETRIES=3
export ORCHESTRATOR_VISION_QUALITY_THRESHOLD=70
export ORCHESTRATOR_STATE_DIR="/memory/orchestrator"
export ORCHESTRATOR_METRICS_DIR="/memory/orchestrator-metrics"
```

### User Configuration

`/memory/orchestrator-config.json`:
```json
{
  "max_retries": 3,
  "vision_quality_threshold": 70,
  "auto_escalate": true,
  "notify_on_escalation": true,
  "track_metrics": true,
  "enable_vision_api": true
}
```

---

## Deliverables

### Code Artifacts

1. **State Manager**: `plugins/speclabs/lib/state-manager.sh`
2. **Decision Maker**: `plugins/speclabs/lib/decision-maker.sh`
3. **Prompt Refiner**: `plugins/speclabs/lib/prompt-refiner.sh`
4. **Vision Validator**: `plugins/speclabs/lib/vision-validator.sh`
5. **Metrics Tracker**: `plugins/speclabs/lib/metrics-tracker.sh`
6. **Orchestration Coordinator**: `plugins/speclabs/lib/orchestration-coordinator.sh`
7. **Updated Command**: `plugins/speclabs/commands/orchestrate-test.md`

### Documentation

1. **User Guide**: How to use the orchestrator
2. **Configuration Guide**: Setup and customization
3. **Architecture Doc**: How it works
4. **Metrics Guide**: Understanding metrics
5. **Troubleshooting Guide**: Common issues

### Test Results

1. **Unit Test Results**: All components tested
2. **Integration Test Results**: Full flow validated
3. **Real-World Test Results**: Production scenarios
4. **Success Rate Report**: Before/after comparison

---

## Risks & Mitigations

### Risk 1: Vision API Cost

**Impact**: High usage could be expensive

**Mitigation**:
- Make Vision API optional (config flag)
- Cache results for same screenshots
- Limit to final validation only
- Provide manual review option

---

### Risk 2: State Corruption

**Impact**: Lost progress, failed resumes

**Mitigation**:
- Atomic writes (write to .tmp, then mv)
- State validation on read
- Backup states before updates
- Recovery from corrupted state

---

### Risk 3: Prompt Refinement Not Effective

**Impact**: Retries don't improve success

**Mitigation**:
- Start with conservative refinements
- Learn from metrics
- Add pattern library
- Escalate faster if not improving

---

### Risk 4: Integration Complexity

**Impact**: Components don't work together

**Mitigation**:
- Build incrementally
- Test after each component
- Clear interfaces between components
- Integration tests at each step

---

## Success Metrics

We'll know Phase 1a is successful when:

1. ✅ **Success Rate**: 90%+ with retries (vs ~70% Phase 0)
2. ✅ **Retry Effectiveness**: 70%+ of retries succeed
3. ✅ **Vision Accuracy**: 95%+ vs manual review
4. ✅ **State Reliability**: 100% no data loss
5. ✅ **Dogfooding**: We use it for real work

---

## Next Steps After Phase 1a

Once Phase 1a is complete:

**Phase 1b (Month 2)**: Real-World Validation
- Dogfood on SpecSwarm development
- Alpha test with users
- Collect metrics and learnings
- Decide: proceed to Phase 2 or iterate

**Phase 2a (Months 3-4)**: Prompt Generation Core
- Build intent analyzer
- Build context gatherer
- Create pattern library
- Enable natural language input

---

## Let's Get Started!

**First Component**: State Manager (Days 1-2)

Ready to start building? 🚀

---

**Plan Created**: 2025-10-16
**Status**: Ready to Implement
**Next Action**: Begin State Manager implementation
