# Task Integration Patterns: Structural Workflow Enforcement

**Date:** 2026-02-04
**Version:** 1.0
**Purpose:** Document specific task creation patterns, metadata schemas, and integration approaches

---

## Overview

This document defines HOW tasks would be used in the sdlc plugin to replace prompt-based invocation gates with structural workflow enforcement.

**Key Insight:** Tasks provide mechanical guarantees (cannot start blocked task) vs gates provide prompt-based discipline (agent checks context declaration).

---

## When to Create Tasks

### TaskCreate Criteria (from Claude Code Documentation)

**Create tasks when:**
- Complex multi-step tasks (3+ distinct steps)
- Non-trivial complex tasks requiring planning
- Plan mode workflows
- User explicitly requests todo list
- User provides multiple tasks

**Do NOT create tasks when:**
- Single straightforward task
- Trivial tasks (less than 3 steps)
- Purely conversational/informational work

### Applied to sdlc Workflows

| Workflow | Create Tasks? | Rationale | Task Count |
|----------|--------------|-----------|------------|
| TDD Cycle (red→domain→green→domain) | **YES** | 4 steps, dependencies, resumable | 4 per cycle |
| Code review (3-stage) | **YES** | 3 stages, sequential, blocking | 3 |
| /sdlc:work (issue implementation) | **YES** | Discovery → Plan → Implement (cycles) → Verify | 5-15 |
| /sdlc:design (event modeling) | **YES** | Facilitate → Design → Validate → Document | 4 |
| /sdlc:pr creation | **YES** | Review → Mutation → PR → Link issues | 4 |
| Single test write | **NO** | Inline via sdlc:red (single step) | 0 |
| Single file update | **NO** | Inline via sdlc:file-updater (single step) | 0 |
| ADR creation | **NO** | Single document (inline via sdlc:adr) | 0 |
| Memory store | **NO** | Single operation (inline) | 0 |

---

## Task Metadata Schema

### Standard Metadata Fields

```typescript
interface SDLCTaskMetadata {
  // === Feature Tracking ===
  feature: string;              // "user-authentication", "invoice-generation"
  slice_number?: number;        // Vertical slice within feature (1-indexed)
  acceptance_criterion?: string; // Specific AC being implemented

  // === TDD Cycle Tracking ===
  cycle_number?: number;        // Which TDD cycle (1-indexed)
  phase: SDLCPhase;            // Current phase (see enum below)

  // === File Tracking ===
  test_file?: string;           // Absolute path to test file
  implementation_file?: string; // Absolute path to implementation
  types_file?: string;          // Absolute path to type definitions

  // === Domain Modeling ===
  domain_types_created?: string[];    // ["UserId", "AuthToken", "AuthError"]
  domain_concerns?: string[];         // Issues raised by domain agent
  domain_decisions?: string[];        // Rationale for type choices

  // === GitHub Integration ===
  parent_issue?: string;        // "#123" - parent issue number
  sub_issue?: string;           // "#456" - sub-issue number
  pr_number?: string;           // "#789" - associated PR

  // === Resumption Context ===
  memento_checkpoint?: string;  // Checkpoint ID in Memento for deep context
  last_test_output?: string;    // Abbreviated test output (last 500 chars)
  last_error?: string;          // Last error encountered
  last_command?: string;        // Last command run

  // === Code Review ===
  review_stage?: "spec" | "quality" | "domain";
  review_findings?: number;     // Count of issues found
  spec_issues?: ReviewIssue[];  // Array of issue objects
  quality_issues?: ReviewIssue[];
  domain_issues?: ReviewIssue[];

  // === git-spice Integration ===
  branch_name?: string;         // Current branch
  stack_position?: string;      // Position in stacked PRs
  base_branch?: string;         // Base branch for this work

  // === Worktree Support ===
  worktree_path?: string;       // Absolute path to worktree (if using)

  // === Agent Resumption (NEW - v4.0) ===
  agent_id?: string;            // agentId for resuming this agent's session
  needs_input?: boolean;        // Signals agent is paused awaiting user input
  question?: string;            // Question text for AskUserQuestion
  question_context?: object;    // Context needed to understand/answer question
  question_options?: string[];  // Option labels for AskUserQuestion
  user_answer?: string;         // User's answer (set by orchestrator after AskUserQuestion)
  answered_at?: string;         // ISO timestamp when user answered
}

type SDLCPhase =
  // TDD phases
  | "red"
  | "domain-after-red"
  | "green"
  | "domain-after-green"
  | "refactor"
  // Review phases
  | "review-spec"
  | "review-quality"
  | "review-domain"
  // Mutation testing
  | "mutation"
  // Event modeling
  | "event-model-design"
  | "event-model-validation"
  // Discovery/planning
  | "discovery"
  | "planning"
  // PR workflow
  | "pr-creation"
  | "pr-review";

interface ReviewIssue {
  type: "MISSING" | "INCOMPLETE" | "OVER-BUILT" | "DIVERGENT" | "CODE_SMELL" | "DOMAIN_VIOLATION";
  severity: "CRITICAL" | "IMPORTANT" | "MINOR";
  description: string;
  file?: string;
  line?: number;
}
```

### Metadata Usage Examples

#### Example 1: Red Phase Task
```javascript
{
  feature: "user-authentication",
  cycle_number: 1,
  phase: "red",
  test_file: "/home/user/project/tests/auth_test.rs",
  acceptance_criterion: "User can authenticate with email and password",
  parent_issue: "#123",
  last_command: "cargo test --test auth_test",
  memento_checkpoint: "auth-start-cycle-1"
}
```

#### Example 2: Domain Review Task
```javascript
{
  feature: "user-authentication",
  cycle_number: 1,
  phase: "domain-after-red",
  test_file: "/home/user/project/tests/auth_test.rs",
  types_file: "/home/user/project/src/auth/types.rs",
  domain_types_created: ["User", "Email", "Password", "AuthError"],
  domain_concerns: [],  // Empty = no concerns, approved
  domain_decisions: [
    "Email uses newtype pattern for validation",
    "AuthError enum covers all failure modes"
  ],
  memento_checkpoint: "auth-domain-types-cycle-1"
}
```

#### Example 3: Code Review Task
```javascript
{
  feature: "user-authentication",
  phase: "review-spec",
  review_stage: "spec",
  base_ref: "main",
  head_ref: "feature/123-auth",
  parent_issue: "#123",
  review_findings: 0,
  spec_issues: []  // No issues found
}
```

---

## Task Dependency Patterns

### Pattern 1: Single TDD Cycle

**Dependency graph:**
```
Red Task (pending)
    ↓ addBlockedBy
Domain-After-Red Task (pending, blocked)
    ↓ addBlockedBy
Green Task (pending, blocked)
    ↓ addBlockedBy
Domain-After-Green Task (pending, blocked)
    ↓ addBlockedBy (optional)
Refactor Task (pending, blocked)
```

**Code:**
```javascript
// 1. Red phase (no dependencies - can start immediately)
const redTask = await TaskCreate({
  subject: "Write failing test for user authentication",
  description: "Create test verifying User can be created with valid email and password. Should fail with 'function not found' error.",
  activeForm: "Writing failing test",
  metadata: {
    feature: "user-authentication",
    cycle_number: 1,
    phase: "red",
    test_file: "tests/auth_test.rs",
    acceptance_criterion: "User can authenticate with email and password",
    parent_issue: "#123"
  }
});

// 2. Domain review after red (blocked by red)
const domainAfterRedTask = await TaskCreate({
  subject: "Create domain types for authentication",
  description: "Review test from red phase. Create type definitions (User, Email, Password, AuthError) with unimplemented!() stubs. Check for domain violations.",
  activeForm: "Creating domain types",
  metadata: {
    feature: "user-authentication",
    cycle_number: 1,
    phase: "domain-after-red"
  }
});
await TaskUpdate({
  taskId: domainAfterRedTask.id,
  addBlockedBy: [redTask.id]
});

// 3. Green phase (blocked by domain)
const greenTask = await TaskCreate({
  subject: "Implement authentication to pass test",
  description: "Implement minimal code to make failing test pass. Use types from domain agent. No over-engineering.",
  activeForm: "Implementing authentication",
  metadata: {
    feature: "user-authentication",
    cycle_number: 1,
    phase: "green",
    implementation_file: "src/auth.rs"
  }
});
await TaskUpdate({
  taskId: greenTask.id,
  addBlockedBy: [domainAfterRedTask.id]
});

// 4. Domain review after green (blocked by green)
const domainAfterGreenTask = await TaskCreate({
  subject: "Review authentication implementation for domain integrity",
  description: "Review green phase implementation. Check for primitive obsession, parse-don't-validate violations, invalid states.",
  activeForm: "Reviewing implementation",
  metadata: {
    feature: "user-authentication",
    cycle_number: 1,
    phase: "domain-after-green"
  }
});
await TaskUpdate({
  taskId: domainAfterGreenTask.id,
  addBlockedBy: [greenTask.id]
});

// 5. Refactor (optional, blocked by final domain review)
const refactorTask = await TaskCreate({
  subject: "Refactor authentication implementation if needed",
  description: "After passing tests and domain review, refactor for clarity. Re-run tests after each change.",
  activeForm: "Refactoring authentication",
  metadata: {
    feature: "user-authentication",
    cycle_number: 1,
    phase: "refactor"
  }
});
await TaskUpdate({
  taskId: refactorTask.id,
  addBlockedBy: [domainAfterGreenTask.id]
});
```

**Visual representation:**
```
✓ Red: Write failing test
  ↓
◻ Domain: Create types (blocked, waiting for red)
  ↓
◻ Green: Implement (blocked, waiting for domain)
  ↓
◻ Domain: Review (blocked, waiting for green)
  ↓
◻ Refactor: Clean up (blocked, waiting for domain)
```

### Pattern 2: Multiple TDD Cycles (Multiple Acceptance Criteria)

**For feature with 3 acceptance criteria:**

```javascript
// Cycle 1 for AC1
const cycle1Tasks = createTDDCycle({
  feature: "user-authentication",
  cycle: 1,
  acceptanceCriterion: "User can register with email and password"
});

// Cycle 2 for AC2 (independent of cycle 1 - can run in parallel)
const cycle2Tasks = createTDDCycle({
  feature: "user-authentication",
  cycle: 2,
  acceptanceCriterion: "User can log in with email and password"
});

// Cycle 3 for AC3 (independent of cycles 1-2)
const cycle3Tasks = createTDDCycle({
  feature: "user-authentication",
  cycle: 3,
  acceptanceCriterion: "User can reset password via email"
});

// Cycles run in parallel (no dependencies between cycles)
// Each cycle has internal dependencies (red→domain→green→domain)
```

**Dependency graph:**
```
Cycle 1: Red → Domain → Green → Domain → Refactor
Cycle 2: Red → Domain → Green → Domain → Refactor  (parallel to Cycle 1)
Cycle 3: Red → Domain → Green → Domain → Refactor  (parallel to Cycles 1-2)
```

### Pattern 3: Three-Stage Code Review

**Sequential stages enforced by dependencies:**

```javascript
// Stage 1: Spec compliance (no dependencies)
const specTask = await TaskCreate({
  subject: "Code review: Spec compliance for user authentication",
  description: "Verify all acceptance criteria are implemented. No over-building or under-building.",
  activeForm: "Reviewing spec compliance",
  metadata: {
    feature: "user-authentication",
    phase: "review-spec",
    review_stage: "spec",
    base_ref: "main",
    head_ref: "feature/123-auth",
    parent_issue: "#123"
  }
});

// Stage 2: Code quality (blocked by spec)
const qualityTask = await TaskCreate({
  subject: "Code review: Quality assessment for user authentication",
  description: "Check for code smells, maintainability issues, test gaps.",
  activeForm: "Reviewing code quality",
  metadata: {
    feature: "user-authentication",
    phase: "review-quality",
    review_stage: "quality"
  }
});
await TaskUpdate({
  taskId: qualityTask.id,
  addBlockedBy: [specTask.id]
});

// Stage 3: Domain integrity (blocked by quality)
const domainReviewTask = await TaskCreate({
  subject: "Code review: Domain integrity for user authentication",
  description: "Check for domain violations, primitive obsession, invalid states representable.",
  activeForm: "Reviewing domain integrity",
  metadata: {
    feature: "user-authentication",
    phase: "review-domain",
    review_stage: "domain"
  }
});
await TaskUpdate({
  taskId: domainReviewTask.id,
  addBlockedBy: [qualityTask.id]
});
```

**Enforces:** Cannot skip stages. Quality review blocked until spec completes. Domain review blocked until quality completes.

### Pattern 4: PR Creation Workflow

**Multi-step PR creation with mutation testing:**

```javascript
// Step 1: Code review (uses three-stage pattern above)
const reviewTasks = createCodeReviewTasks({ feature, issue });

// Step 2: Mutation testing (blocked by review completion)
const mutationTask = await TaskCreate({
  subject: "Run mutation tests on user authentication",
  description: "Run mutation testing on all auth-related code and tests. Store results in task metadata.",
  activeForm: "Running mutation tests",
  metadata: {
    feature: "user-authentication",
    phase: "mutation",
    test_file: "tests/auth_test.rs",
    implementation_file: "src/auth.rs"
  }
});
await TaskUpdate({
  taskId: mutationTask.id,
  addBlockedBy: [reviewTasks.domainReview.id]  // Blocked by final review stage
});

// Step 3: Create PR (blocked by mutation)
const prTask = await TaskCreate({
  subject: "Create pull request for user authentication",
  description: "Create GitHub PR with description, link to issue, add to project board.",
  activeForm: "Creating pull request",
  metadata: {
    feature: "user-authentication",
    phase: "pr-creation",
    parent_issue: "#123",
    branch_name: "feature/123-auth"
  }
});
await TaskUpdate({
  taskId: prTask.id,
  addBlockedBy: [mutationTask.id]
});
```

**Benefits:** Mutation testing can run in background while user continues work. PR creation waits for all validations.

---

## Task Naming Conventions

### Subject Field (Imperative Form)

**Format:** `<Action> <Object> [for <Context>]`

**Examples:**
- "Write failing test for user authentication"
- "Create domain types for authentication"
- "Implement authentication to pass test"
- "Review authentication implementation for domain integrity"
- "Refactor authentication implementation"
- "Run mutation tests on authentication"
- "Create pull request for user authentication"

**Anti-patterns:**
- ❌ "Writing failing test" - Use activeForm for present continuous
- ❌ "Test writing" - Not imperative
- ❌ "TODO: Write test" - Remove "TODO:"
- ❌ "We need to write a test" - Be direct

### activeForm Field (Present Continuous)

**Format:** `<Action>ing <Object>`

**Examples:**
- "Writing failing test"
- "Creating domain types"
- "Implementing authentication"
- "Reviewing implementation"
- "Running mutation tests"
- "Creating pull request"

**Shown in:** Spinner when task status is "in_progress"

### Description Field (Detailed Context)

**Format:** Full sentences with requirements and expected outcomes

**Examples:**
```
"Create test verifying User can be created with valid email and password.
Test should fail with 'function not found' error showing the type doesn't exist yet."

"Review test from red phase. Create type definitions (User, Email, Password, AuthError)
with unimplemented!() stubs. Check for domain violations (primitive obsession,
invalid states representable)."

"Implement minimal code to make the failing test pass. Use types created by domain agent.
No over-engineering - just enough to make the test green."
```

**Include:**
- What needs to be done
- Expected outcome
- Any constraints or guidelines
- References to files/context

---

## Task Resumption Patterns

### Pattern 1: Resume from TaskList

**After session restart:**

```javascript
// Orchestrator or agent queries TaskList
const tasks = await TaskList();

// Find tasks for current feature
const authTasks = tasks.filter(t => t.metadata?.feature === "user-authentication");

// Check status
const pending = authTasks.filter(t => t.status === "pending" && t.blockedBy.length === 0);
const inProgress = authTasks.filter(t => t.status === "in_progress");
const completed = authTasks.filter(t => t.status === "completed");

// Report to user
console.log(`
User Authentication Progress:
- ${completed.length} tasks completed ✓
- ${inProgress.length} tasks in progress
- ${pending.length} tasks ready to start
- ${authTasks.filter(t => t.blockedBy.length > 0).length} tasks blocked ▲
`);

// Resume at first available task
if (inProgress.length > 0) {
  // Continue in-progress task
  const taskToResume = inProgress[0];
  const details = await TaskGet(taskToResume.id);
  // Resume work with context from details.metadata
} else if (pending.length > 0) {
  // Start next pending task
  const taskToStart = pending[0];
  const details = await TaskGet(taskToStart.id);
  // Begin work with context from details.metadata
}
```

### Pattern 2: Resume with Memento Integration

**Combine task metadata (workflow state) with Memento (semantic knowledge):**

```javascript
// Get task details
const task = await TaskGet(taskId);
const { feature, cycle_number, phase, memento_checkpoint } = task.metadata;

// Retrieve deep context from Memento
const memories = await memento_semantic_search({
  query: `${feature} cycle ${cycle_number} ${phase}`,
  limit: 5
});

// If checkpoint exists, open specific nodes
if (memento_checkpoint) {
  const checkpoint = await memento_open_nodes({
    node_ids: [memento_checkpoint]
  });
  // Get rich context: decisions, patterns, learnings
}

// Combine: Task tells WHAT to do, Memento tells WHY and HOW
const context = {
  workflowState: task.metadata,      // From tasks (where we are)
  domainKnowledge: memories,         // From Memento (what we know)
  checkpoint: checkpoint?.nodes      // From Memento (specific context)
};
```

**Benefits:**
- Tasks: Resumable workflow state (no Memento needed to resume)
- Memento: Enhanced context (why decisions were made, patterns discovered)
- Complementary: Tasks for mechanics, Memento for semantics

### Pattern 3: Resume Across Worktrees

**For parallel development (multiple slices in worktrees):**

```javascript
// Each worktree has its own task list
process.env.CLAUDE_CODE_TASK_LIST_ID = `auth-feature-worktree-1`;

const worktree1Tasks = await TaskList();

// Different worktree
process.env.CLAUDE_CODE_TASK_LIST_ID = `auth-feature-worktree-2`;

const worktree2Tasks = await TaskList();

// Tasks are isolated by worktree (parallel independent work)
```

**Metadata includes worktree path:**
```javascript
{
  feature: "user-authentication",
  slice_number: 1,
  worktree_path: "/home/user/project-worktrees/slice-1",
  branch_name: "feature/123-auth-slice-1"
}
```

---

## Agent Task Interaction Patterns

### Pattern 1: Orchestrator Creates, Agent Executes

**Orchestrator:**
```javascript
// Create task graph
const tasks = createTDDCycle({ feature, ac, cycle });

// Spawn agent for first task
Task("sdlc:red", {
  instruction: `Work on task: ${tasks.red.id}. Check TaskGet for details.`,
  taskId: tasks.red.id
});
```

**Agent (red):**
```javascript
// Retrieve task details
const task = await TaskGet(taskId);  // Provided by orchestrator
const { test_file, acceptance_criterion } = task.metadata;

// Do work
writeTest(test_file, acceptance_criterion);

// Update task
await TaskUpdate({
  taskId: task.id,
  status: "completed",
  metadata: {
    ...task.metadata,
    test_file: finalPath,
    last_test_output: testOutput.substring(0, 500)
  }
});

// Return to orchestrator
return "Red phase complete. Test fails as expected.";
```

### Pattern 2: Agent Self-Assignment

**Agent polls TaskList:**
```javascript
// Agent (red) running in background or foreground
while (true) {
  const tasks = await TaskList();

  // Find tasks assigned to me that are unblocked
  const myTasks = tasks.filter(t =>
    t.owner === "red" &&
    t.status === "pending" &&
    t.blockedBy.length === 0
  );

  if (myTasks.length === 0) {
    return; // No work available
  }

  // Claim first task
  const task = myTasks[0];
  await TaskUpdate({ taskId: task.id, status: "in_progress" });

  // Get details
  const details = await TaskGet(task.id);

  // Do work
  executeTask(details);

  // Mark complete
  await TaskUpdate({
    taskId: task.id,
    status: "completed",
    metadata: { /* updated context */ }
  });

  // Continue or exit
  // (could loop for multiple tasks or return)
}
```

**Benefits:**
- Reduced orchestrator overhead
- True parallel execution (multiple agents polling)
- Scales for worktree workflows

**Tradeoffs:**
- More complex agents
- Requires task scoping discipline
- Harder to debug

### Pattern 3: Task Metadata Communication

**Agents communicate via task metadata updates:**

```javascript
// Domain agent raises concern
await TaskUpdate({
  taskId: redTask.id,
  status: "in_progress",  // Not completed - needs revision
  metadata: {
    ...redTask.metadata,
    domain_concerns: ["Primitive obsession: email should be Email type, not String"]
  }
});

// Orchestrator sees concern, asks red to revise
Task("sdlc:red", {
  instruction: "Revise test addressing domain concern from task metadata"
});

// Red revises
await TaskUpdate({
  taskId: redTask.id,
  status: "completed",  // Now complete after addressing concern
  metadata: {
    ...redTask.metadata,
    domain_concerns_addressed: ["Using Email newtype in test signature"]
  }
});

// Orchestrator sees completion, re-invokes domain
Task("sdlc:domain", {
  instruction: "Re-review revised test"
});

// Domain approves, creates types
await TaskUpdate({
  taskId: domainAfterRedTask.id,
  status: "completed",
  metadata: {
    ...domainAfterRedTask.metadata,
    domain_types_created: ["Email", "User"],
    domain_concerns: []  // Empty = approved
  }
});
```

**Benefits:**
- Persistent communication record
- Asynchronous agent interaction
- Clear concern tracking

### Pattern 4: Agent Resumption for Questions (NEW - Critical for v4.0)

**Problem:** Background agents can't use AskUserQuestion (tool call fails). How do long-running agents ask clarifying questions?

**Solution:** Agent pauses, stores question in task metadata, main conversation asks user, resumes agent with answer.

**Full Pattern:**

**1. Background agent hits question:**
```javascript
// Inside mutation agent (running in background)
const task = await TaskGet(myTaskId);

// Found issue that needs user decision
await TaskUpdate({
  taskId: task.id,
  metadata: {
    ...task.metadata,
    agent_id: myAgentId,           // Store for resumption
    needs_input: true,             // Signal pause
    question: "Found 3 surviving mutants. Should I create individual tasks for each?",
    question_context: {
      surviving_mutants: [
        { file: "auth.rs", line: 42, mutation: "== changed to !=" },
        { file: "auth.rs", line: 58, mutation: "true changed to false" },
        { file: "types.rs", line: 15, mutation: "Some changed to None" }
      ],
      test_coverage: "98%",
      mutation_score: "97%"
    },
    question_options: ["Yes - create tasks", "No - just report", "Show mutant details first"]
  }
});

// Exit agent, saving state
return "Paused - awaiting user decision on surviving mutants";
// Agent exits, preserving full conversation history
```

**2. Orchestrator detects pause:**
```javascript
// In main conversation (orchestrator logic)
const task = await TaskGet(mutationTaskId);

if (task.metadata.needs_input) {
  console.log(`Agent paused with question: ${task.metadata.question}`);

  // Ask user
  const answer = await AskUserQuestion({
    questions: [{
      question: task.metadata.question,
      header: "Mutation Testing",
      options: task.metadata.question_options.map(opt => ({
        label: opt,
        description: "" // Could add context from question_context
      })),
      multiSelect: false
    }]
  });

  // Clear pause state
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
  const resumedAgent = await Task({
    subagent_type: "mutation",
    resume: task.metadata.agent_id,  // Resume previous session!
    prompt: `User answered: "${answer}". Continue from where you left off.`,
    run_in_background: true          // Continue in background
  });
}
```

**3. Resumed agent continues:**
```javascript
// Agent resumes with FULL previous context
// - Sees all previous tool calls and results
// - Knows about the 3 surviving mutants
// - Has user's answer
// - No need to re-analyze

const task = await TaskGet(myTaskId);
const userAnswer = task.metadata.user_answer;

if (userAnswer === "Yes - create tasks") {
  // Create individual tasks for each mutant
  for (const mutant of task.metadata.question_context.surviving_mutants) {
    await TaskCreate({
      subject: `Fix surviving mutant: ${mutant.file}:${mutant.line}`,
      description: `Mutation: ${mutant.mutation}`,
      activeForm: `Fixing mutant in ${mutant.file}`,
      metadata: {
        feature: task.metadata.feature,
        phase: "mutation-fix",
        mutant_details: mutant
      }
    });
  }

  await TaskUpdate({
    taskId: task.id,
    status: "completed",
    metadata: {
      ...task.metadata,
      mutation_tasks_created: 3
    }
  });

  return "Created 3 tasks for surviving mutants. Mutation phase complete.";

} else if (userAnswer === "No - just report") {
  // Just complete with report
  await TaskUpdate({
    taskId: task.id,
    status: "completed",
    metadata: {
      ...task.metadata,
      mutation_report: "97% score, 3 mutants survived (see question_context)"
    }
  });

  return "Mutation testing complete. 97% score (3 survivors documented).";
}

// Agent continues seamlessly, no wasted work
```

**Benefits:**
- ✅ Background agents can ask questions (indirectly)
- ✅ No wasted work - agent resumes with full context
- ✅ User sees clean question via AskUserQuestion
- ✅ Works for any agent (mutation, code-review, domain, etc.)
- ✅ Persistent state across interruptions

**When to use:**
- Long-running background agents (mutation, code-review)
- Decision points requiring user input (architectural choices, business rules)
- Error recovery (agent hits unexpected state, needs guidance)
- Progress checkpoints (show results, ask whether to continue)

**Task metadata schema requirements:**
```typescript
interface SDLCTaskMetadata {
  // ... existing fields ...

  // Agent Resumption
  agent_id?: string;              // agentId returned from Task() call - for resumption
  needs_input?: boolean;          // Signals agent is paused awaiting user input
  question?: string;              // Question text for AskUserQuestion
  question_context?: object;      // Context needed to understand/answer question
  question_options?: string[];    // Option labels for AskUserQuestion
  user_answer?: string;           // User's answer (set by orchestrator)
  answered_at?: string;           // ISO timestamp when answered
}
```

**Agents that benefit from resumption:**
- **mutation** - Pause for surviving mutant decisions
- **code-reviewer** - Pause for architectural clarifications
- **domain** - Pause for business rule questions
- **orchestrator** - Pause for workflow decisions (skip phase? run in parallel?)

**Implementation note:** This pattern should be documented in agent prompts and demonstrated in Phase 5 agent restructuring.

---

## Invocation Gate Migration

### Current State: Prompt-Based Gates

**Orchestrator provides:**
```
RED_CONTEXT: FIRST_TEST
ACCEPTANCE_CRITERIA:
- User can authenticate with email and password
```

**Agent validates:**
```markdown
Before proceeding, verify orchestrator provided required context.

If RED_CONTEXT is missing: RETURN "INVOCATION GATE FAILED"
```

**Problems:**
- Prompt-based (no mechanical enforcement)
- Non-persistent (doesn't survive restart)
- Manual discipline required
- Verbose context blocks

### Future State: Task Dependencies

**Orchestrator creates:**
```javascript
const redTask = TaskCreate({ ... });
const domainTask = TaskCreate({ ... });
TaskUpdate({ taskId: domainTask.id, addBlockedBy: [redTask.id] });
```

**System enforces:**
- Cannot start domainTask until redTask completes
- Structural impossibility vs prompt discipline

**Agent retrieves:**
```javascript
const task = TaskGet(taskId);
const { acceptance_criterion, test_file } = task.metadata;
// Context from task metadata, not prompt
```

**Benefits:**
- Mechanical enforcement
- Persistent state
- Less verbose
- Resumable

### Migration Timeline

#### Phase 1: Both Active (v4.0.0-4.0.x)

**Orchestrator:**
```javascript
// Create tasks
const tasks = createTDDCycle({ ... });

// Also provide gate context (redundant)
Task("sdlc:red", {
  instruction: `
    RED_CONTEXT: FIRST_TEST
    ACCEPTANCE_CRITERIA: ${ac}

    Also check TaskList for task: ${tasks.red.id}
  `
});
```

**Agent:**
```markdown
**Preferred: Check TaskList**

If task exists, use task metadata for context.

**Fallback: Check gate**

If no task, validate gate context.
```

**Benefits:**
- Backward compatible
- Both mechanisms work
- Gradual adoption

#### Phase 2: Tasks Primary (v4.1.0-4.9.x)

**Orchestrator:**
```javascript
// Create tasks
const tasks = createTDDCycle({ ... });

// Minimal gate context (defensive)
Task("sdlc:red", {
  instruction: `Work on task ${tasks.red.id}. Gate: RED_CONTEXT=FIRST_TEST`
});
```

**Agent:**
```markdown
**Check TaskList (required)**

Task must exist. If not, error.

**Defensive gate check**

If gate context provided, verify it matches task metadata.
```

**Benefits:**
- Tasks are source of truth
- Gates catch logic errors
- Still backward compatible

#### Phase 3: Tasks Only (v5.0.0+)

**Orchestrator:**
```javascript
// Create tasks
const tasks = createTDDCycle({ ... });

// No gate context
Task("sdlc:red", {
  instruction: `Work on task ${tasks.red.id}`
});
```

**Agent:**
```markdown
**TaskList required**

If no task, return error: "This agent requires task-based invocation."

No gate checking.
```

**Benefits:**
- Simplest
- Pure structural enforcement
- No prompt-based discipline

---

## Task Cleanup Strategies

### Strategy 1: Manual Cleanup (v4.0.0)

**User must explicitly clean up:**
```bash
# User decides when to archive/delete
TaskUpdate({ taskId: "old-task", status: "deleted" });
```

**Pros:** Never loses history, simple
**Cons:** TaskList becomes unwieldy

### Strategy 2: Automatic Archival (Future)

**Completed tasks auto-archive after N days:**
```javascript
const oldTasks = tasks.filter(t =>
  t.status === "completed" &&
  Date.now() - t.completedAt > 30 * 24 * 60 * 60 * 1000  // 30 days
);

oldTasks.forEach(t => TaskUpdate({ taskId: t.id, status: "deleted" }));
```

**Pros:** Keeps TaskList clean
**Cons:** Loses history, may surprise users

### Strategy 3: Feature-Based Cleanup (Recommended)

**When PR merges, archive all related tasks:**
```javascript
// On PR merge event
const prNumber = "#123";
const relatedTasks = tasks.filter(t => t.metadata.pr_number === prNumber);

relatedTasks.forEach(t => {
  TaskUpdate({
    taskId: t.id,
    status: "deleted",
    metadata: {
      ...t.metadata,
      archived_at: new Date().toISOString(),
      archived_reason: `PR ${prNumber} merged`
    }
  });
});
```

**Pros:** Natural workflow boundary, clear lifecycle
**Cons:** Requires metadata tracking

---

## Next Steps

1. **Implement task creation helpers** (createTDDCycle, createCodeReview, etc.)
2. **Define metadata validation** (ensure required fields present)
3. **Test task dependency enforcement** (verify blocked tasks cannot start)
4. **Implement task resumption** (query TaskList, use metadata)
5. **Test cleanup strategies** (manual, then feature-based)
6. **Document task patterns** in agent prompts
7. **Create examples** for users

**Readiness:** HIGH - Clear patterns, well-defined metadata, proven approach.
