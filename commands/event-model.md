---
description: Event sourcing development using Dilger's methodology
argument-hint: [action] [workflow-name]
---

# Event Model Command

You are helping with event-sourced system development following Martin Dilger's "Understanding Eventsourcing" methodology.

**Arguments provided:** $ARGUMENTS

## Determine the Action

Based on the arguments, determine what the user needs:

| If args contain... | Action |
|-------------------|--------|
| `start`, `new`, `brainstorm` | Guide brainstorming session |
| `design <name>` | Design a workflow |
| `scenarios <name>` or `gwt <name>` | Generate GWT scenarios |
| `validate` | Validate the model |
| `implement <name>` | Create implementation plan |
| `reverse [path]` or `extract [path]` | Reverse-engineer from existing code |
| (no args or `help`) | Show available actions |

## Execute the Action

### For Brainstorming (`start`, `new`, `brainstorm`)
Guide the user through:
1. List events in **past tense** using **business language**
2. Arrange chronologically left-to-right
3. Identify event clusters → bounded contexts
4. Create initial workflow files in `docs/event_model/workflows/`

### For Design (`design <workflow>`)
Use the Task tool with `subagent_type="event-model-architect"`:

Prompt: `Design the "$1" workflow. Write output to docs/event_model/workflows/$1.md. Remember: Follow the memory protocol - search memento for existing patterns/conventions, store new discoveries.`

### For GWT Scenarios (`scenarios <workflow>` or `gwt <workflow>`)
Use the Task tool with `subagent_type="gwt-scenario-generator"`:

Prompt: `Generate GWT scenarios for the workflow at docs/event_model/workflows/$1.md. Write to docs/event_model/scenarios/$1/. Remember: Follow the memory protocol - search memento for existing patterns/conventions, store new discoveries.`

### For Validation (`validate`)
Use the Task tool with `subagent_type="model-validator"`:

Prompt: `Validate all event model files in docs/event_model/. Remember: Follow the memory protocol - search memento for existing patterns/conventions, store new discoveries.`

### For Implementation (`implement <workflow>`)
Use the Task tool with `subagent_type="implementation-guide"`:

Prompt: `Create implementation plan for docs/event_model/workflows/$1.md. Remember: Follow the memory protocol - search memento for existing patterns/conventions, store new discoveries.`

### For Reverse Engineering (`reverse [path]` or `extract [path]`)
Use the Task tool with `subagent_type="event-model-reverse-engineer"`:

If a path argument is provided (e.g., `/event-model reverse /path/to/app`), use it. Otherwise default to current working directory.

Prompt: `Analyze the codebase at <path> and extract event model elements. Document findings and provide instructions for using /event-model design, /event-model gwt, and /event-model validate to create the formal artifacts. Remember: Follow the memory protocol - search memento for existing patterns/conventions, store new discoveries.`

After the analysis returns, follow its instructions to run the other event-model commands to create the formal artifacts.

### For Help (no args)
Display:

```
/event-model - Event Sourcing Development

Actions:
  /event-model start              - Begin brainstorming session
  /event-model design <workflow>  - Design a workflow
  /event-model gwt <workflow>     - Generate GWT scenarios
  /event-model validate           - Validate the model
  /event-model implement <name>   - Create implementation plan
  /event-model reverse [path]     - Reverse-engineer from existing code

The Four Patterns:
  State Change  - Command → Event (modify state)
  State View    - Events → Read Model (query)
  Automation    - Event → Process → Command → Event
  Translation   - External → Internal (anti-corruption)

Full reference: ~/.claude/docs/event-sourcing/methodology.md (use echo "$HOME/.claude/docs/event-sourcing/methodology.md" to get absolute path)
```
