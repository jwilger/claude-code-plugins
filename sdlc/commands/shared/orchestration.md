---
description: SDLC orchestration rules - TDD workflow, file delegation, question proxy
user-invocable: false
---

# Orchestration Rules

The main conversation is an **orchestrator only**. It coordinates work but never writes code directly.

## File Operations (MANDATORY DELEGATION)

The main conversation **MUST NEVER** use Write or Edit tools directly. All file modifications go through specialized agents.

### Agent Selection Hierarchy

| File Type | Agent | Notes |
|-----------|-------|-------|
| Test files | `sdlc:red` | All test code, assertions, test fixtures |
| Implementation code | `sdlc:green` | Production code that makes tests pass |
| Domain types/models | `sdlc:domain` | Type definitions, domain entities |
| ADRs | `sdlc:adr` | Architecture Decision Records |
| GWT scenarios | `sdlc:gwt` | Given/When/Then acceptance criteria |
| Everything else | `sdlc:file-updater` | Config, docs, scripts, tooling |

### Update Request Detection

When the user requests a change, classify it:

| Request Pattern | Agent | Example |
|-----------------|-------|---------|
| "Add a test for..." | `sdlc:red` | "Add a test for user validation" |
| "Make the test pass" | `sdlc:green` | "Implement the handler" |
| "Create a type for..." | `sdlc:domain` | "Add an Email type" |
| "Update the config" | `sdlc:file-updater` | "Change the timeout setting" |
| "Record a decision" | `sdlc:adr` | "We chose PostgreSQL" |

## TDD Workflow

### The Cycle (MANDATORY SEQUENCE)

```
     +------------------------------------------------------------------+
     |                                                                  |
     v                                                                  |
+---------+     +----------------+     +---------+     +----------------+
|   RED   | --> | DOMAIN REVIEW  | --> |  GREEN  | --> | DOMAIN REVIEW  |
+---------+     +----------------+     +---------+     +----------------+
     |                 |                    |                 |
     v                 v                    v                 v
  Write ONE      Review test,          Minimal          Review impl,
  failing test   create types,      implementation     verify domain
                 check domain                          integrity
```

Domain review happens TWICE per cycle:
1. **After Red**: Review test implications, create types, evaluate domain alignment
2. **After Green**: Review implementation for domain integrity violations

### Anti-Patterns (VIOLATIONS)

| Pattern | Why It Fails | Correct Action |
|---------|--------------|----------------|
| "Just a small update" | Bypasses TDD | Launch `sdlc:red` first |
| "Quick fix" | Skips domain review | Full cycle required |
| "One line change" | Still needs verification | Run through agents |

### Pre-Edit Checklist

Before ANY code change, verify:
1. [ ] Is this a test file? -> `sdlc:red`
2. [ ] Is this production code? -> `sdlc:green`
3. [ ] Is this a type definition? -> `sdlc:domain`
4. [ ] Does the current test fail? (for green phase)
5. [ ] Has domain modeler reviewed? (before green)

### Agent Iteration Protocol

When launching an agent:
1. Provide clear context about what to do
2. Include relevant file paths
3. Specify the current TDD phase
4. Review the agent's output before proceeding
5. If agent raises concerns, facilitate debate

## Subagent Question Proxy Protocol

Subagents cannot ask users questions directly. Detect and proxy their requests.

### Detection

Look for this marker in task output:

```
AWAITING_USER_INPUT
{
  "context": "...",
  "checkpoint": "...",
  "questions": [...]
}
```

### Protocol Steps

1. **Parse** the JSON from the agent output
2. **Note** the checkpoint entity name
3. **Ask** the user using `AskUserQuestion` with the provided questions array
4. **Launch NEW task** (same agent type) with:
   ```
   USER_INPUT_RESPONSE
   {"q1": "User's Answer"}

   Continue from checkpoint: <checkpoint-entity-name>
   ```

### Critical Rules

- **NEVER** use the Task tool's `resume` parameter (known bug)
- **ALWAYS** launch a fresh task with the response
- The agent will restore context from its memento checkpoint

## Agent Debate Protocol

When agents disagree, facilitate resolution.

### Domain Modeler Veto Power

The domain modeler (`sdlc:domain`) has veto authority over:
- Primitive obsession (using String where domain type needed)
- Invalid state representability
- Parse-don't-validate violations
- Domain boundary violations

### Consensus Requirements

1. Domain raises concern -> Affected agent must respond substantively
2. Orchestrator asks clarifying questions
3. Seek compromise or agreement
4. **If no consensus after 2 rounds**: Escalate to user

### Debate Flow

```
Domain: CONCERN - primitive obsession in test
   |
   v
Red/Green: Explains reasoning
   |
   v
Orchestrator: Facilitates, proposes compromise
   |
   v
[Consensus] -> Proceed
[No consensus after 2 rounds] -> Ask user
```

### Orchestrator Actions During Debate

- Summarize each position clearly
- Ask for specific tradeoff analysis
- Propose middle-ground solutions
- Know when to escalate (don't let debates drag)
