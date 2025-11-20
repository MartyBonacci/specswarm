---
description: Run AI-powered interaction flow validation for any software type (webapp, Android app, REST API, desktop GUI)
visibility: internal
args:
  - name: project_path
    description: Path to project to validate (defaults to current directory)
    required: false
  - name: --session-id
    description: Optional session ID for orchestration integration
    required: false
  - name: --type
    description: Override detected type (webapp|android|rest-api|desktop-gui)
    required: false
  - name: --flows
    description: Path to custom flows JSON file
    required: false
  - name: --url
    description: Override base URL for webapp (default http://localhost:5173)
    required: false
---

# AI-Powered Feature Validation

Run comprehensive validation with intelligent flow generation, interactive error detection, and automatic project type detection.

## Initialize Validation

```bash
echo "🔍 SpecLabs Feature Validation v2.7.0"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Parse arguments
PROJECT_PATH=""
SESSION_ID=""
TYPE_OVERRIDE="auto"
FLOWS_FILE=""
BASE_URL=""

# Check if first arg is a path (doesn't start with --)
if [ -n "$1" ] && [ "${1:0:2}" != "--" ]; then
  PROJECT_PATH="$1"
  shift
else
  PROJECT_PATH="$(pwd)"
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --session-id) SESSION_ID="$2"; shift 2 ;;
    --type) TYPE_OVERRIDE="$2"; shift 2 ;;
    --flows) FLOWS_FILE="$2"; shift 2 ;;
    --url) BASE_URL="$2"; shift 2 ;;
    *) shift ;;
  esac
done

# Validate project path exists
if [ ! -d "$PROJECT_PATH" ]; then
  echo "❌ Error: Project path does not exist: $PROJECT_PATH"
  exit 1
fi

echo "📁 Project: $PROJECT_PATH"
echo ""

# Detect web project and Chrome DevTools MCP availability
PLUGIN_DIR="/home/marty/code-projects/specswarm/plugins/speclabs"
SPECSWARM_PLUGIN_DIR="/home/marty/code-projects/specswarm/plugins/specswarm"

if [ -f "$SPECSWARM_PLUGIN_DIR/lib/web-project-detector.sh" ]; then
  source "$SPECSWARM_PLUGIN_DIR/lib/web-project-detector.sh"

  # Check if Chrome DevTools MCP should be used
  if should_use_chrome_devtools "$PROJECT_PATH"; then
    export CHROME_DEVTOOLS_MODE="enabled"
    export WEB_FRAMEWORK="$WEB_FRAMEWORK"
    echo "🌐 Web project detected: $WEB_FRAMEWORK"
    echo "🎯 Chrome DevTools MCP: Available for browser automation"
    echo "   (saves ~200MB Chromium download)"
    echo ""
  elif is_web_project "$PROJECT_PATH"; then
    export CHROME_DEVTOOLS_MODE="fallback"
    export WEB_FRAMEWORK="$WEB_FRAMEWORK"
    echo "🌐 Web project detected: $WEB_FRAMEWORK"
    echo "📦 Using Playwright fallback for browser automation"
    echo ""
  else
    export CHROME_DEVTOOLS_MODE="disabled"
  fi
fi

# Source validation orchestrator
source "${PLUGIN_DIR}/lib/validate-feature-orchestrator.sh"
```

## Execute Validation

```bash
# Build orchestrator arguments
ORCHESTRATOR_ARGS=(--project-path "$PROJECT_PATH")

[ -n "$SESSION_ID" ] && ORCHESTRATOR_ARGS+=(--session-id "$SESSION_ID")
[ "$TYPE_OVERRIDE" != "auto" ] && ORCHESTRATOR_ARGS+=(--type "$TYPE_OVERRIDE")
[ -n "$FLOWS_FILE" ] && ORCHESTRATOR_ARGS+=(--flows "$FLOWS_FILE")
[ -n "$BASE_URL" ] && ORCHESTRATOR_ARGS+=(--url "$BASE_URL")

# Execute validation
VALIDATION_RESULT=$(validate_feature_orchestrate "${ORCHESTRATOR_ARGS[@]}")
VALIDATION_EXIT_CODE=$?

if [ $VALIDATION_EXIT_CODE -ne 0 ]; then
  echo ""
  echo "❌ Validation failed to execute"
  echo ""
  echo "Result:"
  echo "$VALIDATION_RESULT" | jq '.'
  exit 1
fi
```

## Display Results

```bash
# Parse result
STATUS=$(echo "$VALIDATION_RESULT" | jq -r '.status')
TYPE=$(echo "$VALIDATION_RESULT" | jq -r '.type')
TOTAL_FLOWS=$(echo "$VALIDATION_RESULT" | jq -r '.summary.total_flows')
PASSED_FLOWS=$(echo "$VALIDATION_RESULT" | jq -r '.summary.passed_flows')
FAILED_FLOWS=$(echo "$VALIDATION_RESULT" | jq -r '.summary.failed_flows')
ERROR_COUNT=$(echo "$VALIDATION_RESULT" | jq -r '.summary.error_count')
DURATION=$(echo "$VALIDATION_RESULT" | jq -r '.metadata.duration_seconds')

# Display summary using orchestrator helper
print_validation_summary "$VALIDATION_RESULT"

# Update session if session ID provided
if [ -n "$SESSION_ID" ]; then
  echo "💾 Updating session: $SESSION_ID"

  # Source feature orchestrator
  source "${PLUGIN_DIR}/lib/feature-orchestrator.sh"
  feature_init

  # Store validation results in session
  SESSION_FILE="${FEATURE_SESSION_DIR}/${SESSION_ID}.json"
  if [ -f "$SESSION_FILE" ]; then
    jq --argjson result "$VALIDATION_RESULT" \
       --arg completed_at "$(date -Iseconds)" \
       '.validation = $result |
        .validation.completed_at = $completed_at' \
       "$SESSION_FILE" > "${SESSION_FILE}.tmp"

    mv "${SESSION_FILE}.tmp" "$SESSION_FILE"
    echo "   ✅ Session updated with validation results"
  else
    echo "   ⚠️  Session file not found (validation results not persisted)"
  fi
fi

echo ""
```

## Validation Status Exit Code

```bash
# Display Chrome DevTools MCP tip for web projects (if applicable)
if [ "$CHROME_DEVTOOLS_MODE" = "fallback" ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "💡 TIP: Enhanced Web Validation Available"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Chrome DevTools MCP provides enhanced browser automation:"
  echo "  • Real-time console error monitoring"
  echo "  • Network request inspection during flows"
  echo "  • Runtime state debugging"
  echo "  • Saves ~200MB Chromium download"
  echo ""
  echo "Install Chrome DevTools MCP:"
  echo "  claude mcp add ChromeDevTools/chrome-devtools-mcp"
  echo ""
  echo "Your validation will automatically use it next time!"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
fi

# Exit with appropriate code based on validation status
if [ "$STATUS" = "passed" ]; then
  echo "✅ VALIDATION PASSED"
  exit 0
elif [ "$STATUS" = "failed" ]; then
  echo "⚠️  VALIDATION FAILED"
  exit 1
else
  echo "❌ VALIDATION ERROR"
  exit 1
fi
```

---

## Features

### Automatic Project Type Detection
- **Webapp**: Detects React, Vite, Next.js, React Router applications
- **Android**: Detects Android projects with AndroidManifest.xml
- **REST API**: Detects OpenAPI specs, Express, FastAPI, Flask
- **Desktop GUI**: Detects Electron, PyQt, Tkinter applications

Detection uses file-based analysis with confidence scoring. Manual override available via `--type` flag.

### Intelligent Flow Generation (Webapp)
- **User-Defined Flows**: Parse from spec.md YAML frontmatter or custom flows file
- **AI-Generated Flows**: Analyze feature artifacts (spec.md, plan.md, tasks.md)
- **Feature Type Detection**: Identifies shopping_cart, social_feed, auth, forms, CRUD patterns
- **Smart Merging**: Combines user + AI flows with deduplication

### Interactive Error Detection (Webapp)
- **Browser Automation**: Chrome DevTools MCP (if installed) or Playwright fallback
- **Chrome DevTools MCP Benefits**:
  - Saves ~200MB Chromium download
  - Persistent browser profile (~/.cache/chrome-devtools-mcp/)
  - Enhanced debugging with real-time console/network monitoring
- **Real-Time Error Capture**: Console errors, uncaught exceptions, network failures
- **Terminal Monitoring**: Tracks dev server output for compilation errors
- **Auto-Fix Retry Loop**: Attempts fixes up to 3 times before manual intervention
- **Dev Server Lifecycle**: Automatic startup and guaranteed cleanup

### Standardized Results
- **JSON Output**: Consistent format across all validator types
- **Rich Metadata**: Duration, tool versions, retry attempts, flow counts
- **Artifacts**: Screenshots, logs, detailed reports
- **Session Integration**: Automatic persistence when session ID provided

---

## Usage Examples

### Standalone Validation

```bash
# Validate current directory (auto-detect type)
/speclabs:validate-feature

# Validate specific project
/speclabs:validate-feature /path/to/my-app

# Override detected type
/speclabs:validate-feature /path/to/project --type webapp

# Use custom flows
/speclabs:validate-feature --flows ./custom-flows.json

# Override base URL
/speclabs:validate-feature --url http://localhost:3000
```

### Integrated with Orchestration

```bash
# Called automatically by orchestrate-feature when --validate is used
/speclabs:orchestrate-feature "Add shopping cart" /path/to/project --validate

# Manual validation with session tracking
/speclabs:validate-feature /path/to/project --session-id feature_20251103_143022
```

### CI/CD Integration

```bash
# Exit code 0 = passed, 1 = failed, useful for CI/CD
/speclabs:validate-feature && echo "Deploy approved" || echo "Fix errors before deploy"
```

---

## Output

### Validation Summary
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  VALIDATION SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Type: webapp
  Status: passed
  Duration: 47s

  Flows: 8/8 passed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Artifacts Location
- **Flow Results**: `<project>/.speclabs/validation/flow-results.json`
- **Screenshots**: `<project>/.speclabs/validation/screenshots/*.png`
- **Dev Server Log**: `<project>/.speclabs/validation/dev-server.log`
- **Test Output**: `<project>/.speclabs/validation/test-output-*.log`

---

## Supported Validators

### v2.7.0
- ✅ **webapp**: Full support with AI flows + Chrome DevTools MCP/Playwright + auto-fix

### Future Versions
- ⏳ **android**: Planned for v2.7.1 (Appium-based)
- ⏳ **rest-api**: Planned for v2.7.2 (Newman/Postman-based)
- ⏳ **desktop-gui**: Planned for v2.7.3 (Electron/desktop automation)

---

**Architecture**: Generic orchestrator with pluggable type-specific validators. Extensible design allows adding new validator types without breaking changes.

**Purpose**: Provide comprehensive, automated validation across any software type, with intelligent flow generation and interactive error detection. Reduces manual testing burden and catches errors before deployment.
