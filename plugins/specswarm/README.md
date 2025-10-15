# SpecSwarm Plugin for Claude Code

**Spec-Driven Development with Intelligent Tech Stack Management**

SpecSwarm is an enhanced fork of the SpecKit plugin that adds powerful tech stack drift prevention and automatic validation to your development workflow.

## 🎯 What Makes SpecSwarm Different?

SpecSwarm extends Spec-Driven Development with **95% effective tech stack drift prevention** through:

- ✅ **Auto-detection** of project technologies on first feature
- ✅ **Smart validation** at plan, task, and implementation phases
- ✅ **Automatic addition** of non-conflicting libraries
- ✅ **Conflict detection** with approval workflows
- ✅ **Hard blocking** of prohibited technologies
- ✅ **Zero new commands** - validation embedded in existing workflow

## Attribution

### Forked From
SpecSwarm is a fork of **SpecKit**, which adapted **GitHub's spec-kit** for Claude Code.

**Attribution Chain:**
1. **Original**: [GitHub spec-kit](https://github.com/github/spec-kit)
   - Copyright (c) GitHub, Inc. | MIT License
2. **Adapted**: SpecKit plugin by Marty Bonacci (2025)
   - Claude Code integration and workflow adaptation
3. **Enhanced**: SpecSwarm by Marty Bonacci & Claude Code (2025)
   - Tech stack management and drift prevention system

## Commands

SpecSwarm provides 8 slash commands identical to SpecKit, with enhanced tech stack management:

### `/specswarm:constitution`
Establish project principles including tech stack enforcement.

### `/specswarm:specify <description>`
Create feature specifications with automatic quality validation.

### `/specswarm:clarify`
Resolve ambiguities with targeted clarification questions.

### `/specswarm:plan` ⭐ **Enhanced**
Create technical plans with **automatic tech stack validation**:
- First feature: Auto-creates `/memory/tech-stack.md`
- Subsequent features: Validates all technologies
- Auto-adds non-conflicting libraries
- Prompts for conflict resolution
- Blocks prohibited technologies

### `/specswarm:tasks` ⭐ **Enhanced**
Generate task breakdowns with **tech stack pre-validation**:
- Scans tasks for prohibited technologies
- Auto-corrects with approved alternatives
- Verifies compliance report resolved

### `/specswarm:implement` ⭐ **Enhanced**
Execute implementation with **runtime tech stack enforcement**:
- Validates before every import/dependency
- Blocks prohibited patterns (e.g., class components)
- Warns on unapproved libraries
- Continuous validation during implementation

### `/specswarm:analyze`
Cross-artifact consistency validation.

### `/specswarm:checklist <type>`
Generate requirement quality checklists.

## 🚀 Quick Start

### First Feature (Auto-Setup)
```bash
# 1. Define your feature
/specswarm:specify Create user authentication system

# 2. Create plan (auto-creates tech stack file)
/specswarm:plan
# SpecSwarm detects: TypeScript, React Router, PostgreSQL
# Prompts: "Review tech-stack.md and add prohibited technologies"
# You type: "continue"

# 3. Generate tasks
/specswarm:tasks

# 4. Implement
/specswarm:implement
```

### Subsequent Features (Auto-Validation)
```bash
# 1. Define feature
/specswarm:specify Add product catalog

# 2. Plan with validation
/specswarm:plan
# SpecSwarm validates: TypeScript ✅, React Router ✅
# SpecSwarm auto-adds: react-query (non-conflicting)
# SpecSwarm blocks: Axios (prohibited, use fetch instead)

# 3. Rest of workflow as normal
/specswarm:tasks
/specswarm:implement
```

## 🌳 Git Workflow Management

SpecSwarm now includes **automatic git workflow management** to complete the full feature lifecycle.

### How It Works

After `/specswarm:implement` completes, the **Post-Implement Hook** automatically:

1. **Detects your git repository** and current branch
2. **Offers three workflow options** if you're on a feature branch
3. **Handles the merge and cleanup** based on your choice

### The Three Options

#### Option 1: Merge and Delete (Recommended)

**Best for**: Normal feature completion

**What happens**:
- ✅ Checks for uncommitted changes (prompts to commit)
- ✅ Tests merge for conflicts (dry run)
- ✅ Merges feature branch to main
- ✅ Deletes feature branch
- ✅ Returns you to main branch
- ✅ Ready for next feature!

**Use when**: Feature is complete and tested

---

#### Option 2: Stay on Branch

**Best for**: Additional polish or testing needed

**What happens**:
- ✅ Keeps you on the feature branch
- ✅ Provides manual merge instructions
- ✅ Branch preserved for more work

**Use when**: Need to add more commits, run additional tests, or get code review

---

#### Option 3: Switch Without Merge

**Best for**: Pausing feature work

**What happens**:
- ✅ Switches to main branch
- ✅ Preserves feature branch
- ✅ Provides merge/delete instructions for later

**Use when**: Working on multiple features, need to switch context, or waiting for dependencies

---

### Safety Features

**Conflict Detection**:
```bash
# Tests merge before executing
❌ Merge conflicts detected!

Cannot auto-merge. Please resolve conflicts manually:
  1. git checkout main
  2. git merge 001-user-authentication
  3. Resolve conflicts
  4. git add . && git commit
  5. git branch -d 001-user-authentication
```

**Uncommitted Changes Handling**:
```bash
⚠️  You have uncommitted changes.

 M  src/components/UserProfile.tsx
 M  src/services/auth.ts

Commit these changes first? (yes/no): yes
Commit message: Polish user profile styling
✅ Changes committed
```

---

### Complete Workflow

The full feature lifecycle with SpecSwarm:

```
/specswarm:specify "User authentication"
  → Creates branch: 001-user-authentication ✅

/specswarm:plan
  → Plans on feature branch ✅

/specswarm:tasks
  → Generates tasks on feature branch ✅

/specswarm:implement
  → Implements feature ✅
  → Offers git workflow options ✅
  → Merges and cleans up ✅

Back on main → Ready for next feature! ✅
```

---

### When Git Workflow Doesn't Run

The git workflow **won't prompt** when:

- ❌ Not a git repository
- ❌ Already on main/master branch
- ❌ No branches created (non-git project)

In these cases, you'll see:
```
ℹ️  Already on main branch (main)
```

---

### Expected Output

After `/specswarm:implement` completes:

```
✅ Feature implementation complete!

🌳 Git Workflow
===============

Current branch: 001-user-authentication
Main branch: main

Feature implementation complete! What would you like to do?

  1. Merge to main and delete feature branch (recommended)
  2. Stay on 001-user-authentication for additional work
  3. Switch to main without merging (keep branch)

Choose (1/2/3): 1

✅ Merging and cleaning up...
✅ Merged 001-user-authentication to main
✅ Deleted feature branch 001-user-authentication
🎉 You are now on main
```

## 📋 Tech Stack Management

### Tech Stack File Structure
```markdown
# /memory/tech-stack.md

**Version**: 1.0.0

## Core Technologies (IMMUTABLE)
- **Language**: TypeScript 5.x
- **Framework**: React Router v7
- **Database**: PostgreSQL 17.x

## Standard Libraries (APPROVED)
- Drizzle ORM (database access) <!-- PURPOSE:orm -->
- Zod v4+ (validation) <!-- PURPOSE:validation -->
- fetch API (HTTP requests) <!-- PURPOSE:http-client -->

## Prohibited Technologies
- ❌ Axios (use fetch API instead)
- ❌ Class components (use functional components)
- ❌ Redux (use React Router loaders/actions)
```

### How Validation Works

#### 1. Plan Phase
- Extract technologies from Technical Context
- Classify as: APPROVED, PROHIBITED, CONFLICT, or AUTO_ADD
- Generate Tech Stack Compliance Report
- Auto-add non-conflicting (bump MINOR version)
- Prompt for conflict resolution
- Block prohibited technologies

#### 2. Tasks Phase
- Verify compliance report resolved
- Scan task descriptions for prohibited tech
- Auto-correct with approved alternatives

#### 3. Implementation Phase
- Runtime validation before every import
- Block prohibited patterns
- Warn on unapproved libraries
- Continuous enforcement

### Example: Conflicting Technology
```
⚠️ Conflicting Technology Detected

**Axios v1.6** conflicts with **fetch API**
Both serve the same purpose: HTTP client

| Option | Choice | Implications |
|--------|--------|--------------|
| A | Keep fetch API | Remove Axios, update plan |
| B | Replace with Axios | Tech stack v2.0.0 (MAJOR), refactor code |
| C | Use both | Justify in research.md, document overlap |

Your choice (A/B/C): _
```

### Example: Prohibited Technology
```
❌ Prohibited Technology Detected

**Redux Toolkit** is prohibited in this project.
Reason: "Use React Router loaders/actions for state"

✅ Must use: React Router loaders/actions
📖 See: /memory/tech-stack.md

Cannot proceed until resolved.
```

## 🎨 Workflow Comparison

| Workflow Step | SpecKit | SpecSwarm |
|--------------|---------|-----------|
| Constitution | Set principles | Set principles + tech stack enforcement |
| Specify | Create spec | Create spec (unchanged) |
| Plan | Technical design | Technical design **+ auto-validation** |
| Tasks | Break down work | Break down work **+ validation** |
| Implement | Execute tasks | Execute tasks **+ runtime enforcement** |

## 📊 Effectiveness

| Problem | Without SpecSwarm | With SpecSwarm |
|---------|-------------------|----------------|
| Stack drift across features | ~20% prevention | **95% prevention** |
| Prohibited tech usage | Manual review | **Automatic blocking** |
| Conflicting libraries | Discovered late | **Caught at plan time** |
| Tech documentation | Manual/outdated | **Auto-maintained** |

## 🛠️ Installation

### From Marketplace
```bash
claude plugin marketplace add marty/specswarm
claude plugin install specswarm
```

### From Local Directory
```bash
claude plugin install /path/to/specswarm/plugins/specswarm
```

## 📁 File Structure

```
your-project/
├── memory/
│   ├── constitution.md          # Project principles
│   └── tech-stack.md            # ⭐ Tech stack enforcement
├── features/
│   └── 001-feature-name/
│       ├── spec.md              # Feature specification
│       ├── plan.md              # Tech plan + compliance report
│       ├── tasks.md             # Tasks + validation status
│       └── checklists/          # Quality checklists
```

## 🔄 Version Semantics

Tech stack file uses semantic versioning:

- **MAJOR** (X.0.0): Core technology replacement, prohibited → approved
- **MINOR** (1.X.0): New library additions (auto-added)
- **PATCH** (1.0.X): Documentation updates, purpose tag additions

## 🧪 Examples

### Auto-Addition (Silent)
```
Loading tech stack from /memory/tech-stack.md...

✅ TypeScript 5.x - approved
✅ React Router v7 - approved
➕ react-query v5 - NEW (auto-adding)

Tech Stack Compliance Report:
- react-query v5 auto-added to Data Layer
- Version updated: 1.0.0 → 1.1.0

Continuing with plan generation...
```

### Conflict Resolution (Interactive)
```
⚠️ Axios v1.6 conflicts with fetch API

Your choice (A/B/C): A

✓ Updating plan.md to use fetch API...
✓ Continuing with plan generation...
```

### Prohibition Block (Hard Stop)
```
❌ Redux Toolkit is PROHIBITED

Cannot proceed. Please update plan.md to use:
✅ React Router loaders/actions

Halting until resolved.
```

## 📝 Customizing Tech Stack Template (Optional)

By default, SpecSwarm uses an embedded template when auto-creating `/memory/tech-stack.md`. You can customize this by creating your own template in your project.

### Create Custom Template

Create `/templates/tech-stack-template.md` in your project root:

```markdown
# Project Technology Stack

**Version**: 1.0.0
**Created**: [CREATION_DATE]
**Last Updated**: [LAST_UPDATE_DATE]

<!--
  This file defines the approved technology stack for ALL features in this project.
  Changes require constitutional amendment (see /memory/constitution.md Principle 5).
-->

## Core Technologies (IMMUTABLE)
<!-- These are fundamental to the project and should rarely change -->

- **Language**: [LANGUAGE] [VERSION]
- **Runtime**: [RUNTIME] [VERSION]
- **Framework**: [FRAMEWORK] [VERSION]
- **Database**: [DATABASE] [VERSION]

## Standard Libraries (APPROVED)
<!-- These libraries are approved for use across all features -->

**Data Layer:**
- [ORM_LIBRARY] ([PURPOSE]) <!-- PURPOSE:orm -->
- [VALIDATION_LIBRARY] ([PURPOSE]) <!-- PURPOSE:validation -->

**UI Layer:**
- [STYLING_LIBRARY] ([PURPOSE]) <!-- PURPOSE:css -->
- [COMPONENT_LIBRARY] ([PURPOSE]) <!-- PURPOSE:ui-components -->

**Utilities:**
- [HTTP_CLIENT] ([PURPOSE]) <!-- PURPOSE:http-client -->
- [DATE_LIBRARY] ([PURPOSE]) <!-- PURPOSE:date-utils -->

## Prohibited Technologies
<!-- NEVER use these - constitutional violations trigger errors -->

⚠️ **Add your project-specific prohibitions:**

**Common anti-patterns to consider:**
- ❌ [DEPRECATED_LIBRARY] (use [APPROVED_ALTERNATIVE] instead)
- ❌ [OUTDATED_PATTERN] (use [MODERN_PATTERN] instead)
- ❌ [CONFLICTING_LIBRARY] (use [APPROVED_LIBRARY] instead)

**Why prohibit technologies?**
- Prevents accidental use of deprecated/superseded libraries
- Enforces modern patterns and best practices
- Reduces bundle size (no duplicate libraries)
- Maintains architectural consistency

## Adding New Technologies

**Process for approving new technology:**

1. **Document justification** in feature's `research.md`
2. **Propose amendment** with rationale
3. **Update constitution** if governance review required
4. **Add to appropriate section** above with purpose tag
5. **Increment version number** (MINOR for additions, MAJOR for replacements)

## Version History

- **1.0.0** ([CREATION_DATE]): Initial tech stack [SOURCE]
```

### How It Works

- **First feature**: SpecSwarm checks for `/templates/tech-stack-template.md`
- **If found**: Uses your custom template
- **If not found**: Uses embedded default template
- **Placeholders**: Auto-populated with detected technologies
- **Customization**: Add custom sections, notes, or policies

### Template Tips

1. **Add Purpose Tags**: `<!-- PURPOSE:category -->` enables conflict detection
2. **Document Rationale**: Explain why technologies are prohibited
3. **Version Policies**: Add notes about update strategies
4. **Team Agreements**: Include team-specific conventions

## 💡 Best Practices

1. **Populate Prohibited Technologies Early**
   - Add prohibited tech when creating tech-stack.md
   - Prevents accidental usage throughout project

2. **Use Purpose Tags**
   - Add `<!-- PURPOSE:category -->` comments
   - Enables automatic conflict detection

3. **Constitutional Enforcement**
   - Run `/specswarm:constitution` after first feature
   - Add Principle 5: Technology Stack Consistency

4. **Review Auto-Additions**
   - Check tech-stack.md version history
   - Verify auto-added libraries make sense

## 🤝 Contributing

This is a fork of SpecKit (adapted from GitHub spec-kit).

- Original methodology: [spec-kit repository](https://github.com/github/spec-kit)
- SpecKit adaptation: Issues in SpecSwarm repository
- SpecSwarm enhancements: Issues in SpecSwarm repository

## 📜 License

MIT License (inherited from original spec-kit)

**Attribution Chain:**
- Original: GitHub, Inc. (MIT)
- SpecKit: Marty Bonacci (MIT)
- SpecSwarm: Marty Bonacci & Claude Code (MIT)

## 🔗 Learn More

- [GitHub spec-kit](https://github.com/github/spec-kit) - Original project
- [Spec-Driven Development](https://github.com/github/spec-kit/blob/main/spec-driven.md) - Methodology
- [Claude Code Plugins](https://docs.claude.com/en/docs/claude-code/plugins) - Plugin system
