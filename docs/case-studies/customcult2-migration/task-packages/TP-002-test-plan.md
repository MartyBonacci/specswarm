# Task Package: TP-002 - Test /specswarm:plan Workflow

**Created**: 2025-10-23
**Status**: Ready to Execute
**Phase**: Phase 2 - Core Plugin Testing
**Instance**: Instance B - CustomCult2
**Estimated Duration**: 30-45 minutes

---

## Overview

**Goal**: Test the `/specswarm:plan` command by generating an implementation plan from one of the specs created in TP-001-RETEST.

**Why This Matters**:
- **For Migration**: We need implementation plans for the Laravel upgrade path
- **For Plugin Testing**: Tests the second command in the workflow (specify → **plan** → tasks → implement)
- **For Process**: Validates that the workflow chain works end-to-end

**Dependencies**:
- [x] TP-001-RETEST completed successfully
- [x] 6 feature specs generated (001-006)
- [x] Improvement #001 validated
- [x] CustomCult2 project ready

---

## Which Spec Should We Use?

We have 6 specs from TP-001-RETEST. Let's use **Feature 001** (Laravel 5.8 → 6.x) because:
- ✅ It's the first in the sequence
- ✅ Smaller scope than the full PHP upgrade
- ✅ Has clear dependencies and constraints
- ✅ Representative of upgrade features

**Location**: `/home/marty/code-projects/customcult2/features/001-laravel-5-8-to-6-x-upgrade/`

---

## Plugin Command

### Check Current Branch First

```bash
cd /home/marty/code-projects/customcult2

# See what branch we're on
git branch --show-current

# See what features exist
ls -la features/
```

### Switch to Feature 001 Branch

The specify command should have created a branch for Feature 001. Switch to it:

```bash
# Find the branch name (should be 001-laravel-5-8-to-6-x-upgrade or similar)
git branch | grep "001-laravel"

# Switch to it
git checkout 001-laravel-5-8-to-6-x-upgrade
```

### Primary Command

```bash
/specswarm:plan
```

**That's it!** The plan command should:
1. Read the spec.md from the current feature directory
2. Analyze the requirements
3. Generate a technical implementation plan
4. Create plan.md in the feature directory

---

## Expected Outcomes

### Artifacts That Should Be Created

- [ ] `features/001-laravel-5-8-to-6-x-upgrade/plan.md` - Implementation plan
- [ ] Plan should be substantial (~1000-2000 words)
- [ ] Should include technical design sections

### Expected Plan Sections

The plan should include:
- **Technical Approach**: How to implement the upgrade
- **Architecture**: What components are affected
- **Database Changes**: Migration considerations
- **Dependencies**: What must be updated
- **Testing Strategy**: How to validate the upgrade
- **Rollback Plan**: How to undo if needed
- **Timeline/Phases**: Implementation sequence

### Success Criteria

- [ ] Plan document created
- [ ] All major technical areas covered
- [ ] Specific to CustomCult2 (mentions ThreeDMod.php, etc.)
- [ ] Actionable guidance provided
- [ ] Dependencies on other features noted
- [ ] Laravel 5.8 → 6.x specific breaking changes listed
- [ ] Quality rating >7/10

---

## What We're Testing

### Plan Command Capabilities

1. **Spec Comprehension**: Does it understand the feature spec?
2. **Technical Detail**: Does it provide implementation-level guidance?
3. **Project Awareness**: Does it reference CustomCult2-specific files?
4. **Laravel Knowledge**: Does it know Laravel 5.8 → 6.x breaking changes?
5. **Dependency Tracking**: Does it reference the need to upgrade Laravel before PHP?
6. **Testing Guidance**: Does it provide clear testing strategy?

### Potential Issues to Watch For

⚠️ **What might go wrong**:
- Generic Laravel upgrade advice (not CustomCult2-specific)
- Missing critical files (ThreeDMod.php, controllers, etc.)
- Incomplete breaking changes list
- No rollback strategy
- Missing dependency on completing this before Feature 002
- Doesn't consider existing tech stack (React, Redux, Three.js, etc.)

✅ **Quality indicators**:
- Mentions specific CustomCult2 files
- Lists concrete Laravel 5.8 → 6.x breaking changes
- Provides step-by-step implementation sequence
- Includes testing checkpoints
- References composer.json updates needed
- Notes impact on existing features (3D rendering, algorithms, etc.)

---

## Execution Instructions

### Pre-Execution Checklist

- [ ] In CustomCult2 project directory
- [ ] On branch: 001-laravel-5-8-to-6-x-upgrade
- [ ] Spec file exists: `features/001-laravel-5-8-to-6-x-upgrade/spec.md`
- [ ] feedback-live.md open in editor
- [ ] Timer ready

### Step-by-Step Execution

**Step 1**: Navigate and verify

```bash
cd /home/marty/code-projects/customcult2

# Check branch
git branch --show-current

# Should see: 001-laravel-5-8-to-6-x-upgrade

# Verify spec exists
ls -la features/001-laravel-5-8-to-6-x-upgrade/spec.md
```

**Step 2**: Confirm no plan exists yet

```bash
# Should return "No such file"
ls features/001-laravel-5-8-to-6-x-upgrade/plan.md
```

**Step 3**: Execute plan command

```bash
/specswarm:plan
```

**Start timer!** ⏱️

**Step 4**: Observe execution

Watch for:
- Does it read the spec.md?
- Does it analyze the project?
- Does it reference composer.json?
- Does it mention specific files?
- Any errors or warnings?

**Step 5**: Review generated plan

```bash
# View the plan
cat features/001-laravel-5-8-to-6-x-upgrade/plan.md | head -100

# Or view full plan
cat features/001-laravel-5-8-to-6-x-upgrade/plan.md
```

### During Execution

**Document in feedback-live.md IMMEDIATELY**:

```markdown
### TP-002 Execution - [Start Time]

**Command**: /specswarm:plan
**Feature**: 001 - Laravel 5.8 → 6.x
**Start**: [HH:MM]

#### Observations:
- [What's happening]
- [Any questions or confusion]
- [Errors or warnings]

#### Issues:
[Use issue template for any problems]
```

---

## Post-Execution Validation

### Step 6: Evaluate Plan Quality

**Check these specific things**:

1. **CustomCult2-Specific References**:
   ```bash
   # Should find mentions of these
   grep -i "threedmod\|designer\|board\|redux\|three\.js" features/001-laravel-5-8-to-6-x-upgrade/plan.md
   ```

2. **Laravel 5.8 → 6.x Breaking Changes**:
   ```bash
   # Should mention specific breaking changes
   grep -i "breaking\|deprecated\|removed" features/001-laravel-5-8-to-6-x-upgrade/plan.md
   ```

3. **Implementation Steps**:
   ```bash
   # Should have numbered steps or phases
   grep -E "^#+ (Step|Phase|Stage)" features/001-laravel-5-8-to-6-x-upgrade/plan.md
   ```

4. **Testing Strategy**:
   ```bash
   # Should mention testing
   grep -i "test\|validation\|verify" features/001-laravel-5-8-to-6-x-upgrade/plan.md
   ```

### Step 7: Quality Assessment

Rate the plan on these dimensions (1-10 each):

- **CustomCult2 Awareness**: Does it reference specific files/features?
- **Technical Depth**: Is implementation guidance detailed enough?
- **Laravel Accuracy**: Are breaking changes correct?
- **Actionability**: Could a developer follow this plan?
- **Testing Coverage**: Is testing strategy comprehensive?
- **Risk Management**: Does it address rollback/risks?

**Overall Quality Rating**: [X/10]

### Step 8: Document Results

In feedback-live.md:

```markdown
#### Results:
- Plan file: [path]
- Plan length: [word count]
- Quality rating: [1-10]
- Duration: [X minutes]

#### What Worked:
- [Positive aspects]

#### Issues Found:
- [List issues with severity]

#### CustomCult2 Awareness:
- [Mentions specific files? Y/N]
- [Understands project context? Y/N]

#### Suggested Improvements:
- [Ideas for improving plan command]
```

---

## Migration-Specific Context

### What the Plan Should Address

**Laravel 5.8 → 6.x Key Changes**:
- Requires PHP 7.2+  (CustomCult2 is on 7.2, so ✅ compatible)
- String and array helpers moved to separate package
- Eloquent date serialization format changed
- Authentication scaffolding moved to laravel/ui package
- Queue retry_after → retryAfter rename
- Blade::component renamed to Blade::aliasComponent
- Carbon 2.0 update

**CustomCult2-Specific Concerns**:
- ThreeDMod.php (71KB) - any breaking changes in calculations?
- Laravel Passport - needs upgrade
- Laravel Mix - needs upgrade
- API routes - any serialization changes affecting Three.js data?
- Database migrations - any format changes?
- Queue jobs - retry_after changes

### Success Criteria Specific to This Test

- [ ] Plan mentions Laravel 5.8 → 6.x specifically
- [ ] Lists major breaking changes above
- [ ] References CustomCult2 files (ThreeDMod.php, etc.)
- [ ] Provides composer.json update commands
- [ ] Includes testing strategy for 3D rendering
- [ ] Notes dependency on this completing before Feature 002
- [ ] Includes rollback strategy

---

## Feedback Capture

### Required Documentation

In feedback-live.md, document:

1. **Execution time**: How long did plan take?
2. **Plan quality**: Rate 1-10 with detailed reasoning
3. **Issues encountered**: Any confusion, errors, or problems
4. **CustomCult2 awareness**: Did it understand the project?
5. **Laravel knowledge**: Did it know 5.8 → 6.x changes?
6. **Actionability**: Could you implement from this plan?
7. **Comparison to specify**: Better/worse/same quality as specify?

### Issue Template (if issues found)

```markdown
### Issue #XXX - [Brief Description]

**Time**: [HH:MM]
**Severity**: [Low / Medium / High / Blocker]
**Status**: Open
**Command**: /specswarm:plan

**Problem**:
[What went wrong]

**Expected**:
[What should happen]

**Impact**:
[How this affects the migration]

**Suggested Fix**:
[How to improve the plan command]
```

---

## Instance Switch Triggers

### Switch to Instance A (SpecSwarm) if:
- ⚠️ Plan command fails or errors
- 🐛 Generated plan is low quality or generic
- 🤔 Plan misses critical Laravel changes
- ❓ Unclear what to do next
- ⏰ Task complete (checkpoint)

### Stay in Instance B (CustomCult2) if:
- ✅ Plan generated successfully
- 🚀 Ready to proceed to TP-003 (test tasks)
- 📊 Just documenting observations

---

## Next Task

**After completing TP-002**:
- [ ] Update feedback-live.md with complete results
- [ ] Switch to Instance A
- [ ] Review findings
- [ ] If issues found → Implement improvements
- [ ] If successful → Prepare TP-003 (test tasks workflow)

**Logical Next Task**: TP-003 - Test /specswarm:tasks Workflow
- Will use the plan.md created in TP-002
- Tests task breakdown generation
- Should create tasks.md with ordered implementation tasks

---

## Notes for Plugin Developer (Instance A)

### What to Look For in Feedback

**Critical Evaluation Points**:
1. Did plan read and understand the spec?
2. Did it provide Laravel 5.8 → 6.x specific guidance?
3. Did it reference CustomCult2-specific files?
4. Is the plan actionable (could a developer follow it)?
5. Does it include testing strategy?
6. Does it note dependencies (must complete before Feature 002)?

**Common Issues to Watch For**:
- Generic Laravel upgrade advice (not version-specific)
- Missing breaking changes list
- No CustomCult2 context
- Incomplete testing strategy
- Missing rollback plan
- Doesn't consider existing tech stack (React, Three.js, etc.)

### Potential Improvements to Consider

If feedback shows these issues:

**Improvement #002**: Enhance plan command with version-specific knowledge
- Add Laravel version-specific breaking changes database
- Include framework-specific migration guides
- Reference official upgrade guides

**Improvement #003**: Improve project-aware planning
- Analyze codebase structure (large files, critical paths)
- Identify high-risk areas (ThreeDMod.php)
- Suggest testing priority based on file size/complexity

**Improvement #004**: Add testing strategy generator
- Based on feature type (upgrade, new feature, refactor)
- Include unit, integration, and E2E test suggestions
- Reference existing test structure

---

## Completion Checklist

- [ ] Task executed in Instance B
- [ ] Plan document created at `features/001-.../plan.md`
- [ ] Plan quality evaluated (rating given)
- [ ] Complete feedback documented in feedback-live.md
- [ ] All issues logged with severity
- [ ] Positive observations noted
- [ ] Suggested improvements listed
- [ ] Time metrics recorded
- [ ] Ready to switch to Instance A for review

**Completed**: [YYYY-MM-DD HH:MM]
**Duration**: [X minutes]
**Outcome**: [Success / Partial / Blocked]
**Issues Found**: [Count]
**Quality Rating**: [X/10]

---

## Quick Reference

**Command to run**:
```bash
cd /home/marty/code-projects/customcult2
git checkout 001-laravel-5-8-to-6-x-upgrade
/specswarm:plan
```

**File to check**:
```bash
cat features/001-laravel-5-8-to-6-x-upgrade/plan.md
```

**Feedback location**:
```
~/code-projects/specswarm/docs/case-studies/customcult2-migration/feedback-live.md
```

---

**Ready to test the plan command!** Let's see how it handles Laravel upgrade planning! 🚀
