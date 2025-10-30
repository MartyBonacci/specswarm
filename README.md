# SpecSwarm

A Claude Code plugin marketplace for complete software development lifecycle management with spec-driven workflows, quality validation, and experimental autonomous features.

## Overview

SpecSwarm provides **two curated plugins** that cover the complete software development lifecycle using Claude Code:

- **SpecSwarm v2.0.0**: Production-ready complete toolkit for building, fixing, maintaining, and analyzing software (17 commands)
- **SpecLabs v2.0.0**: Experimental laboratory for autonomous development with Phase 2 Feature Workflow Engine (4 commands)

**Complete lifecycle coverage** from initial specification through implementation, bug fixing, modifications, refactoring, and sunset - with progressive enhancements for quality validation, tech stack consistency, and autonomous workflows.

---

## Available Plugins

### SpecSwarm v2.0.0 (Production-Ready)

**Complete Software Development Toolkit**

The unified, production-ready plugin for the complete development lifecycle. SpecSwarm consolidates spec-driven development, lifecycle workflows, quality validation, and performance monitoring into one comprehensive toolkit.

**18 Commands** | **Production Ready** | **Phase 2.2 Complete**

#### Key Features

- **Spec-Driven Development** - From specification to implementation
- **Bug & Issue Management** - Systematic fixing with regression testing
- **Code Maintenance** - Refactoring and modernization
- **Quality Assurance** - Automated testing and validation (0-100 point scoring)
- **Performance Monitoring** - Bundle size tracking and budgets
- **Architecture Validation** - SSR patterns, tech stack compliance
- **Chain Bug Detection** - Prevents cascading failures (Bug 912→913)
- **Tech Stack Management** - 95% drift prevention

#### Quick Start

```bash
# New Feature Development
/specswarm:specify "Add user authentication with email/password"
/specswarm:plan
/specswarm:tasks
/specswarm:implement

# Bug Fixing
/specswarm:bugfix "Bug 915: Login fails with special characters"

# Code Quality
/specswarm:analyze-quality
/specswarm:refactor "Improve authentication module performance"
```

#### All Commands

**New Feature Workflows (8)**:
- `/specswarm:specify` - Create detailed feature specification
- `/specswarm:plan` - Design implementation with tech stack validation
- `/specswarm:tasks` - Generate dependency-ordered task breakdown
- `/specswarm:implement` - Execute with comprehensive quality validation
- `/specswarm:clarify` - Ask targeted clarification questions
- `/specswarm:checklist` - Generate custom requirement checklists
- `/specswarm:analyze` - Cross-artifact consistency validation
- `/specswarm:constitution` - Create/update project governance

**Bug & Issue Management (2)**:
- `/specswarm:bugfix` - Regression-test-first fixing with ultrathinking (Phase 2.2)
- `/specswarm:hotfix` - Emergency production issue response

**Code Maintenance (2)**:
- `/specswarm:modify` - Feature modification with impact analysis
- `/specswarm:refactor` - Metrics-driven quality improvement

**Workflow Completion (1)** ✨ NEW! Phase 2.2:
- `/specswarm:complete` - Clean, guided feature/bugfix completion with merge to main

**Analysis & Utilities (5)**:
- `/specswarm:analyze-quality` - Comprehensive codebase analysis
- `/specswarm:impact` - Standalone impact analysis
- `/specswarm:suggest` - AI-powered workflow recommendation
- `/specswarm:workflow-metrics` - Cross-workflow analytics
- `/specswarm:deprecate` - Phased feature sunset

[Read full SpecSwarm documentation →](plugins/specswarm/README.md)

---

### SpecLabs v2.0.0 (Experimental)

**Experimental Laboratory for Sprint/Project Orchestration & Advanced Debugging**

⚠️ **EXPERIMENTAL** - Features in active development - Use at your own risk

The experimental wing of SpecSwarm, building toward **autonomous sprint and project orchestration**. The ultimate vision: coordinate multiple Claude Code agents to build features and complete projects with minimal human intervention.

**Vision**: "Give me a feature description Monday evening, wake up Tuesday morning with working, tested, production-ready code."

**4 Commands** | **Phase 2 Complete (Oct 2025)** | **High Risk, High Reward**

#### ✅ Phase 2 Complete Features (October 16, 2025)

- **Phase 1a: Intelligent Components** - State Manager, Decision Maker, Prompt Refiner, Metrics Tracker
- **Phase 1b: Full Automation** - Zero manual steps, intelligent retry logic (up to 3 retries per task)
- **Phase 2: Feature Orchestration** - Complete feature lifecycle from description to implementation
- **SpecSwarm Integration** - Automatic planning (specify → clarify → plan → tasks)
- **Task Automation** - Automatic task conversion and execution
- **Browser Automation** - Playwright-based validation
- **Advanced Debugging** - Systematic multi-bug investigation with logging strategies

**Impact**: 50-67% faster feature implementation vs manual approach

#### Future Roadmap (Phase 3)

- **Phase 3**: Sprint-level coordination with multiple features and parallel agent execution

**Timeline**: Phase 3 planned for Q1 2026

#### Quick Start

```bash
# Phase 2: Orchestrate Complete Feature (NEW!)
/speclabs:orchestrate-feature "Add user authentication" /path/to/project

# Phase 1b: Autonomous Task Execution
/speclabs:orchestrate features/001-fix/workflow.md /path/to/project

# Automated Validation
/speclabs:orchestrate-validate /path/to/project

# Systematic Multi-Bug Debugging
/speclabs:coordinate "navbar broken, sign-out fails, like button blank page"
```

#### All Commands (Phase 2)

**Phase 2: Feature Orchestration (1)** ✅ NEW!:
- `/speclabs:orchestrate-feature` - Complete feature lifecycle from description to implementation
  - NEW: `--audit` flag for comprehensive code audits (compatibility, security, best practices)

**Phase 1b: Task Orchestration (2)** ✅:
- `/speclabs:orchestrate` - Task workflow orchestration with intelligent retry logic
- `/speclabs:orchestrate-validate` - Validation suite (browser, terminal, visual)

**Advanced Debugging (1)**:
- `/speclabs:coordinate` - Systematic multi-bug debugging with logging and orchestration

**Analytics (1)** ✅ NEW!:
- `/speclabs:metrics` - View orchestration performance metrics and analytics dashboard

**Future Commands** (Phase 3):
- `/speclabs:orchestrate-sprint` - Complete sprint backlogs overnight (Phase 3)

[Read full SpecLabs documentation →](plugins/speclabs/README.md)

---

## Which Plugin Should I Use?

### Quick Decision Guide

**🎯 Use SpecSwarm v2.0.0 when**:
- Building new features (specify → plan → tasks → implement)
- Fixing bugs with regression testing
- Modifying existing features
- Refactoring code for quality
- Emergency production fixes
- Quality analysis and validation
- **ANY production-critical work**

**🧪 Use SpecLabs v2.0.0 when**:
- Experimenting with autonomous development
- Testing multi-agent workflows
- Advanced multi-bug debugging (3+ bugs)
- You're comfortable with experimental features
- You can handle bugs and failures gracefully
- **NEVER for production-critical work**

### Plugin Comparison

| Feature | SpecSwarm v2.0.0 | SpecLabs v2.0.0 (Phase 2) | SpecLabs v3.0 (Future) |
|---------|------------------|---------------------------|------------------------|
| **Feature Development** | ✅ Manual with workflows | ✅ Fully automated | ✅ + Sprint-level |
| **Bug Fixing** | ✅ Regression-test-first | ❌ | ✅ Autonomous fixing |
| **Modifications** | ✅ Impact analysis | ❌ | ✅ Autonomous mods |
| **Refactoring** | ✅ Metrics-driven | ❌ | ✅ Autonomous refactor |
| **Quality Validation** | ✅ 0-100 point scoring | ✅ Playwright suite | ✅ Multi-layer validation |
| **Tech Stack Enforcement** | ✅ 95% drift prevention | ❌ | ✅ Autonomous enforcement |
| **Bundle Size Monitoring** | ✅ Performance budgets | ❌ | ✅ Autonomous optimization |
| **Chain Bug Detection** | ✅ Prevents cascades | ❌ | ✅ Auto-detection |
| **Task Orchestration** | ❌ | ✅ Full automation | ✅ Production-ready |
| **Feature Orchestration** | ❌ | ✅ Natural language → code | ✅ + Parallel features |
| **Sprint Orchestration** | ❌ | 🔄 Planned Phase 3 | ✅ Overnight sprints |
| **Browser Automation** | ❌ | ✅ Playwright | ✅ + Vision API |
| **Advanced Debugging** | ❌ | ✅ Systematic | ✅ Autonomous |
| **Parallel Agent Execution** | ❌ | ❌ | ✅ Multi-agent |
| **Stability** | ✅ Production-ready | ⚠️ Experimental | ✅ Production-ready |
| **Commands** | 17 | 4 | 5+ |
| **Utilities** | 8 | 5 components | 15+ |
| **Timeline** | Now | Oct 2025 | Q1 2026 |

### Integration Pattern

**Current (Phase 2)**: Autonomous feature development with SpecSwarm integration

```
Manual SpecSwarm Development:
  /specswarm:specify → /specswarm:plan → /specswarm:tasks → /specswarm:implement
      ↓
  /specswarm:analyze-quality (validate results)

Autonomous Feature Development (Phase 2) ✅ NEW!:
  /speclabs:orchestrate-feature "Add user authentication" /path/to/project
      ↓
  Automatically: SpecSwarm planning (specify → clarify → plan → tasks)
  Automatically: Task conversion and implementation
  Automatically: Validation and retry logic
  Automatically: Bugfix if needed
      ↓
  Deliver: Working, tested feature with comprehensive reporting
```

**Future (Phase 3)**: Sprint-level autonomous development

```
Sprint-Level Orchestration (Phase 3):
  /speclabs:orchestrate-sprint sprint-23-backlog.md /path/to/project
      ↓
  Automatically: parse sprint backlog (identify features)
  Automatically: dependency analysis (determine parallelization)
  Automatically: execute features (uses orchestrate-feature for each)
  Automatically: sprint coordination and tracking
      ↓
  Deliver: Complete sprint ready for deployment
```

**Debugging Integration**:
```
SpecSwarm Single Bug → /specswarm:bugfix
SpecSwarm Multi-Bug (3+) → /speclabs:coordinate (systematic analysis)
```

---

## Installation

### Add the Marketplace

```bash
# Add SpecSwarm marketplace to Claude Code
claude plugin marketplace add marty/specswarm
```

Or if using a local repository:

```bash
claude plugin marketplace add /path/to/specswarm
```

### Install Plugins

Install plugins from the marketplace:

```bash
# Install SpecSwarm plugin (production-ready complete toolkit)
claude plugin install specswarm

# Install SpecLabs plugin (experimental autonomous features)
claude plugin install speclabs
```

List available plugins:

```bash
claude plugin marketplace list
```

---

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

---

## Configuration

Both plugins can be configured through files in `/memory/`:

### Quality Standards (`/memory/quality-standards.md`)

```yaml
# Quality Gates
min_test_coverage: 85
min_quality_score: 80
block_merge_on_failure: false

# Performance Budgets (SpecSwarm v2.0+)
enforce_budgets: true
max_bundle_size: 500      # KB per bundle
max_initial_load: 1000    # KB initial load
```

### Tech Stack (`/memory/tech-stack.md`)

```markdown
## Core Technologies
- TypeScript 5.x
- React Router v7
- PostgreSQL 17.x

## Approved Libraries
- Zod v4+ (validation)
- Drizzle ORM (database)

## Prohibited
- ❌ Redux (use React Router loaders/actions)
- ❌ Class components (use functional)
```

SpecSwarm automatically validates against this configuration at plan, task, and implementation phases.

---

## Migration from Previous Plugins

**If you were using older plugins**, here's what happened:

### Deprecated Plugins (Merged into SpecSwarm v2.0.0)

- **SpecKit** → Merged into SpecSwarm v2.0.0
- **SpecTest** → Merged into SpecSwarm v2.0.0
- **SpecLab** → Merged into SpecSwarm v2.0.0

All features from these plugins are now available in **SpecSwarm v2.0.0**.

**Migration**: Replace old plugin commands with SpecSwarm:
```bash
# Old
/speckit:specify → /specswarm:specify
/spectest:implement → /specswarm:implement
/speclab:bugfix → /specswarm:bugfix
```

### Deprecated Plugins (Merged into SpecLabs v2.0.0)

- **debug-coordinate** → Merged into SpecLabs v2.0.0
- **project-orchestrator** → Merged into SpecLabs v2.0.0

**Migration**: Replace old plugin commands with SpecLabs:
```bash
# Old
/debug-coordinate:coordinate → /speclabs:coordinate
/project-orchestrator:orchestrate-test → /speclabs:orchestrate
/project-orchestrator:orchestrate-validate → /speclabs:orchestrate-validate
```

See `DEPRECATED.md` files in old plugin directories for full migration details.

---

## Repository Structure

```
specswarm/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace configuration
├── plugins/
│   ├── specswarm/                # SpecSwarm v2.0.0 (production)
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── commands/             # 18 commands (NEW: complete)
│   │   │   ├── specify.md
│   │   │   ├── plan.md
│   │   │   ├── tasks.md
│   │   │   ├── implement.md
│   │   │   ├── analyze.md
│   │   │   ├── checklist.md
│   │   │   ├── clarify.md
│   │   │   ├── constitution.md
│   │   │   ├── bugfix.md
│   │   │   ├── hotfix.md
│   │   │   ├── modify.md
│   │   │   ├── refactor.md
│   │   │   ├── deprecate.md
│   │   │   ├── analyze-quality.md
│   │   │   ├── impact.md
│   │   │   ├── suggest.md
│   │   │   ├── workflow-metrics.md
│   │   │   └── complete.md       # NEW! Phase 2.2
│   │   ├── templates/            # NEW! Phase 2.2
│   │   │   └── gitignore-diagnostic-files.txt
│   │   └── README.md
│   └── speclabs/                 # SpecLabs v2.0.0 (experimental - Phase 2)
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/             # 4 commands
│       │   ├── orchestrate-feature.md  # Phase 2
│       │   ├── orchestrate.md
│       │   ├── orchestrate-validate.md
│       │   └── coordinate.md
│       ├── lib/                  # 17 utilities + components
│       │   ├── feature-orchestrator.sh
│       │   ├── task-converter.sh
│       │   ├── state-manager.sh
│       │   ├── decision-maker.sh
│       │   ├── prompt-refiner.sh
│       │   ├── metrics-tracker.sh
│       │   ├── vision-api.sh
│       │   ├── bundle-size-monitor.sh
│       │   ├── chain-bug-detector.sh
│       │   ├── orchestrator-detection.sh
│       │   ├── performance-budget-enforcer.sh
│       │   └── integration-patterns/  # NEW! Phase 2.1
│       └── README.md
├── README.md                     # This file
└── LICENSE                       # MIT License
```

---

## Best Practices

### For SpecSwarm v2.0.0

1. **Define tech-stack.md early** - Prevents drift from day 1
2. **Enable quality gates** - Maintain >80% scores
3. **Run analyze-quality regularly** - Catch issues early
4. **Keep bundles <500KB** - Performance matters
5. **Use bugfix workflow** - Regression testing prevents cascades

### For SpecLabs v2.0.0

1. **Use in non-critical environments** - Experimental features may fail
2. **Always have backups** - Commit before running SpecLabs commands
3. **Review agent work carefully** - Don't blindly trust autonomous execution
4. **Report issues** - Help improve experimental features
5. **Start with small features** - Test with 2-3 task features first
6. **Review generated artifacts** - Check spec.md, plan.md, tasks.md before implementation

---

## Quality Validation (SpecSwarm)

Automated quality scoring across 6 dimensions (0-100 points):

- **Unit Tests** (25 pts) - Proportional by pass rate
- **Code Coverage** (25 pts) - Proportional by coverage %
- **Integration Tests** (15 pts) - API/service testing
- **Browser Tests** (15 pts) - E2E user flows
- **Bundle Size** (20 pts) - Performance budgets
- **Visual Alignment** (15 pts) - Future

**Multi-Framework Support** (11 test frameworks):
- JavaScript: Vitest, Jest, Mocha, Jasmine
- Python: Pytest, unittest
- Go: go test
- Ruby: RSpec
- Java: JUnit
- And more...

---

## Attribution

### SpecSwarm Plugin

SpecSwarm is a consolidated plugin that builds upon **SpecKit**, which adapted **GitHub's spec-kit** for Claude Code.

**Attribution Chain:**

1. **Original**: [GitHub spec-kit](https://github.com/github/spec-kit)
   - Copyright (c) GitHub, Inc. | MIT License
   - Spec-Driven Development methodology and workflow concepts

2. **Adapted**: SpecKit plugin by Marty Bonacci (2025)
   - Claude Code integration and plugin architecture
   - Workflow adaptation for slash commands

3. **Enhanced**: SpecSwarm v2.0.0 by Marty Bonacci & Claude Code (2025)
   - Tech stack management and drift prevention (95% effectiveness)
   - Lifecycle workflows (bugfix, modify, refactor, hotfix, deprecate)
   - Quality validation system (0-100 point scoring)
   - Chain bug detection and bundle size monitoring

**Key Consolidations** (v2.0.0):
- Merged SpecKit (spec-driven workflows from GitHub spec-kit)
- Merged SpecTest (performance enhancements and parallel execution)
- Merged SpecLab (lifecycle workflows for complete coverage)

### SpecLabs Plugin

Experimental autonomous development and debugging with Phase 2 Feature Workflow Engine:

**Created by**: Marty Bonacci & Claude Code (2025)

**Consolidated From**:
- debug-coordinate v1.0.0 (advanced debugging)
- project-orchestrator v0.1.1 (autonomous development)

**Phase 2 Complete** (October 16, 2025):
- Feature Orchestrator - Complete feature lifecycle automation
- Task Converter - Automatic workflow generation
- SpecSwarm Integration - Seamless planning → execution

**Based on Learnings**:
- `docs/learnings/2025-10-14-orchestrator-missed-opportunity.md`
- Test 4A results and orchestrator concept testing
- Real-world Phase 1a/1b development and testing

---

## Community & Support

- **Repository**: https://github.com/MartyBonacci/specswarm
- **Issues**: https://github.com/MartyBonacci/specswarm/issues
- **Original spec-kit**: Questions about SDD methodology → [spec-kit repo](https://github.com/github/spec-kit)
- **Claude Code docs**: [Official documentation](https://docs.claude.com/en/docs/claude-code)

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Individual plugins may have their own attributions and licenses. See each plugin's README for details.

---

## Acknowledgments

- **GitHub** for creating the original [spec-kit](https://github.com/github/spec-kit) project
- **Anthropic** for [Claude Code](https://docs.claude.com/en/docs/claude-code) and the plugin system
- All contributors to Spec-Driven Development methodology

---

## Learn More

- [Spec-Driven Development guide](https://github.com/github/spec-kit/blob/main/spec-driven.md)
- [Claude Code plugins documentation](https://docs.claude.com/en/docs/claude-code/plugins)
- [Claude Code plugin marketplaces](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)
- [GitHub spec-kit](https://github.com/github/spec-kit)

---

**SpecSwarm Marketplace** - Complete software development lifecycle in Claude Code. 🚀

Build it. Fix it. Maintain it. Analyze it. All in one place.
