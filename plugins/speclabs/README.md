# SpecLabs v2.0.0

**Experimental Laboratory for Autonomous Development & Advanced Debugging**

⚠️ **EXPERIMENTAL** - Features in active development - Use at your own risk

---

## Overview

SpecLabs is the experimental wing of the SpecSwarm ecosystem, building toward **autonomous sprint and project orchestration**. The ultimate vision: coordinate multiple Claude Code agents to build features and complete projects with minimal human intervention.

**Vision**: "Give me a feature description Monday evening, wake up Tuesday morning with working, tested, production-ready code."

**Current Status**: ✅ **Phase 2 Complete** - Feature Workflow Engine (October 16, 2025)

**What's Working Now**:
- ✅ **Phase 1a**: State Manager, Decision Maker, Prompt Refiner, Vision API Mock, Metrics Tracker
- ✅ **Phase 1b**: Full automation with zero manual steps and intelligent retry logic
- ✅ **Phase 2**: Complete feature orchestration from description to implementation

**Philosophy**: Rapid innovation → Real-world testing → Production graduation

---

## Quick Start

### Orchestrate a Complete Feature

```bash
# One command to go from feature description to implementation!
/speclabs:orchestrate-feature "Add user authentication with email/password" /path/to/project

# That's it! Everything automated:
# ✅ SpecSwarm planning (specify → clarify → plan → tasks)
# ✅ Task breakdown and conversion
# ✅ Implementation with intelligent retry logic
# ✅ Validation after each task
# ✅ Bugfix if needed
# ✅ Comprehensive reporting
```

### Orchestrate a Single Task

```bash
# Execute a pre-written workflow
/speclabs:orchestrate workflow.md /path/to/project

# Automatic:
# ✅ Agent launch
# ✅ Validation
# ✅ Up to 3 retries with refined prompts
# ✅ Complete/retry/escalate decisions
```

### Validate Implementation

```bash
# Run comprehensive validation suite
/speclabs:orchestrate-validate /path/to/project

# Checks:
# ✅ Playwright browser automation
# ✅ Console errors
# ✅ Network errors
# ✅ Full-page screenshot
```

---

## Commands (4)

### 🚀 Phase 2: Feature Orchestration (NEW!)

#### `/speclabs:orchestrate-feature`
**Complete feature lifecycle orchestration - planning to implementation**

One command to orchestrate an entire feature from natural language description to working, validated implementation.

**Usage**:
```bash
/speclabs:orchestrate-feature "<feature-description>" <project-path> [options]
```

**Examples**:
```bash
# Basic usage
/speclabs:orchestrate-feature "Add dark mode toggle to settings" /home/marty/my-app

# With options
/speclabs:orchestrate-feature "Add feature X" /project --skip-specify --max-retries 5
```

**Options**:
- `--skip-specify`: Skip specify phase (spec.md already exists)
- `--skip-clarify`: Skip clarify phase
- `--skip-plan`: Skip plan phase (plan.md already exists)
- `--max-retries N`: Maximum retries per task (default: 3)

**What It Does**:
1. **SpecSwarm Planning**: Runs specify → clarify → plan → tasks
2. **Task Conversion**: Converts tasks.md to executable workflow files
3. **Implementation**: Executes each task with Phase 1b orchestrator
4. **Validation**: Automatic validation after each task
5. **Retry Logic**: Up to 3 automatic retries per task with refined prompts
6. **Bugfix**: Runs /specswarm:bugfix if tasks fail
7. **Reporting**: Generates comprehensive feature report

**Benefits**:
- ⚡ **50-67% faster** than manual approach
- 🎯 **Zero manual steps** - complete automation
- 🔄 **Intelligent retry logic** - refined prompts on failure
- 📊 **Complete audit trail** - session data for every step

**Perfect For**:
- Adding new features to existing projects
- Implementing user stories from sprint backlogs
- Automating feature development workflows

---

### 🤖 Phase 1b: Task Orchestration

#### `/speclabs:orchestrate`
**Automated workflow orchestration with agent execution and validation**

Execute pre-written workflow files with full automation, intelligent retry logic, and comprehensive validation.

**Usage**:
```bash
/speclabs:orchestrate <workflow-file> <project-path>
```

**Example**:
```bash
/speclabs:orchestrate features/001-fix-bug/workflow.md /home/marty/code-projects/my-app
```

**What It Does**:
1. Parses workflow specification
2. Launches autonomous agent in target project (automatic)
3. Agent executes task independently
4. Runs validation suite automatically
5. Analyzes results with decision maker
6. Retries up to 3 times if needed (with refined prompts)
7. Escalates if max retries exceeded

**Workflow Format**:
```markdown
# Task: [Task Name]

## Description
[What needs to be done]

## Files to Modify
- path/to/file1.ts
- path/to/file2.ts

## Changes Required
[Detailed description of changes]

## Expected Outcome
[What should happen after changes]

## Validation
- [ ] Criterion 1
- [ ] Criterion 2
```

**Phase 1b Features**:
- ✅ Automatic agent launch (no manual Task tool usage)
- ✅ Automatic validation execution
- ✅ True retry loop (up to 3 automatic retries)
- ✅ Intelligent prompt refinement on failure
- ✅ Complete state tracking in /memory/
- ✅ Comprehensive metrics and reporting

---

#### `/speclabs:orchestrate-validate`
**Comprehensive validation suite (browser, terminal, visual analysis)**

Run automated validation on target projects using Playwright browser automation.

**Usage**:
```bash
/speclabs:orchestrate-validate <project-path> [url]
```

**Examples**:
```bash
# Default URL (http://localhost:5173)
/speclabs:orchestrate-validate /home/marty/code-projects/my-app

# Custom URL
/speclabs:orchestrate-validate /home/marty/code-projects/my-app http://localhost:3000
```

**What It Does**:
1. Checks dev server is running
2. Launches Playwright browser automation
3. Navigates to app and waits for load
4. Captures console errors
5. Captures network errors (4xx/5xx responses)
6. Takes full-page screenshot
7. Exports results as JSON
8. Generates validation report

**Validation Output**:
- **Results JSON**: `/tmp/orchestrator-validation-results.json`
- **Screenshot**: `/tmp/orchestrator-validation-screenshot.png`

**Used By**:
- `/speclabs:orchestrate` (automatic validation)
- `/speclabs:orchestrate-feature` (per-task validation)
- Manual validation when needed

---

### 🐛 Advanced Debugging

#### `/speclabs:coordinate`
**Systematic multi-bug debugging with logging, monitoring, and orchestration**

Transform chaotic debugging into systematic investigation with clear orchestration opportunities.

**Usage**:
```bash
/speclabs:coordinate "<problem-description>"
```

**Example**:
```bash
/speclabs:coordinate "navbar not updating after sign-in, sign-out not working, like button causes blank page"
```

**What It Does**:

**Phase 1: Discovery & Analysis**
- Parses problem description into individual issues
- Creates debug session directory (`.debug-sessions/YYYYMMDD-HHMMSS/`)
- Determines strategy (sequential vs orchestrated)
- Orchestrated recommended for 3+ bugs

**Phase 2: Logging Strategy**
- Generates logging strategy template
- Identifies suspected files/components
- Specifies strategic logging points
- Defines monitoring approach

**Phase 3: Monitor & Analyze**
- Guides application run and log capture
- Provides analysis template
- Helps identify root causes per issue
- Documents evidence and findings

**Phase 4: Orchestration Planning** (if 3+ bugs)
- Generates multi-agent orchestration plan
- Groups issues by domain
- Assigns agents to parallel tracks
- Defines coordination points

**Phase 5: Integration & Verification**
- Verification checklist
- Regression testing guidance
- Cleanup recommendations
- Learnings documentation

**Artifacts Created**:
```
.debug-sessions/20251015-143022/
├── problem-description.md     # Issue breakdown
├── logging-strategy.md        # Where to add logs
├── analysis-template.md       # Root cause findings
├── orchestration-plan.md      # Agent coordination (if 3+ bugs)
└── verification-checklist.md  # Post-fix validation
```

---

## Architecture

### Three-Layer Orchestration Stack

```
┌────────────────────────────────────────────────────────────┐
│  Phase 3: SPRINT ORCHESTRATOR (Coming Next!)               │
│  /speclabs:orchestrate-sprint "Build checkout flow"        │
│  ┌──────────────────────────────────────────────────────┐ │
│  │  Phase 2: FEATURE WORKFLOW ENGINE (✅ Complete!)     │ │
│  │  /speclabs:orchestrate-feature "Add user auth"       │ │
│  │  ┌────────────────────────────────────────────────┐ │ │
│  │  │  Phase 1b: TASK EXECUTOR (✅ Complete!)        │ │ │
│  │  │  /speclabs:orchestrate workflow.md project/   │ │ │
│  │  │  ┌────────────────────────────────────────┐  │ │ │
│  │  │  │  Phase 1a: COMPONENTS (✅ Complete!)   │  │ │ │
│  │  │  │  - State Manager                        │  │ │ │
│  │  │  │  - Decision Maker                       │  │ │ │
│  │  │  │  - Prompt Refiner                       │  │ │ │
│  │  │  │  - Vision API (Mock)                    │  │ │ │
│  │  │  │  - Metrics Tracker                      │  │ │ │
│  │  │  └────────────────────────────────────────┘  │ │ │
│  │  └────────────────────────────────────────────────┘ │ │
│  └──────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────┘
```

### Phase 2: Feature Workflow Engine

```
User: /speclabs:orchestrate-feature "Add user auth" /project

↓
SpecSwarm Planning:
  - /specswarm:specify    → spec.md
  - /specswarm:clarify    → refined spec.md
  - /specswarm:plan       → plan.md
  - /specswarm:tasks      → tasks.md (5 tasks identified)

↓
Task Conversion:
  - Parse tasks.md
  - Generate workflow_1.md, workflow_2.md, ... workflow_5.md
  - Inject context from spec.md and plan.md

↓
Implementation (FOR EACH TASK):
  - /speclabs:orchestrate workflow_N.md /project  ← Phase 1b!
    ├─ Launch agent automatically
    ├─ Validate automatically
    ├─ Retry up to 3 times if needed
    └─ Track result

↓
Bugfix (if any tasks failed):
  - /specswarm:bugfix
  - Address remaining issues

↓
Reporting:
  - Generate feature report
  - Export session data
  - Display summary
```

---

## Integration with SpecSwarm

SpecLabs and SpecSwarm work together seamlessly:

### Planning → Execution Pattern

```bash
# SpecSwarm: Planning intelligence
/specswarm:specify "Add shopping cart"
/specswarm:clarify
/specswarm:plan
/specswarm:tasks

# SpecLabs: Autonomous execution (Phase 2 does this automatically!)
/speclabs:orchestrate-feature "Add shopping cart" /project
```

### Quality → Debugging Pattern

```bash
# SpecSwarm: Quality analysis
/specswarm:analyze-quality

# If issues found:
# SpecLabs: Systematic debugging
/speclabs:coordinate "Issues found in quality analysis"
```

### Complete Workflow

```
SpecSwarm (specify → plan → tasks)  ← Planning
    ↓
SpecLabs (orchestrate-feature)      ← Execution
    ↓
SpecLabs (orchestrate-validate)     ← Validation
    ↓
SpecSwarm (analyze-quality)         ← Quality Check
    ↓
SpecSwarm (bugfix/refactor)         ← Polish
```

---

## Development Timeline

### ✅ Phase 1a: Components (October 16, 2025)
**Status**: COMPLETE

**Components Built**:
- State Manager - Session state persistence
- Decision Maker - Complete/retry/escalate logic
- Prompt Refiner - Context-injected retries
- Vision API Mock - Placeholder for future
- Metrics Tracker - Performance tracking

**Deliverable**: Foundation for intelligent orchestration

---

### ✅ Phase 1b: Full Automation (October 16, 2025)
**Status**: COMPLETE

**Features Added**:
- Automatic agent launch (no manual steps)
- Automatic validation execution
- True retry loop (up to 3 automatic retries)
- Zero manual intervention required

**Impact**: 10x faster than manual Phase 1a approach

---

### ✅ Phase 2: Feature Workflow Engine (October 16, 2025)
**Status**: COMPLETE

**Components Built**:
- Feature Orchestrator - Feature session management
- Task Converter - tasks.md → workflow.md conversion
- orchestrate-feature command - Complete feature lifecycle

**Features**:
- SpecSwarm integration (specify → clarify → plan → tasks)
- Automatic task conversion
- Per-task execution with Phase 1b
- Feature-level bugfix
- Comprehensive reporting

**Impact**: 50-67% faster than manual feature implementation

**Documentation**: See `docs/PHASE-2-COMPLETE.md` for full details

---

### 🚀 Phase 3: Sprint Orchestration (Next - Q1 2026)
**Status**: Planned

**Goal**: Orchestrate complete sprints with multiple features

**Components**:
- Sprint Coordinator - Multi-feature orchestration
- Dependency Manager - Feature dependency analysis
- Resource Allocator - Parallel execution planning
- Progress Monitor - Real-time sprint tracking

**Command**: `/speclabs:orchestrate-sprint sprint-backlog.md /project`

**Impact**: Overnight execution of complete sprint backlogs

---

## Usage Examples

### Example 1: Feature Orchestration (Phase 2)

```bash
# Orchestrate complete feature
cd /path/to/your/project
/speclabs:orchestrate-feature "Add email notification system" .

# Output:
# 🎯 Feature Orchestrator - Phase 2
# 📝 Creating feature session...
# ✅ Session: feature_20251016_143022
#
# ## Phase 1: SpecSwarm Planning
# Executing: /specswarm:specify "Add email notification system"
# ✅ Generated: spec.md
#
# Executing: /specswarm:clarify
# [Asks 5 clarification questions]
# ✅ Updated: spec.md
#
# Executing: /specswarm:plan
# ✅ Generated: plan.md
#
# Executing: /specswarm:tasks
# ✅ Generated: tasks.md (4 tasks)
#
# ## Phase 2: Task Implementation
# 🔄 Task 1/4: Create email service
# ✅ Task completed successfully
#
# 🔄 Task 2/4: Add notification templates
# ✅ Task completed successfully
#
# 🔄 Task 3/4: Implement send notification API
# [Validation fails - retry with refined prompt]
# ✅ Task completed successfully (attempt 2)
#
# 🔄 Task 4/4: Add notification UI
# ✅ Task completed successfully
#
# 🎉 Feature Orchestration Complete!
# ✅ Status: SUCCESS
# 📄 Report: feature_20251016_143022_report.md
```

### Example 2: Task Orchestration (Phase 1b)

```bash
# Execute single task workflow
/speclabs:orchestrate features/fix-navbar/workflow.md /home/marty/my-app

# Output:
# 🎯 Project Orchestrator - Phase 1b
# 📝 Session: orch-20251016-143500-789
#
# 🚀 Launching agent...
# [Agent executes task]
#
# 🔍 Running validation...
# ✅ Playwright: Pass
# ✅ Console: No errors
# ✅ Network: No errors
#
# 🤔 Decision: complete
# ✅ Task completed successfully!
```

### Example 3: Systematic Debugging

```bash
# Coordinate multi-bug debugging
/speclabs:coordinate "login fails, password reset broken, session timeout too short"

# Creates debug session with:
# - Problem breakdown (3 issues)
# - Logging strategy
# - Analysis templates
# - Orchestration plan (3+ bugs)
# - Verification checklist
```

---

## Session Data & Reporting

### Feature Sessions (Phase 2)

Stored in: `/memory/orchestrator/features/`

```json
{
  "session_id": "feature_20251016_143022",
  "feature_name": "Add email notifications",
  "status": "complete",
  "specswarm": {
    "specify": { "status": "complete", "output_file": "spec.md" },
    "clarify": { "status": "complete" },
    "plan": { "status": "complete", "output_file": "plan.md" },
    "tasks": { "status": "complete", "task_count": 4 }
  },
  "implementation": {
    "total_count": 4,
    "completed_count": 4,
    "failed_count": 0,
    "tasks": [...]
  },
  "result": {
    "success": true,
    "message": "Feature implementation successful"
  }
}
```

### Task Sessions (Phase 1b)

Stored in: `/memory/orchestrator/sessions/`

```json
{
  "session_id": "orch-20251016-143500-789",
  "status": "success",
  "workflow": {...},
  "agent": {...},
  "validation": {...},
  "retries": {
    "count": 1,
    "max": 3
  },
  "decision": {
    "action": "complete",
    "reason": "Agent completed successfully and validation passed"
  }
}
```

---

## Best Practices

### Feature Orchestration

1. **Clear Feature Descriptions**
   ```bash
   # Good
   /speclabs:orchestrate-feature "Add user authentication with email/password, including password reset flow" /project

   # Too vague
   /speclabs:orchestrate-feature "Add auth" /project
   ```

2. **Start Simple**
   - Test with small features first (2-3 tasks)
   - Build confidence gradually
   - Expand to larger features as you learn

3. **Review Generated Artifacts**
   - Check spec.md and plan.md make sense
   - Review tasks.md before implementation starts
   - Verify workflows are clear

### Task Orchestration

1. **Write Clear Workflows**
   - Be specific about changes required
   - List exact file paths
   - Define clear validation criteria
   - Provide expected outcomes

2. **Trust the Retry Logic**
   - Let Phase 1b retry failed tasks automatically
   - Review refined prompts to understand improvements
   - Only escalate after 3 retries exhausted

3. **Monitor Validation**
   - Review validation results carefully
   - Check screenshots for visual issues
   - Address console errors promptly

---

## Known Limitations

### Phase 2 (Feature Orchestration)

- ⚠️ First real-world implementation - expect edge cases
- ⚠️ Sequential task execution only (no parallelization yet)
- ⚠️ Simple task parser - may need refinement for complex tasks.md
- ⚠️ Vision API still mocked (planned for future)

### Phase 1b (Task Orchestration)

- ⚠️ Vision API validation is mocked (returns success always)
- ⚠️ Limited to single-task workflows
- ⚠️ Basic error recovery

### General

- ⚠️ **Experimental status** - Use in non-production environments
- ⚠️ Agent execution may fail unpredictably
- ⚠️ Always review generated code before committing
- ⚠️ Have backups/commits before running

---

## Troubleshooting

### orchestrate-feature Issues

**SpecSwarm commands fail**:
- Ensure SpecSwarm plugin is installed
- Verify project has proper structure
- Make feature description clear and specific
- Use `--skip-specify` if spec.md already exists

**Task parsing fails**:
- Check tasks.md format (should use `## Task N:` headers)
- Manually review tasks.md for formatting issues
- May need to adjust task-converter.sh parser

**All tasks escalate**:
- Check Phase 1b orchestrator works (`/speclabs:orchestrate` directly)
- Review generated workflow files for clarity
- Increase max-retries: `--max-retries 5`

### orchestrate Issues

**Agent doesn't understand task**:
- Make workflow description more specific
- List exact file paths to modify
- Provide code examples in workflow

**Validation fails**:
- Check dev server is running
- Verify URL is correct
- Review screenshot for visual issues

### orchestrate-validate Issues

**Dev server not running**:
```bash
cd /path/to/project
npm run dev
```

**Playwright installation fails**:
```bash
npm install --save-dev playwright
npx playwright install
```

---

## Documentation

### Complete Guides

- **`docs/PHASE-1A-COMPLETE.md`** - Phase 1a component details
- **`docs/PHASE-1B-COMPLETE.md`** - Phase 1b automation guide
- **`docs/PHASE-2-COMPLETE.md`** - Phase 2 feature orchestration (comprehensive!)
- **`docs/ORCHESTRATOR-ROADMAP.md`** - Complete Phase 1-3 roadmap

### Quick References

- **Feature Session Structure**: See `lib/feature-orchestrator.sh`
- **Task Converter Logic**: See `lib/task-converter.sh`
- **Workflow Format**: See `commands/orchestrate.md`

---

## Why SpecLabs Exists

**Clear Separation**:
- **SpecSwarm** = Production-ready, stable, proven features
- **SpecLabs** = Experimental, high-risk, rapid iteration

**Benefits**:
- ✅ Isolated risk - Bugs don't affect SpecSwarm stability
- ✅ Clear signal - Separate plugin indicates experimental status
- ✅ Safe iteration - Rapid development without stability concerns
- ✅ Easy graduation - Features move to SpecSwarm when proven stable

---

## Usage Warnings

⚠️ **Use SpecLabs when**:
- You're comfortable with experimental features
- You can handle bugs and failures gracefully
- You want to test cutting-edge workflows
- You're willing to provide feedback

⚠️ **Don't use SpecLabs when**:
- Working on production-critical code
- You need guaranteed stability
- Time-sensitive deadlines
- Cannot afford unexpected failures

⚠️ **Always**:
- Test in non-critical environments first
- Have backups/commits before running
- Review agent changes carefully
- Report issues for improvement

---

## Contributing Feedback

**SpecLabs is experimental** - Your feedback drives improvements!

### Report Issues

When reporting bugs or unexpected behavior:

1. **What command?** (`/speclabs:orchestrate-feature`, etc.)
2. **What happened?** (actual behavior)
3. **What expected?** (desired behavior)
4. **Artifacts?** (session data, screenshots, logs)
5. **Context?** (project type, feature complexity)

### Suggest Enhancements

Ideas for Phase 2/3 improvements welcome:
- New validation types
- Better error recovery
- Smarter orchestration logic
- Additional automation
- Integration opportunities

---

## Consolidated From

SpecLabs v1.0.0 merged two deprecated plugins:

### debug-coordinate v1.0.0
- Systematic multi-bug investigation
- Logging strategy generation
- Orchestration planning

### project-orchestrator v0.1.1
- Test workflow execution
- Multi-agent coordination
- Browser validation

**Migration**: Replace `/debug-coordinate:` and `/project-orchestrator:` with `/speclabs:` in workflows.

---

## License

MIT License - See LICENSE file for details

---

## Support

- **Repository**: https://github.com/MartyBonacci/specswarm
- **Issues**: https://github.com/MartyBonacci/specswarm/issues
- **Documentation**: See `docs/` directory for detailed guides

---

**SpecLabs v2.0.0** - Phase 2 Complete! 🚀

**"Give me a feature description, walk away, come back to completed implementation."**

Build autonomously. Debug systematically. Experiment boldly.
