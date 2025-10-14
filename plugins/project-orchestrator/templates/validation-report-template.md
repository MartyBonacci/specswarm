# Validation Report: [Task Name]

**Date**: YYYY-MM-DD HH:MM:SS
**Project**: [project-path]
**Test URL**: [url]
**Orchestrator Version**: 0.1.0-alpha.1

---

## Validation Summary

| Metric | Result |
|--------|--------|
| Browser Validation | ✅ PASSED / ❌ FAILED |
| Console Errors | 0 / [count] |
| Network Errors | 0 / [count] |
| Visual Quality | ✅ PASSED / ⚠️ ISSUES / ❌ FAILED |
| Overall Status | ✅ PASSED / ❌ FAILED |

---

## Browser Validation Results

**Browser**: Chromium (Playwright)
**Page Load Time**: [X]ms
**Page Title**: [title]

### Console Errors

```
[List of console errors, or "None detected"]
```

### Network Errors

```
[List of failed requests, or "None detected"]
```

---

## Visual Analysis

**Screenshot**: `/tmp/orchestrator-validation-screenshot.png`

### Layout Assessment
- [ ] Layout correct
- [ ] No overlapping elements
- [ ] Content visible
- [ ] Responsive design working

### Styling Assessment
- [ ] CSS applied correctly
- [ ] Colors correct
- [ ] Fonts rendering
- [ ] Spacing/padding correct

### Functional Assessment
- [ ] Navigation elements present
- [ ] Buttons visible
- [ ] Forms functional
- [ ] No broken images

### Issues Detected

[List any visual issues found, or "No issues detected"]

---

## Validation Criteria Check

Based on test workflow validation criteria:

- [ ] Criterion 1: [description] - ✅ PASSED / ❌ FAILED
- [ ] Criterion 2: [description] - ✅ PASSED / ❌ FAILED
- [ ] Criterion 3: [description] - ✅ PASSED / ❌ FAILED

---

## Recommendations

**If PASSED**:
- ✅ Task completed successfully
- Ready for manual review
- Consider documenting patterns for future

**If FAILED**:
- ❌ Issues need resolution
- Agent retry recommended with refined prompt
- Manual intervention may be needed

### Suggested Actions

1. [Action item 1]
2. [Action item 2]
3. [Action item 3]

---

## Performance Metrics

| Metric | Value |
|--------|-------|
| Validation Duration | [X]s |
| Browser Launch Time | [X]s |
| Page Load Time | [X]ms |
| Screenshot Capture | [X]ms |

---

## Raw Data

**Results JSON**: `/tmp/orchestrator-validation-results.json`
**Screenshot**: `/tmp/orchestrator-validation-screenshot.png`
**Validation Script**: `/tmp/orchestrator-validate.js`

---

## Next Steps

1. Review validation results
2. If passed: Mark task complete
3. If failed: Analyze errors and retry
4. Document learnings for Phase 0 evaluation

---

**Report Generated**: [timestamp]
**Orchestrator**: Project Orchestrator Plugin v0.1.0-alpha.1
