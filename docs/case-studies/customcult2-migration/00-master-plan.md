# SpecSwarm Plugin Testing + CustomCult2 Modernization Plan
## Strategy: Rapid Iteration with Shared Context (Option 4)

**Created**: 2025-10-23
**Status**: Active
**Duration Estimate**: 44-62 hours (5.5-8 working days)

---

## Overview

Use CustomCult2 migration as real-world test case with **tight feedback loop** between two Claude Code instances:
- **Instance A (SpecSwarm)**: Plugin developer - reads feedback, fixes issues immediately
- **Instance B (CustomCult2)**: Plugin user - executes commands, documents issues as they happen

**Key Innovation**: Fix plugin issues within minutes/hours, not after completing phases, maximizing learning velocity.

---

## Projects Overview

### SpecSwarm Project
- **Location**: `/home/marty/code-projects/specswarm`
- **Purpose**: Plugin marketplace for spec-driven development
- **Plugins**: SpecSwarm v2.0.0 (18 commands), SpecLabs v2.0.0 (4 commands)
- **Status**: Production-ready (SpecSwarm), Experimental (SpecLabs Phase 2 complete)

### CustomCult2 Project
- **Location**: `/home/marty/code-projects/customcult2`
- **Purpose**: Algorithm-driven custom snowboard design platform
- **Current Stack**: PHP 7.2, Laravel 5.8, React 16.8, Redux, Three.js 0.110, Laravel Mix
- **Target Stack**: PHP 8.3+, Laravel 11.x, React 18.x, React Router v7, Three.js latest, Vite

---

## Workflow Process

### Instance Switching Protocol

**Instance B → Instance A (When to switch)**
- ⚠️ Hit an error or confusion
- 🤔 Unexpected behavior
- 🐛 Found a bug in plugin
- ⏰ Every 2-3 completed commands (checkpoint)

**Instance A → Instance B (When to switch)**
- ✅ Fix implemented and tested
- 📦 Next task package prepared
- 🔄 Ready to continue migration work

### Daily Rhythm Example

**Morning (9 AM - 12 PM)**
```
Instance B: Execute 2-3 plugin commands
  → Document issues in feedback-live.md
  → SWITCH
Instance A: Fix 3-5 issues
  → Update improvements-log.md
  → SWITCH
Instance B: Re-test with improvements
  → Continue migration work
```

**Afternoon (1 PM - 5 PM)**
```
Instance B: More migration tasks
  → Fewer issues (plugins improving!)
  → SWITCH (checkpoint)
Instance A: Review metrics
  → Plan next phase
  → Prepare task packages
```

---

## Complete Migration Roadmap

### Phase 1: Setup & First Test (Day 1)
- ✅ File structure created
- ✅ First plugin test (specify workflow)
- ✅ First improvement cycle complete
- ✅ Process validated

**Deliverables**:
- All templates and tracking files
- Task Package TP-001 completed
- First improvements documented
- Workflow proven

### Phase 2: Core Plugin Testing (Days 2-3)
**Test Cases**:
- TP-002: Test plan workflow
- TP-003: Test tasks workflow
- TP-004: Test implement workflow
- TP-005: Test bugfix workflow
- TP-006: Test analyze-quality
- TP-007: Test complete workflow

**Goal**: All SpecSwarm core commands tested and improved

**Deliverables**:
- 6 task packages completed
- 15-20 plugin improvements documented
- Workflow refinements identified
- Core command quality validated

### Phase 3: PHP & Laravel Upgrades (Days 3-6)
**Migration Tasks**:
- TP-008: PHP 7.2 → 8.3 upgrade
- TP-009: Laravel 5.8 → 6.x
- TP-010: Laravel 6.x → 7.x
- TP-011: Laravel 7.x → 8.x
- TP-012: Laravel 8.x → 9.x
- TP-013: Laravel 9.x → 10.x
- TP-014: Laravel 10.x → 11.x

**Using**: Improved SpecSwarm workflows from Phase 2

**Deliverables**:
- PHP 8.3 running without errors
- Laravel 11.x fully functional
- All critical features working (ThreeDMod.php calculations, API routes, Passport auth)
- Migration patterns documented

### Phase 4: SpecLabs Autonomous Testing (Days 6-7)
**Test Cases**:
- TP-015: Test orchestrate-feature (simple feature)
- TP-016: Test orchestrate workflow (task automation)
- TP-017: Test orchestrate-validate (validation suite)
- TP-018: Complex multi-task feature (stress test)

**Goal**: Validate autonomous development capabilities

**Deliverables**:
- SpecLabs tested in real-world scenario
- Autonomous execution patterns validated
- Retry logic effectiveness measured
- Phase 2 feature engine validated

### Phase 5: Frontend Modernization (Days 7-9)
**Migration Tasks**:
- TP-019: React 16.8 → 18.x
- TP-020: Redux → React Router v7 loaders/actions
- TP-021: Three.js 0.110 → latest (with 3D rendering validation)
- TP-022: Laravel Mix → Vite
- TP-023 (Optional): Bootstrap → Tailwind evaluation

**Using**: Battle-tested SpecSwarm + emerging SpecLabs patterns

**Deliverables**:
- React 18.x with React Router v7
- Redux removed, server-side state management
- Three.js latest with working 3D board visualization
- Vite build system operational
- Improved bundle size and performance

### Phase 6: Final Validation & Documentation (Day 10)
**Tasks**:
- Complete quality analysis (baseline vs. final)
- Performance benchmarks
- Feature validation (all critical flows)
- Final case study write-up
- Plugin improvements summary

**Deliverables**:
- Comprehensive case study document
- 30+ plugin improvements documented
- Performance metrics comparison
- Recommendations for future work

---

## Success Metrics

### Plugin Improvement Metrics
- ⏱️ **Mean Time To Fix (MTTF)**: Target <30 minutes per issue
- ✅ **Fix Success Rate**: Target >80% fixes work first try
- 📊 **Issue Density**: Should decrease over time (fewer issues per command)
- 🚀 **Improvement Velocity**: Should accelerate (faster fixes as we learn)
- 📝 **Total Improvements**: Target 30+ documented improvements

### Migration Progress Metrics
- 📦 **Dependencies Updated**: PHP 7.2→8.3, Laravel 5.8→11, React 16.8→18, Three.js 0.110→latest
- ✅ **Features Working**:
  - 3D board rendering with Three.js
  - Designer algorithm calculations (ThreeDMod.php)
  - Progressive input system
  - Graphic upload to S3
  - Share/purchase flows
  - All API routes functional
- 📈 **Quality Score**: Baseline vs. final comparison
- ⚡ **Performance**:
  - Bundle size reduction (target: 30%+)
  - Initial load time improvement
  - 3D rendering performance

### Learning Metrics
- 📝 **Documented Improvements**: Target 30+ improvements with rationale
- 🎯 **Workflow Refinements**: New patterns discovered
- 📚 **Case Study Completeness**: Comprehensive final documentation
- 🔄 **Reusable Patterns**: Migration strategies for future projects

---

## Risk Mitigation

### Technical Risks

**If Instance B blocks on an issue:**
- Document blocking issue clearly
- Switch to Instance A for fix
- If fix takes >1 hour, prepare alternative task
- Resume when fix ready

**If migrations break CustomCult2:**
- Git revert to last working state
- Analyze what went wrong in feedback-live.md
- Fix plugin recommendations
- Retry with improved guidance
- Document as learning opportunity

**If plugins need major rework:**
- Pause migration work
- Focus on plugin improvement
- Resume migration when stable
- Document decision and timeline impact

**If 3D rendering breaks (Three.js upgrade):**
- This is critical feature - highest priority
- Dedicated debugging session
- Test with simple scene first
- Validate geometry, materials, textures separately
- Document Three.js API changes

**If ThreeDMod.php calculations change:**
- Validation suite for algorithm accuracy
- Test with known input/output pairs
- Compare old vs. new results
- Cannot proceed if algorithms drift

### Process Risks

**If feedback loop breaks:**
- Use checkpoint system (every 2-3 commands)
- Set timer reminders if needed
- Keep feedback-live.md always open

**If losing context between sessions:**
- Always end session with clear "Resume Here" note
- Read last 3 entries in improvements-log.md before starting
- Review metrics.md for current state

**If timeline extends beyond estimate:**
- Prioritize critical upgrades (PHP, Laravel, React)
- Defer optional improvements (Bootstrap→Tailwind)
- Document deferred work for future

---

## File Structure Reference

```
~/code-projects/specswarm/docs/case-studies/customcult2-migration/
├── 00-master-plan.md           # This document
├── feedback-live.md            # Active feedback scratchpad
├── improvements-log.md         # Append-only improvement record
├── metrics.md                  # Performance tracking dashboard
├── session-archive/            # Completed session summaries
│   ├── session-001-setup.md
│   ├── session-002-specify-test.md
│   └── ...
├── task-packages/              # Ready-to-execute tasks
│   ├── TP-001-test-specify.md
│   ├── TP-002-test-plan.md
│   └── ...
└── templates/
    ├── feedback-template.md
    ├── task-package-template.md
    └── session-summary-template.md

~/code-projects/customcult2/.migration/
├── plan.md                     # Simplified migration reference
├── current-task.md             # Link/reference to active task
└── quick-reference.md          # Common commands and shortcuts
```

---

## Key Principles

1. **Tight Feedback Loop**: Fix issues within minutes/hours, not days
2. **Real-World Testing**: Every plugin improvement tested immediately
3. **Continuous Documentation**: Capture everything in shared files
4. **Measurable Progress**: Track metrics for both plugin improvement and migration progress
5. **Safe Iteration**: Git commits, rollback capability, incremental changes
6. **Learning Focus**: Migration success AND plugin improvement equally important

---

## Next Steps

After setup completion:
1. ✅ Review all created files and templates
2. ✅ Open Claude Code in `~/code-projects/customcult2` (Instance B)
3. ✅ Read Task Package TP-001
4. ✅ Execute first plugin command: `/specswarm:specify`
5. ✅ Document experience in feedback-live.md
6. ✅ Switch back to Instance A with findings
7. ✅ Begin first improvement cycle

---

**This is a living document. Update as we learn and adapt the process.**
