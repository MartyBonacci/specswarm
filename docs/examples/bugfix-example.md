# Bugfix Example: Login Timeout Issue

**Real-world walkthrough of using `/specswarm:bugfix` to fix a production bug**

---

## Context

**Situation**: Users are reporting that login attempts timeout after 10 seconds, even with correct credentials.

**Impact**:
- ~30% of login attempts failing
- Users frustrated, some churning
- Priority: High

**Goal**: Fix the bug using regression-test-first methodology

---

## Step 1: Create Bugfix Branch

```bash
git checkout main
git pull origin main
git checkout -b bugfix/042-login-timeout
```

**Output:**
```
Switched to a new branch 'bugfix/042-login-timeout'
```

---

## Step 2: Run Bugfix Workflow

```bash
/specswarm:bugfix
```

**Claude's Response:**

```
🐛 Bugfix Workflow - Feature 042
✓ Branch detected: bugfix/042-login-timeout
✓ Feature directory: /home/marty/my-project/features/042-login-timeout

🎯 Smart Integration Detected
✓ SpecSwarm installed: Tech stack enforcement enabled
✓ SpecTest installed: Parallel execution enabled
✓ Loading tech stack: /memory/tech-stack.md

📋 Creating Bugfix Specification

What is the bug? Describe the symptoms and impact:
```

---

## Step 3: Describe the Bug

**Your Response:**
```
Login attempts timeout after 10 seconds. Users enter correct
credentials but see "Request timeout" error. Affects ~30% of
login attempts. Started happening after recent database migration.
```

**Claude Analyzes and Creates bugfix.md:**

```markdown
# Bug 042: Login Timeout After 10 Seconds

**Status**: Active
**Created**: 2025-10-12
**Priority**: High
**Severity**: Major

## Symptoms

- Login requests timeout after 10 seconds
- Error message: "Request timeout - please try again"
- Occurs with correct credentials
- Affects ~30% of login attempts
- Started after database migration on 2025-10-10

## Reproduction Steps

1. Navigate to /login
2. Enter valid credentials
3. Click "Login"
4. Wait 10 seconds
5. See timeout error

**Expected Behavior**: Login succeeds within 2-3 seconds

**Actual Behavior**: Request times out after 10 seconds

## Root Cause Analysis

**Initial Investigation**:
- Database migration added new index
- Index not optimized for query pattern
- Query taking 12-15 seconds (exceeds 10s timeout)

**Component Affected**:
- File: app/services/auth.ts:45-67
- Function: `authenticateUser()`
- Database query: `SELECT * FROM users WHERE email = ? AND active = true`

## Impact Assessment

**Affected Users**: ~30% of login attempts
- High-traffic periods worse (50%+ failure rate)
- Returning users (password login) affected
- OAuth login unaffected

**Affected Features**:
- Password-based authentication: Completely broken for 30%
- Session management: Cannot establish sessions
- User experience: Severe degradation

**Severity Justification**:
- Critical user flow broken
- High failure rate
- No automatic workaround

**Workaround Available**: Yes - users can use OAuth login

## Regression Test Requirements

1. Test that login completes within 3 seconds
2. Test with database under load (simulated)
3. Test query performance with new index

**Test Success Criteria**:
- ✅ Test fails before fix (proves bug exists - timeout occurs)
- ✅ Test passes after fix (proves bug fixed - login < 3s)
- ✅ No new regressions (all other auth tests pass)

## Proposed Solution

**Fix Approach**: Optimize database query

**Changes Required**:
1. Add composite index on (email, active) columns
2. Modify query to use index efficiently
3. Add query performance monitoring

**Risks**: Minimal - index optimization only, no logic changes

**Alternative Approaches**:
- Increase timeout → Rejected (doesn't address root cause)
- Cache authentication → Rejected (security concerns)

---

## Tech Stack Compliance

**Tech Stack File**: /memory/tech-stack.md
**Validation Status**: Pending
**Expected**: TypeScript, PostgreSQL (existing stack)

---

## Metadata

**Workflow**: Bugfix (regression-test-first)
**Created By**: SpecSwarm Plugin v2.0.0
**Smart Integration**: Tech stack enforcement + quality validation enabled
```

---

## Step 4: Claude Creates Regression Test Specification

**Claude automatically creates `regression-test.md`:**

```markdown
# Regression Test: Bug 042 - Login Timeout

**Purpose**: Prove bug exists, validate fix, prevent future regressions

**Test Type**: Integration Test
**Created**: 2025-10-12

---

## Test Objective

Write a test that:
1. ✅ **Fails before fix** (proves timeout bug exists)
2. ✅ **Passes after fix** (proves bug fixed)
3. ✅ **Prevents regression** (catches if bug reintroduced)

---

## Test Specification

### Test Setup

**Database State**:
- 1000 test users in database
- Users table has active column
- Current index state (pre-fix)

**Test Environment**:
- Simulated production load
- 10-second timeout configured

### Test Execution

1. Start timer
2. Call `authenticateUser('test@example.com', 'password123')`
3. Stop timer
4. Check result

### Test Assertions

- ✅ Authentication succeeds (correct credentials)
- ✅ Response time < 3 seconds
- ✅ No timeout error thrown

### Test Teardown

- Clean up test users
- Reset database state

---

## Test Implementation

### Test File Location

**File**: `app/services/auth.test.ts`
**Function Name**: `test_bug_042_login_timeout_regression`

### Test Code Structure

```typescript
describe('Bug 042: Login Timeout Regression Test', () => {
  test('login completes within 3 seconds', async () => {
    // Setup
    const testUser = await createTestUser({
      email: 'test@example.com',
      password: 'password123',
      active: true
    });

    // Execute with timer
    const startTime = Date.now();
    const result = await authenticateUser(
      'test@example.com',
      'password123'
    );
    const duration = Date.now() - startTime;

    // Assert
    expect(result.success).toBe(true);
    expect(duration).toBeLessThan(3000); // 3 seconds
    expect(result.user.id).toBe(testUser.id);
  });
});
```

### Test Validation Criteria

**Before Fix**:
- ❌ Test MUST fail with timeout (duration > 10s)
- If test passes before fix, test is invalid

**After Fix**:
- ✅ Test MUST pass (duration < 3s)
- ✅ All existing auth tests still pass

---

## Edge Cases to Test

1. Login under simulated load (100 concurrent requests)
2. Login with inactive user (should fail fast)
3. Login with incorrect password (should fail fast)

---

## Metadata

**Workflow**: Bugfix (regression-test-first)
**Created By**: SpecSwarm Plugin v2.0.0
```

---

## Step 5: Claude Generates Tasks

**Claude creates `tasks.md`:**

```markdown
# Tasks: Bug 042 - Login Timeout

**Workflow**: Bugfix (Regression-Test-First)
**Status**: Active
**Created**: 2025-10-12

---

## Execution Strategy

**Mode**: Parallel (SpecTest detected)
**Smart Integration**:
- SpecSwarm: Tech stack validation enabled
- SpecTest: Parallel execution + hooks + metrics

---

## Phase 1: Regression Test Creation

### T001: Write Regression Test
**Description**: Implement test in app/services/auth.test.ts
**File**: app/services/auth.test.ts
**Validation**: Test code follows specification
**Parallel**: No (foundational)

### T002: Verify Test Fails
**Description**: Run regression test and confirm it fails (timeout)
**Command**: npm test app/services/auth.test.ts
**Expected**: Test fails with timeout error (duration > 10s)
**Validation**: Test failure proves bug reproduction
**Parallel**: No (depends on T001)

---

## Phase 2: Bug Fix Implementation

### T003: Add Composite Index
**Description**: Add (email, active) composite index to users table
**File**: migrations/20251012-add-auth-index.sql
**Changes**: CREATE INDEX idx_users_email_active ON users(email, active)
**Tech Stack Validation**: ✅ PostgreSQL (compliant)
**Parallel**: No (database schema change)

### T004: Optimize Query
**Description**: Update authenticateUser() to use new index
**File**: app/services/auth.ts:45-67
**Changes**: Ensure query uses (email, active) index efficiently
**Tech Stack Validation**: ✅ TypeScript (compliant)
**Parallel**: No (depends on T003)

### T005: Add Performance Monitoring
**Description**: Add query duration logging
**File**: app/services/auth.ts
**Changes**: Log query performance for monitoring
**Tech Stack Validation**: ✅ TypeScript (compliant)
**Parallel**: No (depends on T004)

### T006: Verify Test Passes
**Description**: Run regression test and confirm it passes (< 3s)
**Command**: npm test app/services/auth.test.ts
**Expected**: Test passes, duration < 3s
**Validation**: Test success proves bug fixed
**Parallel**: No (depends on T005)

---

## Phase 3: Regression Validation

### T007: Run Full Auth Test Suite
**Description**: Verify no new regressions in authentication
**Command**: npm test app/services/auth.test.ts
**Expected**: All tests pass (existing + new regression test)
**Validation**: 100% test pass rate
**Parallel**: No (final validation)

### T008: Performance Validation
**Description**: Verify login performance under load
**Test**: Run load test with 100 concurrent requests
**Expected**: All logins complete < 3s
**Parallel**: No (final validation)

---

## Summary

**Total Tasks**: 8
**Estimated Time**: 1-2 hours
**Parallel Opportunities**: Limited (sequential database changes)

**Success Criteria**:
- ✅ Regression test created
- ✅ Test failed before fix (proved bug with timeout)
- ✅ Fix implemented (composite index + optimized query)
- ✅ Test passed after fix (proved solution)
- ✅ No new regressions
- ✅ Performance validated under load
- ✅ Tech stack compliant
```

---

## Step 6: Claude Executes Workflow

**Claude begins execution with hooks:**

```
🎣 Pre-Bugfix Hook
✓ Checking repository status...
✓ Loading tech stack: /memory/tech-stack.md
✓ Tech stack validation enabled
✓ Metrics initialized

⏱️  Workflow Start Time: 2025-10-12 14:30:00

─────────────────────────────────────────────────

Phase 1: Regression Test Creation

→ T001: Write Regression Test

Creating test file: app/services/auth.test.ts

[Claude writes the test code matching the specification]

✓ Test created: app/services/auth.test.ts:127-158

→ T002: Verify Test Fails

Running: npm test app/services/auth.test.ts -- --testNamePattern="Bug 042"

Output:
  ● Bug 042: Login Timeout Regression Test › login completes within 3 seconds

    Timeout - Async callback was not invoked within the 10000 ms timeout

    expect(duration).toBeLessThan(3000)
    Expected: < 3000
    Received: 12458

    at app/services/auth.test.ts:142:24

✅ Test failed as expected (duration: 12.5s - proves bug exists)

─────────────────────────────────────────────────

Phase 2: Bug Fix Implementation

→ T003: Add Composite Index

Creating migration: migrations/20251012-add-auth-index.sql

```sql
-- Add composite index for email + active lookup
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email_active
ON users(email, active);

-- Analyze table to update statistics
ANALYZE users;
```

Running migration...
✓ Index created: idx_users_email_active
✓ Migration applied successfully

🔍 Tech Stack Validation
✓ PostgreSQL index creation: Compliant
✓ No new dependencies introduced

→ T004: Optimize Query

Updating: app/services/auth.ts:45-67

Before:
```typescript
const user = await db.query(
  'SELECT * FROM users WHERE email = ? AND active = true',
  [email]
);
```

After:
```typescript
// Optimized to use idx_users_email_active
const user = await db.query(
  'SELECT * FROM users WHERE email = $1 AND active = $2',
  [email, true]
);
```

✓ Query optimized to use composite index

🔍 Tech Stack Validation
✓ TypeScript async/await: Compliant
✓ PostgreSQL parameterized query: Compliant

→ T005: Add Performance Monitoring

Adding monitoring to app/services/auth.ts:

```typescript
const startTime = Date.now();
const user = await db.query(...);
const queryDuration = Date.now() - startTime;

logger.info('Auth query performance', {
  duration_ms: queryDuration,
  email: email,
  success: !!user
});

if (queryDuration > 1000) {
  logger.warn('Slow auth query detected', { duration_ms: queryDuration });
}
```

✓ Performance monitoring added

→ T006: Verify Test Passes

Running: npm test app/services/auth.test.ts -- --testNamePattern="Bug 042"

Output:
  ✓ Bug 042: Login Timeout Regression Test › login completes within 3 seconds (287 ms)

✅ Test passed! (duration: 287ms - proves bug fixed)

─────────────────────────────────────────────────

Phase 3: Regression Validation

→ T007: Run Full Auth Test Suite

Running: npm test app/services/auth.test.ts

Output:
  Test Suites: 1 passed, 1 total
  Tests:       24 passed, 24 total
  Time:        3.421 s

✅ All auth tests pass (no regressions)

→ T008: Performance Validation

Running load test: 100 concurrent login requests

Output:
  Total requests: 100
  Successful: 100 (100%)
  Failed: 0 (0%)

  Performance:
    Min: 156ms
    Max: 412ms
    Avg: 273ms
    P95: 358ms
    P99: 398ms

✅ All requests completed < 3s
✅ Performance validated under load

─────────────────────────────────────────────────

🎣 Post-Bugfix Hook

Workflow End Time: 2025-10-12 15:42:00
Duration: 1h 12min

✓ Bug fixed successfully
✓ Regression test added and passing
✓ No new regressions introduced
✓ Performance validated under load
✓ Tech stack compliant (PostgreSQL, TypeScript)

📊 Metrics saved: /memory/workflow-metrics.json

─────────────────────────────────────────────────

✅ Bugfix Workflow Complete - Feature 042

📋 Artifacts Created:
- /features/042-login-timeout/bugfix.md
- /features/042-login-timeout/regression-test.md
- /features/042-login-timeout/tasks.md

📊 Results:
- Bug fixed successfully ✅
- Regression test created and passing ✅
- No new regressions introduced ✅
- Performance: 287ms avg (was 12.5s) - 97.7% improvement ✅
- Tech stack compliant ✅

⏱️  Time to Fix: 1h 12min

📈 Next Steps:
1. Review artifacts in: /features/042-login-timeout
2. Commit changes: git add . && git commit -m "fix: login timeout issue (bug 042)"
3. Create PR and deploy
4. Monitor production metrics
5. View metrics: /specswarm:workflow-metrics 042
```

---

## Step 7: Commit and Deploy

```bash
# Review changes
git status

# Expected output:
On branch bugfix/042-login-timeout
Changes to be committed:
  new file:   features/042-login-timeout/bugfix.md
  new file:   features/042-login-timeout/regression-test.md
  new file:   features/042-login-timeout/tasks.md
  modified:   app/services/auth.ts
  modified:   app/services/auth.test.ts
  new file:   migrations/20251012-add-auth-index.sql

# Commit
git add .
git commit -m "fix: login timeout issue (bug 042)

- Added composite index on users(email, active)
- Optimized authenticateUser query to use new index
- Added performance monitoring
- Login time: 12.5s → 287ms (97.7% improvement)
- Added regression test to prevent future occurrences

Fixes #042"

# Push and create PR
git push origin bugfix/042-login-timeout
gh pr create --title "Fix: Login timeout issue" --body "$(cat <<'EOF'
## Summary
Fixed login timeout bug affecting 30% of users

## Root Cause
Database query taking 12+ seconds due to missing composite index

## Solution
- Added (email, active) composite index
- Optimized query to use index
- Added performance monitoring

## Results
- Login time: 12.5s → 287ms (97.7% improvement)
- 100% test pass rate
- No regressions
- Validated under load (100 concurrent requests)

## Regression Prevention
Added regression test that will fail if this bug reoccurs

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

## Step 8: Monitor in Production

**After deploying:**

```bash
# View metrics for this bugfix
/specswarm:workflow-metrics 042
```

**Output:**
```
📊 Workflow Metrics: Feature 042

**Feature**: Login Timeout Fix
**Workflow**: Bugfix
**Status**: ✓ Completed

---

## Timeline

Specify   ████ 5min
Plan      ████ 8min
Tasks     ██   3min
Implement ████████████████████████████████ 56min
────────────────────────────────────────────────
Total:    ████████████████████████████████ 1h 12min

## Bugfix Metrics

- Time to fix: 1h 12min
- Regression test created: ✅
- Test failed before fix: ✅ (12.5s timeout)
- Test passed after fix: ✅ (287ms)
- New regressions: 0 ✅
- Tech stack compliance: ✅ (PostgreSQL, TypeScript)
- Performance improvement: 97.7% ✅

## Quality Gates Passed

- ✅ All tests passed (24/24)
- ✅ Tech stack compliant
- ✅ Performance validated under load
- ✅ No regressions introduced

## Production Impact (Post-Deploy)

- Login success rate: 70% → 100% ✅
- Avg login time: 8.2s → 312ms ✅
- User complaints: 0 in first 24h ✅
- Rollback required: No ✅
```

---

## Key Takeaways

### What Went Well

1. **Regression-test-first methodology worked perfectly**
   - Test failed before fix (proved bug existed)
   - Test passed after fix (proved solution worked)
   - Prevents this bug from recurring

2. **Smart integration enhanced the workflow**
   - SpecSwarm validated tech stack (no drift)
   - SpecTest tracked metrics automatically
   - Hooks provided validation at each phase

3. **Performance improvement was dramatic**
   - 12.5s → 287ms (97.7% improvement)
   - Load testing validated fix under stress
   - Production metrics confirmed success

4. **Complete documentation created automatically**
   - Bug specification
   - Regression test specification
   - Task breakdown
   - All in `/features/042-login-timeout/`

### Why This Approach Works

1. **Test-first ensures correctness**
   - Can't claim "fixed" unless test passes
   - Test proves bug existed (failure before fix)
   - Test proves bug fixed (success after fix)

2. **Prevents regressions**
   - Test stays in codebase forever
   - CI/CD will catch if bug reintroduced
   - Builds confidence in changes

3. **Documents the bug**
   - Root cause analysis captured
   - Solution rationale documented
   - Future developers understand why

4. **Integrates with existing tools**
   - Tech stack validation (no drift)
   - Parallel execution (where applicable)
   - Metrics tracking (continuous improvement)

---

## Comparison: With vs Without SpecLab

### Without SpecSwarm Bugfix (Ad-hoc)

```
1. Read bug report
2. Try to reproduce manually
3. Make changes (no test first)
4. Test manually
5. Hope it works
6. Push to production
7. 😰 Hope it doesn't break
8. No regression prevention

Result:
- No proof bug existed
- No proof fix works
- Could reintroduce later
- No documentation
- ~2-3 hours (lots of manual testing)
```

### With SpecSwarm Bugfix (Systematic)

```
1. /specswarm:bugfix
2. Claude guides through regression-test-first
3. Test fails (proves bug exists)
4. Implement fix
5. Test passes (proves fix works)
6. Full test suite passes (no regressions)
7. Push with confidence
8. ✅ Regression test prevents recurrence

Result:
- Proof bug existed (failed test)
- Proof fix works (passing test)
- Cannot reintroduce (regression test)
- Complete documentation
- ~1-2 hours (automated workflow)
```

---

## Try It Yourself

**Got a bug to fix?**

```bash
# 1. Create bugfix branch
git checkout -b bugfix/NNN-description

# 2. Run workflow
/specswarm:bugfix

# 3. Follow Claude's guidance

# 4. Get a proven fix with regression prevention
```

**Questions?**
- [Full SpecSwarm Documentation](../../plugins/specswarm/README.md)
- [SpecSwarm Commands Reference](../../plugins/specswarm/COMMANDS.md)
