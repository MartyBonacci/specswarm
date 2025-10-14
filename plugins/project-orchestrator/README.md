# Project Orchestrator Plugin for Claude Code

**⚠️ EXPERIMENTAL - Phase 0: Research & De-Risk**

**Version**: 0.1.0-alpha.1
**Status**: Proof of Concept

---

## What is Project Orchestrator?

Project Orchestrator is an autonomous development system that coordinates multiple Claude Code agents to build features and projects with minimal human intervention.

**Vision**: "Give me a feature description Monday evening, wake up Tuesday morning with working, tested, production-ready code."

**Current Status**: Phase 0 POC - validating core technical architecture

---

## 🎯 Phase 0 Goals

Phase 0 is a 3-5 day validation phase to answer key questions:

1. ✅ **Day 1 (DONE)**: Can agents work across different project directories?
2. 🔄 **Day 2-3**: Can agents implement features successfully?
3. 🔄 **Day 2-3**: Does Playwright browser validation work?
4. 🔄 **Day 4-5**: Can we orchestrate end-to-end (prompt → agent → validate)?

**Success Criteria**:
- Agents complete simple tasks in target projects
- Validation suite catches issues
- Prompts are effective (agent understands and completes)
- Faster than manual development

---

## 🚀 Architecture

### Single-Instance Approach

**Key Insight**: We don't need separate Claude Code instances communicating!

```
┌─────────────────────────────────────┐
│ ORCHESTRATOR (You)                  │
│ Working directory: specswarm         │
│                                      │
│ Strategic Role:                      │
│ - Plans features                     │
│ - Generates prompts                  │
│ - Validates results                  │
│ - Makes decisions                    │
└────────┬────────────────────────────┘
         │
         ├──> Launch Agent 1 (Task tool)
         │    ┌─────────────────────────┐
         │    │ EXECUTOR AGENT          │
         │    │ Working directory:      │
         │    │ tweeter-spectest        │
         │    │                         │
         │    │ Tactical Role:          │
         │    │ - Implements feature    │
         │    │ - Writes code           │
         │    │ - Reports completion    │
         │    └─────────────────────────┘
         │
         └──> Validation Suite
              ┌─────────────────────────┐
              │ - Playwright browser    │
              │ - Claude Vision API     │
              │ - Terminal monitoring   │
              └─────────────────────────┘
```

**Benefits**:
- ✅ Native Task tool integration (no bridge needed)
- ✅ Simple architecture
- ✅ Fresh context for each agent (role separation preserved)
- ✅ Parallel execution possible (future)

---

## 📦 Installation

```bash
# From specswarm directory
claude plugin install /home/marty/code-projects/specswarm/plugins/project-orchestrator
```

Or if you're already in the specswarm project:

```bash
claude plugin install ./plugins/project-orchestrator
```

---

## 🎯 Commands (Phase 0)

### `/project-orchestrator:orchestrate-validate`

Run validation suite on target project.

**Usage**:
```bash
/project-orchestrator:orchestrate-validate <project-path> [url]
```

**Example**:
```bash
# Validate tweeter-spectest (default URL: http://localhost:5173)
/project-orchestrator:orchestrate-validate /home/marty/code-projects/tweeter-spectest

# Validate with custom URL
/project-orchestrator:orchestrate-validate /home/marty/code-projects/tweeter-spectest http://localhost:3000
```

**What it does**:
1. Checks if dev server is running
2. Launches Playwright browser automation
3. Navigates to app
4. Captures console errors
5. Captures network errors
6. Takes screenshot
7. Generates validation report

**Output**:
- Console error report
- Network error report
- Screenshot: `/tmp/orchestrator-validation-screenshot.png`
- Full results: `/tmp/orchestrator-validation-results.json`

---

### `/project-orchestrator:orchestrate-test`

Run full test orchestration workflow with agent execution.

**Usage**:
```bash
/project-orchestrator:orchestrate-test <test-workflow-file> <project-path>
```

**Example**:
```bash
/project-orchestrator:orchestrate-test features/001-fix-vite-config/test-workflow.md /home/marty/code-projects/tweeter-spectest
```

**What it does**:
1. Parses test workflow specification
2. Generates comprehensive prompt for agent
3. Launches agent via Task tool to implement changes
4. Agent works autonomously in target project
5. Prompts to run validation suite
6. Generates orchestration report

**Test Workflow Format**:
See `templates/test-workflow-template.md` for format.

---

## 📝 Creating Test Workflows

Use the template to create test workflows:

```bash
cp plugins/project-orchestrator/templates/test-workflow-template.md features/001-my-test/test-workflow.md
```

Then fill in:
- **Description**: What needs to be done
- **Files to Modify**: List of files
- **Changes Required**: Detailed instructions
- **Expected Outcome**: What should work
- **Validation Criteria**: Checklist to verify
- **Test URL**: Where to test

---

## 🧪 Phase 0 Testing Guide

### Test 1: Validation Only

**Goal**: Verify Playwright browser automation works

**Steps**:
1. Start tweeter-spectest dev server:
   ```bash
   cd /home/marty/code-projects/tweeter-spectest
   npm run dev
   ```

2. Run validation:
   ```bash
   /project-orchestrator:orchestrate-validate /home/marty/code-projects/tweeter-spectest
   ```

3. Review results:
   - Check console output for errors
   - View screenshot: `/tmp/orchestrator-validation-screenshot.png`
   - Review JSON: `/tmp/orchestrator-validation-results.json`

**Success**: ✅ Validation runs, screenshot captured, errors reported

---

### Test 2: Simple Bug Fix

**Goal**: Validate end-to-end orchestration

**Scenario**: Fix a simple bug in tweeter-spectest

**Steps**:
1. Create test workflow:
   ```bash
   mkdir -p features/001-test-orchestrator-poc
   cp plugins/project-orchestrator/templates/test-workflow-template.md features/001-test-orchestrator-poc/test-workflow.md
   ```

2. Edit test workflow with simple task (e.g., fix missing config file)

3. Run orchestration:
   ```bash
   /project-orchestrator:orchestrate-test features/001-test-orchestrator-poc/test-workflow.md /home/marty/code-projects/tweeter-spectest
   ```

4. Observe:
   - Prompt generation
   - Agent execution (Task tool)
   - Agent's work in target project

5. Run validation:
   ```bash
   /project-orchestrator:orchestrate-validate /home/marty/code-projects/tweeter-spectest
   ```

6. Document results:
   - Did agent understand task?
   - Did agent complete successfully?
   - Did validation pass?
   - Time taken vs manual estimate?

**Success**: ✅ Agent completes task, validation passes, faster than manual

---

## 📊 Phase 0 Metrics to Track

For each test, document:

| Metric | Value |
|--------|-------|
| Agent Understanding | Yes/No |
| First-Try Success | Yes/No |
| Iteration Count | 1, 2, 3+ |
| Time to Complete | Xm |
| Manual Estimate | Xm |
| Time Savings | X% |
| Quality Score | 1-10 |
| Validation Pass | Yes/No |

---

## 🎓 Learnings from Test 4A

Project Orchestrator is built on learnings from Test 4A:

**Key Insights**:
1. **Real Over Artificial**: Test on real projects, not toy examples
2. **Small Batches**: 4-6 hour chunks work best
3. **Fast Feedback**: Validate frequently, catch issues early
4. **Vertical Slices**: Work in end-to-end features, not layers
5. **Adaptive Sizing**: Match batch size to confidence level

**What Test 4A Proved**:
- All technical pieces exist
- Multi-layer validation works (Playwright + Vision + Terminal)
- Small batches + fast feedback = success
- Real bugs found: 6x better than artificial tests

---

## 🚧 Phase 0 Limitations

**Current Constraints**:
- Manual visual analysis (not automated Claude Vision yet)
- Basic error detection only
- Single URL validation
- No retry logic
- No metrics persistence
- No decision-making logic

**Phase 1 Will Add**:
- Automated Claude Vision API integration
- Multi-step user flow validation
- Retry logic with prompt refinement
- Decision maker (continue/retry/escalate)
- Metrics tracking in `/memory/`
- Human escalation handling

---

## 📈 Roadmap

### Phase 0: Research & De-Risk (Week 1)
- [x] Validate agent cross-directory access
- [ ] Test agent implementation
- [ ] Test Playwright validation
- [ ] Build end-to-end POC
- **Decision**: Proceed to Phase 1 or iterate

### Phase 1a: Test Orchestrator Foundation (Month 1)
- Test workflow parser
- Prompt generator
- Agent launcher
- Validation coordinator
- State manager
- **Deliverable**: Test Orchestrator CLI

### Phase 1b: Real-World Validation (Month 2)
- Dogfooding on real tests
- Alpha testing with users
- Metrics collection
- **Decision**: Continue or pivot

### Phase 2a: Prompt Generation Core (Months 3-4)
- Intent analyzer
- Context gatherer
- Pattern library
- Prompt validator
- **Deliverable**: Dynamic prompt generation

### Phase 2b: Single-Sprint Projects (Month 5)
- Feature planner
- Sequential execution
- **Deliverable**: Build small features autonomously

### Phase 3a: Multi-Sprint Coordination (Months 6-7)
- Sprint coordinator
- Dependency manager
- Overnight execution
- **Deliverable**: Build complete projects

### Phase 3b: Production Polish (Month 8)
- CLI improvements
- Documentation
- Beta testing
- **Deliverable**: v1.0 release

**Total Timeline**: 8-11 months from Phase 0 to public launch

---

## 🤝 Contributing

This is an experimental Phase 0 POC. Feedback is critical!

**After testing, please document**:
- What worked?
- What didn't work?
- What was surprising?
- What should we improve?
- Should we proceed to Phase 1?

---

## 📜 License

MIT License

**Attribution**:
- Methodology inspired by Test 4A results
- Built on Claude Code plugin system
- Created by Marty Bonacci & Claude Code (2025)

---

## 🔗 Related Documentation

- [PROJECT-ORCHESTRATOR-PLAN.md](../../docs/PROJECT-ORCHESTRATOR-PLAN.md) - Full strategic plan
- [PROJECT-ORCHESTRATOR-VISION.md](../../docs/PROJECT-ORCHESTRATOR-VISION.md) - Vision and philosophy
- [BATCH-SIZING-STRATEGY.md](../../docs/BATCH-SIZING-STRATEGY.md) - Optimal work sizing
- [Test 4A Results](../../docs/testing/test-4a-speclab.md) - Validation that this works

---

**Remember**: Phase 0 is about validation, not perfection. The goal is to answer: "Does this approach work?" 🚀
