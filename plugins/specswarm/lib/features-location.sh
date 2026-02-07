#!/bin/bash
# features-location.sh
# Manages migration from features/ to .specswarm/features/
# Provides consistent feature directory location across all commands

# Function: get_features_dir
# Returns the correct features directory location and handles auto-migration
# Arguments: $1 = project root directory (defaults to REPO_ROOT or current directory)
# Returns: 0 on success, 1 on error
# Exports: FEATURES_DIR (absolute path to features directory)

get_features_dir() {
  local project_root="${1:-${REPO_ROOT:-$(pwd)}}"

  # Ensure we have absolute path
  if [ "${project_root:0:1}" != "/" ]; then
    project_root="$(cd "$project_root" && pwd)"
  fi

  local old_location="${project_root}/features"
  local new_location="${project_root}/.specswarm/features"

  # Check if migration needed
  if [ -d "$old_location" ] && [ ! -d "$new_location" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Migrating Features Directory"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "SpecSwarm now uses .specswarm/features/ instead of features/"
    echo ""
    echo "Benefits:"
    echo "  • No conflicts with Cucumber/Gherkin features/"
    echo "  • All SpecSwarm artifacts in one place"
    echo "  • Follows industry patterns (.github/, .vscode/)"
    echo ""
    echo "Migrating: features/ → .specswarm/features/"

    # Ensure .specswarm directory exists
    mkdir -p "${project_root}/.specswarm"

    # Move features directory
    if mv "$old_location" "$new_location" 2>/dev/null; then
      echo "✅ Migration complete!"
      echo ""
      echo "Your feature artifacts are now in: .specswarm/features/"
      echo ""

      # Count migrated features
      local feature_count=$(find "$new_location" -maxdepth 1 -type d -name '[0-9][0-9][0-9]-*' 2>/dev/null | wc -l)
      if [ "$feature_count" -gt 0 ]; then
        echo "Migrated $feature_count feature(s)"
        echo ""
      fi

      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""
    else
      echo "⚠️  Migration failed - continuing with old location"
      echo ""
      export FEATURES_DIR="$old_location"
      return 0
    fi
  fi

  # Determine which location to use
  if [ -d "$new_location" ]; then
    export FEATURES_DIR="$new_location"
  elif [ -d "$old_location" ]; then
    # Old location exists but migration wasn't triggered (both exist)
    echo ""
    echo "⚠️  WARNING: Both features/ and .specswarm/features/ exist"
    echo ""
    echo "Please consolidate:"
    echo "  1. Review both directories"
    echo "  2. Move any missing features to .specswarm/features/"
    echo "  3. Delete old features/ directory"
    echo ""
    echo "Using: .specswarm/features/ (new location)"
    echo ""
    export FEATURES_DIR="$new_location"
  else
    # Neither exists - use new location
    export FEATURES_DIR="$new_location"
  fi

  return 0
}

# Function: ensure_features_dir
# Ensures features directory exists, creating if necessary
# Arguments: $1 = project root directory (optional)
# Returns: 0 on success
# Exports: FEATURES_DIR

ensure_features_dir() {
  local project_root="${1:-${REPO_ROOT:-$(pwd)}}"

  get_features_dir "$project_root"

  if [ ! -d "$FEATURES_DIR" ]; then
    mkdir -p "$FEATURES_DIR"
  fi

  return 0
}

# Function: find_feature_dir
# Finds a specific feature directory by number
# Arguments: $1 = feature number (e.g., "001" or "1")
#            $2 = project root directory (optional)
# Returns: 0 if found, 1 if not found
# Exports: FEATURE_DIR (absolute path to specific feature)

find_feature_dir() {
  local feature_num="$1"
  local project_root="${2:-${REPO_ROOT:-$(pwd)}}"

  # Ensure features directory location is set
  get_features_dir "$project_root"

  # Pad feature number to 3 digits
  feature_num=$(printf "%03d" $feature_num 2>/dev/null || echo "$feature_num")

  # Search for feature directory
  export FEATURE_DIR=$(find "$FEATURES_DIR" -maxdepth 1 -type d -name "${feature_num}-*" 2>/dev/null | head -1)

  if [ -n "$FEATURE_DIR" ]; then
    return 0
  else
    return 1
  fi
}

# Function: get_next_feature_number
# Determines the next available feature number
# Arguments: $1 = project root directory (optional)
# Returns: Feature number (001, 002, etc.) via stdout
# Side effect: Ensures features directory exists

get_next_feature_number() {
  local project_root="${1:-${REPO_ROOT:-$(pwd)}}"

  ensure_features_dir "$project_root"

  # Find highest existing feature number
  local highest=$(find "$FEATURES_DIR" -maxdepth 1 -type d -name '[0-9][0-9][0-9]-*' 2>/dev/null | \
    sed 's/.*\/\([0-9][0-9][0-9]\)-.*/\1/' | \
    sort -n | \
    tail -1)

  if [ -z "$highest" ]; then
    echo "001"
  else
    printf "%03d" $((10#$highest + 1))
  fi
}

# Function: list_features
# Lists all feature directories
# Arguments: $1 = project root directory (optional)
# Returns: List of feature directory names (one per line) via stdout

list_features() {
  local project_root="${1:-${REPO_ROOT:-$(pwd)}}"

  get_features_dir "$project_root"

  if [ -d "$FEATURES_DIR" ]; then
    find "$FEATURES_DIR" -maxdepth 1 -type d -name '[0-9][0-9][0-9]-*' 2>/dev/null | \
      sort | \
      xargs -n1 basename 2>/dev/null
  fi
}
