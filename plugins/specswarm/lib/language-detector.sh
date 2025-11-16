#!/bin/bash
# language-detector.sh
# Multi-language technology stack detection for SpecSwarm
# Supports: JavaScript/TypeScript, Python, PHP, Go, Ruby, Rust
# Used by: init.md, and potentially other commands

# Function: detect_tech_stack
# Detects project language, framework, build tools, and testing frameworks
# Arguments: $1 = project root directory (defaults to current directory)
# Exports: FRAMEWORK, FRAMEWORK_VERSION, LANGUAGE, LANGUAGE_VERSION, BUILD_TOOL,
#          BUILD_TOOL_VERSION, STATE_MGMT, STYLING, UNIT_TEST, E2E_TEST, RUNTIME

detect_tech_stack() {
  local project_root="${1:-.}"

  # Initialize all variables
  export FRAMEWORK="None detected"
  export FRAMEWORK_VERSION=""
  export LANGUAGE="Unknown"
  export LANGUAGE_VERSION=""
  export BUILD_TOOL="None detected"
  export BUILD_TOOL_VERSION=""
  export STATE_MGMT=""
  export STYLING=""
  export UNIT_TEST=""
  export E2E_TEST=""
  export RUNTIME=""

  # Detect project type based on config files
  cd "$project_root" || return 1

  # JavaScript/TypeScript Detection (Node.js)
  if [ -f "package.json" ]; then
    detect_javascript_stack
    return 0
  fi

  # Python Detection
  if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
    detect_python_stack
    return 0
  fi

  # PHP Detection
  if [ -f "composer.json" ]; then
    detect_php_stack
    return 0
  fi

  # Go Detection
  if [ -f "go.mod" ]; then
    detect_go_stack
    return 0
  fi

  # Ruby Detection
  if [ -f "Gemfile" ]; then
    detect_ruby_stack
    return 0
  fi

  # Rust Detection
  if [ -f "Cargo.toml" ]; then
    detect_rust_stack
    return 0
  fi

  # No config file detected
  return 1
}

# JavaScript/TypeScript Detection
detect_javascript_stack() {
  RUNTIME="Node.js"
  local PACKAGE_JSON
  PACKAGE_JSON=$(cat package.json)

  # Detect framework
  if echo "$PACKAGE_JSON" | jq -e '.dependencies.react' > /dev/null 2>&1; then
    FRAMEWORK="React"
    FRAMEWORK_VERSION=$(echo "$PACKAGE_JSON" | jq -r '.dependencies.react' | sed 's/[\^~]//')
  elif echo "$PACKAGE_JSON" | jq -e '.dependencies.vue' > /dev/null 2>&1; then
    FRAMEWORK="Vue"
    FRAMEWORK_VERSION=$(echo "$PACKAGE_JSON" | jq -r '.dependencies.vue' | sed 's/[\^~]//')
  elif echo "$PACKAGE_JSON" | jq -e '.dependencies."@angular/core"' > /dev/null 2>&1; then
    FRAMEWORK="Angular"
    FRAMEWORK_VERSION=$(echo "$PACKAGE_JSON" | jq -r '.dependencies."@angular/core"' | sed 's/[\^~]//')
  elif echo "$PACKAGE_JSON" | jq -e '.dependencies.next' > /dev/null 2>&1; then
    FRAMEWORK="Next.js"
    FRAMEWORK_VERSION=$(echo "$PACKAGE_JSON" | jq -r '.dependencies.next' | sed 's/[\^~]//')
  elif echo "$PACKAGE_JSON" | jq -e '.dependencies.astro' > /dev/null 2>&1; then
    FRAMEWORK="Astro"
    FRAMEWORK_VERSION=$(echo "$PACKAGE_JSON" | jq -r '.dependencies.astro' | sed 's/[\^~]//')
  elif echo "$PACKAGE_JSON" | jq -e '.dependencies.express' > /dev/null 2>&1; then
    FRAMEWORK="Express"
    FRAMEWORK_VERSION=$(echo "$PACKAGE_JSON" | jq -r '.dependencies.express' | sed 's/[\^~]//')
  else
    FRAMEWORK="Node.js"
    FRAMEWORK_VERSION=$(node --version 2>/dev/null || echo "unknown")
  fi

  # Detect TypeScript
  if echo "$PACKAGE_JSON" | jq -e '.devDependencies.typescript' > /dev/null 2>&1; then
    LANGUAGE="TypeScript"
    LANGUAGE_VERSION=$(echo "$PACKAGE_JSON" | jq -r '.devDependencies.typescript' | sed 's/[\^~]//')
  else
    LANGUAGE="JavaScript"
    LANGUAGE_VERSION="ES2020+"
  fi

  # Detect build tool
  if echo "$PACKAGE_JSON" | jq -e '.devDependencies.vite' > /dev/null 2>&1; then
    BUILD_TOOL="Vite"
    BUILD_TOOL_VERSION=$(echo "$PACKAGE_JSON" | jq -r '.devDependencies.vite' | sed 's/[\^~]//')
  elif echo "$PACKAGE_JSON" | jq -e '.devDependencies.webpack' > /dev/null 2>&1; then
    BUILD_TOOL="Webpack"
    BUILD_TOOL_VERSION=$(echo "$PACKAGE_JSON" | jq -r '.devDependencies.webpack' | sed 's/[\^~]//')
  elif echo "$PACKAGE_JSON" | jq -e '.dependencies.next' > /dev/null 2>&1; then
    BUILD_TOOL="Next.js (built-in)"
    BUILD_TOOL_VERSION="$FRAMEWORK_VERSION"
  elif echo "$PACKAGE_JSON" | jq -e '.dependencies.astro' > /dev/null 2>&1; then
    BUILD_TOOL="Astro (built-in)"
    BUILD_TOOL_VERSION="$FRAMEWORK_VERSION"
  else
    BUILD_TOOL="None detected"
    BUILD_TOOL_VERSION=""
  fi

  # Detect state management
  if echo "$PACKAGE_JSON" | jq -e '.dependencies.zustand' > /dev/null 2>&1; then
    STATE_MGMT="Zustand $(echo "$PACKAGE_JSON" | jq -r '.dependencies.zustand' | sed 's/[\^~]//')"
  elif echo "$PACKAGE_JSON" | jq -e '.dependencies."@reduxjs/toolkit"' > /dev/null 2>&1; then
    STATE_MGMT="Redux Toolkit $(echo "$PACKAGE_JSON" | jq -r '.dependencies."@reduxjs/toolkit"' | sed 's/[\^~]//')"
  elif echo "$PACKAGE_JSON" | jq -e '.dependencies.jotai' > /dev/null 2>&1; then
    STATE_MGMT="Jotai $(echo "$PACKAGE_JSON" | jq -r '.dependencies.jotai' | sed 's/[\^~]//')"
  fi

  # Detect styling
  if echo "$PACKAGE_JSON" | jq -e '.devDependencies.tailwindcss' > /dev/null 2>&1; then
    STYLING="Tailwind CSS $(echo "$PACKAGE_JSON" | jq -r '.devDependencies.tailwindcss' | sed 's/[\^~]//')"
  elif echo "$PACKAGE_JSON" | jq -e '.dependencies."styled-components"' > /dev/null 2>&1; then
    STYLING="Styled Components $(echo "$PACKAGE_JSON" | jq -r '.dependencies."styled-components"' | sed 's/[\^~]//')"
  elif echo "$PACKAGE_JSON" | jq -e '.dependencies."@emotion/react"' > /dev/null 2>&1; then
    STYLING="Emotion $(echo "$PACKAGE_JSON" | jq -r '.dependencies."@emotion/react"' | sed 's/[\^~]//')"
  fi

  # Detect testing frameworks
  if echo "$PACKAGE_JSON" | jq -e '.devDependencies.vitest' > /dev/null 2>&1; then
    UNIT_TEST="Vitest $(echo "$PACKAGE_JSON" | jq -r '.devDependencies.vitest' | sed 's/[\^~]//')"
  elif echo "$PACKAGE_JSON" | jq -e '.devDependencies.jest' > /dev/null 2>&1; then
    UNIT_TEST="Jest $(echo "$PACKAGE_JSON" | jq -r '.devDependencies.jest' | sed 's/[\^~]//')"
  fi

  if echo "$PACKAGE_JSON" | jq -e '.devDependencies.playwright' > /dev/null 2>&1; then
    E2E_TEST="Playwright $(echo "$PACKAGE_JSON" | jq -r '.devDependencies.playwright' | sed 's/[\^~]//')"
  elif echo "$PACKAGE_JSON" | jq -e '.devDependencies.cypress' > /dev/null 2>&1; then
    E2E_TEST="Cypress $(echo "$PACKAGE_JSON" | jq -r '.devDependencies.cypress' | sed 's/[\^~]//')"
  fi
}

# Python Detection
detect_python_stack() {
  LANGUAGE="Python"
  LANGUAGE_VERSION=$(python3 --version 2>/dev/null | cut -d' ' -f2 || echo "unknown")
  RUNTIME="Python $LANGUAGE_VERSION"
  BUILD_TOOL="pip/setuptools"

  # Detect framework from requirements.txt or pyproject.toml
  if [ -f "requirements.txt" ]; then
    if grep -qi "django" requirements.txt; then
      FRAMEWORK="Django"
      FRAMEWORK_VERSION=$(grep -i "django" requirements.txt | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    elif grep -qi "flask" requirements.txt; then
      FRAMEWORK="Flask"
      FRAMEWORK_VERSION=$(grep -i "flask" requirements.txt | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    elif grep -qi "fastapi" requirements.txt; then
      FRAMEWORK="FastAPI"
      FRAMEWORK_VERSION=$(grep -i "fastapi" requirements.txt | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    else
      FRAMEWORK="Python"
      FRAMEWORK_VERSION="$LANGUAGE_VERSION"
    fi

    # Detect testing
    if grep -qi "pytest" requirements.txt; then
      UNIT_TEST="pytest $(grep -i "pytest" requirements.txt | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)"
    fi
  fi

  # Check pyproject.toml if it exists
  if [ -f "pyproject.toml" ]; then
    if grep -qi "django" pyproject.toml && [ "$FRAMEWORK" = "Python" ]; then
      FRAMEWORK="Django"
    elif grep -qi "flask" pyproject.toml && [ "$FRAMEWORK" = "Python" ]; then
      FRAMEWORK="Flask"
    elif grep -qi "fastapi" pyproject.toml && [ "$FRAMEWORK" = "Python" ]; then
      FRAMEWORK="FastAPI"
    fi

    if grep -qi "pytest" pyproject.toml && [ -z "$UNIT_TEST" ]; then
      UNIT_TEST="pytest"
    fi
  fi
}

# PHP Detection
detect_php_stack() {
  LANGUAGE="PHP"
  LANGUAGE_VERSION=$(php --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 || echo "unknown")
  RUNTIME="PHP $LANGUAGE_VERSION"
  BUILD_TOOL="Composer"

  if [ -f "composer.json" ]; then
    # Detect Laravel
    if grep -qi "laravel/framework" composer.json; then
      FRAMEWORK="Laravel"
      FRAMEWORK_VERSION=$(grep -i "laravel/framework" composer.json | grep -oE '[0-9]+\.[0-9]+' | head -1)
    # Detect Symfony
    elif grep -qi "symfony/framework-bundle" composer.json; then
      FRAMEWORK="Symfony"
      FRAMEWORK_VERSION=$(grep -i "symfony/framework-bundle" composer.json | grep -oE '[0-9]+\.[0-9]+' | head -1)
    else
      FRAMEWORK="PHP"
      FRAMEWORK_VERSION="$LANGUAGE_VERSION"
    fi

    # Detect PHPUnit
    if grep -qi "phpunit" composer.json; then
      UNIT_TEST="PHPUnit"
    fi
  fi
}

# Go Detection
detect_go_stack() {
  LANGUAGE="Go"
  LANGUAGE_VERSION=$(go version 2>/dev/null | grep -oE 'go[0-9]+\.[0-9]+(\.[0-9]+)?' | sed 's/go//' || echo "unknown")
  RUNTIME="Go $LANGUAGE_VERSION"
  BUILD_TOOL="go build"

  if [ -f "go.mod" ]; then
    # Detect Gin framework
    if grep -qi "gin-gonic/gin" go.mod; then
      FRAMEWORK="Gin"
      FRAMEWORK_VERSION=$(grep "gin-gonic/gin" go.mod | grep -oE 'v[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    # Detect Echo framework
    elif grep -qi "labstack/echo" go.mod; then
      FRAMEWORK="Echo"
      FRAMEWORK_VERSION=$(grep "labstack/echo" go.mod | grep -oE 'v[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    # Detect Fiber framework
    elif grep -qi "gofiber/fiber" go.mod; then
      FRAMEWORK="Fiber"
      FRAMEWORK_VERSION=$(grep "gofiber/fiber" go.mod | grep -oE 'v[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    else
      FRAMEWORK="Go"
      FRAMEWORK_VERSION="$LANGUAGE_VERSION"
    fi

    # Detect testing framework
    if grep -qi "stretchr/testify" go.mod; then
      UNIT_TEST="testify"
    fi
  fi
}

# Ruby Detection
detect_ruby_stack() {
  LANGUAGE="Ruby"
  LANGUAGE_VERSION=$(ruby --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 || echo "unknown")
  RUNTIME="Ruby $LANGUAGE_VERSION"
  BUILD_TOOL="Bundler"

  if [ -f "Gemfile" ]; then
    # Detect Rails
    if grep -qi "gem ['\"]rails['\"]" Gemfile; then
      FRAMEWORK="Rails"
      FRAMEWORK_VERSION=$(grep -i "gem ['\"]rails['\"]" Gemfile | grep -oE '[0-9]+\.[0-9]+' | head -1)
    # Detect Sinatra
    elif grep -qi "gem ['\"]sinatra['\"]" Gemfile; then
      FRAMEWORK="Sinatra"
      FRAMEWORK_VERSION=$(grep -i "gem ['\"]sinatra['\"]" Gemfile | grep -oE '[0-9]+\.[0-9]+' | head -1)
    else
      FRAMEWORK="Ruby"
      FRAMEWORK_VERSION="$LANGUAGE_VERSION"
    fi

    # Detect RSpec
    if grep -qi "gem ['\"]rspec" Gemfile; then
      UNIT_TEST="RSpec"
    fi
  fi
}

# Rust Detection
detect_rust_stack() {
  LANGUAGE="Rust"
  LANGUAGE_VERSION=$(rustc --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 || echo "unknown")
  RUNTIME="Rust $LANGUAGE_VERSION"
  BUILD_TOOL="Cargo"

  if [ -f "Cargo.toml" ]; then
    # Detect Actix Web
    if grep -qi "actix-web" Cargo.toml; then
      FRAMEWORK="Actix Web"
      FRAMEWORK_VERSION=$(grep -i "actix-web" Cargo.toml | grep -oE '[0-9]+\.[0-9]+' | head -1)
    # Detect Rocket
    elif grep -qi "rocket" Cargo.toml; then
      FRAMEWORK="Rocket"
      FRAMEWORK_VERSION=$(grep "rocket" Cargo.toml | grep -oE '[0-9]+\.[0-9]+' | head -1)
    # Detect Axum
    elif grep -qi "axum" Cargo.toml; then
      FRAMEWORK="Axum"
      FRAMEWORK_VERSION=$(grep "axum" Cargo.toml | grep -oE '[0-9]+\.[0-9]+' | head -1)
    else
      FRAMEWORK="Rust"
      FRAMEWORK_VERSION="$LANGUAGE_VERSION"
    fi
  fi
}

# Display detected stack (can be called separately if needed)
display_detected_stack() {
  echo "📦 Detected Technology Stack:"
  echo ""
  echo "  Framework:     $FRAMEWORK $FRAMEWORK_VERSION"
  echo "  Language:      $LANGUAGE $LANGUAGE_VERSION"
  echo "  Build Tool:    $BUILD_TOOL $BUILD_TOOL_VERSION"
  [ -n "$RUNTIME" ] && echo "  Runtime:       $RUNTIME"
  [ -n "$STATE_MGMT" ] && echo "  State:         $STATE_MGMT"
  [ -n "$STYLING" ] && echo "  Styling:       $STYLING"
  [ -n "$UNIT_TEST" ] && echo "  Unit Tests:    $UNIT_TEST"
  [ -n "$E2E_TEST" ] && echo "  E2E Tests:     $E2E_TEST"
  echo ""
}
