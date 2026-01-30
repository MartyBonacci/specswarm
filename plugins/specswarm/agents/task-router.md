# Task Router Configuration

## Agent Type Mappings

This file defines how tasks are routed to specialist agents based on content analysis.

### Frontend Tasks → react-typescript-specialist
Keywords: component, UI, frontend, React, JSX, TSX, form, button, input, modal, dialog, page, view, hook, useState, useEffect, props, children, render

### Design Tasks → ui-designer
Keywords: design, layout, styling, CSS, SCSS, Tailwind, theme, color, typography, spacing, responsive, mobile, animation, UX

### Architecture Tasks → system-architect
Keywords: architecture, schema, database, API, endpoint, route, model, migration, relationship, ERD, system, integration

### Functional Programming → functional-patterns
Keywords: functional, pure function, compose, pipe, transform, map, filter, reduce, curry, immutable, Either, Result, Option

### Type System → react-typescript-specialist
Keywords: type, interface, TypeScript, generic, enum, union, intersection, utility type, infer

### Default → general-purpose
All other tasks that don't match specific patterns.

## Priority Rules

1. If task matches multiple categories, use this priority:
   - Architecture > Frontend > Design > Functional > Default
2. If task explicitly mentions an agent type, use that type
3. If uncertain, use general-purpose (safer default)

## Agent Capabilities Reference

| Agent Type | Strengths | Use For |
|------------|-----------|---------|
| react-typescript-specialist | React, TypeScript, hooks, components | UI implementation, type definitions |
| ui-designer | Visual design, layouts, color theory | Design decisions (research only, no code) |
| system-architect | System design, databases, APIs | Architectural decisions, schema design |
| functional-patterns | FP patterns, composition, immutability | Data transformations, utility functions |
| general-purpose | Broad capabilities | Default fallback, mixed tasks |

## Routing Algorithm

```
function routeTask(taskContent):
    content = lowercase(taskContent)

    # Check architecture first (highest priority)
    if matches(content, ARCHITECTURE_KEYWORDS):
        return "system-architect"

    # Check frontend
    if matches(content, FRONTEND_KEYWORDS):
        return "react-typescript-specialist"

    # Check design
    if matches(content, DESIGN_KEYWORDS):
        return "ui-designer"

    # Check functional
    if matches(content, FUNCTIONAL_KEYWORDS):
        return "functional-patterns"

    # Default
    return "general-purpose"
```

## Notes

- ui-designer is research-only and should not write implementation code
- react-typescript-specialist handles both React components AND TypeScript types
- system-architect should be used sparingly (only for true architectural work)
- general-purpose is the safe default when uncertain
