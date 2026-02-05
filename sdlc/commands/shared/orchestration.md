---
description: INVOKE for ALL file operations. Orchestrator delegates to agents, never writes directly
user-invocable: false
---

# Orchestration Rules

The main conversation is an **orchestrator only**. It coordinates work but never writes code directly.

## Core Protocol: Orchestration

The orchestrator coordinates work through specialized agents, each with a focused responsibility. Task dependencies enforce workflow discipline mechanically - no manual confirmation gates needed.

## ADR Isolation Principle (CRITICAL)

**ADRs are archival documents.** They exist ONLY to preserve the context of WHY decisions were made, for use when we might reconsider those decisions in the future.

**NEVER reference ADRs in:**
- GitHub issues or PRs
- Code comments
- Review feedback
- Story/slice documentation
- Implementation guidance
- Any day-to-day work output

**ALWAYS reference ARCHITECTURE.md instead** - it is THE authoritative source for current architecture.

The ONLY time ADRs should be consulted is when someone is actively considering changing an architectural decision and needs to understand why the original decision was made.

## Git Operation Protocol (MANDATORY)

Before ANY git operation (commit, branch, rebase, merge, push), check if git-spice manages this project.

### Detection

```bash
# Check if git-spice is installed AND current branch is managed
command -v gs >/dev/null 2>&1 && gs branch checkout 2>/dev/null && echo "GS_MANAGED" || echo "REGULAR_GIT"
```

### Protocol

1. **If GS_MANAGED**: Follow `git-spice` skill patterns and decision tree
2. **If REGULAR_GIT**: Use standard git commands

### Critical Git-Spice Operations

When using git-spice:
- **After PR merges**: Run `gs repo sync`, then IMMEDIATELY verify (see git-spice.md Post-Sync Verification)
- **View stack status**: Use `gs log short` (NOT bare `gs stack` - that doesn't exist)
- **If sync goes wrong**: Use `gs upstack onto <correct-base>` to recover

### Why This Matters

Git-spice manages branch relationships. Using regular git commands (like `git rebase`) on gs-managed branches can corrupt the stack state, leading to lost work or branches moved to wrong bases.

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

### CRITICAL: The Red → Domain Feedback Loop

When domain raises a concern that causes red to revise the test, **domain MUST re-review after the revision**:

```
Red writes test → Domain reviews → Domain raises concern
                                         ↓
                              Red revises test
                                         ↓
                              Domain MUST re-review ← MANDATORY
                                         ↓
                              Domain creates types
                                         ↓
                              Green implements
```

**THE RULE:** After red revises a test based on domain feedback, domain MUST be invoked again BEFORE green.

**Why this matters:**
- Domain's first pass identifies issues with the test design
- Red revises to address those issues (new test signature, different types needed)
- Domain's SECOND pass creates the types for the REVISED test
- **Without the second pass, types don't exist and green is blocked**

**The failure mode:** If you skip domain re-review after red revises:
1. Red writes test with `fn new(name: String) -> Task`
2. Domain says: "Use Result for fallible construction"
3. Red revises to `fn new(name: String) -> Result<Task, TaskError>`
4. ❌ WRONG: Go to green → green has no `TaskError` type
5. ✅ RIGHT: Re-invoke domain → domain creates `TaskError` → green implements

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

## Task Dependency Protocol (Workflow Enforcement)

**Use task dependencies to enforce workflow sequence mechanically.** The TDD cycle is enforced through task blocking relationships, not manual confirmation gates.

### TDD Cycle Task Pattern

```javascript
// Create Red phase task
const redTask = await TaskCreate({
  subject: "Write failing test for user authentication",
  description: "Write ONE test that fails. Verify exact failure message.",
  activeForm: "Writing failing test",
  metadata: { phase: "red", feature: "user-auth" }
});

// Create Domain-after-Red task (blocked by red)
const domainAfterRedTask = await TaskCreate({
  subject: "Review test and create domain types",
  description: "Review test for domain integrity. Create needed types with unimplemented!() stubs.",
  activeForm: "Creating domain types",
  metadata: { phase: "domain-after-red", feature: "user-auth" }
});
await TaskUpdate({
  taskId: domainAfterRedTask.id,
  addBlockedBy: [redTask.id]
});

// Create Green phase task (blocked by domain-after-red)
const greenTask = await TaskCreate({
  subject: "Implement minimal code to pass test",
  description: "Make test pass with simplest implementation. No extra features.",
  activeForm: "Implementing minimal solution",
  metadata: { phase: "green", feature: "user-auth" }
});
await TaskUpdate({
  taskId: greenTask.id,
  addBlockedBy: [domainAfterRedTask.id]
});

// Create Domain-after-Green task (blocked by green)
const domainAfterGreenTask = await TaskCreate({
  subject: "Review implementation for domain integrity",
  description: "Review implementation for primitive obsession, invalid states, domain violations.",
  activeForm: "Reviewing domain integrity",
  metadata: { phase: "domain-after-green", feature: "user-auth" }
});
await TaskUpdate({
  taskId: domainAfterGreenTask.id,
  addBlockedBy: [greenTask.id]
});
```

### Why Task Dependencies Replace Gates

**Old approach (v3.x):** Manual confirmation gates requiring orchestrator to pass context blocks
**New approach (v4.x):** Mechanical task blocking - agents cannot start until dependencies complete

Benefits:
- **Automatic enforcement** - Can't skip workflow steps
- **Visual workflow state** - See entire cycle in task list
- **Resumable** - Restore workflow state after session interruption
- **Parallel-ready** - Multiple cycles can run independently
- **Self-documenting** - Task metadata captures workflow history

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
