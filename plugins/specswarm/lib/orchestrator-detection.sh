#!/bin/bash

# Orchestrator Detection Heuristics
# Purpose: Detect when to use Project Orchestrator for complex debugging/development workflows
# Based on: docs/learnings/2025-10-14-orchestrator-missed-opportunity.md

# Function: should_use_orchestrator
# Returns: 0 (true) if orchestrator should be used, 1 (false) otherwise
# Outputs: JSON recommendation to stdout
#
# Usage:
#   should_use_orchestrator <bug_count> <file_list> <context_info>
#
# Example:
#   RESULT=$(should_use_orchestrator 5 "app/file1.tsx src/server/file2.ts" "requires_logging requires_server_restarts")
#   if [ $? -eq 0 ]; then
#     echo "Orchestrator recommended!"
#   fi

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
    if echo "$context_info" | grep -qE "requires_server_restarts|requires_logging"; then
        complex_coordination_signal=1
    fi

    # Decision logic
    local signal_count=$((multi_bug_signal + multi_domain_signal + high_context_signal + complex_coordination_signal))

    # Strong recommendation: 3+ signals OR core criteria (bugs + domains)
    if [ "$signal_count" -ge 3 ]; then
        recommendation="orchestrator"
        confidence="high"
        reason="Multiple bugs ($bug_count) across different domains ($domain_count) with complex coordination"
    elif [ "$signal_count" -ge 2 ] && [ "$multi_bug_signal" -eq 1 ] && [ "$multi_domain_signal" -eq 1 ]; then
        recommendation="orchestrator"
        confidence="high"
        reason="$bug_count bugs across $domain_count domains (textbook orchestration case)"
    elif [ "$signal_count" -ge 2 ]; then
        recommendation="consider_orchestrator"
        confidence="medium"
        reason="Significant complexity detected ($signal_count signals)"
    fi

    # Output recommendation as JSON
    if [ "$recommendation" = "orchestrator" ]; then
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
    "complex_coordination": $complex_coordination_signal,
    "total_signals": $signal_count
  },
  "benefits": {
    "estimated_time_savings": "40-60%",
    "parallel_investigation": true,
    "better_context_management": true,
    "coordinated_restarts": true
  }
}
EOF
        return 0
    elif [ "$recommendation" = "consider_orchestrator" ]; then
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
    "complex_coordination": $complex_coordination_signal,
    "total_signals": $signal_count
  }
}
EOF
        return 0
    else
        return 1
    fi
}

# Helper: Detect unique domains from file list
# Returns: Count of unique domains detected
#
# Domains:
#   - backend: Server-side code, APIs, middleware
#   - frontend: React components, pages, UI
#   - database: Types, schemas, migrations
#   - testing: Test files, specs
#   - config: Configuration files
detect_domains() {
    local files="$1"
    local domains=""

    # Backend indicators
    if echo "$files" | grep -qE '\.(ts|js).*server|src/server|api/|middleware/|routes/|controllers/'; then
        domains="$domains backend"
    fi

    # Frontend indicators
    if echo "$files" | grep -qE 'app/|components/|pages/|views/|\.(tsx|jsx)'; then
        domains="$domains frontend"
    fi

    # Database indicators
    if echo "$files" | grep -qE 'types/.*\.ts|schema|migrations/|db/|models/'; then
        domains="$domains database"
    fi

    # Testing indicators
    if echo "$files" | grep -qE 'test/|spec\.|\.test\.|\.spec\.|__tests__/'; then
        domains="$domains testing"
    fi

    # Config indicators
    if echo "$files" | grep -qE 'vite\.config|tsconfig|webpack|babel|package\.json|\.env'; then
        domains="$domains config"
    fi

    # Count unique domains
    echo "$domains" | tr ' ' '\n' | sort -u | grep -v '^$' | wc -l
}

# Helper: Get domain names (for display purposes)
# Returns: Space-separated list of domain names
get_domain_names() {
    local files="$1"
    local domains=""

    # Backend indicators
    if echo "$files" | grep -qE '\.(ts|js).*server|src/server|api/|middleware/|routes/|controllers/'; then
        domains="$domains backend"
    fi

    # Frontend indicators
    if echo "$files" | grep -qE 'app/|components/|pages/|views/|\.(tsx|jsx)'; then
        domains="$domains frontend"
    fi

    # Database indicators
    if echo "$files" | grep -qE 'types/.*\.ts|schema|migrations/|db/|models/'; then
        domains="$domains database"
    fi

    # Testing indicators
    if echo "$files" | grep -qE 'test/|spec\.|\.test\.|\.spec\.|__tests__/'; then
        domains="$domains testing"
    fi

    # Config indicators
    if echo "$files" | grep -qE 'vite\.config|tsconfig|webpack|babel|package\.json|\.env'; then
        domains="$domains config"
    fi

    # Return unique domains
    echo "$domains" | tr ' ' '\n' | sort -u | grep -v '^$' | tr '\n' ' '
}

# Export functions
export -f should_use_orchestrator
export -f detect_domains
export -f get_domain_names
