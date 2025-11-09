#!/bin/bash
# lib/detect-project-type.sh
# Detects software project type based on file patterns and configurations

# Detect project type with confidence scoring
detect_project_type() {
  local project_path="$1"
  local detected_types=()
  local confidence_scores=()

  # Normalize project path
  project_path="${project_path:-.}"

  # Validate project path exists
  if [ ! -d "$project_path" ]; then
    echo '{"primary_type":"unknown","confidence":0,"error":"Project path does not exist"}' >&2
    return 1
  fi

  # Web Application Detection
  if [ -f "$project_path/package.json" ]; then
    local has_dev_script=$(jq -r '.scripts.dev // .scripts.start // "null"' "$project_path/package.json" 2>/dev/null)
    if [ "$has_dev_script" != "null" ]; then
      detected_types+=("webapp")

      # Calculate confidence
      local confidence=50

      # Check for common webapp indicators
      [ -f "$project_path/vite.config.js" ] || [ -f "$project_path/vite.config.ts" ] && confidence=$((confidence + 15))
      [ -f "$project_path/next.config.js" ] || [ -f "$project_path/next.config.mjs" ] && confidence=$((confidence + 15))
      [ -f "$project_path/index.html" ] && confidence=$((confidence + 10))
      [ -d "$project_path/.react-router" ] && confidence=$((confidence + 15))
      [ -d "$project_path/src" ] && confidence=$((confidence + 5))
      [ -d "$project_path/public" ] && confidence=$((confidence + 5))

      # Cap at 95 (never 100% certain without running)
      [ $confidence -gt 95 ] && confidence=95

      confidence_scores+=($confidence)
    fi
  fi

  # Android App Detection
  if [ -f "$project_path/app/src/main/AndroidManifest.xml" ] || \
     [ -f "$project_path/AndroidManifest.xml" ]; then
    detected_types+=("android")

    local confidence=60
    [ -f "$project_path/build.gradle" ] || [ -f "$project_path/app/build.gradle" ] && confidence=90
    [ -f "$project_path/settings.gradle" ] && confidence=$((confidence + 5))

    # Cap at 95
    [ $confidence -gt 95 ] && confidence=95

    confidence_scores+=($confidence)
  fi

  # REST API Detection
  if [ -f "$project_path/openapi.yaml" ] || \
     [ -f "$project_path/openapi.json" ] || \
     [ -f "$project_path/swagger.yaml" ] || \
     [ -f "$project_path/swagger.json" ]; then
    detected_types+=("rest-api")
    local confidence=90

    # Check for API server frameworks
    if [ -f "$project_path/package.json" ]; then
      grep -q '"express"\|"fastify"\|"koa"' "$project_path/package.json" 2>/dev/null && confidence=95
    fi

    confidence_scores+=($confidence)
  elif [ -f "$project_path/package.json" ]; then
    # Check for API frameworks without OpenAPI spec
    if grep -q '"express"\|"fastapi"\|"koa"' "$project_path/package.json" 2>/dev/null; then
      detected_types+=("rest-api")
      confidence_scores+=(70)
    fi
  elif [ -f "$project_path/requirements.txt" ] || [ -f "$project_path/pyproject.toml" ]; then
    # Check for Python API frameworks
    if grep -q 'flask\|fastapi\|django' "$project_path/requirements.txt" 2>/dev/null || \
       grep -q 'flask\|fastapi\|django' "$project_path/pyproject.toml" 2>/dev/null; then
      detected_types+=("rest-api")
      confidence_scores+=(70)
    fi
  fi

  # Desktop GUI Detection
  if [ -f "$project_path/package.json" ]; then
    if grep -q '"electron"' "$project_path/package.json" 2>/dev/null; then
      detected_types+=("desktop-gui")
      confidence_scores+=(85)
    fi
  fi

  # Python GUI Detection
  if [ -f "$project_path/pyproject.toml" ]; then
    if grep -q 'tkinter\|PyQt\|PySide' "$project_path/pyproject.toml" 2>/dev/null; then
      detected_types+=("desktop-gui")
      confidence_scores+=(75)
    fi
  fi

  # Handle no detection
  if [ ${#detected_types[@]} -eq 0 ]; then
    echo '{"primary_type":"unknown","confidence":0,"all_detected":[],"message":"No recognized project type detected"}'
    return 1
  fi

  # Find highest confidence type
  local max_confidence=0
  local primary_type=""
  local primary_index=0

  for i in "${!detected_types[@]}"; do
    if [ ${confidence_scores[$i]} -gt $max_confidence ]; then
      max_confidence=${confidence_scores[$i]}
      primary_type=${detected_types[$i]}
      primary_index=$i
    fi
  done

  # Build all_detected array as JSON
  local all_detected_json="["
  for i in "${!detected_types[@]}"; do
    if [ $i -gt 0 ]; then
      all_detected_json+=","
    fi
    all_detected_json+="{\"type\":\"${detected_types[$i]}\",\"confidence\":${confidence_scores[$i]}}"
  done
  all_detected_json+="]"

  # Build and output final JSON result
  jq -n \
    --arg primary_type "$primary_type" \
    --argjson confidence "$max_confidence" \
    --argjson all_detected "$all_detected_json" \
    '{
      "primary_type": $primary_type,
      "confidence": $confidence,
      "all_detected": $all_detected
    }'

  return 0
}

# Get just the primary type (for simple usage)
get_primary_type() {
  local project_path="$1"
  detect_project_type "$project_path" | jq -r '.primary_type'
}

# Get confidence score
get_confidence() {
  local project_path="$1"
  detect_project_type "$project_path" | jq -r '.confidence'
}

# Check if confidence is acceptable (>= 60%)
is_confident() {
  local project_path="$1"
  local confidence=$(get_confidence "$project_path")
  [ "$confidence" -ge 60 ]
}
