---
description: Route natural language requests to appropriate SpecSwarm workflow
args:
  - name: request
    description: Natural language description of what you want to do
    required: true
---

## User Input

```text
$ARGUMENTS
```

## Goal

Analyze the user's natural language request and recommend the appropriate SpecSwarm command.

This command simulates the skill-based routing that the plugin version provides automatically.

---

## Intent Detection Patterns

Parse the user's request and match against these patterns:

### BUILD Patterns (-> /sw:build)
**Keywords**: build, create, make, develop, implement, add, construct, set up, establish, design

**Examples**:
- "build user authentication" -> `/sw:build "user authentication"`
- "create a payment system" -> `/sw:build "payment system"`
- "add dashboard analytics" -> `/sw:build "dashboard analytics"`
- "implement shopping cart" -> `/sw:build "shopping cart"`
- "make a login page" -> `/sw:build "login page"`

### FIX Patterns (-> /sw:fix)
**Keywords**: fix, broken, not working, doesn't work, bug, error, failing, issue, problem, crash

**Examples**:
- "fix the login bug" -> `/sw:fix "login bug"`
- "the checkout is broken" -> `/sw:fix "checkout is broken"`
- "users can't submit forms" -> `/sw:fix "users can't submit forms"`
- "there's an error in the API" -> `/sw:fix "error in the API"`

### MODIFY Patterns (-> /sw:modify)
**Keywords**: change, update, modify, switch, convert, enhance, extend, alter, adjust

**Examples**:
- "change auth to JWT" -> `/sw:modify "change auth to JWT"`
- "add pagination to the API" -> `/sw:modify "add pagination to API"`
- "update the search algorithm" -> `/sw:modify "update search algorithm"`
- "switch from MySQL to PostgreSQL" -> `/sw:modify "switch from MySQL to PostgreSQL"`

### SHIP Patterns (-> /sw:ship)
**Keywords**: ship, deploy, release, merge, publish, finalize, complete, done

**ALWAYS ASK CONFIRMATION** - this is a destructive operation.

**Examples**:
- "ship this feature" -> `/sw:ship`
- "merge to main" -> `/sw:ship`
- "deploy to production" -> `/sw:ship`

### UPGRADE Patterns (-> /sw:upgrade)
**Keywords**: upgrade, update dependencies, migrate, modernize, bump version

**Examples**:
- "upgrade to React 19" -> `/sw:upgrade "upgrade to React 19"`
- "update all dependencies" -> `/sw:upgrade "update all dependencies"`
- "migrate to TypeScript" -> `/sw:upgrade "migrate to TypeScript"`

### REFACTOR Patterns (-> /sw:modify --refactor)
**Keywords**: refactor, clean up, reorganize, restructure, improve code, reduce complexity

**Examples**:
- "refactor the auth module" -> `/sw:modify "auth module" --refactor`
- "clean up the codebase" -> `/sw:modify "codebase" --refactor`

### DEPRECATE Patterns (-> /sw:modify --deprecate)
**Keywords**: deprecate, sunset, retire, phase out, remove feature, end-of-life

**Examples**:
- "deprecate the v1 API" -> `/sw:modify "v1 API" --deprecate`
- "sunset the legacy auth" -> `/sw:modify "legacy auth" --deprecate`

### IMPACT ANALYSIS Patterns (-> /sw:modify --analyze-only)
**Keywords**: impact, blast radius, analyze dependencies, what would happen if

**Examples**:
- "what's the impact of changing the user model?" -> `/sw:modify "user model" --analyze-only`
- "analyze dependencies for auth module" -> `/sw:modify "auth module" --analyze-only`

---

## Execution Steps

### Step 1: Parse User Request

```bash
REQUEST="$ARGUMENTS"

if [ -z "$REQUEST" ]; then
  echo "Error: Please provide a request"
  echo ""
  echo "Usage: /sw:router \"what you want to do\""
  echo ""
  echo "Examples:"
  echo "  /sw:router \"build user authentication\""
  echo "  /sw:router \"fix the login bug\""
  echo "  /sw:router \"change the auth to use JWT\""
  exit 1
fi

echo "Analyzing request: $REQUEST"
echo ""
```

### Step 2: Detect Intent

Analyze the request against the patterns above.

Determine:
1. **Intent Category**: BUILD, FIX, MODIFY, SHIP, UPGRADE, REFACTOR, DEPRECATE, IMPACT_ANALYSIS
2. **Confidence Level**: High (95%+), Medium (70-94%), Low (<70%)
3. **Extracted Description**: The specific task description

### Step 3: Display Recommendation

```bash
echo "----------------------------------------"
echo "Intent Analysis"
echo "----------------------------------------"
echo ""
echo "Detected Intent: [INTENT_CATEGORY]"
echo "Confidence: [HIGH/MEDIUM/LOW]"
echo ""
echo "Recommended Command:"
echo "  [RECOMMENDED_COMMAND]"
echo ""
```

### Step 4: Confirm and Execute

**Use the AskUserQuestion tool to confirm:**

```
Question: "Would you like to run this command?"
Header: "Confirm"
Options:
  1. "Yes, run it" (Recommended)
     Description: "Execute the recommended command now"
  2. "No, show alternatives"
     Description: "See other command options"
  3. "Cancel"
     Description: "Don't run anything"
```

**If user confirms**, use the **SlashCommand tool** to execute the recommended command.

**If user wants alternatives**, display:
- The detected patterns that matched
- Other possible commands that might apply
- Allow user to select a different command

---

## Example Flows

### Example 1: Clear Build Request
```
User: /sw:router "build user authentication with JWT"

Analysis:
  - Keywords found: "build"
  - Clear feature description
  - Confidence: HIGH (95%+)

Recommendation:
  /sw:build "user authentication with JWT"

[Auto-executes after brief pause]
```

### Example 2: Ambiguous Request
```
User: /sw:router "work on the login"

Analysis:
  - No clear action keyword
  - Could be build, fix, or modify
  - Confidence: LOW (<70%)

Options:
  1. /sw:build "login" - Create new login feature
  2. /sw:fix "login" - Fix existing login issues
  3. /sw:modify "login" - Modify login behavior

[Asks user to choose]
```

### Example 3: Ship Request (Always Confirm)
```
User: /sw:router "merge this to main"

Analysis:
  - Keywords found: "merge"
  - SHIP detected
  - Confidence: HIGH

WARNING: Ship is a destructive operation!

Recommendation:
  /sw:ship

[ALWAYS asks for confirmation]
```

---

## Error Handling

**If no intent detected:**
- Display common commands
- Ask user to rephrase or use specific command
- Suggest `/sw:help` for full reference

**If multiple intents detected:**
- List all matching intents
- Ask user to clarify
- Provide examples for disambiguation

---

## Notes

This command exists because the portable version lacks the plugin's automatic skill routing.

In the full plugin version, Claude automatically detects intent and suggests commands based on natural language. This `/sw:router` command provides similar functionality through explicit invocation.

**Tip:** For simple, clear requests, you can skip the router and use commands directly:
- Clear build request: `/sw:build "feature"`
- Clear bug report: `/sw:fix "bug"`
- Ready to merge: `/sw:ship`
