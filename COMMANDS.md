# SpecSwarm Commands Reference

Complete documentation for all 32 SpecSwarm commands.

## Command Categories

- **[Core Workflows](#core-workflows)** (5) - Essential commands for daily development
- **[New Feature Workflows](#new-feature-workflows)** (8) - Building new functionality
- **[Bug & Issue Management](#bug--issue-management)** (3) - Fixing and debugging
- **[Code Maintenance](#code-maintenance)** (2) - Refactoring and modifications
- **[Quality & Analysis](#quality--analysis)** (6) - Testing and validation
- **[Lifecycle Management](#lifecycle-management)** (5) - Release and deployment
- **[Orchestration](#orchestration)** (3) - Autonomous workflows

---

## Core Workflows

These 5 commands handle 95% of daily development work. **Start here** if you're new to SpecSwarm.

### `/specswarm:init`

Initialize SpecSwarm in your project with interactive setup wizard.

**Usage:**
```bash
/specswarm:init
```

**What it does:**
- Creates `.specswarm/` directory structure
- Generates `tech-stack.md` with your technology choices
- Creates `quality-standards.md` with validation gates
- Sets up `constitution.md` for project governance
- Configures performance budgets

**When to use:**
- First-time project setup
- Adding SpecSwarm to existing projects

---

### `/specswarm:build`

Complete workflow for building new features from natural language description.

**Usage:**
```bash
/specswarm:build "feature description"
```

**Natural Language:**
```
"Build user authentication with JWT"
"Create a payment processing system"
"Add dashboard analytics"
```

**What it does:**
1. Creates specification (spec.md)
2. Asks clarifying questions
3. Generates implementation plan (plan.md)
4. Breaks down into tasks (tasks.md)
5. Implements all tasks
6. Validates quality

**When to use:**
- Building any new feature
- When you know what you want but not how to implement it
- Starting fresh feature development

**Related commands:**
- `/specswarm:specify` - Just create specification
- `/specswarm:plan` - Just create plan
- `/specswarm:implement` - Just execute tasks

---

### `/specswarm:fix`

Complete workflow for fixing bugs with regression testing.

**Usage:**
```bash
/specswarm:fix "bug description"
```

**Natural Language:**
```
"Fix the login button on mobile"
"There's a bug in the checkout process"
"Images don't load"
"Tailwind styles not showing up"
```

**What it does:**
1. Creates regression test
2. Analyzes root cause
3. Implements fix
4. Validates fix with tests
5. Detects chain bugs
6. Auto-retries on failure (max 2 attempts)

**When to use:**
- Any bug or broken functionality
- Issues that need regression testing
- Problems that keep coming back

**Related commands:**
- `/specswarm:bugfix` - More detailed bugfix workflow
- `/specswarm:hotfix` - Emergency production fixes

---

### `/specswarm:modify`

Change existing feature behavior with impact analysis and backward compatibility assessment.

**Usage:**
```bash
/specswarm:modify "modification description"
```

**Natural Language:**
```
"Change authentication from session to JWT"
"Add pagination to user list API"
"Update search to use full-text search"
```

**What it does:**
1. Analyzes impact on existing code
2. Identifies breaking changes
3. Creates migration plan if needed
4. Updates specification and plan
5. Implements modifications
6. Validates against regression tests

**When to use:**
- Features that work but need to work differently
- Changing implementation approach
- Enhancing existing functionality
- NOT for bugs (use `/specswarm:fix`)
- NOT for code quality (use `/specswarm:refactor`)

**Examples:**
- Change data source from REST to GraphQL
- Switch caching strategy
- Update UI framework
- Modify business logic

**Related commands:**
- `/specswarm:impact` - Standalone impact analysis

---

### `/specswarm:ship`

Validate quality, merge to parent branch, and complete feature.

**Usage:**
```bash
/specswarm:ship
```

**Natural Language:**
```
"Ship this feature"  ⚠️ (requires confirmation)
"Deploy to production"  ⚠️ (requires confirmation)
"Merge to main"  ⚠️ (requires confirmation)
```

**What it does:**
1. Runs comprehensive quality analysis
2. Checks quality threshold (default 80%)
3. Shows merge plan with confirmation prompt
4. Merges to parent branch
5. Deletes feature branch

**⚠️ DESTRUCTIVE OPERATION:**
- Always requires explicit "yes" confirmation
- Merges and deletes branches
- Cannot be easily undone

**When to use:**
- Feature is complete and tested
- Quality score meets threshold
- Ready to merge to main/production

**Related commands:**
- `/specswarm:complete` - Alias for ship
- `/specswarm:analyze-quality` - Pre-ship quality check

---

## New Feature Workflows

Granular commands for spec-driven feature development. The `/specswarm:build` command runs these automatically.

### `/specswarm:specify`

Create detailed feature specification from natural language description.

**Usage:**
```bash
/specswarm:specify "Add user authentication with email/password"
```

**What it creates:**
```
.specswarm/features/001-user-authentication/spec.md
```

**Specification includes:**
- Feature objectives
- User stories
- Acceptance criteria
- Technical constraints
- Dependencies

**When to use:**
- Starting new features manually
- Need just specification without implementation
- Reviewing feature scope before building

---

### `/specswarm:clarify`

Ask up to 5 targeted clarification questions and encode answers into specification.

**Usage:**
```bash
/specswarm:clarify
```

**What it does:**
- Analyzes current spec.md
- Identifies underspecified areas
- Asks targeted questions
- Updates spec.md with answers

**When to use:**
- After creating specification
- When requirements are unclear
- Before planning implementation

---

### `/specswarm:plan`

Design implementation plan with tech stack validation.

**Usage:**
```bash
/specswarm:plan
```

**What it creates:**
```
.specswarm/features/001-user-authentication/plan.md
```

**Plan includes:**
- Architecture decisions
- File structure
- Component hierarchy
- Data models
- API endpoints
- Tech stack compliance validation

**When to use:**
- After specification is complete
- Before breaking down into tasks
- Need architectural design review

---

### `/specswarm:tasks`

Generate actionable, dependency-ordered task breakdown.

**Usage:**
```bash
/specswarm:tasks
```

**What it creates:**
```
.specswarm/features/001-user-authentication/tasks.md
```

**Task list includes:**
- Dependency-ordered tasks
- Acceptance criteria per task
- Estimated complexity
- Prerequisites

**When to use:**
- After plan is finalized
- Before implementation
- Need clear execution roadmap

---

### `/specswarm:implement`

Execute implementation plan with comprehensive quality validation.

**Usage:**
```bash
/specswarm:implement
```

**What it does:**
1. Reads tasks.md
2. Executes each task in order
3. Creates/modifies files
4. Runs tests continuously
5. Validates quality (0-100 score)
6. Detects chain bugs
7. Monitors bundle size

**Quality validation includes:**
- Unit tests (25 pts)
- Code coverage (25 pts)
- Integration tests (15 pts)
- Browser tests (15 pts)
- Bundle size (20 pts)

**When to use:**
- After tasks are defined
- Ready to write code
- Want autonomous implementation

---

### `/specswarm:checklist`

Generate custom requirement checklist for current feature.

**Usage:**
```bash
/specswarm:checklist
```

**When to use:**
- Need manual verification checklist
- Complex feature with many edge cases
- Compliance requirements

---

### `/specswarm:analyze`

Non-destructive cross-artifact consistency analysis across spec.md, plan.md, and tasks.md.

**Usage:**
```bash
/specswarm:analyze
```

**What it checks:**
- Specification completeness
- Plan alignment with spec
- Tasks coverage of plan
- Dependency conflicts
- Quality issues

**When to use:**
- After generating tasks
- Before implementation
- Periodic consistency checks

---

### `/specswarm:constitution`

Create or update project constitution from interactive inputs.

**Usage:**
```bash
/specswarm:constitution
```

**What it creates:**
```
.specswarm/constitution.md
```

**Constitution includes:**
- Project principles
- Code standards
- Decision-making guidelines
- Technology preferences

**When to use:**
- Project initialization
- Establishing governance
- Team alignment

---

## Bug & Issue Management

Commands for fixing bugs and handling production issues.

### `/specswarm:bugfix`

Regression-test-first bugfix workflow with chain bug detection.

**Usage:**
```bash
/specswarm:bugfix "Bug 915: Login fails with special characters in password"
```

**What it does:**
1. Creates regression test first
2. Analyzes root cause
3. Implements fix
4. Runs all tests
5. Detects chain bugs (new test failures)
6. Validates SSR patterns
7. Auto-retries on failure

**Chain Bug Detection:**
- Compares test counts before/after
- Flags new failing tests
- Prevents cascading failures
- Stops Bug 912→913 scenarios

**When to use:**
- Reported bugs with reproduction steps
- Recurring issues
- Need regression protection
- Critical bug fixes

**Auto-retry:**
- Max 2 retry attempts
- Retry on test failures
- Retry on validation errors

---

### `/specswarm:hotfix`

Expedited emergency response workflow for critical production issues.

**Usage:**
```bash
/specswarm:hotfix "API down in production"
```

**What it does:**
1. Minimal ceremony workflow
2. Fast diagnosis
3. Quick fix implementation
4. Essential testing only
5. Immediate deployment preparation

**When to use:**
- Production is down
- Critical user-facing issues
- Revenue-impacting bugs
- Security vulnerabilities

**Trade-offs:**
- Skips full spec-driven workflow
- Minimal documentation
- Essential tests only
- Plan full fix later

---

### `/specswarm:coordinate`

Complex debugging workflow with logging, monitoring, and agent orchestration.

**Usage:**
```bash
/specswarm:coordinate "Intermittent database connection failures"
```

**What it does:**
- Systematic log analysis
- Monitoring setup
- Multi-agent coordination
- Root cause investigation

**When to use:**
- Complex multi-system bugs
- Intermittent failures
- Need systematic analysis
- Chain bug investigation

---

## Code Maintenance

Commands for improving existing code without changing behavior.

### `/specswarm:refactor`

Metrics-driven code quality improvement with behavior preservation.

**Usage:**
```bash
/specswarm:refactor "Improve authentication module performance"
```

**What it does:**
1. Analyzes code metrics
2. Identifies quality issues
3. Creates refactoring plan
4. Implements improvements
5. Validates behavior unchanged
6. Measures impact

**When to use:**
- Improve code quality
- Reduce complexity
- Enhance performance
- Maintain test coverage
- NOT changing behavior

**Metrics analyzed:**
- Cyclomatic complexity
- Code duplication
- Test coverage
- Performance benchmarks

---

### `/specswarm:deprecate`

Phased feature sunset workflow with migration guidance.

**Usage:**
```bash
/specswarm:deprecate "Sunset old API v1"
```

**What it does:**
1. Analyzes usage patterns
2. Creates deprecation plan
3. Identifies affected consumers
4. Generates migration guide
5. Phases removal safely

**When to use:**
- Removing old features
- Sunsetting APIs
- Technology migration
- Cleaning up tech debt

**Phases:**
1. Deprecation notice
2. Migration path
3. Grace period
4. Final removal

---

## Quality & Analysis

Commands for testing, validation, and codebase analysis.

### `/specswarm:analyze-quality`

Comprehensive codebase quality analysis with prioritized recommendations.

**Usage:**
```bash
/specswarm:analyze-quality
```

**Quality Score (0-100):**
- Unit Tests (25 pts)
- Code Coverage (25 pts)
- Integration Tests (15 pts)
- Browser Tests (15 pts)
- Bundle Size (20 pts)

**What it analyzes:**
- Test coverage gaps
- Code quality issues
- Performance problems
- Security vulnerabilities
- Tech stack drift

**When to use:**
- Before merging features
- Regular quality audits
- Sprint retrospectives
- Pre-release validation

---

### `/specswarm:impact`

Standalone impact analysis for proposed changes.

**Usage:**
```bash
/specswarm:impact "Change database from MongoDB to PostgreSQL"
```

**What it analyzes:**
- Affected files
- Breaking changes
- Backward compatibility
- Migration complexity
- Risk assessment

**When to use:**
- Planning major changes
- Architecture decisions
- Technology migrations
- Before modify/refactor

---

### `/specswarm:suggest`

AI-powered workflow recommendation based on context analysis.

**Usage:**
```bash
/specswarm:suggest "add user authentication"
```

**What it does:**
- Analyzes request context
- Recommends best workflow
- Explains reasoning
- Provides command to run

**When to use:**
- Unsure which command to use
- New to SpecSwarm
- Complex scenarios

---

### `/specswarm:metrics`

Feature-level orchestration metrics and analytics from completed features.

**Usage:**
```bash
/specswarm:metrics [--feature=001-feature-name]
```

**What it shows:**
- Completion rates
- Test metrics
- Git history
- Quality scores
- Time tracking

**When to use:**
- Sprint retrospectives
- Team performance analysis
- Process improvement
- Workflow optimization

---

### `/specswarm:metrics-export`

Export metrics to CSV file for external analysis.

**Usage:**
```bash
/specswarm:metrics-export --output=metrics.csv
```

**When to use:**
- Reporting to stakeholders
- Data visualization
- Trend analysis
- Historical comparison

---

### `/specswarm:validate`

Browser automation validation with flow testing.

**Usage:**
```bash
/specswarm:validate [--url=http://localhost:5173]
```

**What it validates:**
- User flows work
- No console errors
- Network requests succeed
- Visual rendering
- Performance metrics

**When to use:**
- After implementation
- Before merging
- Regression testing
- E2E validation

---

## Lifecycle Management

Commands for release management, security, and rollback.

### `/specswarm:release`

Complete release workflow with versioning, changelog, and deployment.

**Usage:**
```bash
/specswarm:release [--skip-security]
```

**What it does:**
1. Runs quality validation
2. Executes security audit
3. Generates changelog
4. Bumps version
5. Creates git tag
6. Prepares deployment

**When to use:**
- Releasing new versions
- Production deployments
- Publishing packages

---

### `/specswarm:security-audit`

Thorough security scan with pattern matching and deep analysis.

**Usage:**
```bash
/specswarm:security-audit [--thorough]
```

**What it scans:**
- Dependency vulnerabilities
- Code injection risks
- Authentication issues
- Data exposure
- OWASP Top 10

**When to use:**
- Before releases
- Regular security audits
- After dependency updates
- Compliance requirements

---

### `/specswarm:rollback`

Safe rollback to previous version with validation.

**Usage:**
```bash
/specswarm:rollback [--skip-confirm]
```

**What it does:**
1. Identifies previous version
2. Validates rollback safety
3. Reverts changes
4. Runs smoke tests
5. Verifies stability

**When to use:**
- Production issues
- Failed deployments
- Critical bugs in release
- Emergency recovery

⚠️ Use `--skip-confirm` only in emergencies

---

### `/specswarm:upgrade`

Systematic dependency/framework upgrade with compatibility analysis.

**Usage:**
```bash
/specswarm:upgrade "upgrade description"
```

**Natural Language:**
```
"Upgrade to React 19"
"Migrate from Redux to Zustand"
"Update to the latest PostgreSQL"
```

**What it does:**
1. Analyzes breaking changes
2. Creates upgrade plan
3. Updates dependencies
4. Migrates code patterns
5. Runs tests
6. Documents changes

**When to use:**
- Upgrading frameworks
- Updating dependencies
- Technology migrations
- Security patches

---

### `/specswarm:complete`

Alias for `/specswarm:ship` - validates quality and merges feature.

**Usage:**
```bash
/specswarm:complete
```

See [/specswarm:ship](#specswarmship) for full documentation.

---

## Orchestration

Advanced autonomous workflow execution (experimental).

### `/specswarm:orchestrate`

Run automated workflow orchestration with agent execution and validation.

**Usage:**
```bash
/specswarm:orchestrate
```

**What it does:**
- Multi-agent coordination
- Autonomous execution
- Continuous validation
- Error recovery

**When to use:**
- Complex multi-step workflows
- Long-running tasks
- Experimental autonomous mode

---

### `/specswarm:orchestrate-feature`

AI-powered interaction flow validation with Playwright.

**Usage:**
```bash
/specswarm:orchestrate-feature
```

**What it does:**
1. Analyzes feature artifacts
2. Generates intelligent test flows
3. Executes user-defined + AI flows
4. Monitors browser console
5. Monitors terminal output
6. Auto-fixes errors
7. Kills dev server when done

**When to use:**
- Validating complex user flows
- Autonomous feature testing
- Integration testing

---

### `/specswarm:orchestrate-validate`

Run validation suite on target project (browser, terminal, visual).

**Usage:**
```bash
/specswarm:orchestrate-validate
```

**What it validates:**
- Browser functionality
- Terminal output
- Visual alignment
- Performance metrics

**When to use:**
- Full project validation
- Pre-release checks
- Autonomous testing

---

## Command Comparison

### Build vs Fix vs Modify

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/specswarm:build` | New features | Building something that doesn't exist |
| `/specswarm:fix` | Bug fixes | Something is broken or not working |
| `/specswarm:modify` | Change behavior | Working feature needs to work differently |

### Bugfix vs Hotfix

| Command | Purpose | Speed | Documentation |
|---------|---------|-------|---------------|
| `/specswarm:bugfix` | Standard bugs | Normal | Full spec-driven workflow |
| `/specswarm:hotfix` | Production emergencies | Fast | Minimal ceremony |

### Ship vs Complete

- Same command, different names
- Both require confirmation
- Both validate quality first
- Both merge and cleanup

---

## Workflow Patterns

### Standard Feature Development

```bash
/specswarm:build "feature description"
# Or manually:
/specswarm:specify → /specswarm:clarify → /specswarm:plan →
/specswarm:tasks → /specswarm:implement → /specswarm:ship
```

### Bug Fixing

```bash
/specswarm:fix "bug description"
# Or for critical issues:
/specswarm:hotfix "emergency description"
```

### Changing Existing Features

```bash
/specswarm:modify "change description"
```

### Technology Upgrades

```bash
/specswarm:upgrade "upgrade description"
```

### Pre-Release Checklist

```bash
/specswarm:analyze-quality
/specswarm:security-audit
/specswarm:validate
/specswarm:release
```

---

## Tips & Best Practices

1. **Use `/specswarm:init` first** - Sets up proper foundation
2. **Define tech-stack.md early** - Prevents 95% of drift
3. **Use `/specswarm:suggest` when unsure** - Get workflow recommendations
4. **Run `/specswarm:analyze-quality` before shipping** - Catch issues early
5. **Enable quality gates** - Maintain >80% scores
6. **Use natural language for common tasks** - Faster workflows
7. **Use slash commands for precision** - Power user control

---

**See also:**
- [README.md](./README.md) - Quick start and overview
- [docs/SETUP.md](./docs/SETUP.md) - Technical setup
- [docs/FEATURES.md](./docs/FEATURES.md) - Feature deep-dive

---

**SpecSwarm v3.5.0** - Complete software development toolkit
