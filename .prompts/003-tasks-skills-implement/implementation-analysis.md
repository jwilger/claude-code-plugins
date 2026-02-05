# sdlc Plugin Redesign: Implementation Analysis

**Date:** 2026-02-04
**Version:** 1.0
**Status:** Analysis Complete - Ready for Implementation Planning

---

## Executive Summary

This document provides a detailed phase-by-phase analysis of what WOULD need to be done to redesign the sdlc plugin to integrate Claude Code's tasks system and extract reusable skills. This is NOT a code implementation - it is a comprehensive planning document that describes the transformation approach.

**Key Finding:** The sdlc plugin is exceptionally well-positioned for this redesign. The current architecture already separates shared protocols (10 files in commands/shared/) from agent-specific logic (15 agents/), making skill extraction straightforward. The invocation gate pattern provides a clear migration path to task-based dependencies.

---

## Phase 1: Analysis and Extraction

### Objective
Inventory all agents and protocols to identify extractable components, task-suitable workflows, and integration points.

### What Would Be Done

#### 1.1 Agent Inventory Analysis

**Current State:** 15 specialized agents with clear separation of concerns

| Agent | Skills Loaded | Tools | Hooks | Primary Function | Extraction Notes |
|-------|--------------|-------|-------|------------------|------------------|
| red | user-input, memory, tdd-constraints | Read/Write/Edit/Bash/Grep/Glob, Memento | PreToolUse (Edit/Write), PostToolUse (Edit/Write), Stop | Write failing tests | Hooks enforce test-file-only constraint; skills are extractable |
| domain | user-input, memory, tdd-constraints | Read/Write/Edit/Bash/Grep/Glob, Memento | PreToolUse (Edit/Write), PostToolUse (Edit/Write), Stop | Create type definitions, review for domain violations | Hooks enforce type-definition-only; runs twice per cycle |
| green | user-input, memory, tdd-constraints | Read/Write/Edit/Bash/Grep/Glob, Memento | PreToolUse (Edit/Write), PostToolUse (Edit/Write), Stop | Minimal implementation to pass tests | Hooks enforce production-code-only |
| mutation | memory, user-input | Read/Bash/Grep/Glob, Memento | None | Run mutation tests, assess test quality | Good candidate for background tasks |
| code-reviewer | memory, user-input | Read/Bash/Grep/Glob, Memento | None | Three-stage review (spec, quality, domain) | Should be restructured as 3 dependent tasks |
| story | None listed | Read/Bash, Memento | None | Break epics into vertical slices, create sub-issues | Uses gh CLI extensively |
| architect | memory, user-input | Read/Bash/Grep/Glob, Memento | None | Maintain ARCHITECTURE.md, ADR references | Documentation-focused |
| ux | memory, user-input | Read/Bash/Grep/Glob, Memento | None | UX design, atomic design patterns | Could load atomic-design skill |
| discovery | memory, user-input | Read/Bash/Grep/Glob, Memento | None | Research and discovery tasks | Research-focused, minimal file changes |
| workflow-designer | memory, event-modeling | Read/Write/Edit/Bash, Memento | None | Create Event Modeling diagrams | Loads event-modeling skill |
| model-checker | event-modeling | Read/Bash/Grep, Memento | None | Validate Event Modeling diagrams | Loads event-modeling skill |
| design-facilitator | user-input, memory | Read/Bash, Memento | None | Coordinate workflow-designer and model-checker | Orchestrates event modeling workflow |
| gwt | None listed | Read/Write/Edit/Bash | None | Generate Given/When/Then test scenarios | Specialized test format generation |
| adr | None listed | Read/Write/Edit/Bash/Grep, Memento | None | Record Architecture Decision Records | ADR-specific format and workflow |
| file-updater | None listed | Read/Write/Edit/Bash/Grep/Glob | None | Update config, docs, scripts, misc files | General-purpose file updates |

**Key Findings:**
- **3 core TDD agents** (red, green, domain) all load the same 3 skills and use similar hooks
- **Hooks are concentrated** in TDD agents only (red, green, domain) - these enforce workflow discipline
- **Event modeling cluster** (workflow-designer, model-checker, design-facilitator) share event-modeling skill
- **Skills are already well-factored** - agents reference sdlc:shared/ protocols consistently
- **No orchestrator agent exists** - main conversation acts as orchestrator (uses orchestration.md skill)

#### 1.2 Shared Protocol Analysis

**Current State:** 10 shared protocols in commands/shared/, all marked user-invocable: false

| Protocol | Purpose | Complexity | External Dependencies | Extraction Viability |
|----------|---------|------------|----------------------|---------------------|
| orchestration.md | Agent delegation rules, workflow coordination | HIGH | References all other protocols | Extract LAST - references others |
| tdd-constraints.md | Red/green/domain phase boundaries | MEDIUM | None - pure TDD principles | Extract FIRST - most self-contained |
| memory-protocol.md | Memento MCP integration patterns | MEDIUM | Memento MCP server | Extract with MCP-specific caveats |
| user-input-protocol.md | Checkpoint/question format | LOW | None - interaction patterns | Extract EARLY - simple, clear |
| event-modeling.md | Event Modeling patterns, diagram syntax | MEDIUM | Mermaid for diagrams | Extract with diagram tooling notes |
| github-issues.md | gh CLI patterns, issue workflows | MEDIUM | gh CLI + extensions | Extract with gh CLI prerequisites |
| git-spice.md | Stacked PR workflows, branch management | MEDIUM | git-spice CLI | Extract with git-spice prerequisites |
| debugging-protocol.md | Systematic debugging approach | LOW | None - methodology only | Extract EARLY - standalone method |
| atomic-design.md | UI component hierarchy | LOW | None - design principles | Extract EARLY - standalone |
| skill-enforcement.md | Invocation discipline, 1% rule | MEDIUM | References orchestration | May DEPRECATE if tasks replace gates |

**Key Findings:**
- **All protocols are documentation-only** - no executable code, pure knowledge/patterns
- **No Claude Code-specific features** in protocols themselves (hooks are in agents, not protocols)
- **Clean dependency structure** - orchestration references others, but most are independent
- **Already designed for reuse** - all have user-invocable: false (meant as knowledge injection)
- **Extraction order matters** - simple standalone protocols first, complex interconnected ones last

#### 1.3 Task-Suitable Workflow Analysis

**Commands that would benefit from task orchestration:**

| Command | Current Workflow | Task Structure | Task Count | Benefits |
|---------|-----------------|----------------|------------|----------|
| /sdlc:work | Discovery → Plan → Implement → Verify | Discovery task → Planning task → Implementation tasks (red→domain→green cycles) → Verification task | 5-15 | Cross-session resumption, parallel slices in worktrees |
| /sdlc:review | Read changes → 3-stage review → Report | Stage 1 (spec) → Stage 2 (quality) → Stage 3 (domain) | 3 | Enforces stage completion, prevents skipping |
| /sdlc:design | Facilitate → Design workflows → Validate models → Document | Facilitation → Workflow design → Model validation → Documentation | 4 | Tracks Event Modeling progress, resumable |
| /sdlc:pr | Review code → Mutation test → Create PR → Link issues | Code review → Mutation testing (background) → PR creation → Metadata | 4 | Parallel mutation testing, clear state tracking |
| TDD Cycle | Red → Domain → Green → Domain → (Refactor) | Red task → Domain-after-red task → Green task → Domain-after-green task | 4 per cycle | Mechanical enforcement of workflow order |

**Key Finding:** Task dependencies can replace invocation gates for all major workflows. The TDD cycle is the perfect candidate - invocation gates currently validate "did red complete?" which task dependencies enforce structurally.

#### 1.4 External Integration Analysis

**GitHub Integration (gh CLI):**
- Used extensively in: story agent, work command, pr command, review command
- Commands: `gh issue create`, `gh issue list`, `gh pr create`, `gh pr view`, `gh project item-add`
- Extensions required: gh-issue-ext, gh-project-ext, gh-pr-review
- **Migration approach:** Skills document patterns, agents execute via Bash

**git-spice Integration:**
- Optional workflow enhancement (fallback to regular git)
- Detection pattern: Check for gs CLI and managed branch
- Critical operations: `gs repo sync`, `gs upstack onto`, `gs log short`
- **Migration approach:** Extract as standalone skill with decision tree

**Memento MCP Integration:**
- Memory persistence across sessions
- Tools used: semantic_search, create_entities, open_nodes, create_relations
- Used in: All agents except file-updater, gwt, adr
- **Background task limitation:** Background tasks can't use MCP
- **Migration approach:**
  - Tasks metadata stores workflow state (resumable without Memento)
  - Memento stores semantic knowledge (domain decisions, patterns learned)
  - Foreground tasks use Memento, background tasks use task metadata

---

## Phase 2: Skill Structure Design

### What Would Be Done

#### 2.1 Directory Structure Design

**Proposed top-level structure:**

```
claude-code-plugins/
├── .claude-plugin/
│   └── marketplace.json
├── sdlc/
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── agents/              # Claude Code-specific (hooks, tool restrictions)
│   ├── commands/            # User-facing commands
│   ├── output-styles/       # Marvin personality
│   └── docs/                # Plugin documentation
└── skills/                  # NEW: Portable skills for skills.sh
    ├── README.md
    ├── tdd-constraints/
    │   └── SKILL.md
    ├── orchestration-protocol/
    │   └── SKILL.md
    ├── memory-protocol/
    │   └── SKILL.md
    ├── user-input-protocol/
    │   └── SKILL.md
    ├── event-modeling/
    │   └── SKILL.md
    ├── github-issues/
    │   └── SKILL.md
    ├── git-spice/
    │   └── SKILL.md
    ├── debugging-protocol/
    │   └── SKILL.md
    ├── atomic-design/
    │   └── SKILL.md
    └── examples/
        └── tdd-cycle-example.md
```

**Rationale:**
- Top-level skills/ makes them discoverable as standalone package
- Each skill in its own directory for future expansion (could add examples/, tests/)
- README.md at skills/ level documents installation and usage
- examples/ directory provides usage templates

#### 2.2 SKILL.md Template

**Standard frontmatter structure:**

```yaml
---
name: skill-name-lowercase-hyphens
description: Brief one-line description (shows in skill discovery)
version: 1.0.0
author:
  name: John Wilger
  email: john@johnwilger.com
keywords: [tdd, domain-modeling, workflow]
metadata:
  internal: false
  compatibility: ["claude-code", "cursor", "windsurf"]
  prerequisites:
    - description: "Memento MCP server (optional)"
      required: false
    - description: "Understanding of domain modeling principles"
      required: false
---
```

**Body structure:**

```markdown
# Skill Name

## Purpose
What this skill teaches and when to use it.

## Core Principles
Fundamental concepts and patterns.

## Workflow/Patterns
Step-by-step guidance or decision trees.

## Examples
Concrete usage examples.

## Anti-Patterns
Common mistakes and how to avoid them.

## References
Links to related skills, external resources.
```

#### 2.3 Skill Naming Conventions

**Conventions:**
- Lowercase with hyphens: `tdd-constraints`, not `TDD_Constraints` or `tddConstraints`
- Descriptive but concise: `orchestration-protocol` not `agent-orchestration-and-coordination`
- Noun-based for knowledge: `debugging-protocol`, `memory-protocol`
- Action-based for workflows: (none in current set, but future: `create-vertical-slice`)
- Avoid Claude Code-specific terms: `tdd-constraints` not `sdlc-tdd-constraints`

#### 2.4 Installation Workflow Design

**Installation methods:**

1. **Full skill package:**
   ```bash
   npx skills add jwilger/claude-code-plugins --scope project
   # Installs all 10 skills to .claude/skills/
   ```

2. **Individual skill:**
   ```bash
   npx skills add jwilger/claude-code-plugins --skill "tdd-constraints"
   # Installs only tdd-constraints to .claude/skills/
   ```

3. **Global installation:**
   ```bash
   npx skills add jwilger/claude-code-plugins --scope global
   # Installs to ~/.claude/skills/ (available to all projects)
   ```

**Discovery mechanism:**
- Claude Code searches: .claude/skills/, ~/.claude/skills/, and paths in marketplace.json
- Skills referenced in agent frontmatter: `skills: [tdd-constraints]`
- Auto-discovery shows skill descriptions at session start

#### 2.5 Skill Dependency Mechanism

**Approach:** Document recommended skill combinations, don't enforce technically

**In skill README:**
```markdown
## Related Skills

This skill works best when combined with:
- `user-input-protocol` - For checkpoint format when pausing for user decisions
- `memory-protocol` - For storing TDD patterns in Memento

## Loading Example

```yaml
skills:
  - tdd-constraints
  - user-input-protocol
  - memory-protocol
```
```

**Rationale:** Skills.sh format doesn't have native dependency mechanism. Agents load multiple skills via frontmatter array. Documentation guides composition.

---

## Phase 3: Task Integration Patterns

### What Would Be Done

#### 3.1 When to Create Tasks vs Inline Execution

**Task Creation Criteria (from Claude Code tool documentation):**

Create tasks when:
- Complex multi-step tasks (3+ distinct steps)
- Non-trivial complex tasks requiring planning
- Plan mode workflows
- User explicitly requests todo list
- User provides multiple tasks

Do NOT create tasks when:
- Single straightforward task
- Trivial tasks (less than 3 steps)
- Purely conversational/informational work

**Applied to sdlc plugin:**

| Workflow | Task Creation? | Rationale |
|----------|---------------|-----------|
| TDD Cycle (red→domain→green→domain) | YES | 4 steps, dependencies, resumable |
| Code review (3-stage) | YES | 3 stages, sequential, blocking |
| Event modeling session | YES | Multiple steps, long-running, resumable |
| PR creation workflow | YES | Multiple phases, includes long-running mutation testing |
| Single test write | NO | Inline via sdlc:red agent (single step) |
| Single file update | NO | Inline via sdlc:file-updater (single step) |
| ADR creation | NO | Single document creation (inline via sdlc:adr) |

#### 3.2 Task Metadata Schema

**Standard metadata fields for sdlc workflows:**

```typescript
interface SDLCTaskMetadata {
  // Feature tracking
  feature: string;                    // "user-authentication", "invoice-generation"
  slice_number?: number;              // Vertical slice within feature
  acceptance_criterion?: string;      // Specific AC being implemented

  // TDD cycle tracking
  cycle_number?: number;              // Which TDD cycle (1-indexed)
  phase: "red" | "domain-after-red" | "green" | "domain-after-green" | "refactor" | "review" | "mutation";

  // File tracking
  test_file?: string;                 // Absolute path to test file
  implementation_file?: string;       // Absolute path to implementation file
  types_file?: string;                // Absolute path to type definitions

  // Domain modeling
  domain_types_created?: string[];    // ["UserId", "AuthToken", "AuthError"]
  domain_concerns?: string[];         // Issues raised by domain agent

  // GitHub integration
  parent_issue?: string;              // "#123" - parent issue number
  sub_issue?: string;                 // "#456" - sub-issue number
  pr_number?: string;                 // "#789" - associated PR

  // Resumption context
  memento_checkpoint?: string;        // Checkpoint ID in Memento for deep context
  last_test_output?: string;          // Abbreviated test output for quick reference
  last_error?: string;                // Last error encountered (for context)

  // Code review tracking
  review_stage?: "spec" | "quality" | "domain";
  review_findings?: number;           // Count of issues found

  // git-spice integration
  branch_name?: string;               // Current branch
  stack_position?: string;            // Position in stacked PRs

  // Worktree support
  worktree_path?: string;             // Path to worktree (if using worktrees)
}
```

**Usage examples:**

```javascript
// Red phase task
{
  feature: "user-authentication",
  cycle_number: 1,
  phase: "red",
  test_file: "/home/user/project/tests/auth_test.rs",
  acceptance_criterion: "User can authenticate with email and password",
  parent_issue: "#123"
}

// Domain review task
{
  feature: "user-authentication",
  cycle_number: 1,
  phase: "domain-after-red",
  test_file: "/home/user/project/tests/auth_test.rs",
  types_file: "/home/user/project/src/auth/types.rs",
  domain_types_created: ["User", "Email", "Password", "AuthError"]
}
```

#### 3.3 TDD Cycle Task Graph

**Dependency structure for one TDD cycle:**

```
Red Task (pending)
    ↓ (blocks)
Domain-After-Red Task (pending, blocked by Red)
    ↓ (blocks)
Green Task (pending, blocked by Domain-After-Red)
    ↓ (blocks)
Domain-After-Green Task (pending, blocked by Green)
    ↓ (optional - blocks)
Refactor Task (pending, blocked by Domain-After-Green)
```

**Task creation code pattern:**

```javascript
// Task 1: Red phase
const redTask = TaskCreate({
  subject: "Write failing test for user authentication",
  description: "Create test that verifies User can be created with valid email and password. Test should fail with 'function not found' error.",
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

// Task 2: Domain review (blocked by red)
const domainAfterRedTask = TaskCreate({
  subject: "Create domain types for authentication",
  description: "Review test from red phase. Create type definitions (User, Email, Password, AuthError) with unimplemented!() stubs. Check for domain violations.",
  activeForm: "Creating domain types",
  metadata: {
    feature: "user-authentication",
    cycle_number: 1,
    phase: "domain-after-red",
    test_file: "tests/auth_test.rs"
  }
});
TaskUpdate({
  taskId: domainAfterRedTask.id,
  addBlockedBy: [redTask.id]
});

// Task 3: Green phase (blocked by domain)
const greenTask = TaskCreate({
  subject: "Implement authentication to pass test",
  description: "Implement minimal code to make the failing test pass. Use types created by domain agent. No over-engineering.",
  activeForm: "Implementing authentication",
  metadata: {
    feature: "user-authentication",
    cycle_number: 1,
    phase: "green",
    implementation_file: "src/auth.rs"
  }
});
TaskUpdate({
  taskId: greenTask.id,
  addBlockedBy: [domainAfterRedTask.id]
});

// Task 4: Domain review of implementation (blocked by green)
const domainAfterGreenTask = TaskCreate({
  subject: "Review authentication implementation for domain integrity",
  description: "Review green phase implementation. Check for primitive obsession, parse-don't-validate violations, invalid states.",
  activeForm: "Reviewing implementation",
  metadata: {
    feature: "user-authentication",
    cycle_number: 1,
    phase: "domain-after-green"
  }
});
TaskUpdate({
  taskId: domainAfterGreenTask.id,
  addBlockedBy: [greenTask.id]
});
```

#### 3.4 Invocation Gate to Task Migration

**Current State: Invocation Gates (Prompt-Based)**

Red agent requires one of:
```
RED_CONTEXT: FIRST_TEST
ACCEPTANCE_CRITERIA: [...]

RED_CONTEXT: CONTINUING
PREVIOUS_CYCLE_COMPLETE: [...]

RED_CONTEXT: DRILL_DOWN
PARENT_TEST: [...]
```

Domain agent requires one of:
```
DOMAIN_CONTEXT: AFTER_RED
RED_PHASE_COMPLETE: [...]

DOMAIN_CONTEXT: AFTER_GREEN
GREEN_PHASE_COMPLETE: [...]

DOMAIN_CONTEXT: PR_REVIEW
PR_SCOPE: [...]
```

**Future State: Task Dependencies (Structural)**

```javascript
// Red task has no dependencies (can start immediately)
const redTask = TaskCreate({...});

// Domain task blocked by red (cannot start until red completes)
const domainTask = TaskCreate({...});
TaskUpdate({ taskId: domainTask.id, addBlockedBy: [redTask.id] });

// Green task blocked by domain (cannot start until domain completes)
const greenTask = TaskCreate({...});
TaskUpdate({ taskId: greenTask.id, addBlockedBy: [domainTask.id] });
```

**Migration Strategy (3 Phases):**

**Phase 1 - Redundant (Both Active):**
- Orchestrator creates tasks AND provides gate context
- Agents validate gates as before (backward compatible)
- Tasks provide redundant tracking
- Verification: Both mechanisms work independently

**Phase 2 - Tasks Primary (Gates Defensive):**
- Orchestrator creates tasks, provides minimal gate context
- Agents check TaskList for workflow state
- Gate validation becomes defensive check (catches logic errors)
- Tasks are source of truth for workflow order
- Verification: Tasks drive workflow, gates catch edge cases

**Phase 3 - Tasks Only (Gates Removed):**
- Orchestrator creates tasks only
- No gate context provided
- Agents query TaskList for context
- Mechanical enforcement via task dependencies
- Verification: Workflow works without gates

**Backward Compatibility Preservation:**
- Phases 1 and 2 maintain existing command interfaces
- User sees same /sdlc:work, /sdlc:review commands
- Task creation is internal implementation detail
- No breaking changes to user experience
- Phase 3 is optional (users who prefer gates can stay on Phase 2)

#### 3.5 Agent Self-Assignment Pattern

**Autonomous Agent Workflow:**

```javascript
// Agent (running as subagent or background task)
while (true) {
  // 1. Query TaskList for assignable work
  const tasks = TaskList();
  const myTasks = tasks.filter(t =>
    t.owner === "red" &&           // Assigned to me
    t.status === "pending" &&       // Not started
    t.blockedBy.length === 0        // No dependencies
  );

  if (myTasks.length === 0) {
    return; // No work available
  }

  // 2. Claim first available task
  const task = myTasks[0];
  TaskUpdate({ taskId: task.id, status: "in_progress" });

  // 3. Get full context
  const taskDetails = TaskGet(task.id);
  const { test_file, acceptance_criterion } = taskDetails.metadata;

  // 4. Execute work
  // ... write test, run tests, etc ...

  // 5. Mark complete
  TaskUpdate({
    taskId: task.id,
    status: "completed",
    metadata: { last_test_output: "..." }
  });

  // 6. Check for more work or exit
  // (could loop or return)
}
```

**Orchestrator Workflow:**

```javascript
// Orchestrator creates task graph
createTDDCycleTaskGraph(feature, acceptanceCriterion);

// Spawn red agent (it self-assigns from TaskList)
Task("sdlc:red", {
  instruction: "Check TaskList for your tasks and execute them"
});

// Monitor progress
while (/* tasks pending */) {
  const status = TaskList();
  // Check for completion, handle questions, etc.
}
```

**Tradeoffs:**
- **Pro:** Reduced orchestrator overhead (create graph, agents execute)
- **Pro:** Enables parallel execution (multiple agents working simultaneously)
- **Pro:** Scalable for worktree workflows
- **Con:** More complex agents (need task polling logic)
- **Con:** Harder to debug (less centralized control)
- **Con:** Requires clear task scoping

**Recommendation:** Hybrid approach for sdlc:
- Orchestrator spawns first agent explicitly (clear starting point)
- Subsequent agents can self-assign from TaskList
- Orchestrator monitors overall progress, intervenes if needed

#### 3.6 Background Task Patterns

**Good Candidates for Background Execution:**

| Task | Current Duration | Background Viable? | Considerations |
|------|------------------|-------------------|----------------|
| Mutation testing | 5-30 minutes | YES | Pre-approve file permissions, no MCP needed, store results in task metadata |
| Discovery research | Variable | MAYBE | If no user questions needed, can background; otherwise foreground |
| Code review Stage 1 | 1-5 minutes | NO | Too quick to benefit, may need MCP for memento |
| Code review Stage 2 | 1-5 minutes | NO | Too quick to benefit |
| Code review Stage 3 | 1-5 minutes | NO | Too quick to benefit |
| Event modeling validation | 1-10 minutes | MAYBE | Depends on complexity, may need user interaction |

**Background Task Pattern for Mutation Testing:**

```javascript
// Orchestrator creates mutation task
const mutationTask = TaskCreate({
  subject: "Run mutation tests on authentication feature",
  description: "Run mutation testing on src/auth.rs and tests/auth_test.rs. Store results in task metadata.",
  activeForm: "Running mutation tests",
  metadata: {
    feature: "user-authentication",
    phase: "mutation",
    test_file: "tests/auth_test.rs",
    implementation_file: "src/auth.rs"
  }
});

// Spawn mutation agent in background
// Pre-approve file read permissions, no MCP needed
Task("sdlc:mutation", {
  instruction: "Run mutation tests and store results in task metadata",
  background: true, // Runs concurrently
  permissions: ["read:tests/", "read:src/", "bash:cargo"] // Pre-approved
});

// Main conversation continues (PR creation, documentation, etc.)
// Agent completes in background, updates task metadata
// User sees notification when complete
```

**Limitations to manage:**
- No AskUserQuestion in background (task must be fully specified)
- No MCP access (use task metadata instead of Memento)
- Permission pre-approval required (specify file paths upfront)

---

## Phase 4: Skill Extraction Plan

### What Would Be Done

#### 4.1 Skill Extraction Order (Simple to Complex)

**Extraction sequence:**

1. **user-input-protocol** - Simplest, no dependencies
2. **debugging-protocol** - Standalone methodology
3. **atomic-design** - UI patterns, independent
4. **tdd-constraints** - Core to sdlc, self-contained
5. **git-spice** - Tool-specific patterns
6. **github-issues** - Tool-specific patterns
7. **memory-protocol** - MCP integration, some complexity
8. **event-modeling** - References multiple agents
9. **orchestration-protocol** - References other skills, most complex
10. **skill-enforcement** - May deprecate if tasks replace gates

#### 4.2 Example Skill Extraction: tdd-constraints

**Current location:** `sdlc/commands/shared/tdd-constraints.md`

**Current structure:**
```yaml
---
description: TDD phase boundaries and responsibilities
user-invocable: false
---

[Content documenting red/green/domain phases]
```

**Extracted SKILL.md:**
```yaml
---
name: tdd-constraints
description: TDD phase boundaries and responsibilities for red/green/domain workflow
version: 1.0.0
author:
  name: John Wilger
  email: john@johnwilger.com
keywords: [tdd, test-driven-development, domain-modeling, workflow]
metadata:
  internal: false
  compatibility: ["claude-code", "cursor", "windsurf", "cline"]
---

# TDD Constraints

This skill documents the phase boundaries for Test-Driven Development with domain modeling.

## Purpose

Enforce disciplined TDD workflow where:
- Red writes ONE failing test
- Domain reviews and creates types
- Green implements minimally
- Domain reviews implementation

## Phase Responsibilities

### Red Phase
- Write ONE failing test at a time
- Use ONE assertion per test
- Reference types that should exist (let compiler fail)
- Test code ONLY - no type definitions or implementations
- Run test and paste FULL output showing failure

[Rest of content from current tdd-constraints.md...]

## Integration Notes

### Claude Code Integration
In Claude Code, agents enforce these constraints via hooks:
- red agent: PreToolUse hooks block non-test file edits
- domain agent: PreToolUse hooks block non-type file edits
- green agent: PreToolUse hooks block test file edits

See the sdlc plugin for hook implementation examples.

### Other Agents
For agents without hook support, rely on:
- Agent prompt discipline
- Code review checks
- Peer review of agent outputs
```

**Changes made:**
- Added SKILL.md frontmatter (version, author, keywords, metadata)
- Renamed from "description" to "name" field
- Added "Integration Notes" section (Claude Code-specific vs portable)
- Removed Claude Code-specific implementation details from core content
- Added compatibility metadata for other agent frameworks
- Preserved all core principles and patterns

#### 4.3 Extraction Validation Checklist

**For each extracted skill, verify:**

- [ ] SKILL.md frontmatter is valid YAML
- [ ] name field is lowercase-with-hyphens
- [ ] description is concise (< 100 chars)
- [ ] version follows semver (1.0.0)
- [ ] No hardcoded references to sdlc plugin paths
- [ ] No broken internal links
- [ ] Claude Code-specific features clearly marked
- [ ] Portable principles separated from tool-specific implementations
- [ ] Examples use generic file paths (not /home/jwilger/specific-project)
- [ ] Prerequisites documented if any (gh CLI, git-spice, Memento MCP)
- [ ] Related skills mentioned in "See Also" section
- [ ] Keywords appropriate for skills.sh discovery

---

## Phase 5: Agent Restructuring Plan

### What Would Be Done

#### 5.1 Create New Orchestrator Agent

**New file:** `sdlc/agents/orchestrator.md`

**Characteristics:**
- Lightweight (minimal context)
- Loads orchestration skills only
- Uses TaskCreate/TaskUpdate/TaskList/Task tools
- Disallows Write/Edit (delegation only)
- Uses Haiku model (fast, cheap for coordination)

**Frontmatter structure:**
```yaml
---
name: orchestrator
description: Coordinate TDD workflow using tasks and subagents. DELEGATION ONLY - never writes code directly
model: haiku
skills:
  - orchestration-protocol
  - tdd-constraints
tools:
  - TaskCreate
  - TaskUpdate
  - TaskGet
  - TaskList
  - Task
  - Read
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
  - mcp__memento__semantic_search
  - mcp__memento__create_entities
disallowedTools:
  - Write
  - Edit
---

# TDD Workflow Orchestrator

You coordinate the TDD workflow. You NEVER write code directly - you create tasks and spawn agents.

## Your Responsibilities

1. Understand user's intent
2. Create task graph with proper dependencies
3. Spawn specialized agents (red, green, domain)
4. Monitor task progress via TaskList
5. Facilitate agent debates when conflicts arise
6. Report progress to user

[Rest of orchestrator instructions...]
```

**Key differences from current "main conversation as orchestrator":**
- Explicit agent definition (not implicit in main conversation)
- Tool restrictions enforced (disallowedTools)
- Haiku model for cost efficiency
- Task tools explicitly included

#### 5.2 Update Core TDD Agents

**red agent changes:**

Before:
```yaml
skills:
  - sdlc:shared/user-input-protocol
  - sdlc:shared/memory-protocol
  - sdlc:shared/tdd-constraints
```

After:
```yaml
skills:
  - user-input-protocol
  - memory-protocol
  - tdd-constraints
```

**Rationale:** Skills now loaded from top-level skills/ directory, not sdlc:shared/

**domain agent changes:**

Before (invocation gate):
```markdown
## MANDATORY INVOCATION CONFIRMATION (Gate Check)

**Before proceeding with ANY work, you MUST verify the orchestrator has provided the required context in the prompt:**

### Required Context Declaration

The orchestrator MUST declare ONE of these contexts:

**Option A - After Red Phase:**
```
DOMAIN_CONTEXT: AFTER_RED
RED_PHASE_COMPLETE:
- Test: <test name>
- Failure: <exact error message or compilation error>
```
```

After (task-aware):
```markdown
## Workflow Context (Task-Based)

**Before proceeding, check TaskList for your assigned task:**

```javascript
const tasks = TaskList();
const myTask = tasks.find(t => t.owner === "domain" && t.status === "pending" && t.blockedBy.length === 0);

if (!myTask) {
  return "No domain tasks available. Ensure red phase has completed and created a blocking task for domain review.";
}

const taskDetails = TaskGet(myTask.id);
const { phase, test_file, acceptance_criterion } = taskDetails.metadata;

if (phase === "domain-after-red") {
  // Review test, create types
} else if (phase === "domain-after-green") {
  // Review implementation
} else if (phase === "pr-review") {
  // Review for PR
}
```

**Fallback:** If no tasks exist, check for invocation gate context (backward compatibility).
```

**Rationale:** Agents become task-aware but maintain backward compatibility

#### 5.3 Restructure code-reviewer as Task-Based

**Current:** Single agent does all 3 stages sequentially

**After:** Orchestrator creates 3 tasks, agent completes each in sequence

**Task structure:**
```javascript
// Task 1: Spec compliance review
const specTask = TaskCreate({
  subject: "Code review: Spec compliance",
  description: "Verify all acceptance criteria are implemented correctly",
  activeForm: "Reviewing spec compliance",
  metadata: {
    feature: "user-authentication",
    phase: "review",
    review_stage: "spec",
    base_ref: "main",
    head_ref: "feature/123-auth"
  }
});

// Task 2: Code quality review (blocked by spec)
const qualityTask = TaskCreate({
  subject: "Code review: Quality assessment",
  description: "Check for code smells, maintainability issues, test gaps",
  activeForm: "Reviewing code quality",
  metadata: {
    feature: "user-authentication",
    phase: "review",
    review_stage: "quality"
  }
});
TaskUpdate({ taskId: qualityTask.id, addBlockedBy: [specTask.id] });

// Task 3: Domain review (blocked by quality)
const domainReviewTask = TaskCreate({
  subject: "Code review: Domain integrity",
  description: "Check for domain violations, primitive obsession, invalid states",
  activeForm: "Reviewing domain integrity",
  metadata: {
    feature: "user-authentication",
    phase: "review",
    review_stage: "domain"
  }
});
TaskUpdate({ taskId: domainReviewTask.id, addBlockedBy: [qualityTask.id] });
```

**Agent changes:**
```markdown
## Task-Based Review Process

**Check which stage you're assigned:**

```javascript
const myTask = TaskGet(taskId); // Provided by orchestrator
const { review_stage } = myTask.metadata;

switch (review_stage) {
  case "spec":
    // Stage 1: Spec compliance
    performSpecReview();
    break;
  case "quality":
    // Stage 2: Code quality
    performQualityReview();
    break;
  case "domain":
    // Stage 3: Domain integrity
    performDomainReview();
    break;
}
```

**Benefits:**
- Cannot skip stages (dependencies enforce order)
- Clear progress tracking (TaskList shows which stage)
- Resumable (if interrupted, pick up at current stage)
- Each stage completes independently

#### 5.4 Agent Restructuring Verification

**For each agent, verify:**

- [ ] skills: field updated from sdlc:shared/ to top-level skill names
- [ ] No duplicated content from extracted skills
- [ ] Agent-specific instructions preserved
- [ ] Hooks preserved (if any)
- [ ] Tools list unchanged (unless adding task tools)
- [ ] Task awareness added (if workflow-critical)
- [ ] Backward compatibility maintained (can still work without tasks)
- [ ] No broken skill references
- [ ] Agent description unchanged (user-facing)

---

## Phase 6: Marketplace Integration

### What Would Be Done

#### 6.1 Top-Level skills/ Directory Creation

**Create:**
- skills/README.md - Installation guide, skill descriptions, usage examples
- skills/[skill-name]/SKILL.md - 10 extracted skills
- skills/examples/ - Usage templates and examples

**skills/README.md structure:**
```markdown
# SDLC Skills

Portable skills for Test-Driven Development, domain modeling, and SDLC workflows.

## Available Skills

### Core TDD Workflow
- **tdd-constraints** - TDD phase boundaries (red/green/domain)
- **orchestration-protocol** - Agent delegation and workflow coordination

### Integration Patterns
- **memory-protocol** - Memento MCP integration for persistent memory
- **user-input-protocol** - Checkpoint and question format patterns
- **github-issues** - GitHub CLI patterns for issue management
- **git-spice** - Stacked PR workflow patterns

### Specialized Patterns
- **event-modeling** - Event Modeling diagram patterns
- **debugging-protocol** - Systematic debugging methodology
- **atomic-design** - UI component hierarchy patterns

## Installation

### Install All Skills
```bash
npx skills add jwilger/claude-code-plugins
```

### Install Specific Skill
```bash
npx skills add jwilger/claude-code-plugins --skill "tdd-constraints"
```

[More documentation...]
```

#### 6.2 npx skills Installation Testing

**Test cases:**

1. **Full package installation:**
   ```bash
   cd /tmp/test-project
   npx skills add jwilger/claude-code-plugins
   ls .claude/skills/
   # Expected: tdd-constraints/, orchestration-protocol/, etc.
   ```

2. **Single skill installation:**
   ```bash
   npx skills add jwilger/claude-code-plugins --skill "tdd-constraints"
   ls .claude/skills/
   # Expected: tdd-constraints/ only
   ```

3. **Global installation:**
   ```bash
   npx skills add jwilger/claude-code-plugins --scope global
   ls ~/.claude/skills/
   # Expected: All skills
   ```

4. **Claude Code discovery:**
   ```bash
   # Start Claude Code session
   # Skills should appear in discovery
   # Agents should be able to load skills
   ```

#### 6.3 skills.sh Marketplace Submission

**Submission checklist:**

- [ ] GitHub repository public and accessible
- [ ] skills/ directory at repository root
- [ ] Each SKILL.md has valid frontmatter
- [ ] README.md provides clear installation instructions
- [ ] No malicious code (security audit requirement)
- [ ] Keywords appropriate for discovery
- [ ] License specified (MIT or similar)
- [ ] Author information complete
- [ ] Version numbers follow semver

**Submission process (based on skills.sh documentation):**
1. Ensure repository meets format requirements
2. Submit repository URL to skills.sh
3. Await security audit
4. Skills appear in marketplace with install counts
5. Telemetry tracks usage (anonymous)

#### 6.4 Marketplace.json Updates

**Update .claude-plugin/marketplace.json:**

Before:
```json
{
  "name": "jwilger-claude-plugins",
  "plugins": [
    {
      "name": "sdlc",
      "path": "./sdlc/.claude-plugin/plugin.json",
      "version": "3.12.8"
    },
    {
      "name": "bootstrap",
      "path": "./bootstrap/.claude-plugin/plugin.json",
      "version": "1.0.0"
    }
  ]
}
```

After:
```json
{
  "name": "jwilger-claude-plugins",
  "plugins": [
    {
      "name": "sdlc",
      "path": "./sdlc/.claude-plugin/plugin.json",
      "version": "4.0.0"
    },
    {
      "name": "bootstrap",
      "path": "./bootstrap/.claude-plugin/plugin.json",
      "version": "1.0.0"
    }
  ],
  "skills": [
    {
      "path": "./skills/"
    }
  ]
}
```

**Note:** The skills path makes skills discoverable when plugin marketplace is installed.

---

## Phase 7: Documentation and Migration

### What Would Be Done

#### 7.1 Migration Guide Creation

**MIGRATION.md structure:**

```markdown
# Migrating from sdlc v3.12.x to v4.0.0

## Overview

Version 4.0.0 introduces task-based workflow orchestration and extracts reusable skills. This is a **significant architectural change** but maintains **backward compatibility** through command interfaces.

## Breaking Changes

### For Plugin Users
- **None** - All commands (/sdlc:work, /sdlc:review, etc.) work unchanged
- Task creation is internal implementation detail
- Skills are now top-level (but agents reference them correctly)

### For Plugin Customizers
- If you've forked agents: Update skills: field from sdlc:shared/ to top-level names
- If you've customized shared protocols: Extract as custom skills
- If you rely on invocation gates: Phase 2 still supports them (task-based is additive)

## New Features

### Task-Based Workflows
- TDD cycles now visible in TaskList
- Resume work across sessions (tasks persist)
- Parallel development in worktrees (independent task graphs)
- Clear progress tracking (✓ completed, ◻ pending, ▲ blocked)

### Portable Skills
- 10 skills extracted and available via npx skills
- Use in other agent frameworks (Cursor, Windsurf, etc.)
- Independent versioning from plugin
- Compose skills as needed

### Improved Code Review
- Three-stage review now enforced via tasks
- Cannot skip stages (dependencies block)
- Resumable if interrupted

## Migration Steps

### Step 1: Update Plugin

```bash
# Update your plugin marketplace
cd /path/to/claude-code-plugins
git pull origin main
```

### Step 2: Re-run Setup

```bash
# In your project
/sdlc:setup
```

This will:
- Detect version change (3.12.x → 4.0.0)
- Preserve your configuration choices
- Install skills to .claude/skills/

### Step 3: Verify Installation

```bash
ls .claude/skills/
# Expected: tdd-constraints, orchestration-protocol, etc.

grep "^sdlc_version:" .claude/sdlc.yaml
# Expected: sdlc_version: 4.0.0
```

### Step 4: Test Workflow

```bash
# Start a new feature
/sdlc:work

# Work through a TDD cycle
# Observe tasks in TaskList
# Verify agents still work as expected
```

## Customization Migration

### If You Forked Agents

Update skill references:

Before:
```yaml
skills:
  - sdlc:shared/tdd-constraints
  - sdlc:shared/memory-protocol
```

After:
```yaml
skills:
  - tdd-constraints
  - memory-protocol
```

### If You Customized Protocols

Extract as custom skill:

1. Create .claude/skills/my-custom-protocol/SKILL.md
2. Copy protocol content
3. Add SKILL.md frontmatter
4. Reference in agent: `skills: [my-custom-protocol]`

## Rollback

If you encounter issues, rollback to v3.12.8:

```bash
cd /path/to/claude-code-plugins
git checkout tags/v3.12.8
/sdlc:setup
```

## Getting Help

- Issues: https://github.com/jwilger/claude-code-plugins/issues
- Discussions: https://github.com/jwilger/claude-code-plugins/discussions
- Email: john@johnwilger.com
```

#### 7.2 CLAUDE.md Updates

**Add section:**

```markdown
## Architecture (v4.0.0+)

The sdlc plugin uses a three-layer architecture:

### Layer 1: Portable Skills (Teaching)
- **Location:** Top-level skills/ directory
- **Distribution:** Via npx skills add jwilger/claude-code-plugins
- **Purpose:** Document reusable patterns and protocols
- **Examples:** tdd-constraints, orchestration-protocol, event-modeling
- **Portability:** Work across Claude Code, Cursor, Windsurf, etc.

### Layer 2: Structural Tasks (Enforcement)
- **System:** Claude Code built-in task system
- **Tools:** TaskCreate, TaskUpdate, TaskGet, TaskList
- **Purpose:** Enforce workflow order via dependencies
- **Examples:** Red → Domain → Green → Domain cycle
- **Persistence:** Tasks survive session restarts

### Layer 3: Claude Code Hooks (Validation)
- **Location:** In agent frontmatter (agents/*.md)
- **Purpose:** Validate agent behavior and file constraints
- **Examples:** red agent can only edit test files, domain can only edit type definitions
- **Integration:** Hooks reference skill principles, enforce mechanically

## Version Management (v4.0.0+)

**Critical**: When modifying plugin, update versions in FOUR locations:
1. Plugin manifest: sdlc/.claude-plugin/plugin.json
2. Marketplace entry: .claude-plugin/marketplace.json
3. Setup command: sdlc/commands/setup.md (hardcoded version strings)
4. Skills: Individual skill version fields (if skill content changed)

Skills can be versioned independently of the plugin.
```

#### 7.3 CHANGELOG.md Creation

**CHANGELOG.md structure:**

```markdown
# Changelog

All notable changes to the sdlc plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.0] - 2026-02-XX

### Added
- **Task-based workflow orchestration** using Claude Code's built-in task system
  - TDD cycles (red→domain→green→domain) now represented as task graphs
  - Task dependencies enforce workflow order mechanically
  - Task metadata stores resumption context (feature, cycle, files, etc.)
  - Cross-session resumption via persistent tasks
- **10 portable skills** extracted from shared protocols
  - tdd-constraints - TDD phase boundaries
  - orchestration-protocol - Agent delegation patterns
  - memory-protocol - Memento MCP integration
  - user-input-protocol - Checkpoint/question format
  - event-modeling - Event Modeling patterns
  - github-issues - GitHub CLI workflows
  - git-spice - Stacked PR patterns
  - debugging-protocol - Systematic debugging
  - atomic-design - UI component hierarchy
  - (skill-enforcement - deprecated in favor of tasks)
- **New orchestrator agent** for task-based coordination
  - Lightweight (Haiku model)
  - Uses TaskCreate/TaskUpdate/TaskList
  - Disallows Write/Edit (delegation only)
- **Three-stage code review** now enforced via task dependencies
  - Stage 1: Spec compliance
  - Stage 2: Code quality
  - Stage 3: Domain integrity
  - Cannot skip stages
- **skills.sh marketplace integration**
  - Install via npx skills add jwilger/claude-code-plugins
  - Individual skill installation supported
  - Skills work across multiple agent frameworks

### Changed
- **Agent skill references** updated from sdlc:shared/ to top-level names
  - Old: skills: [sdlc:shared/tdd-constraints]
  - New: skills: [tdd-constraints]
- **Invocation gates** now optional (task dependencies provide structural enforcement)
  - Phase 1: Both active (backward compatible)
  - Phase 2: Tasks primary, gates defensive
  - Phase 3: Tasks only (gates can be removed)
- **Workflow state** now stored in task metadata (complements Memento)
  - Tasks: Workflow mechanics (where we are)
  - Memento: Semantic knowledge (what we learned)
- **Code reviewer** restructured as three sequential tasks

### Deprecated
- **skill-enforcement protocol** - Task dependencies replace invocation discipline
- **Invocation gate pattern** - Migrating to task dependencies (gates remain as defensive checks)

### Removed
- None (backward compatible release)

### Fixed
- None

### Migration
See MIGRATION.md for upgrade instructions from v3.12.x

## [3.12.8] - 2026-02-04

### Added
- Domain re-review rule for Red→Domain feedback loop
- git-spice recovery documentation

### Fixed
- Clarified two-step sub-issue creation workflow
- Reinforced business rules vs data validation distinction in GWT

[Previous versions...]
```

#### 7.4 Version Number Updates

**Files requiring version updates:**

1. **sdlc/.claude-plugin/plugin.json:**
   ```json
   {
     "version": "4.0.0"
   }
   ```

2. **.claude-plugin/marketplace.json:**
   ```json
   {
     "plugins": [
       {
         "name": "sdlc",
         "version": "4.0.0"
       }
     ]
   }
   ```

3. **sdlc/commands/setup.md:**
   ```markdown
   If the version in the config doesn't match the current plugin version (**4.0.0**), show a warning:
   ```

   Search for all instances of "3.12.8" and replace with "4.0.0"

4. **Individual skills (if content changed):**
   ```yaml
   ---
   name: tdd-constraints
   version: 1.0.0  # Independent of plugin version
   ---
   ```

---

## Risk Assessment

### High-Risk Areas

#### 1. Task System Scalability
**Risk:** TaskList becomes unwieldy with many tasks
**Likelihood:** Medium
**Impact:** High (unusable interface)
**Mitigation:**
- Test with 50+ tasks to verify performance
- Implement task cleanup/archival strategy
- Use metadata filtering to show relevant tasks only
- Consider task namespacing by feature

#### 2. Skill Discovery After Extraction
**Risk:** Agents can't find skills after moving from sdlc:shared/ to top-level
**Likelihood:** Low
**Impact:** Critical (agents break)
**Mitigation:**
- Test skill loading before migration
- Verify Claude Code search paths include .claude/skills/
- Add fallback skill references during transition
- Include skill installation in setup command

#### 3. Backward Compatibility Breaking
**Risk:** Existing users' workflows break after update
**Likelihood:** Medium
**Impact:** High (user frustration, rollbacks)
**Mitigation:**
- Maintain command interface unchanged
- Support invocation gates during migration (Phase 1-2)
- Test migration path with existing configurations
- Provide clear rollback instructions

#### 4. Background Task MCP Limitation
**Risk:** Background tasks can't use Memento MCP, lose context
**Likelihood:** High
**Impact:** Medium (reduced functionality)
**Mitigation:**
- Use task metadata for workflow state
- Run tasks requiring MCP in foreground
- Pre-load Memento data before backgrounding
- Document which tasks must run foreground

### Medium-Risk Areas

#### 5. skills.sh Marketplace Adoption
**Risk:** Skills not discovered or adopted by other frameworks
**Likelihood:** Medium
**Impact:** Low (plugin still works, less reach)
**Mitigation:**
- Clear documentation and examples
- Keyword optimization for discovery
- Community outreach (blog posts, demos)
- Monitor telemetry and adjust

#### 6. Agent Self-Assignment Complexity
**Risk:** Autonomous agents fail to coordinate correctly
**Likelihood:** Medium
**Impact:** Medium (workflow breaks)
**Mitigation:**
- Start with orchestrator-driven pattern (proven)
- Introduce self-assignment incrementally
- Extensive testing of task polling logic
- Fallback to explicit orchestrator control

#### 7. Migration Guide Completeness
**Risk:** Users don't know how to handle customizations
**Likelihood:** Medium
**Impact:** Medium (support burden)
**Mitigation:**
- Document all customization scenarios
- Provide examples of custom skill extraction
- Create migration testing checklist
- Offer email support for complex cases

### Low-Risk Areas

#### 8. Skill Versioning Confusion
**Risk:** Users confused by skills versioned independently from plugin
**Likelihood:** Low
**Impact:** Low (documentation clarifies)
**Mitigation:**
- Clear version documentation
- CHANGELOG tracks both plugin and skill versions
- skills/README.md explains versioning

#### 9. Hook Preservation During Restructuring
**Risk:** Hooks break when agents updated to reference new skills
**Likelihood:** Low
**Impact:** High if occurs (workflow enforcement broken)
**Mitigation:**
- Test each agent after skill reference update
- Verify hooks still execute correctly
- Document hook dependencies on skills

### Overall Risk Profile

**Low Risk** - The redesign is well-planned and maintains backward compatibility. The current architecture is already well-factored for extraction. Phased migration approach allows incremental adoption and rollback.

**Key Success Factors:**
- Maintain command interface unchanged
- Support both gates and tasks during transition
- Comprehensive testing of skill loading
- Clear migration documentation
- User communication about benefits

---

## File-by-File Change Analysis

### Files to Create

| File | Purpose | Size | Complexity |
|------|---------|------|------------|
| skills/README.md | Installation and usage guide | Large | Low |
| skills/tdd-constraints/SKILL.md | Extracted TDD phase rules | Medium | Low |
| skills/orchestration-protocol/SKILL.md | Extracted delegation patterns | Large | Medium |
| skills/memory-protocol/SKILL.md | Extracted Memento patterns | Medium | Low |
| skills/user-input-protocol/SKILL.md | Extracted checkpoint format | Small | Low |
| skills/event-modeling/SKILL.md | Extracted Event Modeling patterns | Medium | Low |
| skills/github-issues/SKILL.md | Extracted gh CLI patterns | Medium | Low |
| skills/git-spice/SKILL.md | Extracted stacked PR patterns | Medium | Low |
| skills/debugging-protocol/SKILL.md | Extracted debugging method | Small | Low |
| skills/atomic-design/SKILL.md | Extracted UI patterns | Small | Low |
| skills/examples/ | Usage examples and templates | Medium | Low |
| sdlc/agents/orchestrator.md | New task-based orchestrator | Large | High |
| MIGRATION.md | User migration guide | Large | Medium |
| CHANGELOG.md | Version history | Medium | Low |
| docs/task-workflows.md | Task pattern documentation | Medium | Medium |
| skills/USAGE.md | Skill usage guide | Medium | Low |
| docs/TROUBLESHOOTING.md | Common issues and solutions | Medium | Low |

### Files to Modify

| File | Changes | Complexity | Breaking? |
|------|---------|------------|-----------|
| sdlc/agents/red.md | Update skills: references, add task awareness | Low | No |
| sdlc/agents/domain.md | Update skills: references, add task awareness | Medium | No |
| sdlc/agents/green.md | Update skills: references, add task awareness | Low | No |
| sdlc/agents/mutation.md | Update for background task execution | Medium | No |
| sdlc/agents/code-reviewer.md | Restructure as task-based | High | No |
| sdlc/agents/story.md | Update skills: references | Low | No |
| sdlc/agents/workflow-designer.md | Update skills: references | Low | No |
| sdlc/agents/model-checker.md | Update skills: references | Low | No |
| sdlc/agents/design-facilitator.md | Update skills: references | Low | No |
| sdlc/agents/gwt.md | Update skills: references (if any) | Low | No |
| sdlc/agents/architect.md | Update skills: references | Low | No |
| sdlc/agents/ux.md | Update skills: references, add atomic-design | Low | No |
| sdlc/agents/discovery.md | Update skills: references | Low | No |
| sdlc/agents/adr.md | Update skills: references (if any) | Low | No |
| sdlc/agents/file-updater.md | Update skills: references (if any) | Low | No |
| sdlc/.claude-plugin/plugin.json | Version bump to 4.0.0 | Low | No |
| .claude-plugin/marketplace.json | Version bump, add skills path | Low | No |
| sdlc/commands/setup.md | Version update, skill installation | Medium | No |
| CLAUDE.md | Architecture documentation update | Medium | No |

### Files to Deprecate (Not Delete)

| File | Reason | Timeline |
|------|--------|----------|
| sdlc/commands/shared/orchestration.md | Extracted to skill | v5.0.0 (keep for backward compat in v4.x) |
| sdlc/commands/shared/tdd-constraints.md | Extracted to skill | v5.0.0 |
| sdlc/commands/shared/memory-protocol.md | Extracted to skill | v5.0.0 |
| sdlc/commands/shared/user-input-protocol.md | Extracted to skill | v5.0.0 |
| sdlc/commands/shared/event-modeling.md | Extracted to skill | v5.0.0 |
| sdlc/commands/shared/github-issues.md | Extracted to skill | v5.0.0 |
| sdlc/commands/shared/git-spice.md | Extracted to skill | v5.0.0 |
| sdlc/commands/shared/debugging-protocol.md | Extracted to skill | v5.0.0 |
| sdlc/commands/shared/atomic-design.md | Extracted to skill | v5.0.0 |
| sdlc/commands/shared/skill-enforcement.md | Replaced by task system | v5.0.0 |

**Note:** Keep shared protocols in v4.0.0 for backward compatibility. Remove in v5.0.0 after users have migrated.

---

## ✅ Architectural Decisions Finalized

**Date:** 2026-02-04
**Status:** All 6 open questions resolved

See `.prompts/003-tasks-skills-implement/DECISIONS.md` for complete decision log with rationale.

### Decision Summary

| # | Question | Decision | Key Impact |
|---|----------|----------|------------|
| 1 | **Skill Distribution** | Same repository | Skills in `claude-code-plugins/skills/` |
| 2 | **Invocation Gates** | Aggressive removal | No gates in v4.0.0 - tasks only |
| 3 | **Orchestrator** | Main conversation + tasks | Task-based orchestration, not dedicated agent |
| 4 | **Background Tasks** | Background by default + resumption | Long-running agents run in background, can pause/resume |
| 5 | **Skill Naming** | Generic names | `tdd-constraints` not `jwilger-tdd-constraints` |
| 6 | **Task Cleanup** | Rely on Claude Code | No custom cleanup - users ask Claude naturally |

### Key Discovery: Agent Resumption Pattern

**Problem:** Background agents can't use AskUserQuestion (tool fails).

**Solution:** Agent pauses → stores question in task metadata → main conversation asks user → resumes agent with answer.

**Implementation:**
```javascript
// 1. Background agent pauses
TaskUpdate({ metadata: {
  agent_id: myAgentId,
  needs_input: true,
  question: "...",
  question_context: {...}
}});

// 2. Main conversation asks
AskUserQuestion({...});

// 3. Resume with answer
Task({
  resume: agentId,
  prompt: "User answered: ...",
  run_in_background: true
});
```

**Critical for v4.0:** Enables background mutation, code-review, domain agents to ask questions without blocking workflow.

### Impact on Implementation

**Removed from scope:**
- ❌ Invocation gate coexistence logic (Decision 2)
- ❌ Dedicated orchestrator agent (Decision 3 - not possible)
- ❌ Gate migration phases (Decision 2)
- ❌ Custom task cleanup commands (Decision 6)

**Added to scope:**
- ✅ Agent resumption pattern documentation
- ✅ Task metadata schema for resumption (7 new fields)
- ✅ Background execution by default for long-running agents
- ✅ Generic skill naming throughout

**Timeline impact:**
- **Original:** 21-31 days
- **Revised:** 18-26 days (3.5-5 weeks)
- **Net change:** -3 days faster

### Phase-Specific Changes

**Phase 2 (Skill Structure):** Generic naming simplifies manifest format

**Phase 3 (Task Integration):** +1 day for agent resumption pattern documentation

**Phase 4 (Skill Extraction):** No change

**Phase 5 (Agent Restructuring):** -2 days (no orchestrator agent, no gate removal, add background+resumption)

**Phase 6 (Marketplace):** No change

**Phase 7 (Documentation):** -1 day (no gate migration guide)

---

## Next Steps for Implementation

### ✅ Decisions Complete - Ready to Proceed

All architectural decisions finalized (2026-02-04). Implementation can begin immediately.

### Immediate (Before Code Changes)

1. ~~**User decision on open questions**~~ ✅ **COMPLETE** - All 6 decisions finalized
   - See DECISIONS.md for complete log

2. **Create GitHub issues for each phase** (Optional) - Track implementation work:
   - Phase 1: Analysis and extraction (this document)
   - Phase 2: Skill structure design
   - Phase 3: Task integration patterns
   - Phase 4: Skill extraction
   - Phase 5: Agent restructuring
   - Phase 6: Marketplace integration
   - Phase 7: Documentation and migration

3. **Set up testing environment** - Prepare for validation:
   - Test project with existing sdlc v3.12.8
   - Fork for v4.0.0 testing
   - Document test scenarios

### Phase 1 Implementation (Analysis - CURRENT)

- [x] Read research and plan documents
- [x] Analyze current plugin structure
- [x] Inventory agents and protocols
- [x] Identify task-suitable workflows
- [x] Create implementation analysis document (this file)

### Phase 2 Implementation (Skill Structure)

- [ ] Create skills/ directory structure
- [ ] Design SKILL.md template
- [ ] Create skills/README.md
- [ ] Design metadata schema
- [ ] Test skill installation workflow

### Phase 3 Implementation (Task Patterns)

- [ ] Define task metadata schema
- [ ] Create task graph examples
- [ ] Design gate-to-task migration approach
- [ ] Document agent self-assignment pattern
- [ ] Identify background task candidates

### Phase 4 Implementation (Skill Extraction)

- [ ] Extract user-input-protocol (simplest)
- [ ] Extract debugging-protocol
- [ ] Extract atomic-design
- [ ] Extract tdd-constraints (core)
- [ ] Extract git-spice
- [ ] Extract github-issues
- [ ] Extract memory-protocol
- [ ] Extract event-modeling
- [ ] Extract orchestration-protocol (most complex)
- [ ] Deprecate skill-enforcement (or extract if keeping)

### Phase 5 Implementation (Agent Restructuring)

- [ ] Create new orchestrator agent
- [ ] Update red agent
- [ ] Update domain agent
- [ ] Update green agent
- [ ] Restructure code-reviewer as task-based
- [ ] Update mutation agent for background
- [ ] Update remaining agents (story, workflow-designer, etc.)
- [ ] Verify all agent skill references

### Phase 6 Implementation (Marketplace)

- [ ] Create top-level skills/ with all extracted skills
- [ ] Test npx skills installation
- [ ] Update marketplace.json
- [ ] Submit to skills.sh
- [ ] Verify Claude Code discovery

### Phase 7 Implementation (Documentation)

- [ ] Create MIGRATION.md
- [ ] Update CLAUDE.md
- [ ] Create CHANGELOG.md
- [ ] Update setup.md to v4.0.0
- [ ] Create docs/task-workflows.md
- [ ] Create skills/USAGE.md
- [ ] Create docs/TROUBLESHOOTING.md
- [ ] Update all version numbers

### Validation and Release

- [ ] Test migration from v3.12.8 to v4.0.0
- [ ] Verify backward compatibility
- [ ] Test task-based workflows
- [ ] Verify skill loading across agents
- [ ] User acceptance testing
- [ ] Create GitHub release
- [ ] Announce to users

---

## Implementation Readiness Assessment

### Readiness: HIGH

**Strengths:**
- Clear architectural separation already exists (shared protocols vs agents)
- Skills extraction is straightforward (protocols are documentation-only)
- Task system is well-understood and documented
- Migration path is incremental (backward compatible)
- Risk assessment identifies mitigations

**Gaps to Address:**
- User decisions on open questions needed
- Testing strategy needs formalization
- Task cleanup/archival mechanism undefined
- Background task patterns need validation

**Confidence Level:** 85%

**Ready to proceed with:** Phases 2-4 (skill extraction and structure design)

**Requires additional planning:** Phases 5-6 (agent restructuring specifics, marketplace submission timing)

**Blockers:** None - can proceed with implementation planning and skill extraction

---

**Document Status:** Complete and ready for skill extraction planning.
