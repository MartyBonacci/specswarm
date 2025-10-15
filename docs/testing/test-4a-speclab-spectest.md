# Test 4A: SpecLab on SpecTest
## Lifecycle Workflows with Parallel Execution

**Plugins**: SpecLab + SpecTest (integrated)
**Goal**: Validate SpecLab bugfix and modify workflows with SpecTest parallel execution
**Expected Duration**: 6-8 hours (3h bugfix + 3-4h modify)
**Prerequisites**: Complete Test 3 (SpecTest) - Use tweeter-spectest build as base

---

## 📋 Overview

**What This Tests:**
- ✅ SpecLab bugfix workflow (regression-test-first methodology)
- ✅ SpecLab modify workflow (impact-analysis-first approach)
- ✅ Smart integration detection (SpecTest hooks + parallel execution)
- ✅ Lifecycle workflows maintain tech enforcement
- ✅ Complete bugfix and modification cycles

**Success Metrics:**
- ⏱️ Bugfix workflow: ~3 hours
- ⏱️ Modify workflow: ~3-4 hours
- ✅ Regression tests created and effective
- ✅ Impact analysis accurate
- ✅ Parallel execution in lifecycle workflows
- ✅ No regressions introduced

---

## 🚀 Setup

### Prerequisites Check

**Verify Test 3 Complete:**
```bash
# Navigate to tweeter-spectest project
cd ~/code-projects/tweeter-spectest

# Verify app is functional
npm run dev
# Test all features work (auth, tweets, likes, profiles)

# Verify git is clean
git status
# Should show clean working directory
```

**Install SpecLab Plugin:**
```bash
claude plugin install speclab
```

**Expected output:**
```
✓ Plugin installed: speclab
```

**Record Start Time:**

**📝 Note your start time**: ________ (e.g., 10:00 AM)

---

## 🐛 Phase 1: Bugfix Workflow (~3 hours)

### Deliberate Bug to Fix

**Bug**: Backend accepts tweets > 140 characters despite frontend validation

**Impact**: Data integrity issue, breaks core product constraint

**How to Test Bug Exists:**
```bash
# Test via API directly (bypasses frontend validation)
curl -X POST http://localhost:3000/api/tweets \
  -H "Content-Type: application/json" \
  -H "Cookie: [your-auth-cookie]" \
  -d '{"content":"[string with 150 characters]"}'

# Currently: Succeeds (bug exists)
# Should: Return 400 error
```

---

### Step 1: Create Bugfix Branch

**Paste into terminal:**

```bash
# Create and switch to bugfix branch
git checkout -b bugfix/005-character-limit

# Verify branch
git branch
# Should show: * bugfix/005-character-limit
```

**Expected Outcome:**
- ✅ New branch created
- ✅ Ready for bugfix workflow

---

### Step 2: Initiate Bugfix Workflow

**Prompt 1: Start Bugfix**

```
/speclab:bugfix
```

**Expected Outcome:**
```
🔍 Smart Integration Detection
✓ SpecSwarm detected: NOT detected (using SpecTest)
✓ SpecTest detected: ENABLED
✓ Mode: SpecLab + SpecTest (parallel execution + metrics)

📋 Bugfix Workflow Started
✓ Regression-test-first methodology
✓ Parallel execution available for implementation tasks
✓ Hooks system active

Let's document the bug. Please describe:
1. What is the buggy behavior?
2. What should happen instead?
3. Steps to reproduce?
4. Impact/severity?
```

**Your Response:**

```
Bug: Backend accepts tweets over 140 characters when frontend validation is bypassed (e.g., direct API calls).

Expected: Backend must independently enforce 140 character limit and reject tweets > 140 chars with 400 error.

Steps to reproduce:
1. Bypass frontend by sending POST /api/tweets directly via curl/Postman
2. Send request with content > 140 characters
3. Tweet is saved to database (BUG - should be rejected)

Impact: High - Data integrity issue, violates core product constraint (140 character limit), affects all users

Root cause: Missing server-side Zod validation in POST /api/tweets endpoint
```

**Expected Claude Response:**
- Creates bugfix documentation
- Proposes regression test strategy
- Suggests implementation approach

**⏱️ Record time**: ________ minutes (initial diagnosis)

---

### Step 3: Review Bugfix Documentation

**Claude Will Create:** `features/002-tweets/bugfix.md`

**Expected Content Structure:**
```markdown
# Bugfix: Tweet Character Limit Not Enforced

## Bug Description
Backend accepts tweets over 140 characters when frontend validation bypassed.

## Expected Behavior
Backend must enforce 140 character limit independently.

## Root Cause
Missing server-side Zod validation schema in POST /api/tweets.

## Solution Approach
1. Create Zod schema with max(140) constraint
2. Apply validation to POST /api/tweets endpoint
3. Return 400 error with message on validation failure

## Regression Test Strategy
- Test at limit (140 chars): Should succeed
- Test over limit (141+ chars): Should fail with 400
- Test far over limit (200+ chars): Should fail with 400
```

**📝 Review:**
- Bug description accurate?
- Solution approach sound?
- Regression test strategy comprehensive?

---

### Step 4: Create Regression Test Specification

**Claude Will Create:** `features/002-tweets/regression-test.md`

**Expected Content:**
```markdown
# Regression Test: Character Limit Enforcement

## Test Objective
Verify backend rejects tweets > 140 characters.

## Test Framework
Vitest (existing test framework)

## Test Location
`server/tests/tweets.test.ts`

## Test Cases

### TC001: Valid Tweet (Under Limit)
- Input: 140 characters
- Expected: 201 Created, tweet saved

### TC002: Valid Tweet (At Limit)
- Input: Exactly 140 characters
- Expected: 201 Created, tweet saved

### TC003: Invalid Tweet (Over Limit - Boundary)
- Input: 141 characters
- Expected: 400 Bad Request, validation error

### TC004: Invalid Tweet (Over Limit - Far)
- Input: 200 characters
- Expected: 400 Bad Request, validation error
```

**📝 Review:**
- Test cases cover boundary conditions?
- Expected outcomes clear?

---

### Step 5: Generate Bugfix Tasks

**Claude Will Create:** `features/002-tweets/tasks.md`

**Expected Tasks:**
```markdown
# Bugfix Tasks: Character Limit Enforcement

## T001: Write Regression Test
- Create test file with all test cases (TC001-TC004)
- Framework: Vitest
- Status: Pending
- Dependencies: None
- Parallel: No (foundational)

## T002: Verify Test Fails (Proves Bug)
- Run test suite
- Expected: Tests fail (proves bug exists)
- Status: Pending
- Dependencies: T001
- Parallel: No (validation step)

## T003: Create Backend Validation Schema [P]
- Create Zod schema: z.string().max(140)
- Location: server/validation/tweet.schema.ts
- Export: tweetContentSchema
- Status: Pending
- Dependencies: None
- Parallel: YES

## T004: Update POST /api/tweets Endpoint [P]
- Apply Zod validation to request body
- Return 400 on validation failure with error details
- Location: server/routes/tweets.ts
- Status: Pending
- Dependencies: T003
- Parallel: YES (can work alongside T003)

## T005: Verify Test Passes (Proves Fix)
- Run test suite
- Expected: All tests pass (proves fix works)
- Status: Pending
- Dependencies: T003, T004
- Parallel: No (validation step)

## T006: Run Full Test Suite
- Ensure no regressions in other features
- Expected: All tests pass
- Status: Pending
- Dependencies: T005
- Parallel: No (final validation)

📊 Parallel Execution Plan:
- Phase 1: T001 (sequential)
- Phase 2: T002 (sequential, validation)
- Phase 3: T003, T004 (PARALLEL - 2 tasks)
- Phase 4: T005, T006 (sequential, validation)

Expected speedup: ~1.5x (parallel implementation phase)
```

**📝 Review:**
- Parallel tasks identified?
- Dependencies correct?
- Regression-test-first order maintained?

**⏱️ Record time**: ________ minutes (planning phase)

---

### Step 6: Execute Bugfix Implementation

**Prompt 2: Implement Bugfix**

```
/speclab:implement bugfix
```

**Expected Outcome:**
```
🔍 Integration Check
✓ SpecTest integration: Active
✓ Parallel execution: Available
✓ Hooks system: Active
✓ Metrics tracking: Enabled

🎣 Pre-Implement Hook (SpecTest)
✓ Environment validated
✓ Dependencies checked
✓ Metrics initialized

📋 Executing Bugfix Tasks (6 tasks)

Phase 1: Regression Test Creation (sequential)
  → T001: Write regression test
  ✓ Created: server/tests/tweets.test.ts
  ✓ Test cases: TC001-TC004 implemented
  ✓ Complete (1m 30s)

Phase 2: Bug Verification (sequential)
  → T002: Verify test fails
  ✓ Running test suite...
  ✓ Tests failed as expected:
    - TC003: FAIL (accepts 141 chars - BUG CONFIRMED)
    - TC004: FAIL (accepts 200 chars - BUG CONFIRMED)
  ✓ Bug existence proved (45s)

Phase 3: Implementation (PARALLEL - 2 tasks)
  ⚡ Executing 2 tasks in parallel...

  → T003: Create validation schema
  ✓ Created: server/validation/tweet.schema.ts
  ✓ Schema: z.string().min(1).max(140)
  ✓ Exports: tweetContentSchema
  ✓ Complete (2m 15s)

  → T004: Update POST endpoint
  ✓ Updated: server/routes/tweets.ts
  ✓ Applied Zod validation
  ✓ Returns 400 on validation failure
  ✓ Complete (2m 30s)

  ⚡ Parallel batch complete (2m 30s vs ~4m 45s sequential = 1.9x speedup)

Phase 4: Validation (sequential)
  → T005: Verify test passes
  ✓ Running test suite...
  ✓ All regression tests passing:
    - TC001: PASS (140 chars accepted)
    - TC002: PASS (exactly 140 chars accepted)
    - TC003: PASS (141 chars rejected with 400)
    - TC004: PASS (200 chars rejected with 400)
  ✓ Fix verified (1m 0s)

  → T006: Run full test suite
  ✓ Running complete test suite...
  ✓ All tests passing: [N]/[N]
  ✓ No regressions introduced (1m 30s)

🎣 Post-Implement Hook (SpecTest)
✓ All 6 tasks completed
✓ Tests passing: [N]/[N]
✓ No tech violations
📊 Metrics saved to /memory/metrics.json

⚡ Performance Summary:
- Total time: ~9 minutes
- Parallel speedup: 1.9x (implementation phase)
- Time saved: ~2 minutes

✅ Bugfix complete!
```

**Manual Verification:**

```bash
# 1. Verify tests pass
npm test

# 2. Test the fix manually
curl -X POST http://localhost:3000/api/tweets \
  -H "Content-Type: application/json" \
  -H "Cookie: [your-auth-cookie]" \
  -d '{"content":"[150 character string]"}'

# Expected: 400 Bad Request with validation error
```

**📝 Critical Notes:**
- Parallel execution worked? ________
- Tests proved bug existence? ________
- Tests proved fix works? ________
- No regressions? ________

**⏱️ Record time**: ________ minutes (implementation phase)

---

### Step 7: Commit Bugfix

**Paste into terminal:**

```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "fix: enforce 140 character limit on backend

- Add Zod validation schema for tweet content (max 140 chars)
- Apply validation to POST /api/tweets endpoint
- Return 400 error with validation details on failure
- Add regression tests for character limit enforcement
- All tests passing, no regressions

Fixes: Character limit bypass via direct API calls

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"

# Verify commit
git log -1 --stat
```

**Expected Outcome:**
- ✅ Bugfix committed to branch
- ✅ Ready to merge or proceed to modify workflow

**⏱️ Bugfix Total Time**: ________ hours

**📝 Bugfix Phase Complete:**
- Regression test quality: ⭐⭐⭐⭐⭐
- Bug fixed correctly: ✅ / ❌
- No new issues: ✅ / ❌
- Parallel execution effective: ✅ / ❌

---

**💡 Consider /compact (Between Workflows):**

After completing the bugfix workflow, consider running:
```
/compact
```

This will:
- ✅ Summarize bugfix conversation history
- ✅ Preserve all project state and commits
- ✅ Give Claude a fresh context for modify workflow
- ✅ Maintain peak performance for Phase 2

**Continue after compact (if used):**

---

## 🔄 Phase 2: Modify Workflow (~3-4 hours)

### Modification Goal

**Feature to Add**: Retweet functionality

**Scope**: Users can retweet (share) other users' tweets

**Requirements:**
- Retweet button on each tweet
- Retweets appear in feed with "Retweeted by @username"
- Original author credited
- Retweet counts tracked
- Can undo retweet

---

### Step 8: Create Modify Branch

**Paste into terminal:**

```bash
# Return to main and create modify branch
git checkout main
git checkout -b modify/002-add-retweets

# Verify branch
git branch
# Should show: * modify/002-add-retweets
```

**Expected Outcome:**
- ✅ New branch created
- ✅ Ready for modify workflow

---

### Step 9: Initiate Modify Workflow

**Prompt 3: Start Modify**

```
/speclab:modify
```

**Expected Outcome:**
```
🔍 Smart Integration Detection
✓ SpecTest detected: ENABLED
✓ Mode: SpecLab + SpecTest (parallel + metrics)

📋 Modify Workflow Started
✓ Impact-analysis-first methodology
✓ Parallel execution available
✓ Hooks active

Which feature would you like to modify?
List: features/001-authentication, features/002-tweets, features/003-likes, features/004-profiles

Please specify feature path and describe the modification.
```

**Your Response:**

```
Feature: features/002-tweets

Modification: Add retweet functionality. Users should be able to retweet (share) other users' tweets to their own feed. Retweets should appear in the feed with "Retweeted by @username" label, crediting the original author. Track retweet counts. Users should be able to undo retweets. Cannot retweet your own tweets.
```

**Expected Claude Response:**
- Loads existing tweet specification
- Analyzes modification scope
- Identifies affected components

**⏱️ Record time**: ________ minutes (initial analysis)

---

### Step 10: Review Impact Analysis

**Claude Will Create:** `features/002-tweets/impact-analysis.md`

**Expected Content:**
```markdown
# Impact Analysis: Add Retweet Functionality

## Affected Components

### Database Schema (Breaking Change)
**Current:**
- Tweet table: id, profile_id, content, created_at

**Modified:**
- Tweet table adds:
  - original_tweet_id (nullable, FK to tweets)
  - is_retweet (boolean, default false)
  - retweet_count (integer, default 0)
- New index: ON original_tweet_id
- **Impact**: Migration required, affects all tweet queries

### Backend APIs (Additive + Modified)
**New Endpoints:**
- POST /api/retweets (create retweet)
- DELETE /api/retweets/:id (undo retweet)

**Modified Endpoints:**
- GET /api/tweets (must include retweet data, joins required)
- GET /api/tweets/:id (include retweet info)
- GET /api/tweets/user/:username (include user's retweets)

**Impact**: Response format changes (backward compatible with optional fields)

### Frontend Components (Modified)
- TweetCard: Add retweet button, display retweet attribution
- TweetFeed: Handle retweet display
- **Impact**: Component updates, no breaking changes

### Feature Dependencies
- Depends on: Authentication (user identity)
- Depends on: Profiles (retweet author info)
- Affects: Tweet display everywhere
- Affects: User profile (show user's retweets)

## Breaking Changes

### Database Migration
- **Risk**: Medium
- **Mitigation**: Nullable columns, default values
- **Rollback**: Migration can be reversed

### API Response Format
- **Risk**: Low
- **Change**: Adding optional fields to GET /api/tweets
- **Mitigation**: Clients ignore unknown fields (backward compatible)

## Backward Compatibility Strategy

1. **Database:** Migration adds nullable columns (existing rows unaffected)
2. **API:** New fields optional in responses (old clients work)
3. **Frontend:** Graceful degradation if retweet data missing

## Implementation Complexity

**Estimated Tasks:** 12-15 tasks
**Parallel Opportunities:** High (6-8 parallel tasks)
**Expected Duration:** 3-4 hours with parallel execution
**Risk Level:** Medium (schema changes, multiple integrations)
```

**📝 Review:**
- Impact analysis comprehensive?
- Breaking changes identified?
- Mitigation strategies sound?
- Parallel opportunities noted?

**⏱️ Record time**: ________ minutes (impact analysis)

---

### Step 11: Review Modification Specification

**Claude Will Create:** `features/002-tweets/modify.md`

**Expected Content:**
```markdown
# Modification: Add Retweet Functionality

## New Requirements

### Functional Requirements
1. Users can retweet other users' tweets
2. Users cannot retweet their own tweets
3. Retweets appear in feed with attribution
4. Original tweet displays retweet count
5. Users can undo retweets

### UI/UX Requirements
- Retweet button on each tweet (disabled for own tweets)
- "Retweeted by @username" label on retweets
- Retweet count displayed
- Visual distinction between original and retweeted content

### Technical Requirements
- Database: Add retweet fields to tweets table
- Validation: Prevent retweet of own tweets (Zod + database constraint)
- APIs: RESTful retweet endpoints
- IDs: Use uuidv7 for retweet records

## Data Model Changes

### Tweet Table (Modified)
```sql
ALTER TABLE tweets ADD COLUMN original_tweet_id UUID REFERENCES tweets(id);
ALTER TABLE tweets ADD COLUMN is_retweet BOOLEAN DEFAULT FALSE;
ALTER TABLE tweets ADD COLUMN retweet_count INTEGER DEFAULT 0;
CREATE INDEX idx_tweets_original_tweet_id ON tweets(original_tweet_id);
```

## API Specification

### POST /api/retweets
**Request:**
```json
{
  "original_tweet_id": "uuid"
}
```

**Response:**
```json
{
  "id": "uuid",
  "original_tweet_id": "uuid",
  "profile_id": "uuid",
  "is_retweet": true,
  "created_at": "timestamp"
}
```

**Validation:**
- Original tweet must exist
- User cannot retweet own tweet
- User can only retweet once (prevent duplicates)

### DELETE /api/retweets/:id
**Response:** 204 No Content

### GET /api/tweets (Modified Response)
**New fields:**
```json
{
  "id": "uuid",
  "content": "text",
  "is_retweet": false,
  "original_tweet": { ... },  // If is_retweet=true
  "retweet_count": 0,
  "retweeted_by": { ... },    // If is_retweet=true
  ...
}
```

## Testing Strategy

### Unit Tests
- Retweet creation validation
- Prevent retweet of own tweet
- Retweet count updates

### Integration Tests
- Retweet appears in feed
- Undo retweet works
- Retweet count accurate

### Edge Cases
- Retweet deleted tweet (should fail)
- Duplicate retweet (should fail)
- Retweet count consistency
```

**📝 Review:**
- Requirements clear?
- Data model changes sound?
- API design RESTful?

**⏱️ Record time**: ________ minutes (specification)

---

### Step 12: Generate Modification Tasks

**Claude Will Create:** `features/002-tweets/tasks.md`

**Expected Tasks:**
```markdown
# Modify Tasks: Add Retweet Functionality

## Phase 1: Foundation (Sequential)

### T001: Review Impact Analysis
- Read impact-analysis.md
- Understand breaking changes
- Plan migration strategy
- Status: Pending
- Parallel: No

### T002: Create Database Migration
- Add: original_tweet_id, is_retweet, retweet_count
- Add index on original_tweet_id
- Test migration up/down
- Status: Pending
- Dependencies: T001
- Parallel: No (foundational)

## Phase 2: Backend Implementation (Parallel Opportunities)

### T003: Create Retweet Validation Schema [P]
- Zod schema for POST /api/retweets
- Validate original_tweet_id exists
- Prevent retweet of own tweet
- Location: server/validation/retweet.schema.ts
- Status: Pending
- Dependencies: T002
- Parallel: YES

### T004: Implement POST /api/retweets [P]
- Create retweet record
- Increment original tweet retweet_count
- Return retweet object
- Location: server/routes/retweets.ts
- Status: Pending
- Dependencies: T003
- Parallel: YES

### T005: Implement DELETE /api/retweets/:id [P]
- Delete retweet record
- Decrement original tweet retweet_count
- Return 204
- Location: server/routes/retweets.ts
- Status: Pending
- Dependencies: T003
- Parallel: YES

### T006: Modify GET /api/tweets [P]
- Include retweet data in queries
- Join with original tweets
- Join with retweet authors
- Add retweet fields to response
- Location: server/routes/tweets.ts
- Status: Pending
- Dependencies: T002
- Parallel: YES

## Phase 3: Frontend Implementation (Parallel Opportunities)

### T007: Update TweetCard Component [P]
- Add retweet button
- Display retweet attribution
- Handle retweet/undo actions
- Optimistic UI updates
- Location: app/components/TweetCard.tsx
- Status: Pending
- Dependencies: T004, T005
- Parallel: YES

### T008: Update TweetFeed Component [P]
- Handle retweet display
- Fetch retweet data
- Location: app/components/TweetFeed.tsx
- Status: Pending
- Dependencies: T006
- Parallel: YES

### T009: Add Retweet API Client Functions [P]
- createRetweet(tweetId)
- deleteRetweet(retweetId)
- Location: app/api/retweets.ts
- Status: Pending
- Dependencies: None (can start early)
- Parallel: YES

## Phase 4: Testing & Integration (Sequential)

### T010: Write Integration Tests
- Test retweet creation
- Test undo retweet
- Test retweet count updates
- Test feed display
- Location: server/tests/retweets.test.ts
- Status: Pending
- Dependencies: T004, T005, T006
- Parallel: No (validation)

### T011: Test Edge Cases
- Retweet own tweet (should fail)
- Duplicate retweet (should fail)
- Retweet deleted tweet (should fail)
- Status: Pending
- Dependencies: T010
- Parallel: No (validation)

### T012: Run Full Test Suite
- Ensure no regressions
- All features still working
- Status: Pending
- Dependencies: T011
- Parallel: No (final validation)

📊 Parallel Execution Plan:
- Phase 1: T001-T002 (sequential, foundational)
- Phase 2: T003-T006 (PARALLEL - 4 tasks)
- Phase 3: T007-T009 (PARALLEL - 3 tasks, can overlap with Phase 2)
- Phase 4: T010-T012 (sequential, validation)

Expected speedup: ~2.5x (large parallel phases)
Estimated duration: 3-4 hours
```

**📝 Review:**
- Parallel tasks identified (7 parallel tasks)?
- Dependencies correct?
- Impact-analysis-first order maintained?

**⏱️ Record time**: ________ minutes (task generation)

---

### Step 13: Execute Modification Implementation

**Prompt 4: Implement Modification**

```
/speclab:implement modify
```

**Expected Outcome:**
```
🔍 Integration Check
✓ SpecTest integration: Active
✓ Parallel execution: Available (7 parallel tasks detected)
✓ Hooks system: Active
✓ Metrics tracking: Enabled

🎣 Pre-Implement Hook (SpecTest)
✓ Environment validated
✓ Impact analysis reviewed
✓ Migration strategy confirmed
✓ Metrics initialized

📋 Executing Modify Tasks (12 tasks across 4 phases)

Phase 1: Foundation (sequential)
  → T001: Review impact analysis
  ✓ Impact analysis understood
  ✓ Breaking changes: Database schema
  ✓ Mitigation: Nullable columns, backward compatible API
  ✓ Complete (1m 0s)

  → T002: Create database migration
  ✓ Created: migrations/005_add_retweet_fields.sql
  ✓ Columns: original_tweet_id, is_retweet, retweet_count
  ✓ Index: idx_tweets_original_tweet_id
  ✓ Migration tested (up/down)
  ✓ Complete (2m 30s)

Phase 2: Backend Implementation (PARALLEL - 4 tasks)
  ⚡ Executing 4 tasks in parallel...

  → T003: Create validation schema
  ✓ Created: server/validation/retweet.schema.ts
  ✓ Validation: original_tweet_id, prevent own retweet
  ✓ Complete (2m 15s)

  → T004: Implement POST /api/retweets
  ✓ Created: server/routes/retweets.ts
  ✓ Validation applied, retweet_count incremented
  ✓ Complete (3m 45s)

  → T005: Implement DELETE /api/retweets/:id
  ✓ Updated: server/routes/retweets.ts
  ✓ Retweet deletion, retweet_count decremented
  ✓ Complete (2m 30s)

  → T006: Modify GET /api/tweets
  ✓ Updated: server/routes/tweets.ts
  ✓ Joins: original_tweet, retweet_author
  ✓ Response includes retweet fields
  ✓ Complete (4m 0s)

  ⚡ Parallel batch complete (4m 0s vs ~12m 30s sequential = 3.1x speedup)

Phase 3: Frontend Implementation (PARALLEL - 3 tasks)
  ⚡ Executing 3 tasks in parallel...

  → T007: Update TweetCard component
  ✓ Updated: app/components/TweetCard.tsx
  ✓ Retweet button, attribution display
  ✓ Optimistic UI updates
  ✓ Complete (3m 30s)

  → T008: Update TweetFeed component
  ✓ Updated: app/components/TweetFeed.tsx
  ✓ Retweet display handling
  ✓ Complete (2m 0s)

  → T009: Add retweet API functions
  ✓ Created: app/api/retweets.ts
  ✓ Functions: createRetweet, deleteRetweet
  ✓ Complete (1m 45s)

  ⚡ Parallel batch complete (3m 30s vs ~7m 15s sequential = 2.1x speedup)

Phase 4: Testing & Integration (sequential)
  → T010: Write integration tests
  ✓ Created: server/tests/retweets.test.ts
  ✓ Tests: create, undo, count, feed display
  ✓ Complete (3m 0s)

  → T011: Test edge cases
  ✓ Tests: own tweet, duplicate, deleted tweet
  ✓ All edge cases handled correctly
  ✓ Complete (2m 0s)

  → T012: Run full test suite
  ✓ Running complete test suite...
  ✓ All tests passing: [N]/[N]
  ✓ No regressions introduced
  ✓ Complete (2m 0s)

🎣 Post-Implement Hook (SpecTest)
✓ All 12 tasks completed
✓ Tests passing: [N]/[N]
✓ No tech violations
✓ Breaking changes handled correctly
✓ Backward compatibility maintained
📊 Metrics saved to /memory/metrics.json

⚡ Performance Summary:
- Total time: ~27 minutes
- Parallel speedup Phase 2: 3.1x (backend tasks)
- Parallel speedup Phase 3: 2.1x (frontend tasks)
- Overall speedup: ~2.5x
- Time saved: ~12 minutes

✅ Modification complete!
```

**Manual Verification:**

```bash
# 1. Run tests
npm test

# 2. Test retweet functionality manually
npm run dev

# In browser:
# - Navigate to feed
# - Find tweet from another user
# - Click retweet button
# - Verify retweet appears in feed with attribution
# - Verify retweet count increases on original
# - Click undo retweet
# - Verify retweet removed and count decreases

# 3. Test edge cases
# - Try to retweet own tweet (should be disabled)
# - Try to retweet same tweet twice (should fail)
```

**📝 Critical Notes:**
- Parallel execution worked (Phase 2 & 3)? ________
- Impact analysis accurate? ________
- Breaking changes handled? ________
- Backward compatibility maintained? ________
- No regressions? ________

**⏱️ Record time**: ________ minutes (implementation phase)

---

### Step 14: Commit Modification

**Paste into terminal:**

```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat: add retweet functionality

- Add database fields: original_tweet_id, is_retweet, retweet_count
- Create migration: 005_add_retweet_fields.sql
- Implement POST /api/retweets (create retweet)
- Implement DELETE /api/retweets/:id (undo retweet)
- Update GET /api/tweets to include retweet data
- Add retweet UI to TweetCard component
- Add retweet attribution display
- Implement retweet API client functions
- Add integration tests for retweet workflows
- All tests passing, no regressions

Breaking changes: Database schema (backward compatible)
Migration required: Run migrations/005_add_retweet_fields.sql

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"

# Verify commit
git log -1 --stat
```

**Expected Outcome:**
- ✅ Modification committed to branch
- ✅ Ready to merge

**⏱️ Modify Total Time**: ________ hours

**📝 Modify Phase Complete:**
- Impact analysis accuracy: ⭐⭐⭐⭐⭐
- Breaking changes handled: ✅ / ❌
- Backward compatibility: ✅ / ❌
- No regressions: ✅ / ❌
- Parallel execution effective: ✅ / ❌

---

## 📊 Phase 3: Final Metrics

### View Complete Workflow Metrics

**Prompt 5: Full Metrics**

```
/spectest:metrics
```

**Expected Outcome:**
```
📊 SpecTest Performance Metrics Dashboard

Project: tweeter-spectest
Period: All time

Summary:
- Features: 4 (from Test 3) + 2 workflows (bugfix + modify)
- Total tasks: [N]
- Parallel tasks: [N]
- Average speedup: [X]x

Recent Workflow Additions:
┌─────────────────────┬──────────┬─────────┬──────────────┐
│ Workflow            │ Duration │ Tasks   │ Parallel     │
├─────────────────────┼──────────┼─────────┼──────────────┤
│ bugfix/char-limit  │ ~9min    │ 6       │ 2 (1.9x)     │
│ modify/retweets     │ ~27min   │ 12      │ 7 (2.5x)     │
└─────────────────────┴──────────┴─────────┴──────────────┘

Lifecycle Workflows:
• Bugfix time saved: ~2 minutes
• Modify time saved: ~12 minutes
• Total lifecycle speedup: ~2.3x average
```

**📝 Record Final Metrics:**
- Bugfix duration: ________ hours
- Modify duration: ________ hours
- Total Test 4A duration: ________ hours
- Parallel speedup effective: ✅ / ❌

---

## 📋 Final Data Collection

### Record End Time

**📝 End time**: ________ (e.g., 4:30 PM)

**⏱️ Total duration**: ________ hours

**Phase Breakdown:**
- Bugfix workflow: ________ hours
- Modify workflow: ________ hours
- **Total**: ________ hours (target: 6-8 hours)

---

### Complete Results Template

**Use `results/test-4a-results.md` to record:**

1. **Timeline:**
   - Bugfix: ________ hours
   - Modify: ________ hours
   - Total: ________ hours

2. **Integration Quality:**
   - SpecTest integration: ⭐⭐⭐⭐⭐
   - Parallel execution: ⭐⭐⭐⭐⭐
   - Hooks system: ⭐⭐⭐⭐⭐

3. **Workflow Quality:**
   - Regression test effectiveness: ⭐⭐⭐⭐⭐
   - Impact analysis accuracy: ⭐⭐⭐⭐⭐
   - Breaking change handling: ⭐⭐⭐⭐⭐

4. **Issues Encountered:**
   - Issue 1: ________
   - Resolution: ________

5. **Observations:**
   - Integration smoothness?
   - Parallel execution in lifecycle?
   - Workflow effectiveness?

---

## ✅ Success Criteria

### Test Complete When:

- [x] Bugfix workflow completed successfully
- [x] Modify workflow completed successfully
- [x] Parallel execution active in both workflows
- [x] Regression tests effective (proved bug + fix)
- [x] Impact analysis accurate (identified dependencies)
- [x] Breaking changes handled correctly
- [x] No regressions introduced
- [x] All tests passing

### Key Metrics Captured:

- [x] Bugfix duration: ________ hours
- [x] Modify duration: ________ hours
- [x] Parallel speedup: ________x
- [x] Regression test quality: ⭐⭐⭐⭐⭐
- [x] Impact analysis quality: ⭐⭐⭐⭐⭐

---

## 🎯 Key Takeaways

### SpecLab + SpecTest Integration

**What Worked:**
1. _____
2. _____
3. _____

**What Needs Improvement:**
1. _____
2. _____
3. _____

### Lifecycle Workflows

**Bugfix Workflow:**
- Regression-test-first effective? ________
- Bug detection clear? ________
- Fix verification solid? ________

**Modify Workflow:**
- Impact analysis helpful? ________
- Breaking change identification accurate? ________
- Backward compatibility maintained? ________

### Parallel Execution in Lifecycle

- Speedup achieved in bugfix? ________
- Speedup achieved in modify? ________
- Worth overhead? ________

---

## 🔄 Next Steps

**After completing this test:**

1. **Document results** in `results/test-4a-results.md`
2. **Compare with Test 3** baseline
3. **Optional:** Proceed to [Test 4B: SpecLab on SpecSwarm](test-4b-speclab-specswarm.md) if you want to validate tech enforcement in lifecycle workflows

---

## 🎉 Test Complete!

**You've validated:**
- ✅ SpecLab bugfix workflow (regression-test-first)
- ✅ SpecLab modify workflow (impact-analysis-first)
- ✅ SpecTest integration (parallel execution in lifecycle)
- ✅ Complete lifecycle workflow capabilities

**Key Achievement:**
SpecLab workflows integrated successfully with SpecTest's parallel execution, providing 2-4x speedup in lifecycle maintenance tasks.

**Ready for comprehensive testing?** → [Test 4B: SpecLab on SpecSwarm](test-4b-speclab-specswarm.md) (optional)
