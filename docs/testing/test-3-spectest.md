# Test 3: SpecTest Workflow
## Build Tweeter with Parallel Execution + Performance Metrics

**Plugin**: SpecTest
**Goal**: Validate parallel execution (2-4x speedup), hooks, and metrics dashboard
**Expected Duration**: 4-6 hours (should be significantly faster than SpecKit/SpecSwarm)
**Prerequisites**: None (fresh build)

---

## 📋 Overview

**What This Tests:**
- ✅ Parallel task execution (2-4x faster implementation)
- ✅ Pre/post operation hooks at each phase
- ✅ Performance metrics tracking
- ✅ Metrics dashboard (`/spectest:metrics`)
- ✅ Tech stack enforcement (inherited from SpecSwarm)
- ✅ Complete Tweeter app functionality

**Success Metrics:**
- ⏱️ Total time < 6 hours (vs ~8-10h for SpecKit/SpecSwarm)
- ⚡ Parallel execution speedup visible in implementation phase
- 📊 Metrics dashboard populated with data
- 🎯 Hooks execute at appropriate phases
- ✅ Full app functional

**⚠️ Feature Scope Guidance:**
- **Target**: Each feature should be 8-12 hours of implementation work
- **If scope is too large**: Accept MVP approach (partial feature implementation)
- **Document**: Record scope issues in test-3-results.md under "Issues Encountered"
- **Learning**: This is valuable test feedback about feature sizing

---

## 🚀 Setup

### Step 1: Create Repository

```bash
# Create new directory
mkdir tweeter-spectest
cd tweeter-spectest

# Initialize git
git init

# Create README.md with project definition
```

### Step 2: Create README.md

**Paste this content into README.md:**

```markdown
# Tweeter

A simplified Twitter clone styled like the 140-character era.

## Features

- User signup and signin (authentication)
- Tweet posting (140 character limit)
- Tweet feed (newest first)
- Like tweets
- User profiles (bio, avatar)
- View other user profiles and their tweets

## Tech Stack

### Frontend
- React Router v7 (framework mode)
- Programmatic routes (app/routes.ts with RouteConfig - NOT file-based)
- TypeScript
- Functional programming patterns (not OOP)
- Tailwind CSS + Flowbite
- Zod validation

### Backend
- Express REST APIs
- JWT authentication + httpOnly cookies
- TypeScript
- Functional programming patterns (not OOP)
- Zod validation

### Database
- PostgreSQL (via Neon)
- postgres npm package (camelCase ↔ snake_case mapping)
- 3 tables: profiles, tweets, likes
- uuidv7 for IDs

### Security
- @node-rs/argon2 (password hashing)
- Zod (frontend UX + backend security)

### Storage
- Cloudinary (profile avatars)

## Data Structure

**Profile:**
- id (uuidv7)
- username (unique)
- email (unique)
- password_hash (argon2)
- bio (optional, max 160 chars)
- avatar_url (optional, Cloudinary)
- created_at

**Tweet:**
- id (uuidv7)
- profile_id (FK to profiles)
- content (max 140 chars)
- created_at

**Like:**
- id (uuidv7)
- tweet_id (FK to tweets)
- profile_id (FK to profiles)
- created_at
- Unique constraint: (tweet_id, profile_id)

## API Structure

### Authentication
- POST /api/auth/signup
- POST /api/auth/signin
- POST /api/auth/signout

### Tweets
- GET  /api/tweets (feed)
- GET  /api/tweets/:id
- POST /api/tweets
- GET  /api/tweets/user/:username

### Likes
- POST   /api/likes
- DELETE /api/likes/:id

### Profiles
- GET  /api/profiles/:username
- PUT  /api/profiles/:username
- POST /api/profiles/avatar

## Frontend Routes (Programmatic)

```typescript
// app/routes.ts
const routes: RouteConfig[] = [
  { path: '/', component: Landing },
  { path: '/signup', component: Signup },
  { path: '/signin', component: Signin },
  { path: '/feed', component: Feed },
  { path: '/profile/:username', component: Profile },
  { path: '/settings', component: Settings },
];
```

## Development

- Local testing only
- PostgreSQL via Neon
- Cloudinary for avatars
```

**Save and commit:**
```bash
git add README.md
git commit -m "docs: initial project definition"
```

### Step 3: Install SpecTest Plugin

```bash
claude plugin install spectest
```

**Expected output:**
```
✓ Plugin installed: spectest
```

### Step 4: Record Start Time

**📝 Note your start time**: ________ (e.g., 2:00 PM)

---

## 🏗️ Phase 1: Constitution

### Prompt 1: Establish Project Principles

**Paste into Claude Code:**

```
Let's establish the project constitution. This project follows functional programming patterns, uses React Router v7 in framework mode with programmatic routes (NOT file-based), and emphasizes type safety with TypeScript and Zod validation.

Key principles:
1. Functional programming over OOP
2. Type safety (TypeScript + Zod)
3. Programmatic routing (app/routes.ts with RouteConfig)
4. Security-first (argon2, JWT, httpOnly cookies)
5. Modern React patterns (hooks, composition)

/spectest:constitution
```

**Expected Outcome:**
- Claude creates `/memory/constitution.md`
- Constitution includes tech stack principles
- Project principles documented
- Functional programming emphasized

**⏱️ Record constitution time**: ________ minutes

**📝 Notes:**
- Did constitution capture all key principles?
- Was tech stack mentioned appropriately?
- Any clarifications needed?

---

## 📝 Phase 2: Feature Specifications

Build Tweeter incrementally with these features:

**💡 Feature Sizing Tip:**
When specifying features, aim for **8-12 hours of implementation work** per feature. If Claude indicates scope is too large (>15 hours), accept an MVP approach or split the feature. This is a normal part of testing and provides valuable feedback.

---

### Feature 001: Authentication System

**Prompt 2: Specify Authentication**

```
Let's build the authentication system first.

/spectest:specify Create user authentication system with signup and signin functionality. Users should be able to create accounts with username/email/password, sign in with email/password, and sign out. Use JWT tokens stored in httpOnly cookies for session management. Passwords must be hashed with argon2. Include form validation with Zod on both frontend and backend.
```

**Expected Outcome:**
```
🎣 Pre-Specify Hook
✓ Repository detected: Git
✓ Tech stack file: Will be created
✓ Constitution found: /memory/constitution.md
✓ Ready to specify feature

[Claude creates features/001-authentication/spec.md]

🎣 Post-Specify Hook
✓ Spec quality score: [N]/100
✓ No [NEEDS CLARIFICATION] markers
✓ All mandatory sections complete
⚡ Next step: Run /spectest:plan
```

**📝 Notes:**
- Hooks executed? (pre/post)
- Spec quality score?
- Any clarifications needed?

---

### Feature 002: Tweet System

**Prompt 3: Specify Tweets**

```
/spectest:specify Create tweet posting and feed system. Authenticated users can post tweets (max 140 characters), view a feed of all tweets (newest first), and see individual tweets. Validate tweet length with Zod on frontend and backend. Use PostgreSQL for storage with uuidv7 IDs.
```

**Expected Outcome:**
- Hooks execute (pre/post)
- Spec created: `features/002-tweets/spec.md`
- Quality validation passes

---

### Feature 003: Like System

**Prompt 4: Specify Likes**

```
/spectest:specify Create like functionality. Users can like/unlike tweets. Each user can like a tweet only once (unique constraint on tweet_id + profile_id). Display like counts on tweets. Update in real-time when user toggles like.
```

---

### Feature 004: User Profiles

**Prompt 5: Specify Profiles**

```
/spectest:specify Create user profile system. Users have profiles with username, bio (optional, max 160 chars), and avatar (optional, uploaded to Cloudinary). Users can view their own profile, edit bio/avatar, and view other users' profiles. Profile pages show user's tweets.
```

**⏱️ Record total specify time**: ________ minutes (all 4 features)

---

## 🎯 Phase 3: Technical Planning

### Plan Feature 001: Authentication

**Prompt 6: Plan Authentication**

```
/spectest:plan features/001-authentication
```

**Expected Outcome:**
```
🎣 Pre-Plan Hook
✓ Spec loaded: features/001-authentication/spec.md
✓ Tech stack: Auto-detecting from README.md
✓ Validating against constitution

[Claude creates features/001-authentication/plan.md]
[Claude creates/updates /memory/tech-stack.md]

🎣 Post-Plan Hook
✓ Plan quality: [assessment]
✓ Tech stack detected:
  - React Router v7 (framework mode)
  - Express
  - TypeScript
  - PostgreSQL (Neon)
  - JWT + argon2
  - Zod
✓ Constitution compliance: Verified
✓ Tech stack summary generated

⚡ Next step: Run /spectest:tasks
```

**📝 Notes:**
- Tech stack auto-detected correctly?
- Plan includes programmatic routing?
- Functional programming patterns emphasized?

---

### Plan Features 002-004

**Prompt 7-9: Plan Remaining Features**

```
/spectest:plan features/002-tweets
```

```
/spectest:plan features/003-likes
```

```
/spectest:plan features/004-profiles
```

**Expected Outcome (each):**
- Hooks execute (pre/post)
- Plan created
- Tech stack validated
- No drift detected

**⏱️ Record total plan time**: ________ minutes (all 4 features)

---

## ✅ Phase 4: Task Generation

### Generate Tasks for Feature 001

**Prompt 10: Generate Auth Tasks**

```
/spectest:tasks features/001-authentication
```

**Expected Outcome:**
```
🎣 Pre-Tasks Hook
✓ Plan loaded: features/001-authentication/plan.md
✓ Analyzing for parallel opportunities
✓ Constitution principles loaded

[Claude creates features/001-authentication/tasks.md]

📊 Parallel Detection Results:
- Total tasks: [N]
- Sequential tasks: [N] (foundational, dependencies)
- Parallel tasks: [N] marked with [P]
- Estimated speedup: [X]x (if all parallel tasks batched)

🎣 Post-Tasks Hook
✓ Tasks generated: [N] total
✓ Parallel opportunities: [N] tasks
✓ Dependency order: Validated
✓ Execution preview:
  Phase 1: Setup (sequential)
  Phase 2: Implementation ([N] parallel tasks)
  Phase 3: Integration (sequential)

⚡ Next step: Run /spectest:implement
```

**📝 Notes:**
- How many parallel tasks detected?
- Execution preview look correct?

---

### Generate Tasks for Features 002-004

**Prompt 11-13:**

```
/spectest:tasks features/002-tweets
```

```
/spectest:tasks features/003-likes
```

```
/spectest:tasks features/004-profiles
```

**⏱️ Record total tasks time**: ________ minutes (all 4 features)

---

## ⚡ Phase 5: Implementation (Parallel Execution)

**This is where SpecTest's parallel execution shines!**

### Implement Feature 001: Authentication

**Prompt 14: Implement Auth**

```
/spectest:implement features/001-authentication
```

**⚠️ If Scope is Too Large:**

If Claude indicates the feature has too many tasks (>40 tasks or >15 hours):
1. **Accept the MVP approach** Claude suggests (e.g., "Phase 1-3 only")
2. **Document in test-3-results.md** under "Issues Encountered"
3. **Continue with reduced scope** - this validates the workflow with realistic constraints
4. **Learning**: Feature specs should target 8-12 hour implementations

**Expected Outcome:**
```
🎣 Pre-Implement Hook
✓ All checklist items complete
✓ Tech stack validated
✓ Environment ready
✓ Metrics initialized

📋 Executing Tasks ([N] tasks across [M] phases)

Phase 1: Setup (sequential)
  → T001: Initialize project structure
  ✓ Complete

  → T002: Configure database
  ✓ Complete

Phase 2: Core Implementation ([N] tasks - PARALLEL BATCH)
  ⚡ Executing [N] tasks in parallel...

  → T003-T008: [parallel tasks]
  ✓ All tasks complete (2m 15s vs ~12m sequential = 5.3x faster)

Phase 3: Integration (sequential)
  → T009: Integrate authentication flow
  ✓ Complete

🎣 Post-Implement Hook
✓ All [N] tasks completed
✓ No violations detected
✓ Tests passing: [N]/[N]
📊 Metrics saved to /memory/metrics.json

⚡ Performance:
- Total time: [time]
- Parallel speedup: [X]x faster
- Tasks executed in parallel: [N]

✅ Feature complete!
```

**📝 Critical Notes:**
- ⚡ **Parallel execution triggered?**
- ⏱️ **Time for parallel batch vs estimated sequential?**
- 📊 **Speedup factor achieved?**
- ✅ **All tests passing?**

---

### Implement Features 002-004

**Prompt 15-17:**

```
/spectest:implement features/002-tweets
```

**Expected parallel execution in tweet implementation phase**

---

**💡 Consider /compact (Midpoint):**

If your conversation has been running for ~2 hours with many messages, consider running:
```
/compact
```

This will:
- ✅ Preserve all project files and state
- ✅ Summarize conversation history
- ✅ Keep Claude responsive for remaining features
- ✅ Maintain context for Features 3 & 4

**Continue after compact (if used):**

---

```
/spectest:implement features/003-likes
```

**Expected parallel execution in like implementation phase**

```
/spectest:implement features/004-profiles
```

**Expected parallel execution in profile implementation phase (avatar upload, profile views, etc.)**

**⏱️ Record total implement time**: ________ minutes (all 4 features)

**📝 Critical Observations:**
- Total parallel tasks executed: ________
- Average parallel speedup: ________x
- Longest parallel batch: ________ tasks
- Total implementation time vs estimated sequential: ________

---

**💡 Consider /compact (After All Features):**

If you haven't compacted yet and your conversation is long (>150 messages), consider running:
```
/compact
```

This will prepare Claude for the final testing and validation phases with a fresh context window.

---

## 📊 Phase 6: View Performance Metrics

### Check Metrics Dashboard

**Prompt 18: View Dashboard**

```
/spectest:metrics
```

**Expected Outcome:**
```
📊 SpecTest Performance Metrics Dashboard

Last 30 Days (or since project start):

Summary:
- Total features: 4
- Total tasks: [N]
- Parallel tasks: [N]
- Average speedup: [X]x

Feature Breakdown:
┌─────────────────┬──────────┬─────────┬──────────────┐
│ Feature         │ Duration │ Tasks   │ Parallel     │
├─────────────────┼──────────┼─────────┼──────────────┤
│ 001-auth        │ [time]   │ [N]     │ [N] ([X]x)   │
│ 002-tweets      │ [time]   │ [N]     │ [N] ([X]x)   │
│ 003-likes       │ [time]   │ [N]     │ [N] ([X]x)   │
│ 004-profiles    │ [time]   │ [N]     │ [N] ([X]x)   │
└─────────────────┴──────────┴─────────┴──────────────┘

Performance Insights:
• Parallel execution saved: ~[time]
• Average parallel speedup: [X]x
• Most parallel tasks: Feature [NNN] ([N] tasks)

vs. Sequential Estimate: [X]x faster overall ⚡
```

**📝 Record Metrics:**
- Total duration: ________
- Parallel tasks executed: ________
- Average speedup: ________x
- Total time saved: ________

---

### Check Individual Feature Metrics

**Prompt 19: Detail View**

```
/spectest:metrics 001
```

**Expected:** Detailed metrics for authentication feature

**Repeat for other features if interested:**
```
/spectest:metrics 002
/spectest:metrics 003
/spectest:metrics 004
```

---

## ✅ Phase 7: Final Validation

### Test the Application

**Prompt 20: Manual Testing**

**Test checklist:**

```
Please help me test the Tweeter application. Let's verify:

1. **Authentication:**
   - [ ] Signup with new user works
   - [ ] Signin with correct credentials works
   - [ ] Signin with wrong password fails
   - [ ] Signout works
   - [ ] JWT token stored in httpOnly cookie

2. **Tweets:**
   - [ ] Post tweet (under 140 chars) works
   - [ ] Post tweet (over 140 chars) fails with validation
   - [ ] Feed shows tweets newest first
   - [ ] Individual tweet view works

3. **Likes:**
   - [ ] Like tweet works
   - [ ] Unlike tweet works
   - [ ] Like count updates
   - [ ] Can't like same tweet twice

4. **Profiles:**
   - [ ] View own profile works
   - [ ] Edit bio works (under 160 chars)
   - [ ] Upload avatar to Cloudinary works
   - [ ] View other user's profile works
   - [ ] Profile shows user's tweets

Please run the app and verify these features.
```

**Manual Steps:**
```bash
# Start development server
npm run dev

# Open http://localhost:3000
# Follow test checklist above
```

**📝 Record test results:**
- All features working? ________
- Any bugs found? ________
- Performance acceptable? ________

---

## 📋 Final Data Collection

### Record End Time

**📝 End time**: ________ (e.g., 6:45 PM)

**⏱️ Total duration**: ________ hours

---

### Complete Results Template

**Use [Results Template](results-template.md) to record:**

1. **Timeline:**
   - Start: ________
   - End: ________
   - Total: ________ hours
   - Constitution: ________ min
   - Specify (all): ________ min
   - Plan (all): ________ min
   - Tasks (all): ________ min
   - Implement (all): ________ min
   - Testing/validation: ________ min

2. **Parallel Execution:**
   - Total parallel tasks: ________
   - Average speedup: ________x
   - Time saved: ________ min
   - Longest parallel batch: ________ tasks

3. **Quality Metrics:**
   - Features completed: 4/4
   - Tests passing: ________%
   - Tech stack violations: ________
   - Constitution compliance: ✅/❌

4. **User Experience:**
   - Workflow ease: ⭐⭐⭐⭐⭐ (rate 1-5)
   - Documentation clarity: ⭐⭐⭐⭐⭐
   - Error recovery: ⭐⭐⭐⭐⭐
   - Integration smoothness: ⭐⭐⭐⭐⭐

5. **Issues Encountered:**
   - Issue 1: ________
   - Resolution: ________
   - Issue 2: ________
   - Resolution: ________

6. **Observations:**
   - What worked well?
   - What needs improvement?
   - Unexpected behaviors?
   - Suggestions for refinement?

---

## ✅ Success Criteria

### Test Complete When:

- [x] All 4 features implemented and functional
- [x] Total time < 6 hours (significantly less than ~8-10h baseline)
- [x] Parallel execution triggered in implementation phases
- [x] Metrics dashboard populated and accessible
- [x] Hooks executed at appropriate points
- [x] Tech stack auto-detected correctly
- [x] No tech stack drift occurred
- [x] Application fully functional (all tests pass)

### Key Metrics Captured:

- [x] Total duration: ________ hours
- [x] Parallel speedup: ________x
- [x] Time saved vs sequential: ________ minutes
- [x] Parallel tasks executed: ________
- [x] Tech stack violations: ________

---

## 🔄 Next Steps

**After completing this test:**

1. **Fill out [Results Template](results-template.md)**
2. **Save all artifacts:**
   - `/memory/constitution.md`
   - `/memory/tech-stack.md`
   - `/memory/metrics.json`
   - All `features/*/` directories
3. **Commit final state:**
   ```bash
   git add .
   git commit -m "test: complete SpecTest validation"
   ```
4. **💡 /compact before Test 4A:**
   - **Strongly recommended:** Run `/compact` to summarize Test 3
   - This gives you a fresh start for Test 4A lifecycle workflows
   - Your Test 3 project state is fully preserved
5. **Proceed to Phase 2A:**
   - [Test 4A: SpecLab on SpecTest](test-4a-speclab-spectest.md)
   - Use this build as base for lifecycle workflows

---

## 🎉 Test Complete!

**You've validated SpecTest's core capabilities:**
- ✅ Parallel execution (2-4x faster)
- ✅ Hooks system
- ✅ Performance metrics
- ✅ Tech stack enforcement
- ✅ Complete application development

**Key Takeaway:**
SpecTest should have been significantly faster than SpecKit/SpecSwarm due to parallel execution. If not, document why and investigate.

**Ready for lifecycle testing?** → [Test 4A: SpecLab on SpecTest](test-4a-speclab-spectest.md)
