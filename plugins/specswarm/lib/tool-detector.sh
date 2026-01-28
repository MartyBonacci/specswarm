#!/bin/bash
# SpecSwarm Tool Detector
# Detects available MCP tools and provides graceful fallbacks
# Implements lazy loading / dynamic tool fetching for Claude Code 2.1.0+

# Tool availability cache (set after detection)
TOOLS_DETECTED=false
CHROME_DEVTOOLS_AVAILABLE=false
PLAYWRIGHT_AVAILABLE=false
LSP_AVAILABLE=false
CONTEXT7_AVAILABLE=false
NOTIFIER_AVAILABLE=false

# Detect all available tools
detect_available_tools() {
  if [ "$TOOLS_DETECTED" = true ]; then
    return 0
  fi

  local project_path=${1:-$(pwd)}

  # Chrome DevTools MCP
  if check_mcp_tool "chrome-devtools"; then
    CHROME_DEVTOOLS_AVAILABLE=true
  fi

  # Playwright MCP
  if check_mcp_tool "playwright"; then
    PLAYWRIGHT_AVAILABLE=true
  fi

  # LSP tools
  if check_mcp_tool "lsp" || [ -f "$project_path/tsconfig.json" ]; then
    LSP_AVAILABLE=true
  fi

  # Context7 MCP
  if check_mcp_tool "context7"; then
    CONTEXT7_AVAILABLE=true
  fi

  # Notifier plugin
  if check_plugin "notifier"; then
    NOTIFIER_AVAILABLE=true
  fi

  TOOLS_DETECTED=true
}

# Check if MCP tool is available
check_mcp_tool() {
  local tool_name=$1

  # Check global MCP config
  local global_config="$HOME/.claude/settings/mcp.json"
  if [ -f "$global_config" ]; then
    if grep -qi "$tool_name" "$global_config" 2>/dev/null; then
      return 0
    fi
  fi

  # Check project MCP config
  if [ -f ".claude/mcp.json" ]; then
    if grep -qi "$tool_name" ".claude/mcp.json" 2>/dev/null; then
      return 0
    fi
  fi

  # Check for environment variable marker
  local env_var="MCP_${tool_name^^}_ENABLED"
  env_var="${env_var//-/_}"
  if [ -n "${!env_var}" ]; then
    return 0
  fi

  return 1
}

# Check if Claude Code plugin is available
check_plugin() {
  local plugin_name=$1

  # Check marketplace plugins
  local marketplace_dir="$HOME/.claude/plugins/marketplaces"
  if [ -d "$marketplace_dir" ]; then
    if find "$marketplace_dir" -name "$plugin_name" -type d 2>/dev/null | grep -q .; then
      return 0
    fi
  fi

  # Check local plugins
  local local_dir="$HOME/.claude/plugins"
  if [ -d "$local_dir/$plugin_name" ]; then
    return 0
  fi

  return 1
}

# Get tool recommendation for a task type
get_tool_for_task() {
  local task_type=$1
  local project_path=${2:-$(pwd)}

  detect_available_tools "$project_path"

  case "$task_type" in
    "browser-automation")
      if [ "$CHROME_DEVTOOLS_AVAILABLE" = true ]; then
        echo "chrome-devtools-mcp"
      elif [ "$PLAYWRIGHT_AVAILABLE" = true ]; then
        echo "playwright-mcp"
      else
        echo "none"
      fi
      ;;

    "code-analysis")
      if [ "$LSP_AVAILABLE" = true ]; then
        echo "lsp"
      else
        echo "grep-based"
      fi
      ;;

    "documentation-lookup")
      if [ "$CONTEXT7_AVAILABLE" = true ]; then
        echo "context7"
      else
        echo "web-search"
      fi
      ;;

    "notification")
      if [ "$NOTIFIER_AVAILABLE" = true ]; then
        echo "notifier-plugin"
      else
        echo "terminal-bell"
      fi
      ;;

    *)
      echo "unknown"
      ;;
  esac
}

# Display tool availability summary
display_tool_summary() {
  local project_path=${1:-$(pwd)}

  detect_available_tools "$project_path"

  echo "🔧 Available Tools"
  echo "━━━━━━━━━━━━━━━━━━"
  echo ""

  # Browser Automation
  echo "Browser Automation:"
  if [ "$CHROME_DEVTOOLS_AVAILABLE" = true ]; then
    echo "  ✅ Chrome DevTools MCP"
  else
    echo "  ⬜ Chrome DevTools MCP (not installed)"
  fi
  if [ "$PLAYWRIGHT_AVAILABLE" = true ]; then
    echo "  ✅ Playwright MCP"
  else
    echo "  ⬜ Playwright MCP (not installed)"
  fi
  echo ""

  # Code Analysis
  echo "Code Analysis:"
  if [ "$LSP_AVAILABLE" = true ]; then
    echo "  ✅ LSP (TypeScript/JavaScript)"
  else
    echo "  ⬜ LSP (falling back to grep)"
  fi
  echo ""

  # Documentation
  echo "Documentation Lookup:"
  if [ "$CONTEXT7_AVAILABLE" = true ]; then
    echo "  ✅ Context7 MCP"
  else
    echo "  ⬜ Context7 MCP (using web search)"
  fi
  echo ""

  # Notifications
  echo "Notifications:"
  if [ "$NOTIFIER_AVAILABLE" = true ]; then
    echo "  ✅ Notifier Plugin"
  else
    echo "  ⬜ Notifier Plugin (using terminal bell)"
  fi
}

# Get install instructions for missing tools
get_install_instructions() {
  local tool_name=$1

  case "$tool_name" in
    "chrome-devtools")
      echo "claude mcp add ChromeDevTools/chrome-devtools-mcp"
      ;;
    "playwright")
      echo "claude mcp add playwright/playwright"
      ;;
    "context7")
      echo "claude mcp add context7/context7"
      ;;
    "notifier")
      echo "claude plugin add notifier"
      ;;
    *)
      echo "# Tool '$tool_name' - no install instructions available"
      ;;
  esac
}

# Graceful fallback wrapper
# Usage: with_fallback "chrome-devtools" "playwright" "none" command_to_run
with_fallback() {
  local primary_tool=$1
  local fallback_tool=$2
  local none_behavior=$3
  shift 3

  detect_available_tools

  local tool_var="$(echo "${primary_tool^^}_AVAILABLE" | tr '-' '_')"
  local fallback_var="$(echo "${fallback_tool^^}_AVAILABLE" | tr '-' '_')"

  if [ "${!tool_var}" = true ]; then
    echo "Using $primary_tool..."
    "$@"
  elif [ "${!fallback_var}" = true ]; then
    echo "Falling back to $fallback_tool..."
    "$@"
  else
    case "$none_behavior" in
      "skip")
        echo "⚠️  Skipping: No tool available ($primary_tool or $fallback_tool)"
        return 0
        ;;
      "error")
        echo "❌ Error: Required tool not available ($primary_tool or $fallback_tool)"
        return 1
        ;;
      "warn")
        echo "⚠️  Warning: No tool available, proceeding anyway..."
        "$@"
        ;;
    esac
  fi
}
