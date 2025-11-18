# Natural Language Command Detection - Implementation Plan

**Version:** v3.3.0
**Status:** Approved for Implementation
**Date:** 2025-11-17

---

## Executive Summary

Add natural language detection for the "Big 4" high-level commands (build, fix, upgrade, ship) while keeping slash commands available for precision and safety.

**Key Safety Requirement:** ⚠️ **ALWAYS ask user to confirm SHIP command** when detected via natural language. Committing and merging by mistake can have significant consequences.

---

## 1. Detection Strategy: Pattern + Intent Matching

### BUILD Command Triggers

**Primary Intent:** Create something new, add functionality

**Trigger Words (Strong Indicators):**
- `build` - "build a payment system"
- `create` - "create user authentication"
- `add` - "add a dashboard feature"
- `develop` - "develop an admin panel"
- `implement` - "implement shopping cart"
- `make` - "make a search feature"
- `new` (with "feature") - "new feature for notifications"

**Phrases That Indicate BUILD:**
- "I need {feature}"
- "Can you build {feature}"
- "Let's create {feature}"
- "Add {feature} to the app"
- "Build a {feature}"
- "Develop a {feature}"
- "We need to implement {feature}"

**Pattern Detection:**
```regex
^(build|create|add|develop|implement|make|new feature)\s+
^(i need|can you|let's|we need)\s+(to\s+)?(build|create|add)
```

**Confidence Levels:**
- High (95%+): "build authentication", "create payment feature"
- Medium (70-94%): "add user profiles", "I need a dashboard"
- Low (50-69%): "make something for users" (too vague)

**Auto-Execution:** ✅ YES for high confidence (>95%)

---

### FIX Command Triggers

**Primary Intent:** Repair broken functionality, resolve bugs

**Trigger Words (Strong Indicators):**
- `fix` - "fix the login issue"
- `bug` - "there's a bug in checkout"
- `broken` - "the search is broken"
- `doesn't work` - "login doesn't work"
- `not working` - "payment not working"
- `error` - "getting an error on submit"
- `issue` - "issue with the form"
- `problem` - "problem with authentication"
- `fails` - "upload fails on mobile"

**Phrases That Indicate FIX:**
- "{feature} doesn't work"
- "There's a bug in {feature}"
- "{feature} is broken"
- "Fix the {feature}"
- "Getting an error when {action}"
- "{feature} fails to {action}"
- "Problem with {feature}"

**Pattern Detection:**
```regex
^(fix|bug|broken|issue|problem|error|fails)\s+
(doesn't|don't|not)\s+work
^there('s| is)\s+a\s+(bug|issue|problem)
^getting\s+(an\s+)?error
```

**Confidence Levels:**
- High (95%+): "fix login bug", "checkout doesn't work"
- Medium (70-94%): "issue with payments", "getting error"
- Low (50-69%): "something is wrong" (too vague)

**Auto-Execution:** ✅ YES for high confidence (>95%)

---

### SHIP Command Triggers

**Primary Intent:** Complete feature and prepare for merge/deployment

**⚠️ CRITICAL SAFETY REQUIREMENT:**
**ALWAYS require explicit user confirmation before executing SHIP command when detected via natural language, regardless of confidence level.**

**Rationale:** Committing and merging by mistake can have significant consequences:
- Premature feature deployment
- Incomplete code in production
- Merge conflicts
- Breaking main branch
- Team disruption

**Trigger Words (Strong Indicators):**
- `ship` - "ship this feature"
- `deploy` - "deploy to production"
- `merge` - "merge this"
- `complete` - "complete this feature"
- `finish` - "finish up"
- `done` - "I'm done with this"
- `ready` - "ready to merge"

**Phrases That Indicate SHIP:**
- "Ship it"
- "Ship this feature"
- "Deploy this"
- "Merge to main"
- "I'm done"
- "Ready to merge"
- "Complete this feature"
- "Finish this up"

**Pattern Detection:**
```regex
^(ship|deploy|merge|complete|finish|done|ready)\s*
^i('m| am)\s+done
^ready\s+to\s+(merge|deploy|ship)
```

**Confidence Levels:**
- High (95%+): "ship it", "deploy this", "merge to main"
- Medium (70-94%): "I'm done", "ready to merge"
- Low (50-69%): "finish" (ambiguous - finish what?)

**Auto-Execution:** ❌ NEVER - ALWAYS require confirmation

**Confirmation Flow:**
```
User: "ship this feature"

SpecSwarm:
  🎯 Detected: SHIP workflow (98% confidence)

  ⚠️  SHIP COMMAND CONFIRMATION REQUIRED

  This will:
    • Run quality validation
    • Create git commit
    • Merge to parent branch
    • Mark feature as complete

  Current branch: 003-payment-processing
  Merge target: main

  Are you sure you want to ship this feature? (yes/no): _

  [Only proceed if user types "yes" or "y"]
```

---

### UPGRADE Command Triggers

**Primary Intent:** Modernize technology, migrate frameworks

**Trigger Words (Strong Indicators):**
- `upgrade` - "upgrade to React 19"
- `update` - "update dependencies"
- `migrate` - "migrate from Redux to Zustand"
- `modernize` - "modernize the codebase"
- `refactor to` - "refactor to TypeScript"

**Phrases That Indicate UPGRADE:**
- "Upgrade {tech} to {version}"
- "Migrate from {old} to {new}"
- "Update to {tech}"
- "Modernize {component}"
- "Refactor to {tech}"

**Pattern Detection:**
```regex
^(upgrade|update|migrate|modernize)\s+
\s+from\s+\S+\s+to\s+\S+  # "from X to Y" pattern
^refactor\s+to\s+
```

**Confidence Levels:**
- High (95%+): "upgrade to React 19", "migrate from Redux to Zustand"
- Medium (70-94%): "update dependencies", "modernize codebase"
- Low (50-69%): "improve performance" (might be refactor, not upgrade)

**Auto-Execution:** ✅ YES for high confidence (>95%)

---

## 2. Ambiguity Resolution Strategy

### Scenario 1: Multiple Commands Match

**Example:** "fix authentication feature"
- Could mean: FIX (bug in auth) OR MODIFY (change auth requirements)

**Resolution:**
```
SpecSwarm detected: FIX workflow (85% confidence)

You mentioned "authentication". Which action do you want?
  1. Fix a bug in authentication (/specswarm:fix)
  2. Modify authentication requirements (/specswarm:modify)
  3. Refactor authentication code (/specswarm:refactor)

Your choice (1/2/3): _
```

### Scenario 2: Low Confidence Match

**Example:** "work on the dashboard"
- Too vague - what kind of work?

**Resolution:**
```
I detected you want to work on "dashboard" but unclear which workflow:
  1. Build new dashboard features (/specswarm:build)
  2. Fix dashboard bugs (/specswarm:fix)
  3. Upgrade dashboard technology (/specswarm:upgrade)
  4. Modify dashboard requirements (/specswarm:modify)

Your choice (1/2/3/4): _
```

### Scenario 3: No Clear Match

**Example:** "help me with the app"
- No trigger words detected

**Resolution:**
```
I can help! What would you like to do?
  • Build a new feature (/specswarm:build)
  • Fix a bug (/specswarm:fix)
  • Upgrade technology (/specswarm:upgrade)
  • Ship completed work (/specswarm:ship)

Or use a specific command: /specswarm:build "feature description"
```

---

## 3. Implementation Architecture

### File Structure
```
plugins/specswarm/
├── lib/
│   ├── natural-language-dispatcher.sh  # NEW: Detection logic
│   ├── features-location.sh           # Existing
│   └── web-project-detector.sh        # Existing
├── commands/
│   ├── build.md    # Enhanced with NL metadata
│   ├── fix.md      # Enhanced with NL metadata
│   ├── ship.md     # Enhanced with NL metadata
│   └── upgrade.md  # Enhanced with NL metadata
└── .claude-plugin/
    └── command-patterns.json  # NEW: Pattern definitions
```

### Detection Algorithm

**Step 1: Check for Slash Command First**
```bash
# If input starts with /, use existing command system
if [[ "$USER_INPUT" =~ ^/ ]]; then
  # Use current slash command system
  execute_slash_command "$USER_INPUT"
  exit 0
fi

# Otherwise, attempt natural language detection
detect_and_execute_nl_command "$USER_INPUT"
```

**Step 2: Normalize Input**
```bash
normalize_input() {
  echo "$1" |
    tr '[:upper:]' '[:lower:]' |  # lowercase
    sed 's/[^a-z0-9 ]/ /g' |       # remove special chars
    sed 's/  */ /g'                # collapse spaces
}
```

**Step 3: Score Each Command**
```bash
score_command() {
  local input="$1"
  local command="$2"
  local score=0

  # Load patterns for this command
  source "$(dirname "$0")/patterns/${command}-patterns.sh"

  # Check for primary trigger words (50 points each)
  for trigger in "${PRIMARY_TRIGGERS[@]}"; do
    echo "$input" | grep -q "\b$trigger\b" && score=$((score + 50))
  done

  # Check for phrase patterns (30 points each)
  for pattern in "${PHRASE_PATTERNS[@]}"; do
    echo "$input" | grep -qE "$pattern" && score=$((score + 30))
  done

  # Subtract points for conflicting indicators
  for conflict in "${CONFLICTING_WORDS[@]}"; do
    echo "$input" | grep -q "\b$conflict\b" && score=$((score - 20))
  done

  echo $score
}
```

**Step 4: Select Best Match**
```bash
detect_workflow() {
  local input="$1"
  local normalized=$(normalize_input "$input")

  # Score each command
  build_score=$(score_command "$normalized" "build")
  fix_score=$(score_command "$normalized" "fix")
  ship_score=$(score_command "$normalized" "ship")
  upgrade_score=$(score_command "$normalized" "upgrade")

  # Find highest score
  max_score=0
  detected_command=""

  [ $build_score -gt $max_score ] && max_score=$build_score && detected_command="build"
  [ $fix_score -gt $max_score ] && max_score=$fix_score && detected_command="fix"
  [ $ship_score -gt $max_score ] && max_score=$ship_score && detected_command="ship"
  [ $upgrade_score -gt $max_score ] && max_score=$upgrade_score && detected_command="upgrade"

  # Determine confidence level
  if [ $max_score -ge 95 ]; then
    confidence="high"
  elif [ $max_score -ge 70 ]; then
    confidence="medium"
  else
    confidence="low"
  fi

  echo "${detected_command}:${confidence}:${max_score}"
}
```

**Step 5: Execute with Appropriate Safety Checks**
```bash
execute_nl_command() {
  local detection_result=$(detect_workflow "$USER_INPUT")
  local command=$(echo "$detection_result" | cut -d: -f1)
  local confidence=$(echo "$detection_result" | cut -d: -f2)
  local score=$(echo "$detection_result" | cut -d: -f3)

  # CRITICAL: SHIP command ALWAYS requires confirmation
  if [ "$command" = "ship" ]; then
    echo "🎯 Detected: SHIP workflow (${confidence} confidence, score: ${score})"
    echo ""
    echo "⚠️  SHIP COMMAND CONFIRMATION REQUIRED"
    echo ""
    echo "This will:"
    echo "  • Run quality validation"
    echo "  • Create git commit"
    echo "  • Merge to parent branch"
    echo "  • Mark feature as complete"
    echo ""
    echo "Current branch: $(git branch --show-current)"
    echo "Merge target: $(get_parent_branch)"
    echo ""
    read -p "Are you sure you want to ship this feature? (yes/no): " confirm

    if [ "$confirm" != "yes" ] && [ "$confirm" != "y" ]; then
      echo "❌ SHIP command cancelled"
      exit 0
    fi

    # Confirmed - proceed with ship
    /specswarm:ship
    exit 0
  fi

  # For other commands, use confidence-based execution
  if [ "$confidence" = "high" ]; then
    echo "🎯 Detected: ${command^^} workflow (${confidence} confidence)"
    echo ""
    echo "Running: /specswarm:${command} \"${USER_INPUT}\""
    echo ""
    /specswarm:${command} "$USER_INPUT"
  elif [ "$confidence" = "medium" ]; then
    # Ask for confirmation
    echo "🤔 I think you want to ${command^^} (${confidence} confidence)"
    echo ""
    read -p "Is this correct? (y/n): " confirm

    if [ "$confirm" = "y" ] || [ "$confirm" = "yes" ]; then
      /specswarm:${command} "$USER_INPUT"
    else
      show_command_options
    fi
  else
    # Low confidence - show options
    show_command_options
  fi
}
```

---

## 4. User Experience Flows

### Example 1: BUILD - High Confidence (Auto-Execute)

```
User: "Build a user authentication system with JWT tokens"

SpecSwarm:
  🎯 Detected: BUILD workflow (98% confidence)

  Running: /specswarm:build "user authentication system with JWT tokens"

  Step 1: Creating specification...
  [continues with build workflow]
```

### Example 2: FIX - Medium Confidence (Ask First)

```
User: "Add authentication to the app"

SpecSwarm:
  🤔 I think you want to BUILD a new feature (75% confidence)

  Is this correct? (y/n): _

User: y

SpecSwarm:
  ✅ Starting BUILD workflow...
  [continues]
```

### Example 3: SHIP - ALWAYS Confirm (Safety)

```
User: "ship it"

SpecSwarm:
  🎯 Detected: SHIP workflow (99% confidence)

  ⚠️  SHIP COMMAND CONFIRMATION REQUIRED

  This will:
    • Run quality validation
    • Create git commit
    • Merge to parent branch: main
    • Mark feature 003-payment-processing as complete

  Current branch: 003-payment-processing
  Merge target: main

  Are you sure you want to ship this feature? (yes/no): _

User: yes

SpecSwarm:
  ✅ Confirmed. Starting SHIP workflow...

  Running quality checks...
  [continues with ship workflow]
```

### Example 4: Low Confidence (Show Options)

```
User: "Work on the payment system"

SpecSwarm:
  I can help with payments! What would you like to do?

  1. Build payment integration (new feature)
  2. Fix payment bugs
  3. Upgrade payment provider
  4. Modify payment requirements

  Your choice (1-4): _

User: 1

SpecSwarm:
  ✅ Starting BUILD workflow for payment integration...
  [continues]
```

---

## 5. Trigger Word Reference Table

| Command | Primary Triggers | Secondary Triggers | Confidence Boosters | Auto-Execute |
|---------|------------------|-------------------|---------------------|--------------|
| **BUILD** | build, create, add, develop, implement | make, new feature | "I need", "can you" | ✅ High conf. |
| **FIX** | fix, bug, broken, error, issue | problem, doesn't work, fails | "getting error", "not working" | ✅ High conf. |
| **SHIP** | ship, deploy, merge, complete | done, ready, finish | "I'm done", "ready to" | ❌ **NEVER** |
| **UPGRADE** | upgrade, update, migrate | modernize, refactor to | "from X to Y", "to version" | ✅ High conf. |

---

## 6. Edge Cases & Solutions

### Edge Case 1: "Build fix for authentication"
- Contains both "build" AND "fix"
- **Solution:** "fix" gets priority (higher semantic weight for repairs)
- **Result:** FIX workflow

### Edge Case 2: "Ship the bugfix"
- Contains both "ship" AND "bug"
- **Solution:** "ship" is action verb, "bug" is descriptor
- **Result:** SHIP workflow (with mandatory confirmation)

### Edge Case 3: "I need to fix the build"
- "fix" + "build" but "build" is object, not verb
- **Solution:** Verb takes priority
- **Result:** FIX workflow (fixing the build process)

### Edge Case 4: Context-free "Fix it"
- No description of what to fix
- **Solution:** Prompt for details
- **Result:** "Fix what? Please describe the bug/issue"

### Edge Case 5: Technical jargon
- "Implement OAuth2 PKCE flow with refresh tokens"
- Contains "implement" = BUILD
- **Result:** BUILD workflow (high confidence)

### Edge Case 6: False positive SHIP detection
- User says: "I'm done reviewing the code" (not ready to ship)
- Contains "done" trigger word
- **Solution:** SHIP confirmation catches this
- **User can decline:** "Are you sure you want to ship? (yes/no): no"

---

## 7. Fallback Mechanisms

### 1. Always Show Detected Command
```
🎯 Running: /specswarm:build "authentication system"
(Detected from: "build authentication system")
```

### 2. Allow Override (Except SHIP)
```
Press Ctrl+C within 3 seconds to cancel...
[3... 2... 1...]
Proceeding with BUILD workflow
```

**Note:** SHIP command does NOT have timeout - must explicitly type "yes"

### 3. Learn from Corrections
Store in memory.db when user corrects detection:
```sql
INSERT INTO nl_corrections (
  user_input,
  detected_command,
  actual_command,
  timestamp
) VALUES (
  'add payment processing',
  'build',
  'fix',  -- user said it was actually a fix
  NOW()
);
```

### 4. Provide Slash Command Alternative
```
Or use the precise command: /specswarm:build "feature description"
```

---

## 8. Safety Matrix

| Scenario | Detection | Confirmation Required | Can Cancel |
|----------|-----------|----------------------|------------|
| BUILD detected (high conf) | Auto | No | Yes (3s timeout) |
| BUILD detected (medium conf) | Prompt | Yes (y/n) | Yes |
| FIX detected (high conf) | Auto | No | Yes (3s timeout) |
| FIX detected (medium conf) | Prompt | Yes (y/n) | Yes |
| SHIP detected (any conf) | Prompt | **ALWAYS (yes/no)** | **Yes** |
| UPGRADE detected (high conf) | Auto | No | Yes (3s timeout) |
| UPGRADE detected (medium conf) | Prompt | Yes (y/n) | Yes |
| Low confidence (any) | Show options | Yes (number choice) | Yes |

**Key Safety Rule:** SHIP is special - ALWAYS requires explicit "yes" confirmation, no timeout bypass.

---

## 9. Implementation Phases

### Phase 1: Core Detection (v3.3.0) - THIS PLAN

**Deliverables:**
- ✅ Natural language detection algorithm
- ✅ Support for BUILD, FIX, SHIP, UPGRADE
- ✅ Confidence-based execution
- ✅ **SHIP safety confirmation (mandatory)**
- ✅ Pattern files for each command
- ✅ Command dispatcher logic

**Files to Create:**
- `lib/natural-language-dispatcher.sh`
- `lib/patterns/build-patterns.sh`
- `lib/patterns/fix-patterns.sh`
- `lib/patterns/ship-patterns.sh`
- `lib/patterns/upgrade-patterns.sh`
- `.claude-plugin/command-patterns.json`

**Files to Modify:**
- `commands/build.md` (add NL metadata)
- `commands/fix.md` (add NL metadata)
- `commands/ship.md` (add NL metadata + safety warnings)
- `commands/upgrade.md` (add NL metadata)
- `README.md` (document NL feature)

**Testing Checklist:**
- [ ] High confidence BUILD detection auto-executes
- [ ] High confidence FIX detection auto-executes
- [ ] **SHIP detection ALWAYS asks for confirmation (any confidence)**
- [ ] Medium confidence prompts for confirmation
- [ ] Low confidence shows numbered options
- [ ] Edge cases handled correctly
- [ ] Slash commands still work unchanged
- [ ] User can cancel with Ctrl+C (except SHIP)
- [ ] **SHIP cannot be bypassed via timeout**

### Phase 2: Learning System (v3.4.0) - FUTURE

**Deliverables:**
- Store user corrections in memory.db
- Improve detection accuracy over time
- Team-wide learning via exported patterns
- Per-user pattern customization

### Phase 3: Advanced Features (v3.5.0) - FUTURE

**Deliverables:**
- Multi-command detection ("build auth then ship")
- Context awareness (remember last feature worked on)
- Personalized patterns per user
- Voice command support (optional)

---

## 10. Benefits Summary

✅ **Lower Learning Curve:** No need to memorize slash command names
✅ **Natural Conversation:** Talk to SpecSwarm like a teammate
✅ **Faster Workflows:** Skip typing `/specswarm:`
✅ **Still Precise:** Slash commands remain for power users
✅ **Confidence Indicators:** Users know when detection is uncertain
✅ **Graceful Degradation:** Falls back to asking when unsure
✅ **Safety First:** SHIP command has mandatory confirmation
✅ **No Accidents:** Can't accidentally merge/deploy via typo

---

## 11. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| **False positive SHIP** | HIGH (unwanted merge) | **Mandatory confirmation, no timeout bypass** |
| **False detection** | Medium | Show detected command, allow 3s cancel |
| **Ambiguous input** | Low | Ask clarifying question with options |
| **User frustration** | Low | Always offer slash command alternative |
| **Token waste** | Low | Only load detection when no `/` prefix |
| **Confusion** | Low | Clear visual indicators (🎯, ⚠️, 🤔) |

---

## 12. Success Metrics

**How we'll measure success:**

1. **Adoption Rate:**
   - % of commands executed via NL vs slash commands
   - Target: 40%+ within 3 months

2. **Accuracy:**
   - % of high-confidence detections that were correct
   - Target: 95%+ accuracy

3. **User Satisfaction:**
   - Survey: "NL commands made SpecSwarm easier to use"
   - Target: 80%+ agree

4. **Safety:**
   - Zero accidental SHIP executions
   - Target: 0 incidents

5. **Learning Effectiveness:**
   - Detection accuracy improvement over time
   - Target: +5% accuracy per month (Phase 2)

---

## 13. Documentation Requirements

**README.md updates:**
- Add "Natural Language Commands" section
- Show examples of NL vs slash command usage
- Explain confidence levels
- **Highlight SHIP safety confirmation**

**Example:**
```markdown
## Natural Language Commands (v3.3.0+)

SpecSwarm now understands natural language! Just describe what you want:

### Examples

**Build a feature:**
- "Build user authentication with JWT"
- "Create a payment processing system"
- "Add dashboard analytics"

**Fix a bug:**
- "Fix the login button on mobile"
- "There's a bug in checkout"
- "Authentication doesn't work"

**Ship a feature:**
- "Ship this feature" ⚠️ (requires confirmation)
- "Deploy to production" ⚠️ (requires confirmation)
- "Merge to main" ⚠️ (requires confirmation)

**Upgrade technology:**
- "Upgrade to React 19"
- "Migrate from Redux to Zustand"

### Safety Features

🛡️ **SHIP Protection:** Ship commands ALWAYS require explicit confirmation
to prevent accidental merges or deployments.

💡 **Confidence Levels:** SpecSwarm shows confidence and asks when uncertain.

⚡ **Still Fast:** High-confidence commands execute immediately (except SHIP).

🎯 **Still Precise:** Slash commands work exactly as before for power users.
```

---

## 14. Related Documentation

- See: `docs/chrome-devtools-mcp-integration.md` (completed v3.2.0)
- See: `docs/features-directory-migration.md` (completed v3.2.0)
- See: `docs/sqlite-memory-backend-plan.md` (future v3.3.0)
- See: `docs/progressive-loading-plan.md` (future v3.3.0)

---

## Conclusion

This plan implements natural language command detection for SpecSwarm's four high-level workflows (BUILD, FIX, UPGRADE, SHIP) with a strong emphasis on safety, especially for the SHIP command.

**Key Differentiators:**
- Confidence-based execution
- **Mandatory SHIP confirmation (no bypass)**
- Graceful degradation to prompts
- Slash commands always available
- Learning system for improvement

**Critical Safety Commitment:**
The SHIP command will NEVER auto-execute, regardless of confidence level, because the consequences of accidental commits/merges are too severe. This makes SpecSwarm's NL system safer than alternatives that might auto-execute destructive operations.

**Next Steps:**
1. Review and approve this plan
2. Implement Phase 1 (Core Detection)
3. Test thoroughly with focus on SHIP safety
4. Document in README.md
5. Release as v3.3.0

---

**Approved By:** [Pending]
**Implementation Start:** [Pending]
**Target Release:** v3.3.0
