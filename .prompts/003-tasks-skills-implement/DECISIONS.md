# Implementation Decisions Log

**Date:** 2026-02-04
**Status:** ✅ All 6 architectural decisions finalized

---

## Decision Summary

All open questions from the implementation analysis have been resolved. These decisions shape the v4.0.0 architecture and implementation approach.

---

## Decision 1: Skill Distribution Strategy

**Question:** Should extracted skills live in the same repository or a separate repository?

**Decision:** ✅ **Same Repository (Option A)**

**Rationale:**
- Simpler maintenance (single repository for plugin + skills)
- User is sole maintainer - multi-repo overhead not justified
- Skills are young - no evidence they need independent versioning yet
- Can split to separate repo in v4.1+ if skills become popular outside sdlc
- Most marketplace plugins use single-repo structure with /skills subdirectory

**Implementation:**
```
jwilger/claude-code-plugins/
├── skills/
│   ├── tdd-constraints/
│   ├── user-input-protocol/
│   └── ... (8 more skills)
├── sdlc/
│   ├── agents/
│   └── commands/
└── .claude-plugin/marketplace.json
```

**Installation:**
```bash
npx skills add jwilger/claude-code-plugins
```

---

## Decision 2: Invocation Gate Deprecation Timeline

**Question:** How fast should we migrate from prompt-based gates to task dependencies?

**Decision:** ✅ **Aggressive Removal (Option A)**

**Rationale:**
- User is sole user - no backward compatibility concerns
- Eliminates code complexity (no dual-mode maintenance)
- Clean architecture from day one
- Tasks provide mechanical enforcement (no gates needed)
- Can always add gates back if tasks prove insufficient (unlikely)

**Implementation:**
- v4.0.0: Tasks only, no invocation gates
- Remove all gate validation code from agents
- Orchestrator uses TaskCreate/TaskUpdate for workflow structure
- Task dependencies (blockedBy) provide mechanical phase ordering

**What gets removed:**
```yaml
# Old gate validation (REMOVED)
RED_CONTEXT: FIRST_TEST
ACCEPTANCE_CRITERIA: ...

# Agents no longer validate gates
# "If RED_CONTEXT is missing: RETURN INVOCATION GATE FAILED"
```

**What replaces it:**
```javascript
// Task dependencies enforce ordering
TaskCreate({ subject: "Red: Write test" });
TaskCreate({ subject: "Domain: Review types", blockedBy: [redTask] });
TaskCreate({ subject: "Green: Implement", blockedBy: [domainTask] });
```

---

## Decision 3: Orchestrator Agent vs Main Conversation

**Question:** Should orchestration happen in a dedicated subagent or main conversation?

**Decision:** ✅ **Task-Based Orchestration in Main Conversation**

**Clarification:** Initial plan assumed a dedicated orchestrator subagent could spawn other subagents. **Testing revealed this is not possible** - only the main conversation has access to the Task tool for spawning subagents.

**Revised Architecture:**
- Orchestration logic lives in `/sdlc:work` and `/sdlc:design` commands
- Logic runs IN MAIN CONVERSATION
- Uses TaskCreate/TaskUpdate to structure workflow
- Uses Task tool to spawn red/domain/green/mutation subagents
- Subagents can modify task graph (create/update tasks) but cannot spawn agents

**Pattern:**
```javascript
// Command logic in main conversation
/sdlc:work "add authentication"
↓
// Create task graph
const redTask = TaskCreate({ subject: "Red: Write test", ... });
const domainTask = TaskCreate({ subject: "Domain: Types", blockedBy: [redTask.id], ... });
const greenTask = TaskCreate({ subject: "Green: Implement", blockedBy: [domainTask.id], ... });

// Spawn red agent
Task({ subagent_type: "red", prompt: `Work on task ${redTask.id}` });
// Red completes, updates task metadata, returns

// Orchestrator sees red completion, spawns domain
Task({ subagent_type: "domain", prompt: `Work on task ${domainTask.id}` });
// Domain may create additional tasks for rework, returns

// Continue workflow...
```

**Key Insight:** Subagents control workflow by creating/updating tasks, orchestrator (main conversation) executes workflow by spawning agents.

---

## Decision 4: Background Task Default + Agent Resumption Pattern

**Question:** Should mutation testing (and other long-running agents) default to background execution?

**Decision:** ✅ **Background by Default + Agent Resumption (Option A Enhanced)**

**Key Discovery:** Testing revealed that:
1. ✅ Subagents HAVE access to TaskCreate, TaskUpdate, TaskGet, TaskList
2. ❌ Subagents DON'T have access to Task tool (can't spawn other agents)
3. ✅ Background agents CAN access MCP tools if explicitly listed in agent's allowedTools
4. ✅ Mutation agent already has MCP tools configured: `mcp__memento__semantic_search, mcp__memento__create_entities`
5. ✅ Task tool has `resume` parameter for continuing previous agent sessions

**Rationale:**
- Background execution frees user to continue working
- Mutation testing is autonomous (doesn't need interaction)
- MCP access works (explicitly configured in mutation agent)
- Long-running tasks (10-30 minutes typical) benefit most from background
- Demonstrates task system power
- Agent resumption pattern enables background agents to ask questions indirectly

**Implementation:**

**Background execution:**
```javascript
// Spawn mutation agent in background
const result = Task({
  subagent_type: "mutation",
  prompt: "Run mutation tests for authentication module",
  run_in_background: true
});
// Returns immediately with: { agentId: "abc123", taskId: "def456", ... }

// User continues working while mutations run
// Notification when complete: "Mutation testing complete - 100% score"
```

**Agent resumption pattern (NEW - Critical for v4.0):**
```javascript
// 1. Background agent hits issue, pauses
// Inside mutation agent:
await TaskUpdate({
  taskId: myTaskId,
  metadata: {
    agent_id: myAgentId,           // For resuming
    needs_input: true,              // Signal pause
    question: "Found 3 surviving mutants. Create individual tasks for each?",
    question_context: {
      surviving_mutants: [
        { file: "auth.rs", line: 42, mutation: "== to !=" },
        { file: "auth.rs", line: 58, mutation: "true to false" },
        { file: "types.rs", line: 15, mutation: "Some to None" }
      ]
    }
  }
});
return "Paused - need user input on surviving mutants";

// 2. Main conversation sees pause, asks user
const task = await TaskGet(taskId);
if (task.metadata.needs_input) {
  const answer = await AskUserQuestion({
    questions: [{
      question: task.metadata.question,
      options: ["Yes - create tasks", "No - just report", "Show details first"]
    }]
  });

  // 3. Resume agent with answer
  Task({
    subagent_type: "mutation",
    resume: task.metadata.agent_id,  // Resume previous session
    prompt: `User answered: ${answer}. Continue from where you left off.`,
    run_in_background: true          // Continue in background
  });
}

// 4. Resumed agent continues with full context
// - Has complete previous conversation history
// - Sees user's answer
// - Continues without re-analyzing mutations
```

**Agents that benefit from background execution:**
- ✅ mutation (10-30 min runtime, autonomous)
- ✅ code-reviewer (5-10 min, can pause for questions)
- ✅ domain (3-5 min, can pause for business rule questions)
- ⚠️ red/green (1-2 min, interactive - consider foreground)

**Task metadata schema additions:**
```typescript
interface SDLCTaskMetadata {
  // ... existing fields ...

  // Agent Resumption
  agent_id?: string;              // agentId for resuming this agent
  needs_input?: boolean;          // Signals agent is paused awaiting input
  question?: string;              // Question for user
  question_context?: object;      // Context needed to understand/answer question
  question_options?: string[];    // Options for AskUserQuestion
}
```

**Documentation requirements:**
- Document resumption pattern in task-integration-patterns.md
- Add examples for mutation, code-review, domain agents
- Update agent restructuring plan with resumption capabilities
- Include in Phase 5 agent updates

---

## Decision 5: Skill Naming for Marketplace

**Question:** Should skills use namespaced names (jwilger-tdd-constraints) or generic names (tdd-constraints)?

**Decision:** ✅ **Generic Names (Option B)**

**Rationale:**
- Repository provides namespace: `jwilger/claude-code-plugins`
- Cleaner agent definitions: `skills: [tdd-constraints]` vs `skills: [jwilger-tdd-constraints]`
- Better discoverability: skills.sh search finds "tdd-constraints" easily
- Standard practice: Most marketplace skills use generic names
- Low collision risk: TDD/Event Modeling skills are niche
- Metadata includes attribution: Skill manifest has author/repository fields

**Implementation:**

**Skill names:**
- ✅ `tdd-constraints` (not `jwilger-tdd-constraints`)
- ✅ `user-input-protocol` (not `jwilger-user-input-protocol`)
- ✅ `debugging-protocol` (not `jwilger-debugging-protocol`)
- ✅ `atomic-design` (not `jwilger-atomic-design`)
- ✅ `git-spice` (not `jwilger-git-spice`)
- ✅ `github-issues` (not `jwilger-github-issues`)
- ✅ `memory-protocol` (not `jwilger-memory-protocol`)
- ✅ `event-modeling` (not `jwilger-event-modeling`)
- ✅ `orchestration-protocol` (not `jwilger-orchestration-protocol`)

**Skill manifest includes attribution:**
```yaml
---
name: tdd-constraints
author: jwilger
repository: jwilger/claude-code-plugins
version: 1.0.0
description: Red/green/domain phase boundaries and constraints for TDD workflow
---
```

**Agent references:**
```yaml
# In agent frontmatter
skills:
  - tdd-constraints
  - user-input-protocol
  - debugging-protocol
```

---

## Decision 6: Task Cleanup Strategy

**Question:** How should completed tasks be archived or cleaned up?

**Decision:** ✅ **Rely on Claude Code Built-in Cleanup (Option B)**

**Key Discovery:** Claude Code does NOT automatically clean up tasks. Tasks persist indefinitely until manually cleared by user.

**Built-in mechanisms:**
- Press `Ctrl+T` to view task list (shows up to 10 tasks)
- Ask Claude: "show me all tasks" or "clear all tasks"
- Ask Claude: "clear completed tasks" or "clear task X"
- Tasks can be individually managed through conversation

**Rationale:**
- ✅ Already works - users can clear tasks anytime via natural language
- ✅ Simpler - no custom cleanup code needed
- ✅ Flexible - user decides when to clear based on their workflow
- ✅ One less thing to build - focus on core task functionality
- ✅ Standard behavior - consistent with other Claude Code task usage
- ✅ User is sole user - manual cleanup is not a burden

**What sdlc plugin does NOT build:**
- ❌ No `/sdlc:cleanup` command
- ❌ No automatic archival after N days
- ❌ No feature-based cleanup on PR merge
- ❌ No cleanup suggestions/prompts

**User workflow:**
```
User: clear completed tasks
Claude: Cleared 23 completed tasks. 5 tasks remaining.

User: show me all tasks
Claude:
◻ Red: Write payment test
▲ Green: Implement payment (blocked by domain)
▲ Mutation: Test payment (blocked by green)
... (2 more)
```

**Future consideration (v4.1+):**
- Could add smart suggestions: "You have 47 completed tasks. Would you like to clear them?"
- Could add feature-based cleanup: "PR #123 merged. Clear related tasks?"
- Gather usage data first to see if automation is warranted

---

## Impact on Implementation Plan

### Simplified Scope

**Removed from v4.0.0:**
- ❌ Invocation gate coexistence code (Decision 2)
- ❌ Dedicated orchestrator agent (Decision 3 - not possible)
- ❌ Gate migration phases (Decision 2)
- ❌ Custom task cleanup commands (Decision 6)
- ❌ Cleanup automation logic (Decision 6)

**Added to v4.0.0:**
- ✅ Agent resumption pattern documentation (Decision 4)
- ✅ Task metadata schema for resumption (Decision 4)
- ✅ Background execution by default for long-running agents (Decision 4)
- ✅ Generic skill naming (Decision 5)
- ✅ Skills in same repository structure (Decision 1)

### Revised Timeline Estimate

**Original estimate:** 21-31 days (4-6 weeks)

**Revised estimate:** 18-26 days (3.5-5 weeks)

**Time savings:**
- Gate migration complexity: -2 days
- Dedicated orchestrator agent: -2 days
- Custom cleanup logic: -1 day

**Time additions:**
- Agent resumption pattern: +1 day (documentation + examples)
- Background execution testing: +1 day (verify MCP access, test resumption)

**Net change:** -3 days faster

### Phase Impact

**Phase 2 (Skill Structure Design):** No change
- 2-3 days
- Generic naming simplifies (no namespace handling)

**Phase 3 (Task Integration Patterns):** +1 day
- 2-3 days → 3-4 days
- Add agent resumption pattern documentation
- Expand task metadata schema

**Phase 4 (Skill Extraction):** No change
- 5-7 days
- Generic naming is simpler

**Phase 5 (Agent Restructuring):** -2 days
- 7-10 days → 5-8 days
- No dedicated orchestrator to build
- No gate validation code to remove (already gone)
- Add background execution + resumption capabilities

**Phase 6 (Marketplace Integration):** No change
- 2-3 days

**Phase 7 (Documentation):** -1 day
- 3-5 days → 2-4 days
- No gate migration guide needed
- No cleanup documentation needed

**Total:** 18-26 days (vs 21-31 days original)

---

## Next Steps

1. **Update task-integration-patterns.md**
   - Add agent resumption pattern with full examples
   - Update task metadata schema with resumption fields
   - Document background execution strategy

2. **Update implementation-analysis.md**
   - Mark all open questions as RESOLVED
   - Update Phase 5 to reflect simplified scope
   - Revise timeline estimates

3. **Update agent-restructuring-plan.md**
   - Add background execution by default
   - Document resumption capabilities per agent
   - Remove orchestrator agent section

4. **Update SUMMARY.md**
   - Reflect resolved decisions
   - Update timeline to 18-26 days
   - Note simplified scope

5. **Create Phase 2 kickoff**
   - Ready to begin skill structure design
   - All architectural decisions locked in
   - Clear path to implementation

---

## Decision Authority

**Decisions made by:** User (jwilger)
**Date:** 2026-02-04
**Status:** ✅ FINAL - Ready for implementation

All 6 architectural decisions have been finalized. Implementation can proceed with confidence.
