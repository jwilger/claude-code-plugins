---
description: Design event model workflows - brainstorm, document, and generate GWT scenarios
argument-hint: [discover|workflow|gwt|validate] [name]
allowed-tools:
  - Bash
  - Read
  - Write
  - Task
  - AskUserQuestion
  - mcp__memento__semantic_search
  - mcp__memento__create_entities
  - mcp__memento__create_relations
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
mkdir -p docs/event_model/{domain,workflows,scenarios}
```

Create `docs/event_model/README.md` explaining the structure.

### 3. Search Memento for Context

```
mcp__memento__semantic_search: "event model [project-name] domain discovery"
```

Load any existing event modeling decisions or domain understanding.

### 4. Determine Action

Based on arguments:

#### `discover` or no args with no existing domain doc → Domain Discovery

**This phase establishes broad domain understanding WITHOUT diving deep into any single workflow.**

Use the sdlc-event-model agent with discover mode:

```
Task tool with subagent_type="sdlc-event-model":
  MODE: DOMAIN_DISCOVERY

  Facilitate domain discovery for [project-name].

  Your goal is to understand the BUSINESS DOMAIN broadly:
  1. Who are the actors/users of the system?
  2. What are their high-level goals?
  3. What major business processes exist?
  4. What external systems must we integrate with? (Note: just names and purposes, NO technical details)

  DO NOT:
  - Dive deep into any single workflow
  - Make architecture decisions
  - Discuss technical implementation
  - Collect more detail than needed to identify workflows

  DO:
  - Ask broad, open-ended questions
  - Build a mental map of the domain
  - Identify potential workflows to model
  - Suggest which workflow to start with and WHY

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

Then use the sdlc-event-model agent:

```
Task tool with subagent_type="sdlc-event-model":
  MODE: WORKFLOW_DESIGN

  Design the workflow: <workflow-name>

  IMPORTANT: This is the most critical part of the SDLC. Do NOT skip steps.
  Do NOT assume you have enough information. The PROCESS is what reveals the truth.

  Guide through EACH step methodically (from Dymitruk's Event Modeling):

  Step 1 - User Goal: What exactly is the user trying to accomplish?
  Step 2 - Brainstorm Events: What facts get recorded? (sticky-note style, no order yet)
  Step 3 - Order Events: Arrange chronologically as the story unfolds (The Plot)
  Step 4 - Create Wireframes: ASCII mockups for every interaction (The Storyboard)
  Step 5 - Identify Commands: For EACH event, what triggers it?
  Step 6 - Design Read Models: What does each actor need to see?
  Step 7 - Find Automations & Translations: What happens automatically? External systems?
  Step 8 - Create Mermaid Diagram: Flowchart with swimlanes showing complete workflow
  Step 9 - Decompose into Slices: ONE pattern per slice (Command, View, Automation, Translation)

  At EVERY step, ask probing questions:
  - "And then what happens?"
  - "What if [scenario]?"
  - "Who needs to know about this?"
  - "What could go wrong?"

  Do NOT:
  - Make ANY architecture decisions
  - Discuss technical implementation
  - Skip steps because you think you know enough
  - Rush to documentation
  - Skip wireframes (they are mandatory!)
  - Create slices larger than ONE pattern

  Store in docs/event_model/workflows/<name>.md
```

After workflow design completes, **immediately run information completeness check**:

```
Task tool with subagent_type="sdlc-event-model":
  MODE: COMPLETENESS_CHECK

  Run information completeness check on workflow: <workflow-name>

  This is an ITERATIVE process. For EACH gap found:
  1. Create the missing element immediately (ask user if needed)
  2. Update the workflow document
  3. Run the check AGAIN

  Repeat until NO gaps remain. Only then proceed to GWT scenarios.

  Check criteria:
  - Every read model field traces to an event field
  - Every event has a triggering command OR automation OR translation
  - Every command has validation rules defined
  - Every automation has termination conditions

  DO NOT proceed to GWT until this check passes completely.
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

  Read the workflow from docs/event_model/workflows/<name>.md

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
  5. Include wireframe excerpt showing relevant data

  These scenarios ARE the acceptance criteria for future stories.

  Write to docs/event_model/scenarios/<workflow>/<slice>.md
```

After GWT scenarios are generated, **run GWT feedback evaluation**:

```
Task tool with subagent_type="sdlc-event-model":
  MODE: GWT_FEEDBACK

  Evaluate if GWT scenarios reveal missing workflow elements for: <workflow-name>

  Read the scenarios from docs/event_model/scenarios/<workflow>/

  For EACH scenario, ask:
  1. Does this scenario reference events that aren't in the workflow?
  2. Does this scenario imply commands with failure cases we haven't modeled?
  3. Does the Given clause require read model fields we haven't defined?
  4. Does the Then clause imply events or state changes we're missing?

  For EACH gap discovered:
  1. Ask the user to clarify the business behavior
  2. Add the missing element to the workflow document
  3. Update related elements (commands, events, read models) as needed

  After adding elements, this will trigger another completeness check.
```

Then **run information completeness check again**:

```
Task tool with subagent_type="sdlc-event-model":
  MODE: COMPLETENESS_CHECK

  Run information completeness check on workflow: <workflow-name>

  (Same iterative process as before - repeat until no gaps remain)

  This ensures any elements added during GWT feedback are complete.

  Only after this check passes is the workflow ready for review.
```

#### `validate` → Validate Model

```
Task tool with subagent_type="sdlc-event-model":
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

Events: <count>
  - <list>

Commands: <count>
  - <list>

Read Models: <count>
  - <list>

Vertical Slices: <count>
  - <list>

Next steps:
  /sdlc:design gwt <name> - Generate GWT scenarios
  /sdlc:design workflow <next-name> - Design next workflow (stacked)
```

After GWT scenarios:
```
Scenarios Generated: <workflow-name>

Slices with scenarios:
  - <slice 1>: <n> scenarios
  - <slice 2>: <n> scenarios

PR ready for review. To submit:
  git push && gh pr create

Or with git-spice:
  gs branch submit
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
