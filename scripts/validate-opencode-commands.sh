#!/bin/bash
# validate-opencode-commands.sh
# Validates that all command files referenced in opencode.jsonc exist
# and that opencode can parse the config
# Run this as part of CI/CD or before releases

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OPENCODE_CONFIG="$REPO_ROOT/.opencode/opencode.jsonc"
COMMANDS_DIR="$REPO_ROOT/commands"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Validating SpecSwarm OpenCode Commands"
echo "=========================================="
echo ""

# Check if opencode.jsonc exists
if [[ ! -f "$OPENCODE_CONFIG" ]]; then
    echo -e "${RED}❌ Error: opencode.jsonc not found at $OPENCODE_CONFIG${NC}"
    exit 1
fi

echo "📁 Config file: $OPENCODE_CONFIG"
echo "📁 Commands directory: $COMMANDS_DIR"
echo ""

# ===========================================
# Test 1: Validate opencode can parse the config
# ===========================================
echo "Test 1: Checking if opencode can parse config..."

# Check if opencode is available
if command -v opencode &> /dev/null; then
    # Try to run opencode with a simple command - if config is invalid it will error immediately
    cd "$REPO_ROOT"
    if timeout 3 opencode run --help 2>&1 | grep -q "Error.*JSON\|not valid JSON"; then
        echo -e "${RED}❌ opencode config parsing failed${NC}"
        timeout 3 opencode run --help 2>&1 | head -20
        exit 1
    fi
    echo -e "  ${GREEN}✓${NC} opencode config parses successfully"
else
    echo -e "  ${YELLOW}⚠${NC} opencode not installed, skipping config parse test"
fi
echo ""

# ===========================================
# Test 2: Validate @file references exist
# ===========================================
echo "Test 2: Checking @file references in templates..."
echo ""

# Extract all @commands/*.md references from opencode.jsonc
# Pattern matches @commands/filename.md
FILE_REFS=$(grep -oE '@commands/[^"\\]+\.md' "$OPENCODE_CONFIG" | sort -u || true)

if [[ -z "$FILE_REFS" ]]; then
    echo -e "${YELLOW}⚠️  No @commands/ file references found in opencode.jsonc${NC}"
    exit 0
fi

MISSING_FILES=()
FOUND_FILES=()
TOTAL_COUNT=0

echo "Checking referenced command files..."
echo ""

while IFS= read -r ref; do
    ((TOTAL_COUNT++))
    
    # Remove the @ prefix to get the path
    FILE_PATH="${ref#@}"
    RESOLVED_PATH="$REPO_ROOT/$FILE_PATH"
    
    if [[ -f "$RESOLVED_PATH" ]]; then
        FOUND_FILES+=("$ref")
        echo -e "  ${GREEN}✓${NC} $ref"
    else
        MISSING_FILES+=("$ref")
        echo -e "  ${RED}✗${NC} $ref (NOT FOUND: $RESOLVED_PATH)"
    fi
done <<< "$FILE_REFS"

echo ""
echo "=========================================="

# ===========================================
# Test 3: Check for unreferenced command files
# ===========================================
echo ""
echo "Test 3: Checking for unreferenced command files..."
echo ""

UNREFERENCED_FILES=()
for cmd_file in "$COMMANDS_DIR"/*.md; do
    if [[ -f "$cmd_file" ]]; then
        basename_file=$(basename "$cmd_file")
        # Check if this file is referenced with @commands/
        if ! grep -q "@commands/$basename_file" "$OPENCODE_CONFIG" 2>/dev/null; then
            UNREFERENCED_FILES+=("$basename_file")
            echo -e "  ${YELLOW}⚠${NC} $basename_file (not referenced in opencode.jsonc)"
        fi
    fi
done

if [[ ${#UNREFERENCED_FILES[@]} -eq 0 ]]; then
    echo -e "  ${GREEN}✓${NC} All command files are referenced"
fi

echo ""
echo "=========================================="
echo ""

# Summary
echo "📊 Summary:"
echo "   Total references: $TOTAL_COUNT"
echo -e "   ${GREEN}Found: ${#FOUND_FILES[@]}${NC}"

if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
    echo -e "   ${RED}Missing: ${#MISSING_FILES[@]}${NC}"
fi

if [[ ${#UNREFERENCED_FILES[@]} -gt 0 ]]; then
    echo -e "   ${YELLOW}Unreferenced: ${#UNREFERENCED_FILES[@]}${NC}"
fi

echo ""

# Exit with error if any files are missing
if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
    echo -e "${RED}❌ Validation FAILED: ${#MISSING_FILES[@]} missing file(s)${NC}"
    echo ""
    echo "Missing files:"
    for missing in "${MISSING_FILES[@]}"; do
        echo "  - $missing"
    done
    echo ""
    echo "Please ensure all referenced command files exist in the commands/ directory."
    exit 1
fi

# Warn but don't fail for unreferenced files
if [[ ${#UNREFERENCED_FILES[@]} -gt 0 ]]; then
    echo -e "${YELLOW}⚠️  Warning: ${#UNREFERENCED_FILES[@]} unreferenced file(s) in commands/${NC}"
    echo ""
    echo "Consider adding these to opencode.jsonc or removing them:"
    for unreferenced in "${UNREFERENCED_FILES[@]}"; do
        echo "  - $unreferenced"
    done
    echo ""
fi

echo -e "${GREEN}✅ Validation PASSED: All ${#FOUND_FILES[@]} command files exist${NC}"
exit 0
