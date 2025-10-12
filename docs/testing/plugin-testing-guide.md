# Plugin Testing Guide
## Comprehensive Validation of SpecSwarm Plugin Ecosystem

**Purpose**: Validate all 4 plugins (SpecKit, SpecSwarm, SpecTest, SpecLab) through real-world application development

**Test Project**: Tweeter - a simplified Twitter clone (140 character limit era)

---

## 🎯 Testing Overview

### What We're Testing

**Phase 1: Feature Development** (3 complete builds)
- **Test 1**: SpecKit (baseline - pure SDD methodology)
- **Test 2**: SpecSwarm (tech stack enforcement validation)
- **Test 3**: SpecTest (parallel execution + performance validation)

**Phase 2A: Lifecycle Workflows** (initial validation)
- **Test 4A**: SpecLab on SpecTest build (bugfix + modify workflows)

**Phase 2B: Integration Validation** (optional - if refinements needed)
- **Test 4B**: SpecLab on SpecSwarm build (tech enforcement in lifecycle)

---

## 📋 Test Project: Tweeter

### Product Requirements

**Core Functionality:**
- User signup and signin (authentication)
- Tweet posting (140 character limit)
- Tweet feed (newest first)
- Like tweets
- User profiles (bio, avatar)
- View other user profiles and their tweets

**Style**: Classic Twitter aesthetic (pre-280 character era)

### Technical Stack

**Frontend:**
- React Router v7 (framework mode)
- Programmatic routes (`app/routes.ts` with `RouteConfig`)
- TypeScript
- Tailwind CSS + Flowbite
- Functional programming patterns

**Backend:**
- Express REST APIs
- JWT authentication + httpOnly cookies
- TypeScript
- Functional programming patterns (not OOP)

**Database:**
- PostgreSQL (via Neon)
- 3 tables: profiles, tweets, likes
- postgres npm package (camelCase ↔ snake_case mapping)

**Security & Validation:**
- Zod (frontend UX + backend security)
- @node-rs/argon2 (password hashing)
- uuidv7 (ID generation)

**Storage:**
- Cloudinary (profile avatars)

### Data Schema

```typescript
type Profile = {
  id: string;              // uuidv7
  username: string;        // unique
  email: string;           // unique
  password_hash: string;   // argon2
  bio?: string;           // optional, max 160 chars
  avatar_url?: string;    // Cloudinary URL
  created_at: Date;
};

type Tweet = {
  id: string;              // uuidv7
  profile_id: string;      // FK to profiles
  content: string;         // max 140 chars
  created_at: Date;
};

type Like = {
  id: string;              // uuidv7
  tweet_id: string;        // FK to tweets
  profile_id: string;      // FK to profiles
  created_at: Date;
  // Unique constraint: (tweet_id, profile_id)
};
```

### API Structure

```typescript
// Authentication
POST /api/auth/signup
POST /api/auth/signin
POST /api/auth/signout

// Tweets
GET  /api/tweets           // Get all tweets (feed)
GET  /api/tweets/:id       // Get single tweet
POST /api/tweets           // Create tweet
GET  /api/tweets/user/:username  // Get user's tweets

// Likes
POST /api/likes            // Like a tweet
DELETE /api/likes/:id      // Unlike a tweet

// Profiles
GET  /api/profiles/:username     // Get profile
PUT  /api/profiles/:username     // Update profile
POST /api/profiles/avatar        // Upload avatar
```

### Frontend Routes

```typescript
// app/routes.ts (programmatic)
const routes: RouteConfig[] = [
  { path: '/', component: Landing },              // Public landing
  { path: '/signup', component: Signup },         // Registration
  { path: '/signin', component: Signin },         // Login
  { path: '/feed', component: Feed },             // Main feed (auth required)
  { path: '/profile/:username', component: Profile }, // User profile
  { path: '/settings', component: Settings },     // Edit profile
];
```

---

## 🧪 Testing Methodology

### Test Environment

**Each Test = Separate Repository:**
- Fresh project setup for each test
- Clean slate to avoid cross-contamination
- Independent validation of each plugin

**Initial Setup (Same for All Tests):**
1. Create new repo: `tweeter-[plugin-name]`
2. Initialize with README.md containing project definition
3. Install plugin: `claude plugin install [plugin-name]`
4. Follow test-specific workflow

### Success Metrics

**Quantitative:**
- ⏱️ Time to complete (start to functional app)
- 📊 Lines of code generated
- ✅ Test coverage achieved
- 🚫 Tech stack violations caught (SpecSwarm/SpecTest)
- ⚡ Parallel execution speedup (SpecTest vs SpecSwarm)
- 🔄 Rework cycles (iterations needed)

**Qualitative:**
- 👤 User experience (workflow ease)
- 📚 Documentation clarity
- 🛠️ Error recovery capability
- 🔗 Integration smoothness
- 💡 Suggestions quality

### Data Collection

**For Each Test, Record:**
1. **Start time** (when you begin)
2. **Phase durations** (constitution, specify, plan, tasks, implement)
3. **Issues encountered** (errors, confusion, blockers)
4. **Resolutions** (how issues were solved)
5. **End time** (when app is functional)
6. **Final metrics** (LOC, test coverage, etc.)
7. **User experience notes** (what worked well, what didn't)

**Templates Provided:**
- [Results Template](results-template.md) - Structured data collection
- [Comparison Matrix](comparison-matrix.md) - Side-by-side analysis

---

## 📖 Test Workflows

### Phase 1: Feature Development

**Test 1: SpecKit** ([Full Workflow](test-1-speckit.md))
- **Goal**: Baseline pure SDD methodology
- **Duration**: ~8-10 hours
- **Focus**: Workflow fundamentals, documentation quality
- **Output**: Fully functional Tweeter app

**Test 2: SpecSwarm** ([Full Workflow](test-2-specswarm.md))
- **Goal**: Validate tech stack enforcement
- **Duration**: ~8-10 hours
- **Focus**: Tech drift prevention, auto-detection, conflict resolution
- **Output**: Fully functional Tweeter app + tech stack validation

**Test 3: SpecTest** ([Full Workflow](test-3-spectest.md))
- **Goal**: Validate parallel execution and performance
- **Duration**: ~4-6 hours (should be 2-4x faster)
- **Focus**: Parallel task execution, hooks, metrics dashboard
- **Output**: Fully functional Tweeter app + performance metrics

### Phase 2A: Initial Lifecycle Testing

**Test 4A: SpecLab on SpecTest** ([Full Workflow](test-4a-speclab-spectest.md))
- **Goal**: Validate lifecycle workflows with full stack
- **Duration**: ~6-8 hours
- **Prerequisites**: Complete Test 3 (SpecTest build)
- **Focus**: Bugfix + modify workflows, regression testing, impact analysis
- **Output**: Validated lifecycle workflow processes

### Phase 2B: Integration Validation (Optional)

**Test 4B: SpecLab on SpecSwarm** ([Full Workflow](test-4b-speclab-specswarm.md))
- **Goal**: Validate tech enforcement in lifecycle workflows
- **Duration**: ~6-8 hours
- **Prerequisites**: Complete Test 2 (SpecSwarm build)
- **When**: If issues discovered in Test 4A or integration questions arise
- **Focus**: Tech stack validation during maintenance, SpecLab + SpecSwarm integration
- **Output**: Integration edge case validation

---

## ⏱️ Timeline Estimates

### Conservative (Thorough Testing)

**Phase 1: Feature Development**
- Test 1 (SpecKit): 8-10 hours
- Test 2 (SpecSwarm): 8-10 hours
- Test 3 (SpecTest): 4-6 hours
- **Subtotal**: 20-26 hours

**Phase 2A: Lifecycle Testing**
- Test 4A (SpecLab on SpecTest): 6-8 hours
- **Subtotal**: 6-8 hours

**Phase 2B: Integration Validation (if needed)**
- Test 4B (SpecLab on SpecSwarm): 6-8 hours
- **Subtotal**: 6-8 hours

**Total**: 26-34 hours (Phase 2B optional)

### Per-Test Breakdown

| Test | Setup | Constitution | Features | Total |
|------|-------|--------------|----------|-------|
| SpecKit | 0.5h | 0.5h | 7-9h | 8-10h |
| SpecSwarm | 0.5h | 0.5h | 7-9h | 8-10h |
| SpecTest | 0.5h | 0.5h | 3-5h | 4-6h |
| SpecLab (4A) | - | - | 6-8h | 6-8h |
| SpecLab (4B) | - | - | 6-8h | 6-8h |

---

## 🎯 Success Criteria

### Test 1: SpecKit

**✅ Complete When:**
- [ ] Full Tweeter app functional
- [ ] All core features working (auth, tweets, likes, profiles)
- [ ] Constitution established
- [ ] Specifications clear and complete
- [ ] Technical plans detailed
- [ ] Tasks well-organized
- [ ] Implementation systematic
- [ ] No major blockers encountered

**📊 Metrics to Capture:**
- Time to complete
- Number of spec iterations
- Clarity of guidance
- Quality of generated code

---

### Test 2: SpecSwarm

**✅ Complete When:**
- [ ] Full Tweeter app functional (same features as Test 1)
- [ ] Tech stack auto-detected correctly
- [ ] No tech stack drift occurred
- [ ] Conflicts handled appropriately (if any)
- [ ] `/memory/tech-stack.md` accurate

**📊 Metrics to Capture:**
- Time to complete
- Tech stack violations caught
- Auto-detection accuracy
- Comparison with SpecKit (same features, same time?)

---

### Test 3: SpecTest

**✅ Complete When:**
- [ ] Full Tweeter app functional (same features as Tests 1 & 2)
- [ ] Parallel execution worked correctly
- [ ] Hooks executed at appropriate points
- [ ] Metrics tracked and dashboard accessible
- [ ] Significantly faster than Tests 1 & 2

**📊 Metrics to Capture:**
- Time to complete
- Parallel execution speedup (vs SpecSwarm)
- Number of parallel tasks executed
- Metrics dashboard insights
- Hooks execution log

---

### Test 4A: SpecLab on SpecTest

**✅ Complete When:**
- [ ] Bugfix workflow completed successfully
  - [ ] Regression test created
  - [ ] Test failed before fix (proved bug)
  - [ ] Test passed after fix (proved solution)
  - [ ] No new regressions
- [ ] Modify workflow completed successfully
  - [ ] Impact analysis accurate
  - [ ] Breaking changes identified
  - [ ] Backward compatibility maintained
  - [ ] Migration plan (if needed) executed

**📊 Metrics to Capture:**
- Time for bugfix workflow
- Time for modify workflow
- Quality of regression tests
- Accuracy of impact analysis
- Integration smoothness (SpecTest + SpecSwarm + SpecLab)

---

### Test 4B: SpecLab on SpecSwarm (Optional)

**✅ Complete When:**
- [ ] Same bugfix workflow validates tech enforcement
- [ ] Same modify workflow validates tech enforcement
- [ ] Tech stack compliance maintained during lifecycle workflows

**📊 Metrics to Capture:**
- Tech enforcement during bugfix
- Tech enforcement during modify
- Comparison with Test 4A (integration differences)

---

## 🚨 Common Issues & Troubleshooting

### Issue: Plugin Commands Not Found

**Symptom**: `/speckit.specify` or `/specswarm:specify` not recognized

**Solutions:**
1. Verify plugin installed: `claude plugin list`
2. Reinstall if missing: `claude plugin install [plugin-name]`
3. Check spelling (`.` vs `:` - SpecKit uses `.`, others use `:`)

---

### Issue: Auto-Detection Not Working (SpecSwarm)

**Symptom**: Tech stack not detected from README.md

**Solutions:**
1. Ensure README.md contains clear tech mentions
2. Re-run `/specswarm:plan` to trigger detection
3. Manually review `/memory/tech-stack.md` if created

---

### Issue: Parallel Execution Not Triggering (SpecTest)

**Symptom**: Tasks running sequentially instead of parallel

**Solutions:**
1. Verify tasks marked with `[P]` in tasks.md
2. Check for file conflicts (same file = sequential)
3. Review SpecTest README for parallel execution requirements

---

### Issue: SpecLab Not Detecting Integration

**Symptom**: "Running in basic mode" instead of detecting SpecSwarm/SpecTest

**Solutions:**
1. Verify SpecSwarm and/or SpecTest installed
2. Check `claude plugin list` output
3. Try running workflow again (detection happens at start)

---

### Issue: Workflow Stuck or Unclear

**Symptom**: Claude Code waiting for input, unclear what to do next

**Solutions:**
1. Review current phase in workflow doc
2. Check "Expected Outcome" section
3. Provide additional context if prompted
4. Skip to next step if stuck (document issue)

---

## 📊 Analysis & Comparison

### After Completing Tests

**Compare Results:**
1. Fill out [Comparison Matrix](comparison-matrix.md)
2. Analyze time differences
3. Identify plugin strengths/weaknesses
4. Document unexpected behaviors
5. Note user experience insights

**Key Comparisons:**
- **SpecKit vs SpecSwarm**: Does tech enforcement add overhead?
- **SpecSwarm vs SpecTest**: How much faster is parallel execution?
- **SpecTest + SpecLab**: Do integrations work smoothly?
- **SpecSwarm + SpecLab**: Does tech enforcement work in lifecycle?

**Expected Outcomes:**
- SpecTest should be ~2-4x faster than SpecSwarm
- SpecSwarm should catch tech drift if it occurs
- SpecLab should integrate seamlessly with both
- All plugins should produce functional applications

---

## 🔄 Iteration & Refinement

### After Testing

**If Issues Found:**
1. Document issues in [Results Template](results-template.md)
2. Categorize: Bug, UX issue, Documentation gap, etc.
3. Prioritize by severity and impact
4. Create refinement tasks

**Feedback Loop:**
1. Test → Document issues → Refine → Re-test
2. Focus on highest-impact improvements first
3. Validate fixes don't introduce new issues

**Success Indicators:**
- Tests complete without blockers
- Workflows are intuitive
- Generated code is high quality
- Integration works smoothly
- Documentation is clear and sufficient

---

## 📚 Resources

### Documentation
- [SpecKit README](../../plugins/speckit/README.md)
- [SpecSwarm README](../../plugins/specswarm/README.md)
- [SpecTest README](../../plugins/spectest/README.md)
- [SpecLab README](../../plugins/speclab/README.md)
- [Complete Workflow Guide](../cheatsheets/complete-workflow-guide.md)
- [SpecLab Cheatsheet](../cheatsheets/speclab-cheatsheet.md)

### Test Workflows
- [Test 1: SpecKit](test-1-speckit.md)
- [Test 2: SpecSwarm](test-2-specswarm.md)
- [Test 3: SpecTest](test-3-spectest.md)
- [Test 4A: SpecLab on SpecTest](test-4a-speclab-spectest.md)
- [Test 4B: SpecLab on SpecSwarm](test-4b-speclab-specswarm.md)

### Templates
- [Results Template](results-template.md)
- [Comparison Matrix](comparison-matrix.md)

---

## 🚀 Getting Started

**Ready to begin testing?**

1. **Choose your first test**: [Test 1: SpecKit](test-1-speckit.md)
2. **Set up environment**: Create new repo, install plugin
3. **Follow workflow**: Step-by-step prompts provided
4. **Record results**: Use [Results Template](results-template.md)
5. **Move to next test**: Repeat for all tests
6. **Analyze**: Complete [Comparison Matrix](comparison-matrix.md)
7. **Provide feedback**: Document findings and suggestions

**Timeline**: Plan for 26-34 hours total (can be spread over multiple sessions)

**Questions?** Refer to individual test workflows for detailed guidance.

---

**Happy Testing! Your feedback will help refine the plugin ecosystem.** 🎉
