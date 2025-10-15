# Debug Coordinate Plugin for Claude Code

**Version**: 1.0.0
**Purpose**: Systematic debugging coordination with logging, monitoring, and agent orchestration

---

## Overview

Debug Coordinate transforms chaotic multi-bug debugging into a systematic, orchestrated workflow.

**Based on learnings from**: [2025-10-14-orchestrator-missed-opportunity.md](../../docs/learnings/2025-10-14-orchestrator-missed-opportunity.md)

**Key Insight**: When debugging 3+ bugs, sequential investigation wastes time. Orchestrated parallel debugging can save 40-60% of time.

---

## When to Use This Plugin

Use `/debug:coordinate` when:
- ✅ Multiple distinct bugs (3+)
- ✅ Issues span multiple domains (backend, frontend, DB, etc.)
- ✅ Requires extensive logging to diagnose
- ✅ Need to correlate complex behavior
- ✅ Server restarts required during debugging

**Don't use for**:
- ❌ Single, simple bugs (use `/speclab:bugfix` instead)
- ❌ Well-understood issues
- ❌ Issues already diagnosed

---

## Installation

```bash
# From specswarm directory
claude plugin install ./plugins/debug-coordinate
```

Or from anywhere:
```bash
claude plugin install /path/to/specswarm/plugins/debug-coordinate
```

---

## Commands

### `/debug:coordinate <problem-description>`

Coordinate complex debugging workflows.

**Usage**:
```bash
/debug:coordinate "navbar not updating after sign-in, sign-out not working, like button blank page"
```

**What it does**:
1. **Discovery Phase**
   - Parses problem description
   - Identifies distinct issues
   - Creates debug session directory
   - Determines strategy (sequential vs orchestrated)

2. **Logging Strategy**
   - Generates logging plan template
   - Identifies files to instrument
   - Specifies what data to capture

3. **Analysis Phase**
   - Provides monitoring guidance
   - Creates analysis template
   - Helps correlate logs with root causes

4. **Orchestration Phase** (if 3+ bugs)
   - Generates orchestration plan
   - Assigns agents by domain
   - Coordinates parallel fixes

5. **Integration Phase**
   - Creates verification checklist
   - Ensures no regressions
   - Documents learnings

**Output**:
```
.debug-sessions/
└── YYYYMMDD-HHMMSS/
    ├── problem-description.md
    ├── logging-strategy.md
    ├── analysis-template.md
    ├── orchestration-plan.md (if orchestrated)
    ├── verification-checklist.md
    └── logs/
```

---

## Workflow Example

### Scenario: 5 Bugs Found After Manual Testing

**Traditional Approach** (what we want to avoid):
```
🐛 Bug #1 → investigate → log → restart → fix → test
🐛 Bug #2 → investigate → log → restart → fix → test
🐛 Bug #3 → investigate → log → restart → fix → test
🐛 Bug #4 → investigate → log → restart → fix → test
🐛 Bug #5 → investigate → log → restart → fix → test

Time: ~85 minutes
Context: 104K tokens
Restarts: 15+
```

**With Debug Coordinate** (better):
```bash
/debug:coordinate "navbar auth, sign-out cookie, like blank page, scroll jump, NaN likes"
```

**Workflow**:
1. Plugin analyzes: "5 issues detected → ORCHESTRATED strategy"
2. Creates debug session with templates
3. You fill in logging-strategy.md
4. Implement logging, run app, analyze logs
5. Fill in analysis-template.md with root causes
6. Fill in orchestration-plan.md
7. Launch orchestrator:
   ```
   /project-orchestrator:debug --plan=.debug-sessions/YYYYMMDD-HHMMSS/orchestration-plan.md
   ```
8. Orchestrator spawns 4 parallel agents:
   - Agent 1: Backend auth track (bugs #1, #2)
   - Agent 2: Frontend UX track (bugs #3, #4)
   - Agent 3: Data layer track (bug #5)
   - Agent 4: Test automation track
9. Verify with verification-checklist.md

**Result**:
```
Time: ~35 minutes (60% reduction)
Context: ~60K tokens (fresh agents)
Restarts: 3-4 (coordinated)
Quality: Higher (systematic approach)
```

---

## Philosophy

### 1. Systematic Over Random
**Problem**: Random debugging → "try this, try that"
**Solution**: Structured phases ensure complete investigation

### 2. Logging First, Changes Second
**Problem**: Making changes without data → guess-and-check
**Solution**: Add instrumentation, collect data, then fix

### 3. Parallel When Possible
**Problem**: Sequential debugging of independent bugs
**Solution**: 3+ bugs → spawn parallel agents

### 4. Document Everything
**Problem**: Learnings lost, same bugs recur
**Solution**: Audit trail of problem → analysis → fix

### 5. Verify Thoroughly
**Problem**: Fix one bug, break another
**Solution**: Checklists ensure comprehensive verification

---

## Integration with Other Plugins

### With SpecLab
- SpecLab `/speclab:bugfix` now detects multi-bug scenarios
- Automatically suggests `/debug:coordinate`
- Shows orchestration benefits

### With Project Orchestrator
- Debug Coordinate generates orchestration plans
- Orchestrator executes parallel agent workflow
- Coordinates integration and testing

### Workflow Integration
```
User: "I found 5 bugs"
  ↓
/speclab:bugfix
  ↓
Detection: "5 bugs detected → Use orchestrator?"
  ↓
/debug:coordinate "bug descriptions"
  ↓
Creates debug session + templates
  ↓
User fills in analysis
  ↓
/project-orchestrator:debug --plan=...
  ↓
Parallel agents fix bugs
  ↓
Verification
  ↓
Done!
```

---

## Real-World Example

From the learning document that inspired this plugin:

**Scenario**: Manual testing revealed 5 bugs
1. Navbar not updating after sign-in
2. Sign-out button not working
3. Like button redirecting to blank page
4. Scroll jumping to top after like
5. Likes not displaying (showed NaN)

**What actually happened**: Sequential debugging, 104K tokens, 85 minutes

**What should have happened**:
```bash
/debug:coordinate "navbar auth, sign-out, like blank page, scroll jump, NaN likes"

# Follow workflow, generate orchestration plan
# Launch orchestrator with 4 parallel agents:
# - Backend Auth Track (bugs #1, #2)
# - Frontend UX Track (bugs #3, #4)
# - Data Layer Track (bug #5)
# - Test Automation Track

# Result: ~35 minutes, better quality, complete test coverage
```

---

## Detection Heuristics

Debug Coordinate automatically determines strategy:

**ORCHESTRATED** (parallel) when:
- 3+ distinct bugs
- 3+ domains affected
- Complex coordination needed

**SEQUENTIAL** when:
- 1-2 bugs
- Single domain
- Simple investigation

**Detection Algorithm** (from orchestrator-detection.sh):
```bash
if [ "$BUG_COUNT" -ge 3 ]; then
  STRATEGY="orchestrated"
  # 40-60% time savings expected
else
  STRATEGY="sequential"
  # Traditional workflow efficient
fi
```

---

## Templates Created

### 1. problem-description.md
- Parses and lists all issues
- Records creation timestamp
- Documents strategy chosen

### 2. logging-strategy.md
- Identifies files to instrument
- Specifies logging points
- Defines monitoring approach

### 3. analysis-template.md
- Captures log evidence
- Documents root causes
- Categorizes by domain
- Proposes fix strategies

### 4. orchestration-plan.md (if orchestrated)
- Agent assignments by domain
- File modification plans
- Coordination points
- Success criteria

### 5. verification-checklist.md
- Issue verification
- Regression testing
- Cleanup tasks
- Metrics capture

---

## Best Practices

### 1. Good Problem Descriptions
✅ **Good**: "navbar not updating after sign-in, sign-out cookie not clearing, like button shows blank page"
❌ **Bad**: "stuff is broken"

✅ **Good**: List distinct issues separated by commas
❌ **Bad**: Vague or combined descriptions

### 2. Logging Strategy
✅ **Do**: Use searchable prefixes (`[DEBUG-1]`, `[DEBUG-2]`)
✅ **Do**: Capture context (variables, state, params)
✅ **Do**: Log at strategic points (before/after critical operations)
❌ **Don't**: Add random console.logs everywhere

### 3. Root Cause Analysis
✅ **Do**: Base analysis on log evidence
✅ **Do**: Identify specific file:line locations
✅ **Do**: Explain *why* bug occurs
❌ **Don't**: Guess without data

### 4. Orchestration Decisions
✅ **Do**: Use orchestration for 3+ bugs
✅ **Do**: Group bugs by domain
✅ **Do**: Identify dependencies
❌ **Don't**: Orchestrate 1-2 simple bugs

---

## Metrics to Track

After each debug session, capture:

| Metric | Value |
|--------|-------|
| **Issues Fixed** | X |
| **Strategy Used** | Sequential / Orchestrated |
| **Time Taken** | X minutes |
| **Sequential Estimate** | X minutes |
| **Time Savings** | X% |
| **Domains Affected** | backend, frontend, DB, etc. |
| **Restarts Required** | X |
| **Quality Score** | 1-10 |

---

## Troubleshooting

### Plugin not found
```bash
# Verify installation
claude plugin list | grep debug-coordinate

# Reinstall if needed
claude plugin install ./plugins/debug-coordinate
```

### Debug session directory not created
- Check git repository is detected
- Verify write permissions
- Session created in `$REPO_ROOT/.debug-sessions/`

### Orchestrator not suggested when expected
- Check bug count (need 3+)
- Verify problem description has separators (commas, semicolons)
- Review strategy output in plugin

---

## Future Enhancements

Planned improvements:
- Auto-implement logging from strategy
- Real-time log monitoring integration
- Pattern recognition for common bug types
- Integration with Claude Vision for UI bugs
- Metrics dashboard
- Historical bug pattern analysis

---

## Related Documentation

- [Orchestrator Detection System Design](../../docs/learnings/orchestrator-detection-system-design.md)
- [When We Should Have Used Orchestrator](../../docs/learnings/2025-10-14-orchestrator-missed-opportunity.md)
- [SpecLab Plugin](../speclab/README.md)
- [Project Orchestrator Plugin](../project-orchestrator/README.md)

---

## Contributing

This plugin emerged from real-world debugging pain. If you have:
- ✅ New detection heuristics
- ✅ Improved templates
- ✅ Additional automation ideas
- ✅ Real-world usage metrics

Please contribute!

---

## License

MIT License

**Attribution**:
- Inspired by [2025-10-14-orchestrator-missed-opportunity.md](../../docs/learnings/2025-10-14-orchestrator-missed-opportunity.md)
- Built on Claude Code plugin system
- Created by Marty Bonacci & Claude Code (2025)

---

**Remember**: Debugging doesn't have to be chaotic. Coordinate, systematize, orchestrate! 🐛→✅
