#!/bin/bash

echo "=== SpecSwarm Commands ==="
echo ""

for file in plugins/specswarm/commands/*.md; do
  name=$(basename "$file" .md)
  desc=$(grep "^description:" "$file" | head -1 | sed 's/description: *//' | sed "s/^['\"]//;s/['\"]$//" | sed 's/ - .*//')
  echo "$name|$desc"
done | sort

echo ""
echo "=== SpecLabs Commands (Aliases) ==="
echo ""

for file in plugins/speclabs/commands/*.md; do
  name=$(basename "$file" .md)
  desc=$(grep "^description:" "$file" | head -1 | sed 's/description: *//' | sed "s/^['\"]//;s/['\"]$//" | sed 's/ - .*//')
  echo "$name|$desc"
done | sort
