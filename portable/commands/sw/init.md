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
echo "Checking for existing SpecSwarm configuration..."
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
  echo "Found existing configuration files:"
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
echo "Backed up existing files to .specswarm/.backup/"
```

---

### Step 2: Auto-Detect Technology Stack

**Skip this step if `--skip-detection` flag is present.**

```bash
echo "Auto-detecting technology stack..."
echo ""

# Check for common config files
AUTO_DETECT=false
FRAMEWORK=""
LANGUAGE=""
BUILD_TOOL=""

if [ -f "package.json" ]; then
  AUTO_DETECT=true

  # Detect framework from dependencies
  if grep -q '"react"' package.json; then
    if grep -q '"next"' package.json; then
      FRAMEWORK="Next.js"
    elif grep -q '"remix"' package.json || grep -q '"react-router"' package.json; then
      FRAMEWORK="React Router / Remix"
    else
      FRAMEWORK="React"
    fi
  elif grep -q '"vue"' package.json; then
    FRAMEWORK="Vue"
  elif grep -q '"angular"' package.json; then
    FRAMEWORK="Angular"
  elif grep -q '"svelte"' package.json; then
    FRAMEWORK="Svelte"
  fi

  # Detect TypeScript
  if grep -q '"typescript"' package.json; then
    LANGUAGE="TypeScript"
  else
    LANGUAGE="JavaScript"
  fi

  # Detect build tool
  if grep -q '"vite"' package.json; then
    BUILD_TOOL="Vite"
  elif grep -q '"webpack"' package.json; then
    BUILD_TOOL="Webpack"
  fi

  echo "Detected from package.json:"
  echo "  Framework: ${FRAMEWORK:-Not detected}"
  echo "  Language: ${LANGUAGE:-Not detected}"
  echo "  Build Tool: ${BUILD_TOOL:-Not detected}"
  echo ""
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  AUTO_DETECT=true
  LANGUAGE="Python"
  echo "Detected Python project"
elif [ -f "composer.json" ]; then
  AUTO_DETECT=true
  LANGUAGE="PHP"
  echo "Detected PHP project"
elif [ -f "go.mod" ]; then
  AUTO_DETECT=true
  LANGUAGE="Go"
  echo "Detected Go project"
elif [ -f "Cargo.toml" ]; then
  AUTO_DETECT=true
  LANGUAGE="Rust"
  echo "Detected Rust project"
else
  echo "No configuration file detected - manual configuration mode"
  echo ""
  echo "Supported configuration files:"
  echo "   - package.json (JavaScript/TypeScript)"
  echo "   - requirements.txt / pyproject.toml (Python)"
  echo "   - composer.json (PHP)"
  echo "   - go.mod (Go)"
  echo "   - Cargo.toml (Rust)"
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

```
Question 3: "What quality thresholds do you want?"
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

---

### Step 4: Create .specswarm/constitution.md

Use the **SlashCommand** tool to execute the existing constitution command with the gathered information:

```bash
echo "Creating .specswarm/constitution.md..."
```

Use the **SlashCommand** tool:
```
/sw:constitution
```

```bash
echo "Created .specswarm/constitution.md"
```

---

### Step 5: Create .specswarm/tech-stack.md

```bash
echo "Creating .specswarm/tech-stack.md..."

mkdir -p .specswarm

cat > .specswarm/tech-stack.md << 'EOF'
# Tech Stack

**Project**: $PROJECT_NAME
**Generated**: $(date +%Y-%m-%d)
**Auto-Detected**: $AUTO_DETECT

---

## Core Technologies

### Framework
- **$FRAMEWORK**
  - Version: Check package.json
  - Notes: Functional components only (if React)

### Language
- **$LANGUAGE**
  - Strict mode enabled

### Build Tool
- **$BUILD_TOOL**
  - Production optimizations enabled

---

## Approved Libraries

### Data Validation
- Zod v4+ (runtime type validation)

### Utilities
- date-fns (date manipulation)
- lodash-es (utility functions, tree-shakeable)

### Forms (if applicable)
- React Hook Form (if using React)
- Zod validation integration

*Add project-specific approved libraries here*

---

## Prohibited Patterns

### State Management
- Redux (use Zustand or Context API instead)
- MobX (prefer simpler alternatives)

### Deprecated Patterns
- Class components (use functional components with hooks)
- PropTypes (use TypeScript instead)
- Moment.js (use date-fns instead - smaller bundle)

*Add project-specific prohibited patterns here*

---

## Notes

- This file was created by `/sw:init`
- Update this file when adding new technologies or patterns
- Run `/sw:init` again to update with new detections
EOF

echo "Created .specswarm/tech-stack.md"
```

---

### Step 6: Create .specswarm/quality-standards.md

```bash
echo "Creating .specswarm/quality-standards.md..."

cat > .specswarm/quality-standards.md << 'EOF'
# Quality Standards

**Project**: $PROJECT_NAME
**Generated**: $(date +%Y-%m-%d)
**Quality Level**: $QUALITY_LEVEL

---

## Quality Gates

### Minimum Thresholds
- **Quality Score**: $MIN_QUALITY/100
- **Test Coverage**: $MIN_COVERAGE%
- **Enforce Gates**: true

---

## Performance Budgets

- **Max Bundle Size**: 500KB
- **Max Initial Load**: 1000ms
- **Max Chunk Size**: 200KB
- **Enforce Budgets**: true

---

## Code Quality

- **Complexity Threshold**: 10
- **Max File Lines**: 300
- **Max Function Lines**: 50
- **Max Function Parameters**: 5

---

## Testing Requirements

- **Require Tests**: true
- **Minimum Coverage**: $MIN_COVERAGE%

---

## Code Review

- **Require Code Review**: true
- **Min Reviewers**: 1

---

## CI/CD

- **Block Merge on Failure**: true

---

## Custom Checks

### Performance Monitoring
- Monitor Core Web Vitals (LCP, FID, CLS)
- Set performance budgets in CI/CD

### Accessibility
- WCAG 2.1 Level AA compliance
- Automated a11y testing with axe-core

*Add project-specific checks here*

---

## Notes

- Quality level: $QUALITY_LEVEL
- Created by `/sw:init`
- Enforced by `/sw:ship` before merge
- Review and adjust these standards for your team's needs
EOF

echo "Created .specswarm/quality-standards.md"
```

---

### Step 7: Summary and Next Steps

```bash
echo ""
echo "======================================================"
echo "         PROJECT INITIALIZATION COMPLETE"
echo "======================================================"
echo ""
echo "Created Configuration Files:"
echo "   - .specswarm/constitution.md      (governance & principles)"
echo "   - .specswarm/tech-stack.md        (approved technologies)"
echo "   - .specswarm/quality-standards.md (quality gates)"
echo ""
echo "Configuration Summary:"
echo "   Project:        $PROJECT_NAME"
echo "   Framework:      $FRAMEWORK"
echo "   Language:       $LANGUAGE"
echo "   Quality Level:  $QUALITY_LEVEL"
echo "   Min Quality:    $MIN_QUALITY/100"
echo "   Min Coverage:   $MIN_COVERAGE%"
echo ""
echo "Next Steps:"
echo ""
echo "   1. Review the created files in .specswarm/"
echo "   2. Customize as needed for your team"
echo "   3. Build your first feature:"
echo "      /sw:build \"your feature description\""
echo "   4. Ship when ready:"
echo "      /sw:ship"
echo ""
echo "Tips:"
echo "   - Run /sw:suggest for workflow recommendations"
echo "   - Run /sw:help for quick command reference"
echo "   - Tech stack enforcement prevents drift across features"
echo "   - Quality gates ensure consistent code quality"
echo ""
echo "======================================================"
```

---

## Example Usage

### Basic Initialization
```bash
/sw:init
# Interactive questions, auto-detect tech stack
```

### Minimal Setup (No Questions)
```bash
/sw:init --minimal
# Uses all detected values and defaults
```

### Manual Tech Stack (No Auto-Detection)
```bash
/sw:init --skip-detection
# Asks for all technologies manually
```
