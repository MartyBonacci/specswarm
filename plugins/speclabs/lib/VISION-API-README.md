# Vision API Integration

**Part of Phase 1a: Test Orchestrator Foundation**

**⚠️ IMPORTANT: This is a MOCK implementation for Phase 1a architecture validation.**

**Production requires**:
- Playwright for screenshot capture
- Claude API with vision capabilities for analysis
- Real integration code (see comments in vision-api.sh)

---

## Purpose

The Vision API validates UI implementation by:
1. Capturing screenshots of running applications
2. Analyzing screenshots with vision/multimodal AI
3. Detecting UI issues (missing elements, styling problems, layout issues)
4. Feeding results into the Decision Maker for intelligent retry strategies

---

## Quick Start (Mock Implementation)

```bash
source plugins/speclabs/lib/state-manager.sh
source plugins/speclabs/lib/vision-api.sh

# Run complete validation
SESSION_ID="orch-20251016-123456-789"
vision_validate "$SESSION_ID" "http://localhost:3000" "UI must have login form with submit button"

# Check results
vision_report "$SESSION_ID"
```

---

## API Reference

### Core Functions

#### `vision_validate`
Run complete UI validation (screenshot + analysis).

**Arguments**:
- `$1` - session_id
- `$2` - url (e.g., http://localhost:3000)
- `$3` - requirements (text description)

**Returns**: JSON with status, score, screenshot path

**Mock**: Creates placeholder screenshot, analyzes based on keyword matching

**Real**: Would use Playwright + Claude Vision API

---

#### `vision_capture_screenshot`
Capture screenshot of URL.

**Real Implementation** (replace mock):
```bash
playwright screenshot "$url" "$screenshot_file" \
  --viewport-size=1280,720 \
  --full-page \
  --wait-for-selector="body"
```

---

#### `vision_analyze`
Analyze screenshot against requirements.

**Real Implementation** (replace mock):
```bash
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -d '{
    "model": "claude-3-5-sonnet-20241022",
    "max_tokens": 1024,
    "messages": [{
      "role": "user",
      "content": [
        {"type": "image", "source": {"type": "base64", "data": "..."}},
        {"type": "text", "text": "Analyze UI against: '"$requirements"'"}
      ]
    }]
  }'
```

---

### Helper Functions

- `vision_check_elements` - Check specific UI elements
- `vision_validate_design` - Validate against design spec file
- `vision_compare` - Compare before/after screenshots
- `vision_check_accessibility` - Accessibility analysis
- `vision_report` - Human-readable report
- `vision_get_results` - Get results from state
- `vision_cleanup` - Clean up old screenshots

---

## Integration with Phase 1a

**State Manager**: Stores validation results in session state
**Decision Maker**: Detects `ui_issues` failure type from vision results
**Prompt Refiner**: Generates UI-specific refinement guidance

---

## Production Integration Steps

1. **Install Playwright**:
   ```bash
   npm install -D @playwright/test
   npx playwright install chromium
   ```

2. **Get Anthropic API Key**:
   ```bash
   export ANTHROPIC_API_KEY="your-key-here"
   ```

3. **Replace Mock Functions**:
   - Update `vision_capture_screenshot` with Playwright code
   - Update `vision_analyze` with Claude API call
   - Test with real application

4. **Configure**:
   ```bash
   export VISION_SCREENSHOTS_DIR="/path/to/screenshots"
   ```

---

## Testing

```bash
./plugins/speclabs/lib/test-vision-api.sh
```

All 14 tests pass ✅ (validates structure, not real vision analysis)

---

## Files

```
plugins/speclabs/lib/
├── vision-api.sh              # Mock implementation (400 lines)
├── test-vision-api.sh         # Test suite (450 lines)
└── VISION-API-README.md       # This file
```

---

**Vision API v1.0** - Part of SpecLabs Phase 1a
**Status**: ✅ Mock Complete (14/14 tests passing)
**Production Status**: ⚠️ Requires real Playwright + Claude Vision API
**Date**: 2025-10-16
