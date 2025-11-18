#!/bin/bash
# SHIP Command Pattern Detection
# Natural language patterns for detecting SHIP workflow intent
#
# ⚠️ CRITICAL SAFETY REQUIREMENT:
# SHIP commands ALWAYS require explicit user confirmation
# regardless of confidence level. See natural-language-dispatcher.sh
# for enforcement logic.

# Primary trigger words (50 points each)
PRIMARY_TRIGGERS=(
  "ship"
  "deploy"
  "merge"
  "complete"
  "finish"
  "done"
  "ready"
)

# Secondary trigger words (30 points each)
SECONDARY_TRIGGERS=(
  "push"
  "release"
  "publish"
)

# Phrase patterns (30 points each)
# These are regex patterns that match common SHIP phrases
PHRASE_PATTERNS=(
  "^ship it"
  "^ship this"
  "^deploy (this|it|to)"
  "^merge (this|it|to)"
  "^i'?m done"
  "^ready to (merge|deploy|ship)"
  "^complete (this|the) feature"
  "^finish (this|it) up"
)

# Conflicting words that reduce score (subtract 20 points each)
# These indicate the user might want a different command
CONFLICTING_WORDS=(
  "build"
  "create"
  "add"
  "fix"
  "bug"
  "broken"
  "upgrade"
  "update"
)

# Context boosters (add 10 points each)
# Words that increase confidence this is a SHIP command
CONTEXT_BOOSTERS=(
  "production"
  "main"
  "master"
  "release"
  "finished"
  "completed"
  "tested"
  "validated"
  "approved"
)

# High confidence phrases (95+ points automatically)
# NOTE: Despite high confidence, SHIP ALWAYS requires confirmation
HIGH_CONFIDENCE_PHRASES=(
  "^ship "
  "^deploy "
  "^merge "
  "^ready to "
  "^i'?m done"
  "^complete "
  " the .* fix$"  # "ship the bugfix"
)

# Export all arrays for use by dispatcher
export PRIMARY_TRIGGERS
export SECONDARY_TRIGGERS
export PHRASE_PATTERNS
export CONFLICTING_WORDS
export CONTEXT_BOOSTERS
export HIGH_CONFIDENCE_PHRASES
