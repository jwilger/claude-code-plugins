# Event Model

This directory contains the event model for the project, following Martin Dilger's methodology.

## Structure

```
docs/event_model/
├── README.md           # This file - overview and index
├── workflows/          # Workflow definitions (one per use case)
├── scenarios/          # GWT scenarios organized by workflow
├── events/             # Event definitions (optional detail)
├── commands/           # Command definitions (optional detail)
└── read-models/        # Read model definitions (optional detail)
```

## Quick Start

Use `/event-model` in Claude Code to:
- `/event-model start` - Begin brainstorming
- `/event-model design <workflow>` - Design a workflow
- `/event-model gwt <workflow>` - Generate GWT scenarios
- `/event-model validate` - Check information completeness
- `/event-model implement <workflow>` - Plan implementation

## The Four Patterns

| Pattern | Description | Elements |
|---------|-------------|----------|
| **State Change** | User action modifies state | Command → Event |
| **State View** | Query displays data | Events → Read Model |
| **Automation** | Background process | Event → Processor → Command → Event |
| **Translation** | External data enters system | External → Internal Event |

## Workflows

<!-- List workflows here as they're created -->

## Conventions

- **Events**: Past tense, business language (e.g., `OrderPlaced`, `CustomerRegistered`)
- **Commands**: Imperative (e.g., `PlaceOrder`, `RegisterCustomer`)
- **Read Models**: Noun phrases (e.g., `OrderList`, `CustomerDetails`)
- **Streams**: Bounded by business entity lifecycle (30-100 events typical)
