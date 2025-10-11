# Documentation Philosophy

**ALL planning documentation (Phases 1-5) must focus on DECISIONS and RATIONALE, NOT implementation details.**

## Core Principles

1. **ADRs Are Decision Records, Not Implementation Guides**
   - Document WHAT decision was made
   - Document WHY the decision was made (rationale, trade-offs)
   - Document WHAT alternatives were considered and WHY they were rejected
   - Do NOT provide detailed implementation code
   - Do NOT act as implementation tutorial

2. **Minimal Code Examples**
   - Include code ONLY when necessary to explain WHY a decision makes sense
   - Prefer pseudocode or conceptual examples over actual language syntax
   - Prefer Mermaid diagrams for architectural concepts
   - If actual code required: Keep it minimal (5-10 lines max per example)
   - Remove code examples that don't directly support the decision rationale

3. **Implementation Details Belong in Code, Not Docs**
   - ADRs should NOT specify exact struct fields, method signatures, or function bodies
   - Leave implementation details to domain-modeling and TDD agents
   - Focus on constraints and principles, not prescriptive solutions
   - Example: "Use typestate pattern for state machine" (good), not "impl SessionHandle<InputFocused> { pub fn send_text... }" (too detailed)

4. **Document-Specific Guidelines**
   - **REQUIREMENTS_ANALYSIS.md**: WHAT features, WHY they matter, WHAT success looks like (no HOW)
   - **EVENT_MODEL.md**: Business events and event models (no implementation tech)
   - **ADRs**: Architectural decisions with rationale (no implementation code)
   - **ARCHITECTURE.md**: High-level system design synthesizing ADR decisions (no detailed code)
   - **STYLE_GUIDE.md**: Design patterns and visual specifications (no implementation tech)

5. **When Code Examples Are Appropriate**
   - Comparing two architectural approaches (show difference, not full impl)
   - Illustrating a non-obvious pattern (e.g., typestate transformation)
   - Explaining a critical constraint (e.g., why certain API is impossible)
   - Maximum: 10 lines per example, focus on concept not completeness

## What Good ADRs Look Like

**Good ADR (Decision Focus):**
```
## Decision

Use hexagonal architecture with ports and adapters.

## Rationale

1. **Testability**: Ports enable black-box testing with test adapters
2. **Flexibility**: Can swap infrastructure without touching domain
3. **Clarity**: Explicit boundaries between layers

[Optional: 5-line pseudocode showing port concept]
```

**Bad ADR (Implementation Guide):**
```
## Decision

[50 lines of Rust code showing exact trait definitions]
[30 lines showing exact struct implementations]
[20 lines showing exact test setup]
```

## Agent Responsibilities

- **product-manager**: NO implementation details in requirements
- **technical-architect**: Decision rationale, not implementation guides
- **ux-ui-design-expert**: Design patterns, not implementation code
- **domain-modeling agents**: Create actual implementation (informed by ADRs)
- **TDD agents**: Drive implementation details through tests
