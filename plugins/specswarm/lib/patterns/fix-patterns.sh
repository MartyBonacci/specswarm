#!/bin/bash
# FIX Command Pattern Detection
# Natural language patterns for detecting FIX workflow intent

# Primary trigger words (50 points each)
PRIMARY_TRIGGERS=(
  "fix"
  "bug"
  "broken"
  "error"
  "issue"
  "problem"
  "fails"
)

# Secondary trigger words (30 points each)
SECONDARY_TRIGGERS=(
  "doesn't"
  "don't"
  "not"
)

# Phrase patterns (45 points each - boosted for better detection)
# These are regex patterns that match common FIX phrases
PHRASE_PATTERNS=(
  "doesn'?t work"
  "don'?t work"
  "not working"
  "^there'?s (a |an )?(bug|issue|problem|error)"
  "^getting (an? )?(error|issue)"
  "^(having|experiencing) (a |an )?(bug|issue|problem|error)"
  " (fails|failing)"
  "^(fix|repair|resolve) "
  " in "  # "bug in checkout", "error in login"
)

# Conflicting words that reduce score (subtract 20 points each)
# These indicate the user might want a different command
CONFLICTING_WORDS=(
  "build"
  "create"
  "add"
  "new"
  "ship"
  "deploy"
  "merge"
  "upgrade"
  "update"
  "migrate"
)

# Context boosters (add 10 points each)
# Words that increase confidence this is a FIX command
CONTEXT_BOOSTERS=(
  "crash"
  "crashing"
  "exception"
  "failure"
  "regression"
  "regression"
  "breaking"
  "breaks"
  "incorrect"
  "wrong"
  "unexpected"
)

# High confidence phrases (95+ points automatically)
HIGH_CONFIDENCE_PHRASES=(
  "^fix "
  "^there'?s (a |an )?(bug|error|issue)"
  " is broken"
  " are broken"
  " broken$"
  "doesn'?t work"
  "don'?t work"
  "^getting .* error"
)

# Export all arrays for use by dispatcher
export PRIMARY_TRIGGERS
export SECONDARY_TRIGGERS
export PHRASE_PATTERNS
export CONFLICTING_WORDS
export CONTEXT_BOOSTERS
export HIGH_CONFIDENCE_PHRASES
