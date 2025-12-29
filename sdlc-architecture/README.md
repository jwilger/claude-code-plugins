# SDLC Architecture

Architecture Decision Records (ADRs) and ARCHITECTURE.md management.

## Philosophy

This plugin implements the **events/projection pattern** for architectural documentation:

- **ADRs are events**: Immutable historical records of WHY decisions were made
- **ARCHITECTURE.md is a projection**: The current state, derived from accepted ADRs, but standalone

## Features

- Create and manage ADRs with proper structure
- Synthesize accepted ADRs into ARCHITECTURE.md
- Track ADR lifecycle: proposed → accepted/rejected → superseded
- ARCHITECTURE.md never references ADRs (stands alone)

## Commands

| Command | Description |
|---------|-------------|
| `/architect decide <topic>` | Create new ADR |
| `/architect accept <number>` | Accept proposed ADR |
| `/architect reject <number>` | Reject proposed ADR |
| `/architect supersede <old> <new>` | Mark ADR superseded |
| `/architect synthesize` | Update ARCHITECTURE.md from accepted ADRs |
| `/architect list` | List all ADRs |
| `/architect show <number>` | Show specific ADR |

## Agents

| Agent | Role |
|-------|------|
| `adr-writer` | Creates ADRs focusing on WHY (rationale, alternatives, trade-offs) |
| `architecture-synthesizer` | Projects accepted ADRs into standalone ARCHITECTURE.md |

## ADR Structure

ADRs are stored in `docs/adr/ADR-NNN-<title>.md`:

```markdown
# ADR-NNN: <Decision Title>

## Status
proposed | accepted | rejected | superseded by ADR-XXX

## Context
[Forces at play, constraints, requirements]

## Decision
[What was decided]

## Rationale
[Why this decision - trade-offs, key factors]

## Alternatives Considered
[What else was considered and why rejected]

## Consequences
[Positive and negative impacts]
```

## ARCHITECTURE.md

The synthesized architecture document lives at `docs/ARCHITECTURE.md` and includes:
- Overview and system context
- Architecture principles
- Component architecture
- Data architecture
- Integration patterns
- Cross-cutting concerns
- Technology stack

## Dependencies

- **sdlc-core**: Memory protocol and shared conventions

## License

MIT
