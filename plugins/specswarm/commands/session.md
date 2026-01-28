---
description: Manage SpecSwarm sessions - export, import, or teleport for collaborative workflows
args:
  - name: action
    description: Action to perform (export, import, teleport, list)
    required: true
  - name: --feature
    description: Feature number to export (e.g., 001)
    required: false
  - name: --file
    description: File path for export/import
    required: false
  - name: --include-code
    description: Include code changes in export (creates larger bundle)
    required: false
  - name: --session-id
    description: Specific session ID to export
    required: false
---

## User Input

```text
$ARGUMENTS
```

## Goal

Manage SpecSwarm session portability for:
- **Export**: Save session state to file for sharing or backup
- **Import**: Load session state from file
- **Teleport**: Send session to claude.ai/code for handoff
- **List**: Show exportable sessions

**Purpose**: Enable collaborative workflows, cross-device development, and session backup/restore.

---

## Implementation

```bash
#!/bin/bash

echo "🔄 SpecSwarm Session Manager"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
SESSIONS_DIR="${REPO_ROOT}/.specswarm/sessions"
FEATURES_DIR="${REPO_ROOT}/.specswarm/features"
EXPORTS_DIR="${REPO_ROOT}/.specswarm/exports"

# Fallback directories
if [ ! -d "$FEATURES_DIR" ]; then
  FEATURES_DIR="${REPO_ROOT}/features"
fi

# Parse arguments
ACTION=""
FEATURE_NUM=""
FILE_PATH=""
INCLUDE_CODE=false
SESSION_ID=""

for arg in $ARGUMENTS; do
  if [ "${arg:0:2}" != "--" ] && [ -z "$ACTION" ]; then
    ACTION="$arg"
  elif [ "$arg" = "--feature" ]; then
    shift
    FEATURE_NUM="$1"
  elif [ "$arg" = "--file" ]; then
    shift
    FILE_PATH="$1"
  elif [ "$arg" = "--include-code" ]; then
    INCLUDE_CODE=true
  elif [ "$arg" = "--session-id" ]; then
    shift
    SESSION_ID="$1"
  fi
done

# Validate action
if [ -z "$ACTION" ]; then
  echo "❌ Error: Action required"
  echo ""
  echo "Usage: /specswarm:session <action> [options]"
  echo ""
  echo "Actions:"
  echo "  list              List exportable sessions and features"
  echo "  export            Export session/feature to file"
  echo "  import            Import session/feature from file"
  echo "  teleport          Send session to claude.ai/code"
  echo ""
  echo "Options:"
  echo "  --feature <num>   Feature number (e.g., 001)"
  echo "  --file <path>     File path for export/import"
  echo "  --include-code    Include code changes (larger export)"
  echo "  --session-id <id> Specific session ID"
  echo ""
  echo "Examples:"
  echo "  /specswarm:session list"
  echo "  /specswarm:session export --feature 001"
  echo "  /specswarm:session export --feature 001 --include-code --file backup.tar.gz"
  echo "  /specswarm:session import --file backup.tar.gz"
  echo "  /specswarm:session teleport --feature 001"
  exit 1
fi

# Ensure directories exist
mkdir -p "$SESSIONS_DIR"
mkdir -p "$EXPORTS_DIR"

# Function to list sessions
list_sessions() {
  echo "📋 Exportable Sessions"
  echo ""

  # List features
  echo "Features:"
  if [ -d "$FEATURES_DIR" ]; then
    for feature_dir in "$FEATURES_DIR"/[0-9][0-9][0-9]-*/; do
      if [ -d "$feature_dir" ]; then
        local feature_name=$(basename "$feature_dir")
        local has_spec=$([ -f "$feature_dir/spec.md" ] && echo "✓" || echo "✗")
        local has_plan=$([ -f "$feature_dir/plan.md" ] && echo "✓" || echo "✗")
        local has_tasks=$([ -f "$feature_dir/tasks.md" ] && echo "✓" || echo "✗")
        echo "  $feature_name [spec:$has_spec plan:$has_plan tasks:$has_tasks]"
      fi
    done
  else
    echo "  (no features found)"
  fi
  echo ""

  # List active sessions
  echo "Active Sessions:"
  if [ -f "${REPO_ROOT}/.specswarm/build-loop.state" ]; then
    if command -v jq &> /dev/null; then
      local session_id=$(jq -r '.session_id' "${REPO_ROOT}/.specswarm/build-loop.state")
      local feature_desc=$(jq -r '.feature_description' "${REPO_ROOT}/.specswarm/build-loop.state")
      local phase=$(jq -r '.current_phase' "${REPO_ROOT}/.specswarm/build-loop.state")
      echo "  🔄 $session_id (phase: $phase)"
      echo "     $feature_desc"
    fi
  fi

  if [ -d "$SESSIONS_DIR" ]; then
    for session_file in "$SESSIONS_DIR"/*.json; do
      if [ -f "$session_file" ]; then
        local session_name=$(basename "$session_file" .json)
        if command -v jq &> /dev/null; then
          local status=$(jq -r '.status // "unknown"' "$session_file")
          echo "  $session_name ($status)"
        else
          echo "  $session_name"
        fi
      fi
    done
  fi
  echo ""

  # List existing exports
  echo "Existing Exports:"
  if [ -d "$EXPORTS_DIR" ] && [ "$(ls -A "$EXPORTS_DIR" 2>/dev/null)" ]; then
    ls -la "$EXPORTS_DIR"/*.tar.gz 2>/dev/null | while read line; do
      echo "  $line"
    done
  else
    echo "  (no exports found)"
  fi
}

# Function to export session/feature
export_session() {
  local feature_num=$1
  local file_path=$2
  local include_code=$3

  if [ -z "$feature_num" ]; then
    echo "❌ Error: --feature required for export"
    exit 1
  fi

  # Find feature directory
  local feature_dir=$(find "$FEATURES_DIR" -maxdepth 1 -type d -name "${feature_num}-*" 2>/dev/null | head -1)

  if [ -z "$feature_dir" ] || [ ! -d "$feature_dir" ]; then
    echo "❌ Error: Feature directory not found for $feature_num"
    exit 1
  fi

  local feature_name=$(basename "$feature_dir")

  # Default export file path
  if [ -z "$file_path" ]; then
    file_path="${EXPORTS_DIR}/${feature_name}-$(date +%Y%m%d-%H%M%S).tar.gz"
  fi

  echo "📦 Exporting feature: $feature_name"
  echo ""

  # Create temp directory for export
  local temp_dir=$(mktemp -d)
  local export_dir="$temp_dir/$feature_name"
  mkdir -p "$export_dir"

  # Copy feature artifacts
  echo "  Copying feature artifacts..."
  cp -r "$feature_dir"/* "$export_dir/"

  # Copy related session data
  if [ -d "$SESSIONS_DIR" ]; then
    mkdir -p "$export_dir/.sessions"
    cp "$SESSIONS_DIR"/*${feature_num}*.json "$export_dir/.sessions/" 2>/dev/null || true
  fi

  # Copy checkpoints
  local checkpoint_dir="${REPO_ROOT}/.specswarm/checkpoints/$feature_num"
  if [ -d "$checkpoint_dir" ]; then
    echo "  Copying checkpoints..."
    mkdir -p "$export_dir/.checkpoints"
    cp -r "$checkpoint_dir"/* "$export_dir/.checkpoints/"
  fi

  # Include code changes if requested
  if [ "$include_code" = true ]; then
    echo "  Including code changes (this may take a moment)..."

    # Get git diff for the feature branch
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    local main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

    mkdir -p "$export_dir/.code"

    # Save git diff
    git diff "$main_branch"..."$current_branch" > "$export_dir/.code/changes.diff" 2>/dev/null || true

    # Save list of changed files
    git diff --name-only "$main_branch"..."$current_branch" > "$export_dir/.code/changed-files.txt" 2>/dev/null || true

    # Save branch info
    cat > "$export_dir/.code/branch-info.json" << EOF
{
  "current_branch": "$current_branch",
  "main_branch": "$main_branch",
  "exported_at": "$(date -Iseconds)"
}
EOF
  fi

  # Create export metadata
  cat > "$export_dir/.export-metadata.json" << EOF
{
  "feature_num": "$feature_num",
  "feature_name": "$feature_name",
  "exported_at": "$(date -Iseconds)",
  "specswarm_version": "3.8.0",
  "include_code": $include_code,
  "repo_root": "$REPO_ROOT"
}
EOF

  # Create tarball
  echo "  Creating archive..."
  tar -czf "$file_path" -C "$temp_dir" "$feature_name"

  # Cleanup
  rm -rf "$temp_dir"

  echo ""
  echo "✅ Export complete"
  echo ""
  echo "Exported to: $file_path"
  echo "Size: $(du -h "$file_path" | cut -f1)"
  echo ""
  echo "Import on another machine with:"
  echo "  /specswarm:session import --file $file_path"
}

# Function to import session/feature
import_session() {
  local file_path=$1

  if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
    echo "❌ Error: --file required and must exist for import"
    exit 1
  fi

  echo "📥 Importing from: $file_path"
  echo ""

  # Create temp directory for extraction
  local temp_dir=$(mktemp -d)

  # Extract archive
  tar -xzf "$file_path" -C "$temp_dir"

  # Find extracted directory
  local extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d ! -name "$(basename "$temp_dir")" | head -1)

  if [ -z "$extracted_dir" ]; then
    echo "❌ Error: Invalid export archive"
    rm -rf "$temp_dir"
    exit 1
  fi

  local feature_name=$(basename "$extracted_dir")

  # Read metadata
  if [ -f "$extracted_dir/.export-metadata.json" ] && command -v jq &> /dev/null; then
    local feature_num=$(jq -r '.feature_num' "$extracted_dir/.export-metadata.json")
    local exported_at=$(jq -r '.exported_at' "$extracted_dir/.export-metadata.json")
    echo "Feature: $feature_name"
    echo "Exported: $exported_at"
    echo ""
  fi

  # Check for conflicts
  local target_dir="$FEATURES_DIR/$feature_name"
  if [ -d "$target_dir" ]; then
    echo "⚠️  Feature already exists: $target_dir"
    echo ""
    read -p "Overwrite? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
      echo "Import cancelled."
      rm -rf "$temp_dir"
      exit 0
    fi
    rm -rf "$target_dir"
  fi

  # Import feature artifacts
  echo "  Importing feature artifacts..."
  mkdir -p "$FEATURES_DIR"
  cp -r "$extracted_dir" "$target_dir"

  # Remove metadata files from target
  rm -f "$target_dir/.export-metadata.json"

  # Import sessions
  if [ -d "$extracted_dir/.sessions" ]; then
    echo "  Importing session data..."
    cp "$extracted_dir/.sessions"/*.json "$SESSIONS_DIR/" 2>/dev/null || true
    rm -rf "$target_dir/.sessions"
  fi

  # Import checkpoints
  if [ -d "$extracted_dir/.checkpoints" ]; then
    echo "  Importing checkpoints..."
    local checkpoint_dir="${REPO_ROOT}/.specswarm/checkpoints/$feature_num"
    mkdir -p "$checkpoint_dir"
    cp -r "$extracted_dir/.checkpoints"/* "$checkpoint_dir/"
    rm -rf "$target_dir/.checkpoints"
  fi

  # Apply code changes if present
  if [ -d "$extracted_dir/.code" ]; then
    echo ""
    echo "📝 Code changes detected in export"
    echo ""
    if [ -f "$extracted_dir/.code/changes.diff" ]; then
      local line_count=$(wc -l < "$extracted_dir/.code/changes.diff")
      echo "  Changes: $line_count lines of diff"

      read -p "Apply code changes? (y/N): " apply_code
      if [ "$apply_code" = "y" ] || [ "$apply_code" = "Y" ]; then
        echo "  Applying changes..."
        git apply "$extracted_dir/.code/changes.diff" 2>&1 || echo "  ⚠️  Some changes could not be applied"
      else
        echo "  Skipping code changes (diff saved to $target_dir/.code/)"
        mkdir -p "$target_dir/.code"
        cp "$extracted_dir/.code"/* "$target_dir/.code/"
      fi
    fi
    rm -rf "$target_dir/.code"
  fi

  # Cleanup
  rm -rf "$temp_dir"

  echo ""
  echo "✅ Import complete"
  echo ""
  echo "Feature imported to: $target_dir"
  echo ""
  echo "Continue working with:"
  echo "  /specswarm:build (to resume build)"
  echo "  /specswarm:status (to check session status)"
}

# Function to teleport session
teleport_session() {
  local feature_num=$1

  if [ -z "$feature_num" ]; then
    echo "❌ Error: --feature required for teleport"
    exit 1
  fi

  echo "🚀 Teleport Session"
  echo ""
  echo "This will prepare your session for handoff to claude.ai/code"
  echo ""

  # First export the session
  local temp_export="${EXPORTS_DIR}/teleport-${feature_num}-$(date +%Y%m%d-%H%M%S).tar.gz"
  export_session "$feature_num" "$temp_export" "true"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📡 Teleport Instructions"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "1. Run '/teleport' in Claude Code to send this session"
  echo ""
  echo "2. Or manually transfer the export file:"
  echo "   $temp_export"
  echo ""
  echo "3. On the target machine, run:"
  echo "   /specswarm:session import --file <path-to-export>"
  echo ""
  echo "The exported session includes:"
  echo "  ✓ Feature specification"
  echo "  ✓ Implementation plan"
  echo "  ✓ Task breakdown"
  echo "  ✓ Session state"
  echo "  ✓ Checkpoints"
  echo "  ✓ Code changes (as git diff)"
}

# Execute action
case "$ACTION" in
  list)
    list_sessions
    ;;
  export)
    export_session "$FEATURE_NUM" "$FILE_PATH" "$INCLUDE_CODE"
    ;;
  import)
    import_session "$FILE_PATH"
    ;;
  teleport)
    teleport_session "$FEATURE_NUM"
    ;;
  *)
    echo "❌ Error: Unknown action '$ACTION'"
    echo ""
    echo "Valid actions: list, export, import, teleport"
    exit 1
    ;;
esac
```

---

## Usage Examples

### List All Sessions
```bash
/specswarm:session list
```

### Export Feature for Backup
```bash
/specswarm:session export --feature 001
```

### Export with Code Changes
```bash
/specswarm:session export --feature 001 --include-code
```

### Import from File
```bash
/specswarm:session import --file ./backup.tar.gz
```

### Teleport to Another Machine
```bash
/specswarm:session teleport --feature 001
```

---

## Export Contents

Exports include:
- `spec.md` - Feature specification
- `plan.md` - Implementation plan
- `tasks.md` - Task breakdown
- `.sessions/` - Session tracking data
- `.checkpoints/` - Saved checkpoints
- `.code/` - Code changes (with --include-code)
- `.export-metadata.json` - Export metadata

---

## Notes

- Exports are stored in `.specswarm/exports/`
- Code changes are exported as git diffs
- Import handles conflict detection automatically
- Use `/teleport` for seamless Claude Code handoff
