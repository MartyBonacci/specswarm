# SpecSwarm v2.0.0

**Complete Software Development Toolkit**

Build, fix, maintain, and analyze your entire software project with one unified plugin.

---

## Overview

SpecSwarm is a comprehensive plugin that provides everything you need for the complete software development lifecycle:

- ✅ **Spec-Driven Development** - From specification to implementation
- 🐛 **Bug & Issue Management** - Systematic fixing with regression testing
- 🔧 **Code Maintenance** - Refactoring and modernization
- 📊 **Quality Assurance** - Automated testing and validation
- 🚀 **Performance Monitoring** - Bundle size tracking and budgets
- 🏗️ **Architecture Validation** - SSR patterns, tech stack compliance

**18 Commands** | **8 Utilities** | **Production Ready**

---

## Quick Start

### New Feature Development

```bash
# 1. Create specification
/specswarm:specify "Add user authentication with email/password"

# 2. Design implementation plan
/specswarm:plan

# 3. Generate task breakdown
/specswarm:tasks

# 4. Execute implementation with quality validation
/specswarm:implement
```

### Bug Fixing

```bash
# Regression-test-first bugfix workflow
/specswarm:bugfix "Bug 915: Login fails with special characters in password"
```

### Code Quality

```bash
# Comprehensive codebase analysis
/specswarm:analyze-quality

# Metrics-driven refactoring
/specswarm:refactor "Improve authentication module performance"
```

---

## Commands Reference

### 🆕 New Feature Workflows (8 commands)

See full command documentation in [COMMANDS.md](./COMMANDS.md) for detailed usage.

- `/specswarm:specify` - Create detailed feature specification
- `/specswarm:plan` - Design implementation with tech stack validation
- `/specswarm:tasks` - Generate dependency-ordered task breakdown
- `/specswarm:implement` - Execute with comprehensive quality validation
- `/specswarm:clarify` - Ask targeted clarification questions
- `/specswarm:checklist` - Generate custom requirement checklists
- `/specswarm:analyze` - Cross-artifact consistency validation
- `/specswarm:constitution` - Create/update project governance

### 🐛 Bug & Issue Management (2 commands)

- `/specswarm:bugfix` - Regression-test-first fixing with chain bug detection
- `/specswarm:hotfix` - Emergency production issue response

### 🔧 Code Maintenance (2 commands)

- `/specswarm:modify` - Feature modification with impact analysis
- `/specswarm:refactor` - Metrics-driven quality improvement

### 📊 Analysis & Utilities (5 commands)

- `/specswarm:analyze-quality` - Comprehensive codebase analysis
- `/specswarm:impact` - Standalone impact analysis
- `/specswarm:suggest` - AI-powered workflow recommendation
- `/specswarm:workflow-metrics` - Cross-workflow analytics
- `/specswarm:deprecate` - Phased feature sunset

---

## Key Features

### Quality Validation (0-100 Points)

Automated quality scoring across 6 dimensions:

- **Unit Tests** (25 pts) - Proportional by pass rate
- **Code Coverage** (25 pts) - Proportional by coverage %
- **Integration Tests** (15 pts) - API/service testing
- **Browser Tests** (15 pts) - E2E user flows
- **Bundle Size** (20 pts) - Performance budgets ⭐ NEW
- **Visual Alignment** (15 pts) - Future

### Tech Stack Management

Prevents technology drift across features:

```yaml
# /memory/tech-stack.md
Core Technologies:
  - TypeScript 5.x
  - React Router v7
  - PostgreSQL 17.x

Prohibited:
  - ❌ Redux (use React Router loaders/actions)
  - ❌ Class components (use functional)
```

**95% drift prevention** through automatic validation at plan, task, and implementation phases.

### SSR Pattern Validation

Detects production failures before deployment:

- Hardcoded URLs in loaders/actions
- Relative URLs in SSR contexts
- Missing environment-aware patterns
- React Router v7 / Remix / Next.js support

### Multi-Framework Testing

Supports 11 test frameworks automatically:

- JavaScript: Vitest, Jest, Mocha, Jasmine
- Python: Pytest, unittest
- Go: go test
- Ruby: RSpec
- Java: JUnit
- And more...

### Chain Bug Detection ⭐ NEW

Prevents Bug 912→913 cascading failures:

- Compares test counts before/after
- Detects new SSR issues
- Checks TypeScript errors
- Stops cascading bugs

### Bundle Size Monitoring ⭐ NEW

Automatic performance tracking:

- Analyzes production bundles
- Calculates size score (0-20 points)
- Enforces configurable budgets
- Tracks over time

---

## Configuration

### Quality Standards

Enable quality gates by creating `/memory/quality-standards.md`:

```yaml
# Quality Gates
min_test_coverage: 85
min_quality_score: 80
block_merge_on_failure: false

# Performance Budgets (NEW in v2.0)
enforce_budgets: true
max_bundle_size: 500      # KB per bundle
max_initial_load: 1000    # KB initial load
```

### Tech Stack

Define your stack in `/memory/tech-stack.md`:

```markdown
## Core Technologies
- TypeScript 5.x
- React Router v7

## Approved Libraries
- Zod v4+ (validation)
- Drizzle ORM (database)

## Prohibited
- ❌ Redux (use React Router loaders/actions)
```

---

## Integration with SpecLabs

SpecSwarm can suggest experimental SpecLabs features when appropriate:

**Complex Bugs**:
```
/specswarm:bugfix detects chain bugs
→ "Use /speclabs:coordinate for systematic analysis?"
```

**Autonomous Mode**:
```
/specswarm:implement
→ "Try /speclabs:orchestrate-test for autonomous execution?"
```

See [SpecLabs](../speclabs/README.md) for experimental features.

---

## Best Practices

1. **Define tech-stack.md early** - Prevents drift from day 1
2. **Enable quality gates** - Maintain >80% scores
3. **Run analyze-quality regularly** - Catch issues early
4. **Keep bundles <500KB** - Performance matters
5. **Use bugfix workflow** - Regression testing prevents cascades

---

## Troubleshooting

### Quality Validation Not Running

Create `/memory/quality-standards.md` to enable quality gates.

### SSR Validation Fails

Use environment-aware helper:

```typescript
// app/utils/api.ts
export function getApiUrl(path: string): string {
  const base = typeof window !== 'undefined'
    ? ''
    : process.env.API_BASE_URL || 'http://localhost:3000';
  return `${base}${path}`;
}
```

### Bundle Size Exceeds Budget

1. Implement code splitting
2. Use dynamic imports
3. Analyze: `npx vite-bundle-visualizer`
4. Remove unused dependencies

---

## Version History

### v2.0.0 (2025-10-15) - Major Consolidation
- Merged SpecLab lifecycle workflows (9 commands)
- Added chain bug detection
- Added bundle size monitoring
- Added performance budget enforcement
- Complete lifecycle coverage

### v1.1.0 (2025-10-14) - Quality Enhancements
- Phase 1-3 improvements
- SSR validation
- Multi-framework testing
- Proportional scoring
- Project-aware git staging

### v1.0.0 (2025-10-11) - Initial Release
- Spec-driven workflows
- Tech stack management
- Basic quality validation

---

## Attribution

### Forked From

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
   - Consolidated from SpecKit, SpecTest, and SpecLab plugins

---

## License

MIT License - See LICENSE file for details

---

## Support

- **Repository**: https://github.com/MartyBonacci/specswarm
- **Issues**: https://github.com/MartyBonacci/specswarm/issues
- **Migration Guides**: See DEPRECATED.md files in deprecated plugins

---

**SpecSwarm v2.0.0** - Your complete software development toolkit. 🚀

Build it. Fix it. Maintain it. Analyze it. All in one place.
