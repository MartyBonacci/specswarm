#!/bin/bash
# UPGRADE Command Pattern Detection
# Natural language patterns for detecting UPGRADE workflow intent

# Primary trigger words (50 points each)
PRIMARY_TRIGGERS=(
  "upgrade"
  "update"
  "migrate"
  "modernize"
)

# Secondary trigger words (30 points each)
SECONDARY_TRIGGERS=(
  "refactor to"
  "switch to"
  "move to"
)

# Phrase patterns (30 points each)
# These are regex patterns that match common UPGRADE phrases
PHRASE_PATTERNS=(
  "^(upgrade|update) (to|from)"
  "^migrate from .* to "
  " from .* to "
  "^modernize "
  "^refactor to "
  "^switch to "
  "^move to "
)

# Conflicting words that reduce score (subtract 20 points each)
# These indicate the user might want a different command
CONFLICTING_WORDS=(
  "build"
  "create"
  "add"
  "new"
  "fix"
  "bug"
  "broken"
  "ship"
  "deploy"
)

# Context boosters (add 10 points each)
# Words that increase confidence this is an UPGRADE command
CONTEXT_BOOSTERS=(
  "version"
  "latest"
  "dependencies"
  "framework"
  "library"
  "typescript"
  "react"
  "node"
  "python"
  "postgres"
  "database"
)

# High confidence phrases (95+ points automatically)
HIGH_CONFIDENCE_PHRASES=(
  "^upgrade to "
  "^update to "
  "^migrate from .* to "
  "^modernize "
  "^refactor to "
)

# Export all arrays for use by dispatcher
export PRIMARY_TRIGGERS
export SECONDARY_TRIGGERS
export PHRASE_PATTERNS
export CONFLICTING_WORDS
export CONTEXT_BOOSTERS
export HIGH_CONFIDENCE_PHRASES
