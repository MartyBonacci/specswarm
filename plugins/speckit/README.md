# SpecKit Plugin for Claude Code

A Claude Code plugin that brings **Spec-Driven Development** workflow to your projects. This plugin provides a structured, AI-assisted approach to software development that emphasizes writing clear specifications before implementation.

## Attribution

This plugin is adapted from [GitHub's spec-kit](https://github.com/github/spec-kit) project.

**Original Work:**
- Copyright (c) GitHub, Inc.
- Licensed under MIT License
- Original Repository: https://github.com/github/spec-kit

**Adaptation:**
- Adapted for Claude Code by Marty Bonacci
- Removed Python CLI dependencies
- Integrated commands directly into Claude Code workflow

## What is Spec-Driven Development?

Spec-Driven Development (SDD) is a structured process that emphasizes **intent-driven development** where specifications define the "what" and "why" before the "how". Instead of jumping straight to code, SDD follows a systematic workflow:

1. **Constitution** - Establish project principles and constraints
2. **Specification** - Define what needs to be built and why
3. **Planning** - Design the technical approach
4. **Tasks** - Break down work into actionable steps
5. **Implementation** - Build the feature systematically
6. **Analysis** - Validate consistency and completeness

## Commands

This plugin provides 8 slash commands for the complete Spec-Driven Development workflow:

### `/speckit.constitution`
Create or update the project constitution from interactive or provided principle inputs, ensuring all dependent templates stay in sync.

**Usage:**
```
/speckit.constitution
```

Establishes the governing principles for your project, including:
- Technology constraints
- Quality standards
- Team agreements
- Non-negotiable requirements

### `/speckit.specify`
Create or update the feature specification from a natural language feature description.

**Usage:**
```
/speckit.specify Create a user authentication system with email and password
```

Generates a comprehensive specification document that includes:
- Feature overview and context
- Functional requirements
- User stories
- Acceptance criteria
- Edge cases
- Non-functional requirements

### `/speckit.clarify`
Identify underspecified areas in the current feature spec by asking up to 5 highly targeted clarification questions and encoding answers back into the spec.

**Usage:**
```
/speckit.clarify
```

Analyzes your specification to find ambiguities and asks targeted questions to improve clarity and completeness.

### `/speckit.plan`
Execute the implementation planning workflow using the plan template to generate design artifacts.

**Usage:**
```
/speckit.plan
```

Creates a technical implementation plan that includes:
- Architecture decisions
- Technology stack choices
- Data model design
- Component breakdown
- Integration points
- Technical constraints

### `/speckit.tasks`
Generate an actionable, dependency-ordered tasks.md for the feature based on available design artifacts.

**Usage:**
```
/speckit.tasks
```

Breaks down the implementation plan into concrete, executable tasks with:
- Sequential task numbering
- Dependency ordering
- Parallel execution markers
- Phase grouping
- Clear descriptions

### `/speckit.implement`
Execute the implementation plan by processing and executing all tasks defined in tasks.md

**Usage:**
```
/speckit.implement
```

Systematically works through the task list to implement the feature, following the planned approach.

### `/speckit.analyze`
Perform a non-destructive cross-artifact consistency and quality analysis across spec.md, plan.md, and tasks.md after task generation.

**Usage:**
```
/speckit.analyze
```

Validates your specification artifacts for:
- Inconsistencies between documents
- Duplicate requirements
- Ambiguous language
- Coverage gaps
- Constitution violations
- Terminology drift

### `/speckit.checklist`
Generate a custom checklist for the current feature based on user requirements.

**Usage:**
```
/speckit.checklist Create a UX requirements checklist
```

Creates "unit tests for requirements" - checklists that validate the quality of your specifications, not the implementation. Supports different checklist types:
- UX requirements quality
- API requirements quality
- Security requirements quality
- Performance requirements quality

## Workflow Example

Here's a typical Spec-Driven Development workflow using this plugin:

```bash
# 1. Establish project principles
/speckit.constitution

# 2. Define what you want to build
/speckit.specify Create a podcast landing page with episode browsing

# 3. Clarify any ambiguities
/speckit.clarify

# 4. Create technical plan
/speckit.plan

# 5. Generate task breakdown
/speckit.tasks

# 6. Validate consistency
/speckit.analyze

# 7. Create quality checklists
/speckit.checklist UX

# 8. Implement the feature
/speckit.implement
```

## File Structure

The plugin creates the following structure in your project:

```
your-project/
├── memory/
│   └── constitution.md          # Project principles
├── features/
│   └── feature-name/
│       ├── spec.md              # Feature specification
│       ├── plan.md              # Technical plan
│       ├── tasks.md             # Implementation tasks
│       └── checklists/          # Quality checklists
│           ├── ux.md
│           ├── security.md
│           └── ...
```

## Differences from Original spec-kit

This Claude Code plugin adaptation differs from the original spec-kit CLI in several ways:

1. **No Python CLI dependency** - Commands run directly in Claude Code
2. **No external scripts** - Logic integrated into command definitions
3. **Claude Code integration** - Uses Claude Code's native features and tools
4. **Simplified installation** - Install via Claude Code plugin system
5. **Same methodology** - Preserves the core Spec-Driven Development workflow

## Installation

Install this plugin from the SpecSwarm marketplace:

```bash
claude plugin marketplace add marty/specswarm
claude plugin install speckit
```

Or install from a local directory:

```bash
claude plugin install /path/to/specswarm/plugins/speckit
```

## License

This adaptation maintains the MIT License from the original spec-kit project.

**Original License:**
```
MIT License
Copyright (c) GitHub, Inc.
```

**Adaptation License:**
```
MIT License
Copyright (c) 2025 Marty Bonacci
```

See the LICENSE file in the repository root for full license text.

## Learn More

- [Original spec-kit repository](https://github.com/github/spec-kit)
- [Spec-Driven Development documentation](https://github.com/github/spec-kit/blob/main/spec-driven.md)
- [Claude Code documentation](https://docs.claude.com/en/docs/claude-code)
- [Claude Code plugins guide](https://docs.claude.com/en/docs/claude-code/plugins)

## Contributing

This is an adaptation of GitHub's spec-kit. For questions or improvements to the original methodology, please see the [spec-kit repository](https://github.com/github/spec-kit).

For issues specific to this Claude Code adaptation, please file issues in the SpecSwarm repository.
