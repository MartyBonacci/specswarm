# SpecSwarm Features Deep-Dive

Technical documentation for SpecSwarm's advanced features and capabilities.

## Table of Contents

- [Quality Validation System](#quality-validation-system)
- [Tech Stack Management](#tech-stack-management)
- [SSR Pattern Validation](#ssr-pattern-validation)
- [Multi-Framework Testing](#multi-framework-testing)
- [Chain Bug Detection](#chain-bug-detection)
- [Bundle Size Monitoring](#bundle-size-monitoring)
- [Natural Language Commands](#natural-language-commands)
- [Multi-Language Support](#multi-language-support)
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

Prevents **95% of technology drift** by validating against `.specswarm/tech-stack.md` at multiple phases.

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

- **Drift Detection Rate**: 95% (based on production usage)
- **False Positives**: <5% (usually monorepo package conflicts)
- **Developer Satisfaction**: High (prevents review churn)

---

## SSR Pattern Validation

### Overview

Detects production failures before deployment by validating SSR-safe patterns in React Router v7, Remix, and Next.js applications.

### Common SSR Violations

**1. Hardcoded URLs in Loaders**

❌ **Violation:**
```typescript
export async function loader() {
  // Fails in production: localhost not accessible from server
  const response = await fetch('http://localhost:3000/api/users');
  return response.json();
}
```

✅ **Correct:**
```typescript
export async function loader({ request }: LoaderArgs) {
  const url = new URL(request.url);
  const apiUrl = `${url.protocol}//${url.host}/api/users`;
  const response = await fetch(apiUrl);
  return response.json();
}
```

**2. Relative URLs in SSR Context**

❌ **Violation:**
```typescript
export async function loader() {
  // Fails on server: no window object
  const response = await fetch('/api/users');  // Relative URL
  return response.json();
}
```

✅ **Correct:**
```typescript
import { getApiUrl } from '~/utils/api';

export async function loader() {
  const response = await fetch(getApiUrl('/api/users'));
  return response.json();
}

// utils/api.ts
export function getApiUrl(path: string): string {
  if (typeof window !== 'undefined') {
    return path;  // Browser: relative is fine
  }
  return `${process.env.API_BASE_URL || 'http://localhost:3000'}${path}`;
}
```

**3. Browser-Only APIs**

❌ **Violation:**
```typescript
export function loader() {
  const userId = localStorage.getItem('userId');  // ReferenceError on server
  return { userId };
}
```

✅ **Correct:**
```typescript
export function loader({ request }: LoaderArgs) {
  const cookie = request.headers.get('Cookie');
  const userId = parseCookie(cookie).userId;
  return { userId };
}
```

### Detection Algorithm

```typescript
// Pseudocode for SSR validation
function validateSSRPatterns(code: string): Violation[] {
  const violations = [];

  // 1. Check for hardcoded localhost
  if (code.includes('localhost') && isInLoader(code)) {
    violations.push({
      type: 'HARDCODED_LOCALHOST',
      severity: 'error',
      message: 'Use environment-aware URL construction',
    });
  }

  // 2. Check for browser-only APIs
  const browserAPIs = ['localStorage', 'sessionStorage', 'window', 'document'];
  for (const api of browserAPIs) {
    if (code.includes(api) && isInLoader(code)) {
      violations.push({
        type: 'BROWSER_API_IN_SSR',
        severity: 'error',
        message: `${api} not available on server`,
      });
    }
  }

  // 3. Check for relative fetch without environment detection
  if (code.match(/fetch\(['"`]\/api/) && !hasEnvironmentCheck(code)) {
    violations.push({
      type: 'RELATIVE_FETCH_WITHOUT_CHECK',
      severity: 'warning',
      message: 'Use environment-aware helper for API calls',
    });
  }

  return violations;
}
```

### Supported Frameworks

| Framework | Validation | Loader Detection | Action Detection |
|-----------|-----------|------------------|------------------|
| React Router v7 | ✅ Full | ✅ Yes | ✅ Yes |
| Remix | ✅ Full | ✅ Yes | ✅ Yes |
| Next.js | ✅ Partial | ✅ getServerSideProps | ✅ API routes |
| SvelteKit | 🚧 Planned | ❌ Not yet | ❌ Not yet |
| Astro | 🚧 Planned | ❌ Not yet | ❌ Not yet |

### Environment-Aware Patterns

**Recommended Helper:**

```typescript
// app/utils/env.ts
export function isBrowser(): boolean {
  return typeof window !== 'undefined';
}

export function isServer(): boolean {
  return !isBrowser();
}

export function getApiUrl(path: string, request?: Request): string {
  if (isBrowser()) {
    return path;  // Browser: use relative URLs
  }

  // Server: need absolute URL
  if (request) {
    const url = new URL(request.url);
    return `${url.protocol}//${url.host}${path}`;
  }

  return `${process.env.API_BASE_URL || 'http://localhost:3000'}${path}`;
}

// Usage in loader:
export async function loader({ request }: LoaderArgs) {
  const users = await fetch(getApiUrl('/api/users', request));
  return users.json();
}
```

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

## Chain Bug Detection

### Problem Statement

**Scenario:**
1. Fix Bug 912 (login fails with special characters)
2. Introduce Bug 913 (SSR crash in production)
3. Bug 913 not caught because no tests ran on server

**Result:** Cascading failures, production incidents

### Solution

SpecSwarm compares test counts before/after to detect new failures.

### Detection Algorithm

```typescript
function detectChainBugs(before: TestResults, after: TestResults): ChainBug[] {
  const chainBugs = [];

  // 1. Compare total test counts
  if (after.total < before.total) {
    chainBugs.push({
      type: 'TESTS_DISAPPEARED',
      message: `${before.total - after.total} tests no longer run`,
    });
  }

  // 2. Compare passing tests
  if (after.passing < before.passing) {
    const newFailures = before.passing - after.passing;
    chainBugs.push({
      type: 'NEW_FAILURES',
      message: `${newFailures} tests now failing (chain bug suspected)`,
      newlyFailing: identifyNewlyFailingTests(before, after),
    });
  }

  // 3. Check for SSR-specific failures
  if (hasNewSSRErrors(after) && !hasNewSSRErrors(before)) {
    chainBugs.push({
      type: 'SSR_REGRESSION',
      message: 'New SSR errors detected',
    });
  }

  // 4. Check for TypeScript errors
  if (after.typeErrors > before.typeErrors) {
    chainBugs.push({
      type: 'TYPE_ERRORS',
      message: `${after.typeErrors - before.typeErrors} new TypeScript errors`,
    });
  }

  return chainBugs;
}
```

### Real-World Example

**Before fix:**
```
Unit Tests:     50 passed, 0 failed
Integration:    10 passed, 0 failed
Browser Tests:  5 passed, 0 failed
TypeScript:     0 errors
```

**After fix:**
```
Unit Tests:     49 passed, 1 failed  ⚠️ Chain bug detected!
Integration:    9 passed, 1 failed   ⚠️ Chain bug detected!
Browser Tests:  5 passed, 0 failed
TypeScript:     2 errors              ⚠️ New errors!

CHAIN BUG REPORT:
- 2 new test failures (unit + integration)
- 2 new TypeScript errors
- Likely introduced by fix for Bug 912

Newly failing tests:
- test/integration/auth-ssr.test.ts: "SSR auth check"
- test/unit/session.test.ts: "session validation"

Action: Review fix, add SSR test coverage
```

### Prevention

Chain bug detection stops cascading failures by:
1. Running full test suite after every fix
2. Comparing results to baseline
3. Flagging new failures immediately
4. Blocking merge if chain bugs detected

---

## Bundle Size Monitoring

### Overview

Automatic performance budget enforcement with bundle size tracking.

### Supported Bundlers

| Bundler | Detection | Analysis | Budget Check |
|---------|-----------|----------|--------------|
| Vite | ✅ Auto | ✅ dist/ analysis | ✅ Yes |
| Webpack | ✅ Auto | ✅ stats.json | ✅ Yes |
| Rollup | ✅ Auto | ✅ dist/ analysis | ✅ Yes |
| esbuild | ✅ Auto | ✅ outdir analysis | ✅ Yes |
| Parcel | ✅ Auto | ✅ dist/ analysis | ✅ Yes |

### Budget Configuration

```yaml
# .specswarm/quality-standards.md
enforce_budgets: true
max_bundle_size: 500           # KB per bundle
max_initial_load: 1000         # KB initial load
max_route_bundle: 300          # KB per route
```

### Analysis Output

```
Bundle Size Analysis:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Bundle              Size      Budget    Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
main.js             387 KB    500 KB    ✅ PASS
vendor.js           456 KB    500 KB    ✅ PASS
dashboard.js        523 KB    300 KB    ⚠️ OVER
admin.js            612 KB    300 KB    ⚠️ OVER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Initial Load:       843 KB    1000 KB   ✅ PASS
Total:              1978 KB
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Score: 10/20 points (2 bundles over budget)

Recommendations:
1. dashboard.js (+223 KB):
   - Use code splitting for charts
   - Lazy load heavy components

2. admin.js (+312 KB):
   - Remove unused dependencies
   - Implement route-based splitting
```

### Scoring

```
All bundles under budget:    20 points ✅
1-2 bundles over budget:     10 points ⚠️
3+ bundles over budget:      0 points  ❌
```

---

## Natural Language Commands

### Architecture

**Skills vs Commands:**
- **Skills**: Auto-invoked by Claude based on intent detection
- **Commands**: Manually invoked with `/specswarm:` prefix

Both run the same underlying workflows.

### Confidence-Based Execution

**High Confidence (95%+):**
```
User: "Build user authentication with JWT"

SpecSwarm:
  🎯 Detected: BUILD workflow (98% confidence)
  Running: /specswarm:build "user authentication with JWT"
  Press Ctrl+C within 3s to cancel...
  3... 2... 1...
  [Executes workflow]
```

**Medium Confidence (70-94%):**
```
User: "Add authentication"

SpecSwarm:
  🤔 I think you want to BUILD (75% confidence)
  Is this correct?
  1. Yes, run /specswarm:build
  2. No, handle normally

  Your choice: _
```

**Low Confidence (<70%):**
```
User: "Work on the app"

SpecSwarm:
  ❓ What would you like to do?
  1. Build new feature (/specswarm:build)
  2. Fix a bug (/specswarm:fix)
  3. Modify existing feature (/specswarm:modify)
  4. Handle normally

  Your choice: _
```

### Safety Overrides

**SHIP always confirms** (regardless of confidence):
```
User: "Ship it"  [99% confidence detected]

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

## Multi-Language Support

### Supported Languages (6)

1. **JavaScript/TypeScript**
2. **Python**
3. **PHP**
4. **Go**
5. **Ruby**
6. **Rust**

### Auto-Detection

```typescript
function detectLanguage(projectPath: string): Language[] {
  const languages = [];

  if (fileExists('package.json')) languages.push('javascript');
  if (fileExists('requirements.txt') || fileExists('pyproject.toml')) languages.push('python');
  if (fileExists('composer.json')) languages.push('php');
  if (fileExists('go.mod')) languages.push('go');
  if (fileExists('Gemfile')) languages.push('ruby');
  if (fileExists('Cargo.toml')) languages.push('rust');

  return languages;
}
```

### Framework Detection

**JavaScript/TypeScript:**
- React Router v7
- Remix
- Next.js
- Express
- Fastify
- Vite
- Astro

**Python:**
- Django
- Flask
- FastAPI

**PHP:**
- Laravel
- Symfony

**Go:**
- Gin
- Echo
- Chi

**Ruby:**
- Rails
- Sinatra

**Rust:**
- Actix
- Rocket
- Axum

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

**SpecSwarm v3.5.0** - Features deep-dive
