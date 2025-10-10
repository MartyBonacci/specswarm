# SpecSwarm

A Claude Code plugin marketplace for specification-driven development orchestration.

## Overview

SpecSwarm provides curated plugins that help you follow structured, systematic development workflows using Claude Code. The marketplace focuses on tools that emphasize clear specifications, thoughtful planning, and methodical implementation.

## Available Plugins

### SpecKit

Brings Spec-Driven Development (SDD) workflow to Claude Code, adapted from [GitHub's spec-kit project](https://github.com/github/spec-kit).

**Features:**
- 8 slash commands for complete SDD workflow
- Constitution-based project governance
- Systematic specification writing
- Technical planning and task breakdown
- Cross-artifact consistency analysis
- Requirements quality checklists

**Commands:**
- `/speckit.constitution` - Establish project principles
- `/speckit.specify` - Define feature specifications
- `/speckit.clarify` - Resolve ambiguities
- `/speckit.plan` - Create technical plans
- `/speckit.tasks` - Generate task breakdowns
- `/speckit.implement` - Execute implementation
- `/speckit.analyze` - Validate consistency
- `/speckit.checklist` - Create quality checklists

[Read full SpecKit documentation →](plugins/speckit/README.md)

## Installation

### Add the Marketplace

```bash
claude plugin marketplace add marty/specswarm
```

Or if using a local repository:

```bash
claude plugin marketplace add /path/to/specswarm
```

### Install Plugins

Install individual plugins from the marketplace:

```bash
# Install SpecKit plugin
claude plugin install speckit
```

List available plugins:

```bash
claude plugin marketplace list
```

## What is Spec-Driven Development?

Spec-Driven Development is a structured approach to software development that prioritizes clear specifications before implementation:

1. **Define principles** - Establish project constraints and standards
2. **Write specifications** - Document what needs to be built and why
3. **Plan technically** - Design the implementation approach
4. **Break down work** - Create actionable, ordered tasks
5. **Implement systematically** - Build following the plan
6. **Validate quality** - Check for consistency and completeness

This approach leads to:
- Clearer requirements and fewer misunderstandings
- Better architectural decisions made upfront
- More predictable implementation timelines
- Higher quality code that matches specifications
- Easier onboarding for new team members
- Better documentation as a byproduct

## Repository Structure

```
specswarm/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace configuration
├── plugins/
│   └── speckit/                  # SpecKit plugin
│       ├── .claude-plugin/
│       │   └── plugin.json       # Plugin manifest
│       ├── commands/             # Slash commands
│       │   ├── analyze.md
│       │   ├── checklist.md
│       │   ├── clarify.md
│       │   ├── constitution.md
│       │   ├── implement.md
│       │   ├── plan.md
│       │   ├── specify.md
│       │   └── tasks.md
│       └── README.md             # Plugin documentation
├── README.md                     # This file
└── LICENSE                       # MIT License
```

## Attribution

### SpecKit Plugin

The SpecKit plugin is adapted from [GitHub's spec-kit project](https://github.com/github/spec-kit):

- **Original Work:** Copyright (c) GitHub, Inc.
- **Original License:** MIT License
- **Original Repository:** https://github.com/github/spec-kit
- **Adapted for Claude Code by:** Marty Bonacci

Key differences from the original:
- Integrated into Claude Code plugin system
- Removed Python CLI dependencies
- Commands run directly in Claude Code
- Preserved core SDD methodology

## Creating Your Own Plugins

Want to contribute a plugin to SpecSwarm? Follow these guidelines:

1. **Structure:** Follow the [Claude Code plugin structure](https://docs.claude.com/en/docs/claude-code/plugins)
2. **Documentation:** Provide clear README with usage examples
3. **Attribution:** Properly credit any adapted work
4. **Quality:** Test thoroughly before submitting
5. **License:** Use compatible open-source license (MIT preferred)

See [Claude Code plugin documentation](https://docs.claude.com/en/docs/claude-code/plugins) for technical details.

## Community & Support

- **GitHub Issues:** Report bugs or request features
- **Original spec-kit:** Questions about SDD methodology → [spec-kit repo](https://github.com/github/spec-kit)
- **Claude Code docs:** [Official documentation](https://docs.claude.com/en/docs/claude-code)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Individual plugins may have their own attributions and licenses. See each plugin's README for details.

## Acknowledgments

- **GitHub** for creating the original [spec-kit](https://github.com/github/spec-kit) project
- **Anthropic** for [Claude Code](https://docs.claude.com/en/docs/claude-code) and the plugin system
- All contributors to Spec-Driven Development methodology

## Learn More

- [Spec-Driven Development guide](https://github.com/github/spec-kit/blob/main/spec-driven.md)
- [Claude Code plugins documentation](https://docs.claude.com/en/docs/claude-code/plugins)
- [Claude Code plugin marketplaces](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)
- [GitHub spec-kit](https://github.com/github/spec-kit)
