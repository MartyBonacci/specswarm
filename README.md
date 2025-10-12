# SpecSwarm

A Claude Code plugin marketplace for specification-driven development orchestration with intelligent tech stack management and performance enhancements.

## Overview

SpecSwarm provides three curated plugins that help you follow structured, systematic development workflows using Claude Code:

- **SpecKit**: Original spec-driven development workflow (stable)
- **SpecSwarm**: Tech stack drift prevention with 95% effectiveness (stable)
- **SpecTest**: Parallel execution and hooks for 2-4x faster implementation (experimental)

All plugins emphasize clear specifications, thoughtful planning, and methodical implementation - with progressive enhancements for tech stack consistency and performance optimization.

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

---

### SpecSwarm

Enhanced version of SpecKit with **95% tech stack drift prevention** through intelligent validation.

**Unique Features:**
- 8 slash commands with tech stack management
- Auto-detection of project technologies
- Automatic validation at plan/task/implement phases
- Conflict detection with approval workflows
- Hard blocking of prohibited technologies
- Semantic versioning for tech changes

**Key Enhancement**: Prevents tech stack drift across features by maintaining `/memory/tech-stack.md` and validating all technology choices at every workflow phase.

**Commands:**
- `/specswarm:constitution` - Establish principles + tech enforcement
- `/specswarm:specify` - Define specifications
- `/specswarm:clarify` - Resolve ambiguities
- `/specswarm:plan` - Create plans **+ auto tech validation**
- `/specswarm:tasks` - Generate tasks **+ tech pre-validation**
- `/specswarm:implement` - Execute **+ runtime enforcement**
- `/specswarm:analyze` - Validate consistency
- `/specswarm:checklist` - Create quality checklists

[Read full SpecSwarm documentation →](plugins/specswarm/README.md)

---

### SpecTest ⚠️ EXPERIMENTAL

Experimental fork of SpecSwarm with **Phase 1 performance enhancements**: parallel execution, hooks system, and performance metrics.

**Breakthrough Features:**
- **2-4x faster implementation** via parallel task execution
- **Pre/post operation hooks** for automation and validation
- **Performance analytics dashboard** with `/spectest:metrics`
- All SpecSwarm tech stack features preserved

**Phase 1 Complete (Core Workflow)**:
- `/spectest:specify` - With pre/post hooks, quality validation
- `/spectest:plan` - With hooks, tech stack summary
- `/spectest:tasks` - With hooks, parallel detection, execution preview
- `/spectest:implement` - With hooks, **parallel batching** (2-4x faster!)
- `/spectest:metrics` - **NEW**: Performance dashboard

**Performance Impact**: Typical feature implementation drops from ~18-20 minutes to ~6-8 minutes.

[Read full SpecTest documentation →](plugins/spectest/README.md)

---

## Which Plugin Should I Use?

### Choose Based on Your Needs:

**🎯 SpecKit** - Original SDD Workflow
- **Use if**: You want the pure, proven spec-driven development methodology
- **Stability**: ✅ Stable
- **Best for**: Teams new to SDD, conservative environments

**🛡️ SpecSwarm** - Tech Stack Enforcement
- **Use if**: You need tech stack consistency across features
- **Stability**: ✅ Stable
- **Best for**: Multi-developer teams, long-lived projects, preventing drift
- **Includes**: Everything from SpecKit + tech validation

**⚡ SpecTest** - Performance Enhanced
- **Use if**: You want maximum speed and workflow automation
- **Stability**: ⚠️ Experimental (alpha)
- **Best for**: Solo developers, experimental projects, performance-critical workflows
- **Includes**: Everything from SpecSwarm + parallel execution + hooks + metrics

### Quick Comparison:

| Feature | SpecKit | SpecSwarm | SpecTest |
|---------|---------|-----------|----------|
| SDD Workflow | ✅ | ✅ | ✅ |
| Tech Stack Enforcement | ❌ | ✅ | ✅ |
| Parallel Execution | ❌ | ❌ | ✅ 2-4x faster |
| Pre/Post Hooks | ❌ | ❌ | ✅ 8 hook points |
| Performance Metrics | ❌ | ❌ | ✅ Dashboard |
| Stability | Stable | Stable | Experimental |
| Typical Implementation | 18-20 min | 18-20 min | 6-8 min |

**Recommendation**: Start with **SpecSwarm** (stable + tech enforcement), then consider **SpecTest** when you want speed.

---

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
# Install SpecKit plugin (stable, original SDD workflow)
claude plugin install speckit

# Install SpecSwarm plugin (stable, with tech stack management)
claude plugin install specswarm

# Install SpecTest plugin (experimental, with parallel execution + hooks)
claude plugin install spectest
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
│   ├── speckit/                  # SpecKit plugin (original)
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── commands/             # 8 SDD commands
│   │   │   ├── analyze.md
│   │   │   ├── checklist.md
│   │   │   ├── clarify.md
│   │   │   ├── constitution.md
│   │   │   ├── implement.md
│   │   │   ├── plan.md
│   │   │   ├── specify.md
│   │   │   └── tasks.md
│   │   └── README.md
│   ├── specswarm/                # SpecSwarm plugin (tech stack enforcement)
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── commands/             # 8 commands + tech validation
│   │   │   ├── analyze.md
│   │   │   ├── checklist.md
│   │   │   ├── clarify.md
│   │   │   ├── constitution.md
│   │   │   ├── implement.md
│   │   │   ├── plan.md
│   │   │   ├── specify.md
│   │   │   └── tasks.md
│   │   └── README.md
│   └── spectest/                 # SpecTest plugin (experimental)
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/             # 9 commands (adds metrics)
│       │   ├── analyze.md
│       │   ├── checklist.md
│       │   ├── clarify.md
│       │   ├── constitution.md
│       │   ├── implement.md      # Enhanced: parallel execution
│       │   ├── metrics.md        # NEW: performance dashboard
│       │   ├── plan.md           # Enhanced: hooks
│       │   ├── specify.md        # Enhanced: hooks
│       │   └── tasks.md          # Enhanced: hooks + parallel detection
│       └── README.md
├── README.md                     # This file
└── LICENSE                       # MIT License
```

## Attribution

### SpecKit Plugin

The SpecKit plugin is adapted from [GitHub's spec-kit project](https://github.com/github/spec-kit):

- **Original Work:** Copyright (c) GitHub, Inc.
- **Original License:** MIT License
- **Original Repository:** https://github.com/github/spec-kit
- **Adapted for Claude Code by:** Marty Bonacci (2025)

Key differences from the original:
- Integrated into Claude Code plugin system
- Removed Python CLI dependencies
- Commands run directly in Claude Code
- Preserved core SDD methodology

### SpecSwarm Plugin

Enhanced fork of SpecKit with tech stack management:

- **Based on:** SpecKit plugin (adapted from GitHub spec-kit)
- **Enhanced by:** Marty Bonacci & Claude Code (2025)
- **License:** MIT License
- **Key Innovation:** 95% tech stack drift prevention

Key enhancements:
- Tech stack auto-detection and validation
- Semantic versioning for technology changes
- Runtime enforcement of prohibited technologies
- Constitutional tech stack governance
- Auto-addition of non-conflicting libraries
- Conflict detection with approval workflows

### SpecTest Plugin ⚠️ EXPERIMENTAL

Experimental fork of SpecSwarm with performance enhancements:

- **Based on:** SpecSwarm plugin
- **Enhanced by:** Marty Bonacci & Claude Code (2025)
- **License:** MIT License
- **Status:** Alpha - Phase 1 complete
- **Key Innovation:** 2-4x faster implementation via parallel execution

Phase 1 enhancements:
- Parallel task execution (2-4x speedup)
- Pre/post operation hooks (8 hook points on core commands)
- Performance metrics and analytics dashboard
- All SpecSwarm tech stack features preserved
- Intelligent next-step suggestions

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
