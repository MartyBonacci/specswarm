#!/bin/bash
# SpecSwarm Setup Hook
# Automatically initializes .specswarm/ directory when Claude Code runs maintenance
# Triggered via --init, --init-only, or --maintenance CLI flags

set -e

# Find repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
SPECSWARM_DIR="${REPO_ROOT}/.specswarm"

# Check if already initialized
if [ -d "$SPECSWARM_DIR" ]; then
  # Already initialized - check for required files
  MISSING_FILES=()

  [ ! -f "$SPECSWARM_DIR/constitution.md" ] && MISSING_FILES+=("constitution.md")
  [ ! -f "$SPECSWARM_DIR/tech-stack.md" ] && MISSING_FILES+=("tech-stack.md")
  [ ! -f "$SPECSWARM_DIR/quality-standards.md" ] && MISSING_FILES+=("quality-standards.md")

  if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo '{"decision": "approve", "systemMessage": "SpecSwarm partially initialized. Run /specswarm:init for full setup. Missing: '"$(IFS=,; echo "${MISSING_FILES[*]}")"'"}'
  else
    echo '{"decision": "approve", "reason": "SpecSwarm already fully initialized"}'
  fi
  exit 0
fi

# Auto-initialize - create minimal directory structure
mkdir -p "$SPECSWARM_DIR"
mkdir -p "$SPECSWARM_DIR/features"
mkdir -p "$SPECSWARM_DIR/checkpoints"

# Create a setup marker file
cat > "$SPECSWARM_DIR/.setup-marker" << EOF
{
  "auto_initialized": true,
  "initialized_at": "$(date -Iseconds 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S%z")",
  "requires_full_init": true,
  "version": "3.8.0"
}
EOF

# Return success with helpful message
cat << EOF
{
  "decision": "approve",
  "systemMessage": "SpecSwarm auto-initialized at ${SPECSWARM_DIR}. Run /specswarm:init for full configuration (constitution, tech-stack, quality-standards)."
}
EOF

exit 0
