#!/bin/bash
# BUILD Command Pattern Detection
# Natural language patterns for detecting BUILD workflow intent

# Primary trigger words (50 points each)
PRIMARY_TRIGGERS=(
  "build"
  "create"
  "add"
  "develop"
  "implement"
  "make"
)

# Secondary trigger words (30 points each)
SECONDARY_TRIGGERS=(
  "new feature"
  "new"
)

# Phrase patterns (30 points each)
# These are regex patterns that match common BUILD phrases
PHRASE_PATTERNS=(
  "^i need "
  "^can you "
  "^let'?s "
  "^we need "
  " to (build|create|add|develop|implement)"
)

# Conflicting words that reduce score (subtract 20 points each)
# These indicate the user might want a different command
CONFLICTING_WORDS=(
  "fix"
  "bug"
  "broken"
  "error"
  "issue"
  "problem"
  "ship"
  "deploy"
  "merge"
  "upgrade"
  "update"
  "migrate"
)

# Context boosters (add 10 points each)
# Words that increase confidence this is a BUILD command
CONTEXT_BOOSTERS=(
  "feature"
  "functionality"
  "system"
  "module"
  "component"
  "integration"
  "authentication"
  "payment"
  "dashboard"
  "api"
  "endpoint"
)

# High confidence phrases (95+ points automatically)
HIGH_CONFIDENCE_PHRASES=(
  "^build "
  "^create "
  "^add "
  "^implement "
  "^develop "
  "^make a "
  "^make an "
)

# Export all arrays for use by dispatcher
export PRIMARY_TRIGGERS
export SECONDARY_TRIGGERS
export PHRASE_PATTERNS
export CONFLICTING_WORDS
export CONTEXT_BOOSTERS
export HIGH_CONFIDENCE_PHRASES
