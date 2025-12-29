# SDLC Planning

Story planning with three-perspective review (business, technical, UX) aligned with event models.

## Philosophy

Planning should involve multiple perspectives to catch issues early:

- **Business**: Ensures value delivery and proper slice sizing
- **Technical**: Assesses feasibility, risks, and architectural alignment
- **UX**: Protects user experience coherence and accessibility

## Critical Mapping

| Event Model Concept | GitHub Issue Equivalent |
|---------------------|-------------------------|
| Vertical Slice | Story Issue (1:1) |
| GWT Scenarios | Acceptance Criteria |
| Chapter/Theme | Epic (parent issue) |

**This mapping is NON-NEGOTIABLE.** Each vertical slice becomes exactly one story.

## Features

- Plan individual slices as stories
- Three-perspective review (business, tech, UX)
- Create GitHub issues from event model slices
- Manage epics for chapters/themes
- View ready-to-implement issues

## Commands

| Command | Description |
|---------|-------------|
| `/plan slice <name>` | Plan a slice as story |
| `/plan review <name>` | Three-perspective review |
| `/plan create <name>` | Create GitHub issue |
| `/plan epic <name>` | Create epic from chapter |
| `/plan ready` | Show ready issues |

## Agents

| Agent | Perspective |
|-------|-------------|
| `story-planner` | Business - value, slice thinness, acceptance clarity |
| `story-architect` | Technical - complexity, risks, architectural alignment |
| `ux-consultant` | UX - journey coherence, accessibility, user mental model |

## Workflow Integration

1. Design workflow with `/event-model design <name>`
2. Generate acceptance criteria with `/event-model gwt <name>`
3. Plan as story with `/plan slice <name>`
4. Review from all perspectives with `/plan review <name>`
5. Create GitHub issue with `/plan create <name>`

## Dependencies

- **sdlc-core**: Memory protocol and shared conventions
- **github-issues** (optional): For enhanced issue management with gh-issue-ext

## License

MIT
