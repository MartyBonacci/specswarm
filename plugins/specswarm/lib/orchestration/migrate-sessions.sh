#!/bin/bash
# Migrate sessions from old SpecLabs paths to new SpecSwarm structure

OLD_PATHS=(
  ".specswarm/orchestrator/sessions"
  ".specswarm/feature-orchestrator/sessions"
)

NEW_PATH=".specswarm/specswarm/orchestration/sessions"

mkdir -p "$NEW_PATH"

total_migrated=0
for old_path in "${OLD_PATHS[@]}"; do
  if [ -d "$old_path" ]; then
    echo "📦 Migrating from $old_path..."
    count=$(ls -1 "$old_path" 2>/dev/null | wc -l)
    if [ "$count" -gt 0 ]; then
      cp -r "$old_path"/* "$NEW_PATH"/ 2>/dev/null
      total_migrated=$((total_migrated + count))
      echo "   Copied $count sessions"
    fi
  fi
done

if [ "$total_migrated" -gt 0 ]; then
  echo ""
  echo "✅ Session migration complete"
  echo "   Total sessions migrated: $total_migrated"
  echo "   New location: $NEW_PATH"
else
  echo "ℹ️  No sessions found to migrate"
fi
