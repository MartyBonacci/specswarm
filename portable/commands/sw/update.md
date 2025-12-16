---
description: Update SpecSwarm Portable to latest version
---

## Goal

Check for updates to SpecSwarm Portable and install the latest version.

---

## Execution Steps

### Step 1: Check Current Version

```bash
echo "SpecSwarm Portable - Update Check"
echo "=================================="
echo ""

# Read current version
if [ -f ".claude/commands/sw/VERSION" ]; then
  CURRENT_VERSION=$(head -1 .claude/commands/sw/VERSION)
  INSTALL_DATE=$(sed -n '2p' .claude/commands/sw/VERSION)
  echo "Current version: $CURRENT_VERSION"
  echo "Installed: $INSTALL_DATE"
else
  CURRENT_VERSION="unknown"
  echo "Current version: unknown"
fi
echo ""
```

### Step 2: Check Latest Version

```bash
echo "Checking for updates..."
echo ""

# Get latest version from GitHub
LATEST_VERSION=$(curl -fsSL https://api.github.com/repos/MartyBonacci/specswarm/releases/latest 2>/dev/null | grep '"tag_name"' | head -1 | cut -d'"' -f4 | sed 's/^v//')

if [ -z "$LATEST_VERSION" ]; then
  # Fallback: check the VERSION file in main branch
  LATEST_VERSION=$(curl -fsSL https://raw.githubusercontent.com/MartyBonacci/specswarm/main/portable/commands/sw/VERSION 2>/dev/null | head -1)
fi

if [ -z "$LATEST_VERSION" ]; then
  echo "Error: Could not check for updates"
  echo ""
  echo "This might be because:"
  echo "  - No internet connection"
  echo "  - GitHub API rate limit exceeded"
  echo "  - Repository not accessible"
  echo ""
  echo "Try again later or manually update:"
  echo "  curl -fsSL https://raw.githubusercontent.com/MartyBonacci/specswarm/main/portable/install.sh | bash"
  exit 1
fi

echo "Latest version: $LATEST_VERSION"
echo ""
```

### Step 3: Compare Versions

```bash
if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
  echo "=========================================="
  echo "You're up to date!"
  echo "=========================================="
  echo ""
  echo "SpecSwarm Portable $CURRENT_VERSION is the latest version."
  echo ""
  echo "Tips:"
  echo "  - Run /sw:help for command reference"
  echo "  - Run /sw:suggest for workflow recommendations"
  echo ""
  exit 0
fi

echo "=========================================="
echo "Update Available!"
echo "=========================================="
echo ""
echo "Current: $CURRENT_VERSION"
echo "Latest:  $LATEST_VERSION"
echo ""
```

### Step 4: Confirm Update

Use the **AskUserQuestion** tool:

```
Question: "Would you like to update to the latest version?"
Header: "Update"
Options:
  1. "Yes, update now" (Recommended)
     Description: "Download and install the latest version"
  2. "No, keep current version"
     Description: "Stay on the current version"
  3. "Show changelog"
     Description: "View what's new before updating"
```

**If user wants changelog:**
```bash
echo "Fetching changelog..."
echo ""
curl -fsSL https://raw.githubusercontent.com/MartyBonacci/specswarm/main/CHANGELOG.md | head -100
echo ""
echo "..."
echo "(truncated - see full changelog at https://github.com/MartyBonacci/specswarm/blob/main/CHANGELOG.md)"
echo ""
```
Then ask again about updating.

**If user declines:**
```bash
echo "Update skipped."
echo ""
echo "You can update later by running: /sw:update"
exit 0
```

### Step 5: Perform Update

```bash
echo "Updating SpecSwarm Portable..."
echo ""

# Backup current installation
BACKUP_DIR=".claude/commands/sw.backup.$(date +%Y%m%d-%H%M%S)"
cp -r .claude/commands/sw "$BACKUP_DIR"
echo "Backed up current version to: $BACKUP_DIR"

# Download and install new version
echo "Downloading latest version..."

curl -fsSL "https://github.com/MartyBonacci/specswarm/archive/refs/heads/main.tar.gz" | \
  tar -xz --strip-components=2 -C /tmp specswarm-main/portable/commands

if [ -d "/tmp/sw" ]; then
  rm -rf .claude/commands/sw
  mv /tmp/sw .claude/commands/
  echo ""
  echo "=========================================="
  echo "Update Complete!"
  echo "=========================================="
  echo ""
  echo "Updated from $CURRENT_VERSION to $LATEST_VERSION"
  echo ""
  echo "Backup saved to: $BACKUP_DIR"
  echo "(Delete backup after verifying update works)"
  echo ""
  echo "What's new:"
  echo "  See /sw:help for updated command reference"
  echo "  Check CHANGELOG at https://github.com/MartyBonacci/specswarm"
  echo ""
else
  echo "Error: Update failed"
  echo ""
  echo "Restoring from backup..."
  rm -rf .claude/commands/sw
  mv "$BACKUP_DIR" .claude/commands/sw
  echo "Restored previous version."
  echo ""
  echo "Please try again or report this issue:"
  echo "  https://github.com/MartyBonacci/specswarm/issues"
  exit 1
fi
```

---

## Manual Update

If automatic update fails, you can manually update:

```bash
# Remove current installation
rm -rf .claude/commands/sw

# Download and install fresh
curl -fsSL https://raw.githubusercontent.com/MartyBonacci/specswarm/main/portable/install.sh | bash
```

---

## Rollback

If the update causes issues, restore from backup:

```bash
# List backups
ls -la .claude/commands/sw.backup.*

# Restore a specific backup
rm -rf .claude/commands/sw
cp -r .claude/commands/sw.backup.YYYYMMDD-HHMMSS .claude/commands/sw
```

---

## Notes

- Updates preserve your project's `.specswarm/` configuration
- Only command files in `.claude/commands/sw/` are replaced
- Backups are created automatically before each update
- Delete old backups after verifying updates work correctly
