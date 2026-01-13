---
description: INVOKE when making architecture decisions. Creates/manages ADRs with status tracking
argument-hint: [action] [topic]
agent: sdlc:adr
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
  - mcp__memento__semantic_search
  - mcp__memento__create_entities
hooks:
  Stop:
    - hooks:
        - type: prompt
          prompt: |
            Before completing, store any architectural decisions made in this session to memento.
            Output ONLY: {"ok": true}
---

# SDLC Architecture Decision Records

Manage Architecture Decision Records (ADRs). ADRs are immutable historical records documenting WHY architectural decisions were made.

## The Pattern

ADRs are immutable events recording WHY decisions were made. ARCHITECTURE.md is a projection showing WHAT the current architecture is.

## Arguments

`$ARGUMENTS` may contain:
- `decide <topic>` - Create new ADR for a decision
- `accept <number>` - Accept a proposed ADR
- `reject <number>` - Reject a proposed ADR
- `supersede <number>` - Supersede an ADR with a new decision
- `synthesize` - Update ARCHITECTURE.md from accepted ADRs
- `list` - List all ADRs
- (no args) - Show help

## Steps

### 1. Check/Create ADR Directory

```bash
mkdir -p docs/adr
```

### 2. Search Memento for Context

```
mcp__memento__semantic_search: "architecture decisions [project-name]"
```

Load any existing architectural context.

### 3. Execute Action

#### `decide <topic>` - Create New ADR

Get the next ADR number:
```bash
ls docs/adr/*.md 2>/dev/null | wc -l
```

Guide the user through the ADR creation process:
1. What is the context/problem?
2. What options were considered?
3. What decision was made and WHY?
4. What are the consequences (positive and negative)?

Create docs/adr/<number>-<slug>.md with:
- Status: proposed
- Date: today
- Context
- Decision
- Consequences

Focus on WHY, not HOW. The implementation details go elsewhere.

ADR Lifecycle:
```
proposed → accepted → implemented
    ↓          ↓
rejected   superseded
```

ADR Template:
```markdown
# ADR-<number>: <Title>

**Status**: proposed | accepted | rejected | superseded by ADR-X
**Date**: YYYY-MM-DD

## Context

What is the issue that we're seeing that motivates this decision?

## Decision

What is the change that we're proposing and/or doing?

## Consequences

What becomes easier or more difficult because of this decision?

### Positive
- ...

### Negative
- ...

### Neutral
- ...
```

#### `accept <number>` - Accept ADR

Update the ADR status:
```
Status: proposed → accepted
```

Then trigger architecture synthesis:
```
After accepting, run synthesize to update ARCHITECTURE.md.
```

#### `reject <number>` - Reject ADR

Update the ADR status:
```
Status: proposed → rejected
```

Add rejection reason if provided.

#### `supersede <number>` - Supersede ADR

1. Create a new ADR with the updated decision
2. Update old ADR: `Status: superseded by ADR-<new-number>`
3. New ADR should reference: `Supersedes: ADR-<old-number>`

#### `synthesize` - Update ARCHITECTURE.md

Read all accepted ADRs and synthesize into a standalone architecture document.

The ARCHITECTURE.md must:
1. Be STANDALONE - never reference ADRs by number
2. Describe the CURRENT architecture
3. Focus on WHAT, not historical WHY
4. Be readable without knowing ADR history

Structure:
- Overview
- Key Components
- Design Principles
- Patterns Used
- Constraints and Trade-offs

Write to docs/ARCHITECTURE.md

#### `list` - List All ADRs

```bash
ls -1 docs/adr/*.md 2>/dev/null
```

Display:
```
Architecture Decision Records:

ADR-001: Use PostgreSQL for persistence [accepted]
ADR-002: Event sourcing for core domain [accepted]
ADR-003: GraphQL API [proposed]
ADR-004: Microservices vs monolith [rejected]

Total: 4 ADRs (2 accepted, 1 proposed, 1 rejected)
```

### 4. Store in Memento

After creating/updating ADRs:

```
mcp__memento__create_entities:
  name: "ADR-<number>: <title> [date]"
  entityType: "architecture_decision"
  observations:
    - "Project: <name> | Scope: PROJECT_SPECIFIC"
    - "Status: <status>"
    - "Decision: <brief summary>"
    - "Key consequence: <main tradeoff>"
```

### 5. Display Results

After ADR creation:
```
ADR created: docs/adr/003-graphql-api.md

Status: proposed

To accept this ADR:
  /sdlc:adr accept 3

To update architecture docs after accepting:
  /sdlc:adr synthesize
```
