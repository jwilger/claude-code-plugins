---
description: INVOKE for domain discovery, workflow design, GWT generation, or architecture guidance
argument-hint: [discover|workflow|gwt|validate|arch|design-system] [name]
context: fork
allowed-tools:
  - Bash
  - Read
  - Write
  - Task
  - AskUserQuestion
  - mcp__memento__semantic_search
  - mcp__memento__create_entities
  - mcp__memento__create_relations
hooks:
  Stop:
    - hooks:
        - type: prompt
          prompt: |
            Before completing, store event model discoveries in memento:
            - Domain concepts discovered
            - Events, commands, and views identified
            - GWT scenarios created
            - Any deferred questions or open items

            Output ONLY: {"ok": true}
---

# SDLC Design

Design event model workflows following Martin Dilger's "Understanding Eventsourcing" methodology and Adam Dymitruk's Event Modeling approach. Event modeling is about **understanding the business domain**, not documentation. The AI facilitates by asking probing questions, challenging assumptions, and keeping focus on business behavior - not technical implementation.

**CRITICAL**: No architecture or technical decisions during event modeling. Those belong to architecture design phase. The ONLY exception is mandatory third-party integrations (note name and purpose only).

## Arguments

`$ARGUMENTS` may contain:
- `discover` - Start or continue domain discovery (required before first workflow)
- `workflow [name]` - Design a specific workflow (creates PR)
- `gwt <workflow-name>` - Generate GWT scenarios for a workflow
- `validate` - Validate the complete event model
- `arch` - Make architecture decisions (creates ARCHITECTURE.md via ADRs)
- `design-system` - Create/update the design system using Atomic Design methodology
- (no args) - Resume where you left off or start discovery

## Agent Invocation Pattern

All design phases use the Task tool with specialized agents:

```
Task tool with subagent_type="sdlc:<agent-name>":
  <instructions for the agent>
```

Available agents: `sdlc:discovery`, `sdlc:workflow-designer`, `sdlc:model-checker`, `sdlc:gwt`, `sdlc:design-facilitator`, `sdlc:ux`, `sdlc:architect`

## Steps

### 1. Check Configuration

Verify mode is `event-modeling` in `.claude/sdlc.yaml`.

If mode is `traditional`, inform user:
```
This project is configured for traditional development.
Event modeling design is for event-sourced applications.

To switch modes, edit .claude/sdlc.yaml or run /sdlc:setup again.
```

### 2. Check/Create Docs Structure

Check if event model docs exist:
```bash
ls docs/event_model/ 2>/dev/null
```

If not, create the structure:
```bash
mkdir -p docs/event_model/domain
mkdir -p docs/event_model/workflows
```

Create `docs/event_model/README.md` explaining the structure:
- `domain/` - Domain discovery overview
- `workflows/<name>/overview.md` - Workflow overview with master diagram
- `workflows/<name>/slices/` - Individual slice documents (each self-contained with GWT scenarios)

### 3. Search Memento for Context

```
mcp__memento__semantic_search: "event model [project-name] domain discovery"
```

Load any existing event modeling decisions or domain understanding.

### 4. Determine Action

Based on arguments:

#### `discover` or no args with no existing domain doc

**This phase establishes broad domain understanding WITHOUT diving deep into any single workflow.**

Use the `sdlc:discovery` agent to facilitate domain discovery:
- Who are the actors/users of the system?
- What are their high-level goals?
- What major business processes exist?
- What external systems must we integrate with?

Store results in `docs/event_model/domain/overview.md`. When complete, suggest the first workflow to model.

#### `workflow [name]`

**Each workflow design happens on its own branch and creates its own PR.**

For git-spice workflow, see the `shared/git-spice` skill.

If not using git-spice, create a fresh branch:
```bash
git checkout -b event-model/<workflow-name>
```

Use the `sdlc:workflow-designer` agent to guide through the 9-step event modeling process:
1. User Goal
2. Brainstorm Events
3. Order Events (The Plot)
4. Create Wireframes (The Storyboard)
5. Identify Commands
6. Design Read Models
7. Find Automations & Translations
8. Create Mermaid Diagram
9. Decompose into Slices

Output:
- `docs/event_model/workflows/<name>/overview.md`
- `docs/event_model/workflows/<name>/slices/<slice>.md` (one per slice)

After workflow design completes, use `sdlc:model-checker` in `COMPLETENESS_CHECK` mode. This is an ITERATIVE process - for each gap found, create the missing element immediately (ask user if needed), update the workflow document, and run the check AGAIN. Repeat until NO gaps remain.

#### `gwt <workflow>`

First verify we're on the correct workflow branch (`event-model/<workflow-name>`). If not, switch to it.

Use the `sdlc:gwt` agent to generate scenarios. **GWT structure depends on slice type** (see Appendix for pattern details):

- **Command slices**: Given=prior events, When=command, Then=events produced OR error
- **View slices**: Given=current projection state, When=new event, Then=resulting projection state

For each slice: identify pattern type, write happy path first, identify edge cases through questioning, write concrete scenarios with real example data, reference the wireframe in the slice document.

ADD scenarios to existing slice docs at `docs/event_model/workflows/<workflow>/slices/<slice>.md` (add `## GWT Scenarios` section).

After GWT scenarios, use `sdlc:model-checker` in `GWT_FEEDBACK` mode to evaluate if scenarios reveal missing workflow elements. For each gap, ask user to clarify business behavior, add missing element, update related elements.

Then run `sdlc:model-checker` in `COMPLETENESS_CHECK` mode again. Only after this check passes is the workflow ready for review.

#### `validate`

Use `sdlc:model-checker` in `VALIDATION` mode to check:
1. Information completeness - every read model attribute traces to an event
2. Event naming - past tense, business language
3. Command coverage - all events have triggering commands
4. Read model coverage - all queries have read models
5. Automation loops - no infinite event chains
6. Translation coverage - external data has anti-corruption layers

Report gaps as questions to resolve, not technical problems.

#### `arch`

**Prerequisites**:
- At least one workflow must be complete with GWT scenarios
- Domain discovery must exist (`docs/event_model/domain/overview.md`)

Check prerequisites:
```bash
test -f docs/event_model/domain/overview.md || echo "No domain discovery"
ls docs/event_model/workflows/*/overview.md 2>/dev/null || echo "No workflows"
```

If prerequisites not met, inform user what's missing and which commands to run first.

Use the `sdlc:design-facilitator` agent to facilitate architectural decisions:
1. Technology Stack
2. Domain Boundaries
3. Integration Approaches
4. Cross-Cutting Concerns

For EACH significant decision: present options with tradeoffs, after user decides create ADR via `/sdlc:adr decide <topic>`, wait for user to accept ADR. After all decisions made, run `/sdlc:adr synthesize` to create/update ARCHITECTURE.md.

**Output**:
```
Architecture Design Complete: <project-name>

Architecture Document: docs/ARCHITECTURE.md (THE authoritative source)

Next step:
  /sdlc:plan - Create GitHub issues from event model slices

Note: Decision context preserved in docs/adr/ (archival - consult only when reconsidering decisions).
```

#### `design-system`

**Prerequisites**:
- Architecture must exist (`docs/ARCHITECTURE.md`)
- At least one workflow must have wireframes

Check prerequisites:
```bash
test -f docs/ARCHITECTURE.md || echo "No architecture"
ls docs/event_model/workflows/*/overview.md 2>/dev/null || echo "No workflows"
```

If prerequisites not met, inform user to run `/sdlc:design arch` first.

Use the `sdlc:ux` agent in `DESIGN_SYSTEM` mode following Atomic Design process:
1. Analyze wireframes for common UI patterns
2. Gather visual style preferences from user
3. Create design tokens
4. Build component hierarchy (atoms -> molecules -> organisms -> templates)
5. Map read models to component data requirements

Output to `docs/design-system/`

### 5. After Workflow Design - Create/Update PR

After completing a workflow and its GWT scenarios:

```bash
git add docs/event_model/
git commit -m "event-model: add <workflow-name> workflow design and scenarios"
git push -u origin HEAD
gh pr create --title "Event Model: <Workflow Name>" \
  --body "## Workflow: <name>

### Events
<list from workflow doc>

### Vertical Slices
<list of slices>

### Review Focus
- Is the business process accurate?
- Are all events necessary and sufficient?
- Do the GWT scenarios cover edge cases?

**Note**: This is domain modeling only. No architecture decisions are included or requested."
```

For git-spice workflow, see the `shared/git-spice` skill.

### 6. Store in Memento

After design work:

```
mcp__memento__create_entities:
  name: "<Project> <Workflow-Name> Event Model [date]"
  entityType: "event_model"
  observations:
    - "Project: <name> | Path: <path> | Scope: PROJECT_SPECIFIC"
    - "Events: <list of events>"
    - "Vertical Slices: <list of slices>"
    - "Status: <discovery|designed|scenarios-complete>"
```

### 7. Display Results

After domain discovery:
```
Domain Discovery Complete: <project-name>

Actors Identified:
  - <actor 1>: <brief description>
  - <actor 2>: <brief description>

Workflows Identified:
  - <workflow 1>: <brief description>
  - <workflow 2>: <brief description>

Suggested Starting Workflow: <name>
Reason: <why this workflow first>

Next step:
  /sdlc:design workflow <name>
```

After workflow design:
```
Workflow Designed: <name>
Branch: event-model/<name>

Documentation:
  docs/event_model/workflows/<name>/
  |- overview.md
  +- slices/
      |- <slice-1>.md
      |- <slice-2>.md
      +- ...

Vertical Slices: <count>
  Command: <list>
  View: <list>
  Automation: <list>
  Translation: <list>

Next steps:
  /sdlc:design gwt <name> - Generate GWT scenarios
  /sdlc:design workflow <next-name> - Design next workflow (stacked)
```

After GWT scenarios:
```
Scenarios Added: <workflow-name>

Slices updated:
  - <slice-1>.md: <n> scenarios
  - <slice-2>.md: <n> scenarios

PR ready for review.
```

After design system:
```
Design System Created: <project-name>

Documentation:
  docs/design-system/
  |- tokens.md
  |- atoms/
  |- molecules/
  |- organisms/
  |- templates/
  +- mappings.md

Components:
  Atoms: <count>
  Molecules: <count>
  Organisms: <count>
  Templates: <count>

Next step:
  /sdlc:plan - Create GitHub issues from event model slices
```

## What We Do NOT Discuss During Event Modeling

- Database choices
- API designs
- Programming languages
- Frameworks or libraries
- Message brokers or queues
- Deployment architecture
- Performance optimizations
- Caching strategies
- Any implementation detail

The ONLY exception: When a mandatory third-party integration exists, note its name and general purpose. Example: "Must integrate with Stripe for payments" - but NOT "We'll use webhooks with..." or "The API contract is..."

## Event Naming

Events are facts about the business, in business language:
- **Past tense**: Something that HAS happened
- **Business language**: A domain expert would understand
- **Immutable facts**: Not requests or intentions

Good: `OrderPlaced`, `PaymentReceived`, `CustomerRegistered`
Bad: `PlaceOrder`, `ProcessPayment`, `SaveCustomer`

## Appendix: The Four Patterns

These patterns describe business behavior, NOT technical architecture. **Each pattern = ONE vertical slice.**

1. **Command (State Change)**: Trigger -> Command -> Event(s)
   - GWT: Given=events, When=command, Then=events OR error
   - Color: White -> Blue -> Orange

2. **View (State View)**: Events -> Read Model
   - GWT: Given=projection state, When=event, Then=new state
   - Views CANNOT reject - they passively process events
   - Color: Orange -> Green

3. **Automation**: Event -> View (todo list) -> Process -> Command -> Event
   - GWT: Given=events, When=trigger event, Then=command + events
   - Color: Orange -> Green -> Purple -> Blue -> Orange

4. **Translation**: External Data -> Internal Event
   - GWT: Given=external state, When=external trigger, Then=internal event
   - Anti-corruption layer pattern
