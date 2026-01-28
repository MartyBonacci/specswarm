#!/bin/bash
# SpecSwarm Stop Hook
# Prevents unwanted pauses during /specswarm:build workflow
# Inspired by Ralph Wiggum plugin's autonomous loop pattern
# Enhanced with checkpoint support for Claude Code 2.1.0

set -e

# Find repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
STATE_FILE="${REPO_ROOT}/.specswarm/build-loop.state"
CHECKPOINTS_DIR="${REPO_ROOT}/.specswarm/checkpoints"

# Exit early if no build is active (zero overhead when not building)
if [ ! -f "$STATE_FILE" ]; then
  # No build active - allow normal exit
  echo '{"decision": "approve"}'
  exit 0
fi

# Function to create checkpoint after phase completion
create_checkpoint() {
  local feature_num=$1
  local phase=$2
  local feature_dir=$3

  if [ -z "$feature_dir" ] || [ ! -d "$feature_dir" ]; then
    return 0
  fi

  local checkpoint_dir="$CHECKPOINTS_DIR/$feature_num"
  local timestamp=$(date +%s)
  local checkpoint_path="$checkpoint_dir/${phase}-${timestamp}"

  mkdir -p "$checkpoint_path"

  # Copy current feature state
  cp -r "$feature_dir"/* "$checkpoint_path/" 2>/dev/null || true

  # Update manifest
  local manifest_file="$checkpoint_dir/manifest.json"
  if [ ! -f "$manifest_file" ]; then
    echo "[]" > "$manifest_file"
  fi

  if command -v jq &> /dev/null; then
    jq --arg phase "$phase" --arg ts "$(date -Iseconds)" \
       '. += [{"phase": $phase, "timestamp": $ts}]' \
       "$manifest_file" > "${manifest_file}.tmp" 2>/dev/null
    mv "${manifest_file}.tmp" "$manifest_file" 2>/dev/null || true
  fi
}

# Read state file
if ! command -v jq &> /dev/null; then
  # jq not available - allow exit (degraded mode)
  echo '{"decision": "approve", "reason": "jq not available - stop hook disabled"}'
  exit 0
fi

# Parse state
ACTIVE=$(jq -r '.active' "$STATE_FILE" 2>/dev/null || echo "false")
if [ "$ACTIVE" != "true" ]; then
  # Build not active - allow exit
  echo '{"decision": "approve"}'
  exit 0
fi

CURRENT_PHASE=$(jq -r '.current_phase' "$STATE_FILE")
FEATURE_DESC=$(jq -r '.feature_description' "$STATE_FILE")
FEATURE_NUM=$(jq -r '.feature_num' "$STATE_FILE")
QUALITY_THRESHOLD=$(jq -r '.quality_threshold' "$STATE_FILE")
RUN_VALIDATE=$(jq -r '.run_validate' "$STATE_FILE")

# Find features directory
FEATURES_DIR="${REPO_ROOT}/.specswarm/features"
if [ ! -d "$FEATURES_DIR" ]; then
  FEATURES_DIR="${REPO_ROOT}/features"
fi

# Find feature directory
FEATURE_DIR=$(find "$FEATURES_DIR" -maxdepth 1 -type d -name "${FEATURE_NUM}-*" 2>/dev/null | head -1)

# If feature directory doesn't exist yet, we're still in early phases - allow execution
if [ -z "$FEATURE_DIR" ] || [ ! -d "$FEATURE_DIR" ]; then
  echo '{"decision": "approve"}'
  exit 0
fi

# Determine next phase based on current phase completion
NEXT_PHASE=""

case "$CURRENT_PHASE" in
  "specify")
    # Check if spec.md exists
    if [ -f "${FEATURE_DIR}/spec.md" ]; then
      # Create checkpoint after specify phase
      create_checkpoint "$FEATURE_NUM" "specify" "$FEATURE_DIR"
      NEXT_PHASE="clarify"
    fi
    ;;

  "clarify")
    # Check if spec has been updated with clarifications
    # Look for "## Clarifications" section or completion marker
    if grep -q "## Clarifications" "${FEATURE_DIR}/spec.md" 2>/dev/null || \
       grep -q "No clarifications needed" "${FEATURE_DIR}/spec.md" 2>/dev/null; then
      # Create checkpoint after clarify phase
      create_checkpoint "$FEATURE_NUM" "clarify" "$FEATURE_DIR"
      NEXT_PHASE="plan"
    fi
    ;;

  "plan")
    # Check if plan.md exists
    if [ -f "${FEATURE_DIR}/plan.md" ]; then
      # Create checkpoint after plan phase
      create_checkpoint "$FEATURE_NUM" "plan" "$FEATURE_DIR"
      NEXT_PHASE="tasks"
    fi
    ;;

  "tasks")
    # Check if tasks.md exists
    if [ -f "${FEATURE_DIR}/tasks.md" ]; then
      # Create checkpoint after tasks phase
      create_checkpoint "$FEATURE_NUM" "tasks" "$FEATURE_DIR"
      NEXT_PHASE="implement"
    fi
    ;;

  "implement")
    # Check if tasks are completed (look for completion marker)
    if grep -q "## Summary" "${FEATURE_DIR}/tasks.md" 2>/dev/null || \
       grep -q "All tasks completed" "${FEATURE_DIR}/tasks.md" 2>/dev/null; then
      # Create checkpoint after implement phase
      create_checkpoint "$FEATURE_NUM" "implement" "$FEATURE_DIR"
      # Check if validation is requested
      if [ "$RUN_VALIDATE" = "true" ]; then
        NEXT_PHASE="validate"
      else
        NEXT_PHASE="analyze-quality"
      fi
    fi
    ;;

  "validate")
    # Validation complete, move to quality analysis
    NEXT_PHASE="analyze-quality"
    ;;

  "analyze-quality")
    # Check if quality report exists
    QUALITY_REPORT="${FEATURE_DIR}/quality-report.json"
    if [ -f "$QUALITY_REPORT" ]; then
      # Read quality score
      QUALITY_SCORE=$(jq -r '.overall_score // 0' "$QUALITY_REPORT" 2>/dev/null || echo "0")

      # Compare with threshold
      if [ "$QUALITY_SCORE" -ge "$QUALITY_THRESHOLD" ]; then
        # Quality gate passed - build complete!
        rm -f "$STATE_FILE"

        # Return success message and allow exit
        jq -n \
          --arg desc "$FEATURE_DESC" \
          --argjson score "$QUALITY_SCORE" \
          '{
            "decision": "approve",
            "reason": ("✅ Build Complete: " + $desc + "\n\nQuality Score: " + ($score | tostring) + "% - Ready to ship!"),
            "systemMessage": "🎉 Build phase complete!"
          }'
        exit 0
      else
        # Quality too low - need to improve
        NEXT_PHASE="fix-quality"
      fi
    fi
    ;;

  "fix-quality")
    # After fixing issues, re-run quality analysis
    NEXT_PHASE="analyze-quality"
    ;;

  *)
    # Unknown phase - allow exit
    echo '{"decision": "approve", "reason": "Unknown phase: '"$CURRENT_PHASE"'"}'
    exit 0
    ;;
esac

# If no next phase determined, stay in current phase (allow execution)
if [ -z "$NEXT_PHASE" ]; then
  echo '{"decision": "approve"}'
  exit 0
fi

# Update state file with next phase
jq --arg phase "$NEXT_PHASE" '.current_phase = $phase' "$STATE_FILE" > "${STATE_FILE}.tmp"
mv "${STATE_FILE}.tmp" "$STATE_FILE"

# Block exit and feed next phase prompt
PHASE_DISPLAY=$(echo "$NEXT_PHASE" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')

jq -n \
  --arg phase "$NEXT_PHASE" \
  --arg display "$PHASE_DISPLAY" \
  --arg desc "$FEATURE_DESC" \
  '{
    "decision": "block",
    "reason": ("SpecSwarm Build: " + $desc + "\n\n🔄 Moving to next phase: " + $display + "\n\nContinuing automatically..."),
    "systemMessage": ("🔄 Build Phase: " + $display)
  }'

exit 0
