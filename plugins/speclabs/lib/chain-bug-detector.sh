#!/bin/bash
#
# Chain Bug Detector
# Detects when bug fixes introduce new bugs
# Prevents Bug 912 → Bug 913 scenarios
#
# Created: 2025-10-15 (Phase 3)
#

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Detect new issues introduced by bug fix
detect_chain_bugs() {
    local repo_root="${1:-$(pwd)}"
    local before_commit="${2:-HEAD~1}"
    local after_commit="${3:-HEAD}"

    echo -e "${YELLOW}🔍 Checking for chain bugs...${NC}"
    echo ""

    # 1. Compare test results
    local tests_before tests_after
    tests_before=$(git show "$before_commit:memory/metrics.json" 2>/dev/null | grep -o '"tests_passing":[0-9]*' | grep -o '[0-9]*' || echo "0")
    tests_after=$(grep -o '"tests_passing":[0-9]*' "$repo_root/memory/metrics.json" 2>/dev/null | grep -o '[0-9]*' || echo "0")

    # 2. Run SSR validator
    local ssr_issues=0
    if bash "$repo_root/plugins/specswarm/lib/ssr-validator.sh" 2>/dev/null | grep -q "Total Issues:"; then
        ssr_issues=$(bash "$repo_root/plugins/specswarm/lib/ssr-validator.sh" 2>/dev/null | grep "Total Issues:" | grep -oE '[0-9]+' || echo "0")
    fi

    # 3. Check for new TypeScript errors
    local ts_errors=0
    if command -v npx &> /dev/null; then
        ts_errors=$(npx tsc --noEmit 2>&1 | grep -c "error TS" || echo "0")
    fi

    # 4. Analyze changes
    local new_issues=0

    if [ "$tests_after" -lt "$tests_before" ]; then
        new_issues=$((new_issues + 1))
        echo -e "${RED}⚠️  Tests decreased: $tests_before → $tests_after${NC}"
    fi

    if [ "$ssr_issues" -gt 0 ]; then
        new_issues=$((new_issues + 1))
        echo -e "${RED}⚠️  SSR issues detected: $ssr_issues${NC}"
    fi

    if [ "$ts_errors" -gt 0 ]; then
        new_issues=$((new_issues + 1))
        echo -e "${RED}⚠️  TypeScript errors: $ts_errors${NC}"
    fi

    # 5. Generate report
    echo ""
    if [ "$new_issues" -gt 0 ]; then
        echo -e "${RED}═══════════════════════════════════${NC}"
        echo -e "${RED}⛓️  CHAIN BUG DETECTED${NC}"
        echo -e "${RED}═══════════════════════════════════${NC}"
        echo ""
        echo "This bug fix may have introduced $new_issues new issue(s)."
        echo ""
        echo "Recommendations:"
        echo "1. Review the fix for unintended side effects"
        echo "2. Run /speclab:analyze-quality for full analysis"
        echo "3. Consider using /debug-coordinate:coordinate for complex fixes"
        echo ""
        return 1
    else
        echo -e "${GREEN}✓ No chain bugs detected${NC}"
        return 0
    fi
}

# Check if fix created architectural debt
check_architectural_debt() {
    local repo_root="${1:-$(pwd)}"

    # Count anti-patterns
    local useeffect_fetch=$(grep -r "useEffect.*fetch" "$repo_root/app" "$repo_root/src" 2>/dev/null | wc -l || echo "0")
    local hardcoded_urls=$(grep -r "http://localhost" "$repo_root/app" "$repo_root/src" 2>/dev/null | wc -l || echo "0")

    local debt_score=0

    if [ "$useeffect_fetch" -gt 0 ]; then
        debt_score=$((debt_score + useeffect_fetch * 2))
    fi

    if [ "$hardcoded_urls" -gt 0 ]; then
        debt_score=$((debt_score + hardcoded_urls * 3))
    fi

    if [ "$debt_score" -gt 10 ]; then
        echo "WARNING: High architectural debt ($debt_score points)"
        return 1
    fi

    return 0
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    detect_chain_bugs "$@"
fi
