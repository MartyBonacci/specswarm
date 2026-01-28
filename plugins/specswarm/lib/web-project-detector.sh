#!/bin/bash
# SpecSwarm Web Project Detector
# Detects web projects and available browser automation tools

# Global variables set by detection
WEB_FRAMEWORK=""
WEB_PROJECT_DETECTED=false

# Detect if project is a web project
is_web_project() {
  local project_path=${1:-$(pwd)}

  WEB_PROJECT_DETECTED=false
  WEB_FRAMEWORK=""

  # Check for package.json
  if [ -f "$project_path/package.json" ]; then
    local pkg_content=$(cat "$project_path/package.json" 2>/dev/null)

    # Check for React
    if echo "$pkg_content" | grep -q '"react"'; then
      WEB_PROJECT_DETECTED=true
      WEB_FRAMEWORK="React"

      # More specific detection
      if echo "$pkg_content" | grep -q '"next"'; then
        WEB_FRAMEWORK="Next.js"
      elif echo "$pkg_content" | grep -q '"@remix-run/react"\|"react-router"'; then
        WEB_FRAMEWORK="Remix/React Router"
      elif echo "$pkg_content" | grep -q '"gatsby"'; then
        WEB_FRAMEWORK="Gatsby"
      fi
    fi

    # Check for Vue
    if echo "$pkg_content" | grep -q '"vue"'; then
      WEB_PROJECT_DETECTED=true
      WEB_FRAMEWORK="Vue"

      if echo "$pkg_content" | grep -q '"nuxt"'; then
        WEB_FRAMEWORK="Nuxt.js"
      fi
    fi

    # Check for Angular
    if echo "$pkg_content" | grep -q '"@angular/core"'; then
      WEB_PROJECT_DETECTED=true
      WEB_FRAMEWORK="Angular"
    fi

    # Check for Svelte
    if echo "$pkg_content" | grep -q '"svelte"'; then
      WEB_PROJECT_DETECTED=true
      WEB_FRAMEWORK="Svelte"

      if echo "$pkg_content" | grep -q '"@sveltejs/kit"'; then
        WEB_FRAMEWORK="SvelteKit"
      fi
    fi

    # Check for Astro
    if echo "$pkg_content" | grep -q '"astro"'; then
      WEB_PROJECT_DETECTED=true
      WEB_FRAMEWORK="Astro"
    fi

    # Check for generic web indicators
    if [ "$WEB_PROJECT_DETECTED" = false ]; then
      if echo "$pkg_content" | grep -qE '"vite"|"webpack"|"parcel"|"esbuild"'; then
        WEB_PROJECT_DETECTED=true
        WEB_FRAMEWORK="Generic Web"
      fi
    fi
  fi

  # Check for HTML files as fallback
  if [ "$WEB_PROJECT_DETECTED" = false ]; then
    if [ -f "$project_path/index.html" ] || \
       [ -d "$project_path/public" ] || \
       [ -d "$project_path/static" ]; then
      WEB_PROJECT_DETECTED=true
      WEB_FRAMEWORK="Static Web"
    fi
  fi

  return $([ "$WEB_PROJECT_DETECTED" = true ] && echo 0 || echo 1)
}

# Check if Chrome DevTools MCP is available
is_chrome_devtools_available() {
  # Check if Claude Code has Chrome DevTools MCP enabled
  # This is detected by checking for MCP tools in the environment
  if [ -n "$CHROME_DEVTOOLS_MCP_ENABLED" ]; then
    return 0
  fi

  # Check for Chrome DevTools MCP configuration
  local mcp_config="$HOME/.claude/settings/mcp.json"
  if [ -f "$mcp_config" ]; then
    if grep -q "chrome-devtools" "$mcp_config" 2>/dev/null; then
      return 0
    fi
  fi

  # Check local project MCP config
  if [ -f ".claude/mcp.json" ]; then
    if grep -q "chrome-devtools" ".claude/mcp.json" 2>/dev/null; then
      return 0
    fi
  fi

  return 1
}

# Check if Playwright is available
is_playwright_available() {
  local project_path=${1:-$(pwd)}

  # Check if playwright is in dependencies
  if [ -f "$project_path/package.json" ]; then
    if grep -q '"@playwright/test"\|"playwright"' "$project_path/package.json" 2>/dev/null; then
      return 0
    fi
  fi

  # Check if playwright is installed globally
  if command -v playwright &> /dev/null; then
    return 0
  fi

  # Check if npx playwright works
  if npx playwright --version &> /dev/null 2>&1; then
    return 0
  fi

  return 1
}

# Determine if Chrome DevTools MCP should be used
should_use_chrome_devtools() {
  local project_path=${1:-$(pwd)}

  # First check if it's a web project
  if ! is_web_project "$project_path"; then
    return 1
  fi

  # Check if Chrome DevTools MCP is available
  if is_chrome_devtools_available; then
    return 0
  fi

  return 1
}

# Get recommended browser automation tool
get_browser_automation_tool() {
  local project_path=${1:-$(pwd)}

  if ! is_web_project "$project_path"; then
    echo "none"
    return 0
  fi

  if is_chrome_devtools_available; then
    echo "chrome-devtools-mcp"
  elif is_playwright_available "$project_path"; then
    echo "playwright"
  else
    echo "none"
  fi
}

# Display browser automation status
display_browser_status() {
  local project_path=${1:-$(pwd)}
  local tool=$(get_browser_automation_tool "$project_path")

  case "$tool" in
    "chrome-devtools-mcp")
      echo "🎯 Chrome DevTools MCP: Available for browser automation"
      echo "   Benefits: Real-time console monitoring, network inspection"
      echo "   No Chromium download needed (~200MB saved)"
      ;;
    "playwright")
      echo "📦 Playwright: Available for browser automation"
      echo "   Will download Chromium if not cached (~200MB)"
      ;;
    "none")
      echo "⚠️  No browser automation available"
      echo "   Install Chrome DevTools MCP:"
      echo "     claude mcp add ChromeDevTools/chrome-devtools-mcp"
      echo "   Or install Playwright:"
      echo "     npm install -D @playwright/test"
      ;;
  esac
}
