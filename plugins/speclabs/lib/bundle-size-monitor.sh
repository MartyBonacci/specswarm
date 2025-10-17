#!/bin/bash
#
# Bundle Size Monitor
# Tracks bundle sizes and enforces performance budgets
# Prevents large bundles from degrading page load performance
#
# Created: 2025-10-15 (Phase 3)
#

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Performance budgets (in KB)
WARN_THRESHOLD=500    # Warn if bundle > 500KB
CRITICAL_THRESHOLD=1000  # Critical if bundle > 1MB

# Detect build output directory based on framework
detect_build_dir() {
    local repo_root="${1:-$(pwd)}"
    local build_dirs=()

    # Check for various framework build directories
    if [ -d "$repo_root/dist" ]; then
        build_dirs+=("dist")
    fi
    if [ -d "$repo_root/build" ]; then
        build_dirs+=("build")
    fi
    if [ -d "$repo_root/.next" ]; then
        build_dirs+=(".next")
    fi
    if [ -d "$repo_root/out" ]; then
        build_dirs+=("out")
    fi
    if [ -d "$repo_root/public/build" ]; then
        build_dirs+=("public/build")
    fi

    # Return comma-separated list
    IFS=','
    echo "${build_dirs[*]}"
}

# Find all JavaScript bundles
find_bundles() {
    local repo_root="${1:-$(pwd)}"
    local build_dirs="$2"

    IFS=',' read -ra dirs <<< "$build_dirs"

    local bundles=()
    for dir in "${dirs[@]}"; do
        if [ -d "$repo_root/$dir" ]; then
            while IFS= read -r file; do
                bundles+=("$file")
            done < <(find "$repo_root/$dir" -type f \( -name "*.js" -o -name "*.mjs" -o -name "*.cjs" \) 2>/dev/null || true)
        fi
    done

    # Return newline-separated list
    printf '%s\n' "${bundles[@]}"
}

# Get file size in KB
get_size_kb() {
    local file="$1"
    local size_bytes

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        size_bytes=$(stat -f%z "$file" 2>/dev/null || echo "0")
    else
        # Linux
        size_bytes=$(stat -c%s "$file" 2>/dev/null || echo "0")
    fi

    echo $((size_bytes / 1024))
}

# Format size for display
format_size() {
    local size_kb=$1

    if [ "$size_kb" -gt 1024 ]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $size_kb/1024}")MB"
    else
        echo "${size_kb}KB"
    fi
}

# Analyze bundle sizes
analyze_bundles() {
    local repo_root="${1:-$(pwd)}"

    echo -e "${BLUE}📦 Bundle Size Analysis${NC}"
    echo "========================"
    echo ""

    # Detect build directories
    local build_dirs
    build_dirs=$(detect_build_dir "$repo_root")

    if [ -z "$build_dirs" ]; then
        echo -e "${YELLOW}⚠️  No build directory found${NC}"
        echo "Run build command first (e.g., npm run build)"
        return 1
    fi

    echo "Build directories: $build_dirs"
    echo ""

    # Find all bundles
    local bundles
    bundles=$(find_bundles "$repo_root" "$build_dirs")

    if [ -z "$bundles" ]; then
        echo -e "${YELLOW}⚠️  No JavaScript bundles found${NC}"
        return 1
    fi

    # Analyze each bundle
    local total_size=0
    local large_bundles=0
    local critical_bundles=0
    local bundle_details=()

    while IFS= read -r bundle; do
        if [ -f "$bundle" ]; then
            local size_kb
            size_kb=$(get_size_kb "$bundle")
            total_size=$((total_size + size_kb))

            local relative_path="${bundle#$repo_root/}"
            local formatted_size
            formatted_size=$(format_size "$size_kb")

            local status_icon=""
            local status_color="$GREEN"

            if [ "$size_kb" -gt "$CRITICAL_THRESHOLD" ]; then
                status_icon="🔴"
                status_color="$RED"
                critical_bundles=$((critical_bundles + 1))
            elif [ "$size_kb" -gt "$WARN_THRESHOLD" ]; then
                status_icon="🟡"
                status_color="$YELLOW"
                large_bundles=$((large_bundles + 1))
            else
                status_icon="✓"
                status_color="$GREEN"
            fi

            bundle_details+=("$status_icon|$size_kb|$relative_path|$formatted_size|$status_color")
        fi
    done <<< "$bundles"

    # Sort bundles by size (largest first)
    IFS=$'\n' sorted=($(sort -t'|' -k2 -rn <<<"${bundle_details[*]}"))

    # Display results
    echo -e "${BLUE}Bundle Sizes:${NC}"
    echo ""

    for detail in "${sorted[@]}"; do
        IFS='|' read -r icon size path formatted color <<< "$detail"
        echo -e "${color}${icon} ${path}: ${formatted}${NC}"
    done

    echo ""
    echo "─────────────────────────────"
    echo "Total Bundle Size: $(format_size $total_size)"
    echo ""

    # Generate recommendations
    if [ "$critical_bundles" -gt 0 ]; then
        echo -e "${RED}═══════════════════════════════════${NC}"
        echo -e "${RED}🔴 CRITICAL: Bundle Size Budget Exceeded${NC}"
        echo -e "${RED}═══════════════════════════════════${NC}"
        echo ""
        echo "$critical_bundles bundle(s) exceed 1MB threshold"
        echo ""
        echo "Recommendations:"
        echo "1. Enable code splitting (dynamic imports)"
        echo "2. Implement lazy loading for routes/components"
        echo "3. Analyze bundle composition: npx vite-bundle-visualizer"
        echo "4. Remove unused dependencies"
        echo "5. Use tree-shaking optimization"
        echo ""
        return 2
    elif [ "$large_bundles" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Warning: Large Bundles Detected${NC}"
        echo ""
        echo "$large_bundles bundle(s) exceed 500KB threshold"
        echo ""
        echo "Recommendations:"
        echo "1. Consider code splitting for bundles >500KB"
        echo "2. Review dependency sizes: npx webpack-bundle-analyzer"
        echo "3. Enable gzip/brotli compression"
        echo ""
        return 1
    else
        echo -e "${GREEN}✓ All bundles within performance budget${NC}"
        return 0
    fi
}

# Track bundle sizes over time
track_bundle_sizes() {
    local repo_root="${1:-$(pwd)}"
    local metrics_file="$repo_root/memory/metrics.json"

    if [ ! -f "$metrics_file" ]; then
        return 0
    fi

    # Get total bundle size
    local build_dirs
    build_dirs=$(detect_build_dir "$repo_root")

    if [ -z "$build_dirs" ]; then
        return 0
    fi

    local bundles
    bundles=$(find_bundles "$repo_root" "$build_dirs")

    local total_size=0
    while IFS= read -r bundle; do
        if [ -f "$bundle" ]; then
            local size_kb
            size_kb=$(get_size_kb "$bundle")
            total_size=$((total_size + size_kb))
        fi
    done <<< "$bundles"

    # Update metrics.json with bundle size
    if command -v jq &> /dev/null; then
        local temp_file
        temp_file=$(mktemp)
        jq --arg size "$total_size" '.bundle_size_kb = ($size | tonumber)' "$metrics_file" > "$temp_file"
        mv "$temp_file" "$metrics_file"
    fi
}

# Calculate bundle size score (0-20 points)
calculate_bundle_score() {
    local total_size_kb=$1
    local score=0

    # Scoring:
    # < 500KB: 20 points (excellent)
    # 500-750KB: 15 points (good)
    # 750-1000KB: 10 points (acceptable)
    # 1000-2000KB: 5 points (poor)
    # > 2000KB: 0 points (critical)

    if [ "$total_size_kb" -lt 500 ]; then
        score=20
    elif [ "$total_size_kb" -lt 750 ]; then
        score=15
    elif [ "$total_size_kb" -lt 1000 ]; then
        score=10
    elif [ "$total_size_kb" -lt 2000 ]; then
        score=5
    else
        score=0
    fi

    echo "$score"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    analyze_bundles "$@"
fi
