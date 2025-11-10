# SpecSwarm Complete Workflow Guide

**Complete step-by-step guide for using SpecSwarm and SpecLabs plugins effectively.**

---

## Table of Contents

1. [Introduction](#introduction)
2. [One-Time Project Setup](#one-time-project-setup)
3. [Feature Development Workflows](#feature-development-workflows)
4. [Testing and Quality](#testing-and-quality)
5. [Completion and Merge](#completion-and-merge)
6. [Real-World Examples](#real-world-examples)
7. [Troubleshooting](#troubleshooting)

---

## Introduction

This guide shows you how to use SpecSwarm and SpecLabs in your daily development workflow. Whether you're building features, fixing bugs, or maintaining code quality, this guide has you covered.

**Two Paths Available**:
- **SpecSwarm (Manual)**: Step-by-step control, production-ready
- **SpecLabs (Autonomous)**: Faster automation, experimental

---

## One-Time Project Setup

These steps are done **once per project**. They establish the foundation for all future work.

### Prerequisites: Starting a New Project

⚠️ **IMPORTANT**: SpecSwarm is designed for **feature development in existing projects**. Before using SpecSwarm, you need:

**Required**:
- ✅ **Git repository initialized** with at least one commit
- ✅ **Project structure** in place (src/, package.json, etc.)
- ✅ **Tech stack established** (React, Vue, Next.js, Astro, etc.)

**If you're starting from scratch**, scaffold your project first:

```bash
# Choose your framework:

# React + Vite
npm create vite@latest my-app -- --template react-ts
cd my-app

# Next.js
npx create-next-app@latest my-app
cd my-app

# Astro
npm create astro@latest my-app
cd my-app

# Vue
npm create vue@latest my-app
cd my-app

# Then initialize git
git init
git add .
git commit -m "Initial project scaffold"
```

**For existing projects**, just ensure you have a git repository:

```bash
# If not already initialized
git init
git add .
git commit -m "Initial commit"
```

✅ **Now you're ready to use SpecSwarm!**

---

### Step 1: Initialize Claude Code

```bash
/init
```

**What it does**: Creates `.claude/` directory and project configuration

### Step 2: Install SpecSwarm Marketplace

```bash
# Install marketplace
/plugin https://github.com/MartyBonacci/specswarm

# Install plugins
/plugin install specswarm
/plugin install speclabs
```

**Verify installation**:
```bash
/plugin list
```
You should see specswarm v2.1.2 and speclabs v2.7.3

### Step 3: Create Tech Stack Definition

**Why**: Prevents 95% of technology drift across features

Create `/memory/tech-stack.md`:

```markdown
# Tech Stack v1.0.0

## Core Technologies

### Frontend
- React 19.x (functional components only)
- React Router v7.9+ (framework mode with loaders/actions)
- TypeScript 5.x (strict mode)

### Backend
- Node.js 20.x LTS
- PostgreSQL 17.x

### Build & Dev Tools
- Vite 5.x
- Vitest (testing)

## Approved Libraries

### State Management
- React Router v7 loaders/actions (preferred)
- Zustand (if client-side state needed)

### Validation
- Zod v4+ (runtime validation with TypeScript inference)

### Styling
- Tailwind CSS v4+ (Oxide engine)

### Database
- Drizzle ORM (TypeScript-native ORM)

## Prohibited Technologies

❌ **Redux** - Use React Router loaders/actions instead
❌ **Class Components** - Use functional components with hooks
❌ **PropTypes** - Use TypeScript
❌ **CSS-in-JS** - Use Tailwind CSS
❌ **Moment.js** - Use native Date APIs or date-fns

## Version Bump Rules

- MAJOR (1.0.0 → 2.0.0): Replacing existing approved technology
- MINOR (1.0.0 → 1.1.0): Adding new approved technology
- PATCH (1.0.0 → 1.0.1): Updating versions of existing technologies
```

**SpecSwarm will enforce this** during planning phases!

### Step 4: Set Quality Standards

**Why**: Maintains code quality automatically

Create `/memory/quality-standards.md`:

```yaml
# Quality Gates

## Test Coverage
min_test_coverage: 80
min_unit_coverage: 75
min_integration_coverage: 70

## Quality Scores
min_quality_score: 85
block_merge_on_failure: false

## Performance Budgets
enforce_budgets: true
max_bundle_size: 500      # KB per bundle
max_initial_load: 1000    # KB initial load
max_route_bundle: 200     # KB per route chunk

## Code Quality
max_complexity: 10
max_file_lines: 300
enforce_typescript: true
```

**SpecSwarm uses these** for /analyze-quality scoring!

### Step 5: Establish Project Governance

```bash
/specswarm:constitution
```

**What it does**:
- Creates project principles and coding standards
- Documents architectural decisions
- Establishes team agreements

**Interactive prompts**:
- What are your core principles?
- What coding standards should be enforced?
- What architectural patterns are preferred?

**Result**: Creates `/memory/constitution.md`

### Step 6: Verify Setup

```bash
# Check all configuration files exist
ls -la /memory/

# You should see:
# - tech-stack.md
# - quality-standards.md
# - constitution.md
```

✅ **Setup Complete!** You're ready to build features.

---

## Feature Development Workflows

### Choosing the Right Workflow

**Use this decision tree**:

```
Start
  ↓
Can you describe the feature clearly in 2-3 sentences?
  ├─ NO  → Use SpecSwarm Manual (use /clarify to refine)
  ↓
  YES
  ↓
Is it production-critical with zero error tolerance?
  ├─ YES → Use SpecSwarm Manual
  ↓
  NO
  ↓
Use SpecLabs Autonomous ✨
```

**Or use AI recommendation**:
```bash
/specswarm:suggest "your feature idea"
```

### Workflow A: Autonomous (SpecLabs - Faster)

**Best for**: Straightforward features, CRUD operations, UI components

**Complete workflow**:

```bash
# 1. Ensure correct parent branch
git status
git checkout develop  # or sprint-X

# 2. Draft prompt in plan mode (recommended)
# In Claude Code plan mode:
"Help me write a /speclabs:orchestrate-feature prompt for adding
user authentication with email/password login"

# Refine until prompt is clear, then exit plan mode

# 3. Execute autonomous orchestration
/speclabs:orchestrate-feature "Add user authentication with email/password login, JWT tokens, protected routes, login/signup forms with Zod validation, and password strength requirements" --validate

# 4. Respond to planning questions (SpecSwarm phases)
# - Answer clarification questions
# - Confirm tech stack decisions
# - Review generated plan

# 5. Let it run autonomously
# SpecLabs will:
# - Generate spec.md, plan.md, tasks.md
# - Implement all tasks
# - Run Playwright validation (if --validate)
# - Report bugs found
# - Give completion report

# 6. Review the results
# Check:
# - What was implemented?
# - What bugs were found?
# - What tests were run?

# 7. Manual testing (CRITICAL!)
npm run dev
# Test the feature yourself:
# - Happy paths
# - Edge cases
# - Error states
# - Mobile/desktop

# 8. Fix any bugs found
/specswarm:bugfix "Bug 001: Login fails when password contains special characters

Console errors:
TypeError: Cannot read property 'validate' of undefined
  at LoginForm.jsx:45

Terminal errors:
None

Expected: Passwords like 'p@ssw0rd!' should work
Actual: Form submission fails silently

Steps to reproduce:
1. Go to /login
2. Enter email: test@example.com
3. Enter password: p@ssw0rd!
4. Click Submit
5. Nothing happens, console shows error"

# 9. Check quality before merge
/specswarm:analyze-quality

# Should show score >85

# 10. Complete and merge
/specswarm:complete

# Shows merge plan, asks for confirmation
```

### Workflow B: Manual Control (SpecSwarm - More Control)

**Best for**: Complex changes, production-critical work, learning codebase

**Complete workflow**:

```bash
# 1. Ensure correct parent branch
git checkout develop

# 2. Get workflow recommendation
/specswarm:suggest "migrate from Redux to React Router v7 loaders"

# 3. Create specification
/specswarm:specify "Migrate from Redux Toolkit to React Router v7 data loading patterns. Replace all Redux slices and sagas with route loaders and actions. Maintain exact same functionality and user experience."

# 4. Clarify requirements (if needed)
/specswarm:clarify

# SpecSwarm asks targeted questions like:
# - Which routes currently use Redux?
# - Are there any complex saga patterns?
# - What's the error handling strategy?

# 5. Generate implementation plan
/specswarm:plan

# Creates plan.md with:
# - Architecture decisions
# - File changes needed
# - Risk assessment
# - Testing strategy

# Review plan.md before proceeding!

# 6. Generate task breakdown
/specswarm:tasks

# Creates tasks.md with dependency-ordered tasks

# Review tasks.md - make sure it makes sense!

# 7. Execute implementation
/specswarm:implement

# Executes all tasks sequentially
# - Shows progress
# - Reports completion
# - Highlights any failures

# 8. Manual testing
npm run dev
# Test thoroughly!

# 9. Fix bugs
/specswarm:bugfix "Bug 002: ..."

# 10. Quality check
/specswarm:analyze-quality

# 11. Complete and merge
/specswarm:complete
```

---

## Testing and Quality

### Manual Testing Checklist

Always test manually, even with `--validate` flag!

**Frontend Features**:
- [ ] Feature works in Chrome, Firefox, Safari
- [ ] Mobile responsive (test on actual device or DevTools)
- [ ] Keyboard navigation works
- [ ] Screen reader accessible (basic check)
- [ ] Forms validate correctly
- [ ] Error messages are helpful
- [ ] Loading states work
- [ ] Happy path works
- [ ] Edge cases handled (empty states, long text, special characters)

**Backend/API Features**:
- [ ] All HTTP methods work (GET, POST, PUT, DELETE)
- [ ] Authentication/authorization works
- [ ] Input validation works
- [ ] Error responses are correct (400, 401, 403, 404, 500)
- [ ] Database transactions work
- [ ] Performance is acceptable (check query counts)

### Using `/specswarm:bugfix` Effectively

**Good bug report format**:

```bash
/specswarm:bugfix "Bug 003: Shopping cart quantity update fails

**Description**: When user changes quantity in cart, the total doesn't update

**Console Errors**:
Warning: Cannot update a component while rendering a different component
  at CartItem.jsx:127

**Terminal Errors**:
None

**Expected Behavior**:
1. User changes quantity from 1 to 3
2. Item subtotal updates (e.g., $29.99 → $89.97)
3. Cart total updates
4. Database reflects new quantity

**Actual Behavior**:
1. User changes quantity from 1 to 3
2. UI doesn't update
3. Console shows warning
4. Refresh page shows old quantity

**Steps to Reproduce**:
1. Add item to cart
2. Go to /cart
3. Change quantity dropdown from 1 to 3
4. Observe no visual change

**Environment**:
- Browser: Chrome 120
- OS: macOS Sonoma
- User logged in: Yes
- Item ID: 12345"
```

**Why this format works**:
- SpecSwarm creates targeted regression tests
- Easier to reproduce and fix
- Creates better documentation

### Interpreting `/specswarm:analyze-quality` Results

```bash
/specswarm:analyze-quality
```

**Sample output**:
```
Quality Score: 87/100

Breakdown:
✅ Unit Tests: 22/25 pts (88% passing, 89% coverage)
✅ Integration Tests: 14/15 pts (all passing)
✅ Code Coverage: 23/25 pts (92% overall)
⚠️ Bundle Size: 16/20 pts (582 KB - exceeds 500 KB budget)
✅ Browser Tests: 12/15 pts (4/5 E2E tests passing)

Recommendations:
1. Fix failing E2E test: "checkout flow times out"
2. Reduce bundle size by 82 KB (try code splitting)
3. Add tests for error handlers (coverage gap)
```

**What the scores mean**:
- **90-100**: Excellent - ship with confidence
- **80-89**: Good - minor issues to address
- **70-79**: Fair - review before merging
- **Below 70**: Needs work - fix issues before merge

---

## Completion and Merge

### The `/specswarm:complete` Command

```bash
/specswarm:complete
```

**What happens** (v2.1.2+):

1. **Cleanup Phase**:
   - Scans for diagnostic files (check-*.js, debug-*.ts, etc.)
   - Offers to delete or move to .claude/debug/

2. **Pre-Merge Validation**:
   - Runs tests (if test script exists)
   - Checks TypeScript (if tsconfig.json exists)
   - Runs build (if build script exists)
   - Shows completion progress

3. **Branch Detection** (our v2.1.2 fix!):
   ```
   Determining parent branch...
     Stored parent branch: sprint-3
   ✓ Using parent branch from spec.md: sprint-3
   ```

4. **Merge Plan Display** (NEW in v2.1.2):
   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Merge Plan
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     Source branch: 015-add-testing-infrastructure
     Target branch: sprint-3
     Source: spec.md parent_branch field

   ℹ️  Note: Merging into 'sprint-3' (not main)
      This is an intermediate merge in a feature branch hierarchy.

   ⚠️  IMPORTANT: This will merge your changes to sprint-3.
       Make sure you've tested the feature thoroughly.
       If the target branch looks wrong, press 'n' and check spec.md

   Proceed with merge? (y/n):
   ```

5. **Merge Execution**:
   - Checks out parent branch
   - Pulls latest changes
   - Merges with --no-ff (creates merge commit)
   - Creates completion tag
   - Offers to push to remote

6. **Branch Cleanup**:
   - Offers to delete feature branch
   - Offers to delete remote branch

**Best practices**:
- ✅ Always run `/specswarm:analyze-quality` first
- ✅ Review the merge plan carefully
- ✅ Push to remote if working in a team
- ✅ Keep feature branches for a while (easy rollback)

---

## Real-World Examples

### Example 1: Simple Feature (Autonomous)

**Task**: Add a contact form to the website

```bash
# On develop branch
git checkout develop

# Get recommendation
/specswarm:suggest "add contact form with name, email, message fields"
# → Recommends: SpecLabs autonomous

# Execute
/speclabs:orchestrate-feature "Add contact form page with name (text), email (validated), message (textarea) fields, submit button with loading state, success/error messages, and email sending via SendGrid API" --validate

# Respond to questions during planning

# Manual test after completion
npm run dev
# Test: valid submission, invalid email, empty fields, loading state

# No bugs found! 🎉

# Quality check
/specswarm:analyze-quality
# Score: 91/100 ✅

# Complete and merge
/specswarm:complete
```

**Time**: ~45 minutes (vs 2 hours manual)

### Example 2: Complex Feature (Manual Control)

**Task**: Migrate authentication from Firebase to custom JWT system

```bash
# On develop branch
git checkout develop

# This is complex, use manual workflow
/specswarm:specify "Migrate authentication from Firebase to custom JWT-based system. Replace all Firebase auth calls with custom JWT API. Maintain same user experience. Support refresh tokens, password reset, and email verification."

# Clarify requirements
/specswarm:clarify
# Answer ~5 questions about implementation details

# Review plan
/specswarm:plan
cat features/016-*/plan.md
# Review carefully - this is complex!

# Generate tasks
/specswarm:tasks
cat features/016-*/tasks.md
# 45 tasks identified

# Implement
/specswarm:implement

# Test thoroughly (auth is critical!)
npm run dev
# Test all auth flows

# Found 3 bugs during testing

# Fix Bug 1
/specswarm:bugfix "Bug: Refresh token expires too quickly..."

# Fix Bug 2
/specswarm:bugfix "Bug: Password reset email not sending..."

# Fix Bug 3
/specswarm:bugfix "Bug: Email verification link invalid..."

# Quality check
/specswarm:analyze-quality
# Score: 88/100 ✅

# Complete
/specswarm:complete
```

**Time**: ~2 days (vs 3-4 days manual + potential security issues)

### Example 3: Bug Fix Workflow

**Task**: Fix production bug where cart totals are wrong

```bash
# On develop branch
git checkout develop

# Use bugfix workflow (creates regression test!)
/specswarm:bugfix "Bug: Cart total calculation incorrect when discount codes applied

**Console Errors**:
None

**Terminal Errors**:
None

**Expected**:
Item: $100
Discount (20%): -$20
Subtotal: $80
Tax (10%): $8
Total: $88

**Actual**:
Total: $90 (tax calculated before discount)

**Steps to Reproduce**:
1. Add $100 item to cart
2. Apply discount code '20OFF'
3. Proceed to checkout
4. Observe total is $90 instead of $88

**Root Cause** (if known):
Tax calculation happens before discount is applied
File: src/utils/cart.js:calculateTotal()
Line: 45"

# SpecSwarm:
# 1. Creates regression test
# 2. Fixes the bug
# 3. Runs test to verify fix
# 4. Updates documentation

# Test manually
npm run dev
# Verify fix works

# Complete
/specswarm:complete
```

**Time**: ~30 minutes (includes regression test!)

---

## Troubleshooting

### Common Issues

#### Issue: "Tech stack conflict detected"

**Symptom**: SpecSwarm blocks implementation due to tech stack violation

**Solution**:
```bash
# Option 1: Update tech-stack.md if the new tech is approved
# Edit /memory/tech-stack.md
# Add the new technology
# Bump version number

# Option 2: Use approved alternative
# Follow SpecSwarm's recommendation
# Use the approved technology instead
```

#### Issue: "Parent branch detection failed"

**Symptom**: /complete wants to merge to wrong branch

**Solution**:
```bash
# Check spec.md
cat features/015-*/spec.md | grep parent_branch

# If wrong, you can:
# 1. Cancel the merge (press 'n')
# 2. Manually edit spec.md frontmatter
# 3. Run /specswarm:complete again

# Or merge manually:
git checkout correct-parent-branch
git merge --no-ff 015-feature-branch
```

#### Issue: "Quality score too low"

**Symptom**: /analyze-quality shows score <70

**Solution**:
```bash
# Check what's failing
/specswarm:analyze-quality

# Common fixes:
# - Add missing tests (unit, integration)
# - Fix failing tests
# - Reduce bundle size (code splitting)
# - Fix TypeScript errors
# - Add error handling

# Then re-check
/specswarm:analyze-quality
```

#### Issue: "Orchestrate-feature pauses mid-execution"

**Symptom**: SpecLabs stops and waits for input

**Solution**:
```bash
# Make sure you're on v2.7.3+
/plugin list

# If not, update:
/plugin update speclabs

# v2.7.3 eliminated all mid-phase pausing
```

### Getting Help

**In Claude Code**:
```bash
/help
```

**Documentation**:
- [README.md](../README.md) - Overview and quick start
- [CHEATSHEET.md](./CHEATSHEET.md) - Quick reference
- [SpecSwarm README](../plugins/specswarm/README.md) - Detailed command docs
- [SpecLabs README](../plugins/speclabs/README.md) - Autonomous features

**GitHub**:
- Report issues: https://github.com/MartyBonacci/specswarm/issues
- View changelog: https://github.com/MartyBonacci/specswarm/blob/main/CHANGELOG.md

---

## Summary

**One-Time Setup**:
1. /init
2. Install plugins
3. Create tech-stack.md
4. Create quality-standards.md
5. Run /specswarm:constitution

**Per Feature (Autonomous)**:
1. git checkout develop
2. /specswarm:suggest "feature"
3. /speclabs:orchestrate-feature "detailed description" --validate
4. Manual testing
5. /specswarm:bugfix (if needed)
6. /specswarm:analyze-quality
7. /specswarm:complete

**Per Feature (Manual)**:
1. git checkout develop
2. /specswarm:specify → clarify → plan → tasks → implement
3. Manual testing
4. /specswarm:bugfix (if needed)
5. /specswarm:analyze-quality
6. /specswarm:complete

**Happy coding!** 🚀
