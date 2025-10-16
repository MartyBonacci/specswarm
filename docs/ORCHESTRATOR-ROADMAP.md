# Orchestrator Roadmap: Task → Feature → Sprint

**Date**: 2025-10-16 (Updated after Phase 1b completion)
**Purpose**: Complete roadmap from current state to full sprint orchestration
**Status**: Phase 1a/1b COMPLETE, Planning Phase 2/3

---

## Table of Contents

1. [Where We Are Now](#where-we-are-now)
2. [The Layered Architecture](#the-layered-architecture)
3. [Phase Definitions](#phase-definitions)
4. [Current vs Future Capabilities](#current-vs-future-capabilities)
5. [Integration with SpecSwarm](#integration-with-specswarm)
6. [Roadmap Timeline](#roadmap-timeline)
7. [Auto-Compact Recovery Guide](#auto-compact-recovery-guide)

---

## Where We Are Now

### ✅ Phase 1a: Components (COMPLETE)
**Built**: October 16, 2025
**Status**: Production-ready

**Components**:
1. **State Manager** - Session persistence and tracking
2. **Decision Maker** - Intelligent complete/retry/escalate logic
3. **Prompt Refiner** - Context-injected prompts on retry
4. **Vision API (Mock)** - UI validation framework
5. **Metrics Tracker** - Session analytics

**Documentation**:
- `docs/PHASE-1A-COMPLETE.md`
- `docs/STATE-MANAGER-COMPLETE.md`
- `docs/DECISION-MAKER-COMPLETE.md`
- `docs/PROMPT-REFINER-COMPLETE.md`

---

### ✅ Phase 1b: Full Automation (COMPLETE)
**Built**: October 16, 2025 (same day as Phase 1a!)
**Status**: Production-ready

**Additions**:
1. **Automatic Agent Launch** - No manual Task tool usage
2. **Automatic Validation** - Orchestrate-validate runs automatically
3. **True Retry Loop** - Up to 3 automatic retries
4. **Zero Manual Steps** - Fully autonomous execution

**Benefits**:
- 🚀 10x faster testing (2-5 min vs 15-30 min per test)
- 📊 Real validation data (Playwright, console, network)
- ⚡ Rapid iteration (12-30 tests/hour vs 2-4)
- 🎯 No human error (consistent execution)

**Documentation**:
- `docs/PHASE-1B-COMPLETE.md`
- `docs/ORCHESTRATE-INTEGRATION-COMPLETE.md`

---

### What We Can Do TODAY

**Command**: `/speclabs:orchestrate <workflow.md> <project-path>`

**Capabilities**:
- Execute ONE pre-written `workflow.md` file
- Automatically launch agent to implement task
- Automatically validate results (Playwright, console, etc.)
- Intelligently retry up to 3 times with refined prompts
- Automatically make decision (complete/retry/escalate)
- Track all metrics and session state

**Limitations**:
- ❌ Does NOT create `workflow.md` files (you write them manually)
- ❌ Does NOT run SpecSwarm commands (specify, clarify, plan, tasks, etc.)
- ❌ Does NOT handle multiple features
- ❌ Does NOT coordinate across a sprint
- ❌ Does NOT generate its own tasks

**Current Role**: **Task-Level Executor** with intelligent retry logic

---

## The Layered Architecture

```
┌────────────────────────────────────────────────────────────┐
│  Phase 3: SPRINT ORCHESTRATOR (Future)                     │
│  /speclabs:orchestrate-sprint "Build e-commerce checkout"  │
│                                                             │
│  SCOPE: Multiple features                                  │
│  INPUT: Sprint goal or feature list                        │
│  OUTPUT: Complete sprint with multiple features            │
│  PROCESS: Runs Phase 2 for each feature                    │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐ │
│  │  Phase 2: FEATURE WORKFLOW ENGINE (Next)             │ │
│  │  /speclabs:orchestrate-feature "Add user auth"       │ │
│  │                                                       │ │
│  │  SCOPE: Single feature, full lifecycle               │ │
│  │  INPUT: Feature description                          │ │
│  │  OUTPUT: Complete feature with tests                 │ │
│  │  PROCESS: specify → clarify → plan → tasks →         │ │
│  │           implement (using Phase 1b for each task)   │ │
│  │                                                       │ │
│  │  ┌────────────────────────────────────────────────┐ │ │
│  │  │  Phase 1b: TASK EXECUTOR (Current - Built!)   │ │ │
│  │  │  /speclabs:orchestrate workflow.md project/   │ │ │
│  │  │                                                │ │ │
│  │  │  SCOPE: Single task                           │ │ │
│  │  │  INPUT: Pre-written workflow.md               │ │ │
│  │  │  OUTPUT: Implemented task                     │ │ │
│  │  │  PROCESS: Execute → Validate → Decide →       │ │ │
│  │  │           Retry (if needed)                    │ │ │
│  │  │                                                │ │ │
│  │  │  ┌────────────────────────────────────────┐  │ │ │
│  │  │  │  Phase 1a: COMPONENTS (Foundation)     │  │ │ │
│  │  │  │  - State Manager                       │  │ │ │
│  │  │  │  - Decision Maker                      │  │ │ │
│  │  │  │  - Prompt Refiner                      │  │ │ │
│  │  │  │  - Vision API                          │  │ │ │
│  │  │  │  - Metrics Tracker                     │  │ │ │
│  │  │  └────────────────────────────────────────┘  │ │ │
│  │  └────────────────────────────────────────────────┘ │ │
│  └──────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────┘

         ↑ WHERE WE ARE NOW (Phase 1a + 1b)
         ↑↑ NEXT (Phase 2)
         ↑↑↑ FUTURE (Phase 3)
```

---

## Phase Definitions

### Phase 1a: Components (✅ COMPLETE)

**What**: Foundation components for intelligent orchestration
**When**: October 16, 2025
**Duration**: ~10 hours (1 day)

**Components Built**:
1. State Manager - Session persistence
2. Decision Maker - Intelligent decisions
3. Prompt Refiner - Context injection
4. Vision API (Mock) - UI validation
5. Metrics Tracker - Analytics

**Deliverables**:
- 5 bash libraries (~2,700 LOC)
- 5 test suites (62 tests, 100% passing)
- 5 documentation files (~4,000+ lines)

**Status**: ✅ Complete and production-ready

---

### Phase 1b: Full Automation (✅ COMPLETE)

**What**: Remove all manual steps, enable true autonomous execution
**When**: October 16, 2025 (same day as Phase 1a)
**Duration**: ~1 hour

**Additions**:
- Automatic agent launch via Task tool
- Automatic validation via SlashCommand
- True retry loop (no manual restart)
- Real validation data parsing

**Benefits**:
- 10x faster testing and iteration
- Zero manual steps during execution
- Real Playwright/console/network data
- Consistent, reliable execution

**Deliverables**:
- Updated `orchestrate.md` command (~250 lines changed)
- `PHASE-1B-COMPLETE.md` documentation
- Full automation of Phase 1a components

**Status**: ✅ Complete and production-ready

---

### Phase 2: Feature Workflow Engine (🔨 NEXT)

**What**: Integrate SpecSwarm commands to execute full feature lifecycle
**When**: Next implementation phase
**Duration**: 2-3 weeks estimated

**Goal**: Transform from "execute pre-written workflow.md" to "execute full feature from description"

**Architecture**:
```
User: /speclabs:orchestrate-feature "Add user authentication"

↓
Feature Orchestrator:
1. Run /specswarm:specify
   → Generates spec.md

2. Run /specswarm:clarify
   → Asks questions, updates spec.md

3. Run /specswarm:plan
   → Generates plan.md with design

4. Run /specswarm:tasks
   → Generates tasks.md with task list

5. FOR EACH TASK in tasks.md:
   → Convert task to workflow.md
   → Run /speclabs:orchestrate workflow.md project/  ← Uses Phase 1b!
   → Validate with /speclabs:orchestrate-validate
   → Continue to next task

6. Run /specswarm:bugfix (if issues found)
   → Fix bugs with regression tests

7. Run /specswarm:refactor (if needed)
   → Improve code quality

8. Feature complete!
```

**Components to Build**:
1. **Feature Orchestrator Script** - Coordinates SpecSwarm → SpecLabs flow
2. **Task Converter** - Transforms SpecSwarm task → workflow.md
3. **SpecSwarm Command Bridge** - Executes SpecSwarm slash commands
4. **Feature State Manager** - Tracks feature-level progress
5. **Multi-Task Coordinator** - Manages task dependencies

**New Command**: `/speclabs:orchestrate-feature <feature-description> <project-path>`

**Example**:
```bash
/speclabs:orchestrate-feature "Add user authentication with signup and signin" /path/to/project

# Automatically:
# 1. Runs /specswarm:specify → spec.md
# 2. Runs /specswarm:clarify → updates spec
# 3. Runs /specswarm:plan → plan.md
# 4. Runs /specswarm:tasks → tasks.md (5 tasks)
# 5. For each of 5 tasks:
#    - Converts to workflow.md
#    - Runs /speclabs:orchestrate workflow.md project/
#    - Validates results
# 6. Feature complete!
```

**Benefits**:
- No manual workflow.md writing
- Full SpecSwarm workflow integration
- Single feature, end-to-end automation
- Still has Phase 1b's retry logic per task

**Deliverables**:
- `feature-orchestrator.sh`
- `task-converter.sh`
- `/speclabs:orchestrate-feature` command
- Integration tests
- Documentation

**Success Criteria**:
- Execute complete feature from description
- All SpecSwarm commands run automatically
- Phase 1b task executor handles each task
- Feature completes with all tasks done
- Can handle bugfix and refactor cycles

---

### Phase 3: Sprint Orchestrator (🚀 FUTURE)

**What**: Coordinate multiple features across a sprint
**When**: After Phase 2 is stable
**Duration**: 3-4 weeks estimated

**Goal**: Handle multiple features with dependencies and parallel execution

**Architecture**:
```
User: /speclabs:orchestrate-sprint "Build e-commerce checkout flow"

↓
Sprint Orchestrator:
1. Analyze sprint goal
2. Break into features (3-5 features)
   - Feature 1: Product catalog
   - Feature 2: Shopping cart
   - Feature 3: Checkout form
   - Feature 4: Payment integration
   - Feature 5: Order confirmation

3. Analyze dependencies:
   - Cart depends on Catalog
   - Checkout depends on Cart
   - Payment depends on Checkout
   - Confirmation depends on Payment

4. FOR EACH FEATURE (in dependency order):
   → Run /speclabs:orchestrate-feature  ← Uses Phase 2!
   → Wait for completion
   → Validate integration with previous features
   → Continue to next feature

5. Sprint integration testing
6. Sprint complete!
```

**Components to Build**:
1. **Sprint Planner** - Breaks sprint goal into features
2. **Dependency Analyzer** - Detects feature dependencies
3. **Parallel Executor** - Runs independent features in parallel
4. **Integration Validator** - Tests feature interactions
5. **Sprint State Manager** - Tracks sprint-level progress

**New Command**: `/speclabs:orchestrate-sprint <sprint-goal> <project-path>`

**Example**:
```bash
/speclabs:orchestrate-sprint "Build e-commerce checkout" /path/to/project

# Automatically:
# 1. Breaks into 5 features
# 2. Runs Phase 2 for each feature:
#    - Feature 1: Product catalog (uses Phase 2)
#    - Feature 2: Shopping cart (uses Phase 2)
#    - Feature 3: Checkout form (uses Phase 2)
#    - Feature 4: Payment (uses Phase 2)
#    - Feature 5: Confirmation (uses Phase 2)
# 3. Each feature uses Phase 1b for tasks
# 4. Sprint complete!
```

**Advanced Features**:
- Parallel execution of independent features
- Dependency resolution
- Integration testing between features
- Sprint-level rollback if feature fails
- Sprint metrics and reporting

**Deliverables**:
- `sprint-orchestrator.sh`
- `dependency-analyzer.sh`
- `/speclabs:orchestrate-sprint` command
- Integration tests
- Sprint metrics dashboard
- Documentation

**Success Criteria**:
- Handle 3-5 features per sprint
- Respect feature dependencies
- Run independent features in parallel
- Validate feature integration
- Complete sprint end-to-end

---

## Current vs Future Capabilities

| Capability | Phase 1b (Current) | Phase 2 (Next) | Phase 3 (Future) |
|------------|-------------------|----------------|------------------|
| **Scope** | Single task | Single feature | Multiple features |
| **Input** | workflow.md file | Feature description | Sprint goal |
| **SpecSwarm Integration** | ❌ None | ✅ Full workflow | ✅ Multi-feature |
| **Task Generation** | ❌ Manual | ✅ Automatic | ✅ Automatic |
| **Retry Logic** | ✅ 3 attempts | ✅ Inherited | ✅ Inherited |
| **Validation** | ✅ Automatic | ✅ Automatic | ✅ Automatic + Integration |
| **Dependencies** | N/A | N/A (single feature) | ✅ Resolved |
| **Parallel Execution** | N/A | N/A | ✅ Independent features |
| **Output** | Task complete | Feature complete | Sprint complete |
| **User Time** | 0 min (fully auto) | 5-10 min (approval) | 15-30 min (checkpoints) |
| **Duration** | 2-5 min/task | 30-60 min/feature | 4-8 hours/sprint |

---

## Integration with SpecSwarm

### SpecSwarm Commands (Already Exist)

SpecSwarm is a **planning and design system**:

| Command | Purpose | Output |
|---------|---------|--------|
| `/specswarm:specify` | Create feature specification | `spec.md` |
| `/specswarm:clarify` | Ask clarification questions | Updated `spec.md` |
| `/specswarm:plan` | Generate design plan | `plan.md` |
| `/specswarm:tasks` | Generate implementation tasks | `tasks.md` |
| `/specswarm:implement` | Execute tasks (manual guidance) | Implementation |
| `/specswarm:checklist` | Generate verification checklist | `checklist.md` |
| `/specswarm:analyze` | Cross-artifact consistency check | Analysis report |
| `/specswarm:bugfix` | Fix bugs with regression tests | Bug fixes |
| `/specswarm:modify` | Modify feature | Updated feature |
| `/specswarm:refactor` | Improve code quality | Refactored code |

### SpecLabs Commands (Execution Engine)

SpecLabs is an **execution system**:

| Command | Purpose | Phase |
|---------|---------|-------|
| `/speclabs:orchestrate` | Execute task with retry | Phase 1b ✅ |
| `/speclabs:orchestrate-validate` | Validate implementation | Phase 1b ✅ |
| `/speclabs:orchestrate-feature` | Execute feature workflow | Phase 2 🔨 |
| `/speclabs:orchestrate-sprint` | Execute sprint | Phase 3 🚀 |

### The Integration (Phase 2)

**Current Workflow** (Manual):
```
Human: /specswarm:specify
Human: /specswarm:clarify
Human: /specswarm:plan
Human: /specswarm:tasks
Human: Manually writes workflow.md for each task
Human: /speclabs:orchestrate workflow.md project/  (for each task)
```

**Phase 2 Workflow** (Integrated):
```
Human: /speclabs:orchestrate-feature "Add user auth" project/

Automatically:
  ↓ /specswarm:specify
  ↓ /specswarm:clarify
  ↓ /specswarm:plan
  ↓ /specswarm:tasks
  ↓ FOR EACH TASK:
    ↓ Convert to workflow.md
    ↓ /speclabs:orchestrate workflow.md project/
    ↓ /speclabs:orchestrate-validate project/
  ↓ Feature complete!
```

**The Missing Link**: Phase 2 connects SpecSwarm (planning) with SpecLabs (execution)

---

## Roadmap Timeline

### ✅ Completed (October 16, 2025)

**Phase 1a: Components**
- State Manager ✅
- Decision Maker ✅
- Prompt Refiner ✅
- Vision API (Mock) ✅
- Metrics Tracker ✅
- **Duration**: ~10 hours
- **Status**: Production-ready

**Phase 1b: Full Automation**
- Automatic agent launch ✅
- Automatic validation ✅
- True retry loop ✅
- **Duration**: ~1 hour
- **Status**: Production-ready

---

### 🔨 In Progress / Next

**Phase 2: Feature Workflow Engine**
- **Start**: After planning/design
- **Duration**: 2-3 weeks estimated
- **Components**:
  - Feature orchestrator script
  - Task converter (SpecSwarm → workflow.md)
  - SpecSwarm command bridge
  - Feature state manager
  - Multi-task coordinator
- **Deliverable**: `/speclabs:orchestrate-feature` command
- **Blocker**: Need to design SpecSwarm integration approach

---

### 🚀 Future

**Phase 3: Sprint Orchestrator**
- **Start**: After Phase 2 is stable
- **Duration**: 3-4 weeks estimated
- **Components**:
  - Sprint planner
  - Dependency analyzer
  - Parallel executor
  - Integration validator
  - Sprint state manager
- **Deliverable**: `/speclabs:orchestrate-sprint` command

---

## Auto-Compact Recovery Guide

**If this conversation is auto-compacted, here's what you need to know:**

### Current State (as of October 16, 2025)

**What We Have**:
- ✅ Phase 1a: 5 components (State Manager, Decision Maker, Prompt Refiner, Vision API Mock, Metrics Tracker)
- ✅ Phase 1b: Full automation (automatic agent launch, validation, retry loop)
- ✅ `/speclabs:orchestrate` command - Executes single pre-written workflow.md with retry logic

**What We CAN Do**:
- Execute ONE task from a workflow.md file
- Automatically retry up to 3 times with refined prompts
- Automatically validate with Playwright, console, network checks
- Track all session state and metrics
- 10x faster than manual testing

**What We CANNOT Do (Yet)**:
- ❌ Create workflow.md files automatically
- ❌ Run SpecSwarm commands (specify, plan, tasks, etc.)
- ❌ Execute full feature lifecycle
- ❌ Handle multiple features in a sprint

---

### The Vision

**End Goal**: Sprint-level orchestration where you provide a sprint goal and the system:
1. Breaks it into features
2. For each feature: Runs specify → clarify → plan → tasks → implement
3. For each task: Uses Phase 1b to execute with retry logic
4. Validates integration between features
5. Reports sprint completion

**This is a 3-layer architecture**:
- **Layer 1 (Phase 1a/1b)**: Task executor with retry (✅ BUILT)
- **Layer 2 (Phase 2)**: Feature workflow engine (🔨 NEXT)
- **Layer 3 (Phase 3)**: Sprint orchestrator (🚀 FUTURE)

---

### Key Files to Read

**Current Implementation**:
- `docs/PHASE-1A-COMPLETE.md` - Phase 1a components overview
- `docs/PHASE-1B-COMPLETE.md` - Phase 1b automation details
- `docs/ORCHESTRATE-INTEGRATION-COMPLETE.md` - Integration guide
- `plugins/speclabs/commands/orchestrate.md` - The actual command

**Component Documentation**:
- `plugins/speclabs/lib/STATE-MANAGER-README.md`
- `plugins/speclabs/lib/DECISION-MAKER-README.md`
- `plugins/speclabs/lib/PROMPT-REFINER-README.md`

**Vision & Planning**:
- `docs/ORCHESTRATOR-ROADMAP.md` - This file (complete roadmap)
- `docs/PROJECT-ORCHESTRATOR-VISION.md` - Original big vision
- `docs/PHASE-1A-PLAN.md` - Phase 1a implementation plan

---

### What to Build Next

**Phase 2: Feature Workflow Engine**

**Core Question**: How do we connect SpecSwarm commands with SpecLabs orchestrate?

**Approach**:
1. Create `/speclabs:orchestrate-feature` command
2. For a feature description:
   - Run `/specswarm:specify` → get spec.md
   - Run `/specswarm:clarify` → update spec
   - Run `/specswarm:plan` → get plan.md
   - Run `/specswarm:tasks` → get tasks.md
3. For each task in tasks.md:
   - Convert task to workflow.md format
   - Run `/speclabs:orchestrate workflow.md project/`
   - Validate results
   - Continue to next task
4. Feature complete!

**Key Design Decision**: How to automatically invoke SpecSwarm slash commands?
- Option A: Use SlashCommand tool (like we do for orchestrate-validate)
- Option B: Source SpecSwarm command files and execute them
- Option C: Create a bridge script that coordinates between systems

---

### Success Criteria

**Phase 1a/1b** (✅ COMPLETE):
- Execute single task with retry logic
- 10x faster than manual
- Zero manual steps
- Real validation data

**Phase 2** (🔨 NEXT):
- Execute full feature from description
- All SpecSwarm commands run automatically
- No manual workflow.md writing
- Feature complete with all tasks done

**Phase 3** (🚀 FUTURE):
- Execute multiple features in a sprint
- Handle dependencies between features
- Run independent features in parallel
- Sprint complete with all features done

---

## Summary

### The Journey

```
Phase 1a (DONE) → Build intelligent components
Phase 1b (DONE) → Add full automation
Phase 2 (NEXT)  → Integrate SpecSwarm workflow
Phase 3 (FUTURE)→ Multi-feature sprint orchestration
```

### Current Capabilities

**We have a production-ready TASK EXECUTOR** that:
- Takes a pre-written workflow.md
- Executes the task automatically
- Validates results automatically
- Retries intelligently up to 3 times
- Tracks all metrics

**We DO NOT have** (yet):
- Feature-level orchestration
- SpecSwarm integration
- Sprint-level coordination

### The Gap

**Missing Link**: Phase 2 - Convert SpecSwarm's planning outputs (spec, plan, tasks) into workflow.md files that Phase 1b can execute.

Once we have Phase 2, we'll have **full feature-level orchestration**.
Once we have Phase 3, we'll have **full sprint-level orchestration**.

---

**Document Created**: October 16, 2025
**Last Updated**: October 16, 2025
**Status**: Living document - update as phases progress
**Audience**: Future Claude (after auto-compact) or team members

**Related Documents**:
- [Phase 1a Complete](./PHASE-1A-COMPLETE.md)
- [Phase 1b Complete](./PHASE-1B-COMPLETE.md)
- [Integration Complete](./ORCHESTRATE-INTEGRATION-COMPLETE.md)
- [Project Vision](./PROJECT-ORCHESTRATOR-VISION.md)
- [Phase 1a Plan](./PHASE-1A-PLAN.md)
