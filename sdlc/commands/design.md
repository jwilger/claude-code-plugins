---
description: Design event model workflows - brainstorm, document, and generate GWT scenarios
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

Design event model workflows following Martin Dilger's "Understanding Eventsourcing" methodology and Adam Dymitruk's Event Modeling approach (eventmodeling.org). This command facilitates the most critical phase of the SDLC - **event modeling is where we truly understand the business domain**.

## Key Concepts

- **Vertical Slice**: The smallest implementable unit = ONE pattern (Command, View, Automation, or Translation)
- **Wireframes**: ASCII mockups showing data input/output for every interaction
- **Mermaid Diagrams**: Flowcharts with swimlanes showing the complete workflow
- **GWT Scenarios**: Different structures for Commands (Given=events, When=command, Then=events/error) vs Views (Given=state, When=event, Then=new state)

## Core Philosophy

**Event modeling is about understanding, not documentation.**

The AI's role is to be a **facilitator**, not a stenographer. The process involves:
1. Asking probing questions ("And then what happens?")
2. Challenging assumptions
3. Ensuring no steps are skipped
4. Keeping the focus on **business behavior**, not technical implementation

**CRITICAL**: No architecture or technical decisions are made during event modeling. Those decisions belong to initial architecture design and implementation phases. The ONLY exception is mandatory third-party integrations, and even then, keep technical details to a bare minimum.

## Arguments

`$ARGUMENTS` may contain:
- `discover` - Start or continue domain discovery (required before first workflow)
- `workflow [name]` - Design a specific workflow (creates PR)
- `gwt <workflow-name>` - Generate GWT scenarios for a workflow
- `validate` - Validate the complete event model
- `arch` - Make architecture decisions (creates ARCHITECTURE.md via ADRs)
- `design-system` - Create/update the design system using Atomic Design methodology
- (no args) - Resume where you left off or start discovery

## The Process Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     DOMAIN DISCOVERY                             │
│  Broad understanding of business domain, actors, goals          │
│  Identify workflows to model                                     │
│  [Stays on main branch - no PR yet]                             │
└────────────────────────────────────┬────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────┐
│               WORKFLOW DESIGN (per workflow)                     │
│  Create fresh branch from main (or stack with git-spice)        │
│                                                                  │
│  The 9 Steps (from Dymitruk's Event Modeling):                  │
│  1. User Goal - what success looks like                         │
│  2. Brainstorm Events - sticky-note style                       │
│  3. Order Events - chronological story (The Plot)               │
│  4. Create Wireframes - ASCII mockups (The Storyboard)          │
│  5. Identify Commands - what triggers each event                │
│  6. Design Read Models - what each actor sees                   │
│  7. Find Automations & Translations                              │
│  8. Create Mermaid Diagram - flowchart with swimlanes           │
│  9. Decompose into Slices - ONE pattern per slice               │
│                                                                  │
│  [Each workflow gets its own PR]                                │
└────────────────────────────────────┬────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────┐
│              INFORMATION COMPLETENESS CHECK                      │◄──┐
│  Every read model field must trace to an event                  │   │
│  Every event must have a triggering command/automation          │   │
│  Every wireframe field must trace to event or command           │   │
│  Create any missing elements immediately                         │   │
└────────────────────────────────────┬────────────────────────────┘   │
                                     │                                │
                            (gaps found?) ────────────────────────────┘
                                     │
                                     ▼ (complete)
┌─────────────────────────────────────────────────────────────────┐
│                 GWT SCENARIOS (per slice)                        │
│  For Command slices: Given=events, When=cmd, Then=events/error  │
│  For View slices: Given=state, When=event, Then=new state       │
│  Include wireframe excerpt in each scenario                      │
│  Add to same workflow branch/PR                                  │
└────────────────────────────────────┬────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                  GWT FEEDBACK EVALUATION                         │
│  Do scenarios reveal missing workflow elements?                  │
│  - Events not yet modeled?                                       │
│  - Commands with unhandled failure cases?                        │
│  - Read models missing fields?                                   │
│  - Wireframes missing data?                                      │
│  Add any missing elements to workflow                            │
└────────────────────────────────────┬────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────┐
│              INFORMATION COMPLETENESS CHECK                      │◄──┐
│  (Run again after GWT feedback)                                  │   │
│  Verify all additions are complete                               │   │
│  Create any missing elements immediately                         │   │
└────────────────────────────────────┬────────────────────────────┘   │
                                     │                                │
                            (gaps found?) ────────────────────────────┘
                                     │
                                     ▼ (complete)
┌─────────────────────────────────────────────────────────────────┐
│                     REVIEW & MERGE                               │
│  Review workflow PR independently                                │
│  Merge when complete                                             │
│  Repeat for next workflow                                        │
└────────────────────────────────────┬────────────────────────────┘
                                     │
                    (all workflows complete?)
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                   ARCHITECTURE DESIGN                            │
│  Technology stack decisions (informed by event model)           │
│  Domain boundaries (bounded contexts from events)               │
│  Integration approaches (for translations)                       │
│  Cross-cutting concerns                                          │
│                                                                  │
│  For EACH decision:                                              │
│  1. Create ADR via /sdlc:adr decide <topic>                     │
│  2. Accept ADR                                                   │
│  3. Synthesize to ARCHITECTURE.md                                │
│                                                                  │
│  [Creates docs/ARCHITECTURE.md - enables /sdlc:plan]            │
└────────────────────────────────────────────────────────────────┬┘
                                     │
                    (UI application?)
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                     DESIGN SYSTEM (optional)                    │
│  For apps with user interfaces (not CLI tools)                  │
│  Creates reusable components using Atomic Design                │
│                                                                 │
│  Process:                                                       │
│  1. Read event model wireframes for UI patterns                 │
│  2. Define design tokens (colors, typography, spacing)          │
│  3. Build atomic hierarchy (atoms → molecules → organisms)      │
│  4. Map read models to component data                           │
│                                                                 │
│  [Creates docs/design-system/]                                  │
└─────────────────────────────────────────────────────────────────┘
```

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

#### `discover` or no args with no existing domain doc → Domain Discovery

**This phase establishes broad domain understanding WITHOUT diving deep into any single workflow.**

Use the sdlc-discovery agent:

```
Task tool with subagent_type="sdlc-discovery":
  Facilitate domain discovery for [project-name].

  Build broad understanding of the business domain:
  1. Who are the actors/users of the system?
  2. What are their high-level goals?
  3. What major business processes exist?
  4. What external systems must we integrate with?

  Store results in docs/event_model/domain/overview.md

  When complete, suggest the first workflow to model.
```

#### `workflow [name]` → Design Single Workflow (with branch/PR)

**Each workflow design happens on its own branch and creates its own PR.**

First, handle branching:

```bash
# Check current branch
git branch --show-current

# Check if git-spice is available
which gs 2>/dev/null
```

If on main:
```bash
# Create fresh branch for this workflow
git checkout -b event-model/<workflow-name>
```

If on an event-model branch and git-spice available:
```bash
# Stack on top of current workflow
gs branch create event-model/<workflow-name>
```

Then use the sdlc-workflow-designer agent:

```
Task tool with subagent_type="sdlc-workflow-designer":
  Design the workflow: <workflow-name>

  Guide through the 9-step event modeling process:
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
  - docs/event_model/workflows/<name>/overview.md
  - docs/event_model/workflows/<name>/slices/<slice>.md (one per slice)
```

After workflow design completes, **immediately run information completeness check**:

```
Task tool with subagent_type="sdlc-model-checker":
  MODE: COMPLETENESS_CHECK

  Run information completeness check on workflow: <workflow-name>

  This is an ITERATIVE process. For EACH gap found:
  1. Create the missing element immediately (ask user if needed)
  2. Update the workflow document
  3. Run the check AGAIN

  Repeat until NO gaps remain. Only then proceed to GWT scenarios.
```

#### `gwt <workflow>` → Generate Scenarios

First verify we're on the correct workflow branch:

```bash
git branch --show-current
# Should be: event-model/<workflow-name>
```

If not on correct branch, switch to it.

Then use the sdlc-gwt agent:

```
Task tool with subagent_type="sdlc-gwt":
  Generate Given/When/Then scenarios for workflow: <workflow-name>

  Read the workflow from docs/event_model/workflows/<name>/overview.md
  Read each slice from docs/event_model/workflows/<name>/slices/*.md

  CRITICAL: GWT structure depends on slice type!

  For COMMAND slices:
  - Given = prior events (with realistic data)
  - When = command (with realistic input)
  - Then = events produced OR error (never both)

  For VIEW slices:
  - Given = current projection state
  - When = new event to process
  - Then = resulting projection state

  For each slice:
  1. Identify the pattern type (Command, View, Automation, Translation)
  2. Write happy path scenario first
  3. Identify all edge cases through questioning
  4. Write concrete scenarios with real example data
  5. Reference the wireframe already in the slice document

  These scenarios ARE the acceptance criteria for future stories.

  ADD scenarios to existing slice docs at:
  docs/event_model/workflows/<workflow>/slices/<slice>.md

  (Add ## GWT Scenarios section at the bottom of each slice document)
```

After GWT scenarios are generated, **run GWT feedback evaluation**:

```
Task tool with subagent_type="sdlc-model-checker":
  MODE: GWT_FEEDBACK

  Evaluate if GWT scenarios reveal missing workflow elements for: <workflow-name>

  Read the scenarios from docs/event_model/workflows/<workflow>/slices/*.md

  For EACH gap discovered:
  1. Ask the user to clarify the business behavior
  2. Add the missing element to the workflow document
  3. Update related elements as needed

  After adding elements, this will trigger another completeness check.
```

Then **run information completeness check again**:

```
Task tool with subagent_type="sdlc-model-checker":
  MODE: COMPLETENESS_CHECK

  Run information completeness check on workflow: <workflow-name>

  This ensures any elements added during GWT feedback are complete.

  Only after this check passes is the workflow ready for review.
```

#### `validate` → Validate Model

```
Task tool with subagent_type="sdlc-model-checker":
  MODE: VALIDATION

  Validate the event model in docs/event_model/

  Check for:
  1. Information completeness - every read model attribute traces to an event
  2. Event naming - past tense, business language
  3. Command coverage - all events have triggering commands
  4. Read model coverage - all queries have read models
  5. Automation loops - no infinite event chains
  6. Translation coverage - external data has anti-corruption layers

  Report gaps as questions to resolve, not technical problems.
```

#### `arch` → Architecture Design Phase

**Prerequisites**:
- At least one workflow must be complete with GWT scenarios
- Domain discovery must exist (`docs/event_model/domain/overview.md`)

Check prerequisites:
```bash
# Check domain discovery exists
test -f docs/event_model/domain/overview.md || echo "No domain discovery"

# Check for complete workflows (with GWT scenarios)
ls docs/event_model/workflows/*/overview.md 2>/dev/null || echo "No workflows"
```

If prerequisites not met:
```
Cannot proceed with architecture without a completed event model.

Missing:
- [Domain discovery if missing]: Run /sdlc:design discover
- [Workflows if missing]: Run /sdlc:design workflow <name>

The architecture phase requires understanding WHAT we're building
(from the event model) before deciding HOW to build it.
```

**Process**:

This phase bridges event modeling to implementation by making architectural decisions informed by the event model.

Use the sdlc-design-facilitator agent:

```
Task tool with subagent_type="sdlc-design-facilitator":
  Design architecture for the system based on event model in docs/event_model/

  Read and understand:
  1. Domain overview from docs/event_model/domain/overview.md
  2. All workflow overviews
  3. All slices and their patterns (Command, View, Automation, Translation)

  Facilitate architectural decisions in these categories:
  1. Technology Stack
  2. Domain Boundaries
  3. Integration Approaches
  4. Cross-Cutting Concerns

  For EACH significant decision:
  1. Present options with tradeoffs using AskUserQuestion
  2. After user decides, create ADR: /sdlc:adr decide <topic>
  3. Wait for user to accept ADR: /sdlc:adr accept <number>

  After all decisions are made and ADRs accepted:
  - Run /sdlc:adr synthesize to create/update ARCHITECTURE.md
```

**Output**:
```
Architecture Design Complete: <project-name>

ADRs Created:
  - ADR-001: <title> [accepted]
  - ADR-002: <title> [accepted]
  ...

Architecture Document: docs/ARCHITECTURE.md

Key Decisions:
  - Technology: <stack summary>
  - Boundaries: <bounded contexts summary>
  - Integration: <approach summary>
  - Cross-cutting: <patterns summary>

Next step:
  /sdlc:plan - Create GitHub issues from event model slices
```

#### `design-system` → Create/Update Design System

**Prerequisites**:
- Architecture must exist (`docs/ARCHITECTURE.md`)
- At least one workflow must have wireframes

Check prerequisites:
```bash
# Check architecture exists
test -f docs/ARCHITECTURE.md || echo "No architecture"

# Check for workflows with wireframes
ls docs/event_model/workflows/*/overview.md 2>/dev/null || echo "No workflows"
```

If prerequisites not met:
```
Cannot create design system without architecture decisions.

Missing:
- [Architecture if missing]: Run /sdlc:design arch first

The design system phase requires knowing the technology stack
(from architecture) to make appropriate component decisions.
```

If prerequisites met, use the sdlc-ux agent in Design System mode:

```
Task tool with subagent_type="sdlc-ux":
  MODE: DESIGN_SYSTEM

  Create/update the design system for [project-name].

  Read the event model wireframes from docs/event_model/workflows/
  Read the architecture from docs/ARCHITECTURE.md

  Follow the Atomic Design process:
  1. Analyze wireframes for common UI patterns
  2. Gather visual style preferences from user
  3. Create design tokens
  4. Build component hierarchy (atoms → molecules → organisms → templates)
  5. Map read models to component data requirements

  Output to docs/design-system/
```

**Output**:
```
Design System Created: <project-name>

Design Tokens: docs/design-system/tokens.md

Components:
  Atoms: <count> (<list>)
  Molecules: <count> (<list>)
  Organisms: <count> (<list>)
  Templates: <count> (<list>)

Read Model Mappings: docs/design-system/mappings.md

Next step:
  /sdlc:plan - Create GitHub issues from event model slices
```

### 5. After Workflow Design - Create/Update PR

After completing a workflow and its GWT scenarios:

```bash
# Stage changes
git add docs/event_model/

# Commit
git commit -m "event-model: add <workflow-name> workflow design and scenarios"

# Push and create PR
git push -u origin HEAD

# Create PR (or use git-spice if stacking)
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

If using git-spice:
```bash
gs branch submit
```

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
  ├── overview.md
  └── slices/
      ├── <slice-1>.md
      ├── <slice-2>.md
      └── ...

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

PR ready for review. To submit:
  git push && gh pr create

Or with git-spice:
  gs branch submit
```

After design system:
```
Design System Created: <project-name>

Documentation:
  docs/design-system/
  ├── tokens.md
  ├── atoms/
  │   ├── <atom-1>.md
  │   └── ...
  ├── molecules/
  │   ├── <molecule-1>.md
  │   └── ...
  ├── organisms/
  │   ├── <organism-1>.md
  │   └── ...
  ├── templates/
  │   ├── <template-1>.md
  │   └── ...
  └── mappings.md

Components:
  Atoms: <count>
  Molecules: <count>
  Organisms: <count>
  Templates: <count>

Next step:
  /sdlc:plan - Create GitHub issues from event model slices
```

## The Four Patterns (Reference)

These patterns describe business behavior, NOT technical architecture. **Each pattern = ONE vertical slice.**

1. **Command (State Change)**: Trigger → Command → Event(s)
   - GWT: Given=events, When=command, Then=events OR error
   - Color: White → Blue → Orange

2. **View (State View)**: Events → Read Model
   - GWT: Given=projection state, When=event, Then=new state
   - Views CANNOT reject - they passively process events
   - Color: Orange → Green

3. **Automation**: Event → View (todo list) → Process → Command → Event
   - GWT: Given=events, When=trigger event, Then=command + events
   - Color: Orange → Green → Purple → Blue → Orange

4. **Translation**: External Data → Internal Event
   - GWT: Given=external state, When=external trigger, Then=internal event
   - Anti-corruption layer pattern

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
