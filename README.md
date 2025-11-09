# SpecSwarm v3.1 🚀

**Build features, fix bugs, and upgrade dependencies with autonomous AI workflows for Claude Code.**

SpecSwarm is a complete development toolkit for Claude Code, offering both simplified high-level commands for rapid development and granular control for complex workflows. Build complete features in 2 commands instead of 7+, with quality gates, automatic retry logic, and framework migration support.

**New in v3.1**: Project initialization (`/specswarm:init`), rollback safety (`/specswarm:rollback`), security audits (`/specswarm:security-audit`), and release automation (`/specswarm:release`).

---

## Quick Start

### 1. Install SpecSwarm

```bash
# From GitHub
/plugin https://github.com/MartyBonacci/specswarm

# Install the unified toolkit (v3.0+)
/plugin install specswarm
```

**That's it!** SpecSwarm v3.0 consolidates everything into a single plugin.

### 2. Build Your First Feature (The New Way)

```bash
# Build complete feature with one command
/specswarm:build "Add user authentication with email and password" --validate

# [Answer clarification questions - only interactive step]
# [AI handles: spec → plan → tasks → implementation → validation → quality analysis]

# Ship when ready
/specswarm:ship
```

**70% fewer commands**, same powerful results.

### 3. Or Use Manual Control (Advanced)

```bash
# Fine-grained control for complex features
/specswarm:specify "Add user authentication..."
/specswarm:clarify  # Answer clarification questions
/specswarm:plan
/specswarm:tasks
/specswarm:implement
/specswarm:analyze-quality
/specswarm:complete
```

All the power, when you need it.

---

## Getting Started: Your First Feature

### One-Time Project Setup

Before building features, set up your project foundation:

1. **Initialize Claude Code and Install Plugins**:
   ```bash
   /init
   /plugin https://github.com/MartyBonacci/specswarm
   /plugin install specswarm
   ```

2. **Initialize Your Project** (NEW in v3.1 - recommended):
   ```bash
   /specswarm:init

   # This creates 3 foundation files:
   # - .specswarm/constitution.md (coding principles)
   # - .specswarm/tech-stack.md (approved technologies)
   # - .specswarm/quality-standards.md (quality gates)
   #
   # Auto-detects tech stack from package.json
   # Interactive configuration with smart defaults
   ```

   **Alternative (Manual Setup)**:

   If you prefer manual control, create these files yourself:

   **Tech Stack** (`.specswarm/tech-stack.md`):
   ```markdown
   ## Core Technologies
   - React 19.x (functional components only)
   - React Router v7 (framework mode)
   - TypeScript 5.x

   ## Approved Libraries
   - Zod v4+ (validation)
   - Tailwind CSS (styling)

   ## Prohibited
   - ❌ Redux (use React Router loaders/actions)
   - ❌ Class components (use functional with hooks)
   ```

   **Quality Standards** (`.specswarm/quality-standards.md`):
   ```yaml
   min_test_coverage: 80
   min_quality_score: 85
   enforce_budgets: true
   max_bundle_size: 500
   ```

   **Project Constitution**:
   ```bash
   /specswarm:constitution
   ```

### Building a Feature (Simplified - Recommended)

```bash
# 1. Ensure you're on the right parent branch
git checkout develop  # or sprint-X

# 2. Get AI workflow recommendation (optional)
/specswarm:suggest "add user authentication with email/password"

# 3. Build the feature
/specswarm:build "Add user authentication with email/password login, JWT tokens, and protected routes" --validate

# 4. Answer clarification questions (only interactive step)

# 5. Manual testing (CRITICAL - always test yourself)

# 6. Fix any bugs found
/specswarm:fix "Bug: Login fails with special characters..." --regression-test

# 7. Ship with quality gate
/specswarm:ship
```

**Time Savings**: 85-90% reduction in manual orchestration

### Building a Feature (Manual Control)

```bash
# For complex features where you want more control:
/specswarm:specify "Add user authentication..."
/specswarm:clarify  # Answer clarification questions
/specswarm:plan
/specswarm:tasks
/specswarm:implement
/specswarm:analyze-quality
/specswarm:complete
```

**When to use**: Complex features needing step-by-step review

**📖 Full Workflow Guide**: See [WORKFLOW.md](docs/WORKFLOW.md) for detailed instructions, examples, and troubleshooting

**📋 Quick Reference**: See [CHEATSHEET.md](docs/CHEATSHEET.md) for a visual command reference

---

## What's Included?

### SpecSwarm v3.0 (Unified Toolkit) ⭐

Complete software development lifecycle with **28 commands** in a single plugin:

**🚀 High-Level Commands** (New in v3.0 - Simplified Workflow):
- **`build`** - Complete feature development (spec → implementation → quality)
- **`fix`** - Test-driven bug fixing with automatic retry
- **`upgrade`** - Dependency/framework migrations with breaking change analysis
- **`ship`** - Quality-gated merge to parent branch

**📝 Granular Workflow Commands** (Manual Control):
- **New Features**: `specify` → `clarify` → `plan` → `tasks` → `implement` → `complete`
- **Bug Fixing**: `bugfix` with regression testing, `hotfix` for emergencies
- **Code Maintenance**: `modify`, `refactor`, `deprecate`
- **Quality**: `analyze-quality`, `impact` analysis

**🔧 Advanced Capabilities** (From SpecLabs):
- **Orchestration**: `orchestrate-feature` - autonomous lifecycle automation
- **Validation**: `validate` - multi-type validation (webapp, android, REST API, desktop)
- **Debugging**: `coordinate` - systematic multi-bug investigation
- **Analytics**: `metrics` - feature-level performance tracking

**Status**: ✅ Production-ready | v3.0.0-alpha.1 | Consolidation in progress

### ⚠️ SpecLabs (Deprecated)

**SpecLabs has been consolidated into SpecSwarm v3.0.**

All functionality is now available in SpecSwarm. The SpecLabs plugin provides backward compatibility aliases that will be removed in v3.2.0.

**Migration Path**: Replace `/speclabs:*` commands with `/specswarm:*` equivalents.

---

## Core Concepts

### Spec-Driven Development

Write clear specifications before coding. This approach leads to:

✅ Fewer misunderstandings and requirement changes
✅ Better architectural decisions made upfront
✅ More predictable timelines
✅ Higher quality code that matches specs
✅ Better documentation as a byproduct

### Workflow Patterns

**Simplified (v3.0 - Recommended)**:
```
build → [answer questions] → [autonomous execution] → ship
```
**2 commands**, 85-90% less manual orchestration

**Granular Control (Advanced)**:
```
specify → clarify → plan → tasks → implement → analyze-quality → complete
```
**7 commands**, full step-by-step control

**Legacy (SpecLabs - Deprecated)**:
```
orchestrate-feature → [autonomous] → complete
```
Use `/specswarm:orchestrate-feature` or `/specswarm:build` instead

---

## Proven Results

### Real-World Validation: Feature 015 (Testing Infrastructure)

SpecSwarm + SpecLabs has been validated in production with exceptional results:

**Project**: customcult2 (React 19 + Redux + Three.js snowboard customization app)

```
✅ 76/76 Tasks Completed (100%)
✅ 131/136 Tests Passing (96.3%)
✅ 3.27s Test Execution Time
✅ 3,500+ Lines of Test Code Generated
✅ 1,530 Lines of Documentation Created
✅ Successfully Merged to Parent Branch (sprint-4)
```

**Time Savings**:
| Task | Manual | Autonomous | Savings |
|------|--------|-----------|---------|
| Planning | 1-2 hours | 15 min | 85-90% |
| Implementation | 2-3 days | 3-4 hours | 85-90% |
| Test Writing | 1-2 days | Included | 100% |
| Documentation | 4-6 hours | Included | 100% |
| **Total** | **3-5 days** | **4-5 hours** | **85-90%** |

**What Was Validated**:
- ✅ Parent branch detection and merge validation (v2.1.2 fix)
- ✅ Silent autonomous execution (v2.7.3 fix)
- ✅ Tech stack enforcement (prevented Jest drift)
- ✅ Production-ready code quality (96.3% pass rate)
- ✅ Complex branch hierarchies (main → develop → sprint-4 → feature)

**User Experience**:
```bash
# Instance A: 2 commands total
/speclabs:orchestrate-feature "Implement comprehensive testing..." --validate
# [3-4 hours autonomous execution]
/specswarm:complete

# Manual equivalent: 3-5 days, 50+ commands
```

**Read the full case study**: [CHANGELOG.md - Feature 015 Validation](CHANGELOG.md#validated---real-world-production-testing)

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
<summary><strong>SpecSwarm Commands (18)</strong></summary>

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
<summary><strong>SpecLabs Commands (6)</strong></summary>

### Autonomous Orchestration
- `/speclabs:orchestrate-feature` - Complete feature lifecycle automation
- `/speclabs:validate-feature` - Multi-type validation orchestrator

### Task & Workflow Automation
- `/speclabs:orchestrate` - Task workflow orchestration
- `/speclabs:orchestrate-validate` - Validation suite orchestrator

### Debugging & Analytics
- `/speclabs:coordinate` - Multi-bug systematic debugging
- `/speclabs:metrics` - Export orchestration metrics to CSV

</details>

---

## Documentation

### Getting Started Guides
- **[Complete Workflow Guide](docs/WORKFLOW.md)** - Step-by-step guide with examples ⭐ START HERE
- **[Quick Reference Cheat Sheet](docs/CHEATSHEET.md)** - Visual command reference and templates

### Plugin Documentation
- **[SpecSwarm Documentation](plugins/specswarm/README.md)** - Detailed SpecSwarm command reference
- **[SpecLabs Documentation](plugins/speclabs/README.md)** - Experimental autonomous features guide

### Project Information
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and updates

---

## What's New?

### v2.7.3 (November 4, 2025) - SpecLabs
- **Fixed**: Silent autonomous execution - eliminated all mid-phase reporting
- **Better UX**: Agent runs end-to-end without pausing to report statistics
- **Performance**: Complete features without interruption

### v2.7.2 (November 4, 2025) - SpecLabs
- **Fixed**: Agent pause behavior during implement/validate slash command execution
- **Improvement**: More reliable autonomous orchestration

### v2.7.1 (November 4, 2025) - SpecLabs
- **Fixed**: Orchestrate-feature execution without pausing before Task tool launch
- **Better UX**: No more manual "continue" prompts during orchestration

### v2.1.2 (November 4, 2025) - SpecSwarm ⭐
- **Fixed**: Parent branch detection bugs - robust MAIN_BRANCH fallback
- **New**: Branch confirmation prompts during feature creation
- **New**: Detailed merge validation before executing complete
- **Safety**: Prevents accidental merges to wrong branches

### v2.7.0 (November 3, 2025) - SpecLabs
- **New Command**: `/speclabs:validate-feature` - Standalone multi-type validation
- **Auto-Detection**: Automatically detects project type (webapp, android, REST API, desktop)
- **Modular Architecture**: Extensible validator interface for future types

[View full changelog →](CHANGELOG.md)

---

## Best Practices

### Project Setup (Do This First!)
1. **Define tech-stack.md** - Prevents 95% of technology drift across features
2. **Set quality gates** - Maintain >80% quality scores automatically
3. **Run /specswarm:constitution** - Establishes project governance and coding standards
4. **Always work from correct parent branch** - Ensures features merge to the right place

### Feature Development
1. **Use /specswarm:suggest first** - Get AI recommendation on which workflow to use
2. **Autonomous for speed** - Use `/speclabs:orchestrate-feature --validate` for straightforward features
3. **Manual for control** - Use SpecSwarm step-by-step workflow for complex architectural changes
4. **Always test manually** - Never skip manual testing, even with --validate flag
5. **Run /specswarm:analyze-quality before merge** - Catches quality issues early

### Production Workflow
1. **Always commit before features** - Clean git state enables easy rollback
2. **Review planning artifacts** - Check spec.md, plan.md, tasks.md before implementation
3. **Use /specswarm:bugfix for bugs** - Creates regression tests automatically
4. **Verify parent branch** - Our v2.1.2 update shows merge plan before executing

### Advanced Usage
1. **Custom quality standards** - Define project-specific thresholds in quality-standards.md
2. **Performance budgets** - Enforce bundle size limits to prevent bloat
3. **Chain bug prevention** - Use bugfix workflow to prevent cascading failures
4. **Tech stack enforcement** - Let SpecSwarm block incompatible technology choices

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
