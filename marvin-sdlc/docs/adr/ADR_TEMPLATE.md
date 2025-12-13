# ADR Template

Use this template when creating Architecture Decision Records.

## File Naming

```
docs/adr/ADR-NNN-<title-slug>.md
```

Examples:
- `ADR-001-use-event-sourcing.md`
- `ADR-002-hexagonal-architecture.md`
- `ADR-003-postgres-for-event-store.md`

## Template

```markdown
# ADR-NNN: <Decision Title>

## Status

proposed | accepted | rejected | superseded by ADR-XXX

## Context

What is the issue we're addressing?

- Technical constraints
- Business requirements
- Team capabilities
- Time pressures
- Dependencies on other decisions

Be specific about the forces at play. This section should make it clear
WHY this decision needs to be made.

## Decision

What was decided? State clearly and concisely.

Focus on WHAT, not HOW. Implementation details belong in ARCHITECTURE.md
after this ADR is accepted.

## Rationale

Why this decision over alternatives?

- Key factors that led to this choice
- Trade-offs we're accepting
- Risks we're acknowledging
- Principles or values that guided us

This is the most important section - it's WHY we're creating ADRs.

## Alternatives Considered

### Alternative A: <Name>

**Description:** What this alternative involves.

**Why rejected:**
- Reason 1
- Reason 2

### Alternative B: <Name>

**Description:** What this alternative involves.

**Why rejected:**
- Reason 1
- Reason 2

## Consequences

### Positive

- What becomes easier
- What's now possible
- Benefits we gain

### Negative

- What becomes harder
- Constraints we're accepting
- Technical debt introduced
- Future flexibility reduced

### Neutral

- Changes that are neither good nor bad
- Things that will just be different
```

## Status Lifecycle

```
proposed → accepted → (implemented)
    ↓          ↓
rejected   superseded
```

- **proposed**: Under consideration, awaiting approval
- **accepted**: Approved, ready to inform ARCHITECTURE.md
- **rejected**: Not approved, kept for historical record
- **superseded**: Replaced by a newer ADR (reference which one)

## Guidelines

### Keep It Concise

ADRs should be readable in 5 minutes. If it's getting long, you might be:
- Including too much implementation detail
- Combining multiple decisions (split into separate ADRs)
- Writing documentation instead of recording a decision

### Focus on WHY

The most valuable part of an ADR is understanding WHY a decision was made.
Future readers want to know:
- What constraints existed at the time
- What trade-offs were considered
- Why alternatives were rejected

### Avoid Implementation Details

**Bad:**
```markdown
## Decision
We will use the following Rust struct for events:
\`\`\`rust
pub struct Event {
    pub id: Uuid,
    pub aggregate_id: String,
    // 50 more lines...
}
\`\`\`
```

**Good:**
```markdown
## Decision
We will use event sourcing for the order domain, storing events in
PostgreSQL with a single events table per aggregate type.
```

### Minimal Code Examples

If code examples are needed, keep them to 5-10 lines illustrating a concept,
not a complete implementation.

### One Decision Per ADR

Each ADR should cover ONE architectural decision. If you find yourself
writing "and also..." - that's probably a separate ADR.

## Relationship to ARCHITECTURE.md

- **ADRs** = Events (historical record of WHY decisions were made)
- **ARCHITECTURE.md** = Projection (current state, standalone document)

ARCHITECTURE.md should NEVER reference ADRs. It stands alone as the
working document that developers consult during implementation.

When an ADR is accepted, the architecture-synthesizer agent updates
ARCHITECTURE.md to reflect the decision without referencing the ADR.
