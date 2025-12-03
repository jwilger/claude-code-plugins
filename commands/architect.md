---
description: Architecture decision management - ADRs and ARCHITECTURE.md
argument-hint: [action] [topic]
---

# Architect Command

You are facilitating architectural documentation following the ADR (events) → ARCHITECTURE.md (projection) pattern.

**Arguments provided:** $ARGUMENTS

## Determine the Action

| If args contain... | Action |
|-------------------|--------|
| `decide <topic>` or `adr <topic>` | Create new ADR |
| `accept <adr-number>` | Accept an ADR |
| `reject <adr-number>` | Reject an ADR |
| `supersede <old> <new>` | Mark ADR superseded |
| `synthesize` or `sync` | Update ARCHITECTURE.md |
| `list` | List all ADRs |
| `show <adr-number>` | Show specific ADR |
| (no args or `help`) | Show help |

## Execute the Action

### For New ADR (`decide <topic>`, `adr <topic>`)

Use the Task tool with `subagent_type="adr-writer"`:

Prompt: `Create an ADR for: <topic>. Write to docs/adr/ADR-NNN-<topic-slug>.md with status "proposed". Focus on WHY - rationale, alternatives, trade-offs.`

After the agent returns:
1. Show the user the proposed ADR
2. Ask for approval, modifications, or questions
3. If modifications needed, edit the ADR

### For Accept (`accept <adr-number>`)

1. Read the ADR at `docs/adr/ADR-<number>-*.md`
2. Change status from "proposed" to "accepted"
3. Automatically trigger synthesis (update ARCHITECTURE.md)

### For Reject (`reject <adr-number>`)

1. Read the ADR at `docs/adr/ADR-<number>-*.md`
2. Change status from "proposed" to "rejected"
3. ADR remains for historical record (not deleted)

### For Supersede (`supersede <old-number> <new-number>`)

1. Update old ADR status to "superseded by ADR-<new-number>"
2. Trigger synthesis to update ARCHITECTURE.md

### For Synthesize (`synthesize`, `sync`)

Use the Task tool with `subagent_type="architecture-synthesizer"`:

Prompt: `Read all accepted ADRs in docs/adr/ and synthesize into docs/ARCHITECTURE.md. The output must be standalone - it must NOT reference ADRs. ARCHITECTURE.md is the working document for implementation.`

After synthesis:
1. Show user the changes made
2. Confirm ARCHITECTURE.md stands alone

### For List (`list`)

```bash
ls -la docs/adr/
```

Display ADRs with their status (read first line of each to get status).

### For Show (`show <adr-number>`)

Read and display the specified ADR.

### For Help (no args)

Display:

```
/architect - Architecture Decision Management

Actions:
  /architect decide <topic>        - Create new ADR
  /architect accept <number>       - Accept proposed ADR
  /architect reject <number>       - Reject proposed ADR
  /architect supersede <old> <new> - Mark ADR superseded
  /architect synthesize            - Update ARCHITECTURE.md
  /architect list                  - List all ADRs
  /architect show <number>         - Show specific ADR

The Pattern:
  ADRs = Events (immutable historical records of WHY)
  ARCHITECTURE.md = Projection (standalone working document)

Key Principles:
  - ADRs document WHY decisions were made
  - ARCHITECTURE.md NEVER references ADRs
  - ARCHITECTURE.md is what you consult during implementation
  - ADRs are for understanding history or revisiting decisions

Agents: adr-writer, architecture-synthesizer
Docs: ~/.claude/docs/adr/ADR_TEMPLATE.md
```

## ADR Numbering

When creating a new ADR:
1. List existing ADRs to find highest number
2. Use next sequential number (001, 002, etc.)
3. Slugify the topic for filename (lowercase, hyphens)
