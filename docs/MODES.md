# SpecSwarm Command Modes

SpecSwarm supports three command visibility modes to match your workflow preferences and reduce autocomplete clutter.

## TL;DR

```bash
# Check current mode
/specswarm:mode

# Switch modes
/specswarm:mode leader           # 9 core commands (recommended)
/specswarm:mode micro-manager    # 28 commands (granular control)
/specswarm:mode extra            # 33 commands (includes experimental)
```

---

## Philosophy: Leader vs Micro-Manager

### Leader Mode (Default) - "Trust the Automation"

**For:** Most users, daily workflows
**Visible Commands:** 9 core orchestrators
**Philosophy:** Let the system handle the workflow. You lead, the system executes.

**Example workflow:**
```bash
You: "Build user authentication with JWT tokens"
System: → specify → clarify (asks questions) → plan → tasks → implement → quality check
You: Only engage when asked or if something fails
```

**Why this works:**
- Orchestrators handle multi-step workflows
- Natural language skills make it even easier
- You focus on what to build, not how to build it
- 75% less autocomplete clutter

---

### Micro-Manager Mode - "Manual Control"

**For:** Power users who want step-by-step control
**Visible Commands:** 28 commands (9 core + 19 internal)
**Philosophy:** I want to manually control each workflow step

**Example workflow:**
```bash
/specswarm:specify "add JWT auth"
# Review spec.md
/specswarm:clarify
# Answer questions
/specswarm:plan
# Review plan.md
/specswarm:tasks
# Review tasks.md
/specswarm:implement
# Monitor implementation
```

**When to use:**
- You want fine-grained control
- You're debugging a workflow
- You need to stop between steps
- You're learning how SpecSwarm works internally

---

### Extra Mode - "Everything Including Experimental"

**For:** Developers, experimenters, contributors
**Visible Commands:** 33 commands (all)
**Philosophy:** Show me everything

**Includes experimental features:**
- `/specswarm:orchestrate` - Advanced multi-agent coordination
- `/specswarm:orchestrate-feature` - Full autonomous workflow
- `/specswarm:orchestrate-validate` - Validation suite runner
- `/specswarm:refactor` - Metrics-driven code quality
- `/specswarm:deprecate` - Feature sunset workflow

**Warning:** Experimental features are under active development.

---

## Command Breakdown by Mode

### Leader Mode (9 commands)

| Command | Purpose |
|---------|---------|
| `/specswarm:init` | Project setup |
| `/specswarm:suggest` | Get AI workflow recommendation |
| `/specswarm:build` | Create new features (orchestrator) |
| `/specswarm:fix` | Fix bugs (orchestrator) |
| `/specswarm:modify` | Change behavior (orchestrator) |
| `/specswarm:ship` | Deploy/merge (orchestrator) |
| `/specswarm:upgrade` | Update dependencies |
| `/specswarm:metrics` | View analytics |
| `/specswarm:mode` | Switch command visibility modes |

**What's hidden:** 24 commands (19 internal + 5 experimental)

---

### Micro-Manager Mode (+19 internal commands)

**Adds workflow commands called by orchestrators:**

#### Specification Workflow (5 commands)
- `/specswarm:specify` - Create spec.md
- `/specswarm:clarify` - Ask clarification questions
- `/specswarm:plan` - Generate plan.md
- `/specswarm:tasks` - Create tasks.md
- `/specswarm:implement` - Execute implementation

#### Bug & Issue Management (3 commands)
- `/specswarm:bugfix` - Regression-test-first bugfixing
- `/specswarm:hotfix` - Emergency production fixes
- `/specswarm:coordinate` - Complex debugging orchestration

#### Quality & Analysis (4 commands)
- `/specswarm:analyze` - Cross-artifact consistency check
- `/specswarm:analyze-quality` - Quality scoring
- `/specswarm:impact` - Impact analysis
- `/specswarm:validate` - Browser validation with Playwright

#### Lifecycle Management (5 commands)
- `/specswarm:security-audit` - Security scanning
- `/specswarm:complete` - Merge to parent branch
- `/specswarm:rollback` - Safe rollback
- `/specswarm:release` - Release preparation

#### Utilities (2 commands)
- `/specswarm:checklist` - Generate verification checklist
- `/specswarm:constitution` - Project governance
- `/specswarm:metrics-export` - Export metrics to CSV

**What's hidden:** 5 experimental commands

---

### Extra Mode (+5 experimental commands)

**Adds experimental features:**

- `/specswarm:orchestrate` - Multi-agent coordination system
- `/specswarm:orchestrate-feature` - Full autonomous lifecycle
- `/specswarm:orchestrate-validate` - Validation suite runner
- `/specswarm:refactor` - Code quality improvement
- `/specswarm:deprecate` - Feature sunset workflow

**Nothing hidden:** All 33 commands visible

---

## Switching Modes

### Interactive Mode Switcher

```bash
/specswarm:mode
```

**Shows:**
- Current mode and visible command count
- Detailed mode descriptions
- Usage examples

**Example output:**
```
╔════════════════════════════════════════════════════════════════╗
║                    SpecSwarm Command Modes                     ║
╚════════════════════════════════════════════════════════════════╝

📊 Current Mode: leader
   Visible Commands: 9
   Description: Core orchestrators only

────────────────────────────────────────────────────────────────

Available Modes:

  1️⃣  leader (recommended)
     • 9 core commands visible
     • Let the system orchestrate workflows
     • Best for: Most users, daily workflows

  2️⃣  micro-manager
     • 28 commands visible (core + internal)
     • Manual control over workflow steps
     • Best for: Power users who want step-by-step control

  3️⃣  extra
     • 33 commands visible (everything)
     • Includes experimental features
     • Best for: Developers, testing, experimentation

────────────────────────────────────────────────────────────────

💡 Usage:
   /specswarm:mode leader         # Switch to leader mode
   /specswarm:mode micro-manager  # Switch to micro-manager mode
   /specswarm:mode extra          # Switch to extra mode
```

### Direct Mode Switch

```bash
/specswarm:mode micro-manager
```

**Result:**
- Immediately switches to new mode
- Updates config file
- Persists across sessions
- Shows success message with command examples

---

## Configuration

Mode preferences are stored in:

```
~/.claude/plugins/specswarm/config.json
```

**Format:**
```json
{
  "version": "3.6.0",
  "mode": "leader",
  "lastUpdated": "2025-11-19T12:00:00Z"
}
```

**Persistence:**
- Mode persists across Claude Code sessions
- Per-user configuration
- Automatic config file creation on first use

---

## Use Cases & Recommendations

### Use Leader Mode When:
- ✅ Building new features
- ✅ Fixing bugs
- ✅ Daily development work
- ✅ You want minimal cognitive load
- ✅ You trust the orchestration

### Switch to Micro-Manager Mode When:
- 🔧 Debugging workflow issues
- 🔧 Learning SpecSwarm internals
- 🔧 You need to pause between steps
- 🔧 Manual workflow control required
- 🔧 Creating custom workflow combinations

### Switch to Extra Mode When:
- ⚗️  Testing experimental features
- ⚗️  Contributing to SpecSwarm
- ⚗️  Exploring all capabilities
- ⚗️  Development and debugging
- ⚗️  Researching new workflows

---

## Natural Language Integration

**Important:** Natural language skills work in ALL modes!

```bash
# Works in leader mode
You: "Build user authentication"
System: Executes /specswarm:build automatically

# Works in micro-manager mode
You: "Build user authentication"
System: Still executes /specswarm:build (orchestrator)
# But now you can also manually call /specswarm:specify, /specswarm:plan, etc.

# Works in extra mode
You: "Refactor the auth module"
System: Can trigger /specswarm:refactor (experimental)
```

**Skills use orchestrators, not granular commands**, so they work consistently across all modes.

---

## Hidden Command Access

### In Leader Mode

**Granular commands are hidden but still callable:**

```bash
# This works even in leader mode
/specswarm:specify "add authentication"
# But won't appear in autocomplete

# If you try to use a hidden command, you'll get guidance
System: "⚠️ Internal Command
         '/specswarm:specify' is an internal workflow step.

         Recommended: Use '/specswarm:build' instead

         To call internal commands directly, enable micro-manager mode:
         /specswarm:mode micro-manager"
```

**Why this design?**
- Reduces autocomplete clutter
- Doesn't prevent manual access
- Educates users about mode system
- Guides toward better workflows

---

## Migration Guide

### For New Users
**Start with leader mode (default)**
- Learn the 9 core commands
- Use natural language when possible
- Switch to micro-manager if you need more control

### For Existing Users
**Your workflows won't break**
- All commands still work exactly the same
- Only autocomplete visibility changes
- Config defaults to "extra" mode for compatibility
- Switch to "leader" mode to try the new experience

### For Plugin Developers
**Commands are still callable programmatically**
- SlashCommand tool works regardless of mode
- Orchestrators call internal commands normally
- Visibility only affects autocomplete UI
- Skills remain mode-agnostic

---

## FAQ

### Q: Will hidden commands stop working?
**A:** No. Commands are only hidden from autocomplete. You can still call them directly by typing the full command name.

### Q: Do I need to remember which commands are in which mode?
**A:** No. Use `/specswarm:mode` to see the breakdown, or just switch to extra mode to see everything.

### Q: Can I customize which commands are visible?
**A:** Not yet. v3.6.0 has three preset modes. Custom modes may come in a future release if there's demand.

### Q: Will this affect natural language commands?
**A:** No. Skills work the same in all modes. They trigger orchestrators, which call internal commands automatically.

### Q: What happens if I'm in leader mode and an orchestrator fails?
**A:** The error will guide you. You can either:
1. Switch to micro-manager mode to debug step-by-step
2. Use the orchestrator with different parameters
3. Get help with `/specswarm:suggest`

### Q: Can I change modes mid-workflow?
**A:** Yes! Mode switches take effect immediately. If you're in leader mode and want manual control, switch to micro-manager mode and continue where you left off.

### Q: Which mode should I use?
**A:** Start with **leader mode**. Only switch if you feel constrained. Most users stay in leader mode.

---

## Examples

### Example 1: New Feature in Leader Mode

```bash
# Use natural language or slash command
You: "Build a user profile page with avatar upload"

# SpecSwarm builds automatically
System: Running /specswarm:build...
        → Creating specification
        → Asking clarification questions (you answer 2-3 questions)
        → Generating implementation plan
        → Creating task breakdown
        → Implementing feature
        → Running quality check
        ✓ Feature complete! (Quality score: 87/100)

# Clean autocomplete throughout - only saw 9 commands
```

---

### Example 2: Debugging in Micro-Manager Mode

```bash
# Something went wrong, need manual control
/specswarm:mode micro-manager
# Now you can see all workflow commands

# Create spec manually
/specswarm:specify "fix login timeout"
# Edit spec.md directly to add details

# Skip clarify, go straight to plan
/specswarm:plan
# Review plan.md

# Generate tasks
/specswarm:tasks
# Manually edit tasks.md to adjust approach

# Implement with custom modifications
/specswarm:implement
# Monitor and intervene as needed
```

---

### Example 3: Exploring in Extra Mode

```bash
# Enable experimental features
/specswarm:mode extra

# Try autonomous orchestration
/specswarm:orchestrate-feature "add dark mode support" /path/to/project

# System handles entire lifecycle autonomously
# Creates spec → clarifies → plans → implements → validates
# Retries on failures
# Reports final status

# See all capabilities
/specswarm:orchestrate --help
/specswarm:refactor --help
/specswarm:deprecate --help
```

---

## Technical Details

### How Visibility Works

**Command frontmatter:**
```yaml
---
description: Create specification from natural language
visibility: internal  # public | internal | experimental
---
```

**Mode filtering:**
- **public** - Visible in all modes
- **internal** - Visible in micro-manager and extra modes
- **experimental** - Visible only in extra mode

**Autocomplete behavior:**
- Reads mode from `~/.claude/plugins/specswarm/config.json`
- Filters command list based on visibility + mode
- Preserves all command functionality
- Only affects UI presentation

---

## Best Practices

### 1. Start Simple
Begin with leader mode. Only increase complexity if needed.

### 2. Use Natural Language
Let skills detect your intent:
- "Build X" → build workflow
- "Fix Y" → bugfix workflow
- "Change Z" → modify workflow

### 3. Learn the Core Commands
Master the 9 public commands before diving into granular control.

### 4. Switch Modes Strategically
- **Daily work:** leader mode
- **Debugging:** micro-manager mode
- **Exploring:** extra mode

### 5. Read the Spec
Internal commands operate on artifacts (spec.md, plan.md, tasks.md). Understanding these files helps you use granular commands effectively.

---

## Troubleshooting

### Problem: "Command not found in autocomplete"

**Solution:**
```bash
# Check current mode
/specswarm:mode

# Switch to extra mode to see all commands
/specswarm:mode extra
```

---

### Problem: "I used to see all commands, now I only see 9"

**Solution:**
```bash
# You're in leader mode now
# To restore previous behavior:
/specswarm:mode extra
```

---

### Problem: "Which mode am I in?"

**Solution:**
```bash
# Check current mode
/specswarm:mode

# Or check config file
cat ~/.claude/plugins/specswarm/config.json
```

---

## Version History

- **v3.6.0** - Initial mode system release
  - Three modes: leader, micro-manager, extra
  - 9 public, 19 internal, 5 experimental commands
  - Config-based persistence
  - Interactive mode switcher

---

## Feedback

**Love the mode system?** Leave a ⭐ on the repo!

**Have suggestions?** Open an issue:
- Custom modes?
- Different command groupings?
- Mode-specific features?

**Found a bug?** Report it with:
- Current mode
- Command that failed
- Expected vs actual behavior

---

## See Also

- [README.md](../README.md) - Getting started guide
- [COMMANDS.md](../COMMANDS.md) - Complete command reference
- [FEATURES.md](FEATURES.md) - Advanced features
- [SETUP.md](SETUP.md) - Technical setup

---

**Happy building! 🚀**

Remember: The best mode is the one that gets out of your way and lets you focus on creating amazing software.
