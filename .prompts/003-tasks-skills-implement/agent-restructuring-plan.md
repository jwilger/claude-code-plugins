# Agent Restructuring Plan: Task-Aware Skill Loaders

**Date:** 2026-02-04
**Version:** 1.0
**Purpose:** Document how agents would be restructured to load skills and integrate with tasks

---

## Overview

This document describes the transformation of sdlc agents from heavy, protocol-duplicating agents to lightweight skill loaders that integrate with Claude Code's task system.

**Restructuring Principle:** Agents compose skills for knowledge, use tasks for structure, and preserve hooks for validation.

### Key Changes in v4.0.0

**1. Invocation Gates Removed** ✅ DECISION FINALIZED
- ❌ No more `MANDATORY INVOCATION CONFIRMATION` sections
- ❌ No more prompt-based context validation
- ✅ Task dependencies provide mechanical enforcement
- ✅ Agents get context from TaskGet(taskId).metadata

**2. Background Execution by Default** ✅ NEW
- Long-running agents (mutation, code-review) run with `run_in_background: true`
- Agents can access MCP tools if explicitly listed in `tools:`
- Non-blocking workflow - user continues working
- Notification when background agent completes

**3. Agent Resumption Pattern** ✅ CRITICAL NEW FEATURE
- Background agents can pause with questions
- Store question in task metadata (`needs_input: true`)
- Main conversation asks user via AskUserQuestion
- Resume agent with Task({ resume: agentId, prompt: "User answered..." })
- Agent continues with full context, no wasted work

**4. Generic Skill Names** ✅ DECISION FINALIZED
- Skills reference changed from `sdlc:shared/tdd-constraints` to `tdd-constraints`
- Top-level skills/ directory: `claude-code-plugins/skills/tdd-constraints/`
- Installation: `npx skills add jwilger/claude-code-plugins`

**5. Task Metadata Schema Extended** ✅ NEW FIELDS
- Added 7 resumption fields: `agent_id`, `needs_input`, `question`, `question_context`, `question_options`, `user_answer`, `answered_at`
- Agents use TaskGet/TaskUpdate to read/write workflow state
- Persistent across sessions via task system

---

## Before/After Conceptual Examples

### Example 1: Red Agent Restructuring

#### BEFORE (Current v3.12.8)

**Frontmatter:**
```yaml
---
name: red
description: INVOKE for ALL test file changes. TEST CODE ONLY. One assertion per test
model: inherit
skills:
  - sdlc:shared/user-input-protocol
  - sdlc:shared/memory-protocol
  - sdlc:shared/tdd-constraints
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - mcp__memento__semantic_search
  - mcp__memento__create_entities
  - mcp__memento__open_nodes
  - mcp__memento__create_relations
hooks:
  PreToolUse:
    - matcher: Edit
      hooks:
        - type: prompt
          prompt: |
            CONSTRAINT CHECK: You may ONLY edit TEST files.
            [Validation logic...]
  # ... more hooks
---
```

**Agent Prompt (Excerpt):**
```markdown
## MANDATORY INVOCATION CONFIRMATION (Gate Check)

**Before proceeding with ANY work, you MUST verify the orchestrator has provided the required context in the prompt:**

### Required Context Declaration

The orchestrator MUST declare ONE of these contexts:

**Option A - First Test (Starting Fresh):**
```
RED_CONTEXT: FIRST_TEST
ACCEPTANCE_CRITERIA:
- <criteria from the story/task>
```

**Option B - Continuing After Completed Cycle:**
```
RED_CONTEXT: CONTINUING
PREVIOUS_CYCLE_COMPLETE:
- Test: <previous test name>
- Status: PASSES
- Refactoring: <"None" or "Completed: <description>">
```

[If gate validation fails, return: INVOCATION GATE FAILED]
```

**Characteristics:**
- 400+ line agent file
- Duplicates protocol content (user-input, memory, TDD patterns)
- Invocation gate validation in agent prompt
- No task awareness

#### AFTER (v4.0.0)

**Frontmatter:**
```yaml
---
name: red
description: INVOKE for ALL test file changes. TEST CODE ONLY. One assertion per test
model: inherit
skills:
  - user-input-protocol        # Removed sdlc:shared/ prefix
  - memory-protocol            # Removed sdlc:shared/ prefix
  - tdd-constraints            # Removed sdlc:shared/ prefix
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - TaskGet                    # NEW: Task awareness
  - TaskUpdate                 # NEW: Task completion
  - mcp__memento__semantic_search
  - mcp__memento__create_entities
  - mcp__memento__open_nodes
  - mcp__memento__create_relations
hooks:
  PreToolUse:
    - matcher: Edit
      hooks:
        - type: prompt
          prompt: |
            CONSTRAINT CHECK: You may ONLY edit TEST files.
            [Validation logic - UNCHANGED]
  # ... hooks PRESERVED
---
```

**Agent Prompt (Excerpt):**
```markdown
# SDLC Red Phase Agent

You are a TDD specialist focused on the RED phase - writing failing tests.

## Shared Protocols

Follow protocols from injected skills:
- **user-input-protocol**: Checkpoint format for pausing work
- **memory-protocol**: Memento integration patterns
- **tdd-constraints**: Red phase boundaries and constraints

## Workflow Context (Task-Based)

**Check TaskList for your assigned task:**

```javascript
const tasks = TaskList();
const myTask = tasks.find(t =>
  t.owner === "red" &&
  t.status === "pending" &&
  t.blockedBy.length === 0
);

if (!myTask) {
  return "No red phase tasks available. Check TaskList or ask user.";
}

const taskDetails = TaskGet(myTask.id);
const {
  test_file,
  acceptance_criterion,
  cycle_number,
  feature
} = taskDetails.metadata;

// Use task metadata for context - no gates in v4.0.0
```

**No invocation gates in v4.0.0** - Tasks provide ALL context via metadata.

## Your Process

1. **Get context from task metadata** (or gate if legacy)
2. **Search Memento** for relevant test patterns
3. **Write ONE failing test** with ONE assertion
4. **Run test** and paste FULL output
5. **Update task** with results:
   ```javascript
   TaskUpdate({
     taskId: myTask.id,
     status: "completed",
     metadata: {
       ...taskDetails.metadata,
       last_test_output: "[abbreviated output]",
       test_file: "[final file path]"
     }
   });
   ```
6. **Store patterns** in Memento if worth remembering

[Rest of agent-specific instructions - REDUCED, skills handle protocols]
```

**Characteristics:**
- 200-250 line agent file (40% reduction)
- No duplicated protocol content (skills provide)
- Task-aware (checks TaskList, uses TaskGet/TaskUpdate)
- Backward compatible (fallback to gates)
- Hooks preserved (unchanged)

**Key Changes:**
- ✅ Skills: removed sdlc:shared/ prefix
- ✅ Tools: added TaskGet, TaskUpdate
- ✅ Prompt: replaced gate validation with TaskList checking
- ✅ Prompt: added task completion updating
- ✅ Prompt: reduced size (skills handle protocols)
- ✅ Hooks: PRESERVED (unchanged)
- ✅ Backward compat: fallback to gates if no tasks

---

### Example 2: Domain Agent Restructuring

#### BEFORE (Current v3.12.8)

**Agent prompt includes:**
```markdown
## MANDATORY INVOCATION CONFIRMATION (Gate Check)

The orchestrator MUST declare ONE of these contexts:

**Option A - After Red Phase:**
```
DOMAIN_CONTEXT: AFTER_RED
RED_PHASE_COMPLETE:
- Test: <test name>
- Failure: <exact error message>
```

**Option B - After Green Phase:**
```
DOMAIN_CONTEXT: AFTER_GREEN
GREEN_PHASE_COMPLETE:
- Test: <test name>
- Result: <"PASSES" or "fails with: <new error>">
```

**Option C - PR Review:**
```
DOMAIN_CONTEXT: PR_REVIEW
PR_SCOPE:
- Files: <list of changed files>
- Purpose: <what the PR does>
```
```

**Runs twice per TDD cycle:**
1. After red (create types)
2. After green (review implementation)

#### AFTER (v4.0.0)

**Agent prompt becomes:**
```markdown
# SDLC Domain Model Expert

You are the **guardian of domain integrity** in the TDD workflow.

## Shared Protocols

This agent uses shared protocols loaded via skills:
- **user-input-protocol**: Checkpoint/question format
- **memory-protocol**: Memento usage patterns
- **tdd-constraints**: Phase boundaries and domain review responsibilities

## Workflow Context (Task-Based)

**Check TaskList for your assigned task:**

```javascript
const tasks = TaskList();
const myTask = tasks.find(t =>
  t.owner === "domain" &&
  t.status === "pending" &&
  t.blockedBy.length === 0
);

if (!myTask) {
  return "No domain tasks available. Ensure previous phase completed.";
}

const taskDetails = TaskGet(myTask.id);
const {
  phase,              // "domain-after-red" or "domain-after-green" or "pr-review"
  test_file,
  implementation_file,
  acceptance_criterion,
  cycle_number
} = taskDetails.metadata;

// Branch based on phase
if (phase === "domain-after-red") {
  // Review test, create types
  reviewTestAndCreateTypes(taskDetails);
} else if (phase === "domain-after-green") {
  // Review implementation for domain violations
  reviewImplementation(taskDetails);
} else if (phase === "pr-review") {
  // Review PR scope for domain integrity
  reviewPR(taskDetails);
}
```

**Fallback (Backward Compatibility):**

If no tasks exist, check for DOMAIN_CONTEXT gate in prompt (legacy support).

## Your Responsibilities

### When phase === "domain-after-red"
1. **Read test** from task metadata test_file
2. **Search Memento** for domain patterns
3. **Evaluate test** for domain violations:
   - Primitive obsession?
   - Invalid states representable?
   - Parse-don't-validate?
4. **Either:**
   - VETO and request test revision (if domain concerns)
   - Create type definitions (if test is good)
5. **Update task** when complete:
   ```javascript
   TaskUpdate({
     taskId: myTask.id,
     status: "completed",
     metadata: {
       ...taskDetails.metadata,
       types_file: "[path to types created]",
       domain_types_created: ["User", "Email", "Password"],
       domain_concerns: [] // or ["Primitive obsession in email"]
     }
   });
   ```

### When phase === "domain-after-green"
[Similar pattern for implementation review]

[Rest of agent instructions - REDUCED, skills handle protocols]
```

**Key Changes:**
- Task metadata provides phase context (replaces gate)
- Conditional logic based on task phase
- Task completion updates metadata
- Falls back to gates for backward compatibility

---

### Example 3: New Orchestrator Agent

#### NO CURRENT EQUIVALENT (New in v4.0.0)

Currently the "main conversation" acts as orchestrator, using orchestration.md skill.

#### NEW IN v4.0.0

**File:** `sdlc/agents/orchestrator.md`

```yaml
---
name: orchestrator
description: Coordinate TDD workflow using tasks and subagents. DELEGATION ONLY - never writes code
model: haiku                 # Fast, cheap for coordination
skills:
  - orchestration-protocol   # Core delegation rules
  - tdd-constraints          # TDD workflow knowledge
tools:
  - TaskCreate               # Create workflow tasks
  - TaskUpdate               # Update task dependencies
  - TaskGet                  # Get task details
  - TaskList                 # Monitor progress
  - Task                     # Spawn subagents
  - Read                     # Read files for context
  - Bash                     # Run git, gh commands
  - Glob                     # Find files
  - Grep                     # Search code
  - AskUserQuestion          # User interaction
  - mcp__memento__semantic_search    # Search memory
  - mcp__memento__create_entities    # Store decisions
disallowedTools:
  - Write                    # NEVER write files
  - Edit                     # NEVER edit files
---

# TDD Workflow Orchestrator

You coordinate the TDD workflow. You NEVER write code directly - you create tasks and spawn agents.

## Shared Protocols

- **orchestration-protocol**: Agent delegation rules (loaded as skill)
- **tdd-constraints**: TDD workflow understanding (loaded as skill)

## Your Responsibilities

1. **Understand user's intent** - What feature are they building?
2. **Create task graph** - Structure workflow with dependencies
3. **Spawn specialized agents** - red, green, domain for execution
4. **Monitor progress** - Check TaskList, handle agent questions
5. **Facilitate debates** - When domain and red disagree, mediate
6. **Report to user** - Keep user informed of progress

## Task Creation Pattern

For each acceptance criterion, create this task graph:

```javascript
// Task 1: Red phase (no dependencies)
const redTask = TaskCreate({
  subject: "Write failing test for [feature]",
  description: "Create test verifying [acceptance criterion]. Test should fail with clear error.",
  activeForm: "Writing failing test",
  metadata: {
    feature: "[feature-name]",
    cycle_number: 1,
    phase: "red",
    acceptance_criterion: "[criterion text]",
    parent_issue: "#123"
  }
});

// Task 2: Domain review (blocked by red)
const domainAfterRedTask = TaskCreate({
  subject: "Create domain types for [feature]",
  description: "Review red phase test. Create type definitions. Check domain violations.",
  activeForm: "Creating domain types",
  metadata: {
    feature: "[feature-name]",
    cycle_number: 1,
    phase: "domain-after-red"
  }
});
TaskUpdate({ taskId: domainAfterRedTask.id, addBlockedBy: [redTask.id] });

// Task 3: Green phase (blocked by domain)
const greenTask = TaskCreate({
  subject: "Implement [feature] to pass test",
  description: "Minimal implementation using types from domain. Make test pass.",
  activeForm: "Implementing [feature]",
  metadata: {
    feature: "[feature-name]",
    cycle_number: 1,
    phase: "green"
  }
});
TaskUpdate({ taskId: greenTask.id, addBlockedBy: [domainAfterRedTask.id] });

// Task 4: Domain review of implementation (blocked by green)
const domainAfterGreenTask = TaskCreate({
  subject: "Review [feature] implementation for domain integrity",
  description: "Check green phase for domain violations. Verify parse-don't-validate.",
  activeForm: "Reviewing implementation",
  metadata: {
    feature: "[feature-name]",
    cycle_number: 1,
    phase: "domain-after-green"
  }
});
TaskUpdate({ taskId: domainAfterGreenTask.id, addBlockedBy: [greenTask.id] });
```

## Agent Spawning

After creating task graph, spawn first agent:

```javascript
Task("sdlc:red", {
  instruction: "Check TaskList for your tasks. Complete the red phase task.",
  // Agent will use TaskList to find task, TaskGet for details, TaskUpdate when done
});
```

When red completes, spawn domain:

```javascript
Task("sdlc:domain", {
  instruction: "Check TaskList for your tasks. Complete the domain review task.",
});
```

Continue pattern through workflow.

## Monitoring Progress

```javascript
const status = TaskList();
const pending = status.filter(t => t.status === "pending");
const inProgress = status.filter(t => t.status === "in_progress");
const completed = status.filter(t => t.status === "completed");

// Report to user:
// "TDD Cycle 1: ✓ Red complete, ◻ Domain in progress, ◻ Green pending, ◻ Domain review pending"
```

## Conflict Resolution

When domain raises concern about red's test:

1. **Read domain's concern** from task metadata or agent response
2. **Ask red to revise** test addressing concern
3. **CRITICAL: Re-invoke domain** after red revises (domain must review revision)
4. **Only then proceed** to green phase

## You NEVER:
- Write or edit files (disallowed tools)
- Implement features (that's green's job)
- Create types (that's domain's job)
- Write tests (that's red's job)

You are the conductor, agents are the musicians.
```

**Key Characteristics:**
- Haiku model (cost-efficient for coordination)
- disallowedTools enforces delegation
- Task tools explicitly included
- Loads orchestration skills, doesn't duplicate
- Creates task graphs, spawns agents, monitors progress

---

### Example 4: Code Reviewer Restructuring

#### BEFORE (Current v3.12.8)

Single agent, sequential execution:

```markdown
# SDLC Code Reviewer Agent

You perform THREE-STAGE reviews. Each stage is independent.

## Stage 1: Spec Compliance Review
[200 lines of instructions...]

## Stage 2: Code Quality Review
[150 lines of instructions...]

## Stage 3: Domain Integrity Review
[150 lines of instructions...]

[Agent runs all three stages sequentially in one invocation]
```

**Issues:**
- Cannot skip stages (good)
- But skipping is enforced by prompt discipline only (bad)
- No resumability if interrupted
- No clear progress tracking

#### AFTER (v4.0.0)

**Agent becomes task-aware:**

```yaml
---
name: code-reviewer
description: INVOKE before PRs. Three-stage review (spec, quality, domain)
model: inherit
skills:
  - memory-protocol
  - user-input-protocol
  - debugging-protocol        # NEW: For systematic investigation
tools:
  - Read
  - Bash
  - Glob
  - Grep
  - TaskGet                   # NEW: Get assigned review stage
  - TaskUpdate                # NEW: Complete stage
  - mcp__memento__semantic_search
  - mcp__memento__create_entities
---

# SDLC Code Reviewer Agent

You perform one stage of a three-stage review process. Stages are enforced via task dependencies.

## Shared Protocols
- **memory-protocol**: Search for project conventions
- **user-input-protocol**: Pause for clarification
- **debugging-protocol**: Systematic issue investigation

## Task-Based Review

**Check which stage you're assigned:**

```javascript
const myTask = TaskGet(taskId); // Provided by orchestrator
const { review_stage, base_ref, head_ref } = myTask.metadata;

switch (review_stage) {
  case "spec":
    performSpecReview(myTask);
    break;
  case "quality":
    performQualityReview(myTask);
    break;
  case "domain":
    performDomainReview(myTask);
    break;
}
```

## Stage 1: Spec Compliance (review_stage === "spec")

### Your Job
Verify all acceptance criteria are implemented. Not more, not less.

[Stage 1 instructions - FOCUSED on this stage only]

### Completion
```javascript
TaskUpdate({
  taskId: myTask.id,
  status: "completed",
  metadata: {
    ...myTask.metadata,
    review_findings: specIssues.length,
    spec_issues: specIssues // Array of issue objects
  }
});
```

## Stage 2: Code Quality (review_stage === "quality")

[Stage 2 instructions...]

## Stage 3: Domain Integrity (review_stage === "domain")

[Stage 3 instructions...]
```

**Orchestrator creates tasks:**

```javascript
// Orchestrator invoked by /sdlc:review command

// Task 1: Spec compliance
const specTask = TaskCreate({
  subject: "Code review: Spec compliance",
  description: "Verify all acceptance criteria implemented correctly",
  activeForm: "Reviewing spec compliance",
  metadata: {
    feature: "user-authentication",
    phase: "review",
    review_stage: "spec",
    base_ref: "main",
    head_ref: "feature/123-auth"
  }
});

// Task 2: Quality (blocked by spec)
const qualityTask = TaskCreate({
  subject: "Code review: Quality assessment",
  description: "Check code smells, maintainability, test gaps",
  activeForm: "Reviewing code quality",
  metadata: {
    feature: "user-authentication",
    phase: "review",
    review_stage: "quality"
  }
});
TaskUpdate({ taskId: qualityTask.id, addBlockedBy: [specTask.id] });

// Task 3: Domain (blocked by quality)
const domainTask = TaskCreate({
  subject: "Code review: Domain integrity",
  description: "Check domain violations, primitive obsession, invalid states",
  activeForm: "Reviewing domain integrity",
  metadata: {
    feature: "user-authentication",
    phase: "review",
    review_stage: "domain"
  }
});
TaskUpdate({ taskId: domainTask.id, addBlockedBy: [qualityTask.id] });

// Spawn reviewer for stage 1
Task("sdlc:code-reviewer", {
  taskId: specTask.id,
  instruction: "Perform spec compliance review for this task"
});
```

**Benefits:**
- Cannot skip stages (task dependencies enforce)
- Clear progress (TaskList shows ✓ spec, ◻ quality, ◻ domain)
- Resumable (if interrupted, pick up at current stage)
- Each stage completes independently
- Findings stored in task metadata

---

## Background Execution and Agent Resumption

### Background by Default for Long-Running Agents

**Decision (2026-02-04):** Long-running agents run in background by default.

**Agents running in background:**
- **mutation** (10-30 min runtime) - ✅ Has MCP tools configured
- **code-reviewer** (5-10 min) - ✅ Can access MCP if needed
- **domain** (3-5 min, but may need to pause for questions) - ✅ MCP configured

**Agents remaining foreground:**
- **red** (1-2 min, interactive)
- **green** (1-2 min, interactive)
- **orchestrator** (coordination only, not heavy work)

**How orchestrator spawns background agents:**
```javascript
// In main conversation (orchestrator logic)
const mutationResult = await Task({
  subagent_type: "mutation",
  prompt: `Run mutation tests for ${feature}. Work on task: ${mutationTaskId}`,
  run_in_background: true,  // Non-blocking
  model: "sonnet"
});

// Returns immediately with:
// { agentId: "abc123", taskId: "...", output_file: "/path/to/output" }

// User continues working while mutation runs
// Notification when complete
```

**Benefits:**
- User continues working (start next feature)
- Notifications when background agents complete
- TaskList shows ◻ pending, ▲ blocked, ✓ completed
- Can check progress: `tail -f /path/to/output`

### Agent Resumption Pattern (CRITICAL NEW FEATURE)

**Problem:** Background agents can't use AskUserQuestion (tool call fails).

**Solution:** Agent pauses → stores question in task metadata → main conversation asks → resumes with answer.

**Full Example: Mutation Agent Asks Question**

**Step 1: Agent pauses with question**
```javascript
// Inside mutation agent (running in background)
const task = await TaskGet(myTaskId);

// Found 3 surviving mutants - need user decision
await TaskUpdate({
  taskId: task.id,
  metadata: {
    ...task.metadata,
    agent_id: myAgentId,           // Store for resumption
    needs_input: true,             // Signal pause
    question: "Found 3 surviving mutants. Create individual tasks for each?",
    question_context: {
      surviving_mutants: [
        { file: "auth.rs", line: 42, mutation: "== to !=" },
        { file: "auth.rs", line: 58, mutation: "true to false" },
        { file: "types.rs", line: 15, mutation: "Some to None" }
      ]
    },
    question_options: ["Yes - create tasks", "No - just report", "Show details first"]
  }
});

return "Paused - awaiting user decision on surviving mutants";
// Agent exits, preserving full conversation history
```

**Step 2: Orchestrator detects pause and asks user**
```javascript
// Main conversation checks for paused agents
const task = await TaskGet(mutationTaskId);

if (task.metadata.needs_input) {
  // Ask user
  const answer = await AskUserQuestion({
    questions: [{
      question: task.metadata.question,
      header: "Mutation Testing",
      options: task.metadata.question_options.map(opt => ({
        label: opt,
        description: ""
      }))
    }]
  });

  // Clear pause, store answer
  await TaskUpdate({
    taskId: task.id,
    metadata: {
      ...task.metadata,
      needs_input: false,
      user_answer: answer,
      answered_at: new Date().toISOString()
    }
  });

  // Resume agent with answer
  Task({
    subagent_type: "mutation",
    resume: task.metadata.agent_id,  // Resume previous session!
    prompt: `User answered: "${answer}". Continue from where you left off.`,
    run_in_background: true
  });
}
```

**Step 3: Resumed agent continues**
```javascript
// Agent resumes with FULL context
// - All previous tool calls and results preserved
// - Knows about the 3 surviving mutants (already analyzed)
// - Has user's answer
// - No need to re-run mutation tests

const task = await TaskGet(myTaskId);
const userAnswer = task.metadata.user_answer;

if (userAnswer === "Yes - create tasks") {
  // Create tasks for each mutant
  for (const mutant of task.metadata.question_context.surviving_mutants) {
    TaskCreate({
      subject: `Fix mutant: ${mutant.file}:${mutant.line}`,
      description: `Mutation: ${mutant.mutation}`,
      metadata: { feature: task.metadata.feature, phase: "mutation-fix" }
    });
  }
}

// Complete mutation task
TaskUpdate({ taskId: task.id, status: "completed" });
return "Created 3 tasks for surviving mutants. Mutation phase complete.";
```

**Benefits:**
- ✅ Background agents can ask questions (indirectly)
- ✅ No wasted work - agent resumes with full history
- ✅ Clean AskUserQuestion experience for user
- ✅ Works for any agent needing user input

**Agents using resumption pattern:**
- **mutation** - Pause for surviving mutant decisions
- **code-reviewer** - Pause for architectural clarifications
- **domain** - Pause for business rule questions

**Task metadata requirements:**
```typescript
// Added in v4.0.0
interface SDLCTaskMetadata {
  // ... existing fields ...
  agent_id?: string;            // For resuming
  needs_input?: boolean;        // Pause signal
  question?: string;            // Question text
  question_context?: object;    // Context
  question_options?: string[];  // Options
  user_answer?: string;         // Answer
  answered_at?: string;         // Timestamp
}
```

---

## Skill Loading Patterns

### Pattern 1: Core TDD Agents (Red, Green, Domain)

**Common pattern:**
```yaml
skills:
  - user-input-protocol    # Checkpoints and questions
  - memory-protocol        # Memento integration
  - tdd-constraints        # Phase boundaries
```

**Why these three:**
- user-input: May need to pause for clarification
- memory: Store/retrieve patterns
- tdd-constraints: Understand phase responsibilities

### Pattern 2: Specialized Agents (Mutation, Story, Architect)

**Minimal skills:**
```yaml
skills:
  - memory-protocol
  - user-input-protocol
```

**Why minimal:**
- Don't need TDD constraints (not part of red/green/domain cycle)
- May add domain-specific skills (e.g., story loads github-issues)

### Pattern 3: Event Modeling Cluster

**workflow-designer, model-checker, design-facilitator:**
```yaml
skills:
  - event-modeling         # Event Modeling patterns
  - memory-protocol        # Store/retrieve models
  - user-input-protocol    # Pause for decisions
```

**Why event-modeling:**
- All three agents work with Event Modeling diagrams
- Shared validation rules
- Common patterns

### Pattern 4: New Orchestrator

**Lightweight coordination:**
```yaml
skills:
  - orchestration-protocol  # Delegation rules
  - tdd-constraints         # Workflow understanding
```

**Why these two:**
- orchestration: Know how to delegate
- tdd-constraints: Understand workflow structure
- Does NOT load: memory, user-input, event-modeling (not needed for coordination)

---

## Backward Compatibility Approach

### Phase 1: Both Active (v4.0.0 initial)

**Agents support both mechanisms:**

```markdown
## Workflow Context

**Preferred: Check TaskList for your task**

```javascript
const myTask = TaskList().find(t => t.owner === "red" && ...);
if (myTask) {
  // Use task-based workflow
  const context = TaskGet(myTask.id);
  // ... work using task metadata
}
```

**Fallback: Check for invocation gate**

If no tasks exist, check prompt for gate context:

```
If you see RED_CONTEXT: FIRST_TEST in the prompt, use that context.
```

This allows:
- New workflows use tasks (orchestrator creates task graphs)
- Legacy workflows use gates (existing scripts, manual invocations)
- Gradual migration
```

### Phase 2: Tasks Primary (v4.1.0+)

**Agents prefer tasks, gates are defensive:**

```markdown
## Workflow Context

**Check TaskList first:**

```javascript
const myTask = TaskList().find(t => t.owner === "red" && ...);
if (!myTask) {
  throw "No task assigned. This agent should be invoked via task system.";
}

// Defensive check: If gate context provided, verify it matches task
if (promptHasGateContext) {
  verifyGateMatchesTask(gateContext, myTask.metadata);
}
```

Gates become defensive checks, tasks are source of truth.
```

### Phase 3: Tasks Only (v5.0.0+)

**Agents require tasks, gates removed:**

```markdown
## Workflow Context

**Retrieve your task:**

```javascript
const myTask = TaskList().find(t => t.owner === "red" && ...);
if (!myTask) {
  return "ERROR: No task assigned. Use orchestrator to create task graph.";
}

const context = TaskGet(myTask.id);
// ... work using task metadata only
```

No fallback, no gate checking. Pure task-based.
```

---

## Agent-by-Agent Restructuring Summary

| Agent | Skill Changes | Task Integration | Hooks | Complexity |
|-------|--------------|------------------|-------|------------|
| red | Remove sdlc:shared/ prefix | Add TaskGet/TaskUpdate, check TaskList | PRESERVE | MEDIUM |
| domain | Remove sdlc:shared/ prefix | Add TaskGet/TaskUpdate, phase branching | PRESERVE | MEDIUM |
| green | Remove sdlc:shared/ prefix | Add TaskGet/TaskUpdate, check TaskList | PRESERVE | MEDIUM |
| mutation | Remove sdlc:shared/ prefix | Prepare for background tasks | None | MEDIUM |
| code-reviewer | Add debugging-protocol | Task-based stages (major restructure) | None | HIGH |
| story | Add github-issues, orchestration | No task changes (creates issues, not tasks) | None | LOW |
| workflow-designer | Remove sdlc:shared/ prefix | No task changes (creates diagrams) | None | LOW |
| model-checker | Remove sdlc:shared/ prefix | No task changes (validates diagrams) | None | LOW |
| design-facilitator | Remove sdlc:shared/ prefix | Could coordinate via tasks (optional) | None | LOW |
| gwt | Add tdd-constraints | No task changes (generates scenarios) | None | LOW |
| architect | Remove sdlc:shared/ prefix | No task changes (updates docs) | None | LOW |
| ux | Add atomic-design | No task changes (creates designs) | None | LOW |
| discovery | Remove sdlc:shared/ prefix | No task changes (research) | None | LOW |
| adr | None (no skills loaded) | No task changes (creates ADRs) | None | LOW |
| file-updater | None (no skills loaded) | No task changes (updates files) | None | LOW |
| **orchestrator** | **NEW AGENT** | **Core task orchestration** | **None** | **HIGH** |

---

## Restructuring Verification Checklist

For each agent after restructuring, verify:

### Frontmatter
- [ ] skills: field updated (removed sdlc:shared/ prefix)
- [ ] name unchanged (backward compat)
- [ ] description unchanged (user-facing)
- [ ] model unchanged (unless orchestrator - use haiku)
- [ ] tools list updated if task-aware (added TaskGet, TaskUpdate)
- [ ] hooks PRESERVED exactly (if any)
- [ ] disallowedTools added if orchestrator (Write, Edit)

### Agent Prompt
- [ ] No duplicated skill content (skills handle protocols)
- [ ] Task awareness added if workflow-critical
- [ ] Backward compatibility fallback if needed
- [ ] Agent-specific instructions preserved
- [ ] Examples updated to show task usage
- [ ] Anti-patterns documented

### Testing
- [ ] Agent loads skills successfully
- [ ] Agent can access task tools (if added)
- [ ] Hooks still fire correctly
- [ ] Task-based workflow works
- [ ] Fallback to gates works (if backward compat)
- [ ] No broken skill references

---

## Migration Risk Mitigation

### High-Risk Changes

**code-reviewer restructuring:**
- Risk: Breaking three-stage review workflow
- Mitigation: Test thoroughly, maintain single-agent fallback option
- Rollback: Keep v3.12.8 code-reviewer.md as code-reviewer-legacy.md

**Orchestrator introduction:**
- Risk: Users don't understand new invocation pattern
- Mitigation: Commands invoke orchestrator transparently (no user change)
- Rollback: Commands can still work without orchestrator (call agents directly)

### Medium-Risk Changes

**red/green/domain task awareness:**
- Risk: Task metadata missing expected fields
- Mitigation: Fallback to gates, clear error messages
- Rollback: Can work without tasks (gates still functional)

**Skill reference updates:**
- Risk: Skills not found after prefix removal
- Mitigation: Test skill loading before deployment
- Rollback: Keep sdlc:shared/ protocols as symlinks

### Low-Risk Changes

**Agents that don't load skills:**
- Risk: Minimal (adr, file-updater, gwt mostly unchanged)
- Mitigation: Simple review, minimal testing needed
- Rollback: Trivial (agents barely changed)

---

## Implementation Order

### Phase 1: Foundation (Required First)
1. Extract skills (Phase 4 of main plan)
2. Test skill loading from top-level skills/
3. Verify Claude Code discovers skills

### Phase 2: Core Agents (TDD Cycle)
4. Update red agent
5. Update domain agent
6. Update green agent
7. Test one complete TDD cycle with tasks

### Phase 3: Orchestration
8. Create orchestrator agent
9. Update /sdlc:work command to use orchestrator
10. Test orchestrated workflow

### Phase 4: Specialized Agents
11. Restructure code-reviewer (task-based)
12. Update mutation agent (background prep)
13. Update event modeling cluster
14. Update research agents
15. Update utility agents

### Phase 5: Validation
16. Test all workflows end-to-end
17. Verify backward compatibility
18. Test migration from v3.12.8
19. User acceptance testing

---

## Next Steps

1. **Complete skill extraction** (see skill-extraction-plan.md)
2. **Test skill loading** with one agent (red recommended)
3. **Create orchestrator agent** (new file)
4. **Update core TDD agents** (red, green, domain)
5. **Test task-based TDD cycle** (verify workflow)
6. **Update remaining agents** systematically
7. **Comprehensive testing** before release

**Readiness:** HIGH - Clear restructuring patterns, low-risk approach, backward compatible.
