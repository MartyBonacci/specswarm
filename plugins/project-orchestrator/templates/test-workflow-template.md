# Test: [Task Name]

**Created**: YYYY-MM-DD
**Project**: [project-name]
**Complexity**: [Simple/Medium/Complex]
**Estimated Time**: [1-2h / 2-4h / 4-8h]

---

## Description

[Clear description of what needs to be done]

**Example**:
Fix missing Vite configuration that prevents React Router v7 from running in development mode.

---

## Files to Modify

List all files that need changes:

- `path/to/file1.ts`
- `path/to/file2.tsx`
- `path/to/file3.css`

**Example**:
- `vite.config.ts` (create new file)
- `package.json` (update scripts if needed)

---

## Changes Required

Detailed description of what changes to make and why.

**Example**:
Create `vite.config.ts` in project root with:
1. Import React Router Vite plugin
2. Configure plugin with SSR support
3. Set up development server port (5173)
4. Enable React plugin for JSX support

The configuration must support:
- Server-side rendering for React Router v7
- HMR (Hot Module Replacement)
- TypeScript compilation
- React JSX transformation

---

## Expected Outcome

What should work after the changes are complete?

**Example**:
- Dev server starts without errors: `npm run dev`
- Application loads at http://localhost:5173
- React components render correctly
- HMR works (changes reflect immediately)
- No console errors related to Vite config

---

## Validation Criteria

Checklist of things to verify:

- [ ] Dev server starts successfully
- [ ] No console errors
- [ ] Application loads in browser
- [ ] All expected UI elements visible
- [ ] Navigation works (if applicable)
- [ ] No network errors (check Network tab)

---

## Test URL

Default URL to validate:
```
http://localhost:5173
```

Or specific page:
```
http://localhost:5173/signup
```

---

## Additional Context

Any other information that helps complete the task:

**Tech Stack**:
- React Router v7 (framework mode)
- Vite
- TypeScript
- React

**Reference**:
- [Link to docs if applicable]
- [Link to similar implementation]

---

## Success Metrics (Phase 0)

Track these for Phase 0 evaluation:

- **Agent Understanding**: Did agent understand task? (Yes/No)
- **First-Try Success**: Did agent complete on first try? (Yes/No)
- **Iteration Count**: Number of attempts needed (1, 2, 3+)
- **Time to Complete**: Actual time taken (minutes)
- **Quality Score**: Code quality (1-10)
- **Validation Pass**: Did validation pass? (Yes/No)

---

**Template Version**: 0.1.0-alpha.1
**For**: Project Orchestrator Plugin (Phase 0)
