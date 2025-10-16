---
description: Run validation suite on target project (browser, terminal, visual analysis)
---

<!--
ATTRIBUTION:
Project Orchestrator Plugin
by Marty Bonacci & Claude Code (2025)
Based on learnings from Test 4A and Test Orchestrator Agent concept
-->

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Run comprehensive validation on a target project using:
1. **Browser Automation** (Playwright) - Navigate app, capture errors
2. **Visual Analysis** (Claude Vision API) - Analyze screenshots for UI issues
3. **Terminal Monitoring** - Check dev server output for errors

**Usage**: `/speclabs:orchestrate-validate <project-path> [url]`

**Examples**:
```bash
# Validate project at specific path
/speclabs:orchestrate-validate /home/marty/code-projects/tweeter-spectest

# Validate with custom URL
/speclabs:orchestrate-validate /home/marty/code-projects/tweeter-spectest http://localhost:5173
```

---

## Pre-Validation Hook

```bash
echo "🎯 Project Orchestrator - Validation Suite"
echo ""
echo "Phase 0: Research & De-Risk"
echo "Testing: Browser automation + Visual analysis"
echo ""

# Record start time
VALIDATION_START_TIME=$(date +%s)
```

---

## Execution Steps

### Step 1: Parse Arguments

```bash
# Get arguments
ARGS="$ARGUMENTS"

# Parse project path (required)
PROJECT_PATH=$(echo "$ARGS" | awk '{print $1}')

# Parse URL (optional, default to http://localhost:5173)
URL=$(echo "$ARGS" | awk '{print $2}')
if [ -z "$URL" ]; then
  URL="http://localhost:5173"
fi

# Validate project path
if [ -z "$PROJECT_PATH" ]; then
  echo "❌ Error: Project path required"
  echo ""
  echo "Usage: /speclabs:orchestrate-validate <project-path> [url]"
  echo ""
  echo "Example:"
  echo "/speclabs:orchestrate-validate /home/marty/code-projects/tweeter-spectest"
  exit 1
fi

if [ ! -d "$PROJECT_PATH" ]; then
  echo "❌ Error: Project path does not exist: $PROJECT_PATH"
  exit 1
fi

echo "📁 Project: $PROJECT_PATH"
echo "🌐 URL: $URL"
echo ""
```

---

### Step 2: Check If Dev Server Is Running

```bash
echo "🔍 Checking if dev server is running..."
echo ""

# Try to connect to URL
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL" 2>/dev/null || echo "000")

if [ "$HTTP_STATUS" = "000" ]; then
  echo "⚠️  Dev server not running at $URL"
  echo ""
  echo "Please start dev server first:"
  echo "  cd $PROJECT_PATH"
  echo "  npm run dev"
  echo ""
  exit 1
fi

echo "✅ Dev server responding (HTTP $HTTP_STATUS)"
echo ""
```

---

### Step 3: Browser Validation (Playwright)

**NOTE**: For Phase 0, we'll create a simple Node.js script to run Playwright validation.

First, check if Playwright is available in the project:

```bash
echo "📱 Running Browser Validation..."
echo ""

# Check if Playwright is installed in project
cd "$PROJECT_PATH"

if [ ! -d "node_modules/playwright" ]; then
  echo "⚠️  Playwright not installed in project"
  echo ""
  echo "Installing Playwright..."
  npm install --save-dev playwright

  if [ $? -ne 0 ]; then
    echo "❌ Failed to install Playwright"
    exit 1
  fi

  echo "✅ Playwright installed"
  echo ""
fi
```

Now create and run validation script:

```typescript
// Create temporary validation script
const validationScript = `
const { chromium } = require('playwright');

(async () => {
  console.log('🚀 Launching browser...');

  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  // Track console errors
  const consoleErrors = [];
  page.on('console', msg => {
    if (msg.type() === 'error') {
      consoleErrors.push(msg.text());
    }
  });

  // Track network errors
  const networkErrors = [];
  page.on('response', response => {
    if (response.status() >= 400) {
      networkErrors.push({
        url: response.url(),
        status: response.status()
      });
    }
  });

  try {
    // Navigate to app
    console.log('🌐 Navigating to ${URL}...');
    await page.goto('${URL}', { waitUntil: 'networkidle', timeout: 30000 });

    // Wait for any dynamic content
    await page.waitForTimeout(2000);

    // Capture screenshot
    console.log('📸 Capturing screenshot...');
    await page.screenshot({
      path: '/tmp/orchestrator-validation-screenshot.png',
      fullPage: true
    });

    // Get page title
    const title = await page.title();

    console.log('');
    console.log('✅ Browser Validation Complete');
    console.log('');
    console.log('Page Title:', title);
    console.log('Console Errors:', consoleErrors.length);
    console.log('Network Errors:', networkErrors.length);
    console.log('');

    if (consoleErrors.length > 0) {
      console.log('🔴 Console Errors:');
      consoleErrors.forEach((err, i) => {
        console.log(\`  \${i + 1}. \${err}\`);
      });
      console.log('');
    }

    if (networkErrors.length > 0) {
      console.log('🔴 Network Errors:');
      networkErrors.forEach((err, i) => {
        console.log(\`  \${i + 1}. \${err.status} - \${err.url}\`);
      });
      console.log('');
    }

    if (consoleErrors.length === 0 && networkErrors.length === 0) {
      console.log('✅ No errors detected!');
      console.log('');
    }

    // Export results as JSON
    const results = {
      success: true,
      url: '${URL}',
      title: title,
      consoleErrors: consoleErrors,
      networkErrors: networkErrors,
      screenshotPath: '/tmp/orchestrator-validation-screenshot.png',
      timestamp: new Date().toISOString()
    };

    require('fs').writeFileSync(
      '/tmp/orchestrator-validation-results.json',
      JSON.stringify(results, null, 2)
    );

  } catch (error) {
    console.error('❌ Browser validation failed:', error.message);

    const results = {
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    };

    require('fs').writeFileSync(
      '/tmp/orchestrator-validation-results.json',
      JSON.stringify(results, null, 2)
    );

    process.exit(1);
  } finally {
    await browser.close();
  }
})();
`;
```

Write and execute the script:

```bash
# Write validation script
echo "$validationScript" > /tmp/orchestrator-validate.js

# Run validation
cd "$PROJECT_PATH"
node /tmp/orchestrator-validate.js

PLAYWRIGHT_EXIT_CODE=$?

# Check results
if [ $PLAYWRIGHT_EXIT_CODE -ne 0 ]; then
  echo "❌ Browser validation failed"
  exit 1
fi
```

---

### Step 4: Visual Analysis (Claude Vision API - Phase 0 Manual)

For Phase 0, we'll use the Read tool to view the screenshot, since we're already in Claude Code context:

```bash
echo "👁️  Visual Analysis..."
echo ""
echo "Screenshot saved to: /tmp/orchestrator-validation-screenshot.png"
echo ""
echo "To analyze the screenshot, use:"
echo "Read tool with: /tmp/orchestrator-validation-screenshot.png"
echo ""
```

**ACTION REQUIRED**: Use the Read tool to view `/tmp/orchestrator-validation-screenshot.png` and provide visual analysis:
- Is the layout correct?
- Are there any visual bugs (overlapping elements, missing content)?
- Is styling applied correctly?
- Any UX issues?

---

### Step 5: Generate Validation Report

```bash
echo "📊 Validation Report"
echo "===================="
echo ""
echo "Project: $PROJECT_PATH"
echo "URL: $URL"
echo ""

# Read results
if [ -f "/tmp/orchestrator-validation-results.json" ]; then
  # Parse JSON results (simplified for Phase 0)
  TITLE=$(cat /tmp/orchestrator-validation-results.json | grep '"title"' | sed 's/.*: "\(.*\)",/\1/')
  CONSOLE_ERRORS=$(cat /tmp/orchestrator-validation-results.json | grep -c '"consoleErrors"')
  NETWORK_ERRORS=$(cat /tmp/orchestrator-validation-results.json | grep -c '"networkErrors"')

  echo "✅ Browser Validation: PASSED"
  echo "   Page Title: $TITLE"
  echo "   Console Errors: (check results JSON)"
  echo "   Network Errors: (check results JSON)"
  echo ""
  echo "📄 Full results: /tmp/orchestrator-validation-results.json"
  echo "📸 Screenshot: /tmp/orchestrator-validation-screenshot.png"
  echo ""
fi
```

---

## Post-Validation Hook

```bash
echo ""
echo "🎣 Post-Validation Hook"
echo ""

# Calculate duration
VALIDATION_END_TIME=$(date +%s)
VALIDATION_DURATION=$((VALIDATION_END_TIME - VALIDATION_START_TIME))

echo "⏱️  Validation Duration: ${VALIDATION_DURATION}s"
echo ""

# Cleanup temporary files (optional)
# rm -f /tmp/orchestrator-validate.js

echo "✅ Validation Complete"
echo ""
echo "📈 Next Steps:"
echo "1. Review screenshot: /tmp/orchestrator-validation-screenshot.png"
echo "2. Review full results: /tmp/orchestrator-validation-results.json"
echo "3. If validation passed, ready for orchestrate"
echo ""
```

---

## Error Handling

**If project path is invalid**:
- Display usage example
- Exit with error

**If dev server not running**:
- Display instructions to start dev server
- Exit gracefully

**If Playwright installation fails**:
- Display error message
- Exit with error

**If browser navigation fails**:
- Capture error details in results JSON
- Display error message
- Exit with error code

---

## Success Criteria

✅ Playwright browser automation works
✅ Can navigate to target app
✅ Console errors captured
✅ Network errors captured
✅ Screenshot captured successfully
✅ Results exported as JSON
✅ Validation report generated

---

## Phase 0 Notes

**Current Limitations**:
- Manual visual analysis (using Read tool)
- Basic error detection
- Single URL validation
- No retry logic

**Phase 1 Enhancements**:
- Automated Claude Vision API integration
- User flow validation (multi-step)
- Retry logic with refinement
- Comparison with previous screenshots
- Integration with test workflow orchestration
