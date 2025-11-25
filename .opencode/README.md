# SpecSwarm OpenCode Setup

This directory contains the OpenCode configuration for SpecSwarm.

## Overview

SpecSwarm supports both **Claude Code** and **OpenCode** runtimes. This configuration enables the same functionality across both platforms using OpenCode's native command system.

## How It Works

Commands are defined in `opencode.jsonc` using OpenCode's `@file` reference syntax. The `@commands/file.md` notation tells OpenCode to include the file contents in the prompt context when the command is executed. This eliminates duplication - there's a single source of truth for all command definitions.

See: https://opencode.ai/docs/commands/#file-references

## Directory Structure

```
specswarm/
├── commands/                    # Source of truth for all commands (32 files)
│   ├── build.md
│   ├── fix.md
│   └── ...
├── .opencode/
│   ├── opencode.jsonc          # OpenCode config - references commands/
│   └── README.md               # This file
└── scripts/
    └── validate-opencode-commands.sh  # Validates all command references
```

## Installation

### Option 1: Global Installation (Recommended)

Install SpecSwarm globally so it's available in all your projects:

1. **Clone SpecSwarm:**
   ```bash
   git clone https://github.com/MartyBonacci/specswarm.git ~/.specswarm
   ```

2. **Set the config directory in your shell profile** (`~/.zshrc` or `~/.bashrc`):
   ```bash
   export OPENCODE_CONFIG_DIR="$HOME/.specswarm/.opencode"
   ```

3. **Reload your shell:**
   ```bash
   source ~/.zshrc  # or source ~/.bashrc
   ```

4. **Start OpenCode in any project:**
   ```bash
   cd your-project
   opencode
   /specswarm:init
   ```

### Option 2: Per-Project Installation

Copy the OpenCode configuration to your project:

1. **Copy the `.opencode` directory and `commands/`:**
   ```bash
   cp -r /path/to/specswarm/.opencode your-project/
   cp -r /path/to/specswarm/commands your-project/
   ```

2. **Start OpenCode:**
   ```bash
   cd your-project
   opencode
   /specswarm:init
   ```

### Option 3: Symlink Installation

Keep SpecSwarm updated while using it in projects:

```bash
# Clone once
git clone https://github.com/MartyBonacci/specswarm.git ~/.specswarm

# Symlink to your project
ln -s ~/.specswarm/.opencode your-project/.opencode
ln -s ~/.specswarm/commands your-project/commands
```

## Using Commands

All SpecSwarm commands are available with the `/specswarm:` prefix:

```bash
# Core Commands (95% of daily work)
/specswarm:init           # Initialize project configuration
/specswarm:build "desc"   # Build features from specification  
/specswarm:fix "desc"     # Systematic bugfix workflow
/specswarm:modify "desc"  # Modify existing features
/specswarm:ship           # Quality validation and merge

# Example usage
/specswarm:build "Add user authentication with JWT"
/specswarm:fix "Login button not working on mobile"
```

### Natural Language

You can also use natural language with OpenCode:

```
"Build user authentication with JWT"
"Fix the login bug"
"Ship this feature"
```

## Commands Reference

SpecSwarm provides 32 commands for the complete software development lifecycle:

### Core Workflows (5)
| Command | Description |
|---------|-------------|
| `/specswarm:init` | Initialize project configuration |
| `/specswarm:build` | Build features from specification |
| `/specswarm:fix` | Systematic bugfix workflow |
| `/specswarm:modify` | Modify existing features |
| `/specswarm:ship` | Quality validation and merge |

### Feature Development (8)
| Command | Description |
|---------|-------------|
| `/specswarm:specify` | Create feature specification |
| `/specswarm:clarify` | Clarification questions |
| `/specswarm:plan` | Generate implementation plan |
| `/specswarm:tasks` | Break down into tasks |
| `/specswarm:implement` | Execute implementation |
| `/specswarm:checklist` | Create quality checklist |
| `/specswarm:analyze` | Analyze code changes |
| `/specswarm:constitution` | Project governance |

### Bug & Issue Management (3)
| Command | Description |
|---------|-------------|
| `/specswarm:bugfix` | Systematic bug fixing |
| `/specswarm:hotfix` | Production hotfix |
| `/specswarm:coordinate` | Multi-bug coordination |

### Code Maintenance (2)
| Command | Description |
|---------|-------------|
| `/specswarm:refactor` | Code refactoring |
| `/specswarm:deprecate` | Deprecation management |

### Quality & Analysis (6)
| Command | Description |
|---------|-------------|
| `/specswarm:analyze-quality` | Quality analysis (0-100 scoring) |
| `/specswarm:impact` | Impact analysis |
| `/specswarm:suggest` | Workflow suggestions |
| `/specswarm:metrics` | Feature metrics |
| `/specswarm:metrics-export` | Export metrics |
| `/specswarm:validate` | Validation checks |

### Lifecycle Management (5)
| Command | Description |
|---------|-------------|
| `/specswarm:release` | Release management |
| `/specswarm:security-audit` | Security audit |
| `/specswarm:rollback` | Rollback changes |
| `/specswarm:upgrade` | Dependency upgrades |
| `/specswarm:complete` | Complete feature |

### Orchestration (3)
| Command | Description |
|---------|-------------|
| `/specswarm:orchestrate` | Basic orchestration |
| `/specswarm:orchestrate-feature` | Feature orchestration |
| `/specswarm:orchestrate-validate` | Validation orchestration |

## Configuration

### opencode.jsonc

The `opencode.jsonc` file defines all commands using `@file` references:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "command": {
    "specswarm:build": {
      "template": "@commands/build.md\n\n$ARGUMENTS",
      "description": "Build complete feature from specification to implementation"
    }
    // ... 31 more commands
  },
  "instructions": [
    ".specswarm/constitution.md",
    ".specswarm/tech-stack.md",
    ".specswarm/quality-standards.md"
  ]
}
```

### SpecSwarm Project Settings

After running `/specswarm:init`, your project will have:

```
.specswarm/
├── constitution.md       # Project governance
├── tech-stack.md         # Approved technologies
└── quality-standards.md  # Quality gates
```

## Validation

Run the validation script to ensure all command references are valid:

```bash
./scripts/validate-opencode-commands.sh
```

This checks:
- All files referenced in `opencode.jsonc` exist
- All command files in `commands/` are referenced

**Integrate this into CI/CD** to catch issues when commands are added or removed.

## Differences from Claude Code

| Feature | Claude Code | OpenCode |
|---------|-------------|----------|
| Plugin Directory | `.claude-plugin/` | `.opencode/` |
| Commands Location | `commands/` (direct) | `commands/` (via `@file`) |
| Config File | N/A | `opencode.jsonc` |
| Installation | Marketplace | Manual/OPENCODE_CONFIG_DIR |

Both platforms use the same:
- Command definitions in `commands/`
- Project configuration in `.specswarm/`
- Workflow logic

## Troubleshooting

### Commands Not Found

1. **Check that opencode.jsonc exists:**
   ```bash
   cat .opencode/opencode.jsonc
   ```

2. **Verify commands directory exists:**
   ```bash
   ls commands/
   ```

3. **Run validation:**
   ```bash
   ./scripts/validate-opencode-commands.sh
   ```

### OpenCode Not Recognizing Commands

Restart OpenCode to reload configuration:

```bash
# Quit and restart
opencode
```

### File Reference Errors

If you see errors about missing files, ensure the `@commands/` path is correct:
- From the project root, the path `@commands/file.md` should resolve to the `commands/` directory

### Using OPENCODE_CONFIG_DIR

If using global installation, verify the environment variable:

```bash
echo $OPENCODE_CONFIG_DIR
# Should output: /path/to/specswarm/.opencode
```

## Contributing

When adding new commands:

1. Create the command file in `commands/`
2. Add the command reference in `.opencode/opencode.jsonc`
3. Run `./scripts/validate-opencode-commands.sh` to verify
4. Update documentation

## License

MIT License - See LICENSE file for details.

## Support

- **Repository**: https://github.com/MartyBonacci/specswarm
- **Issues**: https://github.com/MartyBonacci/specswarm/issues
- **Documentation**: [docs/README.md](../docs/README.md)
