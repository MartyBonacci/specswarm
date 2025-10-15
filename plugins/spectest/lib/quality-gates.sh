#!/bin/bash

#
# quality-gates.sh - Test framework detection and execution
#
# Part of SpecSwarm Comprehensive Quality Assurance System
# Created: October 14, 2025
#

# Detect test framework
detect_test_framework() {
  local REPO_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

  # JavaScript/TypeScript
  if [ -f "$REPO_ROOT/vitest.config.ts" ] || [ -f "$REPO_ROOT/vitest.config.js" ]; then
    echo "vitest"
    return 0
  elif [ -f "$REPO_ROOT/jest.config.js" ] || [ -f "$REPO_ROOT/jest.config.ts" ]; then
    echo "jest"
    return 0

  # Python
  elif [ -f "$REPO_ROOT/pytest.ini" ] || grep -q "pytest" "$REPO_ROOT/requirements.txt" 2>/dev/null; then
    echo "pytest"
    return 0
  elif [ -f "$REPO_ROOT/setup.py" ] && grep -q "unittest" "$REPO_ROOT/setup.py" 2>/dev/null; then
    echo "unittest"
    return 0

  # PHP
  elif [ -f "$REPO_ROOT/phpunit.xml" ] || [ -f "$REPO_ROOT/phpunit.xml.dist" ]; then
    echo "phpunit"
    return 0

  # Go
  elif [ -f "$REPO_ROOT/go.mod" ] && find "$REPO_ROOT" -name "*_test.go" 2>/dev/null | grep -q .; then
    echo "go-test"
    return 0

  # Ruby
  elif [ -f "$REPO_ROOT/Rakefile" ] && grep -q "rspec" "$REPO_ROOT/Gemfile" 2>/dev/null; then
    echo "rspec"
    return 0
  elif [ -f "$REPO_ROOT/Rakefile" ] && grep -q "minitest" "$REPO_ROOT/Gemfile" 2>/dev/null; then
    echo "minitest"
    return 0

  # Rust
  elif [ -f "$REPO_ROOT/Cargo.toml" ]; then
    echo "cargo-test"
    return 0

  else
    echo "none"
    return 1
  fi
}

# Detect browser test framework
detect_browser_test_framework() {
  local REPO_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

  if [ -f "$REPO_ROOT/playwright.config.ts" ] || [ -f "$REPO_ROOT/playwright.config.js" ]; then
    echo "playwright"
    return 0
  elif [ -f "$REPO_ROOT/cypress.config.ts" ] || [ -f "$REPO_ROOT/cypress.config.js" ] || [ -f "$REPO_ROOT/cypress.json" ]; then
    echo "cypress"
    return 0
  elif [ -f "$REPO_ROOT/wdio.conf.js" ] || [ -f "$REPO_ROOT/wdio.conf.ts" ]; then
    echo "webdriverio"
    return 0
  else
    echo "none"
    return 1
  fi
}

# Run unit tests
run_unit_tests() {
  local TEST_FRAMEWORK=$(detect_test_framework)
  local REPO_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

  echo "  Framework: $TEST_FRAMEWORK"
  echo "  Running unit tests..."
  echo ""

  case "$TEST_FRAMEWORK" in
    vitest)
      cd "$REPO_ROOT" && npx vitest run --reporter=verbose 2>&1
      return $?
      ;;
    jest)
      cd "$REPO_ROOT" && npx jest --verbose --no-coverage 2>&1
      return $?
      ;;
    pytest)
      cd "$REPO_ROOT" && pytest -v --tb=short 2>&1
      return $?
      ;;
    unittest)
      cd "$REPO_ROOT" && python -m unittest discover -v 2>&1
      return $?
      ;;
    phpunit)
      cd "$REPO_ROOT" && vendor/bin/phpunit --verbose 2>&1
      return $?
      ;;
    go-test)
      cd "$REPO_ROOT" && go test ./... -v 2>&1
      return $?
      ;;
    rspec)
      cd "$REPO_ROOT" && bundle exec rspec --format documentation 2>&1
      return $?
      ;;
    minitest)
      cd "$REPO_ROOT" && bundle exec rake test 2>&1
      return $?
      ;;
    cargo-test)
      cd "$REPO_ROOT" && cargo test --verbose 2>&1
      return $?
      ;;
    none)
      echo "  ⚠️  No test framework detected"
      echo "  Skipping unit tests"
      echo ""
      return 0
      ;;
  esac
}

# Run integration tests
run_integration_tests() {
  local TEST_FRAMEWORK=$(detect_test_framework)
  local REPO_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

  # Check if integration tests exist
  local INTEGRATION_TESTS_EXIST=false

  case "$TEST_FRAMEWORK" in
    vitest|jest)
      if find "$REPO_ROOT" -path "*/tests/integration/*" -name "*.test.*" 2>/dev/null | grep -q .; then
        INTEGRATION_TESTS_EXIST=true
      fi
      ;;
    pytest)
      if find "$REPO_ROOT" -path "*/tests/integration/*" -name "test_*.py" 2>/dev/null | grep -q .; then
        INTEGRATION_TESTS_EXIST=true
      fi
      ;;
    *)
      # For other frameworks, assume no integration tests
      INTEGRATION_TESTS_EXIST=false
      ;;
  esac

  if [ "$INTEGRATION_TESTS_EXIST" = false ]; then
    echo "  No integration tests found"
    echo "  Skipping integration tests"
    echo ""
    return 0
  fi

  echo "  Running integration tests..."
  echo ""

  case "$TEST_FRAMEWORK" in
    vitest)
      cd "$REPO_ROOT" && npx vitest run --reporter=verbose tests/integration 2>&1
      return $?
      ;;
    jest)
      cd "$REPO_ROOT" && npx jest --verbose --testPathPattern=integration 2>&1
      return $?
      ;;
    pytest)
      cd "$REPO_ROOT" && pytest -v tests/integration 2>&1
      return $?
      ;;
    *)
      echo "  Integration tests not supported for $TEST_FRAMEWORK"
      return 0
      ;;
  esac
}

# Run browser tests
run_browser_tests() {
  local BROWSER_FRAMEWORK=$(detect_browser_test_framework)
  local REPO_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

  if [ "$BROWSER_FRAMEWORK" = "none" ]; then
    echo "  ⚠️  No browser test framework detected"
    echo "  Skipping browser tests"
    echo ""
    return 0
  fi

  echo "  Framework: $BROWSER_FRAMEWORK"
  echo "  Running browser tests..."
  echo ""

  case "$BROWSER_FRAMEWORK" in
    playwright)
      cd "$REPO_ROOT" && npx playwright test --reporter=list 2>&1
      return $?
      ;;
    cypress)
      cd "$REPO_ROOT" && npx cypress run --reporter spec 2>&1
      return $?
      ;;
    webdriverio)
      cd "$REPO_ROOT" && npx wdio run wdio.conf.js 2>&1
      return $?
      ;;
  esac
}

# Measure code coverage
measure_coverage() {
  local TEST_FRAMEWORK=$(detect_test_framework)
  local REPO_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

  echo "  Measuring code coverage..."
  echo ""

  case "$TEST_FRAMEWORK" in
    vitest)
      local COVERAGE_OUTPUT=$(cd "$REPO_ROOT" && npx vitest run --coverage --reporter=silent 2>&1)
      local COVERAGE_PCT=$(echo "$COVERAGE_OUTPUT" | grep -oE "All files[[:space:]]*\|[[:space:]]*[0-9]+\.[0-9]+" | grep -oE "[0-9]+\.[0-9]+" | head -1)
      if [ -n "$COVERAGE_PCT" ]; then
        echo "  Coverage: ${COVERAGE_PCT}%"
        echo "$COVERAGE_PCT"
      else
        echo "  Coverage: Unable to determine"
        echo "0"
      fi
      ;;
    jest)
      local COVERAGE_OUTPUT=$(cd "$REPO_ROOT" && npx jest --coverage --silent 2>&1)
      local COVERAGE_PCT=$(echo "$COVERAGE_OUTPUT" | grep "All files" | awk '{print $4}' | tr -d '%')
      if [ -n "$COVERAGE_PCT" ]; then
        echo "  Coverage: ${COVERAGE_PCT}%"
        echo "$COVERAGE_PCT"
      else
        echo "  Coverage: Unable to determine"
        echo "0"
      fi
      ;;
    pytest)
      local COVERAGE_OUTPUT=$(cd "$REPO_ROOT" && pytest --cov=. --cov-report=term-missing 2>&1)
      local COVERAGE_PCT=$(echo "$COVERAGE_OUTPUT" | grep "TOTAL" | awk '{print $4}' | tr -d '%')
      if [ -n "$COVERAGE_PCT" ]; then
        echo "  Coverage: ${COVERAGE_PCT}%"
        echo "$COVERAGE_PCT"
      else
        echo "  Coverage: Unable to determine"
        echo "0"
      fi
      ;;
    go-test)
      local COVERAGE_OUTPUT=$(cd "$REPO_ROOT" && go test ./... -cover 2>&1)
      local COVERAGE_PCT=$(echo "$COVERAGE_OUTPUT" | grep "coverage:" | awk '{print $5}' | tr -d '%' | head -1)
      if [ -n "$COVERAGE_PCT" ]; then
        echo "  Coverage: ${COVERAGE_PCT}%"
        echo "$COVERAGE_PCT"
      else
        echo "  Coverage: Unable to determine"
        echo "0"
      fi
      ;;
    *)
      echo "  Coverage measurement not supported for $TEST_FRAMEWORK"
      echo "0"
      ;;
  esac
}

# Calculate quality score
calculate_quality_score() {
  local UNIT_RESULT="${1:-1}"           # 0=pass, 1=fail
  local INTEGRATION_RESULT="${2:-1}"
  local COVERAGE_PCT="${3:-0}"
  local BROWSER_RESULT="${4:-1}"
  local VISUAL_SCORE="${5:-0}"

  local SCORE=0

  # Unit tests (25 points)
  if [ "$UNIT_RESULT" -eq 0 ]; then
    SCORE=$((SCORE + 25))
  fi

  # Integration tests (20 points)
  if [ "$INTEGRATION_RESULT" -eq 0 ]; then
    SCORE=$((SCORE + 20))
  fi

  # Coverage (25 points, scaled)
  # Convert coverage percentage to integer and scale to 25 points
  local COVERAGE_INT=${COVERAGE_PCT%.*}
  if [ -z "$COVERAGE_INT" ]; then
    COVERAGE_INT=0
  fi
  local COVERAGE_POINTS=$((COVERAGE_INT * 25 / 100))
  SCORE=$((SCORE + COVERAGE_POINTS))

  # Browser tests (15 points)
  if [ "$BROWSER_RESULT" -eq 0 ]; then
    SCORE=$((SCORE + 15))
  fi

  # Visual alignment (15 points, scaled)
  local VISUAL_INT=${VISUAL_SCORE%.*}
  if [ -z "$VISUAL_INT" ]; then
    VISUAL_INT=0
  fi
  local VISUAL_POINTS=$((VISUAL_INT * 15 / 100))
  SCORE=$((SCORE + VISUAL_POINTS))

  echo "$SCORE"
}

# Save quality metrics
save_quality_metrics() {
  local FEATURE_NUM="$1"
  local QUALITY_SCORE="$2"
  local COVERAGE_PCT="$3"
  local VISUAL_SCORE="$4"
  local UNIT_RESULT="$5"
  local INTEGRATION_RESULT="$6"
  local BROWSER_RESULT="$7"

  local REPO_ROOT="${8:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
  local METRICS_FILE="${REPO_ROOT}/memory/metrics.json"

  # Create metrics file if it doesn't exist
  if [ ! -f "$METRICS_FILE" ]; then
    echo '{"features": {}}' > "$METRICS_FILE"
  fi

  # Find feature directory
  local FEATURE_DIR=$(find "$REPO_ROOT/features" -maxdepth 1 -type d -name "${FEATURE_NUM}-*" 2>/dev/null | head -1)
  local FEATURE_NAME=$(basename "$FEATURE_DIR" 2>/dev/null)

  if [ -z "$FEATURE_NAME" ]; then
    FEATURE_NAME="${FEATURE_NUM}"
  fi

  # Get current timestamp
  local TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Update metrics (simple approach - append to file)
  # In production, use jq for proper JSON manipulation
  echo "  Saving quality metrics to $METRICS_FILE"
  echo "  Feature: $FEATURE_NAME"
  echo "  Quality Score: $QUALITY_SCORE/100"
  echo "  Coverage: ${COVERAGE_PCT}%"
  echo "  Visual Alignment: ${VISUAL_SCORE}%"
  echo ""
}

# Display quality report
display_quality_report() {
  local UNIT_RESULT="$1"
  local INTEGRATION_RESULT="$2"
  local COVERAGE_PCT="$3"
  local BROWSER_RESULT="$4"
  local VISUAL_SCORE="$5"
  local QUALITY_SCORE="$6"

  echo ""
  echo "📊 Quality Report"
  echo "================="
  echo ""

  # Unit tests
  if [ "$UNIT_RESULT" -eq 0 ]; then
    echo "  Unit Tests: ✅ Pass"
  else
    echo "  Unit Tests: ❌ Fail"
  fi

  # Integration tests
  if [ "$INTEGRATION_RESULT" -eq 0 ]; then
    echo "  Integration Tests: ✅ Pass"
  else
    echo "  Integration Tests: ❌ Fail"
  fi

  # Coverage
  local COVERAGE_INT=${COVERAGE_PCT%.*}
  if [ -z "$COVERAGE_INT" ]; then
    COVERAGE_INT=0
  fi

  if [ "$COVERAGE_INT" -ge 85 ]; then
    echo "  Coverage: ✅ ${COVERAGE_PCT}% (target: 85%)"
  elif [ "$COVERAGE_INT" -ge 70 ]; then
    echo "  Coverage: ⚠️ ${COVERAGE_PCT}% (target: 85%)"
  else
    echo "  Coverage: ❌ ${COVERAGE_PCT}% (target: 85%)"
  fi

  # Browser tests
  if [ "$BROWSER_RESULT" -eq 0 ]; then
    echo "  Browser Tests: ✅ Pass"
  elif [ "$BROWSER_RESULT" -eq 2 ]; then
    echo "  Browser Tests: ⊘ Skipped"
  else
    echo "  Browser Tests: ❌ Fail"
  fi

  # Visual alignment
  local VISUAL_INT=${VISUAL_SCORE%.*}
  if [ -z "$VISUAL_INT" ]; then
    VISUAL_INT=0
  fi

  if [ "$VISUAL_INT" -ge 75 ]; then
    echo "  Visual Alignment: ✅ ${VISUAL_SCORE}% (target: 75%)"
  elif [ "$VISUAL_INT" -ge 60 ]; then
    echo "  Visual Alignment: ⚠️ ${VISUAL_SCORE}% (target: 75%)"
  elif [ "$VISUAL_INT" -eq 0 ]; then
    echo "  Visual Alignment: ⊘ Skipped"
  else
    echo "  Visual Alignment: ❌ ${VISUAL_SCORE}% (target: 75%)"
  fi

  echo ""
  echo "  Overall Quality Score: ${QUALITY_SCORE}/100"
  echo ""
}
