---
description: Atomic Design methodology for UI component systems
user-invocable: false
---

# Design System (Atomic Design)

For applications with user interfaces (web apps, mobile apps), use Brad Frost's Atomic Design methodology. **Skip for CLI tools and libraries.**

## Prerequisites

- Architecture decisions complete (`docs/ARCHITECTURE.md` exists)
- Event model workflows have wireframes (if using event modeling)

## The Hierarchy

| Level | Description | Examples |
|-------|-------------|----------|
| Atoms | Basic elements | Buttons, inputs, labels, icons |
| Molecules | Simple combinations | Form fields, cards, search bars |
| Organisms | Complex components | Navigation, data tables, forms |
| Templates | Page layouts | Dashboard, list view, detail view |

## The Process

1. Analyze wireframes for common UI patterns
2. Gather visual style preferences from user
3. Create design tokens (colors, typography, spacing)
4. Build atomic hierarchy: atoms -> molecules -> organisms -> templates
5. Map read models to component data requirements

## Artifacts Location

`docs/design-system/`

## Integration with Workflow

- **Uses**: Event model wireframes to identify needed components
- **Uses**: Read models to define component data requirements
- **Informs**: Story implementation (stories reference design system components)
- **Reviewed by**: `sdlc:ux` agent

## When to Skip

- CLI tools (no visual UI)
- Libraries (no user-facing interface)
- APIs without frontend (backend-only services)
