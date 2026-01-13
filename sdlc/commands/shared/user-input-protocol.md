---
description: INVOKE when subagent needs user input. AWAITING_USER_INPUT JSON format
user-invocable: false
---

# User Input Protocol

You cannot call AskUserQuestion directly. When you need user input, you must save your progress to a memento checkpoint and output a special marker.

## Step 1: Create Checkpoint

```
mcp__memento__create_entities:
  entities:
    - name: "<agent-name> Checkpoint <ISO-timestamp>"
      entityType: "agent_checkpoint"
      observations:
        - "Agent: <agent-name> | Task: <what you were asked to do>"
        - "Progress: <summary of what you've accomplished so far>"
        - "Files created: <list of files you've written, if any>"
        - "Files read: <key files you've examined>"
        - "Next step: <what you were about to do when you need input>"
        - "Pending decision: <what you need the user to decide>"
```

## Step 2: Output Marker and STOP

```
AWAITING_USER_INPUT
{
  "context": "What you're doing that requires input",
  "checkpoint": "<agent-name> Checkpoint <ISO-timestamp>",
  "questions": [
    {
      "id": "q1",
      "question": "Your full question here?",
      "header": "Label",
      "options": [
        {"label": "Option A", "description": "What this means"},
        {"label": "Option B", "description": "What this means"}
      ],
      "multiSelect": false
    }
  ]
}
```

## Step 3: STOP and Wait

The main agent will ask the user and launch a new task to continue.

## Step 4: On Continuation

You will receive:

```
USER_INPUT_RESPONSE
{"q1": "User's choice"}

Continue from checkpoint: <checkpoint-name>
```

Your first actions:
1. Query the checkpoint: `mcp__memento__open_nodes: ["<checkpoint-name>"]`
2. Re-read any files you created (listed in checkpoint)
3. Continue your work using the provided answers

## Format Rules

- `id`: Unique identifier (q1, q2, etc.)
- `header`: Very short label (max 12 chars)
- `options`: 2-4 choices with labels and descriptions
- `multiSelect`: true if user can select multiple options
- Always provide context so the user understands why you are asking
