# Quality Standards

**Version**: 1.0.0
**Created**: {CREATION_DATE}
**Last Updated**: {LAST_UPDATE_DATE}

<!--
This file defines the quality gates and testing standards for this project.
All features must meet these standards before merging to main.
-->

---

## Quality Gates

### Overall Requirements

```yaml
min_test_coverage: 85
min_quality_score: 80
block_merge_on_failure: false
```

**Explanation**:
- `min_test_coverage`: Minimum percentage of code covered by tests
- `min_quality_score`: Minimum quality score (0-100) required
- `block_merge_on_failure`: If `true`, prevents merge when quality gates fail

---

## Test Requirements

### Unit Tests

```yaml
unit_tests_required: true
framework: {TEST_FRAMEWORK}
command: {TEST_COMMAND}
```

**Coverage Targets**:
- Overall project: **85%**
- Critical business logic: **95%**
- New features: **90%**

**What to Test**:
- Pure functions and utilities
- Business logic and calculations
- Data transformations
- Edge cases and error handling

### Integration Tests

```yaml
integration_tests_required: true
min_integration_coverage: 70
```

**What to Test**:
- API endpoint workflows
- Database operations
- Service interactions
- Authentication flows

### Browser Tests

```yaml
browser_tests_required: true
browser_test_framework: {BROWSER_FRAMEWORK}
browsers:
  - chromium
  - firefox
```

**What to Test**:
- Complete user flows (from spec)
- Form submissions and validation
- Navigation and routing
- Error states and edge cases

---

## Visual Validation

### Spec Alignment

```yaml
spec_alignment_required: true
min_visual_score: 75
```

**What to Validate**:
- All UI elements from spec are present
- Layout matches spec description
- User flows work as specified
- Error messages appear correctly

### Screenshot Analysis

```yaml
screenshot_validation: true
screenshot_on_failure: true
visual_regression_enabled: false  # Phase 2 feature
```

**Screenshots Captured**:
- Each step of user flows
- All major page states
- Error conditions
- Success confirmations

---

## Accessibility Standards

### WCAG Compliance

```yaml
accessibility_required: true
wcag_level: AA
wcag_version: 2.1
```

**Required Checks**:
- ✅ All images have alt text or role="presentation"
- ✅ All form inputs have labels or aria-label
- ✅ All buttons have accessible names
- ✅ Color contrast meets WCAG AA (4.5:1 for text)
- ✅ Keyboard navigation works for all interactive elements
- ✅ Proper heading hierarchy (single h1, logical h2-h6)
- ✅ Links have descriptive text or aria-label

### Semantic HTML

```yaml
semantic_html_required: true
```

**Best Practices**:
- Use semantic elements (`<nav>`, `<main>`, `<article>`, `<aside>`)
- Proper form structure (`<form>`, `<fieldset>`, `<legend>`)
- Meaningful heading hierarchy
- Lists for list content (`<ul>`, `<ol>`, `<dl>`)

---

## Quality Scoring

Quality score is calculated from five components:

| Component | Weight | Pass Criteria | Points |
|-----------|--------|---------------|--------|
| Unit Tests | 25% | All tests passing | 0-25 |
| Integration Tests | 20% | All tests passing | 0-20 |
| Code Coverage | 25% | ≥ min_test_coverage | 0-25 |
| Browser Tests | 15% | All tests passing | 0-15 |
| Visual Alignment | 15% | ≥ min_visual_score | 0-15 |

**Total**: 0-100 points

**Example Calculation**:
```
Unit Tests: ✅ Pass → 25 points
Integration: ✅ Pass → 20 points
Coverage: 94% → 25 points (94/100 * 25)
Browser: ✅ Pass → 15 points
Visual: 85% → 13 points (85/100 * 15)
────────────────────────────────
Total: 98/100 ✅
```

---

## Feature-Specific Exemptions

Some features may not require all quality gates.

### Backend-Only Features

For features with no UI (APIs, workers, migrations):

```yaml
browser_tests_required: false
visual_validation_required: false
accessibility_required: false
```

**When to Use**:
- REST/GraphQL API endpoints
- Background workers/jobs
- Database migrations
- CLI tools

### UI-Only Features

For features with no backend logic:

```yaml
integration_tests_required: false
```

**When to Use**:
- Static pages
- UI component libraries
- Design system components

---

## Test Environment

### Development

```yaml
test_database: sqlite_memory
test_port: 5173
api_mock_mode: true
```

### CI/CD

```yaml
test_database: postgresql_test
parallel_execution: true
max_workers: 4
```

---

## Performance Budgets

### Enforcement (Phase 3 Feature)

```yaml
enforce_budgets: true
block_merge_on_budget_violation: false
```

**Explanation**:
- `enforce_budgets`: Enable performance budget validation during quality checks
- `block_merge_on_budget_violation`: If `true`, prevents merge when budgets exceeded

### Page Load Times

```yaml
max_initial_load: 3000ms  # First page load
max_route_change: 1000ms  # Client-side navigation
max_api_response: 500ms   # API endpoint response
```

### Bundle Sizes

```yaml
max_bundle_size: 500      # KB per bundle (uncompressed)
max_initial_load: 1000    # KB for initial load (uncompressed)
max_js_bundle: 250        # KB gzipped
max_css_bundle: 50        # KB gzipped
max_total_size: 500       # KB gzipped
```

**Budget Levels**:
- **Excellent**: < 500KB total
- **Good**: 500-750KB
- **Acceptable**: 750-1000KB
- **Poor**: 1000-2000KB
- **Critical**: > 2000KB

---

## Security Requirements

### Dependency Scanning

```yaml
vulnerability_scanning: true
max_severity_allowed: medium
auto_update_patches: true
```

### Code Scanning

```yaml
eslint_security_rules: true
no_hardcoded_secrets: true
csrf_protection_required: true
```

---

## Continuous Improvement

### Review Schedule

```yaml
review_frequency: monthly
update_process: team_discussion
version_control: git_commits
```

### Metrics Tracking

Quality metrics are saved to `/memory/metrics.json` for each feature:

```json
{
  "features": {
    "001-user-authentication": {
      "quality_score": 98,
      "coverage": 94,
      "visual_score": 85,
      "tests": {
        "unit": "pass",
        "integration": "pass",
        "browser": "pass"
      }
    }
  }
}
```

---

## Common Issues and Resolutions

### Issue: Tests failing intermittently

**Solution**: Add proper wait conditions, increase timeouts, check for race conditions

### Issue: Coverage below threshold

**Solution**: Identify untested code paths, add tests for edge cases, test error handling

### Issue: Visual validation fails

**Solution**: Review screenshots against spec, update UI to match requirements, clarify spec if ambiguous

### Issue: Accessibility violations

**Solution**: Add missing alt text, labels, ARIA attributes; check color contrast; test keyboard navigation

---

## Tools and Configuration

### Test Frameworks

- **Unit/Integration**: {TEST_FRAMEWORK}
- **Browser**: {BROWSER_FRAMEWORK}
- **Coverage**: {COVERAGE_TOOL}

### CI/CD Integration

```yaml
run_on_pr: true
run_on_push: true
block_merge_on_failure: false
post_results_to_pr: true
```

### Local Development

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Run browser tests
npm run test:browser

# Run specific test file
npm test path/to/test.ts
```

---

## Version History

### 1.0.0 ({CREATION_DATE})

- Initial quality standards
- Established baseline metrics
- Defined testing requirements
- Set coverage targets

---

## Notes

**Philosophy**: Quality gates should enable teams to ship with confidence, not slow them down.

**Flexibility**: Standards can be adjusted based on project needs, team size, and release cadence.

**Continuous Improvement**: Review and update these standards regularly based on team feedback and project evolution.

---

**Questions or Issues?** Discuss quality standards in team meetings or update constitution if governance review needed.
