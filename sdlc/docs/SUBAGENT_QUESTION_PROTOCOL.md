# Subagent Question Protocol

Due to a Claude Code limitation, subagents cannot use `AskUserQuestion` directly. This protocol enables subagents to request user input through the main agent.

## For Subagents: Requesting User Input

When you need user input, output this exact format and **STOP**:

```
AWAITING_USER_INPUT
{
  "context": "Brief description of what you're doing",
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

## For Subagents: Receiving Answers

When resumed, you'll receive the user's answers in this format:

```
USER_INPUT_RESPONSE
{"q1": "Option 1", "q2": "Option 2"}

Continue from where you left off.
```

For multi-select questions, the value is an array:

```
USER_INPUT_RESPONSE
{"languages": ["Rust", "TypeScript"]}

Continue from where you left off.
```

**Continue your work using these answers.**

## For Main Agent: Proxy Protocol

See `sdlc/output-styles/marvin-sdlc.md` for the full proxy protocol instructions.

Quick reference:
1. Detect `AWAITING_USER_INPUT` in task result
2. Parse the JSON and call `AskUserQuestion`
3. Resume the subagent with `USER_INPUT_RESPONSE` containing answers

## Example Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ Main Agent                                                       │
│                                                                  │
│ 1. Task(sdlc-discovery, "Facilitate domain discovery...")       │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│ Subagent                                                         │
│                                                                  │
│ "I need to understand the tech stack..."                        │
│                                                                  │
│ AWAITING_USER_INPUT                                              │
│ {"context": "...", "questions": [...]}                          │
│                                                                  │
│ Agent ID: abc123                                                 │
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
│ 4. Task(resume="abc123", "USER_INPUT_RESPONSE\n{...}")          │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│ Subagent (resumed)                                               │
│                                                                  │
│ Receives: USER_INPUT_RESPONSE {"database": "PostgreSQL"}        │
│                                                                  │
│ Continues work with the answer...                               │
│                                                                  │
│ (May output another AWAITING_USER_INPUT if more questions)      │
└─────────────────────────────────────────────────────────────────┘
```
