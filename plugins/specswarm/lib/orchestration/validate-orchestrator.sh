#!/bin/bash
# lib/validate-feature-orchestrator.sh
# Generic orchestrator that detects project type and delegates to appropriate validator

# Get the plugin directory
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source required libraries
source "${PLUGIN_DIR}/lib/detect-project-type.sh"
source "${PLUGIN_DIR}/lib/validator-interface.sh"

# Main orchestration function
validate_feature_orchestrate() {
  local project_path=""
  local session_id=""
  local type_override="auto"
  local flows_file=""
  local config_file=""
  local url=""
  local device=""
  local spec_file=""

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --project-path)
        project_path="$2"
        shift 2
        ;;
      --session-id)
        session_id="$2"
        shift 2
        ;;
      --type)
        type_override="$2"
        shift 2
        ;;
      --flows)
        flows_file="$2"
        shift 2
        ;;
      --config)
        config_file="$2"
        shift 2
        ;;
      --url)
        url="$2"
        shift 2
        ;;
      --device)
        device="$2"
        shift 2
        ;;
      --spec)
        spec_file="$2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done

  # Default project path to current directory
  project_path="${project_path:-.}"

  # Normalize to absolute path
  project_path="$(cd "$project_path" 2>/dev/null && pwd)"
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Project path does not exist: $project_path" >&2
    create_error_result "unknown" "Project path does not exist: $project_path"
    return 1
  fi

  echo "🔍 Validating project: $project_path"

  # 1. Detect or use override
  local detected_type
  local confidence
  local detection_start=$(date +%s)

  if [ "$type_override" = "auto" ]; then
    echo "   Detecting project type..."
    local detection_result=$(detect_project_type "$project_path")

    if [ $? -ne 0 ]; then
      echo "❌ ERROR: Could not detect project type" >&2
      create_error_result "unknown" "Could not detect project type"
      return 1
    fi

    detected_type=$(echo "$detection_result" | jq -r '.primary_type')
    confidence=$(echo "$detection_result" | jq -r '.confidence')

    echo "   ✅ Detected type: $detected_type (confidence: ${confidence}%)"

    # Warn if low confidence
    if [ "$confidence" -lt 60 ]; then
      echo "   ⚠️  Low confidence (${confidence}%) - detected as '$detected_type'"
      echo "      Consider using --type to specify explicitly"
    fi
  else
    detected_type="$type_override"
    confidence=100
    echo "   ✅ Using specified type: $detected_type"
  fi

  # 2. Validate type is supported
  case "$detected_type" in
    webapp|android|rest-api|desktop-gui)
      # Type is valid
      ;;
    *)
      echo "❌ ERROR: Unsupported type: $detected_type" >&2
      echo "   Supported types: webapp, android, rest-api, desktop-gui" >&2
      create_error_result "$detected_type" "Unsupported project type: $detected_type"
      return 1
      ;;
  esac

  # 3. Select validator script path
  local validator_script="${PLUGIN_DIR}/lib/validators/validate-${detected_type}.sh"

  # 4. Check if validator exists
  if [ ! -f "$validator_script" ]; then
    echo "❌ ERROR: Validator not implemented: validate-${detected_type}.sh" >&2
    echo "   The $detected_type validator has not been implemented yet." >&2
    echo "   Available validators: webapp" >&2
    create_error_result "$detected_type" "Validator not implemented: validate-${detected_type}.sh"
    return 1
  fi

  # 5. Source the validator
  echo "   Loading $detected_type validator..."
  source "$validator_script"

  # 6. Build validator arguments
  local validator_args=(
    --project-path "$project_path"
    --type "$detected_type"
  )

  [ -n "$session_id" ] && validator_args+=(--session-id "$session_id")
  [ -n "$flows_file" ] && validator_args+=(--flows "$flows_file")
  [ -n "$config_file" ] && validator_args+=(--config "$config_file")
  [ -n "$url" ] && validator_args+=(--url "$url")
  [ -n "$device" ] && validator_args+=(--device "$device")
  [ -n "$spec_file" ] && validator_args+=(--spec "$spec_file")

  # 7. Execute validator
  echo "   🚀 Starting validation..."
  echo ""

  local validation_start=$(date +%s)
  local validation_result

  validation_result=$(validate_execute "${validator_args[@]}")
  local validator_exit_code=$?

  local validation_end=$(date +%s)
  local total_duration=$((validation_end - detection_start))

  # 8. Check validator executed successfully
  if [ $validator_exit_code -ne 0 ]; then
    echo "" >&2
    echo "❌ ERROR: Validator failed to execute" >&2
    create_error_result "$detected_type" "Validator execution failed with exit code $validator_exit_code"
    return 1
  fi

  # 9. Validate result schema
  if ! validate_result_schema "$validation_result"; then
    echo "❌ ERROR: Validator returned invalid result format" >&2
    create_error_result "$detected_type" "Validator returned invalid result format"
    return 1
  fi

  # 10. Add orchestrator metadata
  local enriched_result=$(echo "$validation_result" | jq \
    --argjson total_duration "$total_duration" \
    --arg detected_type "$detected_type" \
    --argjson confidence "$confidence" \
    '.metadata.orchestrator = {
      "detected_type": $detected_type,
      "detection_confidence": $confidence,
      "total_duration_seconds": $total_duration,
      "orchestrator_version": "1.0.0"
    }')

  # 11. Return enriched result
  echo "$enriched_result"
  return 0
}

# Helper: Print validation summary
print_validation_summary() {
  local validation_result="$1"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  VALIDATION SUMMARY"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  local status=$(echo "$validation_result" | jq -r '.status')
  local type=$(echo "$validation_result" | jq -r '.type')
  local total_flows=$(echo "$validation_result" | jq -r '.summary.total_flows')
  local passed_flows=$(echo "$validation_result" | jq -r '.summary.passed_flows')
  local failed_flows=$(echo "$validation_result" | jq -r '.summary.failed_flows')
  local error_count=$(echo "$validation_result" | jq -r '.summary.error_count')
  local duration=$(echo "$validation_result" | jq -r '.metadata.duration_seconds')

  echo "  Type: $type"
  echo "  Status: $status"
  echo "  Duration: ${duration}s"
  echo ""
  echo "  Flows: $passed_flows/$total_flows passed"

  if [ "$error_count" -gt 0 ]; then
    echo "  Errors: $error_count found"
  fi

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Print errors if any
  if [ "$error_count" -gt 0 ]; then
    echo ""
    echo "Errors detected:"
    echo "$validation_result" | jq -r '.errors[] | "  • [\(.severity | ascii_upcase)] \(.message) (\(.location))"'
  fi

  # Print artifacts if any
  local artifacts=$(echo "$validation_result" | jq -r '.artifacts | length')
  if [ "$artifacts" -gt 0 ]; then
    echo ""
    echo "Artifacts:"
    echo "$validation_result" | jq -r '.artifacts[] | "  • \(.type): \(.path)"'
  fi

  echo ""
}
