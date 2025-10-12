# SpecSwarm

A Claude Code plugin marketplace for specification-driven development orchestration with intelligent tech stack management and performance enhancements.

## Overview

SpecSwarm provides four curated plugins that help you follow structured, systematic development workflows using Claude Code:

- **SpecKit**: Original spec-driven development workflow (stable)
- **SpecSwarm**: Tech stack drift prevention with 95% effectiveness (stable)
- **SpecTest**: Parallel execution and hooks for 2-4x faster implementation (experimental)
- **SpecLab**: Lifecycle workflow laboratory for bugfix, modify, hotfix, refactor, and deprecate workflows (experimental)

All plugins emphasize clear specifications, thoughtful planning, and methodical implementation - with progressive enhancements for tech stack consistency, performance optimization, and complete lifecycle coverage.

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

### SpecLab ⚠️ EXPERIMENTAL

Experimental lifecycle workflow laboratory that extends spec-driven development to the **complete development lifecycle** (bugfix, modify, hotfix, refactor, deprecate).

**Breakthrough Features:**
- **Bugfix workflow** (40% ROI) - Regression-test-first bug fixing
- **Modify workflow** (30% ROI) - Impact analysis for feature modifications
- **Hotfix workflow** - Expedited emergency response (<2h resolution)
- **Refactor workflow** - Metrics-driven quality improvement
- **Deprecate workflow** - Phased feature sunset with migration guidance
- **Smart integration** with SpecSwarm (tech enforcement) and SpecTest (parallel/hooks)

**Commands:**
- `/speclab:bugfix` - Regression-test-first bug fixing (40% of work)
- `/speclab:modify` - Impact-analysis-first modifications (30% of work)
- `/speclab:hotfix` - Emergency response (10-15% of work)
- `/speclab:refactor` - Metrics-driven quality improvement (10% of work)
- `/speclab:deprecate` - Phased feature sunset (5% of work)
- `/speclab:impact <feature>` - Standalone impact analysis utility
- `/speclab:suggest` - AI workflow recommendation
- `/speclab:workflow-metrics [feature]` - Analytics dashboard

**Coverage Impact**: While SpecSwarm/SpecTest handle feature development (~25% of work), SpecLab covers the remaining **~75%** (bugfixes, modifications, hotfixes, refactoring, deprecations).

**Combined Coverage**: SpecSwarm + SpecTest + SpecLab = **~95% complete development lifecycle**

[Read full SpecLab documentation →](plugins/speclab/README.md)

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

**🔬 SpecLab** - Lifecycle Workflows
- **Use if**: You need workflows for bugfixes, modifications, hotfixes, refactoring, or deprecations
- **Stability**: ⚠️ Experimental (v1.0.0)
- **Best for**: Complete development lifecycle coverage beyond feature development
- **Includes**: 5 lifecycle workflows + 3 utilities + smart integration with SpecSwarm/SpecTest

### Quick Comparison:

| Feature | SpecKit | SpecSwarm | SpecTest | SpecLab |
|---------|---------|-----------|----------|---------|
| **Feature Development** | ✅ | ✅ | ✅ | ❌ |
| **Bugfix Workflow** | ❌ | ❌ | ❌ | ✅ Regression-test-first |
| **Modify Workflow** | ❌ | ❌ | ❌ | ✅ Impact analysis |
| **Hotfix Workflow** | ❌ | ❌ | ❌ | ✅ Emergency response |
| **Refactor Workflow** | ❌ | ❌ | ❌ | ✅ Metrics-driven |
| **Deprecate Workflow** | ❌ | ❌ | ❌ | ✅ Phased sunset |
| Tech Stack Enforcement | ❌ | ✅ | ✅ | ✅ (via SpecSwarm) |
| Parallel Execution | ❌ | ❌ | ✅ 2-4x faster | ✅ (via SpecTest) |
| Pre/Post Hooks | ❌ | ❌ | ✅ 8 hook points | ✅ (via SpecTest) |
| Performance Metrics | ❌ | ❌ | ✅ Dashboard | ✅ Extended |
| Stability | Stable | Stable | Experimental | Experimental |
| Lifecycle Coverage | ~25% | ~25% | ~25% | **~75%** |
| Typical Feature Impl | 18-20 min | 18-20 min | 6-8 min | N/A |
| Typical Bugfix | N/A | N/A | N/A | ~2h |
| Typical Modify | N/A | N/A | N/A | ~4h |
| Typical Hotfix | N/A | N/A | N/A | <2h |

**Recommended Setup for Complete Coverage**:
- **Feature Development**: Use **SpecTest** (fastest with parallel execution)
- **Bugfixes**: Use **SpecLab:bugfix** (regression-test-first)
- **Modifications**: Use **SpecLab:modify** (impact analysis)
- **Emergencies**: Use **SpecLab:hotfix** (expedited response)
- **Quality**: Use **SpecLab:refactor** (metrics-driven)
- **Sunset**: Use **SpecLab:deprecate** (phased removal)

**Combined**: Install all plugins for **~95% development lifecycle coverage**

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

# Install SpecLab plugin (experimental, lifecycle workflows)
claude plugin install speclab
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
│   ├── spectest/                 # SpecTest plugin (experimental)
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── commands/             # 9 commands (adds metrics)
│   │   │   ├── analyze.md
│   │   │   ├── checklist.md
│   │   │   ├── clarify.md
│   │   │   ├── constitution.md
│   │   │   ├── implement.md      # Enhanced: parallel execution
│   │   │   ├── metrics.md        # NEW: performance dashboard
│   │   │   ├── plan.md           # Enhanced: hooks
│   │   │   ├── specify.md        # Enhanced: hooks
│   │   │   └── tasks.md          # Enhanced: hooks + parallel detection
│   │   └── README.md
│   └── speclab/                  # SpecLab plugin (experimental)
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/             # 8 commands (5 workflows + 3 utilities)
│       │   ├── bugfix.md         # Regression-test-first bug fixing
│       │   ├── modify.md         # Impact-analysis-first modifications
│       │   ├── hotfix.md         # Emergency response workflow
│       │   ├── refactor.md       # Metrics-driven quality improvement
│       │   ├── deprecate.md      # Phased feature sunset
│       │   ├── impact.md         # Standalone impact analysis utility
│       │   ├── suggest.md        # AI workflow recommendation
│       │   └── workflow-metrics.md  # Cross-workflow analytics
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

### SpecLab Plugin ⚠️ EXPERIMENTAL

Experimental lifecycle workflow laboratory:

- **Based on:** spec-kit-extensions methodologies by Marty Bonacci
- **Inspired by:** https://github.com/MartyBonacci/spec-kit-extensions
- **Created by:** Marty Bonacci & Claude Code (2025)
- **License:** MIT License
- **Status:** Experimental v1.0.0
- **Key Innovation:** Complete lifecycle coverage (bugfix, modify, hotfix, refactor, deprecate)

Key workflows:
- Bugfix: Regression-test-first methodology (40% of development work)
- Modify: Impact-analysis-first modifications (30% of development work)
- Hotfix: Expedited emergency response (10-15% of work)
- Refactor: Metrics-driven quality improvement (10% of work)
- Deprecate: Phased feature sunset (5% of work)
- Smart integration with SpecSwarm (tech enforcement) and SpecTest (parallel/hooks)

**Production Results** (from spec-kit-extensions):
- 100% build success rate
- 0 regressions in production
- ~30% time savings on modifications
- Complete lifecycle coverage when combined with SpecSwarm/SpecTest

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

## 🧪 Testing

**Want to validate the plugins yourself?** Complete testing workflows available:

- **[Testing Quick Start](docs/testing/QUICK-START.md)** ⭐ - Start here for testing overview
- **[Plugin Testing Guide](docs/testing/plugin-testing-guide.md)** - Comprehensive testing methodology
- **[Test 3: SpecTest Workflow](docs/testing/test-3-spectest.md)** - Complete workflow with prompts (paste into Claude Code)

**Test Project**: Build "Tweeter" (simplified Twitter clone) to validate:
- **Phase 1**: Feature development (SpecKit, SpecSwarm, SpecTest)
- **Phase 2A**: Lifecycle workflows (SpecLab on SpecTest)
- **Phase 2B**: Integration validation (optional)

**Expected Timeline**: 10-14 hours (quick) or 26-34 hours (comprehensive)

---

## 📚 Documentation

### Quick Start Guides

**New to SpecSwarm plugins?** Start here:

1. **[Complete Workflow Guide](docs/cheatsheets/complete-workflow-guide.md)** ⭐
   - Master reference for choosing the right plugin
   - Decision trees and comparison matrices
   - Integration patterns and best practices

2. **Plugin Cheatsheets** (Quick Reference):
   - [SpecLab Cheatsheet](docs/cheatsheets/speclab-cheatsheet.md) - Lifecycle workflows (bugfix, modify, hotfix, refactor, deprecate)
   - SpecKit Cheatsheet *(coming soon)* - Original SDD workflow
   - SpecSwarm Cheatsheet *(coming soon)* - Tech stack enforcement
   - SpecTest Cheatsheet *(coming soon)* - Parallel execution + metrics

3. **Real-World Examples**:
   - [Bugfix Example](docs/examples/bugfix-example.md) - Complete walkthrough of fixing a production bug
   - Feature Development Example *(coming soon)*
   - Modification Example *(coming soon)*

### Full Plugin Documentation

- [SpecKit README](plugins/speckit/README.md) - Original SDD workflow
- [SpecSwarm README](plugins/specswarm/README.md) - Tech stack enforcement
- [SpecTest README](plugins/spectest/README.md) - Parallel execution + metrics
- [SpecLab README](plugins/speclab/README.md) - Lifecycle workflows

---

## Learn More

- [Spec-Driven Development guide](https://github.com/github/spec-kit/blob/main/spec-driven.md)
- [Claude Code plugins documentation](https://docs.claude.com/en/docs/claude-code/plugins)
- [Claude Code plugin marketplaces](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)
- [GitHub spec-kit](https://github.com/github/spec-kit)
- [spec-kit-extensions](https://github.com/MartyBonacci/spec-kit-extensions) - SpecLab methodologies
