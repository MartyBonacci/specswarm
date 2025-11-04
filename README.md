# SpecSwarm

**Build features, fix bugs, and maintain code with autonomous AI workflows for Claude Code.**

SpecSwarm is a plugin marketplace that brings spec-driven development and autonomous orchestration to Claude Code. Write specifications, generate plans, and let AI handle the implementation - from initial feature development through bug fixes, refactoring, and production deployments.

---

## Quick Start

### 1. Install the Marketplace

```bash
# From GitHub
/plugin https://github.com/MartyBonacci/specswarm
```

### 2. Install Plugins

```bash
# Production-ready complete toolkit (recommended)
/plugin install specswarm

# Experimental autonomous features (optional)
/plugin install speclabs
```

### 3. Build Your First Feature

```bash
# Create a detailed specification
/specswarm:specify "Add user authentication with email and password"

# Generate implementation plan
/specswarm:plan

# Break down into actionable tasks
/specswarm:tasks

# Execute implementation
/specswarm:implement

# Complete and merge
/specswarm:complete
```

**Or use autonomous orchestration** (SpecLabs - experimental):

```bash
/speclabs:orchestrate-feature "Add user authentication with email/password" --validate
```

This single command will autonomously: generate spec, create plan, build tasks, implement, validate in browser, and deliver a complete feature.

---

## What's Included?

### SpecSwarm v2.1.1 (Production-Ready) ⭐

Complete software development lifecycle toolkit with 17 commands covering:

- **New Features**: `specify` → `plan` → `tasks` → `implement` → `complete`
- **Bug Fixing**: `bugfix` with regression testing, `hotfix` for emergencies
- **Code Maintenance**: `modify`, `refactor`, `deprecate`
- **Quality**: `analyze-quality`, `impact` analysis, `workflow-metrics`

**Status**: ✅ Production-ready | Stable | Safe for critical work

### SpecLabs v2.7.1 (Experimental) 🧪

Autonomous orchestration and advanced debugging:

- **Feature Orchestration**: `orchestrate-feature` - complete lifecycle automation
- **Validation**: `validate-feature` - multi-type validation (webapp, android, REST API, desktop)
- **Debugging**: `coordinate` - systematic multi-bug investigation
- **Analytics**: `metrics` - orchestration performance tracking

**Status**: ⚠️ Experimental | Active development | Use at own risk

---

## Core Concepts

### Spec-Driven Development

Write clear specifications before coding. This approach leads to:

✅ Fewer misunderstandings and requirement changes
✅ Better architectural decisions made upfront
✅ More predictable timelines
✅ Higher quality code that matches specs
✅ Better documentation as a byproduct

### Workflow Pattern

**Manual (SpecSwarm)**:
```
specify → clarify → plan → tasks → implement → analyze-quality → complete
```

**Autonomous (SpecLabs)**:
```
orchestrate-feature → [everything happens automatically] → done
```

---

## Real-World Examples

### Example 1: Add a New Feature

```bash
# Manual approach (full control)
/specswarm:specify "Add shopping cart with product quantity adjustment"
/specswarm:plan
/specswarm:tasks
/specswarm:implement

# Autonomous approach (faster, experimental)
/speclabs:orchestrate-feature "Add shopping cart" /path/to/project --validate
```

### Example 2: Fix a Bug

```bash
# Regression-test-first bug fixing
/specswarm:bugfix "Bug 915: Login fails when email contains plus sign"
```

### Example 3: Refactor Code

```bash
# Metrics-driven refactoring
/specswarm:refactor "Improve authentication module performance by 30%"
```

### Example 4: Quality Analysis

```bash
# Comprehensive codebase analysis (0-100 score)
/specswarm:analyze-quality
```

---

## Configuration (Optional)

Create these files in your project's `/memory/` directory for customization:

### `/memory/tech-stack.md` - Enforce technology choices

```markdown
## Core Technologies
- React 19.x (functional components only)
- React Router v7 (framework mode)
- PostgreSQL 17.x

## Approved Libraries
- Zod v4+ (validation)
- Drizzle ORM (database)

## Prohibited
- ❌ Redux (use React Router loaders/actions instead)
- ❌ Class components (use functional components with hooks)
```

### `/memory/quality-standards.md` - Set quality gates

```yaml
# Quality Gates
min_test_coverage: 85
min_quality_score: 80

# Performance Budgets
enforce_budgets: true
max_bundle_size: 500      # KB per bundle
max_initial_load: 1000    # KB initial load
```

---

## When to Use Which Plugin?

### Use SpecSwarm when:
- ✅ Building production features
- ✅ Fixing critical bugs
- ✅ Refactoring existing code
- ✅ You need full control
- ✅ Stability is important

### Use SpecLabs when:
- ✅ Experimenting with autonomous development
- ✅ You're comfortable with experimental features
- ✅ You want end-to-end automation
- ✅ You can handle failures gracefully
- ❌ **NOT** for production-critical work

---

## Key Features

### SpecSwarm Features

✅ **Tech Stack Enforcement** - 95% drift prevention
✅ **Quality Scoring** - 0-100 point validation
✅ **Bundle Size Monitoring** - Performance budgets
✅ **Chain Bug Detection** - Prevents cascading failures
✅ **Git Workflow Integration** - Branch management
✅ **Multi-Framework Support** - 11+ test frameworks

### SpecLabs Features

✅ **Autonomous Orchestration** - Natural language → working code
✅ **Multi-Type Validation** - Webapp, Android, REST API, Desktop
✅ **Intelligent Retry Logic** - Auto-fix up to 3 times
✅ **Browser Automation** - Playwright integration
✅ **AI-Powered Flows** - Smart test generation
✅ **Session Tracking** - Complete orchestration history

---

## All Commands

<details>
<summary><strong>SpecSwarm Commands (17)</strong></summary>

### New Feature Development
- `/specswarm:specify` - Create feature specification
- `/specswarm:plan` - Design implementation
- `/specswarm:tasks` - Generate task breakdown
- `/specswarm:implement` - Execute implementation
- `/specswarm:clarify` - Ask clarification questions
- `/specswarm:checklist` - Generate requirement checklists
- `/specswarm:analyze` - Validate consistency
- `/specswarm:constitution` - Project governance

### Bug & Issue Management
- `/specswarm:bugfix` - Regression-test-first fixing
- `/specswarm:hotfix` - Emergency production fixes

### Code Maintenance
- `/specswarm:modify` - Feature modifications
- `/specswarm:refactor` - Quality improvements
- `/specswarm:deprecate` - Phased feature sunset

### Analysis & Completion
- `/specswarm:analyze-quality` - Comprehensive analysis
- `/specswarm:impact` - Impact analysis
- `/specswarm:suggest` - AI workflow recommendations
- `/specswarm:workflow-metrics` - Performance analytics
- `/specswarm:complete` - Finish and merge features

</details>

<details>
<summary><strong>SpecLabs Commands (5)</strong></summary>

### Autonomous Orchestration
- `/speclabs:orchestrate-feature` - Complete feature lifecycle automation
- `/speclabs:validate-feature` - Multi-type validation orchestrator

### Task & Workflow Automation
- `/speclabs:orchestrate` - Task workflow orchestration
- `/speclabs:orchestrate-validate` - Validation suite

### Debugging & Analytics
- `/speclabs:coordinate` - Multi-bug systematic debugging
- `/speclabs:metrics` - Orchestration analytics

</details>

---

## Documentation

- **[SpecSwarm Documentation](plugins/specswarm/README.md)** - Detailed SpecSwarm guide
- **[SpecLabs Documentation](plugins/speclabs/README.md)** - Experimental features guide
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and updates

---

## What's New?

### v2.7.1 (November 4, 2025) - SpecLabs
- **Fixed**: Orchestrate-feature now executes fully autonomously without pausing
- **Better UX**: No more manual "continue" prompts during orchestration

### v2.7.0 (November 3, 2025) - SpecLabs
- **New Command**: `/speclabs:validate-feature` - Standalone multi-type validation
- **Auto-Detection**: Automatically detects project type (webapp, android, REST API, desktop)
- **Modular Architecture**: Extensible validator interface for future types

### v2.1.1 (October 30, 2025) - SpecSwarm
- **Enhanced Git**: Parent branch tracking - features merge back to origin branch
- **Improved**: Complete workflow now respects branch hierarchy

[View full changelog →](CHANGELOG.md)

---

## Best Practices

### Getting Started
1. **Start with SpecSwarm** - Learn the manual workflow first
2. **Define tech-stack.md** - Prevent drift from day 1
3. **Set quality gates** - Maintain >80% scores
4. **Use small features** - Test with 2-3 task features first

### Production Workflow
1. **Always commit before experiments** - Easy rollback if needed
2. **Review specs before implementation** - Catch issues early
3. **Run analyze-quality regularly** - Maintain quality
4. **Test autonomous features** - Verify SpecLabs results carefully

### Advanced Usage
1. **Custom quality standards** - Tailor to your project
2. **Performance budgets** - Keep bundles small
3. **Chain bug prevention** - Use bugfix workflow
4. **Orchestration sessions** - Track complex workflows

---

## Support & Community

- **Repository**: https://github.com/MartyBonacci/specswarm
- **Issues**: https://github.com/MartyBonacci/specswarm/issues
- **Claude Code Docs**: https://docs.claude.com/en/docs/claude-code
- **Original Spec-Kit**: https://github.com/github/spec-kit

---

## Attribution

**SpecSwarm** builds upon [GitHub's spec-kit](https://github.com/github/spec-kit) (MIT License), adapted for Claude Code with enhanced tech stack management, lifecycle workflows, and quality validation.

**SpecLabs** is original work focused on autonomous development and multi-agent orchestration.

Both plugins created by **Marty Bonacci** with **Claude Code** (2025).

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**SpecSwarm Marketplace** - Build it. Fix it. Maintain it. Automate it. 🚀

Ready to get started? Run `/plugin https://github.com/MartyBonacci/specswarm` in Claude Code!
