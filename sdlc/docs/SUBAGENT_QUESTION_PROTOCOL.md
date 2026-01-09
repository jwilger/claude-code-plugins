# Subagent Question Protocol

Due to a Claude Code limitation, subagents cannot use `AskUserQuestion` directly. This protocol enables subagents to request user input through the main agent using memento checkpoints for state persistence.

> **Why Checkpoints?** Claude Code's `resume` parameter has a known bug ([Issue #13619](https://github.com/anthropics/claude-code/issues/13619)) that causes 400 errors when resuming agents that have used tools. This protocol avoids `resume` entirely by persisting state to memento.

## For Subagents: Requesting User Input

When you need user input, you must:
1. **Save your progress** to memento as a checkpoint
2. **Output the AWAITING_USER_INPUT marker** with checkpoint reference
3. **STOP** and wait for continuation

### Step 1: Create Checkpoint Entity

Before outputting AWAITING_USER_INPUT, save your current state:

```
mcp__memento__create_entities:
  entities:
    - name: "<agent-type> Checkpoint <ISO-timestamp>"
      entityType: "agent_checkpoint"
      observations:
        - "Agent: <your-agent-type> | Task: <what you were asked to do>"
        - "Progress: <summary of what you've accomplished so far>"
        - "Files created: <list of files you've written, if any>"
        - "Files read: <key files you've examined>"
        - "Next step: <what you were about to do when you need input>"
        - "Pending decision: <what you need the user to decide>"
```

If you've discovered domain knowledge, also create relationships:

```
mcp__memento__create_relations:
  relations:
    - from: "<checkpoint-name>"
      to: "<related-entity>"
      relationType: "discovered"
```

### Step 2: Output AWAITING_USER_INPUT

Output this exact format and **STOP**:

```
AWAITING_USER_INPUT
{
  "context": "Brief description of what you're doing",
  "checkpoint": "<agent-type> Checkpoint <ISO-timestamp>",
  "questions": [
    {
      "id": "q1",
      "question": "The full question text?",
      "header": "ShortLabel",
      "options": [
        {"label": "Option 1", "description": "What this means"},
        {"label": "Option 2", "description": "What this means"}
      ],
      "multiSelect": false
    }
  ]
}
```

### Format Rules

| Field | Description | Example |
|-------|-------------|---------|
| `context` | What you're working on (helps user understand) | "Designing database architecture" |
| `checkpoint` | The memento entity name you just created | "sdlc-discovery Checkpoint 2026-01-08T14:32:00Z" |
| `id` | Unique ID for each question | "q1", "q2", "db_choice" |
| `question` | Full question text ending with ? | "Which database fits your needs?" |
| `header` | Short label (max 12 chars) | "Database", "Auth", "Framework" |
| `options` | 2-4 choices with label and description | See below |
| `multiSelect` | `true` if multiple selections allowed | `false` |

### Option Format

```json
{
  "label": "PostgreSQL",
  "description": "Relational database with strong ACID compliance"
}
```

### Multiple Questions

You can ask up to 4 questions at once:

```
AWAITING_USER_INPUT
{
  "context": "Setting up the technology stack",
  "checkpoint": "sdlc-discovery Checkpoint 2026-01-08T14:32:00Z",
  "questions": [
    {
      "id": "database",
      "question": "Which database should we use?",
      "header": "Database",
      "options": [
        {"label": "PostgreSQL", "description": "Relational, ACID"},
        {"label": "MongoDB", "description": "Document store"}
      ],
      "multiSelect": false
    },
    {
      "id": "framework",
      "question": "Which web framework?",
      "header": "Framework",
      "options": [
        {"label": "Axum", "description": "Rust async framework"},
        {"label": "Actix", "description": "Rust actor framework"}
      ],
      "multiSelect": false
    }
  ]
}
```

## For Subagents: Continuing After User Response

When the main agent launches a new task with the user's answers, you'll receive:

```
USER_INPUT_RESPONSE
{"q1": "Option 1", "q2": "Option 2"}

Continue from checkpoint: <checkpoint-entity-name>
```

### Your First Actions on Continuation

1. **Query the checkpoint** to restore your context:
   ```
   mcp__memento__open_nodes: ["<checkpoint-entity-name>"]
   ```

2. **Follow relationships** to gather additional context:
   ```
   mcp__memento__semantic_search: "<project-name> domain"
   ```

3. **Re-read any files you created** (listed in checkpoint observations)

4. **Continue your work** with the user's answers and restored context

For multi-select questions, the value is an array:

```
USER_INPUT_RESPONSE
{"languages": ["Rust", "TypeScript"]}

Continue from checkpoint: sdlc-discovery Checkpoint 2026-01-08T14:32:00Z
```

## For Main Agent: Proxy Protocol

See `sdlc/output-styles/marvin-sdlc.md` for the full proxy protocol instructions.

Quick reference:
1. Detect `AWAITING_USER_INPUT` in task result
2. Parse the JSON, extract `checkpoint` and `questions`
3. Call `AskUserQuestion` with the provided questions array
4. Launch a **NEW task** (same agent type) with `USER_INPUT_RESPONSE` and checkpoint reference

**IMPORTANT**: Do NOT use the Task tool's `resume` parameter. Launch a fresh task instead.

## Example Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ Main Agent                                                       │
│                                                                  │
│ 1. Task(subagent_type="sdlc-discovery",                         │
│         prompt="Facilitate domain discovery for TaskFlow...")   │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│ Subagent (First Invocation)                                      │
│                                                                  │
│ "I need to understand the tech stack..."                        │
│                                                                  │
│ Creates checkpoint in memento:                                   │
│   name: "sdlc-discovery Checkpoint 2026-01-08T14:32:00Z"        │
│   observations:                                                  │
│     - "Agent: sdlc-discovery | Task: Domain discovery"          │
│     - "Progress: Identified 3 actors, learned core business"    │
│     - "Files created: docs/event_model/domain/overview.md"      │
│     - "Next step: Identify workflows"                           │
│     - "Pending decision: notification preferences"              │
│                                                                  │
│ AWAITING_USER_INPUT                                              │
│ {"context": "...", "checkpoint": "sdlc-discovery Checkpoint...",│
│  "questions": [...]}                                            │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│ Main Agent                                                       │
│                                                                  │
│ 2. Detects AWAITING_USER_INPUT                                  │
│ 3. AskUserQuestion(questions from JSON)                         │
│                                                                  │
│ User selects: "PostgreSQL"                                       │
│                                                                  │
│ 4. Task(subagent_type="sdlc-discovery",    ◄── NEW task, not    │
│         prompt="USER_INPUT_RESPONSE...         resume!          │
│                Continue from checkpoint: ...")                   │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│ Subagent (Second Invocation - Fresh Agent)                       │
│                                                                  │
│ Receives: USER_INPUT_RESPONSE {"database": "PostgreSQL"}        │
│           Continue from checkpoint: sdlc-discovery Checkpoint...│
│                                                                  │
│ 1. Queries memento for checkpoint                               │
│ 2. Reads files listed in checkpoint (overview.md)               │
│ 3. Has full context restored!                                   │
│                                                                  │
│ Continues work with the answer...                               │
│                                                                  │
│ (May create another checkpoint + AWAITING_USER_INPUT)           │
└─────────────────────────────────────────────────────────────────┘
```

## Checkpoint Best Practices

### What to Include in Checkpoint Observations

| Category | Example |
|----------|---------|
| Identity | `"Agent: sdlc-discovery \| Task: Domain discovery for TaskFlow"` |
| Progress | `"Progress: Completed actor mapping, identified 5 workflows"` |
| Artifacts | `"Files created: docs/event_model/domain/overview.md, docs/event_model/workflows/user-registration.md"` |
| Context | `"Files read: README.md, Cargo.toml, existing docs/"` |
| Next Step | `"Next step: Detail the User Registration workflow"` |
| Pending | `"Pending decision: Notification delivery method"` |

### Creating Relationships

Link your checkpoint to other relevant entities:

```
mcp__memento__create_relations:
  relations:
    - from: "sdlc-discovery Checkpoint 2026-01-08T14:32:00Z"
      to: "TaskFlow Project"
      relationType: "part_of"
    - from: "sdlc-discovery Checkpoint 2026-01-08T14:32:00Z"
      to: "TaskFlow Domain Concepts Jan 2026"
      relationType: "discovered"
```

### Checkpoint Naming Convention

Use: `<agent-type> Checkpoint <ISO-8601-timestamp>`

Examples:
- `sdlc-discovery Checkpoint 2026-01-08T14:32:00Z`
- `sdlc-workflow-designer Checkpoint 2026-01-08T15:45:30Z`
- `sdlc-red Checkpoint 2026-01-08T16:00:00Z`

The timestamp ensures uniqueness and provides temporal context.
