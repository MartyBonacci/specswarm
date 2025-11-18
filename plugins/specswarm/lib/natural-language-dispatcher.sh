#!/bin/bash
# Natural Language Command Dispatcher
# Detects user intent from natural language input and dispatches to appropriate command
#
# Version: v3.3.0
# Safety: SHIP commands ALWAYS require explicit confirmation

# Get the directory where this script is located
DISPATCHER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERNS_DIR="${DISPATCHER_DIR}/patterns"

# Normalize user input for better matching
# Converts to lowercase, preserves apostrophes for patterns, collapses spaces
normalize_input() {
  local input="$1"
  echo "$input" | \
    tr '[:upper:]' '[:lower:]' | \
    sed "s/[^a-z0-9 ']/ /g" | \
    sed 's/  */ /g' | \
    sed 's/^ //; s/ $//'
}

# Score a command based on pattern matching
# Args: $1 = normalized input, $2 = command name (build|fix|ship|upgrade)
# Returns: score (0-100+)
score_command() {
  local input="$1"
  local command="$2"
  local score=0

  # Load patterns for this command
  if [ ! -f "${PATTERNS_DIR}/${command}-patterns.sh" ]; then
    echo "0"
    return
  fi

  # Source the pattern file (sets arrays: PRIMARY_TRIGGERS, SECONDARY_TRIGGERS, etc.)
  source "${PATTERNS_DIR}/${command}-patterns.sh"

  # Check for high confidence phrases first (auto 95+ points)
  if [ -n "${HIGH_CONFIDENCE_PHRASES:-}" ]; then
    for pattern in "${HIGH_CONFIDENCE_PHRASES[@]}"; do
      if echo "$input" | grep -qE "$pattern"; then
        score=$((score + 95))
        break
      fi
    done
  fi

  # Check for primary trigger words (50 points each)
  if [ -n "${PRIMARY_TRIGGERS:-}" ]; then
    for trigger in "${PRIMARY_TRIGGERS[@]}"; do
      if echo "$input" | grep -qE "\b$trigger\b"; then
        score=$((score + 50))
      fi
    done
  fi

  # Check for secondary trigger words (30 points each)
  if [ -n "${SECONDARY_TRIGGERS:-}" ]; then
    for trigger in "${SECONDARY_TRIGGERS[@]}"; do
      if echo "$input" | grep -qE "$trigger"; then
        score=$((score + 30))
      fi
    done
  fi

  # Check for phrase patterns (45 points each - boosted)
  if [ -n "${PHRASE_PATTERNS:-}" ]; then
    for pattern in "${PHRASE_PATTERNS[@]}"; do
      if echo "$input" | grep -qE "$pattern"; then
        score=$((score + 45))
      fi
    done
  fi

  # Add context boosters (10 points each)
  if [ -n "${CONTEXT_BOOSTERS:-}" ]; then
    for booster in "${CONTEXT_BOOSTERS[@]}"; do
      if echo "$input" | grep -qE "\b$booster\b"; then
        score=$((score + 10))
      fi
    done
  fi

  # Subtract points for conflicting indicators (20 points each)
  if [ -n "${CONFLICTING_WORDS:-}" ]; then
    for conflict in "${CONFLICTING_WORDS[@]}"; do
      if echo "$input" | grep -qE "\b$conflict\b"; then
        score=$((score - 20))
      fi
    done
  fi

  # Ensure score doesn't go negative
  [ $score -lt 0 ] && score=0

  echo "$score"
}

# Detect workflow from user input
# Args: $1 = user input (raw)
# Returns: "command:confidence:score" or "none:low:0" if no match
detect_workflow() {
  local user_input="$1"
  local normalized=$(normalize_input "$user_input")

  # Score each command
  local build_score=$(score_command "$normalized" "build")
  local fix_score=$(score_command "$normalized" "fix")
  local ship_score=$(score_command "$normalized" "ship")
  local upgrade_score=$(score_command "$normalized" "upgrade")

  # Find highest score
  local max_score=0
  local detected_command=""

  if [ "$build_score" -gt "$max_score" ]; then
    max_score=$build_score
    detected_command="build"
  fi

  if [ "$fix_score" -gt "$max_score" ]; then
    max_score=$fix_score
    detected_command="fix"
  fi

  if [ "$ship_score" -gt "$max_score" ]; then
    max_score=$ship_score
    detected_command="ship"
  fi

  if [ "$upgrade_score" -gt "$max_score" ]; then
    max_score=$upgrade_score
    detected_command="upgrade"
  fi

  # Determine confidence level based on score
  local confidence
  if [ "$max_score" -ge 95 ]; then
    confidence="high"
  elif [ "$max_score" -ge 70 ]; then
    confidence="medium"
  elif [ "$max_score" -ge 50 ]; then
    confidence="low"
  else
    confidence="none"
    detected_command="none"
  fi

  echo "${detected_command}:${confidence}:${max_score}"
}

# Get parent branch for current feature
# Used by SHIP confirmation to show merge target
get_parent_branch() {
  local repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
  local current_branch=$(git branch --show-current 2>/dev/null)

  # Try to read parent branch from spec.md
  if [ -n "$current_branch" ]; then
    local feature_dir=$(find "${repo_root}/.specswarm/features" -maxdepth 1 -type d -name "*-*" 2>/dev/null | head -1)
    if [ -d "$feature_dir" ] && [ -f "$feature_dir/spec.md" ]; then
      local parent=$(grep "^parent_branch:" "$feature_dir/spec.md" 2>/dev/null | sed 's/parent_branch: *//')
      if [ -n "$parent" ]; then
        echo "$parent"
        return
      fi
    fi
  fi

  # Fallback to MAIN_BRANCH or default
  if [ -n "${MAIN_BRANCH:-}" ]; then
    echo "$MAIN_BRANCH"
  else
    echo "main"
  fi
}

# Show command options when detection fails or is ambiguous
show_command_options() {
  echo ""
  echo "I can help! What would you like to do?"
  echo ""
  echo "  1. Build a new feature (/specswarm:specify)"
  echo "  2. Fix a bug (/specswarm:bugfix)"
  echo "  3. Upgrade technology (/specswarm:upgrade)"
  echo "  4. Ship completed work (/specswarm:complete)"
  echo ""
  echo "Or use a specific command directly:"
  echo "  /specswarm:specify \"feature description\""
  echo "  /specswarm:bugfix \"bug description\""
  echo ""
}

# Execute detected command with appropriate safety checks
# Args: $1 = user input (raw), $2 = detection result (command:confidence:score)
execute_nl_command() {
  local user_input="$1"
  local detection_result="$2"

  local command=$(echo "$detection_result" | cut -d: -f1)
  local confidence=$(echo "$detection_result" | cut -d: -f2)
  local score=$(echo "$detection_result" | cut -d: -f3)

  # Handle no detection or very low confidence
  if [ "$command" = "none" ] || [ "$confidence" = "none" ]; then
    echo "🤔 I'm not sure what you want to do."
    show_command_options
    return 1
  fi

  # ⚠️ CRITICAL: SHIP command ALWAYS requires confirmation
  if [ "$command" = "ship" ]; then
    echo "🎯 Detected: SHIP workflow (${confidence} confidence, score: ${score})"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  SHIP COMMAND CONFIRMATION REQUIRED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "This will:"
    echo "  • Run quality validation"
    echo "  • Create git commit"
    echo "  • Merge to parent branch"
    echo "  • Mark feature as complete"
    echo ""

    local current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    local parent_branch=$(get_parent_branch)

    echo "Current branch: $current_branch"
    echo "Merge target: $parent_branch"
    echo ""

    read -p "Are you sure you want to ship this feature? (yes/no): " confirm
    echo ""

    if [ "$confirm" != "yes" ] && [ "$confirm" != "y" ]; then
      echo "❌ SHIP command cancelled"
      echo ""
      return 1
    fi

    echo "✅ Confirmed. Starting SHIP workflow..."
    echo ""

    # Execute the ship command (high-level orchestrator)
    claude slash "/specswarm:ship"
    return 0
  fi

  # Map commands to actual slash commands
  local slash_command
  case "$command" in
    "build")
      slash_command="/specswarm:build"
      ;;
    "fix")
      slash_command="/specswarm:fix"
      ;;
    "upgrade")
      slash_command="/specswarm:upgrade"
      ;;
    *)
      echo "⚠️  Unknown command: $command"
      show_command_options
      return 1
      ;;
  esac

  # Execute based on confidence level
  if [ "$confidence" = "high" ]; then
    # High confidence - execute with 3-second cancel window
    echo "🎯 Detected: ${command^^} workflow (${confidence} confidence, score: ${score})"
    echo ""
    echo "Running: $slash_command \"${user_input}\""
    echo ""
    echo "Press Ctrl+C within 3 seconds to cancel..."

    # 3-second cancellable delay
    for i in 3 2 1; do
      echo -n "$i... "
      sleep 1
    done
    echo ""
    echo ""

    # Execute the command
    claude slash "$slash_command" "$user_input"
    return 0

  elif [ "$confidence" = "medium" ]; then
    # Medium confidence - ask for confirmation
    echo "🤔 I think you want to ${command^^} (${confidence} confidence, score: ${score})"
    echo ""
    read -p "Is this correct? (y/n): " confirm
    echo ""

    if [ "$confirm" = "y" ] || [ "$confirm" = "yes" ]; then
      echo "✅ Starting ${command^^} workflow..."
      echo ""
      claude slash "$slash_command" "$user_input"
      return 0
    else
      echo "Let me help you choose:"
      show_command_options
      return 1
    fi

  elif [ "$confidence" = "low" ]; then
    # Low confidence - show options
    echo "🤔 Detected possible ${command^^} workflow, but confidence is low (score: ${score})"
    echo ""
    show_command_options
    return 1
  fi
}

# Main dispatcher function
# This is the entry point called by command files
dispatch_natural_language() {
  local user_input="$1"

  # Detect workflow
  local detection_result=$(detect_workflow "$user_input")

  # Execute with appropriate safety checks
  execute_nl_command "$user_input" "$detection_result"
}

# Export functions for use by command files
export -f normalize_input
export -f score_command
export -f detect_workflow
export -f get_parent_branch
export -f show_command_options
export -f execute_nl_command
export -f dispatch_natural_language
