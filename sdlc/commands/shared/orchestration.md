---
description: INVOKE for ALL file operations. Orchestrator delegates to agents, never writes directly
user-invocable: false
---

# Orchestration Rules

The main conversation is an **orchestrator only**. It coordinates work but never writes code directly.

## Core Protocol: Skill Enforcement

**Before ANY task, invoke the skill enforcement protocol.** See `sdlc:shared/skill-enforcement` for:
- The 1% rule (if a skill might apply, invoke it)
- Rationalization red flags
- Mandatory invocations

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

### Domain Review is MANDATORY (NO EXCEPTIONS)

**You MUST invoke `sdlc:domain` after EVERY red phase and EVERY green phase.**

This is unconditional. There are NO valid reasons to skip domain review:
- NOT for "trivial" changes
- NOT for "obvious" rendering/UI fixes
- NOT for "simple" bug fixes
- NOT for "just one line"
- NOT for "it's clearly not a domain concern"

**Even if the domain agent will likely just approve**, the discipline of invoking it:
- Forces a pause to consider domain integrity
- Catches cases where "obviously just X" accidentally introduces problems
- Maintains the ritual that keeps the workflow consistent
- Provides documentation that the review happened

**Minimum domain review output** (even for "trivial" changes):
```
Domain review: No domain types modified, no primitive obsession introduced.
APPROVE - proceed to [next phase]
```

### The "Quick Fix" Trap

When fixing bugs or making "small" changes, you are **especially likely** to skip domain review. This is when you need it MOST:

- Bug fixes often introduce shortcuts that bypass type safety
- "Small" changes accumulate into primitive obsession
- "Obvious" rendering changes can leak domain concepts

**If you catch yourself thinking "this is too trivial for domain review" - that thought IS the red flag.**

### Anti-Patterns (VIOLATIONS)

| Pattern | Why It Fails | Correct Action |
|---------|--------------|----------------|
| "Just a small update" | Bypasses TDD | Launch `sdlc:red` first |
| "Quick fix" | Skips domain review | Full cycle required |
| "One line change" | Still needs verification | Run through agents |
| "Obviously not a domain concern" | Rationalization - review anyway | Invoke `sdlc:domain` |
| "It's just rendering/UI" | UI can leak domain concepts | Invoke `sdlc:domain` |
| "Domain would just rubber-stamp it" | The ritual matters | Invoke `sdlc:domain` |

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

### Fresh Context Protocol (CRITICAL)

**Agents have ZERO context from the conversation.** Every agent invocation starts fresh.

When launching ANY agent, you MUST provide:

| Information | Why | Example |
|-------------|-----|---------|
| File paths | Agent can't see what you've been discussing | "Edit `src/domain/user.rs`" |
| Current test | Green needs to know what to pass | "Make `test_user_creation` pass" |
| Acceptance criteria | What "done" looks like | "User must have valid email" |
| Relevant domain types | Prevent primitive obsession | "Use the `Email` type from `types.rs`" |
| Error messages | What specifically failed | "Test fails with: expected Ok, got Err" |

**NEVER say:**
- "As discussed earlier..." - Agent wasn't in that discussion
- "Continue from where we left off" - Agent has no memory
- "You know what to do" - Agent knows nothing
- "Fix the issue" - Which issue? Be specific

**ALWAYS say:**
- "The test at `tests/user_test.rs:45` fails with [exact error]"
- "Implement `fn create_user()` in `src/domain/user.rs` to make this pass"
- "Use the `Email` type for the email field, not `String`"

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

## Parallel Development (Worktrees)

When `git.worktrees: true` in `.claude/sdlc.yaml`, the project supports parallel development.

### Worktree-Aware Context

When working in a worktree:
1. **Check current location**: `git worktree list` shows all active worktrees
2. **Include worktree path** when launching agents so they know the context
3. **Store worktree info in memento** for session continuity

### Parallel Slice Prerequisites

Before starting parallel work on slices:
1. **Event schemas must be defined** - The contracts between slices
2. **Integration points must be spec'd** - Shared interfaces documented
3. **Slices must be independent** - No implementation dependencies

### When Parallel Development is Safe

| Scenario | Safe for Parallel? | Why |
|----------|-------------------|-----|
| Two slices from same workflow | YES | Slices are independent by design |
| Slice and its dependent | NO | Must complete integration first |
| Slice and shared infrastructure | DEPENDS | Infrastructure must be spec'd/stubbed |
| Two unrelated features | YES | No interaction |

### Worktree Cleanup

After PR merge:
```bash
# List worktrees
git worktree list

# Remove merged worktree
git worktree remove <path>

# Prune stale worktrees
git worktree prune
```

## Code Review Gate

Before creating PRs, the **three-stage code review** must pass:
1. **Stage 1: Spec Compliance** - All acceptance criteria implemented?
2. **Stage 2: Code Quality** - Clean, maintainable, well-tested?
3. **Stage 3: Domain Integrity** - Domain types used correctly? Compile-time enforcement opportunities?

Stage 3 invokes `sdlc:domain` for deep analysis including a **Compile-Time Enforcement Audit** - identifying runtime checks in tests that the type system could enforce instead.

See `sdlc:code-reviewer` agent for details. All three stages must pass before mutation testing.
