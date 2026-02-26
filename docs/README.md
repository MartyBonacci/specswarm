# SpecSwarm Documentation

Complete documentation for the SpecSwarm Claude Code plugin.

## 📚 Documentation Index

### Quick Start
- **[Main README](../README.md)** - Overview, installation, and quick start guide
- **[Commands Reference](../COMMANDS.md)** - Complete documentation for all 21 commands (10 visible + 11 internal)

### Detailed Guides
- **[Setup Guide](./SETUP.md)** - Technical setup, configuration, and troubleshooting
- **[Features Deep-Dive](./FEATURES.md)** - Technical documentation for advanced features

---

## 🚀 Getting Started

### New to SpecSwarm?

1. **Read**: [Main README](../README.md) - Understand what SpecSwarm does
2. **Install**: Follow the 2-step installation in the README
3. **Configure**: Run `/specswarm:init` to set up your project
4. **Build**: Try `/specswarm:build "your first feature"`

### Looking for Something Specific?

**Installation & Setup:**
- Installation instructions → [README: Installation](../README.md#installation)
- Initial configuration → [Setup: Configuration](./SETUP.md#configuration)
- Directory structure → [Setup: Directory Structure](./SETUP.md#directory-structure)

**Learning Commands:**
- Core 5 commands → [Commands: Core Workflows](../COMMANDS.md#core-workflows)
- All 21 commands → [Commands Reference](../COMMANDS.md)
- Natural language usage → [README: Natural Language](../README.md#natural-language-commands-v33)

**Advanced Features:**
- Quality validation → [Features: Quality System](./FEATURES.md#quality-validation-system)
- Tech stack management → [Features: Tech Stack](./FEATURES.md#tech-stack-management)
- Bundle size monitoring → [Features: Bundle Size](./FEATURES.md#bundle-size-monitoring)
- SSR validation → [Features: SSR Patterns](./FEATURES.md#ssr-pattern-validation)

**Configuration:**
- Quality standards → [Setup: Quality Standards](./SETUP.md#quality-standards)
- Tech stack definition → [Setup: Tech Stack](./SETUP.md#tech-stack-definition)
- Performance budgets → [Setup: Performance Budgets](./SETUP.md#performance-budgets)

**Troubleshooting:**
- Common issues → [Setup: Troubleshooting](./SETUP.md#troubleshooting)
- Quality validation → [Setup: Quality Not Running](./SETUP.md#quality-validation-not-running)
- Natural language → [Setup: Skills Not Triggering](./SETUP.md#natural-language-skills-not-triggering)

---

## 📖 Documentation Structure

### [Main README](../README.md)
**Purpose:** First impression, quick start, core concepts

**Contents:**
- Overview and benefits
- Installation (2 steps)
- Quick start examples
- Natural language usage
- Core concepts
- Version history

**Audience:** New users, getting started

---

### [Commands Reference](../COMMANDS.md)
**Purpose:** Complete command documentation

**Contents:**
- All commands organized by category (10 visible + 11 internal)
- Usage examples for each command
- When to use each command
- Command comparison tables
- Workflow patterns

**Audience:** Daily users, command reference

---

### [Setup Guide](./SETUP.md)
**Purpose:** Technical setup and configuration

**Contents:**
- Installation details
- Directory structure explanation
- Configuration files (tech-stack.md, quality-standards.md)
- Performance budget setup
- Optional integrations (Chrome DevTools MCP)
- Troubleshooting guide
- Advanced configuration

**Audience:** Project setup, configuration, troubleshooting

---

### [Features Deep-Dive](./FEATURES.md)
**Purpose:** Technical feature documentation

**Contents:**
- Quality validation system (0-100 scoring)
- Tech stack management (95% drift prevention)
- SSR pattern validation
- Multi-framework testing
- Chain bug detection
- Bundle size monitoring
- Natural language architecture
- Multi-language support

**Audience:** Advanced users, understanding internals

---

## 🎯 Common Tasks

### "I want to build a new feature"
1. Read: [Commands: /specswarm:build](../COMMANDS.md#specswarmcomplete)
2. Run: `/specswarm:build "feature description"`
3. Or use natural language: "Build user authentication with JWT"

### "I need to fix a bug"
1. Read: [Commands: /specswarm:fix](../COMMANDS.md#specswarmfix)
2. Run: `/specswarm:fix "bug description"`
3. Or use natural language: "Fix the login button on mobile"

### "I want to change how something works"
1. Read: [Commands: /specswarm:modify](../COMMANDS.md#specswarmmodify)
2. Run: `/specswarm:modify "change description"`
3. Or use natural language: "Change authentication from session to JWT"

### "I'm ready to ship"
1. Read: [Commands: /specswarm:ship](../COMMANDS.md#specswarmship)
2. Run: `/specswarm:ship`
3. Or use natural language: "Ship this feature" (will ask for confirmation)

### "I need to set up SpecSwarm in my project"
1. Read: [Setup: Configuration](./SETUP.md#configuration)
2. Run: `/specswarm:init`
3. Follow interactive prompts

### "Quality validation isn't working"
1. Read: [Setup: Troubleshooting](./SETUP.md#troubleshooting)
2. Check: Does `.specswarm/quality-standards.md` exist?
3. Fix: Run `/specswarm:init` if missing

### "I want to prevent tech stack drift"
1. Read: [Features: Tech Stack Management](./FEATURES.md#tech-stack-management)
2. Read: [Setup: Tech Stack Definition](./SETUP.md#tech-stack-definition)
3. Create: `.specswarm/tech-stack.md`
4. Define: Core technologies, approved libraries, prohibited patterns

### "Bundle sizes are too large"
1. Read: [Features: Bundle Size Monitoring](./FEATURES.md#bundle-size-monitoring)
2. Read: [Setup: Performance Budgets](./SETUP.md#performance-budgets)
3. Analyze: Run `/specswarm:analyze-quality`
4. Fix: Implement code splitting, remove unused dependencies

---

## 🔍 Search by Topic

### Commands
- **Core workflows**: [Commands: Core Workflows](../COMMANDS.md#core-workflows)
- **Feature development**: [Commands: New Feature Workflows](../COMMANDS.md#new-feature-workflows)
- **Bug fixing**: [Commands: Bug & Issue Management](../COMMANDS.md#bug--issue-management)
- **Code maintenance**: [Commands: Code Maintenance](../COMMANDS.md#code-maintenance)
- **Quality analysis**: [Commands: Quality & Analysis](../COMMANDS.md#quality--analysis)
- **Release management**: [Commands: Lifecycle Management](../COMMANDS.md#lifecycle-management)

### Features
- **Quality validation**: [Features: Quality System](./FEATURES.md#quality-validation-system)
- **Tech stack**: [Features: Tech Stack Management](./FEATURES.md#tech-stack-management)
- **SSR validation**: [Features: SSR Patterns](./FEATURES.md#ssr-pattern-validation)
- **Testing**: [Features: Multi-Framework Testing](./FEATURES.md#multi-framework-testing)
- **Bug detection**: [Features: Chain Bug Detection](./FEATURES.md#chain-bug-detection)
- **Performance**: [Features: Bundle Size Monitoring](./FEATURES.md#bundle-size-monitoring)
- **Natural language**: [Features: Natural Language](./FEATURES.md#natural-language-commands)

### Setup & Configuration
- **Installation**: [README: Installation](../README.md#installation)
- **Configuration**: [Setup: Configuration](./SETUP.md#configuration)
- **Directory structure**: [Setup: Directory Structure](./SETUP.md#directory-structure)
- **Quality standards**: [Setup: Quality Standards](./SETUP.md#quality-standards)
- **Tech stack**: [Setup: Tech Stack Definition](./SETUP.md#tech-stack-definition)
- **Troubleshooting**: [Setup: Troubleshooting](./SETUP.md#troubleshooting)

---

## 📊 Documentation Stats

- **Main README**: 400 lines (simplified from 670)
- **Commands Reference**: 600+ lines covering 21 commands (10 visible + 11 internal)
- **Setup Guide**: 500+ lines of technical setup
- **Features Deep-Dive**: 600+ lines of feature documentation
- **Total Documentation**: 2,100+ lines

---

## 🆘 Need Help?

### Quick Links
- **Installation issues**: [Setup: Troubleshooting](./SETUP.md#troubleshooting)
- **Command not found**: [Setup: Plugin Not Loading](./SETUP.md#plugin-not-loading)
- **Quality not running**: [Setup: Quality Validation Not Running](./SETUP.md#quality-validation-not-running)
- **Natural language not working**: [Setup: Natural Language Skills Not Triggering](./SETUP.md#natural-language-skills-not-triggering)

### External Resources
- **Repository**: https://github.com/MartyBonacci/specswarm
- **Issues**: https://github.com/MartyBonacci/specswarm/issues
- **Claude Code Docs**: https://docs.anthropic.com/claude-code

---

## 📝 Contributing to Documentation

Found an issue or want to improve the docs?

1. **Typos/errors**: Open an issue on GitHub
2. **Missing documentation**: Suggest additions via GitHub issues
3. **Unclear explanations**: Let us know what's confusing

---

## 🔄 Version History

See [README: Version History](../README.md#version-history) for release notes and changelog.

---

**SpecSwarm v4.0.0** - Documentation index

*Navigate confidently through SpecSwarm's comprehensive documentation.*
