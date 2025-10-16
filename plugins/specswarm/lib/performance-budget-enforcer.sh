#!/bin/bash
#
# Performance Budget Enforcer
# Enforces performance budgets defined in quality-standards.md
# Prevents deployments that violate performance thresholds
#
# Created: 2025-10-15 (Phase 3)
#

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Load performance budgets from quality-standards.md
load_budgets() {
    local repo_root="${1:-$(pwd)}"
    local standards_file="$repo_root/memory/quality-standards.md"

    # Default budgets
    MAX_BUNDLE_SIZE=500          # KB
    MAX_INITIAL_LOAD=1000        # KB
    MAX_PAGE_LOAD_TIME=3000      # ms
    MAX_TIME_TO_INTERACTIVE=5000 # ms
    MAX_FIRST_CONTENTFUL_PAINT=2000 # ms

    if [ -f "$standards_file" ]; then
        # Try to extract budgets from quality-standards.md
        if grep -q "max_bundle_size" "$standards_file" 2>/dev/null; then
            MAX_BUNDLE_SIZE=$(grep "max_bundle_size" "$standards_file" | grep -oE '[0-9]+' | head -1)
        fi
        if grep -q "max_initial_load" "$standards_file" 2>/dev/null; then
            MAX_INITIAL_LOAD=$(grep "max_initial_load" "$standards_file" | grep -oE '[0-9]+' | head -1)
        fi
        if grep -q "max_page_load_time" "$standards_file" 2>/dev/null; then
            MAX_PAGE_LOAD_TIME=$(grep "max_page_load_time" "$standards_file" | grep -oE '[0-9]+' | head -1)
        fi
    fi

    # Export for use in other functions
    export MAX_BUNDLE_SIZE
    export MAX_INITIAL_LOAD
    export MAX_PAGE_LOAD_TIME
    export MAX_TIME_TO_INTERACTIVE
    export MAX_FIRST_CONTENTFUL_PAINT
}

# Enforce bundle size budget
enforce_bundle_budget() {
    local repo_root="${1:-$(pwd)}"
    local violations=0

    echo -e "${BLUE}📦 Enforcing Bundle Size Budget${NC}"
    echo "Budget: ${MAX_BUNDLE_SIZE}KB per bundle"
    echo ""

    # Detect build directories
    local build_dirs=()
    if [ -d "$repo_root/dist" ]; then
        build_dirs+=("$repo_root/dist")
    fi
    if [ -d "$repo_root/build" ]; then
        build_dirs+=("$repo_root/build")
    fi
    if [ -d "$repo_root/.next" ]; then
        build_dirs+=("$repo_root/.next")
    fi

    if [ ${#build_dirs[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No build directory found${NC}"
        echo "Run build command first"
        return 1
    fi

    # Check each bundle
    local total_size=0
    for dir in "${build_dirs[@]}"; do
        while IFS= read -r bundle; do
            if [ -f "$bundle" ]; then
                local size_bytes
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    size_bytes=$(stat -f%z "$bundle" 2>/dev/null || echo "0")
                else
                    size_bytes=$(stat -c%s "$bundle" 2>/dev/null || echo "0")
                fi
                local size_kb=$((size_bytes / 1024))
                total_size=$((total_size + size_kb))

                if [ "$size_kb" -gt "$MAX_BUNDLE_SIZE" ]; then
                    violations=$((violations + 1))
                    local relative_path="${bundle#$repo_root/}"
                    local formatted_size
                    if [ "$size_kb" -gt 1024 ]; then
                        formatted_size="$(awk "BEGIN {printf \"%.2f\", $size_kb/1024}")MB"
                    else
                        formatted_size="${size_kb}KB"
                    fi
                    echo -e "${RED}✗ $relative_path: ${formatted_size} (exceeds ${MAX_BUNDLE_SIZE}KB)${NC}"
                fi
            fi
        done < <(find "$dir" -type f \( -name "*.js" -o -name "*.mjs" -o -name "*.cjs" \) 2>/dev/null || true)
    done

    echo ""
    if [ "$violations" -gt 0 ]; then
        echo -e "${RED}❌ Bundle Budget Violated${NC}"
        echo "$violations bundle(s) exceed ${MAX_BUNDLE_SIZE}KB limit"
        return 1
    else
        echo -e "${GREEN}✓ All bundles within budget${NC}"
        return 0
    fi
}

# Enforce initial load budget
enforce_initial_load_budget() {
    local repo_root="${1:-$(pwd)}"

    echo ""
    echo -e "${BLUE}🚀 Enforcing Initial Load Budget${NC}"
    echo "Budget: ${MAX_INITIAL_LOAD}KB for initial load"
    echo ""

    # Calculate initial load size (all bundles in main chunk)
    local build_dirs=()
    if [ -d "$repo_root/dist" ]; then
        build_dirs+=("$repo_root/dist")
    fi
    if [ -d "$repo_root/build" ]; then
        build_dirs+=("$repo_root/build")
    fi

    if [ ${#build_dirs[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No build directory found${NC}"
        return 1
    fi

    local initial_load_size=0
    for dir in "${build_dirs[@]}"; do
        # Find main/index bundles (typically loaded initially)
        while IFS= read -r bundle; do
            if [[ "$bundle" =~ (index|main|app|client)\.(js|mjs|cjs)$ ]]; then
                if [ -f "$bundle" ]; then
                    local size_bytes
                    if [[ "$OSTYPE" == "darwin"* ]]; then
                        size_bytes=$(stat -f%z "$bundle" 2>/dev/null || echo "0")
                    else
                        size_bytes=$(stat -c%s "$bundle" 2>/dev/null || echo "0")
                    fi
                    local size_kb=$((size_bytes / 1024))
                    initial_load_size=$((initial_load_size + size_kb))
                fi
            fi
        done < <(find "$dir" -type f \( -name "*.js" -o -name "*.mjs" -o -name "*.cjs" \) 2>/dev/null || true)
    done

    echo "Initial Load Size: ${initial_load_size}KB"

    if [ "$initial_load_size" -gt "$MAX_INITIAL_LOAD" ]; then
        echo -e "${RED}❌ Initial Load Budget Violated${NC}"
        echo "Exceeds ${MAX_INITIAL_LOAD}KB limit by $((initial_load_size - MAX_INITIAL_LOAD))KB"
        echo ""
        echo "Recommendations:"
        echo "1. Implement code splitting"
        echo "2. Use dynamic imports for routes"
        echo "3. Defer non-critical JavaScript"
        return 1
    else
        echo -e "${GREEN}✓ Initial load within budget${NC}"
        return 0
    fi
}

# Generate performance budget report
generate_budget_report() {
    local repo_root="${1:-$(pwd)}"
    local bundle_status="$2"
    local initial_load_status="$3"

    echo ""
    echo "═══════════════════════════════════════"
    echo "Performance Budget Report"
    echo "═══════════════════════════════════════"
    echo ""

    echo "Budget Limits:"
    echo "- Max Bundle Size: ${MAX_BUNDLE_SIZE}KB"
    echo "- Max Initial Load: ${MAX_INITIAL_LOAD}KB"
    echo ""

    echo "Enforcement Results:"
    if [ "$bundle_status" -eq 0 ]; then
        echo -e "- Bundle Size: ${GREEN}✓ PASS${NC}"
    else
        echo -e "- Bundle Size: ${RED}✗ FAIL${NC}"
    fi

    if [ "$initial_load_status" -eq 0 ]; then
        echo -e "- Initial Load: ${GREEN}✓ PASS${NC}"
    else
        echo -e "- Initial Load: ${RED}✗ FAIL${NC}"
    fi

    echo ""
    if [ "$bundle_status" -ne 0 ] || [ "$initial_load_status" -ne 0 ]; then
        echo -e "${RED}⛔ Performance Budget Enforcement Failed${NC}"
        echo ""
        echo "Action Required:"
        echo "1. Review bundle composition"
        echo "2. Implement optimizations"
        echo "3. Update budgets in quality-standards.md (if justified)"
        echo "4. Re-run validation after fixes"
        return 1
    else
        echo -e "${GREEN}✅ All Performance Budgets Met${NC}"
        return 0
    fi
}

# Main execution
enforce_performance_budgets() {
    local repo_root="${1:-$(pwd)}"

    echo -e "${BLUE}⚡ Performance Budget Enforcement${NC}"
    echo "═══════════════════════════════════════"
    echo ""

    # Load budgets
    load_budgets "$repo_root"

    # Enforce budgets
    local bundle_status=0
    local initial_load_status=0

    enforce_bundle_budget "$repo_root" || bundle_status=$?
    enforce_initial_load_budget "$repo_root" || initial_load_status=$?

    # Generate report
    generate_budget_report "$repo_root" "$bundle_status" "$initial_load_status"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    enforce_performance_budgets "$@"
fi
