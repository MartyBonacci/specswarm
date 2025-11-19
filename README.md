# SpecSwarm v3.3.6

**Complete Software Development Toolkit**

Build, fix, maintain, and analyze your entire software project with one unified plugin.

---

## Overview

SpecSwarm is a comprehensive plugin that provides everything you need for the complete software development lifecycle across **6 languages** (JavaScript/TypeScript, Python, PHP, Go, Ruby, Rust):

- ✅ **Spec-Driven Development** - From specification to implementation
- 🌐 **Multi-Language Support** - Auto-detection for 6 languages and frameworks
- 🐛 **Bug & Issue Management** - Systematic fixing with regression testing
- 🔧 **Code Maintenance** - Refactoring and modernization
- 📊 **Quality Assurance** - Automated testing and validation
- 🚀 **Performance Monitoring** - Bundle size tracking and budgets
- 🏗️ **Architecture Validation** - SSR patterns, tech stack compliance
- 📖 **Context-Aware** - Reads README.md for better project understanding

**32 Commands** | **4 High-Level** + **28 Granular** | **Production Ready**

---

## Installation

Install SpecSwarm from GitHub in two simple steps:

```bash
# 1. Add the marketplace
/plugin marketplace add MartyBonacci/specswarm

# 2. Install the plugin
/plugin install specswarm@MartyBonacci
```

Restart Claude Code to activate the plugin.

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

## Natural Language Commands (v3.3+)

SpecSwarm now understands **natural language** - just describe what you want in plain English!

### Skills vs Commands Architecture

SpecSwarm provides two ways to execute workflows:

**🎤 Skills (Natural Language)** - Auto-invoked by Claude based on your intent
- Located in `skills/` directory
- Claude automatically activates when your message matches the skill description
- No slash notation needed - just describe what you want
- Examples: "build auth", "fix the login bug", "ship this feature"

**⚡ Commands (Slash Notation)** - Explicit manual invocation
- Located in `commands/` directory
- Require `/specswarm:command` syntax
- Provide precise control for power users
- Examples: `/specswarm:build`, `/specswarm:fix`, `/specswarm:ship`

**Both approaches run the same workflows** - Skills provide natural language convenience, Commands provide explicit control.

### How It Works

Instead of memorizing slash commands, simply tell SpecSwarm what you want to do:

**Build a Feature:**
```
"Build user authentication with JWT"
"Create a payment processing system"
"Add dashboard analytics"
```

**Fix a Bug:**
```
"Fix the login button on mobile"
"There's a bug in the checkout process"
"Authentication doesn't work"
```

**Ship a Feature:**
```
"Ship this feature"  ⚠️ (requires confirmation)
"Deploy to production"  ⚠️ (requires confirmation)
"Merge to main"  ⚠️ (requires confirmation)
```

**Upgrade Technology:**
```
"Upgrade to React 19"
"Migrate from Redux to Zustand"
"Update to the latest PostgreSQL"
```

### Confidence-Based Execution

SpecSwarm analyzes your request and provides confidence feedback:

- **High Confidence (95%+):** Auto-executes with 3-second cancel window
- **Medium Confidence (70-94%):** Asks for confirmation first
- **Low Confidence (<70%):** Shows numbered options to choose from

### Safety Features

🛡️ **SHIP Protection:** SHIP commands (deploy, merge, complete) **ALWAYS** require explicit "yes" confirmation, regardless of confidence level. This prevents accidental merges or deployments that could have significant consequences.

💡 **Confidence Indicators:** SpecSwarm shows its confidence level and detected workflow, so you always know what it's about to do.

⚡ **3-Second Cancel Window:** For high-confidence BUILD, FIX, and UPGRADE commands, you have 3 seconds to press Ctrl+C if the detection was wrong.

🎯 **Slash Commands Still Work:** All slash commands work exactly as before. Natural language is an optional convenience feature for faster workflows.

### Examples

**High Confidence (Auto-Execute):**
```
User: "Build a shopping cart feature"

SpecSwarm:
  🎯 Detected: BUILD workflow (98% confidence)

  Running: /specswarm:build "shopping cart feature"

  Press Ctrl+C within 3 seconds to cancel...
  3... 2... 1...

  [Continues with complete BUILD workflow]
```

**Medium Confidence (Confirmation):**
```
User: "Add authentication"

SpecSwarm:
  🤔 I think you want to BUILD (75% confidence)

  Is this correct? (y/n): _
```

**SHIP Safety (Always Confirm):**
```
User: "Ship it"

SpecSwarm:
  🎯 Detected: SHIP workflow (99% confidence)

  ⚠️  SHIP COMMAND CONFIRMATION REQUIRED

  This will:
    • Run quality validation
    • Create git commit
    • Merge to parent branch: main
    • Mark feature as complete

  Current branch: 003-payment-processing
  Merge target: main

  Are you sure you want to ship this feature? (yes/no): _
```

### Why Natural Language?

✅ **Lower Learning Curve:** No need to memorize slash command names
✅ **Natural Conversation:** Talk to SpecSwarm like a teammate
✅ **Faster Workflows:** Skip typing `/specswarm:`
✅ **Still Precise:** Slash commands remain for power users
✅ **Safety First:** SHIP command has mandatory confirmation
✅ **No Accidents:** Can't accidentally merge/deploy via typo

---

## Getting Started Workflow

### First-Time Project Setup

Before using SpecSwarm commands, establish your project foundation:

**Directory Structure:**

SpecSwarm stores all artifacts in `.specswarm/`:
```
my-project/
├── .specswarm/
│   ├── features/          # Feature artifacts (auto-migrated from old location)
│   │   ├── 001-user-authentication/
│   │   │   ├── spec.md
│   │   │   ├── plan.md
│   │   │   └── tasks.md
│   │   └── 002-password-reset/
│   ├── tech-stack.md      # Technology standards
│   ├── quality-standards.md
│   └── constitution.md
├── src/
└── package.json
```

**Auto-Migration:** If you have an existing `features/` directory in your project root, SpecSwarm will automatically migrate it to `.specswarm/features/` on first use. This:
- Eliminates conflicts with Cucumber/Gherkin `features/`
- Groups all SpecSwarm artifacts together
- Follows modern tooling patterns (`.github/`, `.vscode/`)
- Keeps valuable feature documentation committed in git

1. **Create Tech Stack Definition** (`.specswarm/tech-stack.md`):
   ```markdown
   ## Core Technologies
   - React 19.x
   - React Router v7

   ## Approved Libraries
   - Zod v4+ (validation)

   ## Prohibited
   - ❌ Redux (use React Router loaders/actions)
   ```

   This prevents 95% of technology drift across features.

2. **Set Quality Standards** (`.specswarm/quality-standards.md`):
   ```yaml
   min_test_coverage: 80
   min_quality_score: 85
   enforce_budgets: true
   max_bundle_size: 500  # KB
   ```

3. **Establish Project Governance**:
   ```bash
   /specswarm:constitution
   ```

### Feature Development Workflow

**Step 1: Get Workflow Recommendation**
```bash
/specswarm:suggest "add user authentication"
```
SpecSwarm analyzes your request and recommends the best workflow.

**Step 2: Execute Recommended Workflow**

For most features:
```bash
/specswarm:specify → /specswarm:clarify → /specswarm:plan →
/specswarm:tasks → /specswarm:implement
```

**Step 3: Quality Check & Complete**
```bash
# Check quality before merge
/specswarm:analyze-quality

# Merge to parent branch (shows confirmation with v2.1.2+)
/specswarm:complete
```

### When to Use Each Command

| Command | When to Use | Example |
|---------|-------------|---------|
| `/specswarm:suggest` | Starting any task | Get workflow recommendation |
| `/specswarm:specify` | New features | "Add shopping cart" |
| `/specswarm:bugfix` | Fixing bugs | "Login fails with +" |
| `/specswarm:hotfix` | Production emergencies | "API down in prod" |
| `/specswarm:modify` | Changing features | "Update cart logic" |
| `/specswarm:refactor` | Improving code | "Optimize auth" |
| `/specswarm:deprecate` | Removing features | "Sunset old API" |
| `/specswarm:analyze-quality` | Before merging | Quality check |
| `/specswarm:complete` | Finishing features | Merge & cleanup |

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
# .specswarm/tech-stack.md
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

Enable quality gates by creating `.specswarm/quality-standards.md`:

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

Define your stack in `.specswarm/tech-stack.md`:

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

## Optional: Chrome DevTools MCP (Web Projects Only)

For **web projects** (React, Vue, Next.js, etc.), SpecSwarm can leverage Chrome DevTools MCP for enhanced browser debugging during bugfixes and validation.

### Benefits for Web Projects

- ✅ **Real-time Console Monitoring** - Capture JavaScript errors during test execution
- ✅ **Network Request Inspection** - Monitor API calls and failures
- ✅ **Runtime State Debugging** - Inspect variables, DOM, application state
- ✅ **Saves ~200MB Download** - No Chromium installation needed
- ✅ **Persistent Browser Profile** - Stored at `~/.cache/chrome-devtools-mcp/`

### Installation (Optional)

```bash
claude mcp add ChromeDevTools/chrome-devtools-mcp
```

### Automatic Integration

Once installed, SpecSwarm **automatically detects** Chrome DevTools MCP and uses it for web projects:

```bash
# Bugfix workflow with enhanced debugging
/specswarm:bugfix "Login fails with special characters"

# Output:
# 🌐 Web project detected: React
# 🎯 Chrome DevTools MCP: Available for enhanced browser debugging
```

### Commands That Use Chrome DevTools MCP

**For Web Projects Only:**
- `/specswarm:bugfix` - Enhanced error diagnostics during bug reproduction
- `/specswarm:fix` - Retry diagnostics with console/network monitoring
- `/specswarm:validate` - Browser automation for flow validation

**Not Applicable to Non-Web Projects:**
- Python, PHP, Go, Ruby, Rust projects use language-specific debugging
- Chrome DevTools MCP is silently skipped for non-web projects

### Fallback Behavior

**Without Chrome DevTools MCP:**
- SpecSwarm automatically falls back to Playwright
- Downloads Chromium (~200MB) if needed
- Identical functionality, just without real-time MCP tools
- No errors or warnings - seamless fallback

### Detection Logic

SpecSwarm detects web projects by analyzing:
- `package.json` with React, Vue, Angular, Next.js, Astro, Svelte dependencies
- API frameworks (Express, Fastify) with `client/`, `public/`, `frontend/` directories

Non-web projects (Python CLI, Go APIs, Rust binaries) automatically skip browser automation.

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

Create `.specswarm/quality-standards.md` to enable quality gates.

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

### v3.3.1 (2025-11-18) - Natural Language Bug Fix 🔧
- **Fixed**: Natural language commands now work via Skills architecture
- **Added**: Skills directory with build/fix/ship/upgrade SKILL.md files
- **Changed**: Removed incorrect natural language claims from command files
- **Improved**: README documentation explaining Skills vs Commands architecture
- **Why**: v3.3.0 built NL infrastructure but placed it in Commands (slash-only) instead of Skills (auto-invoked)
- **Impact**: Natural language now actually works - "build auth" triggers `/specswarm:build`

### v3.3.0 (2025-11-17) - Natural Language Commands ⭐
- **New**: Natural language command detection for BUILD, FIX, SHIP, UPGRADE workflows
- **Safety**: SHIP commands ALWAYS require explicit confirmation (no bypass)
- **Smart**: Confidence-based execution (high/medium/low)
- **User-Friendly**: Talk to SpecSwarm naturally - "build auth", "fix login bug"
- **Backward Compatible**: All slash commands work exactly as before
- **Pattern Matching**: Sophisticated intent detection with 95%+ accuracy target
- **Graceful Degradation**: Shows numbered options when uncertain

### v2.1.2 (2025-11-04) - Git Workflow Safety ⭐
- **Fixed**: Parent branch detection bugs - robust MAIN_BRANCH fallback
- **New**: Branch confirmation prompts during feature creation
- **New**: Detailed merge validation before completing features
- **Safety**: Prevents accidental merges to wrong branches
- **UX**: Clear visibility into parent branch selection logic

### v2.1.1 (2025-10-30) - Parent Branch Tracking
- **Enhanced**: Parent branch tracking - features merge back to origin branch
- **Improved**: Complete workflow respects branch hierarchy
- **New**: Stores parent_branch in spec.md YAML frontmatter

### v2.1.0 (2025-10-20) - Enhanced Git Workflow
- **New**: Improved git branch detection and management
- **Fixed**: Branch detection edge cases
- **Improved**: Sequential branch workflow support

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

**SpecSwarm v3.3.4** - Your complete software development toolkit. 🚀

Build it. Fix it. Maintain it. Analyze it. All in one place.
