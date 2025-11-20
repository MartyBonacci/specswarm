---
description: Switch between command visibility modes (leader, micro-manager, extra)
visibility: public
args:
  - name: mode_name
    description: Mode to switch to (leader|micro-manager|extra)
    required: false
---

## User Input

```text
$ARGUMENTS
```

## Goal

Allow users to switch between three command visibility modes:
- **leader** - Show 8 core commands (default)
- **micro-manager** - Show 27 commands (core + internal)
- **extra** - Show all 32 commands (including experimental)

---

## Execution Steps

### 1. Initialize Config Path

```bash
# Config file location
CONFIG_DIR="${HOME}/.claude/plugins/specswarm"
CONFIG_FILE="${CONFIG_DIR}/config.json"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# Initialize default config if doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
  cat > "$CONFIG_FILE" << 'EOF'
{
  "version": "3.6.0",
  "mode": "leader",
  "lastUpdated": ""
}
EOF
fi
```

---

### 2. Read Current Mode

```bash
# Read current mode from config
if command -v jq &> /dev/null; then
  CURRENT_MODE=$(jq -r '.mode // "leader"' "$CONFIG_FILE" 2>/dev/null || echo "leader")
else
  # Fallback if jq not available
  CURRENT_MODE=$(grep -o '"mode"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" 2>/dev/null | cut -d'"' -f4)
  [ -z "$CURRENT_MODE" ] && CURRENT_MODE="leader"
fi
```

---

### 3. Parse User Input

```bash
MODE_ARG="$ARGUMENTS"

# Trim whitespace
MODE_ARG=$(echo "$MODE_ARG" | xargs)

# If no argument, show current mode and options
if [ -z "$MODE_ARG" ]; then
  SHOW_MENU=true
else
  SHOW_MENU=false
  NEW_MODE="$MODE_ARG"
fi
```

---

### 4. Display Current Mode (if no argument)

```bash
if [ "$SHOW_MENU" = true ]; then
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║                    SpecSwarm Command Modes                     ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""

  # Determine visible command counts
  case "$CURRENT_MODE" in
    leader)
      VISIBLE_COUNT=8
      MODE_DESC="Core orchestrators only"
      ;;
    micro-manager)
      VISIBLE_COUNT=27
      MODE_DESC="Core + internal commands"
      ;;
    extra)
      VISIBLE_COUNT=32
      MODE_DESC="All commands including experimental"
      ;;
    *)
      VISIBLE_COUNT=8
      MODE_DESC="Unknown mode (defaulting to leader)"
      CURRENT_MODE="leader"
      ;;
  esac

  echo "📊 Current Mode: $CURRENT_MODE"
  echo "   Visible Commands: $VISIBLE_COUNT"
  echo "   Description: $MODE_DESC"
  echo ""
  echo "────────────────────────────────────────────────────────────────"
  echo ""
  echo "Available Modes:"
  echo ""
  echo "  1️⃣  leader (recommended)"
  echo "     • 8 core commands visible"
  echo "     • Let the system orchestrate workflows"
  echo "     • Best for: Most users, daily workflows"
  echo "     • Commands: init, suggest, build, fix, modify, ship, upgrade, metrics"
  echo ""
  echo "  2️⃣  micro-manager"
  echo "     • 27 commands visible (core + internal)"
  echo "     • Manual control over workflow steps"
  echo "     • Best for: Power users who want step-by-step control"
  echo "     • Adds: specify, clarify, plan, tasks, implement, and 14 more..."
  echo ""
  echo "  3️⃣  extra"
  echo "     • 32 commands visible (everything)"
  echo "     • Includes experimental features"
  echo "     • Best for: Developers, testing, experimentation"
  echo "     • Adds: orchestrate-*, refactor, deprecate"
  echo ""
  echo "────────────────────────────────────────────────────────────────"
  echo ""
  echo "💡 Usage:"
  echo "   /specswarm:mode leader         # Switch to leader mode"
  echo "   /specswarm:mode micro-manager  # Switch to micro-manager mode"
  echo "   /specswarm:mode extra          # Switch to extra mode"
  echo ""
  echo "🔧 Config: $CONFIG_FILE"
  echo ""

  exit 0
fi
```

---

### 5. Validate and Switch Mode

```bash
# Validate mode argument
case "$NEW_MODE" in
  leader|micro-manager|extra)
    # Valid mode
    ;;
  *)
    echo "❌ Error: Invalid mode '$NEW_MODE'"
    echo ""
    echo "Valid modes: leader, micro-manager, extra"
    echo ""
    echo "Usage: /specswarm:mode [mode_name]"
    echo "   or: /specswarm:mode (to see options)"
    exit 1
    ;;
esac

# Check if already in this mode
if [ "$NEW_MODE" = "$CURRENT_MODE" ]; then
  echo "ℹ️  Already in $NEW_MODE mode"
  exit 0
fi
```

---

### 6. Update Config File

```bash
# Get current timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Update config file
if command -v jq &> /dev/null; then
  # Use jq for proper JSON manipulation
  jq --arg mode "$NEW_MODE" --arg ts "$TIMESTAMP" \
    '.mode = $mode | .lastUpdated = $ts' \
    "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
else
  # Fallback: simple sed replacement
  sed -i.bak "s/\"mode\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"mode\": \"$NEW_MODE\"/" "$CONFIG_FILE"
  sed -i.bak "s/\"lastUpdated\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"lastUpdated\": \"$TIMESTAMP\"/" "$CONFIG_FILE"
  rm -f "${CONFIG_FILE}.bak"
fi
```

---

### 7. Display Success Message

```bash
echo "✅ Mode switched: $CURRENT_MODE → $NEW_MODE"
echo ""

# Show what changed
case "$NEW_MODE" in
  leader)
    echo "📊 Leader Mode Activated"
    echo "   • 8 core commands now visible"
    echo "   • Internal commands hidden from autocomplete"
    echo "   • Focus on orchestrated workflows"
    echo ""
    echo "Visible commands:"
    echo "   /specswarm:init        - Project setup"
    echo "   /specswarm:suggest     - Get workflow recommendation"
    echo "   /specswarm:build       - Create new features"
    echo "   /specswarm:fix         - Fix bugs"
    echo "   /specswarm:modify      - Change behavior"
    echo "   /specswarm:ship        - Deploy/merge"
    echo "   /specswarm:upgrade     - Update dependencies"
    echo "   /specswarm:metrics     - View analytics"
    echo ""
    echo "💡 Tip: Use natural language! Just say:"
    echo "   'Build user authentication with JWT'"
    echo "   'Fix the login timeout bug'"
    ;;

  micro-manager)
    echo "🔧 Micro-Manager Mode Activated"
    echo "   • 27 commands now visible"
    echo "   • Full workflow control enabled"
    echo "   • Internal commands accessible"
    echo ""
    echo "Additional commands available:"
    echo "   /specswarm:specify     - Create spec only"
    echo "   /specswarm:clarify     - Ask clarification questions"
    echo "   /specswarm:plan        - Generate plan only"
    echo "   /specswarm:tasks       - Create task breakdown"
    echo "   /specswarm:implement   - Execute implementation only"
    echo "   ... and 14 more internal commands"
    echo ""
    echo "💡 Manual workflow example:"
    echo "   /specswarm:specify → /specswarm:clarify → /specswarm:plan"
    echo "   → /specswarm:tasks → /specswarm:implement"
    ;;

  extra)
    echo "⚗️  Extra Mode Activated"
    echo "   • All 32 commands visible"
    echo "   • Experimental features enabled"
    echo "   • Maximum flexibility"
    echo ""
    echo "Experimental commands available:"
    echo "   /specswarm:orchestrate           - Multi-agent coordination"
    echo "   /specswarm:orchestrate-feature   - Full autonomous workflow"
    echo "   /specswarm:orchestrate-validate  - Validation suite"
    echo "   /specswarm:refactor              - Code quality improvement"
    echo "   /specswarm:deprecate             - Feature sunset workflow"
    echo ""
    echo "⚠️  Note: Experimental features are under development"
    ;;
esac

echo ""
echo "🔧 Config saved to:"
echo "   $CONFIG_FILE"
echo ""
echo "📝 To switch modes again:"
echo "   /specswarm:mode [leader|micro-manager|extra]"
echo ""
```

---

## Mode Definitions

### Leader Mode (Default)
- **Visible**: 8 core commands
- **Hidden**: 24 commands (19 internal + 5 experimental)
- **Philosophy**: "Lead the workflow, don't micromanage"
- **Target**: Most users, daily work

**Visible Commands:**
1. init
2. suggest
3. build
4. fix
5. modify
6. ship
7. upgrade
8. metrics

---

### Micro-Manager Mode
- **Visible**: 27 commands (8 core + 19 internal)
- **Hidden**: 5 experimental commands
- **Philosophy**: "I want control over each step"
- **Target**: Power users

**Additional Visible Commands (19):**
1. specify
2. clarify
3. plan
4. tasks
5. implement
6. analyze
7. checklist
8. constitution
9. bugfix
10. hotfix
11. coordinate
12. impact
13. analyze-quality
14. validate
15. security-audit
16. complete
17. rollback
18. release
19. metrics-export

---

### Extra Mode
- **Visible**: 32 commands (all)
- **Hidden**: None
- **Philosophy**: "Show me everything"
- **Target**: Developers, experimenters

**Additional Visible Commands (5):**
1. orchestrate
2. orchestrate-feature
3. orchestrate-validate
4. refactor
5. deprecate

---

## Config File Structure

```json
{
  "version": "3.6.0",
  "mode": "leader",
  "lastUpdated": "2025-11-19T12:00:00Z"
}
```

**Location**: `~/.claude/plugins/specswarm/config.json`

---

## Success Criteria

✅ Current mode displayed
✅ Mode options explained
✅ Mode switching validated
✅ Config file updated
✅ Success message with next steps
✅ Changes persist across sessions
