# Testing Results

This directory contains human-readable summaries of plugin testing results.

## Purpose

**Claude Code logs everything automatically** in `~/.claude/projects/`, but those logs are machine-readable JSON. These results files provide:
- Human-readable summaries
- High-level metrics and observations
- Cross-test comparisons
- Insights and recommendations

## Structure

### Individual Test Results
- **[test-1-results.md](test-1-results.md)** - SpecKit baseline test
- **[test-2-results.md](test-2-results.md)** - SpecSwarm tech enforcement test
- **[test-3-results.md](test-3-results.md)** - SpecTest parallel execution test ⭐
- **[test-4a-results.md](test-4a-results.md)** - SpecLab lifecycle workflows (on SpecTest)
- **[test-4b-results.md](test-4b-results.md)** - SpecLab lifecycle workflows (on SpecSwarm)

### Cross-Test Analysis
- **[comparison-matrix.md](comparison-matrix.md)** - Side-by-side comparison of all tests

## Workflow

### During Testing:
1. Open the relevant test workflow (e.g., `test-3-spectest.md`)
2. Open the results file (e.g., `test-3-results.md`)
3. Follow prompts in the test workflow
4. Record observations/metrics in the results file as you go
5. Claude Code automatically logs everything in `~/.claude/`

### After Testing:
1. Fill out the "Quick Summary" section
2. Complete any missing metrics
3. Update `comparison-matrix.md` with findings
4. Detailed logs remain in `~/.claude/projects/` for reference

## What to Record

### ✅ Do Record:
- Start/end times for each phase
- High-level metrics (time, parallel tasks, speedup)
- Issues encountered and resolutions
- Observations and insights
- User experience notes
- Comparison bullets

### ❌ Don't Record:
- Full conversation transcripts (Claude Code logs these)
- Code snippets (unless particularly notable)
- Step-by-step execution details (logs have this)
- Repetitive information

## Benefits

1. **Quick reference** - Scan results without parsing logs
2. **Easy comparison** - See all tests side-by-side
3. **Human insights** - Capture observations logs can't
4. **Shareable** - Results are readable by anyone
5. **Complete record** - Logs + summaries = full picture

## Claude Code Logs Location

Detailed logs for each test project:
```
~/.claude/projects/-home-marty-code-projects-tweeter-speckit/
~/.claude/projects/-home-marty-code-projects-tweeter-specswarm/
~/.claude/projects/-home-marty-code-projects-tweeter-spectest/
```

Each directory contains `.jsonl` files (one per conversation) with complete technical details.

---

**Happy Testing!** 🎉
