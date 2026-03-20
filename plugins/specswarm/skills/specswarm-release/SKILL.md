---
name: specswarm-release
effort: low
description: Prepare releases with changelog, version bump, and tagging. Confirms on release/tag/publish/version intent.
allowed-tools: AskUserQuestion, SlashCommand
---

# SpecSwarm Release

Provides natural language access to `/specswarm:release` command.

## When to Invoke

Trigger this skill when the user mentions:
- Releasing a version
- Cutting a release
- Tagging and publishing
- Version bumping
- Creating a changelog

**Examples:**
- "Release version 2.0"
- "Cut a patch release"
- "Tag and publish"
- "Bump the minor version"
- "Prepare a release"

## Instructions

**Confirm and extract version type:**

1. **Detect** that user wants to create a release
2. **Extract version type** from context:
   - "patch" / "bug fix release" → `--patch`
   - "minor" / "new features" → `--minor`
   - "major" / "breaking changes" → `--major`
3. **If version type is clear**, ask for confirmation using AskUserQuestion:

   **Question**: "Release Confirmation"
   **Description**: "This will run quality gates, generate changelog, bump version, and create a git tag."
   **Options**:
   - **Option 1** (label: "Yes, create release"): "Run release workflow"
   - **Option 2** (label: "No, cancel"): "Cancel release"

4. **If version type is unclear**, ask which type:
   - Use AskUserQuestion with options: "Patch (bug fixes)", "Minor (new features)", "Major (breaking changes)", "Cancel"

5. **Execute**: Run `/specswarm:release --patch|--minor|--major` based on selection

## Semantic Understanding

**Release equivalents**: release, tag, publish, cut, version, bump, changelog
**Version terms**: patch, minor, major, breaking, semver
