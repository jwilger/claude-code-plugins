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

Design event model workflows following Martin Dilger's "Understanding Eventsourcing" methodology. This command facilitates the most critical phase of the SDLC - **event modeling is where we truly understand the business domain**.

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
│  Suggest initial workflow to model                               │
│  [Stays on main branch - no PR yet]                             │
└────────────────────────────────────┬────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                   WORKFLOW DESIGN (per workflow)                 │
│  Create fresh branch from main (or stack with git-spice)        │
│  Deep dive into ONE workflow                                     │
│  Brainstorm → Order → Commands → Read Models → Automations      │
│  [Each workflow gets its own PR]                                │
└────────────────────────────────────┬────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                     GWT SCENARIOS (per workflow)                 │
│  Generate Given/When/Then for each vertical slice               │
│  Add to same workflow branch/PR                                  │
└────────────────────────────────────┬────────────────────────────┘
                                     │
                                     ▼
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

  Guide through EACH step methodically:

  Step 1 - User Goal: What exactly is the user trying to accomplish?
  Step 2 - Brainstorm Events: What facts get recorded? (sticky-note style, no order yet)
  Step 3 - Order Events: Arrange chronologically as the story unfolds
  Step 4 - Identify Commands: For EACH event, what triggers it?
  Step 5 - Design Read Models: What does each actor need to see?
  Step 6 - Find Automations: What events trigger other commands automatically?
  Step 7 - Map Integrations: External systems that must be integrated (minimal detail)

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

  Store in docs/event_model/workflows/<name>.md
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

  For each vertical slice:
  1. Write happy path scenario first
  2. Identify all edge cases through questioning
  3. Write concrete scenarios with real example data

  These scenarios ARE the acceptance criteria for future stories.

  Write to docs/event_model/scenarios/<workflow>/<slice>.md
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

These patterns describe business behavior, NOT technical architecture:

1. **State Change**: Command → Event (a decision was made, a fact recorded)
2. **State View**: Events → Read Model (what information is derived from facts)
3. **Automation**: Event → Process → Command → Event (what happens automatically)
4. **Translation**: External data → Internal event (information from outside our domain)

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
