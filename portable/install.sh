#!/bin/bash
#
# SpecSwarm Portable Installer
# Installs SpecSwarm commands into your project's .claude/commands/ directory
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/MartyBonacci/specswarm/main/portable/install.sh | bash
#

set -e

VERSION="3.5.0"
REPO="MartyBonacci/specswarm"
BRANCH="main"

echo ""
echo "=============================================="
echo " SpecSwarm Portable Installer v${VERSION}"
echo "=============================================="
echo ""

# Check if we're in a project directory
if [ ! -d ".git" ] && [ ! -f "package.json" ] && [ ! -f "requirements.txt" ] && [ ! -f "composer.json" ]; then
  echo "Warning: This doesn't look like a project directory."
  echo ""
  echo "SpecSwarm Portable should be installed in your project root."
  echo ""
  read -p "Continue anyway? (y/n): " confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Installation cancelled."
    exit 0
  fi
  echo ""
fi

# Create .claude/commands directory if not exists
if [ ! -d ".claude" ]; then
  mkdir -p .claude/commands
  echo "Created .claude/commands/"
else
  echo "Found existing .claude/ directory"
  mkdir -p .claude/commands
fi

# Check for existing installation
if [ -d ".claude/commands/sw" ]; then
  echo ""
  echo "Existing SpecSwarm Portable installation found."
  EXISTING_VERSION=$(head -1 .claude/commands/sw/VERSION 2>/dev/null || echo "unknown")
  echo "Current version: $EXISTING_VERSION"
  echo ""
  read -p "Overwrite with v${VERSION}? (y/n): " confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Installation cancelled."
    exit 0
  fi

  # Backup existing installation
  BACKUP_DIR=".claude/commands/sw.backup.$(date +%Y%m%d-%H%M%S)"
  mv .claude/commands/sw "$BACKUP_DIR"
  echo "Backed up existing installation to: $BACKUP_DIR"
fi

echo ""
echo "Downloading SpecSwarm Portable v${VERSION}..."
echo ""

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Download and extract
curl -fsSL "https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz" -o "$TEMP_DIR/specswarm.tar.gz"

# Extract only the portable/commands/sw directory
cd "$TEMP_DIR"
tar -xzf specswarm.tar.gz
cd - > /dev/null

# Copy commands to .claude/commands/sw
if [ -d "$TEMP_DIR/specswarm-${BRANCH}/portable/commands/sw" ]; then
  cp -r "$TEMP_DIR/specswarm-${BRANCH}/portable/commands/sw" .claude/commands/
  echo "Installed commands to .claude/commands/sw/"
else
  echo "Error: Could not find portable commands in downloaded archive"
  exit 1
fi

# Count installed commands
COMMAND_COUNT=$(ls -1 .claude/commands/sw/*.md 2>/dev/null | wc -l)

echo ""
echo "=============================================="
echo " Installation Complete!"
echo "=============================================="
echo ""
echo "Version: ${VERSION}"
echo "Commands installed: ${COMMAND_COUNT}"
echo "Location: .claude/commands/sw/"
echo ""
echo "Commands are now available as /sw:*"
echo ""
echo "Quick Start:"
echo "  /sw:init    - Initialize project configuration"
echo "  /sw:build   - Build a new feature"
echo "  /sw:fix     - Fix a bug"
echo "  /sw:ship    - Merge when ready"
echo "  /sw:help    - View all commands"
echo ""
echo "Natural Language Routing:"
echo "  /sw:router \"build user authentication\""
echo "  /sw:router \"fix the login bug\""
echo ""
echo "Documentation: https://github.com/${REPO}"
echo ""
