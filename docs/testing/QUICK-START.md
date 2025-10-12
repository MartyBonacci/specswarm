# Testing Quick Start Guide

**TL;DR**: Complete testing workflows for all 4 plugins with detailed prompts

---

## 🎯 What You're Testing

**Phase 1: Feature Development** (Build Tweeter 3 times)
1. Test 1: SpecKit - Baseline pure SDD (~8-10h)
2. Test 2: SpecSwarm - Tech stack enforcement (~8-10h)
3. Test 3: SpecTest - Parallel execution (~4-6h) ⭐ **START HERE**

**Phase 2A: Lifecycle Workflows** (Use SpecTest build)
4. Test 4A: SpecLab - Bugfix + Modify workflows (~6-8h)

**Phase 2B: Integration Validation** (Optional)
5. Test 4B: SpecLab on SpecSwarm - Tech enforcement in lifecycle (~6-8h)

---

## 📚 Documentation Structure

### Master Guide
- **[Plugin Testing Guide](plugin-testing-guide.md)** - Complete overview, success criteria, troubleshooting

### Detailed Test Workflows

**✅ All Complete & Ready:**

- **[Test 1: SpecKit](test-1-speckit.md)** - Baseline SDD workflow
  - Complete step-by-step prompts
  - Metrics collection templates
  - Expected outcomes documented

- **[Test 2: SpecSwarm](test-2-specswarm.md)** - Tech stack enforcement
  - Auto-detection validation
  - Tech compliance verification
  - Comparison with Test 1

- **[Test 3: SpecTest](test-3-spectest.md)** ⭐ **START HERE**
  - Full Tweeter build with parallel execution
  - Most important test
  - Creates base for Phase 2A

- **[Test 4A: SpecLab on SpecTest](test-4a-speclab-spectest.md)** - Lifecycle workflows
  - Bugfix workflow (detailed)
  - Modify workflow (detailed)
  - Integration validation

- **[Test 4B: SpecLab on SpecSwarm](test-4b-speclab-specswarm.md)** - Optional
  - Tech enforcement in lifecycle
  - Run if issues discovered in 4A

### Templates
- **Results Template** (*below*)
- **Comparison Matrix** (*below*)

---

## 🚀 Recommended Testing Order

### Option A: Quick Validation (Focus on SpecTest + SpecLab)

**Day 1: SpecTest Build** (~4-6 hours)
1. Follow [Test 3: SpecTest](test-3-spectest.md) completely
2. Build full Tweeter app
3. Validate parallel execution
4. Check metrics dashboard

**Day 2: SpecLab Lifecycle** (~6-8 hours)
1. Use SpecTest build as base
2. Test bugfix workflow (fix deliberate bug)
3. Test modify workflow (add retweet feature)
4. Validate integration

**Total**: ~10-14 hours for core validation

---

### Option B: Comprehensive Testing (All plugins)

**Week 1: Feature Development**
- Day 1-2: Test 1 (SpecKit)
- Day 3-4: Test 2 (SpecSwarm)
- Day 5: Test 3 (SpecTest)

**Week 2: Lifecycle Workflows**
- Day 1: Test 4A (SpecLab on SpecTest)
- Day 2: Test 4B (SpecLab on SpecSwarm) - optional

**Total**: ~26-34 hours for complete validation

---

## 📖 Test Workflows

### Test 1: SpecKit (Baseline)

**Summary**: Build full Tweeter to establish baseline

✅ **Complete detailed workflow**: [Test 1: SpecKit](test-1-speckit.md)

**Key Highlights**:
- Baseline SDD methodology validation
- 4 features: authentication, tweets, likes, profiles
- Step-by-step prompts for each phase
- Comprehensive metrics collection
- ~8-10 hours expected
- Foundation for all comparisons

---

### Test 2: SpecSwarm (Tech Enforcement)

**Summary**: Build full Tweeter with tech stack validation

✅ **Complete detailed workflow**: [Test 2: SpecSwarm](test-2-specswarm.md)

**Key Highlights**:
- Auto-detect tech stack from README.md
- Continuous tech enforcement during development
- 95% drift prevention validation
- Comparison metrics with Test 1
- ~8-10 hours expected (similar to SpecKit)
- Tech compliance audit included

---

### Test 3: SpecTest (Parallel Execution)

**Summary**: Build full Tweeter with 2-4x speedup

✅ **Complete detailed workflow**: [Test 3: SpecTest](test-3-spectest.md)

**Key Highlights**:
- Full prompts provided (paste into Claude Code)
- Expected outcomes documented
- Parallel execution validation
- Metrics dashboard usage
- ~4-6 hours expected

**⭐ START HERE** - This is your most important test!

---

### Test 4A: SpecLab on SpecTest (Lifecycle Workflows)

**Summary**: Test bugfix + modify workflows on SpecTest build

**Prerequisites**: Complete Test 3 (SpecTest) first

✅ **Complete detailed workflow**: [Test 4A: SpecLab on SpecTest](test-4a-speclab-spectest.md)

**Key Highlights**:
- Bugfix workflow with regression-test-first methodology (~3h)
- Modify workflow with impact-analysis-first approach (~3-4h)
- Smart integration detection (SpecTest for parallel execution)
- Complete prompts for each phase
- Expected: ~6-8 hours total

**What You'll Test**:
- Fix: Tweet character limit not enforced (bugfix workflow)
- Add: Retweet functionality (modify workflow)
- Validate: Integration with SpecTest features
- Verify: Parallel execution during lifecycle workflows

---

### Test 4B: SpecLab on SpecSwarm (Optional)

**Summary**: Validate tech enforcement during lifecycle workflows

**When to Run**: If issues discovered in Test 4A or integration questions

**Prerequisites**: Complete Test 2 (SpecSwarm) first

✅ **Complete detailed workflow**: [Test 4B: SpecLab on SpecSwarm](test-4b-speclab-specswarm.md)

**Key Highlights**:
- Same workflows as Test 4A (bugfix + modify)
- Focus on tech stack enforcement integration
- Validates SpecSwarm + SpecLab combination
- Complete prompts and validation steps
- Expected: ~6-8 hours total

**What You'll Validate**:
- Tech enforcement active during bugfix workflow
- Tech enforcement active during modify workflow
- No tech drift during maintenance
- Comparison with Test 4A integration

---

## 📊 Results Template

### For Each Test, Record:

**Test Information**:
- Test: [1/2/3/4A/4B]
- Plugin: [SpecKit/SpecSwarm/SpecTest/SpecLab]
- Date: ________
- Tester: ________

**Timeline**:
- Start time: ________
- End time: ________
- Total duration: ________ hours
- Phase breakdown:
  - Constitution: ________ min
  - Specify: ________ min
  - Plan: ________ min
  - Tasks: ________ min
  - Implement: ________ min
  - Testing: ________ min

**Plugin-Specific Metrics**:

*For SpecSwarm:*
- Tech stack auto-detected? ✅/❌
- Tech violations caught: ________
- Drift prevented? ✅/❌

*For SpecTest:*
- Parallel tasks executed: ________
- Average speedup: ________x
- Time saved: ________ min
- Metrics dashboard accessible? ✅/❌

*For SpecLab:*
- Bugfix workflow time: ________ hours
- Modify workflow time: ________ hours
- Regression test quality: ⭐⭐⭐⭐⭐
- Impact analysis accuracy: ⭐⭐⭐⭐⭐

**Quality Metrics**:
- Features completed: ___/4
- Tests passing: ________%
- Code quality: ⭐⭐⭐⭐⭐
- Tech stack compliance: ✅/❌

**User Experience**:
- Workflow ease: ⭐⭐⭐⭐⭐
- Documentation clarity: ⭐⭐⭐⭐⭐
- Error recovery: ⭐⭐⭐⭐⭐
- Integration smoothness: ⭐⭐⭐⭐⭐

**Issues Encountered**:
1. Issue: ________
   Resolution: ________
   Time lost: ________ min

2. Issue: ________
   Resolution: ________
   Time lost: ________ min

**Observations**:
- What worked well?
- What needs improvement?
- Unexpected behaviors?
- Suggestions for refinement?

---

## 📊 Comparison Matrix

### After Completing All Tests:

| Metric | SpecKit | SpecSwarm | SpecTest | SpecLab (4A) |
|--------|---------|-----------|----------|--------------|
| **Time** | _____h | _____h | _____h | _____h |
| **Ease of Use** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Code Quality** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Tech Enforcement** | N/A | _____ violations | _____ violations | _____ violations |
| **Parallel Tasks** | N/A | N/A | _____ tasks | _____ tasks |
| **Parallel Speedup** | N/A | N/A | _____x | _____x |
| **Issues** | _____ | _____ | _____ | _____ |
| **Rework Cycles** | _____ | _____ | _____ | _____ |

### Key Comparisons:

**SpecSwarm vs SpecKit**:
- Time difference: ________ (should be similar)
- Tech drift prevented? ________
- Overhead acceptable? ________

**SpecTest vs SpecSwarm**:
- Time difference: ________ (SpecTest should be 2-4x faster)
- Parallel speedup achieved? ________
- Quality maintained? ________

**SpecLab Integration**:
- Works with SpecTest? ________
- Tech enforcement active? ________
- Parallel execution in lifecycle? ________

---

## ✅ Testing Checklist

### Before Starting:
- [ ] Read [Plugin Testing Guide](plugin-testing-guide.md)
- [ ] Review [Test 3: SpecTest](test-3-spectest.md) workflow
- [ ] Set up test environment (multiple repos)
- [ ] Install required plugins
- [ ] Prepare data collection template

### Phase 1: Feature Development
- [ ] Complete Test 1: SpecKit (~8-10h)
- [ ] Complete Test 2: SpecSwarm (~8-10h)
- [ ] Complete Test 3: SpecTest (~4-6h) ⭐
- [ ] Record all metrics
- [ ] Fill out comparison matrix

### Phase 2A: Lifecycle Workflows
- [ ] Complete Test 4A: SpecLab (~6-8h)
- [ ] Bugfix workflow validated
- [ ] Modify workflow validated
- [ ] Record integration observations

### Phase 2B: Optional
- [ ] Complete Test 4B: SpecLab on SpecSwarm (if needed)

### After Testing:
- [ ] Complete results templates for all tests
- [ ] Fill out comparison matrix
- [ ] Document all issues and suggestions
- [ ] Provide feedback for refinements

---

## 🎯 Success Indicators

### Overall Success:
- [ ] All tests completed without major blockers
- [ ] SpecTest significantly faster than SpecKit/SpecSwarm
- [ ] SpecSwarm caught tech drift (if any)
- [ ] SpecLab workflows completed successfully
- [ ] Integrations worked smoothly
- [ ] Documentation was sufficient

### Red Flags:
- ❌ Tests took longer than expected
- ❌ Parallel execution didn't work
- ❌ Tech stack not detected
- ❌ Major blockers encountered
- ❌ Generated code quality poor
- ❌ Documentation confusing

---

## 🚀 Getting Started

**Ready to begin?**

1. **Start with Test 3** (SpecTest is most important):
   - Follow [Test 3: SpecTest](test-3-spectest.md) step-by-step
   - This creates the base for Phase 2A

2. **Then Test 4A** (SpecLab lifecycle workflows):
   - Use SpecTest build as base
   - Test bugfix + modify workflows

3. **Optionally**: Run Tests 1, 2, and 4B for comprehensive validation

**Timeline**:
- Quick validation (SpecTest + SpecLab): ~10-14 hours
- Comprehensive (all tests): ~26-34 hours

---

## 📚 Additional Resources

### Complete Test Workflows
- [Test 1: SpecKit](test-1-speckit.md) - Baseline SDD methodology
- [Test 2: SpecSwarm](test-2-specswarm.md) - Tech stack enforcement
- [Test 3: SpecTest](test-3-spectest.md) - Parallel execution ⭐
- [Test 4A: SpecLab on SpecTest](test-4a-speclab-spectest.md) - Lifecycle workflows
- [Test 4B: SpecLab on SpecSwarm](test-4b-speclab-specswarm.md) - Optional integration test

### Guides & Cheatsheets
- [Plugin Testing Guide](plugin-testing-guide.md) - Complete overview
- [SpecLab Cheatsheet](../cheatsheets/speclab-cheatsheet.md) - Lifecycle workflows reference
- [Complete Workflow Guide](../cheatsheets/complete-workflow-guide.md) - All plugins

---

**Happy Testing! Your feedback will shape the plugin ecosystem.** 🎉
