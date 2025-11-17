#!/bin/bash
# web-project-detector.sh
# Detects if current project is a web application requiring browser automation
# Used by: bugfix.md, fix.md, validate.md
# Depends on: language-detector.sh

# Function: is_web_project
# Determines if the current project is web-based and would benefit from Chrome DevTools MCP
# Arguments: $1 = project root directory (defaults to current directory)
# Returns: 0 if web project, 1 if not web project
# Exports: IS_WEB_PROJECT (true/false), WEB_FRAMEWORK (framework name)

is_web_project() {
  local project_root="${1:-.}"

  # Initialize exports
  export IS_WEB_PROJECT="false"
  export WEB_FRAMEWORK=""

  # Change to project root
  cd "$project_root" || return 1

  # Source language detector if not already loaded
  if ! command -v detect_tech_stack &> /dev/null; then
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$script_dir/language-detector.sh"
  fi

  # Detect tech stack
  detect_tech_stack "$project_root"

  # Check if framework is web-based
  case "$FRAMEWORK" in
    React|Vue|Angular|Svelte|Next.js|Nuxt|Astro|Remix|SolidJS|Qwik)
      IS_WEB_PROJECT="true"
      WEB_FRAMEWORK="$FRAMEWORK"
      return 0
      ;;
    Express|Fastify|Koa|Hapi|NestJS)
      # API frameworks - might serve web content or have browser-testable endpoints
      # Check if there's a client/public directory or if it serves static files
      if [ -d "client" ] || [ -d "public" ] || [ -d "static" ] || [ -d "frontend" ]; then
        IS_WEB_PROJECT="true"
        WEB_FRAMEWORK="$FRAMEWORK (with frontend)"
        return 0
      else
        # Pure API - no browser automation needed
        IS_WEB_PROJECT="false"
        return 1
      fi
      ;;
    *)
      # Non-web framework (Python CLI, Go binary, etc.) or unknown
      IS_WEB_PROJECT="false"
      return 1
      ;;
  esac
}

# Function: detect_chrome_devtools_mcp
# Checks if Chrome DevTools MCP server is installed and connected
# Returns: 0 if available, 1 if not available
# Exports: CHROME_DEVTOOLS_AVAILABLE (true/false)

detect_chrome_devtools_mcp() {
  export CHROME_DEVTOOLS_AVAILABLE="false"

  # Check if MCP is connected (not just installed)
  if claude mcp list 2>/dev/null | grep -q "chrome-devtools.*connected"; then
    CHROME_DEVTOOLS_AVAILABLE="true"
    return 0
  fi

  return 1
}

# Function: should_use_chrome_devtools
# Determines if Chrome DevTools MCP should be used for this project
# Combines web project detection with MCP availability
# Arguments: $1 = project root directory (defaults to current directory)
# Returns: 0 if should use, 1 if should not use
# Exports: USE_CHROME_DEVTOOLS (true/false), USE_REASON (explanation)

should_use_chrome_devtools() {
  local project_root="${1:-.}"

  export USE_CHROME_DEVTOOLS="false"
  export USE_REASON=""

  # First, check if this is a web project
  if ! is_web_project "$project_root"; then
    USE_REASON="Not a web project (detected: $FRAMEWORK)"
    return 1
  fi

  # Web project detected, now check if Chrome DevTools MCP is available
  if detect_chrome_devtools_mcp; then
    USE_CHROME_DEVTOOLS="true"
    USE_REASON="Web project ($WEB_FRAMEWORK) with Chrome DevTools MCP available"
    return 0
  else
    USE_REASON="Web project ($WEB_FRAMEWORK) but Chrome DevTools MCP not available - using Playwright fallback"
    return 1
  fi
}
