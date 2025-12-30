---
description: Design event model workflows - brainstorm, document, and generate GWT scenarios
argument-hint: [workflow-name]
allowed-tools:
  - Bash
  - Read
  - Write
  - Task
  - AskUserQuestion
  - mcp__memento__semantic_search
  - mcp__memento__create_entities
---

# SDLC Design

Design event model workflows following Martin Dilger's "Understanding Eventsourcing" methodology. This command:
1. Guides brainstorming of workflows
2. Documents workflows and their components
3. Generates Given/When/Then scenarios for slices
4. Validates the event model for completeness

## Arguments

`$ARGUMENTS` may contain:
- `<workflow-name>` - Design a specific workflow
- `gwt <workflow-name>` - Generate GWT scenarios for a workflow
- `validate` - Validate the complete event model
- (no args) - Start interactive workflow design

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
ls docs/event_model/workflows/ 2>/dev/null
```

If not, ask if user wants to create the structure:
```bash
mkdir -p docs/event_model/{workflows,scenarios}
```

Create template files:
- `docs/event_model/workflows/_template.md`
- `docs/event_model/scenarios/_template.md`

### 3. Search Memento for Context

```
mcp__memento__semantic_search: "event model [project-name]"
```

Load any existing event modeling decisions or patterns.

### 4. Determine Action

Based on arguments:

#### No args or workflow name → Design Workflow

Use the sdlc-event-model agent:

```
Task tool with subagent_type="sdlc-event-model":
  Design the workflow: <workflow-name or "new workflow">

  Guide the user through:
  1. Identifying the user goal/problem
  2. Brainstorming events (what facts get recorded)
  3. Identifying commands (what triggers events)
  4. Designing read models (what views are needed)
  5. Identifying automations (event → process → command)
  6. Mapping external integrations (translations)

  Document the workflow in docs/event_model/workflows/<name>.md

  Remember: Search memento for context, store discoveries.
```

#### `gwt <workflow>` → Generate Scenarios

Use the sdlc-gwt agent:

```
Task tool with subagent_type="sdlc-gwt":
  Generate Given/When/Then scenarios for workflow: <workflow-name>

  Read the workflow from docs/event_model/workflows/<name>.md

  For each vertical slice in the workflow:
  1. Identify the user action (When)
  2. Determine required preconditions (Given)
  3. Specify expected outcomes (Then)

  Include:
  - Happy path scenarios
  - Edge cases and error conditions
  - Validation failures

  Write scenarios to docs/event_model/scenarios/<workflow>/<slice>.md

  Remember: GWT scenarios ARE acceptance criteria for stories.
```

#### `validate` → Validate Model

Use the sdlc-model-validator agent (or inline validation):

```
Task tool with subagent_type="sdlc-event-model":
  Validate the event model in docs/event_model/

  Check for:
  1. Information completeness - every read model attribute traces to an event
  2. Event naming - past tense, business language
  3. Command coverage - all events have triggering commands
  4. Read model coverage - all queries have read models
  5. Automation loops - no infinite event chains
  6. Translation coverage - external data has anti-corruption layers

  Report any gaps or issues found.
```

### 5. Store in Memento

After design work, store key decisions:

```
mcp__memento__create_entities:
  name: "<Workflow-Name> Event Model [date]"
  entityType: "event_model"
  observations:
    - "Project: <name> | Path: <path> | Scope: PROJECT_SPECIFIC"
    - "Events: <list of events>"
    - "Commands: <list of commands>"
    - "Key decisions: <any notable design choices>"
```

### 6. Display Results

After workflow design:
```
Workflow designed: <name>

Events:
  - UserRegistered
  - EmailVerified
  - PasswordChanged

Commands:
  - RegisterUser
  - VerifyEmail
  - ChangePassword

Read Models:
  - UserProfile
  - AuthenticationStatus

Next steps:
  - /sdlc:design gwt <name> - Generate GWT scenarios
  - /sdlc:design validate - Validate complete model
  - /plan review <name> - Three-perspective story review
```

## The Four Patterns

Always enforce these event sourcing patterns:

1. **State Change**: Command → Event (only way to modify state)
2. **State View**: Events → Read Model (query stored events)
3. **Automation**: Event → Process → Command → Event (background work)
4. **Translation**: External data → Internal event (anti-corruption layer)

## Event Naming

Events must be:
- **Past tense**: Something that HAS happened
- **Business language**: Understandable by domain experts
- **Immutable facts**: Not requests or intentions

Good: `OrderPlaced`, `PaymentReceived`, `InventoryReserved`
Bad: `PlaceOrder`, `ProcessPayment`, `ReserveInventory`
