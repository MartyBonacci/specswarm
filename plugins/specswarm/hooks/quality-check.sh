#!/bin/bash
# SpecSwarm PostToolUse Quality Hook
# Runs lint/typecheck after every file write during active builds
# Designed for <2 second execution to avoid editor lag

set -e

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
STATE_FILE="${REPO_ROOT}/.specswarm/build-loop.state"

# Only run during active builds (zero overhead otherwise)
if [ ! -f "$STATE_FILE" ]; then
  echo '{"decision": "approve"}'
  exit 0
fi

# Parse the tool event from stdin
TOOL_INPUT=$(cat)
TOOL_NAME=$(echo "$TOOL_INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)

# Only act on file-writing tools
case "$TOOL_NAME" in
  Edit|MultiEdit|Write) ;;
  *) echo '{"decision": "approve"}'; exit 0 ;;
esac

# Skip non-source files
case "$FILE_PATH" in
  *.md|*.json|*.yaml|*.yml|*.txt|*.csv|*.log|*.lock)
    echo '{"decision": "approve"}'
    exit 0
    ;;
  */node_modules/*|*/.git/*|*/dist/*|*/build/*|*/.specswarm/*)
    echo '{"decision": "approve"}'
    exit 0
    ;;
esac

# Skip if file doesn't exist (was deleted or path is empty)
if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  echo '{"decision": "approve"}'
  exit 0
fi

cd "$REPO_ROOT"

ISSUES=""

# Detect and run the project's linter (fast path only)
run_lint() {
  local file="$1"
  local ext="${file##*.}"

  case "$ext" in
    ts|tsx|js|jsx|mjs|cjs)
      # Prefer biome (fastest), then eslint
      if [ -f "biome.json" ] || [ -f "biome.jsonc" ]; then
        if command -v biome &>/dev/null; then
          LINT_OUT=$(biome check "$file" 2>&1) || ISSUES="$LINT_OUT"
        elif npx --no-install biome --version &>/dev/null 2>&1; then
          LINT_OUT=$(npx --no-install biome check "$file" 2>&1) || ISSUES="$LINT_OUT"
        fi
      elif [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] || [ -f ".eslintrc.yml" ] || [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ]; then
        if npx --no-install eslint --version &>/dev/null 2>&1; then
          LINT_OUT=$(npx --no-install eslint --no-warn-ignored "$file" 2>&1) || ISSUES="$LINT_OUT"
        fi
      fi
      ;;
    py)
      if command -v ruff &>/dev/null; then
        LINT_OUT=$(ruff check "$file" 2>&1) || ISSUES="$LINT_OUT"
      elif command -v flake8 &>/dev/null; then
        LINT_OUT=$(flake8 "$file" 2>&1) || ISSUES="$LINT_OUT"
      fi
      ;;
    go)
      if command -v go &>/dev/null; then
        LINT_OUT=$(go vet "$file" 2>&1) || ISSUES="$LINT_OUT"
      fi
      ;;
    rb)
      if command -v rubocop &>/dev/null; then
        LINT_OUT=$(rubocop --format simple "$file" 2>&1) || ISSUES="$LINT_OUT"
      fi
      ;;
    rs)
      # Rust: clippy is too slow for per-file, skip
      ;;
  esac
}

# Detect and run typecheck (TypeScript only, fast single-file check)
run_typecheck() {
  local file="$1"
  local ext="${file##*.}"

  case "$ext" in
    ts|tsx)
      if [ -f "tsconfig.json" ] && npx --no-install tsc --version &>/dev/null 2>&1; then
        # Use --noEmit for type-checking only, limited to the changed file's project
        TC_OUT=$(npx --no-install tsc --noEmit --pretty false 2>&1 | grep -F "$file" 2>/dev/null) || true
        if [ -n "$TC_OUT" ]; then
          if [ -n "$ISSUES" ]; then
            ISSUES="$ISSUES\n\nTypeCheck:\n$TC_OUT"
          else
            ISSUES="TypeCheck:\n$TC_OUT"
          fi
        fi
      fi
      ;;
  esac
}

# Run checks with a timeout to prevent lag (2 second max)
timeout 2 bash -c "$(declare -f run_lint); run_lint '$FILE_PATH'" 2>/dev/null || true
timeout 2 bash -c "$(declare -f run_typecheck); run_typecheck '$FILE_PATH'" 2>/dev/null || true

# Log to audit file if audit logging is enabled
AUDIT_FILE="${REPO_ROOT}/.specswarm/audit.jsonl"
if [ -f "$AUDIT_FILE" ] || [ -d "${REPO_ROOT}/.specswarm" ]; then
  TIMESTAMP=$(date -Iseconds 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S%z")
  HAS_ISSUES=$( [ -n "$ISSUES" ] && echo "true" || echo "false" )
  jq -n -c \
    --arg ts "$TIMESTAMP" \
    --arg event "quality_check" \
    --arg file "$FILE_PATH" \
    --arg tool "$TOOL_NAME" \
    --argjson issues "$HAS_ISSUES" \
    '{timestamp: $ts, event: $event, file: $file, tool: $tool, has_issues: $issues}' \
    >> "$AUDIT_FILE" 2>/dev/null || true
fi

# Return result
if [ -n "$ISSUES" ]; then
  # Truncate long output to keep response manageable
  TRUNCATED=$(echo -e "$ISSUES" | head -20)
  jq -n \
    --arg issues "$TRUNCATED" \
    '{
      "decision": "approve",
      "systemMessage": ("⚠️ Quality issues detected:\n" + $issues + "\n\nFix these before continuing.")
    }'
else
  echo '{"decision": "approve"}'
fi

exit 0
