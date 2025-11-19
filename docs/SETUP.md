# SpecSwarm Setup Guide

Complete technical setup documentation for SpecSwarm.

## Table of Contents

- [Installation](#installation)
- [Directory Structure](#directory-structure)
- [Configuration](#configuration)
- [Tech Stack Definition](#tech-stack-definition)
- [Quality Standards](#quality-standards)
- [Performance Budgets](#performance-budgets)
- [Optional Integrations](#optional-integrations)
- [Manual Setup](#manual-setup)
- [Troubleshooting](#troubleshooting)

---

## Installation

### Automated Installation (Recommended)

Install SpecSwarm from GitHub in two simple steps:

```bash
# 1. Add the marketplace
/plugin marketplace add MartyBonacci/specswarm

# 2. Install the plugin
/plugin install specswarm@MartyBonacci
```

Restart Claude Code to activate the plugin.

### Verify Installation

```bash
# Check installed plugins
/plugin list

# You should see:
# specswarm@MartyBonacci v3.5.0
```

---

## Directory Structure

### Overview

SpecSwarm stores all artifacts in `.specswarm/` to avoid conflicts with other tools:

```
my-project/
├── .specswarm/                  # SpecSwarm workspace (committed to git)
│   ├── features/                # Feature-specific artifacts
│   │   ├── 001-user-authentication/
│   │   │   ├── spec.md         # Feature specification
│   │   │   ├── plan.md         # Implementation plan
│   │   │   └── tasks.md        # Task breakdown
│   │   ├── 002-password-reset/
│   │   │   ├── spec.md
│   │   │   ├── plan.md
│   │   │   └── tasks.md
│   │   └── 003-payment-processing/
│   │       ├── spec.md
│   │       ├── plan.md
│   │       └── tasks.md
│   ├── tech-stack.md           # Technology standards
│   ├── quality-standards.md    # Quality gates and budgets
│   └── constitution.md         # Project governance
├── src/                        # Your application code
├── tests/                      # Your test files
└── package.json                # Your dependencies
```

### Auto-Migration from Old Structure

**Legacy Structure:**
```
my-project/
├── features/                   # Old location (conflicts with Cucumber)
│   ├── 001-user-authentication/
│   └── 002-password-reset/
```

**SpecSwarm automatically migrates to:**
```
my-project/
├── .specswarm/
│   ├── features/               # New location
│   │   ├── 001-user-authentication/
│   │   └── 002-password-reset/
```

**Migration behavior:**
- Runs automatically on first SpecSwarm command
- Moves `features/` → `.specswarm/features/`
- Preserves all files and history
- No data loss
- One-time operation

### Why `.specswarm/`?

✅ **Avoids conflicts** with Cucumber/Gherkin `features/`
✅ **Groups artifacts** together like `.github/`, `.vscode/`
✅ **Stays in git** - valuable documentation is committed
✅ **Clear ownership** - explicitly SpecSwarm-managed

---

## Configuration

### Recommended: Use `/specswarm:init`

The easiest way to configure SpecSwarm:

```bash
/specswarm:init
```

**What it creates:**
- `.specswarm/tech-stack.md` (with interactive prompts)
- `.specswarm/quality-standards.md` (with default values)
- `.specswarm/constitution.md` (optional)
- Directory structure

**Interactive prompts:**
1. Core technologies (e.g., "React 19.x, Node.js 20.x")
2. Approved libraries (e.g., "Zod, Drizzle ORM")
3. Prohibited patterns (e.g., "Redux, Class components")
4. Quality threshold (default: 80)
5. Test coverage minimum (default: 85%)
6. Bundle size budget (default: 500KB)

### Manual Configuration

If you prefer manual setup, create these files:

---

## Tech Stack Definition

### Create `.specswarm/tech-stack.md`

**Purpose:** Prevent technology drift across features (95% effectiveness)

**Template:**

```markdown
# Technology Stack

## Core Technologies

Define your foundational technologies with specific versions:

- **Runtime**: Node.js 20.x
- **Language**: TypeScript 5.x
- **Framework**: React Router v7 (framework mode)
- **Database**: PostgreSQL 17.x
- **Styling**: Tailwind CSS v4

## Approved Libraries

Libraries you've evaluated and approved for use:

### Validation
- **Zod v4+** - Type-safe runtime validation

### Database
- **Drizzle ORM** - Type-safe SQL queries

### State Management
- **React Router loaders/actions** - Server-side state
- **Zustand** - Client-side state (when needed)

### UI Components
- **shadcn/ui** - Accessible components
- **Headless UI** - Unstyled primitives

## Prohibited

Patterns and libraries explicitly banned from use:

- ❌ **Redux** - Use React Router loaders/actions for server state
- ❌ **Class components** - Use functional components with hooks
- ❌ **Moment.js** - Use native Intl or date-fns (smaller bundle)
- ❌ **axios** - Use native fetch API
- ❌ **Lodash** - Use native ES methods or es-toolkit (smaller)

## Decision Rationale

### Why React Router v7?
- Built-in SSR and data loading
- Eliminates need for separate state management
- Progressive enhancement by default
- Modern React patterns

### Why Drizzle over Prisma?
- Zero runtime dependencies
- Fully type-safe without code generation
- SQL-first approach
- Better edge/serverless support

### Why ban Redux?
- Replaced by React Router loaders/actions
- Reduces bundle size
- Simpler mental model
- Better server integration
```

**Impact:**
- SpecSwarm validates tech stack at **plan**, **task**, and **implementation** phases
- Catches drift before it's committed
- Provides feedback when prohibited libraries detected
- Suggests alternatives from approved list

---

## Quality Standards

### Create `.specswarm/quality-standards.md`

**Purpose:** Define quality gates and thresholds for automated validation

**Template:**

```yaml
---
# Quality Gates
min_test_coverage: 85          # Minimum code coverage percentage (0-100)
min_quality_score: 80          # Minimum overall quality score (0-100)
block_merge_on_failure: false  # true = prevent merge if quality fails

# Performance Budgets
enforce_budgets: true          # Enable bundle size monitoring
max_bundle_size: 500           # KB per individual bundle
max_initial_load: 1000         # KB for initial page load
max_route_bundle: 300          # KB per route bundle

# Test Requirements
require_unit_tests: true       # Must have unit tests
require_integration_tests: true # Must have integration tests
require_browser_tests: false   # E2E tests (expensive, optional)

# Validation Rules
enforce_ssr_patterns: true     # Validate SSR-safe code (React Router v7/Remix/Next.js)
check_tech_stack_drift: true   # Validate against tech-stack.md
detect_chain_bugs: true        # Compare test counts before/after
---

# Quality Score Breakdown (0-100 points)

## Unit Tests (25 points)
- 0 passing = 0 points
- Proportional by pass rate
- Example: 80% pass rate = 20 points

## Code Coverage (25 points)
- 0% coverage = 0 points
- Proportional by coverage percentage
- Example: 85% coverage = 21.25 points

## Integration Tests (15 points)
- 0 passing = 0 points
- Proportional by pass rate
- API/service level testing

## Browser Tests (15 points)
- 0 passing = 0 points
- Proportional by pass rate
- E2E user flows with Playwright

## Bundle Size (20 points)
- 20 points if all bundles under budget
- 10 points if 1-2 bundles over budget
- 0 points if 3+ bundles over budget

## Visual Alignment (15 points - Future)
- Placeholder for design QA automation
```

**Quality Score Examples:**

| Scenario | Unit | Coverage | Integration | Browser | Bundle | Total | Pass? |
|----------|------|----------|-------------|---------|--------|-------|-------|
| Excellent | 25 | 25 | 15 | 15 | 20 | **100** | ✅ Yes |
| Good | 20 | 21 | 12 | 10 | 20 | **83** | ✅ Yes |
| Borderline | 15 | 17 | 10 | 0 | 10 | **52** | ❌ No (< 80) |
| Poor | 10 | 10 | 5 | 0 | 0 | **25** | ❌ No |

---

## Performance Budgets

### Bundle Size Monitoring

**How it works:**
1. SpecSwarm analyzes production build output
2. Calculates total size of each bundle
3. Compares against budget in `quality-standards.md`
4. Awards 0-20 points based on compliance

**Supported bundlers:**
- Vite
- Webpack
- Rollup
- esbuild
- Parcel

**Example budget enforcement:**

```yaml
# .specswarm/quality-standards.md
enforce_budgets: true
max_bundle_size: 500           # 500 KB per bundle
max_initial_load: 1000         # 1 MB initial load
```

**Scoring:**
- All bundles under budget: **20 points**
- 1-2 bundles over budget: **10 points** (warning)
- 3+ bundles over budget: **0 points** (fail)

**What to do when budget exceeded:**

```bash
# 1. Analyze bundle composition
npx vite-bundle-visualizer

# 2. Common solutions:
# - Code splitting: import() dynamic imports
# - Tree shaking: Remove unused exports
# - Lazy loading: Defer non-critical code
# - Dependency audit: Remove large unused libs

# 3. Re-validate
/specswarm:analyze-quality
```

---

## Optional Integrations

### Chrome DevTools MCP (Web Projects Only)

**Purpose:** Enhanced browser debugging for React, Vue, Next.js, etc.

**Benefits:**
- ✅ Real-time console monitoring during tests
- ✅ Network request inspection
- ✅ Runtime state debugging
- ✅ Saves ~200MB (no Chromium download)
- ✅ Persistent browser profile

**Installation:**

```bash
claude mcp add ChromeDevTools/chrome-devtools-mcp
```

**Auto-Detection:**

SpecSwarm automatically detects:
1. **Web project** (package.json with React/Vue/Angular/Next/Astro/Svelte)
2. **Chrome DevTools MCP available**
3. **Uses MCP** for enhanced debugging

**Fallback:**
- Without MCP: Uses Playwright + Chromium download (~200MB)
- No errors, seamless fallback
- Identical functionality

**Commands that use MCP:**
- `/specswarm:bugfix` - Enhanced error diagnostics
- `/specswarm:fix` - Retry diagnostics with console monitoring
- `/specswarm:validate` - Browser automation with real-time logs

**Not applicable to:**
- Python projects
- Go projects
- PHP projects
- Ruby projects
- Rust projects

---

## Manual Setup

### Create Minimal Configuration

If you want to skip `/specswarm:init`:

**1. Create directory:**
```bash
mkdir -p .specswarm/features
```

**2. Create tech-stack.md:**
```bash
echo "## Core Technologies
- Your framework here

## Approved Libraries
- Your libraries here

## Prohibited
- Things to avoid" > .specswarm/tech-stack.md
```

**3. Create quality-standards.md:**
```bash
echo "---
min_test_coverage: 80
min_quality_score: 80
enforce_budgets: true
max_bundle_size: 500
---" > .specswarm/quality-standards.md
```

**4. Commit to git:**
```bash
git add .specswarm/
git commit -m "Initialize SpecSwarm configuration"
```

---

## Troubleshooting

### Quality Validation Not Running

**Symptom:** `/specswarm:implement` or `/specswarm:analyze-quality` doesn't validate

**Solution:**
```bash
# Ensure quality-standards.md exists
ls .specswarm/quality-standards.md

# If missing, create it:
/specswarm:init
```

### Tech Stack Drift Not Detected

**Symptom:** Prohibited libraries used without warning

**Solution:**
```bash
# Ensure tech-stack.md exists and has Prohibited section
cat .specswarm/tech-stack.md

# Format:
# ## Prohibited
# - ❌ Library Name (reason)
```

### SSR Validation Fails

**Symptom:** Error about hardcoded URLs in loaders/actions

**Solution:**

Create environment-aware helper:

```typescript
// app/utils/api.ts
export function getApiUrl(path: string): string {
  const base = typeof window !== 'undefined'
    ? ''  // Browser: relative URLs
    : process.env.API_BASE_URL || 'http://localhost:3000';  // Server: absolute
  return `${base}${path}`;
}

// Usage in loaders:
export async function loader() {
  const response = await fetch(getApiUrl('/api/users'));
  return response.json();
}
```

### Bundle Size Exceeds Budget

**Symptom:** Quality score penalized for large bundles

**Solutions:**

**1. Implement code splitting:**
```typescript
// Before: Direct import
import HeavyComponent from './HeavyComponent';

// After: Dynamic import
const HeavyComponent = lazy(() => import('./HeavyComponent'));
```

**2. Use dynamic imports:**
```typescript
// Route-based splitting
const routes = [
  {
    path: '/dashboard',
    lazy: () => import('./routes/dashboard'),
  },
];
```

**3. Analyze bundle:**
```bash
npx vite-bundle-visualizer
# or
npx webpack-bundle-analyzer dist/stats.json
```

**4. Remove unused dependencies:**
```bash
npm uninstall unused-package
```

### Features Directory Not Migrated

**Symptom:** Old `features/` still in project root

**Solution:**
```bash
# Run any SpecSwarm command to trigger auto-migration
/specswarm:suggest "test"

# Or manually:
mv features .specswarm/features
```

### Plugin Not Loading

**Symptom:** `/specswarm:*` commands not recognized

**Solutions:**

**1. Verify installation:**
```bash
/plugin list
```

**2. Reinstall if missing:**
```bash
/plugin install specswarm@MartyBonacci
```

**3. Restart Claude Code:**
```bash
# Exit and reopen Claude Code
```

**4. Check marketplace:**
```bash
/plugin marketplace list
```

### Natural Language Skills Not Triggering

**Symptom:** "Build auth" doesn't trigger `/specswarm:build`

**Possible causes:**

**1. Plugin not restarted:**
```bash
# Restart Claude Code after installation
```

**2. Conflicting user-level skills:**
```bash
# Check for conflicts
ls ~/.claude/skills/

# Remove if found:
rm -rf ~/.claude/skills/specswarm-*
```

**3. Insufficient confidence:**
- Try more specific phrasing: "Build user authentication with JWT"
- Or use slash command: `/specswarm:build "auth"`

### Permission Errors

**Symptom:** Cannot read/write `.specswarm/` files

**Solution:**
```bash
# Fix permissions
chmod -R u+rw .specswarm/
```

---

## Advanced Configuration

### Custom Feature Numbering

By default, features are numbered `001-`, `002-`, etc.

**Custom prefix:**
```yaml
# .specswarm/quality-standards.md
feature_prefix: "FEAT-"  # Results in FEAT-001-, FEAT-002-
```

### Multiple Environments

**Development:**
```yaml
# .specswarm/quality-standards.md
min_quality_score: 70  # Relaxed for rapid iteration
```

**Production:**
```yaml
# .specswarm/quality-standards.md
min_quality_score: 90  # Strict for releases
block_merge_on_failure: true
```

### CI/CD Integration

**GitHub Actions:**
```yaml
# .github/workflows/quality.yml
name: Quality Check
on: [pull_request]
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: /specswarm:analyze-quality
      - run: exit ${{ quality_score >= 80 ? 0 : 1 }}
```

---

## Next Steps

- **Quick Start**: See [README.md](../README.md) for first feature
- **Commands**: See [COMMANDS.md](../COMMANDS.md) for complete reference
- **Features**: See [FEATURES.md](./FEATURES.md) for technical deep-dive

---

**SpecSwarm v3.5.0** - Complete setup guide
