#!/bin/bash
#
# Multi-Framework Test Detector
# Detects and runs tests across multiple testing frameworks
#
# Created: 2025-10-15
# Phase 2 Enhancement
#

set -euo pipefail

# Detect which test framework(s) are installed
detect_test_frameworks() {
    local repo_root="${1:-$(pwd)}"
    local frameworks=()

    # JavaScript/TypeScript Frameworks
    if [ -f "$repo_root/package.json" ]; then
        # Vitest
        if grep -q '"vitest"' "$repo_root/package.json" 2>/dev/null; then
            frameworks+=("vitest")
        fi

        # Jest
        if grep -q '"jest"' "$repo_root/package.json" 2>/dev/null || \
           grep -q '"@jest"' "$repo_root/package.json" 2>/dev/null; then
            frameworks+=("jest")
        fi

        # Mocha
        if grep -q '"mocha"' "$repo_root/package.json" 2>/dev/null; then
            frameworks+=("mocha")
        fi

        # AVA
        if grep -q '"ava"' "$repo_root/package.json" 2>/dev/null; then
            frameworks+=("ava")
        fi

        # Jasmine
        if grep -q '"jasmine"' "$repo_root/package.json" 2>/dev/null; then
            frameworks+=("jasmine")
        fi
    fi

    # Python Frameworks
    if [ -f "$repo_root/requirements.txt" ] || [ -f "$repo_root/pyproject.toml" ] || [ -f "$repo_root/setup.py" ]; then
        # Pytest
        if grep -qE "pytest|pytest-cov" "$repo_root/requirements.txt" 2>/dev/null || \
           grep -q "pytest" "$repo_root/pyproject.toml" 2>/dev/null; then
            frameworks+=("pytest")
        fi

        # Unittest (built-in, check for test files)
        if find "$repo_root" -name "test_*.py" -o -name "*_test.py" 2>/dev/null | grep -q .; then
            if ! echo "${frameworks[@]}" | grep -q "pytest"; then
                frameworks+=("unittest")
            fi
        fi
    fi

    # Go Testing
    if [ -f "$repo_root/go.mod" ]; then
        frameworks+=("gotest")
    fi

    # Ruby Testing
    if [ -f "$repo_root/Gemfile" ]; then
        if grep -q "rspec" "$repo_root/Gemfile" 2>/dev/null; then
            frameworks+=("rspec")
        fi
        if grep -q "minitest" "$repo_root/Gemfile" 2>/dev/null; then
            frameworks+=("minitest")
        fi
    fi

    # Java Testing
    if [ -f "$repo_root/pom.xml" ] || [ -f "$repo_root/build.gradle" ]; then
        if grep -q "junit" "$repo_root/pom.xml" 2>/dev/null || \
           grep -q "junit" "$repo_root/build.gradle" 2>/dev/null; then
            frameworks+=("junit")
        fi
    fi

    # Return comma-separated list
    IFS=','
    echo "${frameworks[*]}"
}

# Run tests for a specific framework
run_tests() {
    local framework="$1"
    local repo_root="${2:-$(pwd)}"
    local output=""
    local exit_code=0

    cd "$repo_root" || return 1

    case "$framework" in
        "vitest")
            output=$(npx vitest run --reporter=verbose 2>&1 || true)
            exit_code=$?
            ;;
        "jest")
            output=$(npx jest --verbose --no-coverage 2>&1 || true)
            exit_code=$?
            ;;
        "mocha")
            output=$(npx mocha "test/**/*.js" 2>&1 || true)
            exit_code=$?
            ;;
        "ava")
            output=$(npx ava --verbose 2>&1 || true)
            exit_code=$?
            ;;
        "jasmine")
            output=$(npx jasmine 2>&1 || true)
            exit_code=$?
            ;;
        "pytest")
            output=$(python -m pytest -v 2>&1 || true)
            exit_code=$?
            ;;
        "unittest")
            output=$(python -m unittest discover -v 2>&1 || true)
            exit_code=$?
            ;;
        "gotest")
            output=$(go test ./... -v 2>&1 || true)
            exit_code=$?
            ;;
        "rspec")
            output=$(bundle exec rspec --format documentation 2>&1 || true)
            exit_code=$?
            ;;
        "minitest")
            output=$(ruby -Itest test/**/*_test.rb 2>&1 || true)
            exit_code=$?
            ;;
        "junit")
            if [ -f "pom.xml" ]; then
                output=$(mvn test 2>&1 || true)
            elif [ -f "build.gradle" ]; then
                output=$(./gradlew test 2>&1 || true)
            fi
            exit_code=$?
            ;;
        *)
            echo "Unknown framework: $framework" >&2
            return 1
            ;;
    esac

    echo "$output"
    return $exit_code
}

# Parse test results from output
parse_test_results() {
    local framework="$1"
    local output="$2"
    local total=0
    local passed=0
    local failed=0
    local skipped=0

    case "$framework" in
        "vitest")
            # Vitest format: "Test Files  1 passed (1)"
            # "Tests  10 passed | 2 failed (12)"
            if echo "$output" | grep -q "Tests.*passed.*failed"; then
                passed=$(echo "$output" | grep -oE "Tests.*" | grep -oE "[0-9]+ passed" | grep -oE "[0-9]+" | head -1 || echo "0")
                failed=$(echo "$output" | grep -oE "Tests.*" | grep -oE "[0-9]+ failed" | grep -oE "[0-9]+" | head -1 || echo "0")
                skipped=$(echo "$output" | grep -oE "Tests.*" | grep -oE "[0-9]+ skipped" | grep -oE "[0-9]+" | head -1 || echo "0")
            elif echo "$output" | grep -q "Test Files.*passed"; then
                passed=$(echo "$output" | grep -oE "[0-9]+ passed" | grep -oE "[0-9]+" | head -1 || echo "0")
                failed=0
                skipped=0
            fi
            total=$((passed + failed + skipped))
            ;;
        "jest")
            # Jest format: "Tests:       3 failed, 17 passed, 20 total"
            passed=$(echo "$output" | grep -oE "[0-9]+ passed" | grep -oE "[0-9]+" | tail -1 || echo "0")
            failed=$(echo "$output" | grep -oE "[0-9]+ failed" | grep -oE "[0-9]+" | tail -1 || echo "0")
            skipped=$(echo "$output" | grep -oE "[0-9]+ skipped" | grep -oE "[0-9]+" | tail -1 || echo "0")
            total=$(echo "$output" | grep -oE "[0-9]+ total" | grep -oE "[0-9]+" | tail -1 || echo "$((passed + failed + skipped))")
            ;;
        "mocha")
            # Mocha format: "15 passing (123ms)"
            # "3 failing"
            passed=$(echo "$output" | grep -oE "[0-9]+ passing" | grep -oE "[0-9]+" || echo "0")
            failed=$(echo "$output" | grep -oE "[0-9]+ failing" | grep -oE "[0-9]+" || echo "0")
            skipped=$(echo "$output" | grep -oE "[0-9]+ pending" | grep -oE "[0-9]+" || echo "0")
            total=$((passed + failed + skipped))
            ;;
        "pytest")
            # Pytest format: "5 passed, 2 failed, 1 skipped in 0.42s"
            passed=$(echo "$output" | grep -oE "[0-9]+ passed" | grep -oE "[0-9]+" || echo "0")
            failed=$(echo "$output" | grep -oE "[0-9]+ failed" | grep -oE "[0-9]+" || echo "0")
            skipped=$(echo "$output" | grep -oE "[0-9]+ skipped" | grep -oE "[0-9]+" || echo "0")
            total=$((passed + failed + skipped))
            ;;
        "gotest")
            # Go test format: "PASS" or "FAIL"
            # Count ok/FAIL lines
            passed=$(echo "$output" | grep -c "^ok" || echo "0")
            failed=$(echo "$output" | grep -c "^FAIL" || echo "0")
            skipped=$(echo "$output" | grep -c "^skip" || echo "0")
            total=$((passed + failed + skipped))
            ;;
        *)
            # Generic: try to find common patterns
            passed=$(echo "$output" | grep -oiE "[0-9]+ pass(ed|ing)?" | grep -oE "[0-9]+" | head -1 || echo "0")
            failed=$(echo "$output" | grep -oiE "[0-9]+ fail(ed|ing)?" | grep -oE "[0-9]+" | head -1 || echo "0")
            total=$((passed + failed))
            ;;
    esac

    echo "total=$total passed=$passed failed=$failed skipped=$skipped"
}

# Check for coverage tool availability
detect_coverage_tool() {
    local framework="$1"
    local repo_root="${2:-$(pwd)}"
    local tool=""

    case "$framework" in
        "vitest")
            if grep -q '"@vitest/coverage-v8"' "$repo_root/package.json" 2>/dev/null || \
               grep -q '"@vitest/coverage-c8"' "$repo_root/package.json" 2>/dev/null; then
                tool="@vitest/coverage-v8"
            fi
            ;;
        "jest")
            # Jest has built-in coverage
            tool="jest-builtin"
            ;;
        "pytest")
            if grep -q "pytest-cov" "$repo_root/requirements.txt" 2>/dev/null || \
               grep -q "pytest-cov" "$repo_root/pyproject.toml" 2>/dev/null; then
                tool="pytest-cov"
            fi
            ;;
        "gotest")
            # Go has built-in coverage
            tool="go-builtin"
            ;;
    esac

    echo "$tool"
}

# Run coverage measurement
run_coverage() {
    local framework="$1"
    local repo_root="${2:-$(pwd)}"
    local output=""
    local coverage_pct=0

    cd "$repo_root" || return 1

    case "$framework" in
        "vitest")
            output=$(npx vitest run --coverage 2>&1 || true)
            # Parse: "All files      | 87.50 |"
            coverage_pct=$(echo "$output" | grep "All files" | grep -oE "[0-9]+\.[0-9]+" | head -1 || echo "0")
            ;;
        "jest")
            output=$(npx jest --coverage --coverageReporters=text 2>&1 || true)
            # Parse: "All files      | 87.50 |"
            coverage_pct=$(echo "$output" | grep -E "^All files" | awk '{print $4}' || echo "0")
            ;;
        "pytest")
            output=$(python -m pytest --cov --cov-report=term 2>&1 || true)
            # Parse: "TOTAL      100   20    80%"
            coverage_pct=$(echo "$output" | grep "^TOTAL" | awk '{print $NF}' | tr -d '%' || echo "0")
            ;;
        "gotest")
            output=$(go test ./... -cover 2>&1 || true)
            # Parse: "coverage: 85.7% of statements"
            coverage_pct=$(echo "$output" | grep -oE "coverage: [0-9]+\.[0-9]+%" | grep -oE "[0-9]+\.[0-9]+" | head -1 || echo "0")
            ;;
        *)
            coverage_pct=0
            ;;
    esac

    # Remove % sign if present
    coverage_pct=$(echo "$coverage_pct" | tr -d '%')

    echo "$coverage_pct"
}

# Get framework display name
get_framework_name() {
    local framework="$1"

    case "$framework" in
        "vitest") echo "Vitest" ;;
        "jest") echo "Jest" ;;
        "mocha") echo "Mocha" ;;
        "ava") echo "AVA" ;;
        "jasmine") echo "Jasmine" ;;
        "pytest") echo "Pytest" ;;
        "unittest") echo "Python unittest" ;;
        "gotest") echo "Go test" ;;
        "rspec") echo "RSpec" ;;
        "minitest") echo "Minitest" ;;
        "junit") echo "JUnit" ;;
        *) echo "$framework" ;;
    esac
}

# Main detection function that outputs JSON
detect_and_report() {
    local repo_root="${1:-$(pwd)}"

    # Detect frameworks
    local frameworks
    frameworks=$(detect_test_frameworks "$repo_root")

    if [ -z "$frameworks" ]; then
        echo '{"frameworks": [], "primary": null}'
        return 0
    fi

    # Convert to array
    IFS=',' read -ra framework_array <<< "$frameworks"

    # Priority order (prefer these frameworks)
    local priority=("vitest" "jest" "pytest" "gotest" "mocha")
    local primary=""

    # Find highest priority framework
    for prio in "${priority[@]}"; do
        for fw in "${framework_array[@]}"; do
            if [ "$fw" = "$prio" ]; then
                primary="$fw"
                break 2
            fi
        done
    done

    # If no priority match, use first detected
    if [ -z "$primary" ]; then
        primary="${framework_array[0]}"
    fi

    # Build JSON output
    echo "{"
    echo "  \"frameworks\": [\"${framework_array[*]//,/\", \"}\"],"
    echo "  \"primary\": \"$primary\","
    echo "  \"count\": ${#framework_array[@]}"
    echo "}"
}

# If script is executed directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    detect_and_report "$@"
fi
