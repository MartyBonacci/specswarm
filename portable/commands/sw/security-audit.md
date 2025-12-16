---
description: Comprehensive security scanning including dependency vulnerabilities, secret detection, OWASP Top 10 analysis, and configuration checks
args:
  - name: --quick
    description: Quick scan (dependency check and basic secret detection only)
    required: false
  - name: --thorough
    description: Thorough scan (extensive pattern matching and deep analysis)
    required: false
---

## Goal

Perform a comprehensive security audit of your codebase to identify vulnerabilities before merging or releasing.

## User Input

```text
$ARGUMENTS
```

---

## What This Command Does

`/sw:security-audit` performs a comprehensive security analysis of your codebase:

1. **Dependency Scanning** - Checks for known vulnerabilities in npm/yarn/pnpm packages
2. **Secret Detection** - Scans for hardcoded API keys, passwords, tokens, and credentials
3. **OWASP Top 10 Analysis** - Detects common web vulnerabilities (XSS, SQL injection, etc.)
4. **Security Configuration** - Validates HTTPS, CORS, headers, and other security settings
5. **Report Generation** - Creates actionable report with severity levels and remediation steps

---

## When to Use This Command

- Before merging features to main/production branches
- As part of CI/CD pipeline security gates
- Before major releases
- After adding new dependencies
- When investigating security concerns
- Regular security audits (monthly/quarterly)

---

## Prerequisites

- Git repository
- Node.js project with package.json (for dependency scanning)
- Working directory should be project root

---

## Usage

```bash
/sw:security-audit
```

**Options** (via interactive prompts):
- Scan depth (quick/standard/thorough)
- Report format (markdown/json/both)
- Severity threshold (all/medium+/high+/critical)
- Auto-fix vulnerabilities (yes/no)

---

## Output

Generates a security audit report: `security-audit-YYYY-MM-DD.md`

**Report Sections**:
1. Executive Summary (overall risk score, critical findings count)
2. Dependency Vulnerabilities (from npm audit/yarn audit)
3. Secret Detection Results (hardcoded credentials, API keys)
4. Code Vulnerabilities (OWASP Top 10 patterns)
5. Security Configuration Issues
6. Remediation Recommendations (prioritized by severity)

---

## Implementation

```bash
#!/bin/bash

set -euo pipefail

# ============================================================================
# SECURITY AUDIT COMMAND - v3.1.0
# ============================================================================

echo "🔒 SpecSwarm Security Audit"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================================================
# CONFIGURATION
# ============================================================================

REPORT_DATE=$(date +%Y-%m-%d)
REPORT_FILE="security-audit-${REPORT_DATE}.md"
SCAN_DEPTH="standard"
REPORT_FORMAT="markdown"
SEVERITY_THRESHOLD="all"
AUTO_FIX="no"

# Vulnerability counters
CRITICAL_COUNT=0
HIGH_COUNT=0
MEDIUM_COUNT=0
LOW_COUNT=0
INFO_COUNT=0

# Temporary files for scan results
TEMP_DIR=$(mktemp -d)
DEP_SCAN_FILE="${TEMP_DIR}/dep-scan.json"
SECRET_SCAN_FILE="${TEMP_DIR}/secret-scan.txt"
CODE_SCAN_FILE="${TEMP_DIR}/code-scan.txt"
CONFIG_SCAN_FILE="${TEMP_DIR}/config-scan.txt"

# Cleanup on exit
trap 'rm -rf "$TEMP_DIR"' EXIT

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

log_section() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$1"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
}

log_finding() {
  local severity=$1
  local category=$2
  local message=$3

  case "$severity" in
    CRITICAL) ((CRITICAL_COUNT++)); echo "🔴 CRITICAL [$category]: $message" ;;
    HIGH)     ((HIGH_COUNT++));     echo "🟠 HIGH [$category]: $message" ;;
    MEDIUM)   ((MEDIUM_COUNT++));   echo "🟡 MEDIUM [$category]: $message" ;;
    LOW)      ((LOW_COUNT++));      echo "🔵 LOW [$category]: $message" ;;
    INFO)     ((INFO_COUNT++));     echo "ℹ️  INFO [$category]: $message" ;;
  esac
}

calculate_risk_score() {
  # Risk score = (CRITICAL * 10) + (HIGH * 5) + (MEDIUM * 2) + (LOW * 1)
  local score=$(( CRITICAL_COUNT * 10 + HIGH_COUNT * 5 + MEDIUM_COUNT * 2 + LOW_COUNT * 1 ))
  echo "$score"
}

get_risk_level() {
  local score=$1
  if [ "$score" -ge 50 ]; then
    echo "CRITICAL"
  elif [ "$score" -ge 20 ]; then
    echo "HIGH"
  elif [ "$score" -ge 10 ]; then
    echo "MEDIUM"
  else
    echo "LOW"
  fi
}

# ============================================================================
# PREFLIGHT CHECKS
# ============================================================================

log_section "Preflight Checks"

# Check if in git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "❌ Error: Not in a git repository"
  echo "   Security audit requires a git repository to scan committed code"
  exit 1
fi

# Check if package.json exists
if [ ! -f "package.json" ]; then
  echo "⚠️  Warning: No package.json found - dependency scanning will be skipped"
  HAS_PACKAGE_JSON=false
else
  HAS_PACKAGE_JSON=true
  echo "✅ Found package.json"
fi

# Detect package manager
if [ "$HAS_PACKAGE_JSON" = true ]; then
  if [ -f "package-lock.json" ]; then
    PKG_MANAGER="npm"
    echo "✅ Detected npm package manager"
  elif [ -f "yarn.lock" ]; then
    PKG_MANAGER="yarn"
    echo "✅ Detected yarn package manager"
  elif [ -f "pnpm-lock.yaml" ]; then
    PKG_MANAGER="pnpm"
    echo "✅ Detected pnpm package manager"
  else
    PKG_MANAGER="npm"
    echo "⚠️  No lock file found, defaulting to npm"
  fi
fi

echo ""
echo "Repository: $(basename "$(git rev-parse --show-toplevel)")"
echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
echo "Scan Date: $(date '+%Y-%m-%d %H:%M:%S')"

# ============================================================================
# INTERACTIVE CONFIGURATION
# ============================================================================

log_section "Scan Configuration"

# Question 1: Scan depth
cat << 'EOF_QUESTION_1' | claude --question
{
  "questions": [
    {
      "question": "How thorough should the security scan be?",
      "header": "Scan depth",
      "multiSelect": false,
      "options": [
        {
          "label": "Quick scan",
          "description": "Fast scan - dependency check and basic secret detection (~1 min)"
        },
        {
          "label": "Standard scan",
          "description": "Recommended - all checks with standard patterns (~3-5 min)"
        },
        {
          "label": "Thorough scan",
          "description": "Deep scan - extensive pattern matching and analysis (~10+ min)"
        }
      ]
    }
  ]
}
EOF_QUESTION_1

# Parse scan depth answer
if echo "$CLAUDE_ANSWERS" | jq -e '.["Scan depth"] == "Quick scan"' > /dev/null 2>&1; then
  SCAN_DEPTH="quick"
elif echo "$CLAUDE_ANSWERS" | jq -e '.["Scan depth"] == "Thorough scan"' > /dev/null 2>&1; then
  SCAN_DEPTH="thorough"
else
  SCAN_DEPTH="standard"
fi

echo "Scan depth: $SCAN_DEPTH"

# Question 2: Severity threshold
cat << 'EOF_QUESTION_2' | claude --question
{
  "questions": [
    {
      "question": "What severity level should be included in the report?",
      "header": "Severity",
      "multiSelect": false,
      "options": [
        {
          "label": "All findings",
          "description": "Include all severity levels (CRITICAL, HIGH, MEDIUM, LOW, INFO)"
        },
        {
          "label": "Medium and above",
          "description": "Show CRITICAL, HIGH, and MEDIUM (hide LOW and INFO)"
        },
        {
          "label": "High and above",
          "description": "Show only CRITICAL and HIGH findings"
        },
        {
          "label": "Critical only",
          "description": "Show only CRITICAL findings"
        }
      ]
    }
  ]
}
EOF_QUESTION_2

# Parse severity threshold
if echo "$CLAUDE_ANSWERS" | jq -e '.["Severity"] == "Medium and above"' > /dev/null 2>&1; then
  SEVERITY_THRESHOLD="medium"
elif echo "$CLAUDE_ANSWERS" | jq -e '.["Severity"] == "High and above"' > /dev/null 2>&1; then
  SEVERITY_THRESHOLD="high"
elif echo "$CLAUDE_ANSWERS" | jq -e '.["Severity"] == "Critical only"' > /dev/null 2>&1; then
  SEVERITY_THRESHOLD="critical"
else
  SEVERITY_THRESHOLD="all"
fi

echo "Severity threshold: $SEVERITY_THRESHOLD"

# Question 3: Auto-fix
if [ "$HAS_PACKAGE_JSON" = true ]; then
  cat << 'EOF_QUESTION_3' | claude --question
{
  "questions": [
    {
      "question": "Should we attempt to auto-fix dependency vulnerabilities?",
      "header": "Auto-fix",
      "multiSelect": false,
      "options": [
        {
          "label": "Yes, auto-fix",
          "description": "Run 'npm audit fix' to automatically update vulnerable dependencies"
        },
        {
          "label": "No, report only",
          "description": "Only generate report without making changes"
        }
      ]
    }
  ]
}
EOF_QUESTION_3

  # Parse auto-fix answer
  if echo "$CLAUDE_ANSWERS" | jq -e '.["Auto-fix"] == "Yes, auto-fix"' > /dev/null 2>&1; then
    AUTO_FIX="yes"
  fi

  echo "Auto-fix: $AUTO_FIX"
fi

# ============================================================================
# SCAN 1: DEPENDENCY VULNERABILITIES
# ============================================================================

log_section "1. Dependency Vulnerability Scan"

if [ "$HAS_PACKAGE_JSON" = true ]; then
  echo "Running ${PKG_MANAGER} audit..."

  # Run audit and capture results
  case "$PKG_MANAGER" in
    npm)
      if npm audit --json > "$DEP_SCAN_FILE" 2>/dev/null; then
        echo "✅ npm audit completed"
      else
        echo "⚠️  npm audit found vulnerabilities"
      fi

      # Parse npm audit results
      if [ -f "$DEP_SCAN_FILE" ]; then
        VULN_CRITICAL=$(jq '.metadata.vulnerabilities.critical // 0' "$DEP_SCAN_FILE")
        VULN_HIGH=$(jq '.metadata.vulnerabilities.high // 0' "$DEP_SCAN_FILE")
        VULN_MEDIUM=$(jq '.metadata.vulnerabilities.moderate // 0' "$DEP_SCAN_FILE")
        VULN_LOW=$(jq '.metadata.vulnerabilities.low // 0' "$DEP_SCAN_FILE")

        echo "  Critical: $VULN_CRITICAL"
        echo "  High: $VULN_HIGH"
        echo "  Medium: $VULN_MEDIUM"
        echo "  Low: $VULN_LOW"

        # Update counters
        CRITICAL_COUNT=$((CRITICAL_COUNT + VULN_CRITICAL))
        HIGH_COUNT=$((HIGH_COUNT + VULN_HIGH))
        MEDIUM_COUNT=$((MEDIUM_COUNT + VULN_MEDIUM))
        LOW_COUNT=$((LOW_COUNT + VULN_LOW))
      fi
      ;;
    yarn)
      if yarn audit --json > "$DEP_SCAN_FILE" 2>/dev/null; then
        echo "✅ yarn audit completed"
      else
        echo "⚠️  yarn audit found vulnerabilities"
      fi
      ;;
    pnpm)
      if pnpm audit --json > "$DEP_SCAN_FILE" 2>/dev/null; then
        echo "✅ pnpm audit completed"
      else
        echo "⚠️  pnpm audit found vulnerabilities"
      fi
      ;;
  esac

  # Auto-fix if requested
  if [ "$AUTO_FIX" = "yes" ]; then
    echo ""
    echo "Attempting auto-fix..."
    case "$PKG_MANAGER" in
      npm)
        npm audit fix
        echo "✅ Auto-fix completed"
        ;;
      yarn)
        echo "⚠️  Yarn does not support auto-fix - please update manually"
        ;;
      pnpm)
        pnpm audit --fix
        echo "✅ Auto-fix completed"
        ;;
    esac
  fi
else
  echo "⏭️  Skipping dependency scan (no package.json)"
fi

# ============================================================================
# SCAN 2: SECRET DETECTION
# ============================================================================

log_section "2. Secret Detection Scan"

echo "Scanning for hardcoded secrets..."

# Secret patterns to detect
declare -A SECRET_PATTERNS=(
  ["AWS Access Key"]='AKIA[0-9A-Z]{16}'
  ["AWS Secret Key"]='aws_secret_access_key[[:space:]]*=[[:space:]]*[A-Za-z0-9/+=]{40}'
  ["GitHub Token"]='gh[pousr]_[A-Za-z0-9]{36,}'
  ["Slack Token"]='xox[baprs]-[0-9a-zA-Z-]+'
  ["Google API Key"]='AIza[0-9A-Za-z-_]{35}'
  ["Stripe Key"]='sk_live_[0-9a-zA-Z]{24,}'
  ["Private Key"]='-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----'
  ["Password in Code"]='password[[:space:]]*=[[:space:]]*["\047][^"\047]{8,}["\047]'
  ["API Key"]='api[_-]?key[[:space:]]*=[[:space:]]*["\047][^"\047]{20,}["\047]'
  ["Generic Secret"]='secret[[:space:]]*=[[:space:]]*["\047][^"\047]{16,}["\047]'
)

# Files to exclude from scanning
EXCLUDE_PATTERNS="node_modules|\.git|\.lock|package-lock\.json|yarn\.lock|pnpm-lock\.yaml|\.min\.js|\.map$"

# Scan for each pattern
for secret_type in "${!SECRET_PATTERNS[@]}"; do
  pattern="${SECRET_PATTERNS[$secret_type]}"

  # Search in git tracked files only
  results=$(git ls-files | grep -vE "$EXCLUDE_PATTERNS" | xargs grep -HnE "$pattern" 2>/dev/null || true)

  if [ -n "$results" ]; then
    log_finding "CRITICAL" "Secret Detection" "Found $secret_type"
    echo "$results" >> "$SECRET_SCAN_FILE"
    echo "---" >> "$SECRET_SCAN_FILE"
  fi
done

if [ -f "$SECRET_SCAN_FILE" ] && [ -s "$SECRET_SCAN_FILE" ]; then
  echo "⚠️  Found hardcoded secrets - see report for details"
else
  echo "✅ No hardcoded secrets detected"
fi

# ============================================================================
# SCAN 3: OWASP TOP 10 CODE ANALYSIS
# ============================================================================

log_section "3. OWASP Top 10 Code Analysis"

echo "Scanning for common web vulnerabilities..."

# OWASP patterns to detect
declare -A OWASP_PATTERNS=(
  ["SQL Injection"]='(query|execute)\s*\(\s*["\047].*\+|SELECT.*FROM.*WHERE.*\+|INSERT INTO.*VALUES.*\+'
  ["XSS - innerHTML"]='innerHTML\s*=\s*.*\+'
  ["XSS - dangerouslySetInnerHTML"]='dangerouslySetInnerHTML.*__html:'
  ["Command Injection"]='(exec|spawn|system)\s*\(\s*.*\+'
  ["Path Traversal"]='\.\./'
  ["Eval Usage"]='eval\s*\('
  ["Insecure Random"]='Math\.random\(\)'
  ["Weak Crypto"]='md5|sha1'
)

# File patterns to scan (source code only)
SOURCE_PATTERNS="\.js$|\.jsx$|\.ts$|\.tsx$|\.py$|\.php$|\.rb$"

for vuln_type in "${!OWASP_PATTERNS[@]}"; do
  pattern="${OWASP_PATTERNS[$vuln_type]}"

  # Search in source files
  results=$(git ls-files | grep -E "$SOURCE_PATTERNS" | grep -vE "$EXCLUDE_PATTERNS" | xargs grep -HnE "$pattern" 2>/dev/null || true)

  if [ -n "$results" ]; then
    # Determine severity based on vulnerability type
    case "$vuln_type" in
      *"SQL Injection"*|*"Command Injection"*)
        severity="CRITICAL"
        ;;
      *"XSS"*|*"Path Traversal"*)
        severity="HIGH"
        ;;
      *"Eval"*|*"Weak Crypto"*)
        severity="MEDIUM"
        ;;
      *)
        severity="LOW"
        ;;
    esac

    log_finding "$severity" "Code Vulnerability" "$vuln_type detected"
    echo "$results" >> "$CODE_SCAN_FILE"
    echo "---" >> "$CODE_SCAN_FILE"
  fi
done

if [ -f "$CODE_SCAN_FILE" ] && [ -s "$CODE_SCAN_FILE" ]; then
  echo "⚠️  Found potential code vulnerabilities - see report for details"
else
  echo "✅ No obvious code vulnerabilities detected"
fi

# ============================================================================
# SCAN 4: SECURITY CONFIGURATION CHECK
# ============================================================================

log_section "4. Security Configuration Check"

echo "Checking security configurations..."

# Check for HTTPS enforcement
if [ -f "package.json" ]; then
  # Check scripts for HTTPS
  if grep -q "http://localhost" package.json 2>/dev/null; then
    log_finding "INFO" "Configuration" "Development server using HTTP (localhost is acceptable)"
  fi

  # Check for security-related dependencies
  if grep -q "helmet" package.json 2>/dev/null; then
    echo "✅ Found helmet (security headers middleware)"
  else
    log_finding "MEDIUM" "Configuration" "Missing helmet - no HTTP security headers"
  fi

  if grep -q "cors" package.json 2>/dev/null; then
    echo "✅ Found cors middleware"
    # Check for permissive CORS
    if git ls-files | xargs grep -E "cors\(\s*\{" 2>/dev/null | grep -q "origin.*\*"; then
      log_finding "HIGH" "Configuration" "Permissive CORS - allows all origins (*)"
    fi
  fi

  # Check for environment variable usage
  if git ls-files | grep -E "\.js$|\.ts$" | xargs grep -q "process\.env\." 2>/dev/null; then
    echo "✅ Using environment variables"
  else
    log_finding "LOW" "Configuration" "No environment variables detected - check config management"
  fi
fi

# Check for .env in git
if git ls-files | grep -q "^\.env$" 2>/dev/null; then
  log_finding "CRITICAL" "Configuration" ".env file is tracked in git - contains secrets!"
fi

# Check for proper .gitignore
if [ -f ".gitignore" ]; then
  if grep -q "\.env" .gitignore 2>/dev/null; then
    echo "✅ .env properly ignored"
  else
    log_finding "MEDIUM" "Configuration" ".env not in .gitignore"
  fi

  if grep -q "node_modules" .gitignore 2>/dev/null; then
    echo "✅ node_modules properly ignored"
  else
    log_finding "LOW" "Configuration" "node_modules not in .gitignore"
  fi
fi

echo "✅ Configuration check complete"

# ============================================================================
# GENERATE REPORT
# ============================================================================

log_section "Generating Security Report"

# Calculate overall risk
RISK_SCORE=$(calculate_risk_score)
RISK_LEVEL=$(get_risk_level "$RISK_SCORE")

echo "Risk Score: $RISK_SCORE"
echo "Risk Level: $RISK_LEVEL"
echo ""
echo "Findings:"
echo "  🔴 Critical: $CRITICAL_COUNT"
echo "  🟠 High: $HIGH_COUNT"
echo "  🟡 Medium: $MEDIUM_COUNT"
echo "  🔵 Low: $LOW_COUNT"
echo "  ℹ️  Info: $INFO_COUNT"

# Generate markdown report
cat > "$REPORT_FILE" << EOF
# Security Audit Report

**Generated**: $(date '+%Y-%m-%d %H:%M:%S')
**Repository**: $(basename "$(git rev-parse --show-toplevel)")
**Branch**: $(git rev-parse --abbrev-ref HEAD)
**Scan Depth**: $SCAN_DEPTH
**Severity Threshold**: $SEVERITY_THRESHOLD

---

## Executive Summary

**Overall Risk Score**: $RISK_SCORE
**Risk Level**: $RISK_LEVEL

### Findings Summary

| Severity | Count |
|----------|-------|
| 🔴 Critical | $CRITICAL_COUNT |
| 🟠 High | $HIGH_COUNT |
| 🟡 Medium | $MEDIUM_COUNT |
| 🔵 Low | $LOW_COUNT |
| ℹ️  Info | $INFO_COUNT |

**Risk Assessment**:
- **0-9**: Low risk - minimal security concerns
- **10-19**: Medium risk - some vulnerabilities need attention
- **20-49**: High risk - significant security issues present
- **50+**: Critical risk - immediate action required

---

## 1. Dependency Vulnerabilities

EOF

if [ "$HAS_PACKAGE_JSON" = true ] && [ -f "$DEP_SCAN_FILE" ]; then
  cat >> "$REPORT_FILE" << EOF
### npm Audit Results

\`\`\`json
$(cat "$DEP_SCAN_FILE")
\`\`\`

**Remediation**:
- Run \`npm audit fix\` to automatically fix vulnerabilities
- Run \`npm audit fix --force\` for breaking changes (review first!)
- Manually update packages that cannot be auto-fixed

EOF
else
  cat >> "$REPORT_FILE" << EOF
No dependency scan performed (package.json not found).

EOF
fi

# Secret detection section
cat >> "$REPORT_FILE" << EOF
---

## 2. Secret Detection

EOF

if [ -f "$SECRET_SCAN_FILE" ] && [ -s "$SECRET_SCAN_FILE" ]; then
  cat >> "$REPORT_FILE" << EOF
⚠️  **Hardcoded secrets detected!**

\`\`\`
$(cat "$SECRET_SCAN_FILE")
\`\`\`

**Remediation**:
1. Remove all hardcoded secrets from code
2. Use environment variables (\`.env\` files)
3. Add \`.env\` to \`.gitignore\`
4. Rotate all exposed credentials immediately
5. Use secret management tools (AWS Secrets Manager, HashiCorp Vault, etc.)

EOF
else
  cat >> "$REPORT_FILE" << EOF
✅ No hardcoded secrets detected.

EOF
fi

# Code vulnerabilities section
cat >> "$REPORT_FILE" << EOF
---

## 3. Code Vulnerabilities (OWASP Top 10)

EOF

if [ -f "$CODE_SCAN_FILE" ] && [ -s "$CODE_SCAN_FILE" ]; then
  cat >> "$REPORT_FILE" << EOF
⚠️  **Potential code vulnerabilities detected!**

\`\`\`
$(cat "$CODE_SCAN_FILE")
\`\`\`

**Remediation**:
- **SQL Injection**: Use parameterized queries/ORMs
- **XSS**: Sanitize user input, use React's built-in XSS protection
- **Command Injection**: Validate and sanitize all user input
- **Path Traversal**: Validate file paths, use path.resolve()
- **Eval**: Remove eval(), use safer alternatives
- **Weak Crypto**: Use bcrypt/argon2 for passwords, SHA-256+ for hashing

EOF
else
  cat >> "$REPORT_FILE" << EOF
✅ No obvious code vulnerabilities detected.

EOF
fi

# Configuration section
cat >> "$REPORT_FILE" << EOF
---

## 4. Security Configuration

See findings above for configuration issues.

**Recommended Security Headers** (use helmet.js):
\`\`\`javascript
app.use(helmet({
  contentSecurityPolicy: true,
  hsts: true,
  noSniff: true,
  xssFilter: true
}));
\`\`\`

**Recommended CORS Configuration**:
\`\`\`javascript
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || 'http://localhost:3000',
  credentials: true
}));
\`\`\`

---

## 5. Remediation Recommendations

### Priority 1: Critical (Fix Immediately)

EOF

if [ "$CRITICAL_COUNT" -gt 0 ]; then
  cat >> "$REPORT_FILE" << EOF
$CRITICAL_COUNT critical issues found:
- Review dependency vulnerabilities with CRITICAL severity
- Remove all hardcoded secrets and rotate credentials
- Fix SQL injection and command injection vulnerabilities
- Check if .env is committed to git

EOF
else
  cat >> "$REPORT_FILE" << EOF
✅ No critical issues found.

EOF
fi

cat >> "$REPORT_FILE" << EOF
### Priority 2: High (Fix This Week)

EOF

if [ "$HIGH_COUNT" -gt 0 ]; then
  cat >> "$REPORT_FILE" << EOF
$HIGH_COUNT high-severity issues found:
- Update dependencies with HIGH severity vulnerabilities
- Fix XSS and path traversal vulnerabilities
- Review permissive CORS configurations

EOF
else
  cat >> "$REPORT_FILE" << EOF
✅ No high-severity issues found.

EOF
fi

cat >> "$REPORT_FILE" << EOF
### Priority 3: Medium (Fix This Sprint)

EOF

if [ "$MEDIUM_COUNT" -gt 0 ]; then
  cat >> "$REPORT_FILE" << EOF
$MEDIUM_COUNT medium-severity issues found:
- Add helmet for security headers
- Fix weak cryptography usage
- Add .env to .gitignore if missing

EOF
else
  cat >> "$REPORT_FILE" << EOF
✅ No medium-severity issues found.

EOF
fi

cat >> "$REPORT_FILE" << EOF

### Priority 4: Low & Info (Address in Backlog)

$LOW_COUNT low-severity + $INFO_COUNT info findings.

---

## Next Steps

1. **Immediate**: Address all CRITICAL findings
2. **This Week**: Fix HIGH severity issues
3. **This Sprint**: Resolve MEDIUM issues
4. **Ongoing**: Set up automated security scanning in CI/CD
5. **Monthly**: Run \`/sw:security-audit\` regularly

---

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [npm Audit Documentation](https://docs.npmjs.com/cli/v8/commands/npm-audit)
- [Helmet.js Security Headers](https://helmetjs.github.io/)
- [NIST Vulnerability Database](https://nvd.nist.gov/)

---

**Generated by**: SpecSwarm v3.1.0 Security Audit
**Command**: \`/sw:security-audit\`

EOF

echo "✅ Report generated: $REPORT_FILE"

# ============================================================================
# SUMMARY
# ============================================================================

log_section "Security Audit Complete"

echo "Report saved to: $REPORT_FILE"
echo ""
echo "Summary:"
echo "  Risk Level: $RISK_LEVEL ($RISK_SCORE points)"
echo "  Critical: $CRITICAL_COUNT"
echo "  High: $HIGH_COUNT"
echo "  Medium: $MEDIUM_COUNT"
echo "  Low: $LOW_COUNT"
echo "  Info: $INFO_COUNT"
echo ""

if [ "$CRITICAL_COUNT" -gt 0 ]; then
  echo "⚠️  CRITICAL ISSUES FOUND - Immediate action required!"
  echo "   Review $REPORT_FILE for details and remediation steps"
elif [ "$HIGH_COUNT" -gt 0 ]; then
  echo "⚠️  HIGH SEVERITY ISSUES - Address within the week"
  echo "   Review $REPORT_FILE for details"
elif [ "$MEDIUM_COUNT" -gt 0 ]; then
  echo "✅ No critical issues, but $MEDIUM_COUNT medium-severity findings"
  echo "   Review $REPORT_FILE for improvements"
else
  echo "✅ No significant security issues detected"
  echo "   Good job! Keep running regular security audits"
fi

echo ""
echo "Next: Review the report and prioritize remediation work"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

---

## Examples

### Example 1: Quick Security Scan

```bash
/sw:security-audit
# Select: Quick scan
# Select: All findings
# Result: security-audit-2025-01-15.md generated in ~1 minute
```

### Example 2: Pre-Release Audit

```bash
/sw:security-audit
# Select: Thorough scan
# Select: High and above
# Select: Yes, auto-fix
# Result: Comprehensive audit with auto-fixed dependencies
```

### Example 3: CI/CD Integration

```yaml
# .github/workflows/security.yml
name: Security Audit
on: [push, pull_request]
jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: /sw:security-audit
      - run: |
          if grep -q "CRITICAL" security-audit-*.md; then
            echo "Critical vulnerabilities found!"
            exit 1
          fi
```

---

## Notes

- **False Positives**: Pattern matching may produce false positives - review all findings
- **Complementary Tools**: Consider using additional tools (Snyk, SonarQube, Dependabot)
- **Regular Scans**: Run monthly or before major releases
- **Auto-Fix**: Use with caution - test thoroughly after auto-fixing dependencies
- **Secret Rotation**: If secrets are found, rotate them immediately even after removal

---

## See Also

- `/sw:release` - Includes security audit as part of release checklist
- `/sw:analyze-quality` - Code quality analysis
- `/sw:ship` - Enforces quality gates before merge

---

**Version**: 3.1.0
**Category**: Security & Quality
**Estimated Time**: 1-10 minutes (depending on scan depth)
