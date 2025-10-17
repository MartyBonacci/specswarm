---
description: Comprehensive codebase quality analysis with prioritized recommendations
---

<!--
ATTRIBUTION CHAIN:
1. Original: SpecLab plugin by Marty Bonacci & Claude Code (2025)
2. Phase 2 Enhancement: Comprehensive quality analysis feature
-->

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Perform comprehensive codebase quality analysis to identify improvement opportunities and generate prioritized recommendations.

**Key Capabilities**:
1. **Test Coverage Gaps**: Find files without tests
2. **Architecture Issues**: Detect anti-patterns and violations
3. **Missing Documentation**: Identify undocumented code
4. **Performance Issues**: Find optimization opportunities
5. **Security Issues**: Detect vulnerabilities
6. **Quality Scoring**: Calculate module-level quality scores

**Coverage**: Provides holistic codebase health assessment

---

## Execution Steps

### 1. Initialize Analysis Context

**YOU MUST NOW initialize the analysis using the Bash tool:**

1. **Get repository root:**
   ```bash
   git rev-parse --show-toplevel 2>/dev/null || pwd
   ```
   Store as REPO_ROOT.

2. **Display analysis banner:**
   ```
   📊 Codebase Quality Analysis
   ============================

   Analyzing: {REPO_ROOT}
   Started: {TIMESTAMP}
   ```

3. **Detect project type** by reading package.json:
   - Framework: Vite, Next.js, Remix, CRA, or Generic
   - Language: JavaScript, TypeScript, Python, Go, etc.
   - Test framework: Vitest, Jest, Pytest, etc.

---

### 2. Test Coverage Gap Analysis

**YOU MUST NOW analyze test coverage gaps:**

1. **Find all source files** using Bash:
   ```bash
   find ${REPO_ROOT} -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) \
     -not -path "*/node_modules/*" \
     -not -path "*/dist/*" \
     -not -path "*/build/*" \
     -not -path "*/.next/*" \
     -not -path "*/test/*" \
     -not -path "*/tests/*" \
     -not -path "*/__tests__/*"
   ```
   Store count as TOTAL_SOURCE_FILES.

2. **Find all test files** using Bash:
   ```bash
   find ${REPO_ROOT} -type f \( \
     -name "*.test.ts" -o -name "*.test.tsx" -o -name "*.test.js" -o -name "*.test.jsx" -o \
     -name "*.spec.ts" -o -name "*.spec.tsx" -o -name "*.spec.js" -o -name "*.spec.jsx" \
   \) -not -path "*/node_modules/*"
   ```
   Store count as TOTAL_TEST_FILES.

3. **Calculate test coverage ratio:**
   ```
   TEST_RATIO = (TOTAL_TEST_FILES / TOTAL_SOURCE_FILES) * 100
   ```

4. **Find files without corresponding tests:**
   - For each source file in app/, src/, lib/
   - Check if corresponding test file exists
   - Add to UNTESTED_FILES list if no test found

5. **Display test coverage gaps:**
   ```
   📋 Test Coverage Gaps
   =====================

   Source Files: {TOTAL_SOURCE_FILES}
   Test Files: {TOTAL_TEST_FILES}
   Test Ratio: {TEST_RATIO}%

   Files Without Tests ({COUNT}):
   {TOP_10_UNTESTED_FILES}

   Priority: {HIGH/MEDIUM/LOW}
   Impact: Missing tests for {COUNT} files
   ```

---

### 3. Architecture Pattern Analysis

**YOU MUST NOW analyze architectural patterns:**

1. **Run SSR pattern validator** using Bash:
   ```bash
   bash ~/.claude/plugins/marketplaces/specswarm-marketplace/plugins/specswarm/lib/ssr-validator.sh
   ```
   Capture issues count and details.

2. **Scan for common anti-patterns** using Grep:

   a. **useEffect with fetch** (should use loaders):
      ```bash
      grep -rn "useEffect.*fetch" app/ src/ --include="*.tsx" --include="*.ts"
      ```

   b. **Client-side state for server data** (should use loader data):
      ```bash
      grep -rn "useState.*fetch\|useState.*axios" app/ src/ --include="*.tsx"
      ```

   c. **Class components** (should use functional):
      ```bash
      grep -rn "class.*extends React.Component" app/ src/ --include="*.tsx" --include="*.jsx"
      ```

   d. **Inline styles** (should use Tailwind/CSS modules):
      ```bash
      grep -rn "style={{" app/ src/ --include="*.tsx" --include="*.jsx"
      ```

3. **Display architecture issues:**
   ```
   🏗️  Architecture Issues
   ======================

   SSR Patterns: {SSR_ISSUES} issues
   - Hardcoded URLs: {COUNT}
   - Relative URLs in SSR: {COUNT}

   React Anti-Patterns: {REACT_ISSUES} issues
   - useEffect with fetch: {COUNT}
   - Client-side state: {COUNT}
   - Class components: {COUNT}

   Styling Issues: {STYLE_ISSUES} issues
   - Inline styles: {COUNT}

   Priority: {CRITICAL/HIGH/MEDIUM/LOW}
   Impact: Architectural debt in {TOTAL_ISSUES} locations
   ```

---

### 4. Documentation Gap Analysis

**YOU MUST NOW analyze documentation gaps:**

1. **Find functions without JSDoc** using Grep:
   ```bash
   grep -rn "^function\|^export function\|^const.*= (" app/ src/ --include="*.ts" --include="*.tsx" | \
     while read line; do
       # Check if previous line has /** comment
     done
   ```

2. **Find components without prop types:**
   ```bash
   grep -rn "export.*function.*Component\|export.*const.*Component" app/ src/ --include="*.tsx"
   ```
   Check if they have TypeScript interface/type definitions.

3. **Find API endpoints without OpenAPI/comments:**
   ```bash
   find app/routes/ app/api/ -name "*.ts" -o -name "*.tsx"
   ```
   Check for route handler documentation.

4. **Display documentation gaps:**
   ```
   📚 Documentation Gaps
   =====================

   Functions without JSDoc: {COUNT}
   Components without prop types: {COUNT}
   API endpoints without docs: {COUNT}

   Priority: {MEDIUM/LOW}
   Impact: {COUNT} undocumented items
   ```

---

### 5. Performance Issue Detection

**YOU MUST NOW detect performance issues:**

1. **Run bundle size analyzer** (Phase 3 Enhancement) using Bash:
   ```bash
   bash ~/.claude/plugins/marketplaces/specswarm-marketplace/plugins/speclabs/lib/bundle-size-monitor.sh ${REPO_ROOT}
   ```
   Capture:
   - Total bundle size
   - List of large bundles (>500KB)
   - List of critical bundles (>1MB)
   - Bundle size score (0-20 points)

2. **Find missing lazy loading:**
   ```bash
   grep -rn "import.*from" app/pages/ app/routes/ --include="*.tsx" | \
     grep -v "React.lazy\|lazy("
   ```

3. **Find unoptimized images:**
   ```bash
   find public/ static/ app/ -type f \( -name "*.jpg" -o -name "*.png" \) -size +100k
   ```

4. **Display performance issues:**
   ```
   ⚡ Performance Issues
   =====================

   Bundle Sizes (Phase 3):
   - Total: {TOTAL_SIZE}
   - Large bundles (>500KB): {COUNT}
   - Critical bundles (>1MB): {COUNT}
   - Top offenders:
     * {LARGEST_BUNDLE_1}
     * {LARGEST_BUNDLE_2}
   - Score: {SCORE}/20 points

   Missing Lazy Loading: {COUNT} routes
   Unoptimized Images: {COUNT} files (>{SIZE})

   Priority: {HIGH/MEDIUM}
   Impact: Page load performance degraded by {TOTAL_SIZE}
   ```

---

### 6. Security Issue Detection

**YOU MUST NOW detect security issues:**

1. **Find exposed secrets** using Grep:
   ```bash
   grep -rn "API_KEY\|SECRET\|PASSWORD.*=" app/ src/ --include="*.ts" --include="*.tsx" | \
     grep -v "process.env\|import.meta.env"
   ```

2. **Find missing input validation:**
   ```bash
   grep -rn "formData.get\|request.body\|params\." app/routes/ app/api/ --include="*.ts"
   ```
   Check if followed by validation logic.

3. **Find potential XSS vulnerabilities:**
   ```bash
   grep -rn "dangerouslySetInnerHTML\|innerHTML" app/ src/ --include="*.tsx" --include="*.jsx"
   ```

4. **Display security issues:**
   ```
   🔒 Security Issues
   ==================

   Exposed Secrets: {COUNT} potential leaks
   Missing Input Validation: {COUNT} endpoints
   XSS Vulnerabilities: {COUNT} locations

   Priority: {CRITICAL if >0, else LOW}
   Impact: Security risk in {COUNT} locations
   ```

---

### 7. Module-Level Quality Scoring

**YOU MUST NOW calculate quality scores per module:**

1. **Group files by module/directory:**
   - app/pages/
   - app/components/
   - app/utils/
   - src/services/
   - etc.

2. **For each module, calculate score:**
   - Test Coverage: Has tests? (+25 points)
   - Documentation: Has JSDoc/types? (+15 points)
   - No Anti-Patterns: Clean architecture? (+20 points)
   - No Security Issues: Secure? (+20 points)
   - Performance: Optimized? (+20 points)
   - Total: 0-100 points

3. **Display module scores:**
   ```
   📊 Module Quality Scores
   ========================

   app/pages/: 75/100 ████████████████░░░░ (Good)
   - Test Coverage: ✓ 25/25
   - Documentation: ✓ 15/15
   - Architecture: ⚠️ 15/20 (2 anti-patterns)
   - Security: ✓ 20/20
   - Performance: ✗ 0/20 (missing lazy load)

   app/components/: 45/100 ██████████░░░░░░░░░░ (Needs Improvement)
   - Test Coverage: ✗ 0/25 (no tests)
   - Documentation: ⚠️ 10/15 (missing prop types)
   - Architecture: ✓ 20/20
   - Security: ✓ 20/20
   - Performance: ⚠️ 10/20 (large bundle)

   Overall Codebase Score: {AVERAGE}/100
   ```

---

### 8. Prioritized Recommendations

**YOU MUST NOW generate prioritized recommendations:**

1. **Critical Priority** (security, production failures):
   - Exposed secrets
   - SSR pattern violations
   - Security vulnerabilities

2. **High Priority** (quality, maintainability):
   - Missing test coverage for core modules
   - Major architecture anti-patterns
   - Large bundle sizes

3. **Medium Priority** (improvement opportunities):
   - Missing documentation
   - Minor anti-patterns
   - Missing lazy loading

4. **Low Priority** (nice-to-have):
   - Additional JSDoc
   - Inline style cleanup
   - Image optimization

5. **Display recommendations:**
   ```
   📈 Prioritized Recommendations
   ===============================

   🔴 CRITICAL (Fix Immediately):
   1. Remove 3 exposed API keys from client code
      Impact: Security breach risk
      Files: app/config.ts:12, app/utils/api.ts:45, src/client.ts:8
      Fix: Move to environment variables

   2. Fix 11 hardcoded URLs in SSR contexts
      Impact: Production deployment will fail
      Files: See SSR validation report
      Fix: Use getApiUrl() helper

   🟠 HIGH (Fix This Week):
   3. Add tests for 15 untested core modules
      Impact: No regression protection
      Modules: app/pages/, app/components/Auth/
      Fix: Generate test templates

   4. Reduce bundle size by 2.5MB
      Impact: Slow page loads
      Files: dist/main.js (3.2MB), dist/vendor.js (1.8MB)
      Fix: Implement code splitting and lazy loading

   🟡 MEDIUM (Fix This Sprint):
   5. Add JSDoc to 45 functions
      Impact: Maintainability
      Fix: Use IDE code generation

   6. Replace 12 useEffect fetches with loaders
      Impact: Architecture consistency
      Fix: Migrate to React Router loaders

   🟢 LOW (Nice to Have):
   7. Optimize 8 large images
      Impact: Minor performance gain
      Fix: Use next/image or image optimization service

   Estimated Impact: Fixing critical + high items would increase quality score from {CURRENT}/100 → {PROJECTED}/100
   ```

---

### 9. Generate Analysis Report

**YOU MUST NOW generate final report:**

1. **Create summary:**
   ```
   ═══════════════════════════════════════════════
   Quality Analysis Report
   ═══════════════════════════════════════════════

   Overall Quality Score: {SCORE}/100 {STATUS_EMOJI}

   Breakdown:
   - Test Coverage: {SCORE}/100
   - Architecture: {SCORE}/100
   - Documentation: {SCORE}/100
   - Performance: {SCORE}/100
   - Security: {SCORE}/100

   Issues Found:
   - Critical: {COUNT} 🔴
   - High: {COUNT} 🟠
   - Medium: {COUNT} 🟡
   - Low: {COUNT} 🟢

   Total Issues: {TOTAL}
   ```

2. **Save report** to file:
   - Write to: `/memory/quality-analysis-{TIMESTAMP}.md`
   - Include all sections above
   - Add file-by-file details
   - Include fix commands/examples

3. **Display next steps:**
   ```
   📋 Next Steps
   =============

   1. Review full report: /memory/quality-analysis-{TIMESTAMP}.md
   2. Fix critical issues first (security + SSR)
   3. Run quality validation: /specswarm:implement --validate-only
   4. Track improvements in metrics.json

   Commands:
   - View detailed SSR issues: bash plugins/specswarm/lib/ssr-validator.sh
   - Generate test templates: /specswarm:implement {feature}
   - Re-run analysis: /specswarm:analyze-quality
   ```

---

## Success Criteria

✅ All analysis sections completed
✅ Issues categorized by priority
✅ Recommendations generated with impact estimates
✅ Report saved to /memory/
✅ Next steps provided

---

## Operating Principles

1. **Comprehensive**: Scan entire codebase, not just recent changes
2. **Prioritized**: Critical issues first, nice-to-haves last
3. **Actionable**: Provide specific fixes, not just problems
4. **Impact-Aware**: Estimate quality score improvement
5. **Automated**: Runnable without user interaction
6. **Repeatable**: Track improvements over time

---

**Note**: This command provides a holistic view of codebase quality. Use it before major releases, after adding new features, or when quality scores decline.
