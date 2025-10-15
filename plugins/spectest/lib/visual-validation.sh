#!/bin/bash

#
# visual-validation.sh - Screenshot analysis and UI validation
#
# Part of SpecSwarm Comprehensive Quality Assurance System
# Created: October 14, 2025
#
# Uses Claude Code's multimodal capabilities to analyze UI screenshots
#

# Analyze screenshots against spec requirements
analyze_screenshots_against_spec() {
  local SCREENSHOT_DIR="$1"
  local SPEC_FILE="$2"
  local FEATURE_DIR="$3"

  echo ""
  echo "📸 Visual Validation"
  echo "===================="
  echo ""

  # Check if screenshot directory exists
  if [ ! -d "$SCREENSHOT_DIR" ]; then
    echo "  ⚠️  Screenshot directory not found: $SCREENSHOT_DIR"
    echo "  Skipping visual validation"
    echo ""
    return 0
  fi

  # Find all screenshots
  local SCREENSHOTS=$(find "$SCREENSHOT_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) 2>/dev/null | sort)

  if [ -z "$SCREENSHOTS" ]; then
    echo "  ⚠️  No screenshots found in $SCREENSHOT_DIR"
    echo "  Skipping visual validation"
    echo ""
    return 0
  fi

  # Count screenshots
  local SCREENSHOT_COUNT=$(echo "$SCREENSHOTS" | wc -l)
  echo "  Found $SCREENSHOT_COUNT screenshot(s)"
  echo ""

  # Extract UI requirements from spec
  local UI_REQUIREMENTS=$(extract_ui_requirements "$SPEC_FILE")

  if [ -z "$UI_REQUIREMENTS" ]; then
    echo "  ⚠️  No UI requirements found in spec"
    echo "  Skipping detailed validation"
    echo ""

    # Still show screenshots for manual review
    echo "  Screenshots available for manual review:"
    echo "$SCREENSHOTS" | while IFS= read -r screenshot; do
      echo "    - $(basename "$screenshot")"
    done
    echo ""
    return 50  # Neutral score when no requirements to validate against
  fi

  echo "  Analyzing screenshots against spec requirements..."
  echo ""

  # Create analysis report
  local ANALYSIS_REPORT="${FEATURE_DIR}/visual-validation-report.md"

  cat > "$ANALYSIS_REPORT" <<EOF
# Visual Validation Report

**Feature**: $(basename "$FEATURE_DIR")
**Date**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Screenshots Analyzed**: $SCREENSHOT_COUNT

---

## Spec Requirements

The following UI requirements were extracted from the spec:

$UI_REQUIREMENTS

---

## Screenshots for Review

EOF

  # List each screenshot with prompt for Claude Code to analyze
  local SCREENSHOT_INDEX=1
  echo "$SCREENSHOTS" | while IFS= read -r SCREENSHOT_PATH; do
    local SCREENSHOT_NAME=$(basename "$SCREENSHOT_PATH")

    echo "  [$SCREENSHOT_INDEX/$SCREENSHOT_COUNT] $SCREENSHOT_NAME"

    # Add to analysis report
    cat >> "$ANALYSIS_REPORT" <<EOF
### Screenshot $SCREENSHOT_INDEX: $SCREENSHOT_NAME

**Path**: \`$SCREENSHOT_PATH\`

**Analysis Needed**: Claude Code should analyze this screenshot and verify:

1. **Required Elements Present**: Are all UI elements from the spec visible?
2. **Layout Correctness**: Does the layout match the spec description?
3. **Styling Appropriateness**: Are colors, fonts, spacing reasonable?
4. **Accessibility Elements**: Are labels, alt text, ARIA attributes visible/implied?
5. **User Flow Logic**: Does the UI state make sense for this step?

**Spec Context**:
$UI_REQUIREMENTS

---

EOF

    SCREENSHOT_INDEX=$((SCREENSHOT_INDEX + 1))
  done

  echo ""
  echo "  ✅ Visual validation report created:"
  echo "     $ANALYSIS_REPORT"
  echo ""
  echo "  📋 Claude Code: Please review the screenshots and update the report with findings."
  echo ""

  # For Phase 1, return a neutral score
  # In Phase 2, we'll integrate actual Claude Code analysis
  return 75
}

# Extract UI requirements from spec
extract_ui_requirements() {
  local SPEC_FILE="$1"

  if [ ! -f "$SPEC_FILE" ]; then
    return
  fi

  # Extract relevant UI sections from spec
  # Sections to look for:
  # - User Interface
  # - Visual Design
  # - Components
  # - User Experience

  local UI_SECTIONS=""

  # Extract "User Interface" section
  local UI_SECTION=$(awk '
    BEGIN { in_section=0 }
    /^## User Interface/ { in_section=1; next }
    /^## / { if (in_section) exit }
    in_section { print }
  ' "$SPEC_FILE")

  if [ -n "$UI_SECTION" ]; then
    UI_SECTIONS="${UI_SECTIONS}

## User Interface (from spec)

${UI_SECTION}"
  fi

  # Extract "Visual Design" section
  local VISUAL_SECTION=$(awk '
    BEGIN { in_section=0 }
    /^## Visual Design/ { in_section=1; next }
    /^## / { if (in_section) exit }
    in_section { print }
  ' "$SPEC_FILE")

  if [ -n "$VISUAL_SECTION" ]; then
    UI_SECTIONS="${UI_SECTIONS}

## Visual Design (from spec)

${VISUAL_SECTION}"
  fi

  # Extract "User Flows" section for context
  local FLOWS_SECTION=$(awk '
    BEGIN { in_section=0 }
    /^## User Flows/ { in_section=1; next }
    /^## / { if (in_section) exit }
    in_section { print }
  ' "$SPEC_FILE")

  if [ -n "$FLOWS_SECTION" ]; then
    UI_SECTIONS="${UI_SECTIONS}

## User Flows (from spec)

${FLOWS_SECTION}"
  fi

  echo "$UI_SECTIONS"
}

# Perform automated screenshot analysis (Phase 2 feature)
# This is a placeholder for future integration with Claude Code's multimodal API
automated_screenshot_analysis() {
  local SCREENSHOT_PATH="$1"
  local UI_REQUIREMENTS="$2"

  # Phase 2: This would use Claude Code's API to:
  # 1. Read the screenshot image
  # 2. Analyze it against requirements
  # 3. Return structured feedback

  # For now, this is a placeholder
  echo "automated_screenshot_analysis: Not yet implemented (Phase 2)"
}

# Generate screenshot comparison report
generate_screenshot_report() {
  local SCREENSHOT_DIR="$1"
  local SPEC_FILE="$2"
  local OUTPUT_FILE="$3"

  local SCREENSHOTS=$(find "$SCREENSHOT_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) 2>/dev/null | sort)
  local UI_REQUIREMENTS=$(extract_ui_requirements "$SPEC_FILE")

  cat > "$OUTPUT_FILE" <<EOF
# Screenshot Analysis

## Spec Requirements

$UI_REQUIREMENTS

## Screenshots

EOF

  echo "$SCREENSHOTS" | while IFS= read -r screenshot; do
    echo "### $(basename "$screenshot")" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "Path: \`$screenshot\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "**Please analyze this screenshot against the spec requirements above.**" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
  done

  echo "Report generated: $OUTPUT_FILE"
}

# Calculate visual alignment score based on checklist
calculate_visual_alignment_score() {
  local ANALYSIS_REPORT="$1"

  # Phase 1: Return default score
  # Phase 2: Parse analysis report for actual scores

  # For now, check if report exists and has content
  if [ -f "$ANALYSIS_REPORT" ]; then
    local LINE_COUNT=$(wc -l < "$ANALYSIS_REPORT")
    if [ "$LINE_COUNT" -gt 20 ]; then
      echo "75"  # Neutral score
    else
      echo "50"  # Lower score if minimal report
    fi
  else
    echo "0"
  fi
}

# Validate accessibility from screenshots (basic checks)
check_accessibility_from_screenshots() {
  local SCREENSHOT_DIR="$1"

  echo "  Accessibility validation from screenshots:"
  echo "  - Phase 1: Manual review recommended"
  echo "  - Phase 2: Automated checking planned"
  echo ""

  # Placeholder for Phase 2 automated accessibility checks
  # Would analyze screenshots for:
  # - Color contrast
  # - Text size/readability
  # - Visual hierarchy
  # - Focus indicators
}

# Extract user flows from spec for test generation
extract_user_flows() {
  local SPEC_FILE="$1"

  if [ ! -f "$SPEC_FILE" ]; then
    return
  fi

  # Extract user flows section
  awk '
    BEGIN { in_section=0 }
    /^## User Flows/ { in_section=1; next }
    /^## / { if (in_section) exit }
    in_section { print }
  ' "$SPEC_FILE"
}

# Generate Playwright test from user flow
generate_playwright_test_from_flow() {
  local FLOW_DESCRIPTION="$1"
  local OUTPUT_FILE="$2"

  # Phase 2: Parse flow description and generate test code
  # For now, create placeholder

  cat > "$OUTPUT_FILE" <<'EOF'
import { test, expect } from '@playwright/test';

// TODO: Auto-generated test from user flow
// This is a Phase 2 feature - manual test creation recommended for now

test.describe('User Flow', () => {
  test('complete flow', async ({ page }) => {
    // TODO: Implement test steps based on flow description

    await page.goto('/');
    await page.screenshot({ path: 'test-results/screenshots/flow-step-1.png' });

    // Add more steps...
  });
});
EOF

  echo "  Placeholder test generated: $OUTPUT_FILE"
  echo "  Phase 2 will auto-generate from flow description"
}
