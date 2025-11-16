# ⛔ SpecLabs - DEPRECATED

## 🚨 THIS PLUGIN IS DEPRECATED AND WILL BE REMOVED IN v3.3.0

**All SpecLabs functionality has been consolidated into SpecSwarm v3.0+**

### ⚠️ IMMEDIATE ACTION REQUIRED

1. **Uninstall SpecLabs**: `/plugin uninstall speclabs`
2. **Use SpecSwarm instead**: All commands available as `/specswarm:orchestrate-feature`, etc.
3. **Update scripts**: Replace `/speclabs:*` with `/specswarm:*`

### Why This Change?

- ✅ **Unified Plugin**: All features now in SpecSwarm (easier installation)
- ✅ **Better Maintenance**: Single codebase, faster bug fixes
- ✅ **No Feature Loss**: All SpecLabs commands work in SpecSwarm
- ✅ **Multi-Language Support**: SpecSwarm v3.2 adds Python, PHP, Go, Ruby, Rust

### Deprecation Timeline

- **v3.0.0** (Nov 2025): SpecLabs consolidated into SpecSwarm
- **v3.2.0** (Jan 2025): SpecLabs marked as deprecated ← **YOU ARE HERE**
- **v3.3.0** (Planned): SpecLabs plugin removed from marketplace

### Migration Guide

All SpecLabs commands are available in SpecSwarm with the same names:

| Old SpecLabs Command | New SpecSwarm Command |
|---------------------|----------------------|
| `/speclabs:orchestrate-feature` | `/specswarm:orchestrate-feature` |
| `/speclabs:orchestrate` | `/specswarm:orchestrate` |
| `/speclabs:validate-feature` | `/specswarm:validate` |
| `/speclabs:coordinate` | `/specswarm:coordinate` |
| `/speclabs:metrics` | `/specswarm:metrics` |

**Simply replace `/speclabs:` with `/specswarm:` in all your workflows!**

---

## Historical Documentation Below (v2.7.3)

⚠️ **DO NOT USE** - For reference only

---

## Overview

SpecLabs is the experimental wing of SpecSwarm, focused on **autonomous feature orchestration** and **multi-agent coordination**. The ultimate vision: natural language feature descriptions → working, tested, production-ready code with minimal human intervention.

**Vision**: "Describe a feature Monday evening, wake up Tuesday morning with working, tested code."

**Current Status**: v2.7.3 - Silent autonomous execution with multi-type validation

---

## Quick Start

### Autonomous Feature Development

```bash
# Complete feature lifecycle in one command
/speclabs:orchestrate-feature "Add user authentication with email/password" --validate

# Automatically executes:
# ✅ SpecSwarm planning (specify → clarify → plan → tasks)
# ✅ Implementation with intelligent retry (up to 3 attempts)
# ✅ Browser validation with Playwright
# ✅ Auto-fix if errors detected
# ✅ Complete with comprehensive report
```

### Standalone Validation

```bash
# Validate after implementation (auto-detects project type)
/speclabs:validate-feature /path/to/project

# Supports: Webapp, Android (planned), REST API (planned), Desktop (planned)
```

### Advanced Debugging

```bash
# Systematic multi-bug investigation
/speclabs:coordinate "navbar broken, sign-out fails, like button blank page"

# Coordinates:
# ✅ Systematic bug analysis
# ✅ Logging strategy design
# ✅ Orchestrated investigation
# ✅ Comprehensive debugging report
```

---

## When to Use SpecLabs vs SpecSwarm

### Use SpecLabs (Autonomous) When:

✅ **Feature is well-defined** - You can describe it clearly in 2-3 sentences
✅ **Straightforward implementation** - No complex architectural decisions needed
✅ **Speed is priority** - 50-67% faster than manual workflow
✅ **You're comfortable with experimental** - Can handle occasional unexpected results
✅ **Want browser validation** - Playwright testing included with `--validate`

**Best For**: Standard CRUD operations, UI components, API endpoints, form validation, data transformations

### Use SpecSwarm (Manual) When:

✅ **Complex architectural changes** - Framework upgrades, major refactoring
✅ **Production-critical work** - Zero tolerance for mistakes
✅ **Learning the codebase** - Step-by-step gives you control and understanding
✅ **Unclear requirements** - Need to refine specs through clarify workflow
✅ **Multi-stakeholder approval** - Need to review plans before implementation

**Best For**: Database migrations, auth system changes, performance optimization, security fixes

### Decision Tree

```
Start → Can you describe feature in 2-3 sentences?
  ├─ Yes → Is it production-critical with zero error tolerance?
  │   ├─ Yes → Use SpecSwarm (manual)
  │   └─ No  → Use SpecLabs (autonomous) ✨
  └─ No  → Use SpecSwarm (manual) - use /clarify to refine
```

### Hybrid Approach (Recommended)

1. Use **SpecSwarm /suggest** to get recommendation
2. Use **SpecLabs orchestrate-feature** for initial implementation
3. Use **SpecSwarm /bugfix** for fixing issues (creates regression tests)
4. Use **SpecSwarm /analyze-quality** before merge

---

## Getting Started with SpecLabs

### Prerequisites

Before using SpecLabs, ensure you have:
1. ✅ Created `.specswarm/tech-stack.md` (SpecLabs enforces this during planning)
2. ✅ Set up project with `/init`
3. ✅ On correct parent branch (e.g., `develop` or `sprint-X`)

### Your First Autonomous Feature

**Step 1: Draft Your Prompt (Use Plan Mode)**
```
Based on SpecSwarm/SpecLabs plugins, help me write a
/speclabs:orchestrate-feature prompt for adding user login with email/password.
```
Refine in plan mode until prompt is clear and detailed.

**Step 2: Execute Autonomous Orchestration**
```bash
/speclabs:orchestrate-feature "Add user login with email/password, JWT authentication, protected routes, and login/signup forms with validation" --validate
```

**Step 3: Respond to Planning Questions**
- SpecLabs will ask clarification questions during planning
- Answer these to refine the specification
- Let it run autonomously after planning completes

**Step 4: Manual Testing (ALWAYS DO THIS!)**
- Test the feature yourself in browser/app
- Check edge cases and error states
- Take screenshots of any bugs

**Step 5: Fix Bugs If Needed**
```bash
/specswarm:bugfix "Bug: Login fails with special characters in password

Console errors: [paste errors]
Terminal errors: [paste errors]"
```

**Step 6: Complete & Merge**
```bash
/specswarm:analyze-quality  # Check quality score
/specswarm:complete         # Merge to parent branch
```

### Understanding `--validate` Flag

When you use `--validate`:
- ✅ Playwright launches a real browser
- ✅ AI generates test flows from your spec
- ✅ Tests critical user journeys automatically
- ✅ Monitors console for errors
- ✅ Auto-fixes issues (up to 3 retries)
- ⚠️ **Still requires manual testing** - automated tests don't catch everything!

**Example with validation**:
```bash
/speclabs:orchestrate-feature "Add shopping cart with add/remove items, quantity adjustment, and total calculation" --validate
```

Playwright will:
1. Start your dev server
2. Navigate to the app
3. Test add-to-cart flow
4. Test quantity adjustments
5. Verify total calculations
6. Check for console errors

---

## Commands

### `/speclabs:orchestrate-feature` - Autonomous Feature Lifecycle

Complete feature development from natural language description to working code.

**Usage**:
```bash
/speclabs:orchestrate-feature "feature description" [project-path] [flags]
```

**Flags**:
- `--validate` - Run browser validation after implementation
- `--audit` - Run comprehensive code audit (compatibility, security, best practices)
- `--skip-specify` - Skip specification (spec.md already exists)
- `--skip-clarify` - Skip clarification phase
- `--skip-plan` - Skip planning (plan.md already exists)
- `--max-retries N` - Maximum retries per task (default: 3)

**What It Does**:
1. **Planning Phase**: Generates spec.md, plan.md, tasks.md via SpecSwarm
2. **Implementation Phase**: Executes all tasks with intelligent retry logic
3. **Validation Phase** (if --validate): Browser automation with Playwright
4. **Bugfix Phase** (if needed): Auto-fixes failed tasks
5. **Audit Phase** (if --audit): Comprehensive quality validation
6. **Reporting**: Complete session tracking and metrics

**Example**:
```bash
# Full autonomous workflow with validation
/speclabs:orchestrate-feature "Add shopping cart with quantity adjustment" --validate --audit
```

---

### `/speclabs:validate-feature` - Multi-Type Validation Orchestrator

Standalone validation command that auto-detects project type and runs appropriate validation.

**Usage**:
```bash
/speclabs:validate-feature [project-path] [flags]
```

**Flags**:
- `--type TYPE` - Override auto-detection (webapp, android, rest-api, desktop-gui)
- `--session-id ID` - Link to orchestration session

**Supported Types**:
- ✅ **Webapp** (v2.7.0): React, Vite, Next.js, React Router
  - AI-powered flow generation from spec/plan/tasks
  - Playwright browser automation
  - Console/exception monitoring
  - Auto-fix retry loop (up to 3 attempts)
  - Dev server lifecycle management

- 🔄 **Android** (v2.7.1+ planned): AndroidManifest.xml projects
- 🔄 **REST API** (v2.7.2+ planned): OpenAPI/Swagger specs
- 🔄 **Desktop GUI** (v2.7.3+ planned): Electron apps

**Example**:
```bash
# Auto-detect and validate
/speclabs:validate-feature /home/user/my-project

# Override detection
/speclabs:validate-feature --type webapp
```

---

### `/speclabs:orchestrate` - Task Workflow Orchestration

Execute pre-defined task workflows with autonomous agent coordination.

**Usage**:
```bash
/speclabs:orchestrate workflow.md [project-path]
```

**What It Does**:
- Launches autonomous agent
- Executes tasks from workflow file
- Intelligent retry logic (up to 3 attempts)
- Comprehensive error reporting

---

### `/speclabs:orchestrate-validate` - Validation Suite

Run comprehensive validation suite (browser, terminal, visual analysis).

**Usage**:
```bash
/speclabs:orchestrate-validate /path/to/project
```

**Validation Types**:
- Browser automation with Playwright
- Terminal output monitoring
- Visual regression testing (future)

---

### `/speclabs:coordinate` - Systematic Multi-Bug Debugging

Coordinate complex debugging workflows for multiple related bugs.

**Usage**:
```bash
/speclabs:coordinate "bug description 1, bug description 2, bug description 3"
```

**What It Does**:
1. Parse and analyze multiple bug descriptions
2. Design systematic logging strategy
3. Orchestrate investigation workflow
4. Generate comprehensive debugging report
5. Coordinate with agent execution

**Best For**:
- 3+ related bugs
- Complex system interactions
- Cascading failures
- Performance issues affecting multiple areas

---

### `/speclabs:metrics` - Orchestration Analytics

View orchestration session metrics and performance analytics.

**Usage**:
```bash
/speclabs:metrics [session-id]
```

**Metrics Displayed**:
- Session duration and status
- Task completion rates
- Retry counts and success rates
- Validation results
- Performance trends

---

## Architecture

### Intelligent Components

**State Manager** (`lib/state-manager.sh`):
- Session tracking and persistence
- State transitions and validation
- Error recovery

**Decision Maker** (`lib/decision-maker.sh`):
- Intelligent routing decisions
- Retry logic and error handling
- Workflow optimization

**Prompt Refiner** (`lib/prompt-refiner.sh`):
- Context-aware prompt enhancement
- Error message analysis
- Retry prompt generation

**Metrics Tracker** (`lib/metrics-tracker.sh`):
- Performance monitoring
- Success rate tracking
- Analytics and reporting

### Validation Architecture (v2.7.0+)

**Validator Interface** (`lib/validator-interface.sh`):
- Standardized contract for all validators
- JSON result schema
- Extensible for new types

**Project Type Detection** (`lib/detect-project-type.sh`):
- File-based detection with confidence scoring
- Supports: webapp, android, rest-api, desktop-gui
- Manual override available

**Orchestrator** (`lib/validate-feature-orchestrator.sh`):
- Generic orchestration logic
- Type-specific delegation
- Session integration
- Result aggregation

**Webapp Validator** (`lib/validators/validate-webapp.sh`):
- AI-powered flow generation
- Playwright integration
- Auto-fix retry loop
- Dev server management

---

## Session Tracking

All orchestrations create session files in `.specswarm/feature-orchestrator/sessions/`:

```json
{
  "session_id": "feature_20251104_143022",
  "feature_description": "Add user authentication",
  "project_path": "/path/to/project",
  "status": "completed",
  "phases": {
    "specify": {...},
    "plan": {...},
    "tasks": {...},
    "implementation": {...},
    "validation": {...},
    "bugfix": {...}
  },
  "metrics": {
    "duration_seconds": 1847,
    "tasks_completed": 23,
    "tasks_failed": 2,
    "retry_count": 4
  }
}
```

Access sessions with:
```bash
/speclabs:metrics session_id
```

---

## Configuration

### Quality Standards (`.specswarm/quality-standards.md`)

```yaml
# Orchestration Settings
max_task_retries: 3
auto_bugfix_enabled: true
validation_enabled: true
```

### Tech Stack (`.specswarm/tech-stack.md`)

Enforced during planning phase when orchestrate-feature integrates with SpecSwarm.

---

## Best Practices

### Getting Started
1. **Start small**: Test with 2-3 task features first
2. **Always commit**: Have clean git state before orchestration
3. **Review artifacts**: Check spec.md, plan.md before proceeding
4. **Monitor sessions**: Use `/speclabs:metrics` to track progress

### Production Use
1. **NOT for critical work**: SpecLabs is experimental
2. **Verify outputs**: Always review generated code
3. **Test thoroughly**: Don't skip manual testing
4. **Report issues**: Help improve experimental features

### Advanced Usage
1. **Custom workflows**: Create reusable workflow.md files
2. **Session analysis**: Track patterns across multiple features
3. **Validation customization**: Define custom flows in spec.md
4. **Performance tuning**: Adjust retry counts and timeouts

---

## Development Roadmap

### ✅ Completed

- **v2.7.3** (Nov 2025): Silent autonomous execution - eliminated all mid-phase reporting
- **v2.7.2** (Nov 2025): Fixed agent pause behavior during slash command execution
- **v2.7.1** (Nov 2025): Fixed autonomous execution (no pausing before Task tool)
- **v2.7.0** (Nov 2025): Multi-type validation orchestrator
- **v2.6.1** (Oct 2025): Optimized implementation phase
- **v2.6.0** (Oct 2025): AI-powered flow validation
- **v2.5.0** (Oct 2025): Playwright integration
- **v2.0.0** (Oct 2025): Feature orchestration complete
- **v1.1.0** (Oct 2025): Intelligent retry logic
- **v1.0.0** (Oct 2025): Task orchestration

### 🔄 In Progress

- **v2.8.0+**: Additional validator types (Android, REST API, Desktop)
- Performance optimization for large codebases
- Enhanced error recovery strategies

### 📋 Planned

- **v3.0.0**: Sprint-level orchestration
  - Multi-feature coordination
  - Parallel agent execution
  - Dependency analysis
  - Sprint backlog management

---

## Troubleshooting

### Orchestration Pauses Mid-Execution

**Fixed in v2.7.3** - Update to latest version:
```bash
/plugin update speclabs
```

**Note**: v2.7.1 fixed Task tool pausing, v2.7.2 fixed slash command execution pausing, v2.7.3 eliminated all mid-phase reporting. If still experiencing pauses, ensure you're on v2.7.3+.

### Validation Fails

1. Check dev server starts correctly: `npm run dev`
2. Verify port availability (default: 5173 for Vite)
3. Check Playwright installation: `npx playwright install`
4. Review validation logs: `.speclabs/validation/`

### Task Retry Exhausted

1. Review error messages in session file
2. Check if issue is environmental (missing deps, config)
3. Fix underlying issue and re-run
4. Increase retry count: `--max-retries 5`

### Session Not Found

Sessions are in `.specswarm/feature-orchestrator/sessions/`
- Check session ID is correct
- Verify session file exists
- Use `/speclabs:metrics` without args to list recent sessions

---

## Technical Details

### Validator Interface Contract

All validators must implement:

```bash
validate_execute(
  --project-path <absolute_path>
  --session-id <id>
  --type <webapp|android|rest-api|desktop-gui>
)
```

**Return**: Standardized JSON result
```json
{
  "status": "passed|failed|error",
  "type": "webapp|android|rest-api|desktop-gui",
  "summary": {
    "total_flows": 5,
    "passed_flows": 4,
    "failed_flows": 1,
    "error_count": 2,
    "duration_seconds": 127
  },
  "errors": [...],
  "artifacts": [...],
  "metadata": {...}
}
```

### Extending with New Validators

1. Create `/lib/validators/validate-{type}.sh`
2. Implement `validate_execute()` function
3. Return standardized JSON result
4. Update detection in `/lib/detect-project-type.sh`
5. Validator automatically available via orchestrator

---

## Performance Metrics

Based on real-world testing:

**Feature Implementation**:
- Manual (SpecSwarm): ~90-120 minutes
- Autonomous (SpecLabs): ~30-60 minutes
- **Speedup**: 50-67% faster

**Success Rates** (Phase 2):
- First attempt success: ~70%
- After retry (3 attempts): ~90%
- Total orchestration success: ~85%

**Common Issues**:
- Environment setup: 8%
- Dependency conflicts: 5%
- Test failures: 4%
- Other: 3%

---

## Known Limitations

1. **Experimental Status**: Not production-ready, bugs expected
2. **Single Feature**: Sprint orchestration not yet available
3. **Validation Types**: Only webapp validator complete (v2.7.0)
4. **Error Recovery**: Limited to retry logic, may need manual intervention
5. **Complex Features**: Best with 5-15 task features, struggles with 20+

---

## Support

- **Issues**: https://github.com/MartyBonacci/specswarm/issues
- **Main Docs**: [SpecSwarm README](../../README.md)
- **Changelog**: [CHANGELOG.md](../../CHANGELOG.md)

---

## License

MIT License - see [LICENSE](../../LICENSE) for details.

---

**SpecLabs v2.7.3** - Autonomous orchestration for the future of software development. 🧪🚀

Experimental. Powerful. Evolving.
