# Task Package: TP-001 - Test /specswarm:specify Workflow

**Created**: 2025-10-23
**Status**: Ready to Execute
**Phase**: Phase 1 - Setup & First Test
**Instance**: Instance B - CustomCult2
**Estimated Duration**: 30-45 minutes

---

## Overview

**Goal**: Test the `/specswarm:specify` command by creating a feature specification for upgrading PHP from 7.2 to 8.3 in the CustomCult2 project.

**Why This Matters**:
- **For Migration**: We need to plan the PHP upgrade systematically
- **For Plugin Testing**: This is our first real-world test of the specify workflow
- **For Process**: Validates the rapid iteration feedback loop

**Dependencies**:
- [x] CustomCult2 project exists at `/home/marty/code-projects/customcult2`
- [x] SpecSwarm plugin installed in Claude Code
- [x] Git repository initialized
- [x] Feedback tracking files created

---

## Plugin Command

### Primary Command

```bash
/specswarm:specify "Upgrade PHP from 7.2 to 8.3 with all breaking changes addressed and Laravel 5.8 compatibility maintained"
```

### Context
This command should:
1. Create a feature specification document
2. Analyze breaking changes between PHP 7.2 and 8.3
3. Consider Laravel 5.8 compatibility constraints
4. Define success criteria
5. List dependencies and risks

---

## Expected Outcomes

### Artifacts That Should Be Created

- [ ] `features/001-php-upgrade/spec.md` - Feature specification document
- [ ] Feature directory with proper naming (001-*)
- [ ] Clear structure following SpecSwarm spec format

### Expected Behavior

1. Command should detect this is a PHP version upgrade task
2. Should analyze current `composer.json` for PHP requirements
3. Should recognize Laravel 5.8 constraint (requires PHP 7.2-7.4 range)
4. Should list PHP 7.2→8.3 breaking changes
5. Should propose incremental upgrade path
6. Should define validation criteria
7. Should identify critical files to test (ThreeDMod.php, controllers, etc.)

### Success Criteria

- [ ] Spec document is comprehensive (>500 words)
- [ ] Breaking changes are listed specifically
- [ ] Laravel compatibility constraints identified
- [ ] Success criteria are measurable
- [ ] Dependencies and risks documented
- [ ] Follows SpecSwarm spec.md template format

---

## Plugin Testing Focus

### What We're Testing

- **Command**: `/specswarm:specify`
- **Aspect**: Quality and completeness of generated specifications for real-world migration tasks

### What to Watch For

⚠️ **Potential Issues**:
- May not detect Laravel version constraints from composer.json
- May suggest direct 7.2→8.3 upgrade (dangerous) vs incremental
- May miss PHP deprecations relevant to Laravel 5.8
- May not identify critical CustomCult2-specific files to test
- May generate generic spec instead of project-specific

✅ **Quality Indicators**:
- Spec mentions specific PHP 7.2→8.3 breaking changes
- Recognizes need to check Laravel compatibility first
- Lists specific files in CustomCult2 to validate
- Proposes testing strategy for ThreeDMod.php (71KB algorithm file)
- Includes rollback plan
- Defines clear success metrics

### Questions to Answer

1. Does the specify command analyze existing project files (composer.json)?
2. Does it understand framework version constraints?
3. Does it provide actionable, specific guidance vs generic advice?
4. Is the generated spec detailed enough to proceed to planning?
5. Does it identify CustomCult2-specific risks (3D rendering, algorithms)?

---

## Execution Instructions

### Pre-Execution Checklist

- [ ] Read this entire task package
- [ ] Open terminal in `/home/marty/code-projects/customcult2`
- [ ] Git status clean (run `git status`)
- [ ] On main branch (or create `feature/001-php-upgrade`)
- [ ] Open `~/code-projects/specswarm/docs/case-studies/customcult2-migration/feedback-live.md` in editor
- [ ] Timer ready to track duration

### Step-by-Step Execution

**Step 1**: Navigate to CustomCult2 project
```bash
cd /home/marty/code-projects/customcult2
```

**Step 2**: Check current state
```bash
# View current PHP requirement
cat composer.json | grep "php"

# View current Laravel version
cat composer.json | grep "laravel/framework"

# Git status
git status
```

**Expected Output**:
- PHP: "^7.2"
- Laravel: "5.8.*"
- Git: Clean working directory (or committed changes)

**Step 3**: Optional - Create feature branch
```bash
git checkout -b feature/001-php-upgrade
```

**Step 4**: Execute SpecSwarm specify command
```bash
/specswarm:specify "Upgrade PHP from 7.2 to 8.3 with all breaking changes addressed and Laravel 5.8 compatibility maintained"
```

**Step 5**: Start timer and observe
- ⏱️ Note start time in feedback-live.md
- 👀 Watch what the command does
- 📝 Note any questions or confusion immediately
- ⚠️ Log any errors or unexpected behavior

### During Execution

**Document in feedback-live.md IMMEDIATELY**:

```markdown
### TP-001 Execution - [Start Time]

**Command**: /specswarm:specify "..."
**Start**: [HH:MM]

#### Observations:
- [What's happening]
- [Any questions or confusion]
- [Errors or warnings]

#### Issues:
[Use issue template for any problems]
```

**Watch for these specific things**:
1. Does it read composer.json?
2. Does it create features/ directory?
3. Does it name the feature correctly (001-*)?
4. What's the quality of the generated spec?
5. Any errors or confusion in the output?

### Post-Execution Validation

**Step 6**: Verify artifacts created
```bash
# Check if features directory created
ls -la features/

# Check feature directory name
ls -la features/ | grep "001"

# View generated spec
cat features/001-*/spec.md | head -50
```

**Step 7**: Evaluate spec quality
- [ ] Open `features/001-php-upgrade/spec.md` (or whatever it's named)
- [ ] Read through entire document
- [ ] Check against quality indicators above
- [ ] Rate quality 1-10

**Step 8**: Document results in feedback-live.md

```markdown
#### Results:
- Feature directory: [path]
- Spec file: [path]
- Quality rating: [1-10]
- Duration: [X minutes]

#### What Worked:
- [Positive aspects]

#### Issues Found:
- [List of issues with severity]

#### Suggested Improvements:
- [Ideas for improving the specify command]
```

---

## Migration-Specific Context

### Current CustomCult2 State
- **PHP Version**: 7.2
- **Laravel Version**: 5.8 (requires PHP ^7.2)
- **Critical Constraint**: Laravel 5.8 is EOL and doesn't support PHP 8.x
- **Implication**: Must upgrade Laravel first, OR upgrade PHP incrementally while staying in 7.x range

### Target State After TP-001
- **Specification created**: Clear plan for PHP upgrade
- **Decision made**: Direct upgrade vs incremental
- **Risks identified**: What could break
- **Testing strategy**: How to validate the upgrade

### Critical CustomCult2 Areas
- **ThreeDMod.php** (71KB): Complex snowboard calculation algorithms - any PHP breaking changes here are high risk
- **API Controllers**: Laravel controllers with type hints
- **Three.js Integration**: PHP serves 3D model data
- **S3 Upload**: AWS SDK compatibility
- **Passport Auth**: OAuth implementation

### Rollback Plan
This is a spec creation task - no code changes yet. If something goes wrong:
```bash
# Just delete the features directory
rm -rf features/001-*
```

---

## Feedback Capture

### Required Documentation in feedback-live.md

**Immediately after execution, document**:

1. **Execution time**: How long did specify take?
2. **Spec quality**: Rate 1-10 with reasoning
3. **Issues encountered**: Any confusion, errors, or problems
4. **Positive observations**: What worked well
5. **Suggested improvements**: Specific ideas for making specify better

**Use this template**:

```markdown
### Issue #001 - [If any issue found]

**Time**: [HH:MM]
**Severity**: [Low / Medium / High / Blocker]
**Status**: Open

**Problem**:
[Detailed description]

**Expected**:
[What should have happened]

**Impact**:
[How this affects the migration]

**Suggested Fix**:
[How to improve the specify command]
```

### Metrics to Track

- **Total time**: [Start to finish in minutes]
- **Issues found**: [Count by severity]
- **Spec quality**: [Rating 1-10]
- **Spec completeness**: [% of expected sections present]
- **Project awareness**: [Did it understand CustomCult2 context?]
- **Framework awareness**: [Did it catch Laravel constraints?]

---

## Instance Switch Triggers

### Switch to Instance A (SpecSwarm) if:
- ⚠️ Specify command fails or errors
- 🐛 Generated spec is low quality or generic
- 🤔 Spec misses critical Laravel constraints
- ❓ Unclear what to do next
- ⏰ Task complete (checkpoint)

### Stay in Instance B (CustomCult2) if:
- ✅ Specify succeeds and spec looks good
- 🚀 Ready to proceed to next task (TP-002: test plan)
- 📊 Just documenting observations

**After completing this task**: Switch to Instance A for review and potential fixes

---

## Next Task

**After completing TP-001**:
- [ ] Update feedback-live.md with complete results
- [ ] Switch to Instance A
- [ ] Review findings
- [ ] If issues found → Implement improvements
- [ ] If successful → Prepare TP-002 (test plan workflow)

**Logical Next Task**: TP-002 - Test /specswarm:plan Workflow
- Will use the spec created in TP-001
- Tests the plan generation command
- Should create plan.md with implementation design

---

## Notes for Plugin Developer (Instance A)

### What to Look For in Feedback

**Critical Evaluation Points**:
1. Did specify detect composer.json constraints?
2. Did it propose incremental upgrade path?
3. Did it identify Laravel 5.8 as the blocker?
4. Did it mention specific PHP 7.2→8.3 breaking changes?
5. Did it reference CustomCult2-specific files?
6. Is the spec actionable for planning phase?

**Common Issues to Watch For**:
- Generic PHP upgrade advice (not project-specific)
- Missing Laravel version constraint analysis
- Suggesting impossible direct upgrade
- Not identifying critical test areas (ThreeDMod.php, algorithms)
- Poor spec structure or formatting

### Potential Improvements to Implement

If feedback shows these issues:

**Improvement #1**: Add composer.json parsing to specify command
- Parse PHP and framework requirements
- Warn about version conflicts
- Suggest compatible upgrade paths

**Improvement #2**: Add framework-specific guidance
- Detect Laravel version
- Reference Laravel upgrade guide
- Note Laravel version PHP support matrix

**Improvement #3**: Add project file analysis
- Identify large/complex files (>50KB)
- Note files with potential breaking change risks
- Suggest targeted testing areas

### Related Plugin Code

- File: `plugins/specswarm/commands/specify.md`
- Should review how specify command gathers project context
- May need to enhance with file system analysis

---

## Completion Checklist

- [ ] Task executed in Instance B (CustomCult2)
- [ ] Spec document created at `features/001-*/spec.md`
- [ ] Spec quality evaluated (rating given)
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

## Instance A Review Checklist

When reviewing feedback from TP-001:

- [ ] Read complete feedback-live.md entry
- [ ] Evaluate each issue for priority
- [ ] Determine which improvements to implement now vs defer
- [ ] Implement high-priority improvements
- [ ] Update improvements-log.md
- [ ] Update metrics.md
- [ ] Prepare TP-002 or request re-test of TP-001

**Remember**: Goal is rapid iteration. Fix critical issues immediately, defer nice-to-haves.
