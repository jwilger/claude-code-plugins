---
name: architecture-collaboration
description: Guides collaborative ADR creation with user during Phase 3. Facilitates pair-programming on architectural decision records using IDE diff modification flow and QUESTION: comments. User has final authority on all architectural decisions.
allowed-tools: [Read, Edit, Write, Glob, Grep, WebSearch, WebFetch, mcp__memento__create_entities, mcp__memento__create_relations, mcp__memento__add_observations, mcp__memento__semantic_search, mcp__memento__open_nodes, mcp__time__get_current_time, AskUserQuestion]
---

# Architecture Collaboration Skill

Guides main conversation on how to collaborate with user during Phase 3: Architectural Decision Records (ADRs).

## Core Principle

**User has final authority on all architectural decisions. AI provides options and analysis, user decides.**

## Collaboration Protocol

### 1. Advisory Agent Consultation

When architectural decisions needed:

1. Call adr-writer agent for research/recommendations
2. Agent analyzes requirements, event model, existing ADRs
3. Agent returns ADR draft recommendations with alternatives (NO file editing)
4. Main conversation receives recommendations

### 2. Collaborative ADR Creation Loop

**DO NOT** write ADR files autonomously. Instead:

1. **Propose one ADR section at a time**:
   - Present Context section first (what forces are at play)
   - Then Decision section (what is proposed)
   - Then Rationale (why this choice)
   - Then Consequences (positive/negative outcomes)
   - Then Alternatives Considered
   - Use IDE diff modification for each section

2. **Acknowledge user modifications**:
   - "I see you chose alternative X instead. That prioritizes..."
   - "I understand you reject this decision. The concern is..."
   - "You've added consequence Y. That's an important consideration..."
   - Engage in architectural dialogue

3. **Answer QUESTION: comments**:
   - User adds `QUESTION: What about scalability?` inline
   - Main conversation answers with architectural analysis
   - Remove QUESTION: prefix after answering

4. **Iterate until user approves**:
   - Status starts as "proposed"
   - User changes to "accepted" to approve decision
   - User changes to "rejected" if decision not approved
   - Only "accepted" ADRs are implemented

### 3. Architecture-Specific Patterns

**Decision Focus, Not Implementation:**

- ADRs document WHAT was decided and WHY
- ADRs do NOT contain implementation code
- Focus on constraints, principles, patterns (not specifics)
- Leave implementation to domain-modeling and TDD phases

**Alternatives Analysis:**

- Always present multiple options
- Analyze trade-offs for each
- Let user choose based on their priorities
- Document why alternatives were rejected

**Dependency Management:**

- Some ADRs depend on others
- Some ADRs supersede older ones
- Use memento to track ADR relationships

### 4. Memento Integration

**Record architectural decisions:**

```json
{
  "entities": [{
    "name": "ADR-XXX: [Decision Summary]",
    "entityType": "architectural_decision",
    "observations": [
      "Project: [project] | Scope: PROJECT_SPECIFIC",
      "Status: [proposed|accepted|rejected|superseded]",
      "Decision: [what was decided]",
      "Rationale: [why user chose this]",
      "Alternatives: [what was rejected and why]",
      "Date: [timestamp]"
    ]
  }]
}
```

**Create relationships:**

```json
{
  "relations": [{
    "from": "ADR-023: New Approach",
    "to": "ADR-015: Old Approach",
    "relationType": "supersedes"
  }]
}
```

### 5. ARCHITECTURE.md Synthesis

**After any ADR status changes to/from "accepted":**

1. Call architecture-synthesizer agent
2. Agent updates ARCHITECTURE.md to reflect all accepted ADRs
3. Collaborate with user on architecture document
4. ARCHITECTURE.md is projection of accepted ADRs

### 6. Phase Completion

Before moving to Phase 4 (Design System):

- ✅ All necessary ADRs created collaboratively
- ✅ User has approved/rejected each ADR (set status)
- ✅ ARCHITECTURE.md reflects all accepted ADRs
- ✅ All QUESTION: comments resolved
- ✅ Key decisions stored in memento
- ✅ ADRs focus on decisions, not implementation

## QUESTION: Comment Examples

### In ADR Context Section

```markdown
## Context

The system needs to handle concurrent updates to shared resources.

QUESTION: What's the expected concurrency level? Are we talking 10s, 100s, or 1000s of concurrent users?

Currently, we have no locking mechanism.
```

### In ADR Rationale Section

```markdown
## Rationale

Optimistic locking chosen because:
- Lower latency than pessimistic locking
- Reduces database connection hold time

QUESTION: Should we use version numbers or timestamps for optimistic locking?

Conflicts are expected to be rare based on usage patterns.
```

### In Alternatives Considered

```markdown
## Alternatives Considered

### Alternative 1: Pessimistic Locking

QUESTION: Did we benchmark pessimistic locking performance? What were the results?

Rejected because...
```

## Collaboration Anti-Patterns

❌ **Don't**: Write complete ADR and ask for rubber-stamp approval
✅ **Do**: Propose sections iteratively, collaborate on each

❌ **Don't**: Make architectural decisions on user's behalf
✅ **Do**: Present options with analysis, user decides

❌ **Don't**: Include implementation code in ADRs
✅ **Do**: Focus on decision and rationale, defer implementation

❌ **Don't**: Skip alternatives analysis
✅ **Do**: Always present and analyze multiple options

## ADR Status Workflow

1. **Proposed**: Draft ADR created collaboratively
2. **User Review**: User edits, asks questions, requests changes
3. **User Decision**:
   - Sets status to "accepted" → Becomes part of architecture
   - Sets status to "rejected" → Not implemented
4. **If Accepted**: architecture-synthesizer updates ARCHITECTURE.md
5. **If Later Superseded**: New ADR created with supersedes relationship

## Success Criteria

Architecture collaboration is successful when:

- User has made informed decisions (understood trade-offs)
- User feels ownership of architectural choices
- ADRs clearly document decisions and rationale
- Alternatives were properly analyzed
- User approved/rejected each ADR explicitly
- ARCHITECTURE.md accurately reflects accepted ADRs
- Key decisions documented in memento
