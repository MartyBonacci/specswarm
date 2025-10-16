# Integration Patterns Library

**Version:** 1.0.0
**Status:** Phase 2.1 - Active Development
**Purpose:** Proven-correct integration patterns for common external services

---

## Overview

This library contains **battle-tested, production-ready** integration patterns for popular external services. Each pattern has been:

- ✅ **Tested in production** - Used in real projects
- ✅ **Debugged and fixed** - Common pitfalls removed
- ✅ **Fully documented** - Usage examples and warnings
- ✅ **Type-safe** - Complete TypeScript definitions

**Why This Exists:**
The Phase 2 Cloudinary bug (see `docs/learnings/PHASE-2-FAILURE-ANALYSIS-001.md`) revealed that generated code can have subtle API parameter bugs that TypeScript can't catch. This library prevents similar bugs by providing **proven patterns** for common integrations.

---

## Available Patterns

### 🖼️ Cloudinary (Image Storage)

**Pattern:** `cloudinary/avatar-upload.ts`
**Status:** ✅ Production-Ready
**Version:** 1.0.0
**Last Tested:** 2025-01-16

**What it does:**
- Avatar image uploads with automatic resize (200x200)
- Face-detection cropping
- Comprehensive error handling
- Image deletion utilities

**Known Issues Fixed:**
- ❌ Removed invalid `format: 'auto'` parameter (caused runtime error)
- ✅ Proper error logging for debugging
- ✅ Environment variable validation

**Usage:**
```typescript
import { uploadAvatar, configureCloudinary } from '@/lib/cloudinary/avatar-upload';

// Configure once on server startup
configureCloudinary();

// Upload in route handler
const result = await uploadAvatar(fileBuffer, userId);
console.log('Avatar URL:', result.secure_url);
```

**See:** `cloudinary/avatar-upload.ts` for complete documentation

---

### 💳 Stripe (Payments) - COMING SOON

**Pattern:** `stripe/payment-intent.ts`
**Status:** 🚧 Planned
**Planned:** Phase 2.1

Will include:
- Payment intent creation
- Webhook handling
- Subscription management
- Customer management

---

### ✉️ SendGrid (Email) - COMING SOON

**Pattern:** `sendgrid/send-email.ts`
**Status:** 🚧 Planned
**Planned:** Phase 2.1

Will include:
- Transactional email sending
- Template usage
- Error handling
- Rate limit handling

---

## How to Use This Library

### For Developers (Manual Integration)

1. **Copy the pattern file** to your project
2. **Install dependencies** listed in the pattern
3. **Set up environment variables**
4. **Follow the usage guide** in the pattern file

### For Orchestrator (Automatic Integration)

When the orchestrator detects external service usage, it should:

1. **Detect SDK import**
   ```typescript
   // Detected: import { cloudinary } from 'cloudinary';
   ```

2. **Inject proven pattern**
   ```bash
   # Copy pattern to project
   cp lib/integration-patterns/cloudinary/avatar-upload.ts \
      "$PROJECT_PATH/src/utils/cloudinaryUpload.ts"
   ```

3. **Reference pattern in generated code**
   ```typescript
   import { uploadAvatar } from '@/utils/cloudinaryUpload';
   ```

**Future:** Phase 3 will automate this detection and injection.

---

## Pattern Structure

Each pattern follows this structure:

```
<service>/
├── README.md                    # Service overview
├── <pattern-name>.ts            # Implementation
├── <pattern-name>.test.ts       # Tests
└── examples/
    ├── express-route.ts         # Express example
    ├── remix-action.ts          # Remix/React Router example
    └── nextjs-api-route.ts      # Next.js example
```

---

## Creating New Patterns

### Requirements

1. **Must be tested in production** - No theoretical code
2. **Must include common pitfalls section** - Document what NOT to do
3. **Must include debugging tips** - Help users troubleshoot
4. **Must be fully typed** - TypeScript with strict mode
5. **Must include tests** - Unit tests for critical paths

### Template

Use this template for new patterns:

```typescript
/**
 * <Service> <Feature> Pattern
 *
 * ✅ PROVEN CORRECT - Tested and validated
 * Version: 1.0.0
 * Last Updated: YYYY-MM-DD
 *
 * Brief description of what this pattern does.
 * Based on real-world implementation in <project>.
 *
 * ⚠️ IMPORTANT: Document critical warnings here
 */

// Types
export interface ServiceResponse {
  // Define response structure
}

// Configuration
export function configureService(): void {
  // Setup code
}

// Main function
export async function doSomething(
  params: string
): Promise<ServiceResponse> {
  // Implementation with error handling
}

/**
 * USAGE GUIDE
 * ===========
 * Step-by-step usage instructions
 */

/**
 * COMMON PITFALLS TO AVOID
 * =========================
 * ❌ DON'T: Specific things to avoid
 * ✅ DO: Correct approaches
 */

/**
 * DEBUGGING TIPS
 * ==============
 * 1. Tip one
 * 2. Tip two
 */
```

### Submission Process

1. Test pattern in real project
2. Document all parameters and options
3. Add common pitfalls section
4. Create tests
5. Add examples for popular frameworks
6. Submit PR with pattern file

---

## Pattern Quality Standards

### ✅ Production-Ready

- Tested in at least one production project
- No known bugs
- Comprehensive error handling
- Full TypeScript types
- Usage examples for 3+ frameworks

### 🧪 Beta

- Tested in development environment
- May have edge cases
- Basic error handling
- TypeScript types present
- At least one usage example

### 🚧 Planned

- Not yet implemented
- Requirements documented
- Placeholder file exists

---

## Integration Detection

Future Phase 3 functionality will automatically detect external service usage:

```bash
# Scan for SDK imports
grep -r "from 'cloudinary'" src/ → Cloudinary detected
grep -r "from 'stripe'" src/ → Stripe detected
grep -r "from '@sendgrid'" src/ → SendGrid detected

# Inject proven pattern
if cloudinary_detected; then
  inject_pattern "cloudinary/avatar-upload"
fi
```

This prevents bugs like the `format: 'auto'` issue by using proven patterns instead of generating new code.

---

## Contributing

### Add a New Pattern

1. Create pattern file following template
2. Test in production project
3. Document thoroughly
4. Add to this README
5. Submit PR

### Report Pattern Bug

1. Open issue with:
   - Pattern name and version
   - Error message
   - Code that caused the error
   - Expected behavior

2. We'll investigate and update pattern

### Request New Pattern

Open issue with:
- Service name
- Use case description
- Why pattern is needed

---

## Related Documentation

- `docs/learnings/PHASE-2-FAILURE-ANALYSIS-001.md` - Why this library exists
- `docs/PHASE-3-REQUIREMENTS.md` - Future auto-detection plans
- `docs/improvements/GIT-WORKFLOW-AUTOMATION.md` - Phase 2.1 improvements

---

## Pattern Versioning

Patterns use semantic versioning:

- **Major (1.0.0 → 2.0.0)**: Breaking API changes
- **Minor (1.0.0 → 1.1.0)**: New features, backward compatible
- **Patch (1.0.0 → 1.0.1)**: Bug fixes, backward compatible

Each pattern includes version number and last updated date.

---

## Metrics

**Current Status:**
- ✅ Production-Ready Patterns: 1 (Cloudinary avatar upload)
- 🧪 Beta Patterns: 0
- 🚧 Planned Patterns: 2 (Stripe, SendGrid)
- 📊 Total Lines of Battle-Tested Code: ~350

**Success Metrics:**
- Bugs prevented by using patterns vs generating: TBD
- Developer time saved: TBD
- Pattern usage in orchestrator: TBD (Phase 3)

---

## License

Same as parent SpecSwarm/SpecLabs project.

---

**Last Updated:** 2025-01-16
**Maintainers:** SpecLabs Development Team
**Status:** Active Development (Phase 2.1)
