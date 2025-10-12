# Test 1: SpecKit (Baseline)
## Pure SDD Methodology Validation

**Purpose**: Establish baseline for Specification-Driven Development (SDD) workflow by building complete Tweeter application

**Expected Duration**: ~8-10 hours

**Plugin**: SpecKit (original SDD workflow)

---

## 🎯 Test Objectives

### Primary Goals:
1. Validate pure SDD methodology without enhancements
2. Establish baseline metrics for comparison
3. Test complete feature development workflow
4. Assess documentation clarity and user experience

### What We're Measuring:
- ⏱️ Time to complete full application
- 📝 Quality of generated specifications
- 🏗️ Quality of technical plans
- ✅ Task organization effectiveness
- 💻 Generated code quality
- 🔄 Number of iterations/rework cycles
- 👤 Overall user experience

---

## 📋 Prerequisites

### Required Tools:
- Claude Code CLI installed
- Git initialized repository
- SpecKit plugin installed

### Installation:
```bash
# Install SpecKit plugin
claude plugin install speckit

# Verify installation
claude plugin list
# Should show: speckit v1.0.0
```

---

## 🚀 Test Workflow

### Phase 0: Repository Setup

#### Step 1: Create Test Repository

```bash
# Create new directory
mkdir tweeter-speckit
cd tweeter-speckit

# Initialize git
git init

# Create initial README.md
touch README.md
```

#### Step 2: Define Project in README.md

**Open README.md and add:**

```markdown
# Tweeter

A simplified Twitter clone from the 140-character limit era.

## Product Vision

Tweeter is a social microblogging platform where users can share short thoughts and interact with others' content. It captures the essence of early Twitter with its 140-character limit, focusing on concise communication and real-time social interaction.

## Core Features

### 1. User Authentication
- User signup with username, email, and password
- User signin with email and password
- Secure session management
- User signout

### 2. Tweet Management
- Create tweets (max 140 characters)
- View tweet feed (newest first)
- View individual tweets
- View user's tweet history

### 3. Social Interactions
- Like tweets
- Unlike tweets
- View like counts

### 4. User Profiles
- User profile pages with bio and avatar
- Edit profile (bio, avatar)
- View other users' profiles
- View user's tweets on their profile

## Technical Stack

### Frontend
- React Router v7 (framework mode)
- Programmatic routes (app/routes.ts with RouteConfig)
- TypeScript
- Tailwind CSS + Flowbite
- Zod validation
- Functional programming patterns

### Backend
- Express REST APIs
- TypeScript
- JWT authentication with httpOnly cookies
- Zod validation
- Functional programming patterns (not OOP)

### Database
- PostgreSQL (via Neon)
- postgres npm package (camelCase ↔ snake_case mapping)
- 3 tables: profiles, tweets, likes

### Security & Validation
- @node-rs/argon2 (password hashing)
- Zod (frontend UX + backend security)
- uuidv7 (ID generation)

### Storage
- Cloudinary (profile avatars)

## Data Schema

### Profile
- id (string, uuidv7, primary key)
- username (string, unique)
- email (string, unique)
- password_hash (string, argon2)
- bio (string, optional, max 160 chars)
- avatar_url (string, optional, Cloudinary URL)
- created_at (timestamp)

### Tweet
- id (string, uuidv7, primary key)
- profile_id (string, foreign key to profiles)
- content (string, max 140 chars)
- created_at (timestamp)

### Like
- id (string, uuidv7, primary key)
- tweet_id (string, foreign key to tweets)
- profile_id (string, foreign key to profiles)
- created_at (timestamp)
- Unique constraint: (tweet_id, profile_id)

## Authentication Pattern

Following the commonality project approach:
- JWT tokens stored in httpOnly cookies
- Secure token generation and validation
- Protected route middleware
- Automatic token refresh

## API Structure

### Authentication
- POST /api/auth/signup
- POST /api/auth/signin
- POST /api/auth/signout

### Tweets
- GET /api/tweets (get all tweets for feed)
- GET /api/tweets/:id (get single tweet)
- POST /api/tweets (create tweet)
- GET /api/tweets/user/:username (get user's tweets)

### Likes
- POST /api/likes (like a tweet)
- DELETE /api/likes/:id (unlike a tweet)

### Profiles
- GET /api/profiles/:username (get profile)
- PUT /api/profiles/:username (update profile)
- POST /api/profiles/avatar (upload avatar)

## Frontend Routes

Programmatic routing (app/routes.ts):
- / (landing page, public)
- /signup (registration)
- /signin (login)
- /feed (main feed, auth required)
- /profile/:username (user profile)
- /settings (edit profile, auth required)

## Style Guidelines

- Classic Twitter aesthetic (pre-280 character era)
- Blue and white color scheme
- Clean, minimalist design
- Responsive layout
- Focus on readability and usability
```

**Commit the README:**
```bash
git add README.md
git commit -m "Initial project definition for Tweeter"
```

**Expected Outcome:**
- ✅ Repository initialized
- ✅ README.md with complete project definition
- ✅ Initial commit created

---

### Phase 1: Constitution Setup

#### Step 3: Create Project Constitution

**Prompt 1: Establish Constitution**

```
/speckit.constitution
```

**What Claude Will Do:**
1. Read your README.md
2. Extract project requirements
3. Create constitution with:
   - Project mission
   - Core principles
   - Development standards
   - Quality criteria
   - Success metrics

**Expected Outcome:**
```
✓ Constitution created: /memory/constitution.md
✓ Project mission defined
✓ Core principles established
✓ Development standards set
✓ Quality criteria documented
```

**What to Observe:**
- Does constitution align with README.md?
- Are technical standards clear?
- Are quality criteria reasonable?
- Is success measurable?

**Record:**
- Time spent: _____ minutes
- Iterations needed: _____
- Constitution quality: ⭐⭐⭐⭐⭐

---

### Phase 2: Feature Development

You'll build 4 features in sequence:
1. **Authentication** (signup, signin, signout)
2. **Tweets** (create, view feed, view single)
3. **Likes** (like, unlike tweets)
4. **Profiles** (view, edit, avatar upload)

#### Feature 1: Authentication

**Prompt 2: Specify Authentication**

```
/speckit.specify Create user authentication system with signup and signin functionality. Users should be able to create accounts with username/email/password, sign in with email/password, and sign out. Use JWT tokens stored in httpOnly cookies for session management. Passwords must be hashed with argon2. Include form validation with Zod on both frontend and backend.
```

**Expected Outcome:**
```
✓ Spec created: features/001-authentication/spec.md
✓ Functional requirements documented
✓ Technical requirements defined
✓ Success criteria established
✓ User flows described
```

**What to Review:**
- Are requirements clear and complete?
- Is technical approach sound?
- Are edge cases considered?
- Is validation comprehensive?

---

**Prompt 3: Plan Authentication**

```
/speckit.plan features/001-authentication
```

**Expected Outcome:**
```
✓ Plan created: features/001-authentication/plan.md
✓ Database schema defined (Profile table)
✓ API endpoints planned (signup, signin, signout)
✓ Frontend components planned (SignupForm, SigninForm, auth context)
✓ Routes planned (/signup, /signin)
✓ Integration points identified
✓ Testing strategy outlined
```

**What to Review:**
- Is architecture appropriate?
- Are all components identified?
- Is database schema correct?
- Are integration points clear?

---

**Prompt 4: Generate Tasks**

```
/speckit.tasks features/001-authentication
```

**Expected Outcome:**
```
✓ Tasks created: features/001-authentication/tasks.md
✓ Tasks organized by component
✓ Dependencies identified
✓ Acceptance criteria for each task
✓ Estimated 8-12 tasks
```

**What to Review:**
- Are tasks granular enough?
- Are dependencies correct?
- Is order logical?
- Are acceptance criteria clear?

---

**Prompt 5: Implement Authentication**

```
/speckit.implement features/001-authentication
```

**Expected Outcome:**
```
✓ Database migration created (profiles table)
✓ Backend API endpoints implemented
✓ Frontend components created
✓ Routes configured
✓ Validation schemas defined
✓ Auth context/hooks created
✓ All tasks completed
```

**What to Test:**
1. Open the application
2. Navigate to /signup
3. Create a test account
4. Sign out
5. Sign in with same credentials
6. Verify session persists

**Record:**
- Time spent: _____ minutes
- Tasks completed: _____ / _____
- Issues encountered: _____
- Code quality: ⭐⭐⭐⭐⭐

---

#### Feature 2: Tweets

**Prompt 6: Specify Tweets**

```
/speckit.specify Create tweet management system. Users should be able to create tweets (max 140 characters), view a feed of all tweets (newest first), and view individual tweets. Tweets should display the author's username, content, timestamp, and like count. Include validation for character limit on both frontend and backend.
```

**Expected Outcome:**
```
✓ Spec created: features/002-tweets/spec.md
✓ Tweet creation flow documented
✓ Feed display requirements defined
✓ Character limit validation specified
✓ Data display requirements clear
```

---

**Prompt 7: Plan Tweets**

```
/speckit.plan features/002-tweets
```

**Expected Outcome:**
```
✓ Plan created: features/002-tweets/plan.md
✓ Database schema defined (Tweet table with foreign key to Profile)
✓ API endpoints planned (create, get all, get by id, get by user)
✓ Frontend components planned (TweetForm, TweetFeed, TweetCard)
✓ Routes planned (/feed)
✓ Integration with auth system
```

---

**Prompt 8: Generate Tasks**

```
/speckit.tasks features/002-tweets
```

**Expected Outcome:**
```
✓ Tasks created: features/002-tweets/tasks.md
✓ Database tasks (migration)
✓ Backend tasks (API endpoints)
✓ Frontend tasks (components, routes)
✓ Integration tasks (auth protection)
✓ Estimated 10-14 tasks
```

---

**Prompt 9: Implement Tweets**

```
/speckit.implement features/002-tweets
```

**Expected Outcome:**
```
✓ Database migration created (tweets table)
✓ Backend API endpoints implemented
✓ Frontend components created
✓ Feed route configured (/feed)
✓ Auth protection added
✓ Character limit validation implemented
✓ All tasks completed
```

**What to Test:**
1. Sign in to your test account
2. Navigate to /feed
3. Create a tweet (within 140 chars)
4. Try to create tweet over 140 chars (should fail)
5. Verify tweet appears in feed
6. Create several tweets
7. Verify newest appears first

**Record:**
- Time spent: _____ minutes
- Tasks completed: _____ / _____
- Issues encountered: _____
- Code quality: ⭐⭐⭐⭐⭐

---

#### Feature 3: Likes

**Prompt 10: Specify Likes**

```
/speckit.specify Create like functionality for tweets. Users should be able to like and unlike tweets. Each tweet should display its like count. A user can only like a tweet once. Likes should update in real-time without page refresh. Include optimistic UI updates.
```

**Expected Outcome:**
```
✓ Spec created: features/003-likes/spec.md
✓ Like/unlike flow documented
✓ Unique constraint specified
✓ UI update behavior defined
✓ Optimistic update strategy described
```

---

**Prompt 11: Plan Likes**

```
/speckit.plan features/003-likes
```

**Expected Outcome:**
```
✓ Plan created: features/003-likes/plan.md
✓ Database schema defined (Like table with unique constraint)
✓ API endpoints planned (create like, delete like)
✓ Frontend updates planned (TweetCard modifications)
✓ Optimistic UI strategy detailed
```

---

**Prompt 12: Generate Tasks**

```
/speckit.tasks features/003-likes
```

**Expected Outcome:**
```
✓ Tasks created: features/003-likes/tasks.md
✓ Database tasks (migration with unique constraint)
✓ Backend tasks (API endpoints)
✓ Frontend tasks (UI updates, optimistic updates)
✓ Estimated 6-8 tasks
```

---

**Prompt 13: Implement Likes**

```
/speckit.implement features/003-likes
```

**Expected Outcome:**
```
✓ Database migration created (likes table)
✓ Backend API endpoints implemented
✓ TweetCard component updated
✓ Optimistic UI implemented
✓ Like state management added
✓ All tasks completed
```

**What to Test:**
1. View tweet feed
2. Like a tweet
3. Verify like count increases
4. Unlike the same tweet
5. Verify like count decreases
6. Try to like same tweet twice (should toggle)
7. Check database for unique constraint

**Record:**
- Time spent: _____ minutes
- Tasks completed: _____ / _____
- Issues encountered: _____
- Code quality: ⭐⭐⭐⭐⭐

---

#### Feature 4: Profiles

**Prompt 14: Specify Profiles**

```
/speckit.specify Create user profile system. Users should be able to view their own profile and other users' profiles. Profiles should display username, bio (optional, max 160 chars), avatar (optional), and user's tweets. Users should be able to edit their own bio and upload an avatar image. Avatar images should be stored in Cloudinary. Include settings page for profile editing.
```

**Expected Outcome:**
```
✓ Spec created: features/004-profiles/spec.md
✓ Profile view requirements documented
✓ Profile edit functionality specified
✓ Avatar upload flow defined
✓ Cloudinary integration described
```

---

**Prompt 15: Plan Profiles**

```
/speckit.plan features/004-profiles
```

**Expected Outcome:**
```
✓ Plan created: features/004-profiles/plan.md
✓ Database schema updates (Profile table bio/avatar columns)
✓ API endpoints planned (get profile, update profile, upload avatar)
✓ Frontend components planned (ProfileView, ProfileEdit, AvatarUpload)
✓ Routes planned (/profile/:username, /settings)
✓ Cloudinary integration strategy
```

---

**Prompt 16: Generate Tasks**

```
/speckit.tasks features/004-profiles
```

**Expected Outcome:**
```
✓ Tasks created: features/004-profiles/tasks.md
✓ Database tasks (migration for bio/avatar)
✓ Backend tasks (API endpoints, Cloudinary integration)
✓ Frontend tasks (components, routes, upload UI)
✓ Estimated 12-16 tasks
```

---

**Prompt 17: Implement Profiles**

```
/speckit.implement features/004-profiles
```

**Expected Outcome:**
```
✓ Database migration created (bio/avatar columns)
✓ Cloudinary configuration added
✓ Backend API endpoints implemented
✓ Frontend components created
✓ Profile and settings routes configured
✓ Avatar upload functionality working
✓ All tasks completed
```

**What to Test:**
1. Navigate to your profile (/profile/[your-username])
2. Navigate to settings (/settings)
3. Update your bio
4. Upload an avatar image
5. Verify changes persist
6. View another user's profile
7. Click on a username in feed to view their profile
8. Verify you can't edit other users' profiles

**Record:**
- Time spent: _____ minutes
- Tasks completed: _____ / _____
- Issues encountered: _____
- Code quality: ⭐⭐⭐⭐⭐

---

## 📊 Final Testing & Validation

### End-to-End Testing

**Complete User Flow:**
1. ✅ Visit landing page (/)
2. ✅ Sign up with new account
3. ✅ Sign in with credentials
4. ✅ Create several tweets
5. ✅ Like/unlike tweets
6. ✅ Edit profile bio
7. ✅ Upload avatar
8. ✅ View other user profiles
9. ✅ Sign out
10. ✅ Sign back in (verify session)

**Quality Checks:**
- [ ] All features working correctly
- [ ] No console errors
- [ ] Responsive design working
- [ ] Form validation working
- [ ] Error messages clear
- [ ] Loading states present
- [ ] Database constraints enforced
- [ ] Authentication secure

---

## 📈 Metrics Collection

### Time Tracking

**Phase Durations:**
- Setup (Phase 0): _____ minutes
- Constitution (Phase 1): _____ minutes
- Authentication: _____ minutes
- Tweets: _____ minutes
- Likes: _____ minutes
- Profiles: _____ minutes
- Testing: _____ minutes
- **Total**: _____ hours

### Quality Metrics

**Specifications:**
- Clarity: ⭐⭐⭐⭐⭐
- Completeness: ⭐⭐⭐⭐⭐
- Iterations needed: _____

**Technical Plans:**
- Architecture quality: ⭐⭐⭐⭐⭐
- Detail level: ⭐⭐⭐⭐⭐
- Iterations needed: _____

**Tasks:**
- Organization: ⭐⭐⭐⭐⭐
- Granularity: ⭐⭐⭐⭐⭐
- Dependency clarity: ⭐⭐⭐⭐⭐

**Implementation:**
- Code quality: ⭐⭐⭐⭐⭐
- Test coverage: _____%
- Bugs encountered: _____
- Rework cycles: _____

### User Experience

**Workflow Ease:**
- Command clarity: ⭐⭐⭐⭐⭐
- Guidance quality: ⭐⭐⭐⭐⭐
- Error recovery: ⭐⭐⭐⭐⭐
- Overall satisfaction: ⭐⭐⭐⭐⭐

---

## 🚨 Issues Encountered

### Issue Log

**Issue 1:**
- Description: _____
- Phase: _____
- Resolution: _____
- Time lost: _____ minutes

**Issue 2:**
- Description: _____
- Phase: _____
- Resolution: _____
- Time lost: _____ minutes

**Issue 3:**
- Description: _____
- Phase: _____
- Resolution: _____
- Time lost: _____ minutes

---

## 💡 Observations & Insights

### What Worked Well:
1. _____
2. _____
3. _____

### What Needs Improvement:
1. _____
2. _____
3. _____

### Unexpected Behaviors:
1. _____
2. _____
3. _____

### Suggestions:
1. _____
2. _____
3. _____

---

## ✅ Success Criteria

**Test 1 is Complete When:**
- [ ] All 4 features fully functional
- [ ] End-to-end user flow works
- [ ] No critical bugs
- [ ] All metrics collected
- [ ] Observations documented
- [ ] Ready to compare with Test 2 (SpecSwarm)

**Baseline Established:**
- ✅ Time to build full app: _____ hours
- ✅ Code quality baseline: ⭐⭐⭐⭐⭐
- ✅ Workflow experience baseline: ⭐⭐⭐⭐⭐
- ✅ Ready for comparison testing

---

## 🎯 Next Steps

**After Completing Test 1:**
1. Review all metrics and observations
2. Document any patterns or issues
3. Proceed to [Test 2: SpecSwarm](test-2-specswarm.md)
4. Compare results to establish SpecSwarm value

**Key Comparison Points for Test 2:**
- Does tech stack enforcement add overhead?
- Does auto-detection work correctly?
- Are tech violations caught?
- Is generated code quality similar?

---

## 📚 Additional Resources

- [Plugin Testing Guide](plugin-testing-guide.md) - Complete testing methodology
- [SpecKit README](../../plugins/speckit/README.md) - Full SpecKit documentation
- [Testing Quick Start](QUICK-START.md) - Quick reference guide
- [Complete Workflow Guide](../cheatsheets/complete-workflow-guide.md) - All plugin commands

---

**You've established the baseline! Now test the enhancements.** 🎉
