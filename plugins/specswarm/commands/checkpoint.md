---
description: Manage build checkpoints - list, restore, or delete saved workflow states
args:
  - name: action
    description: Action to perform (list, restore, delete, create)
    required: true
  - name: --feature
    description: Feature number (e.g., 001)
    required: false
  - name: --phase
    description: Phase to restore to (e.g., plan, tasks, implement)
    required: false
  - name: --all
    description: Apply action to all checkpoints (use with delete)
    required: false
---

## User Input

```text
$ARGUMENTS
```

## Goal

Manage checkpoints for SpecSwarm workflows. Checkpoints save progress after each phase, enabling:
- **Rollback**: Restore to a previous state if something goes wrong
- **Experimentation**: Try different approaches and rollback if needed
- **Recovery**: Resume interrupted builds from last good state

---

## Implementation

```bash
#!/bin/bash

echo "🔖 SpecSwarm Checkpoint Manager"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
CHECKPOINTS_DIR="${REPO_ROOT}/.specswarm/checkpoints"
FEATURES_DIR="${REPO_ROOT}/.specswarm/features"

# Fallback to features/ if .specswarm/features doesn't exist
if [ ! -d "$FEATURES_DIR" ]; then
  FEATURES_DIR="${REPO_ROOT}/features"
fi

# Parse arguments
ACTION=""
FEATURE_NUM=""
PHASE=""
ALL_FLAG=false

for arg in $ARGUMENTS; do
  if [ "${arg:0:2}" != "--" ] && [ -z "$ACTION" ]; then
    ACTION="$arg"
  elif [ "$arg" = "--feature" ]; then
    shift
    FEATURE_NUM="$1"
  elif [ "$arg" = "--phase" ]; then
    shift
    PHASE="$1"
  elif [ "$arg" = "--all" ]; then
    ALL_FLAG=true
  fi
done

# Validate action
if [ -z "$ACTION" ]; then
  echo "❌ Error: Action required"
  echo ""
  echo "Usage: /specswarm:checkpoint <action> [options]"
  echo ""
  echo "Actions:"
  echo "  list              List all checkpoints"
  echo "  restore           Restore to a checkpoint"
  echo "  delete            Delete checkpoints"
  echo "  create            Manually create a checkpoint"
  echo ""
  echo "Options:"
  echo "  --feature <num>   Feature number (e.g., 001)"
  echo "  --phase <name>    Phase name (e.g., plan, tasks)"
  echo "  --all             Apply to all (delete only)"
  echo ""
  echo "Examples:"
  echo "  /specswarm:checkpoint list"
  echo "  /specswarm:checkpoint list --feature 001"
  echo "  /specswarm:checkpoint restore --feature 001 --phase plan"
  echo "  /specswarm:checkpoint delete --feature 001 --phase implement"
  echo "  /specswarm:checkpoint delete --all"
  exit 1
fi

# Ensure checkpoints directory exists
mkdir -p "$CHECKPOINTS_DIR"

# Function to list checkpoints
list_checkpoints() {
  local feature_filter=$1

  echo "📋 Available Checkpoints"
  echo ""

  if [ ! -d "$CHECKPOINTS_DIR" ] || [ -z "$(ls -A "$CHECKPOINTS_DIR" 2>/dev/null)" ]; then
    echo "ℹ️  No checkpoints found"
    echo ""
    echo "Checkpoints are created automatically during /specswarm:build"
    echo "after each phase completes (specify, clarify, plan, tasks, implement)."
    return 0
  fi

  # List features with checkpoints
  for feature_dir in "$CHECKPOINTS_DIR"/*/; do
    if [ ! -d "$feature_dir" ]; then
      continue
    fi

    local feature_name=$(basename "$feature_dir")

    # Filter by feature if specified
    if [ -n "$feature_filter" ] && [ "$feature_name" != "$feature_filter" ]; then
      continue
    fi

    echo "┌─────────────────────────────────────────────"
    echo "│ Feature: $feature_name"
    echo "├─────────────────────────────────────────────"

    # List checkpoints for this feature
    if [ -f "$feature_dir/manifest.json" ]; then
      if command -v jq &> /dev/null; then
        jq -r '.[] | "│ \(.phase): \(.timestamp)"' "$feature_dir/manifest.json" 2>/dev/null
      else
        cat "$feature_dir/manifest.json"
      fi
    else
      # List by directory
      for checkpoint in "$feature_dir"/*; do
        if [ -d "$checkpoint" ]; then
          local phase=$(basename "$checkpoint" | sed 's/-[0-9]*$//')
          local timestamp=$(basename "$checkpoint" | grep -oE '[0-9]+$')
          echo "│ $phase: $(date -d @$timestamp 2>/dev/null || echo $timestamp)"
        fi
      done
    fi

    echo "└─────────────────────────────────────────────"
    echo ""
  done
}

# Function to create checkpoint
create_checkpoint() {
  local feature_num=$1
  local phase=$2

  if [ -z "$feature_num" ]; then
    echo "❌ Error: --feature required for create action"
    exit 1
  fi

  if [ -z "$phase" ]; then
    echo "❌ Error: --phase required for create action"
    exit 1
  fi

  # Find feature directory
  local feature_dir=$(find "$FEATURES_DIR" -maxdepth 1 -type d -name "${feature_num}-*" 2>/dev/null | head -1)

  if [ -z "$feature_dir" ] || [ ! -d "$feature_dir" ]; then
    echo "❌ Error: Feature directory not found for $feature_num"
    exit 1
  fi

  local checkpoint_dir="$CHECKPOINTS_DIR/$feature_num"
  local timestamp=$(date +%s)
  local checkpoint_path="$checkpoint_dir/${phase}-${timestamp}"

  mkdir -p "$checkpoint_path"

  # Copy current feature state
  cp -r "$feature_dir"/* "$checkpoint_path/"

  # Update manifest
  local manifest_file="$checkpoint_dir/manifest.json"
  if [ ! -f "$manifest_file" ]; then
    echo "[]" > "$manifest_file"
  fi

  if command -v jq &> /dev/null; then
    jq --arg phase "$phase" --arg ts "$(date -Iseconds)" \
       '. += [{"phase": $phase, "timestamp": $ts, "path": "'"$checkpoint_path"'"}]' \
       "$manifest_file" > "${manifest_file}.tmp"
    mv "${manifest_file}.tmp" "$manifest_file"
  fi

  echo "✅ Checkpoint created"
  echo ""
  echo "Feature:    $feature_num"
  echo "Phase:      $phase"
  echo "Timestamp:  $(date -Iseconds)"
  echo "Location:   $checkpoint_path"
}

# Function to restore checkpoint
restore_checkpoint() {
  local feature_num=$1
  local phase=$2

  if [ -z "$feature_num" ]; then
    echo "❌ Error: --feature required for restore action"
    exit 1
  fi

  if [ -z "$phase" ]; then
    echo "❌ Error: --phase required for restore action"
    exit 1
  fi

  local checkpoint_dir="$CHECKPOINTS_DIR/$feature_num"

  if [ ! -d "$checkpoint_dir" ]; then
    echo "❌ Error: No checkpoints found for feature $feature_num"
    exit 1
  fi

  # Find the checkpoint
  local checkpoint_path=$(find "$checkpoint_dir" -maxdepth 1 -type d -name "${phase}-*" | sort -r | head -1)

  if [ -z "$checkpoint_path" ] || [ ! -d "$checkpoint_path" ]; then
    echo "❌ Error: No checkpoint found for phase '$phase'"
    echo ""
    echo "Available phases for feature $feature_num:"
    ls -1 "$checkpoint_dir" | grep -v manifest.json | sed 's/-[0-9]*$//' | sort -u
    exit 1
  fi

  # Find target feature directory
  local feature_dir=$(find "$FEATURES_DIR" -maxdepth 1 -type d -name "${feature_num}-*" 2>/dev/null | head -1)

  if [ -z "$feature_dir" ]; then
    echo "❌ Error: Feature directory not found for $feature_num"
    exit 1
  fi

  # Confirm restore
  echo "⚠️  RESTORE CONFIRMATION"
  echo ""
  echo "This will restore feature $feature_num to phase '$phase'."
  echo ""
  echo "From:  $checkpoint_path"
  echo "To:    $feature_dir"
  echo ""
  echo "⚠️  Current state will be backed up to:"
  echo "     $checkpoint_dir/pre-restore-$(date +%s)"
  echo ""
  read -p "Continue? (y/N): " confirm

  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Restore cancelled."
    exit 0
  fi

  # Backup current state before restore
  local backup_path="$checkpoint_dir/pre-restore-$(date +%s)"
  mkdir -p "$backup_path"
  cp -r "$feature_dir"/* "$backup_path/" 2>/dev/null || true

  # Restore checkpoint
  rm -rf "$feature_dir"/*
  cp -r "$checkpoint_path"/* "$feature_dir/"

  # Update build state if exists
  if [ -f "${REPO_ROOT}/.specswarm/build-loop.state" ]; then
    if command -v jq &> /dev/null; then
      jq --arg phase "$phase" '.current_phase = $phase' \
         "${REPO_ROOT}/.specswarm/build-loop.state" > "${REPO_ROOT}/.specswarm/build-loop.state.tmp"
      mv "${REPO_ROOT}/.specswarm/build-loop.state.tmp" "${REPO_ROOT}/.specswarm/build-loop.state"
    fi
  fi

  echo ""
  echo "✅ Checkpoint restored"
  echo ""
  echo "Feature:    $feature_num"
  echo "Phase:      $phase"
  echo "Backup:     $backup_path"
  echo ""
  echo "You can continue the build from here or try a different approach."
}

# Function to delete checkpoints
delete_checkpoint() {
  local feature_num=$1
  local phase=$2
  local all=$3

  if [ "$all" = true ]; then
    echo "⚠️  DELETE ALL CHECKPOINTS"
    echo ""
    read -p "This will delete ALL checkpoints. Continue? (y/N): " confirm

    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
      echo "Delete cancelled."
      exit 0
    fi

    rm -rf "$CHECKPOINTS_DIR"/*
    echo "✅ All checkpoints deleted"
    return 0
  fi

  if [ -z "$feature_num" ]; then
    echo "❌ Error: --feature or --all required for delete action"
    exit 1
  fi

  local checkpoint_dir="$CHECKPOINTS_DIR/$feature_num"

  if [ ! -d "$checkpoint_dir" ]; then
    echo "❌ Error: No checkpoints found for feature $feature_num"
    exit 1
  fi

  if [ -z "$phase" ]; then
    # Delete all checkpoints for feature
    echo "⚠️  DELETE FEATURE CHECKPOINTS"
    echo ""
    read -p "Delete all checkpoints for feature $feature_num? (y/N): " confirm

    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
      echo "Delete cancelled."
      exit 0
    fi

    rm -rf "$checkpoint_dir"
    echo "✅ All checkpoints for feature $feature_num deleted"
  else
    # Delete specific phase checkpoint
    local checkpoint_path=$(find "$checkpoint_dir" -maxdepth 1 -type d -name "${phase}-*" | head -1)

    if [ -z "$checkpoint_path" ]; then
      echo "❌ Error: No checkpoint found for phase '$phase'"
      exit 1
    fi

    rm -rf "$checkpoint_path"
    echo "✅ Checkpoint deleted: $phase for feature $feature_num"
  fi
}

# Execute action
case "$ACTION" in
  list)
    list_checkpoints "$FEATURE_NUM"
    ;;
  create)
    create_checkpoint "$FEATURE_NUM" "$PHASE"
    ;;
  restore)
    restore_checkpoint "$FEATURE_NUM" "$PHASE"
    ;;
  delete)
    delete_checkpoint "$FEATURE_NUM" "$PHASE" "$ALL_FLAG"
    ;;
  *)
    echo "❌ Error: Unknown action '$ACTION'"
    echo ""
    echo "Valid actions: list, create, restore, delete"
    exit 1
    ;;
esac
```

---

## Automatic Checkpoints

Checkpoints are automatically created during `/specswarm:build` workflow after each phase:

| Phase | When Saved | What's Saved |
|-------|------------|--------------|
| specify | After spec.md created | spec.md |
| clarify | After clarifications added | spec.md (updated) |
| plan | After plan.md created | spec.md, plan.md |
| tasks | After tasks.md generated | spec.md, plan.md, tasks.md |
| implement | After each task completes | All artifacts + code changes |

---

## Usage Examples

### List All Checkpoints
```bash
/specswarm:checkpoint list
```

### List Checkpoints for Specific Feature
```bash
/specswarm:checkpoint list --feature 001
```

### Restore to Planning Phase
```bash
/specswarm:checkpoint restore --feature 001 --phase plan
```

### Manually Create Checkpoint
```bash
/specswarm:checkpoint create --feature 001 --phase custom-save
```

### Delete All Checkpoints
```bash
/specswarm:checkpoint delete --all
```

---

## Notes

- Checkpoints include all feature artifacts (spec.md, plan.md, tasks.md)
- A backup is created before each restore operation
- Checkpoints are stored in `.specswarm/checkpoints/<feature-num>/`
- Use checkpoints to experiment with different implementation approaches
