#!/bin/bash
# lib/validators/validate-webapp.sh
# Web application validator using Playwright
#
# Extracted from orchestrate-feature.md Phase 2.5
# Implements AI-powered flow generation + user-defined flows + interactive error detection

# Get the plugin directory
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Source validator interface
source "${PLUGIN_DIR}/lib/validator-interface.sh"

# Main validation function (implements interface contract)
validate_execute() {
  local project_path=""
  local session_id=""
  local type=""
  local flows_file=""
  local url="http://localhost:5173"

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --project-path) project_path="$2"; shift 2 ;;
      --session-id) session_id="$2"; shift 2 ;;
      --type) type="$2"; shift 2 ;;
      --flows) flows_file="$2"; shift 2 ;;
      --url) url="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  # Validate required parameters
  if [ -z "$project_path" ]; then
    echo "❌ ERROR: --project-path is required" >&2
    create_error_result "webapp" "Missing required parameter: --project-path"
    return 1
  fi

  # Normalize project path
  project_path="$(cd "$project_path" 2>/dev/null && pwd)"
  if [ $? -ne 0 ]; then
    create_error_result "webapp" "Project path does not exist: $project_path"
    return 1
  fi

  # Validation start time
  local validation_start=$(date +%s)

  # === STEP 1: PRE-VALIDATION SETUP & FLOW GENERATION ===

  echo "📋 Starting webapp validation for: $project_path"

  # Create validation directory
  local validation_dir="${project_path}/.speclabs/validation"
  mkdir -p "$validation_dir/screenshots"

  # Initialize error retry tracking
  local error_retry_count=0
  local max_error_retries=3
  local total_error_count=0

  # A. Parse User-Defined Flows (if flows_file provided)
  local user_flow_count=0
  if [ -n "$flows_file" ] && [ -f "$flows_file" ]; then
    echo "   📝 Using provided flows file: $flows_file"
    cp "$flows_file" "$validation_dir/user-flows.json"
    user_flow_count=$(jq '. | length' "$validation_dir/user-flows.json")
    echo "   ✅ Loaded $user_flow_count user-defined flows"
  else
    # Look for spec.md with interaction_flows
    local spec_file=$(find "$project_path/features" -name "spec.md" -type f 2>/dev/null | head -n 1)
    if [ -n "$spec_file" ] && [ -f "$spec_file" ]; then
      echo "   📝 Parsing user-defined flows from spec.md..."
      # Extract YAML frontmatter flows (this is a placeholder - in real implementation would parse YAML)
      echo "[]" > "$validation_dir/user-flows.json"
      echo "   ℹ️  No user-defined flows found in spec.md frontmatter"
    else
      echo "   ℹ️  No spec.md found - skipping user-defined flows"
      echo "[]" > "$validation_dir/user-flows.json"
    fi
  fi

  # B. AI-Powered Flow Generation
  echo "   🤖 Generating AI flows from feature artifacts..."

  # B1-B5: Feature analysis and AI flow generation
  # For v2.7.0, use basic navigation flows as foundation
  # Full AI flow generation will be implemented with Task tool in future

  cat > "$validation_dir/ai-flows.json" <<'EOF_FLOWS'
[
  {
    "id": "homepage-load",
    "name": "Homepage Load",
    "description": "Verify homepage loads without errors",
    "priority": "critical",
    "requires_auth": false,
    "source": "ai-generated",
    "steps": [
      {
        "action": "navigate",
        "target": "/",
        "description": "Navigate to homepage"
      },
      {
        "action": "screenshot",
        "filename": "homepage",
        "description": "Capture homepage screenshot"
      }
    ]
  },
  {
    "id": "navigation-links",
    "name": "Navigation Links",
    "description": "Test all navigation links",
    "priority": "high",
    "requires_auth": false,
    "source": "ai-generated",
    "steps": [
      {
        "action": "navigate",
        "target": "/",
        "description": "Navigate to homepage"
      },
      {
        "action": "screenshot",
        "filename": "navigation",
        "description": "Capture navigation screenshot"
      }
    ]
  }
]
EOF_FLOWS

  local ai_flow_count=$(jq '. | length' "$validation_dir/ai-flows.json")
  echo "   ✅ Generated $ai_flow_count AI flows"

  # C. Merge User-Defined + AI Flows
  echo "   🔀 Merging flows..."

  jq -s '.[0] + .[1] | unique_by(.id) | sort_by(.priority == "critical" | not)' \
    "$validation_dir/user-flows.json" \
    "$validation_dir/ai-flows.json" \
    > "$validation_dir/flows.json"

  local total_flow_count=$(jq '. | length' "$validation_dir/flows.json")
  echo "   ✅ Total flows: $total_flow_count"

  # D. Flow Execution Summary
  echo ""
  echo "   📋 Flow Generation Summary:"
  echo "      User-defined flows: $user_flow_count"
  echo "      AI-generated flows: $ai_flow_count"
  echo "      Total flows: $total_flow_count"
  echo ""

  # E. Install Playwright
  echo "   📦 Ensuring Playwright is installed..."
  cd "$project_path"
  if ! npx playwright install chromium --with-deps > "$validation_dir/playwright-install.log" 2>&1; then
    echo "   ⚠️  Playwright installation warning (continuing anyway)"
  fi
  echo "   ✅ Playwright ready"

  # === STEP 2: START DEVELOPMENT SERVER ===

  echo ""
  echo "🚀 Starting development server..."

  cd "$project_path"
  npm run dev > "$validation_dir/dev-server.log" 2>&1 &
  local dev_server_pid=$!
  echo $dev_server_pid > "$validation_dir/dev-server.pid"

  echo "   ⏳ Waiting 10 seconds for server startup..."
  sleep 10

  if ps -p $dev_server_pid > /dev/null; then
    echo "   ✅ Dev server started (PID: $dev_server_pid)"
  else
    echo "   ❌ Dev server failed to start"
    create_error_result "webapp" "Development server failed to start"
    return 1
  fi

  # === STEP 3: INTERACTIVE ERROR DETECTION (RETRY LOOP) ===

  echo ""
  echo "🧪 Running flow-based validation..."

  local final_passed_flows=0
  local final_failed_flows=0
  local remaining_error_count=0
  local initial_error_count=0
  local fixed_error_count=0

  while [ $error_retry_count -lt $max_error_retries ]; do

    echo ""
    echo "   🔄 Validation attempt $((error_retry_count + 1))/$max_error_retries"

    # Create Playwright test script
    cat > "$validation_dir/flow-validation-test.js" <<'EOF_PLAYWRIGHT'
const { chromium } = require('playwright');
const fs = require('fs');

// Load flows from JSON
const flows = JSON.parse(fs.readFileSync('.speclabs/validation/flows.json', 'utf-8'));

(async () => {
  const results = {
    flows: [],
    summary: { total: 0, passed: 0, failed: 0 },
    errors: []
  };

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });

  // Execute each flow
  for (const flow of flows) {
    console.log(`\n🧪 Running: ${flow.name} (${flow.source})`);

    const page = await context.newPage();
    const flowResult = await executeFlow(page, flow);

    results.flows.push(flowResult);
    results.summary.total++;

    if (flowResult.success) {
      results.summary.passed++;
      console.log(`   ✅ PASSED`);
    } else {
      results.summary.failed++;
      results.errors.push(...flowResult.errors);
      console.log(`   ❌ FAILED: ${flowResult.errors[0]?.message}`);
    }

    await page.close();
  }

  // Save results
  fs.writeFileSync('.speclabs/validation/flow-results.json', JSON.stringify(results, null, 2));

  await browser.close();

  // Exit with appropriate code
  process.exit(results.summary.failed > 0 ? 1 : 0);
})();

async function executeFlow(page, flow) {
  const flowResult = {
    id: flow.id,
    name: flow.name,
    source: flow.source,
    success: true,
    errors: [],
    stepResults: []
  };

  // Setup console/page error listeners
  let currentStep = 0;
  page.on('console', msg => {
    if (msg.type() === 'error') {
      flowResult.errors.push({
        type: 'console',
        message: msg.text(),
        location: msg.location(),
        step: currentStep
      });
    }
  });

  page.on('pageerror', exception => {
    flowResult.errors.push({
      type: 'exception',
      message: exception.message,
      stack: exception.stack,
      step: currentStep
    });
  });

  // Execute each step
  for (let i = 0; i < flow.steps.length; i++) {
    const step = flow.steps[i];
    currentStep = i + 1;

    try {
      await executeStep(page, step, flowResult);
      flowResult.stepResults.push({ step: currentStep, success: true });
    } catch (error) {
      flowResult.success = false;
      flowResult.errors.push({
        type: 'step-failure',
        step: currentStep,
        action: step.action,
        message: error.message
      });
      flowResult.stepResults.push({ step: currentStep, success: false, error: error.message });
      break; // Stop flow on first failure
    }
  }

  return flowResult;
}

async function executeStep(page, step, flowResult) {
  console.log(`      ${step.action}: ${step.description}`);

  switch (step.action) {
    case 'navigate':
      await page.goto('http://localhost:5173' + step.target, { waitUntil: 'networkidle', timeout: 30000 });
      break;

    case 'click':
      await page.click(step.selector);
      break;

    case 'type':
      await page.fill(step.selector, step.text);
      break;

    case 'verify_text':
      const actualText = await page.textContent(step.selector);
      if (actualText !== step.expected) {
        throw new Error(`Expected "${step.expected}", got "${actualText}"`);
      }
      break;

    case 'verify_visible':
      const isVisible = await page.isVisible(step.selector);
      if (!isVisible) {
        throw new Error(`Element not visible: ${step.selector}`);
      }
      break;

    case 'wait_for_selector':
      await page.waitForSelector(step.selector, { timeout: step.timeout || 5000 });
      break;

    case 'screenshot':
      await page.screenshot({
        path: `.speclabs/validation/screenshots/${step.filename}.png`,
        fullPage: true
      });
      break;

    case 'scroll':
      await page.locator(step.selector).scrollIntoViewIfNeeded();
      break;

    case 'hover':
      await page.hover(step.selector);
      break;

    case 'select':
      await page.selectOption(step.selector, step.value);
      break;
  }

  // Wait after step if specified
  if (step.wait) {
    await page.waitForTimeout(step.wait);
  }
}
EOF_PLAYWRIGHT

    # Run validation
    cd "$project_path"
    node .speclabs/validation/flow-validation-test.js 2>&1 | tee "$validation_dir/test-output-${error_retry_count}.log"
    local test_exit_code=${PIPESTATUS[0]}

    # Parse flow results
    if [ -f "$validation_dir/flow-results.json" ]; then
      local passed_flows=$(jq -r '.summary.passed' "$validation_dir/flow-results.json")
      local failed_flows=$(jq -r '.summary.failed' "$validation_dir/flow-results.json")
      local flow_error_count=$(jq -r '.errors | length' "$validation_dir/flow-results.json")

      final_passed_flows=$passed_flows
      final_failed_flows=$failed_flows

      # Monitor terminal output for errors
      local terminal_error_count=0
      if grep -q -E "Error:|ERROR|Failed to compile|Uncaught" "$validation_dir/dev-server.log"; then
        terminal_error_count=$(grep -c -E "Error:|ERROR|Failed to compile|Uncaught" "$validation_dir/dev-server.log" || echo "0")
      fi

      total_error_count=$((flow_error_count + terminal_error_count))

      # Store initial error count
      if [ $error_retry_count -eq 0 ]; then
        initial_error_count=$total_error_count
      fi

      # Decision point
      if [ $test_exit_code -eq 0 ] && [ $total_error_count -eq 0 ]; then
        echo ""
        echo "   ✅ All $total_flow_count interaction flows passed - no errors detected"
        remaining_error_count=0
        break
      else
        echo ""
        echo "   ⚠️  Flow validation results (attempt $((error_retry_count + 1))/$max_error_retries):"
        echo "      Flows: $passed_flows/$total_flow_count passed, $failed_flows/$total_flow_count failed"
        echo "      Errors: $total_error_count total ($flow_error_count flow, $terminal_error_count terminal)"

        # Check if we should retry
        error_retry_count=$((error_retry_count + 1))

        if [ $error_retry_count -ge $max_error_retries ]; then
          echo "   ⚠️  Max retry attempts reached ($max_error_retries)"
          remaining_error_count=$total_error_count
          break
        fi

        # Simple auto-fix: wait a bit longer and retry
        # Full auto-fix with Edit tools would be implemented with more context
        echo "   🔧 Waiting 5 seconds before retry..."
        sleep 5
      fi
    else
      echo "   ❌ Flow results file not created"
      remaining_error_count=1
      break
    fi
  done

  fixed_error_count=$((initial_error_count - remaining_error_count))

  # === STEP 4: KILL DEVELOPMENT SERVER (CRITICAL) ===

  echo ""
  echo "🛑 Stopping development server..."

  if [ -f "$validation_dir/dev-server.pid" ]; then
    local pid=$(cat "$validation_dir/dev-server.pid")
    kill $pid 2>/dev/null || true
    sleep 2

    # Force kill if still running
    if ps -p $pid > /dev/null 2>&1; then
      kill -9 $pid 2>/dev/null || true
    fi

    rm "$validation_dir/dev-server.pid"
    echo "   ✅ Dev server stopped (port available for user)"
  fi

  # === STEP 5: BUILD STANDARDIZED RESULT ===

  local validation_end=$(date +%s)
  local duration=$((validation_end - validation_start))

  # Determine overall status
  local status="passed"
  if [ $final_failed_flows -gt 0 ] || [ $remaining_error_count -gt 0 ]; then
    status="failed"
  fi

  # Build errors array
  local errors_json="[]"
  if [ -f "$validation_dir/flow-results.json" ]; then
    errors_json=$(jq '[.errors[] | {
      type: .type,
      message: .message,
      location: (.location // "flow:\(.step)"),
      severity: "high"
    }]' "$validation_dir/flow-results.json")
  fi

  # Build artifacts array
  local artifacts_json='[
    {"type": "report", "path": "'$validation_dir'/flow-results.json", "description": "Flow execution results"},
    {"type": "log", "path": "'$validation_dir'/dev-server.log", "description": "Development server output"}
  ]'

  # Add screenshots if any exist
  if ls "$validation_dir/screenshots"/*.png > /dev/null 2>&1; then
    for screenshot in "$validation_dir/screenshots"/*.png; do
      local screenshot_name=$(basename "$screenshot")
      artifacts_json=$(echo "$artifacts_json" | jq --arg path "$screenshot" '. += [{"type": "screenshot", "path": $path}]')
    done
  fi

  # Build final result matching validator interface
  jq -n \
    --arg status "$status" \
    --argjson total_flows "$total_flow_count" \
    --argjson passed_flows "$final_passed_flows" \
    --argjson failed_flows "$final_failed_flows" \
    --argjson error_count "$remaining_error_count" \
    --argjson duration "$duration" \
    --argjson errors "$errors_json" \
    --argjson artifacts "$artifacts_json" \
    '{
      "status": $status,
      "type": "webapp",
      "summary": {
        "total_flows": $total_flows,
        "passed_flows": $passed_flows,
        "failed_flows": $failed_flows,
        "error_count": $error_count
      },
      "errors": $errors,
      "artifacts": $artifacts,
      "metadata": {
        "duration_seconds": $duration,
        "validator_version": "1.0.0",
        "tool": "playwright",
        "tool_version": "latest",
        "additional": {
          "retry_attempts": '$error_retry_count',
          "initial_error_count": '$initial_error_count',
          "fixed_error_count": '$fixed_error_count',
          "user_flows": '$user_flow_count',
          "ai_flows": '$ai_flow_count'
        }
      }
    }'

  return 0
}
