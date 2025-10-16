#!/bin/bash
#
# SSR Pattern Validator
# Detects server-side rendering architectural issues
# Prevents Bug 913-type problems (hardcoded URLs, relative URLs in SSR contexts)
#
# Created: 2025-10-15
# Based on learnings from Bug 913 - Server-side loader fetch failure
#

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global counters
TOTAL_ISSUES=0
HARDCODED_URLS=0
RELATIVE_URLS=0
MISSING_HELPERS=0

# Detect SSR framework
detect_ssr_framework() {
    local repo_root="${1:-$(pwd)}"
    local framework="none"

    # Check package.json for frameworks
    if [ -f "$repo_root/package.json" ]; then
        if grep -q '"react-router"' "$repo_root/package.json" 2>/dev/null; then
            # Check if framework mode (has react-router.config.ts)
            if [ -f "$repo_root/react-router.config.ts" ]; then
                framework="react-router-v7"
            fi
        elif grep -q '"@remix-run/react"' "$repo_root/package.json" 2>/dev/null; then
            framework="remix"
        elif grep -q '"next"' "$repo_root/package.json" 2>/dev/null; then
            framework="nextjs"
        fi
    fi

    echo "$framework"
}

# Find loader and action files
find_ssr_files() {
    local repo_root="${1:-$(pwd)}"
    local framework="$2"
    local files=()

    case "$framework" in
        "react-router-v7")
            # React Router v7: app/pages/*.tsx, app/routes/*.tsx
            if [ -d "$repo_root/app/pages" ]; then
                mapfile -t page_files < <(find "$repo_root/app/pages" -name "*.tsx" -o -name "*.ts" 2>/dev/null || true)
                files+=("${page_files[@]}")
            fi
            if [ -d "$repo_root/app/routes" ]; then
                mapfile -t route_files < <(find "$repo_root/app/routes" -name "*.tsx" -o -name "*.ts" 2>/dev/null || true)
                files+=("${route_files[@]}")
            fi
            ;;
        "remix")
            # Remix: app/routes/*.tsx
            if [ -d "$repo_root/app/routes" ]; then
                mapfile -t remix_files < <(find "$repo_root/app/routes" -name "*.tsx" -o -name "*.ts" 2>/dev/null || true)
                files+=("${remix_files[@]}")
            fi
            ;;
        "nextjs")
            # Next.js: app/ directory (App Router) or pages/ (Pages Router)
            if [ -d "$repo_root/app" ]; then
                mapfile -t app_files < <(find "$repo_root/app" -name "page.tsx" -o -name "layout.tsx" -o -name "route.ts" 2>/dev/null || true)
                files+=("${app_files[@]}")
            fi
            if [ -d "$repo_root/pages" ]; then
                mapfile -t page_files < <(find "$repo_root/pages" -name "*.tsx" -o -name "*.ts" 2>/dev/null || true)
                files+=("${page_files[@]}")
            fi
            ;;
    esac

    printf '%s\n' "${files[@]}"
}

# Check for hardcoded localhost URLs
check_hardcoded_urls() {
    local file="$1"
    local issues=()

    # Pattern: fetch('http://localhost:
    # Pattern: fetch("http://localhost:
    # Pattern: fetch(`http://localhost:
    while IFS= read -r line_num; do
        local line_content
        line_content=$(sed -n "${line_num}p" "$file")
        issues+=("$file:$line_num:Hardcoded localhost URL: $line_content")
        ((HARDCODED_URLS++))
        ((TOTAL_ISSUES++))
    done < <(grep -n "fetch.*['\"\`]https\?://localhost:" "$file" 2>/dev/null | cut -d: -f1 || true)

    # Pattern: fetch('http://
    # Pattern: fetch("http://
    # But exclude environment variables like ${API_URL}
    while IFS= read -r line_num; do
        local line_content
        line_content=$(sed -n "${line_num}p" "$file")
        # Skip if it contains env variables
        if ! echo "$line_content" | grep -q '\${'; then
            issues+=("$file:$line_num:Hardcoded absolute URL: $line_content")
            ((HARDCODED_URLS++))
            ((TOTAL_ISSUES++))
        fi
    done < <(grep -n "fetch.*['\"\`]https\?://[^']" "$file" 2>/dev/null | grep -v "localhost" | cut -d: -f1 || true)

    printf '%s\n' "${issues[@]}"
}

# Check for relative URLs in loader/action contexts
check_relative_urls_in_ssr() {
    local file="$1"
    local issues=()

    # First, check if file has loader or action exports
    if ! grep -q "export.*function.*loader\|export.*function.*action\|export.*async.*loader\|export.*async.*action" "$file" 2>/dev/null; then
        # No loader/action in this file, skip
        return 0
    fi

    # Now check for fetch calls with relative URLs inside loader/action functions
    # Pattern: fetch('/api/
    # Pattern: fetch("/api/
    # This is problematic in SSR context (Node.js) but fine in client context

    # Extract loader function content
    local in_loader=false
    local brace_count=0
    local line_num=0

    while IFS= read -r line; do
        ((line_num++))

        # Check if entering loader or action
        if echo "$line" | grep -q "export.*function.*loader\|export.*async.*loader\|export.*function.*action\|export.*async.*action"; then
            in_loader=true
            brace_count=0
        fi

        # Count braces to track function scope
        if [ "$in_loader" = true ]; then
            local open_braces
            local close_braces
            open_braces=$(echo "$line" | grep -o "{" | wc -l)
            close_braces=$(echo "$line" | grep -o "}" | wc -l)
            brace_count=$((brace_count + open_braces - close_braces))

            # Check for relative URL fetch inside loader/action
            if echo "$line" | grep -q "fetch.*['\"\`]/"; then
                # Found relative URL fetch
                issues+=("$file:$line_num:Relative URL in SSR context (loader/action): $line")
                ((RELATIVE_URLS++))
                ((TOTAL_ISSUES++))
            fi

            # Exit loader/action when braces balance
            if [ $brace_count -eq 0 ] && echo "$line" | grep -q "}"; then
                in_loader=false
            fi
        fi
    done < "$file"

    printf '%s\n' "${issues[@]}"
}

# Check for environment-aware helper usage
check_helper_usage() {
    local file="$1"
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null || dirname "$file")

    # Check if helper exists
    local helper_exists=false
    if [ -f "$repo_root/app/utils/api.ts" ] || [ -f "$repo_root/src/utils/api.ts" ] || [ -f "$repo_root/lib/api.ts" ]; then
        helper_exists=true
    fi

    if [ "$helper_exists" = false ]; then
        # No helper exists, but check if file has fetch calls
        if grep -q "fetch.*http" "$file" 2>/dev/null; then
            echo "$file:0:Missing environment-aware API helper (e.g., app/utils/api.ts with getApiUrl())"
            ((MISSING_HELPERS++))
            ((TOTAL_ISSUES++))
        fi
    else
        # Helper exists, check if file imports it
        if grep -q "fetch.*['\"\`]https\?://" "$file" 2>/dev/null; then
            if ! grep -q "import.*getApiUrl\|from.*api" "$file" 2>/dev/null; then
                echo "$file:0:Hardcoded URL found but not using getApiUrl() helper"
                ((MISSING_HELPERS++))
                ((TOTAL_ISSUES++))
            fi
        fi
    fi
}

# Generate validation report
generate_report() {
    local framework="$1"
    shift
    local all_issues=("$@")

    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo -e "${BLUE}🔍 SSR Pattern Validation Report${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo ""
    echo "Framework Detected: $framework"
    echo "Total Issues Found: $TOTAL_ISSUES"
    echo ""

    if [ $TOTAL_ISSUES -eq 0 ]; then
        echo -e "${GREEN}✓ No SSR architectural issues detected${NC}"
        echo -e "${GREEN}✓ All API calls follow best practices${NC}"
        echo ""
        return 0
    fi

    echo -e "${YELLOW}⚠️  Issues Detected:${NC}"
    echo ""

    # Hardcoded URLs
    if [ $HARDCODED_URLS -gt 0 ]; then
        echo -e "${RED}❌ Hardcoded URLs: $HARDCODED_URLS${NC}"
        echo "   Files with hardcoded localhost or absolute URLs"
        echo ""
    fi

    # Relative URLs in SSR
    if [ $RELATIVE_URLS -gt 0 ]; then
        echo -e "${RED}❌ Relative URLs in SSR Context: $RELATIVE_URLS${NC}"
        echo "   Loaders/actions using relative URLs (will fail in Node.js)"
        echo ""
    fi

    # Missing helpers
    if [ $MISSING_HELPERS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Missing Environment-Aware Helpers: $MISSING_HELPERS${NC}"
        echo "   Files not using getApiUrl() or similar pattern"
        echo ""
    fi

    echo -e "${BLUE}Detailed Issues:${NC}"
    echo ""
    for issue in "${all_issues[@]}"; do
        echo "  • $issue"
    done
    echo ""

    # Recommendations
    echo -e "${BLUE}📋 Recommendations:${NC}"
    echo ""

    if [ $HARDCODED_URLS -gt 0 ] || [ $RELATIVE_URLS -gt 0 ]; then
        echo "1. Create environment-aware API helper:"
        echo ""
        echo "   File: app/utils/api.ts"
        echo ""
        echo "   export function getApiUrl(path: string): string {"
        echo "     const base = typeof window !== 'undefined'"
        echo "       ? '' // Client: use relative URLs (Vite proxy)"
        echo "       : process.env.API_BASE_URL || 'http://localhost:3000'; // Server: absolute URLs"
        echo "     return \`\${base}\${path}\`;"
        echo "   }"
        echo ""
        echo "2. Replace all fetch calls:"
        echo ""
        echo "   ❌ fetch('http://localhost:3000/api/tweets')"
        echo "   ❌ fetch('/api/tweets') // fails in SSR"
        echo "   ✅ fetch(getApiUrl('/api/tweets'))"
        echo ""
    fi

    if [ $MISSING_HELPERS -gt 0 ]; then
        echo "3. Import and use helper in all loaders/actions:"
        echo ""
        echo "   import { getApiUrl } from '../utils/api';"
        echo ""
    fi

    echo -e "${YELLOW}⚠️  SSR validation failed with $TOTAL_ISSUES issue(s)${NC}"
    echo ""

    return 1
}

# Main validation function
validate_ssr_patterns() {
    local repo_root="${1:-$(pwd)}"

    echo ""
    echo -e "${BLUE}🔍 Validating SSR Patterns...${NC}"
    echo ""

    # Detect framework
    local framework
    framework=$(detect_ssr_framework "$repo_root")

    if [ "$framework" = "none" ]; then
        echo -e "${GREEN}ℹ️  No SSR framework detected (React Router v7, Remix, or Next.js)${NC}"
        echo -e "${GREEN}✓ SSR validation skipped${NC}"
        echo ""
        return 0
    fi

    echo "✓ Framework detected: $framework"
    echo ""

    # Find SSR files
    local ssr_files
    mapfile -t ssr_files < <(find_ssr_files "$repo_root" "$framework")

    if [ ${#ssr_files[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No loader/action files found${NC}"
        echo ""
        return 0
    fi

    echo "✓ Found ${#ssr_files[@]} loader/action files to validate"
    echo ""

    # Collect all issues
    local all_issues=()

    # Validate each file
    for file in "${ssr_files[@]}"; do
        if [ -f "$file" ]; then
            # Check hardcoded URLs
            mapfile -t hardcoded < <(check_hardcoded_urls "$file")
            all_issues+=("${hardcoded[@]}")

            # Check relative URLs in SSR context
            mapfile -t relative < <(check_relative_urls_in_ssr "$file")
            all_issues+=("${relative[@]}")

            # Check helper usage
            mapfile -t helpers < <(check_helper_usage "$file")
            all_issues+=("${helpers[@]}")
        fi
    done

    # Generate report
    generate_report "$framework" "${all_issues[@]}"
}

# If script is executed directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    validate_ssr_patterns "$@"
fi
