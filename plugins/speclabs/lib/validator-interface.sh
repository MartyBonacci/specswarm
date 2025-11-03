#!/bin/bash
# lib/validator-interface.sh
# Defines the contract that ALL validators must implement

# Interface version (for compatibility checking)
VALIDATOR_INTERFACE_VERSION="1.0.0"

# Standard function signature that all validators MUST implement
#
# REQUIRED PARAMETERS (via named args):
#   --project-path <absolute_path>  : Path to project root
#   --session-id <id>               : Optional session ID for tracking
#   --type <software_type>          : webapp|android|rest-api|desktop-gui
#
# OPTIONAL PARAMETERS:
#   --flows <flows.json>            : Path to flows file (AI + user-defined)
#   --config <config.json>          : Validator-specific configuration
#   --url <url>                     : Target URL (webapp) or API base URL
#   --device <device_name>          : Android device name (android)
#   --spec <spec_file>              : OpenAPI spec path (rest-api)
#
# RETURN VALUE:
#   JSON object matching VALIDATOR_RESULT_SCHEMA (see below)
#   Exit code: 0 = success (even if validation failed), 1 = validator error
#
validate_execute() {
  echo "❌ ERROR: Validator must implement validate_execute() function" >&2
  echo "   This function should parse arguments and execute validation" >&2
  return 1
}

# Standard result schema (JSON)
# All validators MUST return JSON matching this structure
VALIDATOR_RESULT_SCHEMA='
{
  "status": "passed|failed|error",
  "type": "webapp|android|rest-api|desktop-gui",
  "summary": {
    "total_flows": <number>,
    "passed_flows": <number>,
    "failed_flows": <number>,
    "error_count": <number>
  },
  "errors": [
    {
      "type": "console|exception|network|assertion|step-failure",
      "message": "<error message>",
      "location": "<file:line or flow:step>",
      "severity": "critical|high|medium|low"
    }
  ],
  "artifacts": [
    {
      "type": "screenshot|log|report|video",
      "path": "<absolute_path>",
      "description": "<optional description>"
    }
  ],
  "metadata": {
    "duration_seconds": <number>,
    "validator_version": "<version>",
    "tool": "<playwright|appium|newman|etc>",
    "tool_version": "<version>",
    "additional": { /* validator-specific metadata */ }
  }
}
'

# Validation helper: Check if result matches schema
validate_result_schema() {
  local result_json="$1"

  # Check required top-level fields
  local has_status=$(echo "$result_json" | jq 'has("status")' 2>/dev/null)
  local has_type=$(echo "$result_json" | jq 'has("type")' 2>/dev/null)
  local has_summary=$(echo "$result_json" | jq 'has("summary")' 2>/dev/null)
  local has_errors=$(echo "$result_json" | jq 'has("errors")' 2>/dev/null)
  local has_artifacts=$(echo "$result_json" | jq 'has("artifacts")' 2>/dev/null)
  local has_metadata=$(echo "$result_json" | jq 'has("metadata")' 2>/dev/null)

  if [ "$has_status" = "true" ] && \
     [ "$has_type" = "true" ] && \
     [ "$has_summary" = "true" ] && \
     [ "$has_errors" = "true" ] && \
     [ "$has_artifacts" = "true" ] && \
     [ "$has_metadata" = "true" ]; then
    return 0
  else
    echo "❌ Validator result does not match interface schema" >&2
    echo "   Missing required fields - status, type, summary, errors, artifacts, or metadata" >&2
    return 1
  fi
}

# Helper: Create a basic error result when validator fails to execute
create_error_result() {
  local type="$1"
  local error_message="$2"

  jq -n \
    --arg type "$type" \
    --arg error_message "$error_message" \
    '{
      "status": "error",
      "type": $type,
      "summary": {
        "total_flows": 0,
        "passed_flows": 0,
        "failed_flows": 0,
        "error_count": 1
      },
      "errors": [
        {
          "type": "exception",
          "message": $error_message,
          "location": "validator-setup",
          "severity": "critical"
        }
      ],
      "artifacts": [],
      "metadata": {
        "duration_seconds": 0,
        "validator_version": "unknown",
        "tool": "unknown",
        "tool_version": "unknown"
      }
    }'
}
