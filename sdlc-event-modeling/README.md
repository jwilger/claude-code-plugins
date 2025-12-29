# SDLC Event Modeling

Event Sourcing development using Martin Dilger's "Understanding Eventsourcing" methodology.

## Philosophy

Event Modeling provides a visual and structured approach to designing event-sourced systems:

- **Events are immutable facts** in past tense using business language
- **"Not losing information"** is foundational - store what happened, not just current state
- **Four patterns** describe any information system: State Change, State View, Automation, Translation

## Features

- Design event-sourced workflows with the four patterns
- Generate Given/When/Then scenarios for business rules
- Validate models for information completeness
- Create implementation plans from event models
- Reverse-engineer event models from existing code

## Commands

| Command | Description |
|---------|-------------|
| `/event-model start` | Begin brainstorming session |
| `/event-model design <workflow>` | Design a workflow |
| `/event-model gwt <workflow>` | Generate GWT scenarios |
| `/event-model validate` | Validate the model |
| `/event-model implement <name>` | Create implementation plan |
| `/event-model reverse [path]` | Reverse-engineer from existing code |

## Agents

| Agent | Role |
|-------|------|
| `event-model-architect` | Designs workflows using the four patterns |
| `gwt-scenario-generator` | Creates Given/When/Then scenarios |
| `model-validator` | Validates completeness and naming conventions |
| `implementation-guide` | Creates implementation plans |
| `event-model-reverse-engineer` | Extracts event model from existing code |

## The Four Patterns

| Pattern | Description | Flow |
|---------|-------------|------|
| **State Change** | User action modifies state | Command → Event |
| **State View** | Query displays data | Events → Read Model |
| **Automation** | Background process | Event → Process → Command → Event |
| **Translation** | External data enters | External → Internal Event |

## Project Structure

When using this plugin, event models are stored in `docs/event_model/`:

```
docs/event_model/
├── README.md           # Overview and index
├── workflows/          # Workflow definitions
├── scenarios/          # GWT scenarios by workflow
├── events/             # Event definitions (optional)
├── commands/           # Command definitions (optional)
└── read-models/        # Read model definitions (optional)
```

## Dependencies

- **sdlc-core**: Memory protocol and shared conventions

## License

MIT
