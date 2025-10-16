# SpecLabs v1.0.0

**Experimental Laboratory for Autonomous Development & Advanced Debugging**

⚠️ **EXPERIMENTAL** - Features in active development - Use at your own risk

---

## Overview

SpecLabs is the experimental wing of the SpecSwarm ecosystem, providing cutting-edge features for autonomous development workflows and advanced systematic debugging. This plugin consolidates experimental capabilities that are too early-stage for production inclusion in SpecSwarm.

**Philosophy**: Rapid innovation → Real-world testing → Production graduation

**Current Status**: Phase 0 - Research & De-Risk

---

## Why SpecLabs Exists

**Clear Separation**:
- **SpecSwarm** = Production-ready, stable, proven features
- **SpecLabs** = Experimental, high-risk, rapid iteration

**Benefits**:
✅ Isolated risk - Bugs don't affect SpecSwarm stability
✅ Clear signal - Separate plugin indicates experimental status
✅ Safe iteration - Rapid development without stability concerns
✅ Easy graduation - Features move to SpecSwarm when proven stable
✅ Natural pairing - Debugging + orchestration work together

---

## Commands (3)

### 🤖 Autonomous Development

#### `/speclabs:orchestrate-test`
**Automated test workflow with agent execution and validation**

Execute autonomous development tasks using multi-agent coordination.

**Usage**:
```bash
/speclabs:orchestrate-test <test-workflow-file> <project-path>
```

**Example**:
```bash
/speclabs:orchestrate-test features/001-fix-bug/test-workflow.md /home/marty/code-projects/my-app
```

**What it does**:
1. Parses test workflow specification
2. Generates comprehensive agent prompt
3. Launches autonomous agent in target project
4. Agent executes task independently
5. Validation suite ready for verification

**Test Workflow Format**:
```markdown
# Test: [Task Name]

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

**Phase 0 Limitations**:
- Single task execution only
- Basic error handling
- Manual validation required
- No retry logic yet

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

**What it does**:
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

**Phase 0 Limitations**:
- Manual visual analysis (use Read tool on screenshot)
- Single URL validation only
- No multi-step user flows yet
- Basic error detection

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

**What it does**:

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

**Design Philosophy**:
1. **Systematic Over Random** - Structured phases prevent random debugging
2. **Logging First** - Add instrumentation before making changes
3. **Parallel When Possible** - 3+ bugs → orchestrate for efficiency
4. **Document Everything** - Create audit trail for learnings
5. **Verify Thoroughly** - Checklists ensure nothing missed

---

## Integration with SpecSwarm

SpecSwarm can suggest SpecLabs features when appropriate:

### Complex Bugs
```bash
# When bugfix detects chain bugs
/specswarm:bugfix "Multiple related issues found"
→ Suggestion: "Consider /speclabs:coordinate for systematic multi-bug analysis"
```

### Autonomous Mode
```bash
# When implementing large features
/specswarm:implement
→ Suggestion: "Try /speclabs:orchestrate-test for autonomous execution"
```

**Workflow Pattern**:
```
SpecSwarm (specify → plan → tasks)
    ↓
SpecLabs (orchestrate-test) - Autonomous execution
    ↓
SpecLabs (orchestrate-validate) - Automated verification
    ↓
SpecSwarm (analyze-quality) - Production validation
```

---

## Phase 0 Status

### Current Capabilities

**Autonomous Development**:
- ✅ Task workflow parsing
- ✅ Comprehensive prompt generation
- ✅ Multi-agent coordination
- ✅ Browser automation (Playwright)
- ✅ Console/network error capture
- ✅ Screenshot capture

**Advanced Debugging**:
- ✅ Multi-bug problem analysis
- ✅ Strategy determination (sequential vs orchestrated)
- ✅ Logging strategy generation
- ✅ Analysis templates
- ✅ Orchestration planning (3+ bugs)
- ✅ Verification checklists

### Known Limitations

**Autonomous Development**:
- ❌ No retry logic on failures
- ❌ Manual visual analysis required
- ❌ Single task execution only
- ❌ No multi-step user flows
- ❌ Limited error recovery

**Advanced Debugging**:
- ❌ Manual logging implementation (not automated)
- ❌ No automated log analysis
- ❌ Manual orchestration execution
- ❌ No metrics persistence

### Expected Bug Rate

**Phase 0 Reality**: Expect bugs and rough edges!

- Agent execution may fail unpredictably
- Validation may miss subtle issues
- Orchestration plans require manual refinement
- Error handling is basic
- Edge cases not covered

**This is intentional** - Phase 0 is about learning and de-risking before broader rollout.

---

## Development Roadmap

### Phase 1 (Planned)
- Automated Claude Vision API integration for visual analysis
- Retry logic with prompt refinement
- Decision maker (continue/retry/escalate)
- Human escalation handling
- Metrics persistence to `/memory/`
- Multi-step user flow validation

### Phase 2 (Future)
- Multiple test workflow support
- Parallel agent execution
- Automated log analysis
- Integration test generation
- Performance regression detection
- Chain bug auto-detection

### Graduation to SpecSwarm
**When features are proven stable** (high success rate, low bug count, real-world validation):
- Move commands to SpecSwarm
- Update documentation
- Maintain SpecLabs for next experiments

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

## Best Practices

### Autonomous Development

1. **Write Clear Workflows**
   - Be specific about changes required
   - List all files to modify
   - Define clear validation criteria
   - Provide expected outcomes

2. **Review Agent Work**
   - Don't blindly trust agent output
   - Verify changes make sense
   - Test thoroughly before committing
   - Watch for unintended modifications

3. **Start Small**
   - Begin with simple tasks
   - Build confidence gradually
   - Learn agent capabilities/limitations
   - Expand scope as you gain experience

### Advanced Debugging

1. **Be Specific in Problem Descriptions**
   ```bash
   # Good
   /speclabs:coordinate "Login button doesn't respond, password reset email fails, session expires immediately"

   # Too vague
   /speclabs:coordinate "Auth is broken"
   ```

2. **Follow the Phases**
   - Don't skip logging strategy
   - Capture evidence systematically
   - Document root causes thoroughly
   - Use orchestration for 3+ bugs

3. **Use Debug Sessions**
   - Archive sessions for learning
   - Review patterns across sessions
   - Improve logging strategies over time
   - Build debugging playbooks

---

## Examples

### Example 1: Autonomous Bug Fix

```bash
# 1. Create test workflow
cat > features/001-navbar-fix/test-workflow.md <<'EOF'
# Test: Fix Navbar Update After Sign-In

## Description
Navbar doesn't update to show user info after successful sign-in

## Files to Modify
- app/components/Navbar.tsx
- app/routes/_index.tsx

## Changes Required
1. Add user data to loader in _index.tsx
2. Update Navbar to re-render on user change
3. Ensure proper cache invalidation

## Expected Outcome
After sign-in, navbar immediately shows username and logout button

## Validation
- [ ] Navbar shows username after sign-in
- [ ] Logout button appears
- [ ] No console errors
- [ ] No full page refresh required
EOF

# 2. Execute autonomous fix
/speclabs:orchestrate-test features/001-navbar-fix/test-workflow.md /home/marty/my-app

# 3. Validate results
/speclabs:orchestrate-validate /home/marty/my-app

# 4. Review screenshot
Read /tmp/orchestrator-validation-screenshot.png

# 5. If successful, run production quality validation
/specswarm:analyze-quality
```

### Example 2: Multi-Bug Debugging

```bash
# 1. Start systematic debugging
/speclabs:coordinate "navbar not updating, sign-out broken, like button blank page"

# Creates:
# .debug-sessions/20251015-143500/
#   ├── problem-description.md (3 issues identified)
#   ├── logging-strategy.md (template)
#   └── ...

# 2. Fill in logging strategy
# [Edit logging-strategy.md to identify suspected files and logging points]

# 3. Implement logging
# [Add console.log statements as specified]

# 4. Run app and reproduce issues
# [Capture logs]

# 5. Analyze and fill in analysis template
# [Document root causes]

# 6. Review orchestration plan
# [Created automatically for 3+ bugs]

# 7. Execute fixes (manual or orchestrated)

# 8. Verify with checklist
# [Complete verification-checklist.md]
```

---

## Troubleshooting

### Orchestrate-Test Fails

**Agent doesn't understand task**:
- Make workflow description more specific
- List exact file paths to modify
- Provide code examples in workflow
- Break into smaller tasks

**Agent makes wrong changes**:
- Review workflow clarity
- Check if files exist at specified paths
- Verify project is in correct state
- Consider manual implementation

**Validation fails**:
- Check dev server is running
- Verify URL is correct
- Review screenshot for visual issues
- Check validation results JSON

### Orchestrate-Validate Fails

**Dev server not running**:
```bash
cd /path/to/project
npm run dev
```

**Playwright installation fails**:
```bash
cd /path/to/project
npm install --save-dev playwright
npx playwright install
```

**Browser can't navigate**:
- Check URL is accessible in browser manually
- Ensure no authentication required
- Verify no blocking errors

### Coordinate Issues

**Debug session not created**:
- Ensure you're in a git repository
- Check write permissions
- Verify problem description provided

**Strategy incorrect**:
- Manually adjust if needed
- Edit problem-description.md
- Choose sequential or orchestrated based on context

---

## Learning Resources

### Based on Real Learnings

SpecLabs workflows are built from real-world debugging experiences:

**Debug Coordinate**:
- Based on: `docs/learnings/2025-10-14-orchestrator-missed-opportunity.md`
- Lesson: Systematic investigation > random debugging

**Orchestrate-Test**:
- Based on: Test 4A results and orchestrator concept testing
- Lesson: Clear prompts + autonomous agents = time savings

### Recommended Reading

1. Read DEPRECATED.md files in merged plugins for context:
   - `plugins/debug-coordinate/DEPRECATED.md`
   - `plugins/project-orchestrator/DEPRECATED.md`

2. Review SpecSwarm integration points:
   - `plugins/specswarm/README.md` - Section: "Integration with SpecLabs"

3. Study workflow templates in debug sessions:
   - `.debug-sessions/*/logging-strategy.md`
   - `.debug-sessions/*/orchestration-plan.md`

---

## Contributing Feedback

**SpecLabs is experimental** - Your feedback drives improvements!

### Report Issues

When reporting bugs or unexpected behavior:

1. **What command?** (`/speclabs:coordinate`, etc.)
2. **What happened?** (actual behavior)
3. **What expected?** (desired behavior)
4. **Artifacts?** (debug session, screenshots, logs)
5. **Phase 0 context?** (understand experimental status)

### Suggest Enhancements

Ideas for Phase 1/2 improvements welcome:

- New validation types
- Better error recovery
- Smarter orchestration logic
- Additional automation
- Integration opportunities

---

## Consolidated From

SpecLabs v1.0.0 merges two deprecated plugins:

### debug-coordinate v1.0.0
**Advanced debugging workflows**
- Systematic multi-bug investigation
- Logging strategy generation
- Orchestration planning

### project-orchestrator v0.1.1
**Autonomous development**
- Test workflow execution
- Multi-agent coordination
- Browser validation

**Migration**: Replace `/debug-coordinate:` and `/project-orchestrator:` with `/speclabs:` in workflows.

See DEPRECATED.md files in those plugins for full migration details.

---

## License

MIT License - See LICENSE file for details

---

## Support

- **Repository**: https://github.com/MartyBonacci/specswarm
- **Issues**: https://github.com/MartyBonacci/specswarm/issues
- **Migration Guides**: See DEPRECATED.md in `debug-coordinate/` and `project-orchestrator/`

---

**SpecLabs v1.0.0** - Experimental Laboratory 🧪

Build autonomously. Debug systematically. Experiment boldly.
