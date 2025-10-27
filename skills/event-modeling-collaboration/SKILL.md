---
name: event-modeling-collaboration
description: Guides collaborative event model design with user during Phase 2. Facilitates pair-programming on event model documentation using IDE diff modification flow and QUESTION: comments. Use when working on event modeling (12-step process).
allowed-tools: [Read, Glob, Grep, WebSearch, WebFetch, mcp__memento__create_entities, mcp__memento__create_relations, mcp__memento__add_observations, mcp__memento__semantic_search, mcp__memento__open_nodes, mcp__time__get_current_time, AskUserQuestion]
---

# Event Modeling Collaboration Skill

Guides main conversation on how to collaborate with user during Phase 2: Event Modeling (12-step process).

## Core Principle

**User is co-creator of event models, not reviewer of AI-generated models.**

## Collaboration Protocol

### 1. Step-by-Step Advisory Consultation

For each of the 12 event modeling steps:

1. Call appropriate event-modeling-step-N agent for recommendations
2. Agent analyzes requirements/existing model and returns recommendations (NO file editing)
3. Main conversation receives step-specific recommendations

### 2. Collaborative Refinement Loop

**DO NOT** write event model files autonomously. Instead:

1. **Propose one component at a time**:
   - Present recommendation for specific event/command/UI/projection
   - Use IDE diff modification so user can edit directly
   - User reviews, modifies, approves via IDE

2. **Acknowledge user modifications**:
   - "I see you renamed EventX to EventY. That's clearer because..."
   - "I understand you want to split this event. Consider that..."
   - Engage in dialogue about event model design choices

3. **Answer QUESTION: comments**:
   - User adds `QUESTION: Should this be one event or two?` inline
   - Main conversation answers directly in event model file
   - Remove QUESTION: prefix after answering

4. **Iterate until correct**:
   - Continue refining component with user
   - Move to next component only when current approved
   - User has final say on all event model structure

### 3. Event Modeling-Specific Patterns

**Step-by-Step Progression:**

- Work through steps 1-12 for ONE event model before starting next
- Each step builds on previous steps
- Don't move to next step until current step complete

**Component Types:**

- Events: Persistent state changes
- Commands: Business operations
- UI Screens: User interaction points
- Automations: System-triggered actions
- Projections: Read models
- Queries: Data retrieval
- Domain Types: Value objects

**Collaboration Points:**

- Event naming (business language vs technical terms)
- Event granularity (one vs multiple events)
- Command responsibilities (what belongs in command)
- UI screen layout (ASCII wireframes via ux-consultant)
- Data field types (domain types vs primitives)

### 4. Memento Integration

**Record event modeling decisions:**

```json
{
  "entities": [{
    "name": "Event Model Decision: [Topic]",
    "entityType": "event_model_decision",
    "observations": [
      "Project: [project] | Scope: PROJECT_SPECIFIC",
      "Event Model: [name]",
      "Decision: [what was decided]",
      "Rationale: [why user chose this approach]",
      "Step: [which step (1-12)]",
      "Date: [timestamp]"
    ]
  }]
}
```

### 5. Phase Completion

Before moving to Phase 3 (ADRs):

- ✅ All 12 steps completed for all event models
- ✅ event-modeling-pm review complete (business validation)
- ✅ event-modeling-architect review complete (technical validation)
- ✅ User has approved all event model documentation
- ✅ All QUESTION: comments resolved
- ✅ Key decisions stored in memento
- ✅ Cross-links between all components established

## QUESTION: Comment Examples

### In Event Document

```markdown
## Event: PaymentCaptured

### Data Fields

- transaction_id: String
QUESTION: Should this be a UUID or allow arbitrary strings from payment gateway?
- captured_amount: MonetaryAmount
- captured_at: Timestamp
```

### In Command Document

```markdown
## Command: CapturePayment

### Event Aggregation

Loads PaymentAuthorized event to get authorization_code.

QUESTION: Should we also load OrderCreated to validate amount, or trust authorization amount?

### Emits Events
...
```

## Collaboration Anti-Patterns

❌ **Don't**: Write all 12 steps for an event model and ask for approval
✅ **Do**: Propose one step/component, collaborate iteratively

❌ **Don't**: Create implementation code in event model docs
✅ **Do**: Focus on WHAT happens, not HOW it's implemented

❌ **Don't**: Skip user collaboration during step agent recommendations
✅ **Do**: Facilitate pair-programming on each component

❌ **Don't**: Treat event model as specification for autonomous implementation
✅ **Do**: Treat event model as collaborative design artifact

## Event Modeling Review Collaboration

**After event-modeling-pm review:**

- Present business validation findings
- Collaborate with user on addressing issues
- User decides which changes to make
- Iterate until business logic is sound

**After event-modeling-architect review:**

- Present architectural validation findings
- Collaborate with user on technical feasibility
- User decides which architectural approaches to use
- Iterate until model is technically sound

## Success Criteria

Event modeling collaboration is successful when:

- User feels ownership of event models (co-created, not reviewed)
- Event models capture business domain clearly
- All 12 steps properly executed with user participation
- User approved event model structure through iterative refinement
- Vertical slices are linear and complete
- Data lineage is traceable to external sources
- Key decisions documented in memento
