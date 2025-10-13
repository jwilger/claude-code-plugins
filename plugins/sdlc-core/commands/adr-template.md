---
description: Load Architectural Decision Record (ADR) template and structure
disable-model-invocation: false
---

# Architectural Decision Record (ADR) Template and Guidelines

## ADR Structure

Each ADR should follow this structure:

### Title
- Use format: "ADR-XXX: [Decision Summary]"
- Example: "ADR-001: Use Hexagonal Architecture with Ports and Adapters"

### Status
- **proposed**: Decision under consideration, awaiting user approval
- **accepted**: Decision approved and should guide implementation
- **rejected**: Decision considered but not approved
- **superseded**: Decision replaced by a newer ADR (reference replacement ADR)

### Context
- What forces are at play (technical, political, social, project constraints)?
- What is the issue we're trying to address?
- Why does this decision need to be made now?

### Decision
- What is the change we're proposing or have agreed to implement?
- State clearly and concisely what was decided
- Focus on WHAT was decided, not HOW to implement it

### Rationale
- Why did we make this decision?
- What alternatives did we consider?
- What are the trade-offs?
- What are the key factors that led to this decision?

### Consequences
- What becomes easier or more difficult as a result of this decision?
- What are the positive outcomes?
- What are the negative outcomes or constraints?
- What future decisions does this enable or constrain?

### Alternatives Considered
- What other options were evaluated?
- Why were they rejected?
- What would be the implications of each alternative?

## Documentation Philosophy: Decision Focus vs Implementation Details

**ADRs Are Decision Records, NOT Implementation Guides**

### What ADRs Should Contain

- **WHAT** decision was made
- **WHY** the decision was made (rationale, trade-offs)
- **WHAT** alternatives were considered and **WHY** they were rejected
- **CONSEQUENCES** of the decision (positive and negative)

### What ADRs Should NOT Contain

- Detailed implementation code
- Exact struct fields, method signatures, or function bodies
- Step-by-step implementation instructions
- Complete code examples that act as tutorials

### The Key Principle

> ADRs document architectural DECISIONS and their RATIONALE, not implementation DETAILS.

Leave implementation details to:
- **domain-modeling agents**: Create actual type implementations
- **TDD agents**: Drive implementation details through tests

Focus ADRs on:
- **Constraints and principles**: What rules must be followed?
- **High-level patterns**: What architectural approach are we taking?
- **Trade-off analysis**: Why did we choose this over alternatives?

## Minimal Code Examples Guidelines

Code examples in ADRs should be **rare and minimal**:

### When Code Examples Are Appropriate

1. **Comparing architectural approaches**: Show difference, not full implementation
   - Example: Demonstrate difference between callback vs. async/await pattern
   - Keep to 5-10 lines per approach

2. **Illustrating a non-obvious pattern**: Show concept, not complete solution
   - Example: Typestate pattern transformation
   - Focus on the unique aspect being explained

3. **Explaining a critical constraint**: Show why certain API is impossible or required
   - Example: Demonstrate why trait bounds are necessary
   - Highlight the constraint, not the solution

### Code Example Best Practices

- **Maximum 10 lines per example**
- **Prefer pseudocode** over actual language syntax when possible
- **Prefer Mermaid diagrams** for architectural concepts
- **Focus on concept**, not completeness
- **Remove code** that doesn't directly support the decision rationale

### Example: Good vs Bad ADR

**Good ADR (Decision Focus):**
```markdown
## Decision

Use hexagonal architecture with ports and adapters.

## Rationale

1. **Testability**: Ports enable black-box testing with test adapters
2. **Flexibility**: Can swap infrastructure without touching domain
3. **Clarity**: Explicit boundaries between layers

## Consequences

- Positive: Easy to test domain logic in isolation
- Positive: Infrastructure can evolve independently
- Negative: More initial boilerplate for port definitions

[Optional: 5-line pseudocode showing port concept]
```

**Bad ADR (Implementation Guide):**
```markdown
## Decision

[50 lines of Rust code showing exact trait definitions]
[30 lines showing exact struct implementations]
[20 lines showing exact test setup]
```

## ARCHITECTURE.md Update Requirement

**MANDATORY**: ARCHITECTURE.md MUST be updated whenever ANY ADR changes status to/from "accepted"

### When to Update ARCHITECTURE.md

1. **ADR status changes to "accepted"**: Add the architectural decision to ARCHITECTURE.md
2. **ADR status changes from "accepted"**: Update ARCHITECTURE.md to reflect superseded decision
3. **ADR is rejected**: No update needed (decision not part of architecture)

### What to Update in ARCHITECTURE.md

- **High-level synthesis**: Integrate accepted decision into overall architecture description
- **Architectural diagrams**: Update diagrams to reflect new decision
- **Cross-cutting concerns**: Show how decision affects multiple components
- **Consistency**: Ensure all accepted ADRs are reflected in architecture

The ARCHITECTURE.md file is a **projection** of all accepted ADRs into a cohesive system design.

## Status Lifecycle

```
proposed → accepted → implemented
    ↓          ↓
rejected   superseded (by newer ADR)
```

- Start all new ADRs with **proposed** status
- User must approve before changing to **accepted**
- Update to **superseded** when replaced by newer ADR (include reference)
- Change to **rejected** if decision not approved

## Agent Responsibilities

- **technical-architect**: Creates ADRs, proposes decisions, updates status
- **User**: Final approval authority, reviews and approves/rejects decisions
- **technical-architect**: Updates ARCHITECTURE.md when ADR status changes
- **domain-modeling agents**: Implement accepted decisions (don't define them)
- **TDD agents**: Test implementations (don't define architecture)

This process methodology is now loaded and active for your current task.
