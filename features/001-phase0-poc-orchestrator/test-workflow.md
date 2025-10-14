# Test: Phase 0 POC - Like Functionality + User Profiles + Navbar

**Created**: 2025-10-14
**Project**: tweeter-spectest
**Complexity**: Medium
**Estimated Time**: 8-12 hours
**Target**: /home/marty/code-projects/tweeter-spectest

---

## Description

Implement three complete vertical-slice features to test Project Orchestrator's ability to handle realistic multi-feature development:

1. **Like Functionality**: Allow users to like/unlike tweets
2. **User Profiles**: View and edit user profile pages
3. **Navbar Component**: Site-wide navigation

These features represent a realistic development task that would normally take a developer 8-12 hours manually. This tests the orchestrator's ability to:
- Generate effective prompts for complex multi-feature work
- Coordinate agent work across database, backend, and frontend
- Handle tech stack compliance (React Router v7, functional programming, etc.)
- Produce production-ready code

---

## Files to Create/Modify

### Database

**Create**:
- `migrations/004_create_likes_table.sql` - Likes table with constraints
- `migrations/005_add_user_profile_fields.sql` - Add bio/avatar to users

### Backend (Express API)

**Create**:
- `backend/routes/likes.ts` - Like/unlike endpoints
- `backend/routes/users.ts` - User profile GET/PUT endpoints

**Modify**:
- `backend/routes/tweets.ts` - Add like count to tweet responses
- `backend/server.ts` - Register new routes

### Frontend (React Router v7)

**Create**:
- `app/components/Navbar.tsx` - Site-wide navigation component
- `app/components/LikeButton.tsx` - Like button with state
- `app/pages/Profile.tsx` - User profile view page
- `app/pages/ProfileEdit.tsx` - Profile edit page
- `app/actions/likes.ts` - Like/unlike actions
- `app/actions/profiles.ts` - Profile update actions

**Modify**:
- `app/root.tsx` - Add Navbar to root layout
- `app/routes.ts` - Add profile routes
- `app/pages/Feed.tsx` - Add LikeButton to tweets
- `app/pages/TweetDetail.tsx` - Add LikeButton to tweet detail

---

## Changes Required

### Phase 1: Database Schema (Migrations)

#### Migration 004: Likes Table

```sql
-- migrations/004_create_likes_table.sql
CREATE TABLE IF NOT EXISTS likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  tweet_id UUID NOT NULL REFERENCES tweets(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Prevent duplicate likes
  UNIQUE(user_id, tweet_id)
);

-- Index for fast lookups
CREATE INDEX idx_likes_user_id ON likes(user_id);
CREATE INDEX idx_likes_tweet_id ON likes(tweet_id);
CREATE INDEX idx_likes_created_at ON likes(created_at DESC);
```

#### Migration 005: User Profile Fields

```sql
-- migrations/005_add_user_profile_fields.sql
ALTER TABLE users
ADD COLUMN bio TEXT,
ADD COLUMN avatar_url TEXT,
ADD COLUMN updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- Add trigger to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

### Phase 2: Backend API (Express)

#### Likes Routes (`backend/routes/likes.ts`)

**Requirements**:
- POST `/api/likes` - Like a tweet (idempotent)
- DELETE `/api/likes/:tweetId` - Unlike a tweet
- GET `/api/tweets/:id/likes` - Get users who liked (optional, nice-to-have)
- Must verify JWT auth
- Must validate tweet exists
- Must prevent duplicate likes (database constraint)
- Return updated like count

**Tech Stack Compliance**:
- Pure functions (no classes)
- Zod validation
- postgres npm package for DB
- httpOnly cookie auth

#### User Profile Routes (`backend/routes/users.ts`)

**Requirements**:
- GET `/api/users/:id` - Get user profile (public)
- PUT `/api/users/:id` - Update own profile (auth required)
- Must include bio, avatarUrl fields
- Must validate user can only edit their own profile
- Zod validation for bio (max 280 chars) and avatarUrl

#### Update Tweets Routes (`backend/routes/tweets.ts`)

**Requirements**:
- Add like count to tweet response objects
- Add `userHasLiked` boolean (if authenticated)
- Use JOIN or subquery to efficiently get like counts

**Example response**:
```typescript
{
  id: "...",
  content: "...",
  authorId: "...",
  authorUsername: "...",
  createdAt: "...",
  likeCount: 5,
  userHasLiked: true
}
```

---

### Phase 3: Frontend Components

#### Navbar Component (`app/components/Navbar.tsx`)

**Requirements**:
- Display site logo/name
- Navigation links: Home (Feed), Profile (current user)
- Sign out button
- Responsive design (mobile + desktop)
- Use Tailwind CSS + Flowbite
- Must be a functional component
- Show current user's username
- Active link highlighting

**Layout**:
```
[Logo] [Home] [Profile] [User: @username] [Sign Out]
```

#### LikeButton Component (`app/components/LikeButton.tsx`)

**Requirements**:
- Display heart icon (filled if liked, outline if not)
- Display like count
- Click to like/unlike (optimistic UI)
- Disable while request in flight
- Use Form from React Router for mutations
- Must use server actions (no useEffect data fetching)
- Tailwind CSS styling

**States**:
- Not liked: Outline heart, gray color
- Liked: Filled heart, red color
- Loading: Disabled state

#### Profile Page (`app/pages/Profile.tsx`)

**Requirements**:
- Display user info: username, email, bio, avatar
- Show "Edit Profile" button (if viewing own profile)
- Show user's tweets (optional, nice-to-have)
- Use React Router loader to fetch data
- Responsive layout
- Tailwind CSS styling

**Route**: `/profile/:userId`

#### Profile Edit Page (`app/pages/ProfileEdit.tsx`)

**Requirements**:
- Form fields: bio (textarea), avatar URL (text input)
- Cancel button (navigates back)
- Save button (submits form)
- Use React Router action for submission
- Zod client-side validation
- Display validation errors
- Redirect to profile on success

**Route**: `/profile/:userId/edit`

---

### Phase 4: React Router Integration

#### Actions (`app/actions/likes.ts`)

```typescript
// Like/unlike action using React Router server actions
export async function toggleLikeAction({ request }: ActionFunctionArgs) {
  // 1. Get JWT from cookie
  // 2. Call backend API
  // 3. Return updated data
  // 4. Handle errors
}
```

#### Actions (`app/actions/profiles.ts`)

```typescript
// Update profile action
export async function updateProfileAction({ request, params }: ActionFunctionArgs) {
  // 1. Validate with Zod
  // 2. Get JWT from cookie
  // 3. Call backend PUT /api/users/:id
  // 4. Handle errors
  // 5. Redirect to profile on success
}
```

#### Routes (`app/routes.ts`)

Add programmatic routes:
```typescript
{
  path: '/profile/:userId',
  Component: Profile,
  loader: profileLoader,
},
{
  path: '/profile/:userId/edit',
  Component: ProfileEdit,
  loader: profileEditLoader,
  action: updateProfileAction,
}
```

#### Root Layout (`app/root.tsx`)

Add Navbar above Outlet:
```typescript
<Navbar />
<Outlet />
```

---

## Expected Outcome

After implementation, the application should have:

### Like Functionality
- ✅ Users can click heart icon to like tweets
- ✅ Like count displays correctly
- ✅ Heart icon shows filled (red) when liked
- ✅ Users can unlike by clicking again
- ✅ Database prevents duplicate likes
- ✅ Like state persists across page refreshes

### User Profiles
- ✅ Users can view any user's profile at `/profile/:userId`
- ✅ Profile shows username, email, bio, avatar
- ✅ "Edit Profile" button visible on own profile
- ✅ Edit page allows updating bio and avatar URL
- ✅ Changes save successfully
- ✅ Validation prevents bio > 280 chars

### Navbar
- ✅ Navbar appears on all pages
- ✅ Navigation links work (Home, Profile)
- ✅ Active link highlighted
- ✅ Current username displayed
- ✅ Sign out button works
- ✅ Responsive on mobile and desktop

### Tech Stack Compliance
- ✅ All code uses functional programming (no classes)
- ✅ React Router v7 loaders/actions (no useEffect fetching)
- ✅ Programmatic routing (no file-based routes)
- ✅ Zod validation everywhere
- ✅ postgres npm package (no ORM)
- ✅ Tailwind CSS styling
- ✅ JWT in httpOnly cookies

---

## Validation Criteria

### Database Validation
- [ ] Migrations run successfully (`npm run migrate`)
- [ ] Likes table created with proper constraints
- [ ] Users table has bio/avatar fields
- [ ] No SQL errors in logs

### Backend Validation
- [ ] POST `/api/likes` returns 200 and like created
- [ ] DELETE `/api/likes/:tweetId` returns 200 and like removed
- [ ] GET `/api/users/:id` returns user with profile fields
- [ ] PUT `/api/users/:id` updates profile successfully
- [ ] Tweets include `likeCount` and `userHasLiked` fields
- [ ] Auth required for like/unlike
- [ ] Auth required for profile edit
- [ ] Can't edit other users' profiles

### Frontend Validation
- [ ] Navbar visible on all pages
- [ ] Like button appears on tweets
- [ ] Like button state toggles on click
- [ ] Like count increments/decrements
- [ ] Profile page displays user info
- [ ] Edit profile form works
- [ ] Validation errors display correctly
- [ ] Navigation links work
- [ ] Sign out button works

### Browser Validation (Playwright)
- [ ] No console errors
- [ ] No network errors (4xx/5xx)
- [ ] Page loads successfully
- [ ] All UI elements render correctly

### Visual Validation
- [ ] Navbar looks good (spacing, alignment, colors)
- [ ] Like button icon clear (heart visible)
- [ ] Profile page layout clean
- [ ] Edit form styled properly
- [ ] Responsive on mobile width
- [ ] Tailwind classes applied correctly

---

## Test URLs

Primary test URLs for validation:

1. **Feed with Like Buttons**: `http://localhost:5173/feed`
2. **Profile View**: `http://localhost:5173/profile/[user-id]`
3. **Profile Edit**: `http://localhost:5173/profile/[user-id]/edit`
4. **Tweet Detail with Likes**: `http://localhost:5173/tweet/[tweet-id]`

---

## Additional Context

### Tech Stack (MUST COMPLY)

**Approved**:
- TypeScript 5.x (strict mode)
- React Router v7 (framework mode, programmatic routes)
- Express (REST APIs)
- PostgreSQL 17 (via postgres npm package)
- Zod (validation)
- Tailwind CSS + Flowbite (UI)
- JWT + httpOnly cookies (auth)

**PROHIBITED** (will fail validation):
- ❌ Class components or class-based services
- ❌ File-based routing (must use app/routes.ts)
- ❌ useEffect for data fetching (use loaders)
- ❌ ORMs (Drizzle, Prisma, TypeORM)
- ❌ localStorage for tokens
- ❌ Redux (use loaders/actions)

### Functional Programming Patterns

All code MUST use functional programming:
- Pure functions (no side effects in core logic)
- Factory functions (not classes)
- Immutable data transformations
- Function composition

**Example**:
```typescript
// ✅ Good (factory function)
export function createLikeService(db: Database) {
  return {
    async toggleLike(userId: string, tweetId: string) { ... },
    async getLikeCount(tweetId: string) { ... }
  };
}

// ❌ Bad (class)
export class LikeService {
  constructor(private db: Database) {}
  async toggleLike(userId: string, tweetId: string) { ... }
}
```

### Database Naming Conventions

- **Database**: `snake_case` (user_id, created_at)
- **Application**: `camelCase` (userId, createdAt)
- **postgres package handles conversion automatically**

### Authentication Pattern

Extract JWT from cookies in loaders/actions:
```typescript
const cookie = request.headers.get('Cookie');
const response = await fetch(API_URL, {
  headers: { 'Cookie': cookie }
});
```

---

## Success Metrics (Phase 0 Evaluation)

Track these for evaluating Project Orchestrator:

### Agent Performance
- [ ] Agent understood all three features? (Yes/No)
- [ ] Agent completed on first try? (Yes/No)
- [ ] Iteration count needed: _____
- [ ] Time to complete: _____ minutes
- [ ] Manual estimate: 480-720 minutes (8-12 hours)
- [ ] Time savings: _____%

### Code Quality
- [ ] Tech stack compliant? (Yes/No)
- [ ] Functional programming used? (Yes/No)
- [ ] No classes found? (Yes/No)
- [ ] Programmatic routing? (Yes/No)
- [ ] Zod validation everywhere? (Yes/No)
- [ ] Code quality score: 1-10: _____

### Validation Results
- [ ] Playwright validation passed? (Yes/No)
- [ ] Zero console errors? (Yes/No)
- [ ] Zero network errors? (Yes/No)
- [ ] Visual quality acceptable? (Yes/No)

### Orchestrator Effectiveness
- [ ] Prompt quality: 1-10: _____
- [ ] Agent autonomy: 1-10: _____
- [ ] Validation effectiveness: 1-10: _____
- [ ] Overall success: 1-10: _____

---

## Notes for Agent

**This is a test of Project Orchestrator (Phase 0 POC).**

You are implementing three features that represent realistic development work. Focus on:

1. **Tech Stack Compliance**: Follow tweeter-spectest's tech stack EXACTLY
2. **Quality**: Production-ready code, not prototype quality
3. **Completeness**: All three features working end-to-end
4. **Patterns**: Functional programming, no classes
5. **Best Practices**: Proper error handling, validation, security

The orchestrator will validate your work with:
- Browser automation (Playwright)
- Visual analysis (Claude Vision)
- Manual testing

**Work autonomously. Report blockers only if you cannot proceed.**

Good luck! This is the proof that autonomous development can work at realistic scale. 🚀

---

**Workflow Version**: 0.1.0-alpha.1
**Created For**: Project Orchestrator Plugin Phase 0 POC
**Target Project**: tweeter-spectest (/home/marty/code-projects/tweeter-spectest)
