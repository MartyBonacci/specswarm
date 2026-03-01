# SpecSwarm Features Deep-Dive

Technical documentation for SpecSwarm's advanced features and capabilities.

## Table of Contents

- [Quality Validation System](#quality-validation-system)
- [Tech Stack Management](#tech-stack-management)
- [Multi-Framework Testing](#multi-framework-testing)
- [Natural Language Commands](#natural-language-commands)
- [Language Agnostic](#language-agnostic)
- [Planned Features](#planned-features)
- [Workflow Orchestration](#workflow-orchestration)

---

## Quality Validation System

### Overview

SpecSwarm provides automated quality scoring across 6 dimensions with a total of 0-100 points.

### Scoring Breakdown

| Category | Max Points | Description | Requirements |
|----------|-----------|-------------|--------------|
| **Unit Tests** | 25 | Individual function/component tests | Test framework detected |
| **Code Coverage** | 25 | % of code covered by tests | Coverage tool available |
| **Integration Tests** | 15 | API/service level testing | Integration test suite |
| **Browser Tests** | 15 | E2E user flows | Playwright/Cypress setup |
| **Bundle Size** | 20 | Performance budgets | Production build |
| **Visual Alignment** | 15 | Design QA (future) | Not yet implemented |

### Proportional Scoring

Scores are proportional to achievement, not binary:

**Unit Tests (25 points):**
```
Score = (passing_tests / total_tests) * 25

Examples:
- 100% pass rate (50/50 tests) = 25 points
- 80% pass rate (40/50 tests) = 20 points
- 0% pass rate (0/50 tests) = 0 points
```

**Code Coverage (25 points):**
```
Score = (coverage_percentage / 100) * 25

Examples:
- 100% coverage = 25 points
- 85% coverage = 21.25 points
- 50% coverage = 12.5 points
```

**Integration Tests (15 points):**
```
Score = (passing_integration / total_integration) * 15

Examples:
- 10/10 pass = 15 points
- 8/10 pass = 12 points
- 0/10 pass = 0 points
```

**Browser Tests (15 points):**
```
Score = (passing_e2e / total_e2e) * 15

Examples:
- 5/5 pass = 15 points
- 3/5 pass = 9 points
- 0/5 pass = 0 points
```

**Bundle Size (20 points):**
```
if all_bundles_under_budget:
    score = 20
elif bundles_over_budget <= 2:
    score = 10  # Warning
else:
    score = 0   # Fail

Examples:
- All bundles ≤ 500KB = 20 points
- 1 bundle = 550KB = 10 points (warning)
- 3 bundles over = 0 points (fail)
```

### Quality Gates

Configure thresholds in `.specswarm/quality-standards.md`:

```yaml
min_test_coverage: 85          # Minimum 85% code coverage
min_quality_score: 80          # Minimum 80/100 overall score
block_merge_on_failure: false  # Prevent merge if quality < threshold
```

### Real-World Examples

**Scenario 1: Excellent Quality (Score: 95)**
```
Unit Tests:        25/25 (100% pass rate)
Code Coverage:     23/25 (92% coverage)
Integration:       15/15 (all pass)
Browser Tests:     12/15 (80% pass rate)
Bundle Size:       20/20 (all under budget)
Visual:            0/15  (not implemented)
--------------------------------
Total:             95/100 ✅ PASS (threshold: 80)
```

**Scenario 2: Borderline (Score: 78)**
```
Unit Tests:        20/25 (80% pass rate)
Code Coverage:     18/25 (72% coverage)
Integration:       12/15 (80% pass rate)
Browser Tests:     0/15  (no E2E tests)
Bundle Size:       10/20 (2 bundles over budget)
Visual:            0/15  (not implemented)
--------------------------------
Total:             78/100 ❌ FAIL (threshold: 80)

Action Required:
- Fix 10% unit test failures
- Add E2E tests for critical flows
- Reduce bundle sizes (see /specswarm:analyze-quality)
```

**Scenario 3: Production Ready (Score: 100)**
```
Unit Tests:        25/25 (100% pass rate)
Code Coverage:     25/25 (100% coverage)
Integration:       15/15 (all pass)
Browser Tests:     15/15 (all pass)
Bundle Size:       20/20 (all under budget)
Visual:            0/15  (not implemented)
--------------------------------
Total:             100/100 ✅ EXCELLENT
```

### When Quality Validation Runs

| Command | Validation | Scoring | Gates |
|---------|-----------|---------|-------|
| `/specswarm:implement` | ✅ Full | ✅ Yes | ✅ Yes |
| `/specswarm:bugfix` | ✅ Full | ✅ Yes | ✅ Yes |
| `/specswarm:ship` | ✅ Full | ✅ Yes | ✅ Yes (blocks merge) |
| `/specswarm:analyze-quality` | ✅ Full | ✅ Yes | ❌ No (report only) |
| `/specswarm:fix` | ✅ Tests only | ❌ No | ❌ No |
| `/specswarm:modify` | ✅ Full | ✅ Yes | ✅ Yes |
| `/specswarm:modify --refactor` | ✅ Full | ✅ Yes | ✅ Yes |

---

## Tech Stack Management

### Overview

Prevents technology drift by validating against `.specswarm/tech-stack.md` at multiple phases.

### Validation Phases

**1. Plan Phase (`/specswarm:plan`)**
- Checks proposed libraries against approved list
- Flags prohibited patterns
- Suggests alternatives

**2. Task Phase (`/specswarm:tasks`)**
- Validates task dependencies
- Ensures tasks use approved tech

**3. Implementation Phase (`/specswarm:implement`)**
- Scans created files for imports
- Detects prohibited library usage
- Blocks commit if violations found

### Detection Methods

**Import Analysis:**
```typescript
// Detected prohibited pattern
import { createStore } from 'redux';  // ❌ Redux prohibited

// Suggested alternative
import { loader, action } from '@remix-run/react';  // ✅ React Router approved
```

**Package.json Scanning:**
```json
{
  "dependencies": {
    "redux": "^5.0.0"  // ❌ Flagged during install
  }
}
```

**Pattern Matching:**
```typescript
// Detected class component
class UserProfile extends React.Component {  // ❌ Class components prohibited
  render() { ... }
}

// Suggested functional component
function UserProfile() {  // ✅ Functional components approved
  return ...;
}
```

### Tech Stack File Structure

```markdown
# .specswarm/tech-stack.md

## Core Technologies
- TypeScript 5.x (required)
- React Router v7 (framework mode)
- PostgreSQL 17.x

## Approved Libraries

### Validation
- Zod v4+ (type-safe validation)

### Database
- Drizzle ORM (type-safe SQL)

### UI Components
- shadcn/ui (accessible components)

## Prohibited

### State Management
- ❌ Redux - Use React Router loaders/actions
  - Reason: Built-in server state in RR v7
  - Alternative: Zustand for client state

### Date/Time
- ❌ Moment.js - Use date-fns or Intl
  - Reason: 67KB bundle size
  - Alternative: date-fns (2KB per function)

### HTTP
- ❌ axios - Use fetch API
  - Reason: Native fetch is sufficient
  - Alternative: ky (3KB) if fetch wrapper needed
```

### Drift Prevention Effectiveness

**Without Tech Stack Management:**
```
Feature 1: Uses Redux
Feature 2: Uses Zustand
Feature 3: Uses React Context
Feature 4: Uses Jotai
Result: 4 different state solutions = maintenance nightmare
```

**With Tech Stack Management:**
```
Feature 1: React Router loaders (server state)
Feature 2: React Router loaders (server state)
Feature 3: React Router loaders (server state)
Feature 4: Zustand (client state, approved)
Result: Consistent patterns = maintainable codebase
```

### Metrics

- **False Positives**: Low (usually monorepo package conflicts)
- **Developer Satisfaction**: High (prevents review churn)

---

---

## Multi-Framework Testing

### Supported Test Frameworks (11)

SpecSwarm automatically detects and runs tests with:

**JavaScript/TypeScript:**
- **Vitest** - Fast unit testing
- **Jest** - Popular testing framework
- **Mocha** - Flexible test runner
- **Jasmine** - Behavior-driven testing

**Python:**
- **Pytest** - Modern Python testing
- **unittest** - Standard library testing

**Go:**
- **go test** - Built-in testing

**Ruby:**
- **RSpec** - Behavior-driven development

**Java:**
- **JUnit** - Standard Java testing

**PHP:**
- **PHPUnit** - PHP testing framework

**Rust:**
- **cargo test** - Rust testing

### Auto-Detection Algorithm

```typescript
// Pseudocode for test framework detection
function detectTestFramework(projectPath: string): TestFramework {
  // Check package.json first
  const packageJson = readPackageJson(projectPath);

  if (packageJson.devDependencies?.vitest) return 'vitest';
  if (packageJson.devDependencies?.jest) return 'jest';
  if (packageJson.devDependencies?.mocha) return 'mocha';

  // Check for language-specific files
  if (fileExists('pytest.ini') || fileExists('pyproject.toml')) return 'pytest';
  if (fileExists('go.mod')) return 'go-test';
  if (fileExists('Gemfile') && hasRSpec()) return 'rspec';
  if (fileExists('pom.xml') || fileExists('build.gradle')) return 'junit';
  if (fileExists('Cargo.toml')) return 'cargo-test';
  if (fileExists('composer.json') && hasPHPUnit()) return 'phpunit';

  return 'unknown';
}
```

### Test Execution

**Single framework:**
```bash
# Vitest detected
✓ Running tests with Vitest
  ✓ 45 tests passed
  ✓ 2 tests failed
  Coverage: 87%
```

**Multiple frameworks (monorepo):**
```bash
# Frontend: Vitest
✓ Frontend tests: 45/45 passed

# Backend: Pytest
✓ Backend tests: 23/25 passed

# Go services: go test
✓ Service tests: 15/15 passed
```

### Coverage Collection

**Supported coverage tools:**
- **JavaScript**: c8, istanbul, Vitest coverage, Jest coverage
- **Python**: coverage.py, pytest-cov
- **Go**: go test -cover
- **Ruby**: SimpleCov
- **Java**: JaCoCo
- **PHP**: Xdebug, PHPDBG
- **Rust**: tarpaulin, llvm-cov

**Coverage formats:**
```
Coverage: 87.5% (263/300 lines)
Files:
  src/auth.ts:         95% (120/126 lines)
  src/api.ts:          82% (98/120 lines)
  src/components/:     88% (45/51 lines)
```

---

## Natural Language Commands

### Architecture

**Skills vs Commands:**
- **Skills**: Auto-invoked by Claude based on intent detection
- **Commands**: Manually invoked with `/specswarm:` prefix

Both run the same underlying workflows.

### Skill-Based Routing

SpecSwarm uses keyword matching to route natural language to the right workflow:

**Clear intent** — routes directly:
```
User: "Build user authentication with JWT"
→ Routes to /specswarm:build "user authentication with JWT"
```

**Ambiguous intent** — asks for clarification:
```
User: "Work on the app"
→ Asks: What would you like to do? (build / fix / modify)
```

### Safety

**SHIP always confirms** — destructive operations are never auto-executed:
```
User: "Ship it"

SpecSwarm:
  ⚠️ SHIP CONFIRMATION - Destructive Operation

  This will:
    • Merge feature branch to main
    • Delete feature branch
    • Cannot be easily undone

  Are you sure? (yes/no): _
```

### Trigger Keywords

See individual skills for complete keyword lists:
- `skills/specswarm-build/SKILL.md:specswarm-build/SKILL.md`
- `skills/specswarm-fix/SKILL.md:specswarm-fix/SKILL.md`
- `skills/specswarm-modify/SKILL.md:specswarm-modify/SKILL.md`
- `skills/specswarm-ship/SKILL.md:specswarm-ship/SKILL.md`
- `skills/specswarm-upgrade/SKILL.md:specswarm-upgrade/SKILL.md`

---

## Language Agnostic

SpecSwarm's core workflow (specify, clarify, plan, tasks, implement, ship) works with **any language or framework** Claude can read. There is no language-specific tooling — Claude handles the code understanding and generation.

The quality analysis step includes test runner detection for common frameworks as a convenience for automated scoring. See [Multi-Framework Testing](#multi-framework-testing) above for supported test runners.

---

## Planned Features

The following features are designed but **not yet implemented** (shell scripts do not exist):

- **Chain Bug Detection** — Compare test counts before/after fixes to prevent cascading failures
- **SSR Pattern Validation** — Detect hardcoded URLs, browser-only APIs in server contexts
- **Bundle Size Monitoring** — Analyze production bundles, enforce size budgets
- **Language Auto-Detection** — Automatic project language detection during init

---

## Workflow Orchestration

### Overview

Autonomous multi-agent workflow execution (experimental).

### Orchestration Modes

**`/specswarm:build --orchestrate`**
- Multi-agent coordination
- Autonomous decision-making
- Continuous validation
- AI-powered test generation
- User flow validation
- Auto-fixes errors
- Performance metrics

### Agent Coordination

```typescript
interface OrchestrationAgent {
  name: string;
  role: 'planner' | 'implementer' | 'validator' | 'fixer';
  capabilities: string[];
  currentTask?: Task;
}

// Example orchestration
const agents = [
  {
    name: 'Planner',
    role: 'planner',
    capabilities: ['spec', 'plan', 'tasks'],
  },
  {
    name: 'Implementer',
    role: 'implementer',
    capabilities: ['code', 'files', 'tests'],
  },
  {
    name: 'Validator',
    role: 'validator',
    capabilities: ['quality', 'tests', 'validation'],
  },
  {
    name: 'Fixer',
    role: 'fixer',
    capabilities: ['debug', 'fix', 'retry'],
  },
];
```

---

**See also:**
- [README.md](../README.md) - Quick start
- [COMMANDS.md](../COMMANDS.md) - Command reference
- [docs/SETUP.md](./SETUP.md) - Setup guide

---

**SpecSwarm v4.0.1** - Features deep-dive
