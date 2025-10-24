# Task Package: TP-XXX - [Task Name]

**Created**: [YYYY-MM-DD]
**Status**: [Pending / In Progress / Completed / Blocked]
**Phase**: [Phase Number - Phase Name]
**Instance**: [Instance B - CustomCult2]

---

## Overview

**Goal**: [Clear, concise goal statement]

**Why This Matters**:
- [Reason 1 - For migration]
- [Reason 2 - For plugin testing]

**Dependencies**:
- [ ] [Previous task that must be complete]
- [ ] [Required setup or configuration]

---

## Plugin Command(s)

### Primary Command

```bash
/specswarm:[command] "[arguments]"
```

**OR**

```bash
/speclabs:[command] "[arguments]" /path/to/project
```

### Follow-up Commands (if applicable)

```bash
/specswarm:[command2]
```

---

## Expected Outcomes

### Artifacts That Should Be Created

- [ ] `[file-path]` - [Description of file]
- [ ] `[file-path]` - [Description of file]

### Expected Behavior

1. [Step 1 that should happen]
2. [Step 2 that should happen]
3. [Step 3 that should happen]

### Success Criteria

- [ ] [Measurable success criterion 1]
- [ ] [Measurable success criterion 2]
- [ ] [Measurable success criterion 3]

---

## Plugin Testing Focus

### What We're Testing

- **Command**: `/specswarm:[command]` or `/speclabs:[command]`
- **Aspect**: [What specific aspect of the plugin we're evaluating]

### What to Watch For

⚠️ **Potential Issues**:
- [Known edge case or potential problem]
- [Area that needs special attention]

✅ **Quality Indicators**:
- [What good output looks like]
- [Signs the plugin is working well]

### Questions to Answer

1. [Question about plugin effectiveness]
2. [Question about user experience]
3. [Question about output quality]

---

## Execution Instructions

### Pre-Execution Checklist

- [ ] Read this entire task package
- [ ] Git status clean (or committed)
- [ ] On correct branch: [branch-name]
- [ ] feedback-live.md open in editor
- [ ] Terminal ready in CustomCult2 directory

### Step-by-Step Execution

**Step 1**: [First action]
```bash
[command if applicable]
```

**Step 2**: [Second action]
```bash
[command if applicable]
```

**Step 3**: [Third action]

[Continue for all steps...]

### During Execution

**Document in feedback-live.md**:
- ⏱️ Start time
- ⚠️ Any errors or confusion immediately
- 🤔 Unexpected behavior
- ✅ Successful completions
- 📝 Observations about plugin quality

### Post-Execution Validation

- [ ] Check all expected artifacts were created
- [ ] Validate artifact quality
- [ ] Test affected features manually
- [ ] Review git diff
- [ ] Update feedback-live.md with results

---

## Migration-Specific Context

### Current State
[Description of current CustomCult2 state relevant to this task]

### Target State
[Description of desired state after this task]

### Critical Areas
- **3D Rendering**: [Impact on Three.js visualization]
- **Algorithms**: [Impact on ThreeDMod.php calculations]
- **API Routes**: [Impact on Laravel routes]
- **State Management**: [Impact on Redux/React state]

### Rollback Plan
If this task breaks something critical:
```bash
git reset --hard HEAD~1
# OR
git revert [commit-hash]
```

---

## Feedback Capture

### Required Documentation

**In feedback-live.md, document**:
1. Every issue encountered (use Issue template)
2. Time taken for each major step
3. Overall experience (smooth / rough / blocked)
4. Suggested improvements to plugin

**Metrics to Track**:
- Total time: [actual time taken]
- Issues found: [count]
- Blockers: [count]
- Quality score: [your rating 1-10]

---

## Instance Switch Triggers

**Switch to Instance A if**:
- ⚠️ Hit a blocker (can't proceed)
- 🐛 Found bug in plugin
- 🤔 Plugin output is confusing or wrong
- ⏰ Completed this task package (checkpoint)

**Stay in Instance B if**:
- ✅ Task completed successfully
- 🚀 Ready for next task immediately
- 📊 Just minor observations to note

---

## Next Task

**After completing this task**:
- [ ] Update feedback-live.md
- [ ] If issues found → Switch to Instance A
- [ ] If successful → Consider proceeding to [TP-XXX]
- [ ] Git commit if changes made

**Logical Next Task**: TP-XXX - [Next Task Name]

---

## Notes for Plugin Developer (Instance A)

### What to Look For in Feedback

- [Specific aspect to evaluate]
- [Metric to track]
- [Common issue pattern]

### Potential Improvements

- [Idea 1 for improvement]
- [Idea 2 for improvement]

### Related Plugin Code

- File: `plugins/specswarm/commands/[command].md`
- Lines: [relevant line numbers if known]

---

## Completion Checklist

- [ ] Task executed successfully
- [ ] All expected artifacts created
- [ ] Feedback documented in feedback-live.md
- [ ] Migration progress noted
- [ ] Issues logged (if any)
- [ ] Git committed (if applicable)
- [ ] Ready for next step

**Completed**: [YYYY-MM-DD HH:MM]
**Duration**: [X hours Y minutes]
**Outcome**: [Success / Partial / Blocked]
