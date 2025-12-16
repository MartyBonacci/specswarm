# SpecSwarm Portable

**Standalone version for Claude Code Web interface and per-project installation**

SpecSwarm Portable brings the full power of SpecSwarm's spec-driven development workflows to any project, without requiring the marketplace plugin system.

## Installation

### One-Liner (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/MartyBonacci/specswarm/main/portable/install.sh | bash
```

### Manual Installation

```bash
# Clone the repository
git clone --depth=1 https://github.com/MartyBonacci/specswarm.git /tmp/specswarm

# Copy portable commands to your project
cp -r /tmp/specswarm/portable/commands/sw .claude/commands/

# Clean up
rm -rf /tmp/specswarm

echo "Installed! Run /sw:help for usage."
```

## Quick Start

```bash
# Initialize your project
/sw:init

# Build a feature
/sw:build "user authentication with JWT"

# Fix a bug
/sw:fix "login fails with special characters"

# Merge when ready
/sw:ship
```

## Commands

All 35 commands are available with the `/sw:` prefix:

| Category | Commands |
|----------|----------|
| **Core Workflows** | `/sw:init`, `/sw:build`, `/sw:fix`, `/sw:modify`, `/sw:ship` |
| **Feature Dev** | `/sw:specify`, `/sw:clarify`, `/sw:plan`, `/sw:tasks`, `/sw:implement` |
| **Quality** | `/sw:analyze-quality`, `/sw:validate`, `/sw:security-audit` |
| **Lifecycle** | `/sw:complete`, `/sw:release`, `/sw:rollback` |
| **Portable Only** | `/sw:help`, `/sw:router`, `/sw:update` |

Run `/sw:help` for the complete command reference.

## Natural Language Routing

Since the portable version doesn't have automatic skill detection, use `/sw:router` for natural language commands:

```bash
# Instead of figuring out which command to use:
/sw:router "build a payment system"
# --> Recommends: /sw:build "payment system"

/sw:router "the checkout is broken"
# --> Recommends: /sw:fix "checkout is broken"
```

## Differences from Plugin Version

| Feature | Plugin (`/specswarm:*`) | Portable (`/sw:*`) |
|---------|------------------------|-------------------|
| Natural language auto-routing | Automatic | Use `/sw:router` |
| Confidence-based execution | Yes | Manual |
| Tool restrictions | Yes | No |
| All commands | Yes (32) | Yes (35) |
| SlashCommand chaining | Yes | Yes |
| Namespace | `/specswarm:` | `/sw:` |

See [LIMITATIONS.md](LIMITATIONS.md) for details.

## Updating

```bash
/sw:update
```

Or manually:

```bash
curl -fsSL https://raw.githubusercontent.com/MartyBonacci/specswarm/main/portable/install.sh | bash
```

## Project Structure

After installation, your project will have:

```
your-project/
  .claude/
    commands/
      sw/                    # SpecSwarm Portable commands
        build.md
        fix.md
        ...
        VERSION
  .specswarm/               # Created by /sw:init
    constitution.md         # Project governance
    tech-stack.md           # Approved technologies
    quality-standards.md    # Quality gates
    features/               # Feature artifacts
```

## Requirements

- Claude Code (Web or CLI)
- Git repository (for branch management)
- Project root access (to create `.claude/` directory)

## Uninstalling

```bash
rm -rf .claude/commands/sw
```

Your `.specswarm/` configuration and feature artifacts are preserved.

## Support

- Documentation: https://github.com/MartyBonacci/specswarm
- Issues: https://github.com/MartyBonacci/specswarm/issues
- Run `/sw:help` for quick reference
