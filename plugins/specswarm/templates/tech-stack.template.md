# Tech Stack - [PROJECT_NAME]

**Last Updated**: [DATE]
**Auto-Generated**: [AUTO_GENERATED]

---

## Core Technologies

### Framework
- **[FRAMEWORK]** [VERSION]
  - Notes: [FRAMEWORK_NOTES]

### Language
- **[LANGUAGE]** [VERSION]
  - Notes: [LANGUAGE_NOTES]

### Build Tool
- **[BUILD_TOOL]** [VERSION]
  - Notes: [BUILD_TOOL_NOTES]

---

## State Management

[STATE_MANAGEMENT_SECTION]

---

## Styling

[STYLING_SECTION]

---

## Testing

### Unit Testing
- **[UNIT_TEST_FRAMEWORK]** [VERSION]
  - Purpose: Component and function unit tests

### Integration Testing
- **[INTEGRATION_TEST_FRAMEWORK]** [VERSION]
  - Purpose: API and integration tests

### End-to-End Testing
- **[E2E_TEST_FRAMEWORK]** [VERSION]
  - Purpose: Full application flow testing

---

## Approved Libraries

[APPROVED_LIBRARIES_SECTION]

---

## Prohibited Technologies

The following technologies/patterns are **NOT** approved for this project:

[PROHIBITED_SECTION]

---

## Guidelines

### Adding New Dependencies

Before adding a new dependency:
1. Check if existing approved libraries can solve the problem
2. Verify the library is actively maintained
3. Check bundle size impact
4. Ensure TypeScript support (if applicable)
5. Get team approval for major dependencies

### Version Updates

- Follow semver for all dependencies
- Test thoroughly before updating major versions
- Document breaking changes in this file
- Update CI/CD pipelines if needed

---

## Notes

[NOTES_SECTION]

---

**Tech Stack Enforcement**: This file is used by SpecSwarm to prevent technology drift. Commands like `/specswarm:build` and `/specswarm:implement` will reference this file to ensure consistency across features.
