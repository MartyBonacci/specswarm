---
description: Interactive project initialization - creates constitution, tech stack, and quality standards
args:
  - name: --skip-detection
    description: Skip automatic technology detection
    required: false
  - name: --minimal
    description: Use minimal defaults without interactive questions
    required: false
---

## User Input

```text
$ARGUMENTS
```

## Goal

Initialize a new project with SpecSwarm by creating three foundation files:
1. `.specswarm/constitution.md` - Project governance and coding principles
2. `.specswarm/tech-stack.md` - Approved technologies and prohibited patterns
3. `.specswarm/quality-standards.md` - Quality gates and performance budgets

This command streamlines project setup from 3 manual steps to a single interactive workflow.

---

## Execution Steps

### Step 1: Check for Existing Files

```bash
echo "🔍 Checking for existing SpecSwarm configuration..."
echo ""

EXISTING_FILES=()

if [ -f ".specswarm/constitution.md" ]; then
  EXISTING_FILES+=("constitution.md")
fi

if [ -f ".specswarm/tech-stack.md" ]; then
  EXISTING_FILES+=("tech-stack.md")
fi

if [ -f ".specswarm/quality-standards.md" ]; then
  EXISTING_FILES+=("quality-standards.md")
fi

if [ ${#EXISTING_FILES[@]} -gt 0 ]; then
  echo "⚠️  Found existing configuration files:"
  for file in "${EXISTING_FILES[@]}"; do
    echo "   - .specswarm/$file"
  done
  echo ""
fi
```

If existing files found, use **AskUserQuestion** tool:

```
Question: "Existing configuration files detected. What would you like to do?"
Header: "Existing Files"
Options:
  1. "Update existing files"
     Description: "Merge new settings with existing configuration"
  2. "Backup and recreate"
     Description: "Save existing files to .backup/ and create fresh configuration"
  3. "Cancel initialization"
     Description: "Abort and keep existing configuration unchanged"
```

Store response in `$EXISTING_ACTION`.

If `$EXISTING_ACTION` == "Cancel", exit with message.
If `$EXISTING_ACTION` == "Backup and recreate", create backups:

```bash
mkdir -p .specswarm/.backup/$(date +%Y%m%d-%H%M%S)
for file in "${EXISTING_FILES[@]}"; do
  cp ".specswarm/$file" ".specswarm/.backup/$(date +%Y%m%d-%H%M%S)/$file"
done
echo "✅ Backed up existing files to .specswarm/.backup/"
```

---

### Step 2: Auto-Detect Technology Stack

**Skip this step if `--skip-detection` flag is present.**

```bash
echo "🔍 Auto-detecting technology stack..."
echo ""

# Source the multi-language detector
PLUGIN_DIR="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
source "${PLUGIN_DIR}/lib/language-detector.sh"

# Attempt to detect tech stack
if detect_tech_stack "$(pwd)"; then
  AUTO_DETECT=true

  # Display detected stack
  display_detected_stack
else
  # No config file detected - manual configuration mode
  echo "ℹ️  No configuration file detected - auto-detection disabled"
  echo ""
  echo "📋 Supported configuration files:"
  echo "   • package.json (JavaScript/TypeScript)"
  echo "   • requirements.txt / pyproject.toml (Python)"
  echo "   • composer.json (PHP)"
  echo "   • go.mod (Go)"
  echo "   • Gemfile (Ruby)"
  echo "   • Cargo.toml (Rust)"
  echo ""
  echo "💡 Starting a new project?"
  echo ""
  echo "   Consider scaffolding your project first for automatic setup:"
  echo ""
  echo "   # JavaScript/TypeScript"
  echo "   npm create vite@latest . -- --template react-ts  # React + Vite"
  echo "   npx create-next-app@latest .                     # Next.js"
  echo "   npm create astro@latest .                        # Astro"
  echo "   npm create vue@latest .                          # Vue"
  echo ""
  echo "   # Python"
  echo "   pip install flask && flask init                  # Flask"
  echo "   django-admin startproject myproject .            # Django"
  echo "   pip install fastapi && touch main.py             # FastAPI"
  echo ""
  echo "   # PHP"
  echo "   composer create-project laravel/laravel .        # Laravel"
  echo ""
  echo "   # Go"
  echo "   go mod init github.com/username/project          # Go"
  echo ""
  echo "   # Ruby"
  echo "   rails new . --skip-bundle                        # Rails"
  echo ""
  echo "   # Rust"
  echo "   cargo init                                        # Rust"
  echo ""
  echo "   Then re-run /specswarm:init for automatic detection."
  echo ""
  echo "⚠️  Continuing with manual tech stack configuration..."
  echo ""
  read -p "Press Enter to continue with manual setup, or Ctrl+C to scaffold first..."
  echo ""
  AUTO_DETECT=false
fi
```

---

### Step 3: Interactive Configuration (if not --minimal)

**Skip this step if `--minimal` flag is present. Use detected values or sensible defaults.**

Use **AskUserQuestion** tool for configuration:

```
Question 1: "What is your project name?"
Header: "Project"
Options:
  - Auto-detected from package.json "name" field or current directory name
  - Allow custom input via "Other" option
```

Store in `$PROJECT_NAME`.

```
Question 2 (if AUTO_DETECT=true): "We detected your tech stack. Is this correct?"
Header: "Tech Stack"
Options:
  1. "Yes, looks good"
     Description: "Use detected technologies as-is"
  2. "Let me modify"
     Description: "Adjust the detected stack"
  3. "Start from scratch"
     Description: "Manually specify all technologies"
```

Store in `$TECH_CONFIRM`.

If `$TECH_CONFIRM` == "Let me modify" or "Start from scratch" or AUTO_DETECT=false:

```
Question 3: "What is your primary framework?"
Header: "Framework"
Options:
  1. "React"
  2. "Vue"
  3. "Angular"
  4. "Next.js"
  5. "Node.js (backend)"
  6. "Other" (allow custom input)
```

```
Question 4: "What testing framework do you use?"
Header: "Testing"
multiSelect: true
Options:
  1. "Vitest (unit)"
  2. "Jest (unit)"
  3. "Playwright (e2e)"
  4. "Cypress (e2e)"
  5. "Testing Library"
  6. "Other" (allow custom input)
```

```
Question 5: "What quality thresholds do you want?"
Header: "Quality"
Options:
  1. "Standard (80% coverage, 80 quality score)"
     Description: "Recommended for most projects"
  2. "Strict (90% coverage, 90 quality score)"
     Description: "For mission-critical applications"
  3. "Relaxed (70% coverage, 70 quality score)"
     Description: "For prototypes and experiments"
  4. "Custom" (allow custom input)
```

Store in `$QUALITY_LEVEL`.

Parse quality thresholds:
- Standard: min_quality_score=80, min_test_coverage=80
- Strict: min_quality_score=90, min_test_coverage=90
- Relaxed: min_quality_score=70, min_test_coverage=70

```
Question 6: "Do you want to use default coding principles?"
Header: "Principles"
Options:
  1. "Yes, use defaults"
     Description: "DRY, SOLID, type safety, test coverage, documentation"
  2. "Let me provide custom principles"
     Description: "Define your own 3-5 principles"
```

Store in `$PRINCIPLES_CHOICE`.

If `$PRINCIPLES_CHOICE` == "Let me provide custom":
  Ask for custom principles (text input via "Other" option or multiple questions)

---

### Step 4: Create .specswarm/constitution.md

Use the **SlashCommand** tool to execute the existing constitution command with the gathered information:

```bash
echo "📝 Creating .specswarm/constitution.md..."

# If custom principles provided, pass them to constitution command
if [ "$PRINCIPLES_CHOICE" = "custom" ]; then
  # Use SlashCommand tool to run:
  # /specswarm:constitution with custom principles
else
  # Use SlashCommand tool to run:
  # /specswarm:constitution (will use defaults)
fi

echo "✅ Created .specswarm/constitution.md"
```

Use the **SlashCommand** tool:
```
/specswarm:constitution
```

---

### Step 5: Create .specswarm/tech-stack.md

```bash
echo "📝 Creating .specswarm/tech-stack.md..."

# Read template
TEMPLATE=$(cat plugins/specswarm/templates/tech-stack.template.md)

# Replace placeholders
OUTPUT="$TEMPLATE"
OUTPUT="${OUTPUT//\[PROJECT_NAME\]/$PROJECT_NAME}"
OUTPUT="${OUTPUT//\[DATE\]/$(date +%Y-%m-%d)}"
OUTPUT="${OUTPUT//\[AUTO_GENERATED\]/$([[ $AUTO_DETECT == true ]] && echo "Yes" || echo "No")}"
OUTPUT="${OUTPUT//\[FRAMEWORK\]/$FRAMEWORK}"
OUTPUT="${OUTPUT//\[VERSION\]/$FRAMEWORK_VERSION}"
OUTPUT="${OUTPUT//\[FRAMEWORK_NOTES\]/"Functional components only (if React), composition API (if Vue)"}"
OUTPUT="${OUTPUT//\[LANGUAGE\]/$LANGUAGE}"
OUTPUT="${OUTPUT//\[LANGUAGE_VERSION\]/$LANGUAGE_VERSION}"
OUTPUT="${OUTPUT//\[BUILD_TOOL\]/$BUILD_TOOL}"
OUTPUT="${OUTPUT//\[BUILD_TOOL_VERSION\]/$BUILD_TOOL_VERSION}"

# State management section
if [ -n "$STATE_MGMT" ]; then
  STATE_SECTION="- **$STATE_MGMT**
  - Purpose: Application state management
  - Notes: Preferred over alternatives"
else
  STATE_SECTION="- No state management library detected
  - Recommendation: Use React Context for simple state, Zustand for complex state"
fi
OUTPUT="${OUTPUT//\[STATE_MANAGEMENT_SECTION\]/$STATE_SECTION}"

# Styling section
if [ -n "$STYLING" ]; then
  STYLE_SECTION="- **$STYLING**
  - Purpose: Component styling
  - Notes: Follow established patterns in codebase"
else
  STYLE_SECTION="- No styling framework detected
  - Recommendation: Consider Tailwind CSS for utility-first styling"
fi
OUTPUT="${OUTPUT//\[STYLING_SECTION\]/$STYLE_SECTION}"

# Testing section
UNIT_SECTION="${UNIT_TEST:-"Not configured - recommended: Vitest"}"
E2E_SECTION="${E2E_TEST:-"Not configured - recommended: Playwright"}"
OUTPUT="${OUTPUT//\[UNIT_TEST_FRAMEWORK\]/$UNIT_SECTION}"
OUTPUT="${OUTPUT//\[E2E_TEST_FRAMEWORK\]/$E2E_SECTION}"
OUTPUT="${OUTPUT//\[INTEGRATION_TEST_FRAMEWORK\]/${UNIT_TEST:-"Same as unit testing"}}"

# Approved libraries section
APPROVED_SECTION="### Data Validation
- Zod v4+ (runtime type validation)

### Utilities
- date-fns (date manipulation)
- lodash-es (utility functions, tree-shakeable)

### Forms (if applicable)
- React Hook Form (if using React)
- Zod validation integration

*Add project-specific approved libraries here*"
OUTPUT="${OUTPUT//\[APPROVED_LIBRARIES_SECTION\]/$APPROVED_SECTION}"

# Prohibited section
PROHIBITED_SECTION="### State Management
- ❌ Redux (use Zustand or Context API instead)
- ❌ MobX (prefer simpler alternatives)

### Deprecated Patterns
- ❌ Class components (use functional components with hooks)
- ❌ PropTypes (use TypeScript instead)
- ❌ Moment.js (use date-fns instead - smaller bundle)

*Add project-specific prohibited patterns here*"
OUTPUT="${OUTPUT//\[PROHIBITED_SECTION\]/$PROHIBITED_SECTION}"

# Notes section
NOTES_SECTION="- This file was ${AUTO_DETECT:+auto-detected from package.json and }created by \`/specswarm:init\`
- Update this file when adding new technologies or patterns
- Run \`/specswarm:init\` again to update with new detections"
OUTPUT="${OUTPUT//\[NOTES_SECTION\]/$NOTES_SECTION}"

# Write file
echo "$OUTPUT" > .specswarm/tech-stack.md

echo "✅ Created .specswarm/tech-stack.md"
```

---

### Step 6: Create .specswarm/quality-standards.md

```bash
echo "📝 Creating .specswarm/quality-standards.md..."

# Read template
TEMPLATE=$(cat plugins/specswarm/templates/quality-standards.template.md)

# Replace placeholders based on quality level
OUTPUT="$TEMPLATE"
OUTPUT="${OUTPUT//\[PROJECT_NAME\]/$PROJECT_NAME}"
OUTPUT="${OUTPUT//\[DATE\]/$(date +%Y-%m-%d)}"
OUTPUT="${OUTPUT//\[AUTO_GENERATED\]/Yes}"

# Quality thresholds
case "$QUALITY_LEVEL" in
  "Standard")
    MIN_QUALITY=80
    MIN_COVERAGE=80
    ;;
  "Strict")
    MIN_QUALITY=90
    MIN_COVERAGE=90
    ;;
  "Relaxed")
    MIN_QUALITY=70
    MIN_COVERAGE=70
    ;;
  "Custom")
    # Would be provided by user
    MIN_QUALITY="${CUSTOM_QUALITY:-80}"
    MIN_COVERAGE="${CUSTOM_COVERAGE:-80}"
    ;;
  *)
    MIN_QUALITY=80
    MIN_COVERAGE=80
    ;;
esac

OUTPUT="${OUTPUT//\[MIN_QUALITY_SCORE\]/$MIN_QUALITY}"
OUTPUT="${OUTPUT//\[MIN_TEST_COVERAGE\]/$MIN_COVERAGE}"
OUTPUT="${OUTPUT//\[ENFORCE_GATES\]/true}"

# Performance budgets
OUTPUT="${OUTPUT//\[ENFORCE_BUDGETS\]/true}"
OUTPUT="${OUTPUT//\[MAX_BUNDLE_SIZE\]/500}"
OUTPUT="${OUTPUT//\[MAX_INITIAL_LOAD\]/1000}"
OUTPUT="${OUTPUT//\[MAX_CHUNK_SIZE\]/200}"

# Code quality
OUTPUT="${OUTPUT//\[COMPLEXITY_THRESHOLD\]/10}"
OUTPUT="${OUTPUT//\[MAX_FILE_LINES\]/300}"
OUTPUT="${OUTPUT//\[MAX_FUNCTION_LINES\]/50}"
OUTPUT="${OUTPUT//\[MAX_FUNCTION_PARAMS\]/5}"

# Testing
OUTPUT="${OUTPUT//\[REQUIRE_TESTS\]/true}"

# Code review
OUTPUT="${OUTPUT//\[REQUIRE_CODE_REVIEW\]/true}"
OUTPUT="${OUTPUT//\[MIN_REVIEWERS\]/1}"

# CI/CD
OUTPUT="${OUTPUT//\[BLOCK_MERGE_ON_FAILURE\]/true}"

# Custom checks section
CUSTOM_CHECKS="### Performance Monitoring
- Monitor Core Web Vitals (LCP, FID, CLS)
- Set performance budgets in CI/CD

### Accessibility
- WCAG 2.1 Level AA compliance
- Automated a11y testing with axe-core

*Add project-specific checks here*"
OUTPUT="${OUTPUT//\[CUSTOM_CHECKS_SECTION\]/$CUSTOM_CHECKS}"

# Exemptions section
EXEMPTIONS="*No exemptions currently granted. Request exemptions via team discussion.*"
OUTPUT="${OUTPUT//\[EXEMPTIONS_SECTION\]/$EXEMPTIONS}"

# Notes section
NOTES="- Quality level: $QUALITY_LEVEL
- Created by \`/specswarm:init\`
- Enforced by \`/specswarm:ship\` before merge
- Review and adjust these standards for your team's needs"
OUTPUT="${OUTPUT//\[NOTES_SECTION\]/$NOTES}"

# Write file
echo "$OUTPUT" > .specswarm/quality-standards.md

echo "✅ Created .specswarm/quality-standards.md"
```

---

### Step 7: Summary and Next Steps

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "         ✅ PROJECT INITIALIZATION COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📁 Created Configuration Files:"
echo "   ✓ .specswarm/constitution.md      (governance & principles)"
echo "   ✓ .specswarm/tech-stack.md        (approved technologies)"
echo "   ✓ .specswarm/quality-standards.md (quality gates)"
echo ""
echo "📊 Configuration Summary:"
echo "   Project:        $PROJECT_NAME"
echo "   Framework:      $FRAMEWORK $FRAMEWORK_VERSION"
echo "   Language:       $LANGUAGE"
echo "   Quality Level:  $QUALITY_LEVEL"
echo "   Min Quality:    $MIN_QUALITY/100"
echo "   Min Coverage:   $MIN_COVERAGE%"
echo ""
echo "📚 Next Steps:"
echo ""
echo "   1. Review the created files in .specswarm/"
echo "   2. Customize as needed for your team"
echo "   3. Build your first feature:"
echo "      /specswarm:build \"your feature description\""
echo "   4. Ship when ready:"
echo "      /specswarm:ship"
echo ""
echo "💡 Tips:"
echo "   • Run /specswarm:suggest for workflow recommendations"
echo "   • Tech stack enforcement prevents drift across features"
echo "   • Quality gates ensure consistent code quality"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

---

## Important Notes

### Auto-Detection Accuracy

The auto-detection logic parses `package.json` to identify:
- Framework (React, Vue, Angular, Next.js)
- Language (TypeScript vs JavaScript)
- Build tool (Vite, Webpack, built-in)
- State management (Zustand, Redux Toolkit, Jotai)
- Styling (Tailwind, Styled Components, Emotion)
- Testing frameworks (Vitest, Jest, Playwright, Cypress)

Detection is **best-effort** - users can always modify or override detected values.

### File Conflict Handling

If configuration files already exist:
- **Update**: Merges new values with existing (preserves custom edits)
- **Backup**: Saves to `.specswarm/.backup/[timestamp]/` before recreating
- **Cancel**: Aborts initialization, keeps existing files

### Template Customization

Templates are located at:
- `plugins/specswarm/templates/tech-stack.template.md`
- `plugins/specswarm/templates/quality-standards.template.md`

Teams can customize these templates for organization-specific standards.

### Integration with Existing Commands

Once initialized, other commands reference these files:
- `/specswarm:build` - Enforces tech stack
- `/specswarm:ship` - Enforces quality gates
- `/specswarm:analyze-quality` - Reports against standards
- `/specswarm:upgrade` - Updates tech-stack.md

---

## Example Usage

### Basic Initialization
```bash
/specswarm:init
# Interactive questions, auto-detect tech stack
```

### Minimal Setup (No Questions)
```bash
/specswarm:init --minimal
# Uses all detected values and defaults
```

### Manual Tech Stack (No Auto-Detection)
```bash
/specswarm:init --skip-detection
# Asks for all technologies manually
```

### Update Existing Configuration
```bash
/specswarm:init
# Detects existing files, offers to update
```
