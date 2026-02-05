---
name: user-input-protocol
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Pattern for subagents to request user input when AskUserQuestion is unavailable
tags:
  - user-input
  - subagent
  - checkpoint
  - resumption
portability: high
dependencies: []
---

# User Input Protocol

**Version:** 1.0.0
**Portability:** High

---

## Objective

Defines a pattern for subagents (background tasks, delegated agents) to request user input when they cannot directly call AskUserQuestion.

**Purpose:** Enable long-running or background agents to ask clarifying questions without failing or making assumptions.

**Scope:**
- **Included:** Pause pattern, state preservation, question format, resumption workflow
- **Excluded:** Specific checkpoint implementations (framework-dependent)

---

## Core Principles

### Principle 1: Subagents Cannot Directly Ask Questions

**The Problem:** In most agent frameworks, only the main conversation can call AskUserQuestion. Subagents (background tasks, delegated agents) attempting to call it will fail.

**Why this matters:** Long-running agents often hit decision points requiring user input. Without a pattern, they must either guess (bad) or fail (wasteful).

**How to apply:**
- Accept that subagents have limited tools
- Design a pause-and-resume pattern instead of direct calls
- Use the main conversation as an intermediary

**Example:**
```
# Agent framework limitation
Main Conversation: CAN call AskUserQuestion ✓
Subagent (background): CANNOT call AskUserQuestion ✗

# Solution
Subagent pauses → Main conversation asks → Subagent resumes
```

### Principle 2: Save State Before Pausing

**The Principle:** Before requesting input, save all necessary context so work can resume seamlessly.

**Why this matters:** Session restarts lose conversation history. State preservation ensures no wasted work redoing analysis.

**How to apply:**
1. Document what you've done so far
2. Save references to files created/read
3. Store the specific decision pending
4. Preserve enough context to continue without re-analyzing

**Example (Framework-Agnostic):**
```
State to preserve:
- Task description and progress
- Files created: [auth_test.rs, auth.rs]
- Files analyzed: [user.rs, session.rs]
- Decision needed: "Should Email validation be strict or lenient?"
- Context: "Found 3 different email patterns in existing code"
```

### Principle 3: Structured Question Format

**The Principle:** Use a consistent, structured format for questions that includes context, options, and constraints.

**Why this matters:** Ad-hoc question formats lead to confusion. Structured formats ensure users have enough context to make informed decisions.

**How to apply:**
- Provide context explaining why you're asking
- Offer specific options (2-4 choices)
- Include descriptions explaining each option's implications
- Indicate whether multiple selections are allowed

**Example Format:**
```json
{
  "context": "Why you're asking this question",
  "question": "The actual question text?",
  "options": [
    {
      "label": "Option A",
      "description": "What this means and its implications"
    },
    {
      "label": "Option B",
      "description": "What this means and its implications"
    }
  ],
  "multiSelect": false
}
```

### Principle 4: Clean Resumption

**The Principle:** When resuming with the user's answer, retrieve saved state and continue seamlessly without redoing work.

**Why this matters:** Users expect agents to remember what they were doing. Redoing analysis wastes time and creates frustration.

**How to apply:**
1. Retrieve saved state (checkpoint, task metadata, etc.)
2. Load files you were working on
3. Read the user's answer
4. Continue immediately from where you paused

**Example:**
```
# Bad: Restart from scratch
"Let me re-analyze all the code to understand the problem again..."

# Good: Resume cleanly
"You chose Option A (strict email validation). Continuing implementation..."
```

---

## Constraints and Boundaries

### DO:
- Save comprehensive state before pausing (all context needed to resume)
- Provide clear context explaining why you need input
- Offer specific options with clear descriptions
- Indicate you're pausing and waiting for input
- Resume cleanly using saved state

### DON'T:
- Assume you can call AskUserQuestion from a subagent (you can't)
- Pause without saving state (context will be lost)
- Ask vague questions without options ("What should I do?")
- Make assumptions when user input is actually needed
- Redo analysis when resuming (use saved state)

**Rationale:** This pattern bridges the gap between subagent limitations and user interaction needs while preserving work and context.

---

## Usage Patterns

### Pattern 1: Background Agent Needs Clarification

**Scenario:** Long-running mutation testing agent finds surviving mutants and needs to know whether to create individual tasks.

**Approach:**
1. Pause current work
2. Save state (mutant details, progress so far)
3. Format question with specific options
4. Signal pause to main conversation
5. Main conversation asks user via AskUserQuestion
6. Main conversation resumes agent with answer
7. Agent retrieves state and continues

**Example (Conceptual):**
```
# Step 1: Agent pauses
Save state:
- Feature: user-authentication
- Progress: Mutation testing complete, 97% score
- Pending decision: 3 surviving mutants found
- Mutant details: [file:line details for each]

# Step 2: Agent signals
Output: PAUSED_FOR_INPUT
Question: "Found 3 surviving mutants. Create individual fix tasks?"
Options: ["Yes - create tasks", "No - just report"]

# Step 3: Main conversation intermediates
(Main conversation detects pause, calls AskUserQuestion)
User answer: "Yes - create tasks"

# Step 4: Agent resumes
Retrieve state → Read mutant details → Create 3 tasks → Complete
```

### Pattern 2: Domain Agent Encounters Ambiguous Business Rule

**Scenario:** Domain modeling agent finds conflicting patterns in existing code and needs business rule clarification.

**Approach:**
1. Document the conflict found
2. Save analysis of both patterns
3. Ask user which is correct
4. Resume and apply the chosen rule

**Example:**
```
State:
- Analyzing: Email validation logic
- Found: Two patterns
  - Pattern A: Strict RFC 5322 compliance (auth module)
  - Pattern B: Lenient validation (signup module)
- Decision: Which pattern should be standard?

Question: "Found two email validation approaches. Which should be canonical?"
Options:
  - "Strict RFC 5322 (more secure, may reject valid emails)"
  - "Lenient (more permissive, may accept invalid emails)"
  - "Keep both (context-dependent)"
```

### Pattern 3: Code Reviewer Needs Architectural Decision

**Scenario:** Code review agent finds architectural inconsistency and needs to know preferred approach.

**Approach:**
1. Document the inconsistency
2. Present the tradeoffs
3. Ask for preferred direction
4. Resume and apply feedback

---

## Integration with Other Skills

**Works well with:**
- **debugging-protocol:** When debugging reveals ambiguous root cause, pause and ask user
- **tdd-constraints:** When test requirements are unclear, pause and clarify acceptance criteria
- **orchestration-protocol:** Main orchestrator detects pauses and manages user interaction

**Prerequisites:**
- Framework must support agent resumption (continuing with full context)
- State preservation mechanism (checkpoints, task metadata, or similar)
- Main conversation can spawn and resume subagents

---

## Common Pitfalls

### Pitfall 1: Trying to Call AskUserQuestion from Subagent

**Problem:** Subagent attempts direct tool call and fails

**Solution:** Accept the limitation. Use pause-and-resume pattern instead.

### Pitfall 2: Pausing Without State Preservation

**Problem:** Agent pauses but doesn't save context. On resumption, starts over.

**Solution:** Always save comprehensive state before signaling pause. Test resumption to verify no work is lost.

### Pitfall 3: Vague Questions Without Options

**Problem:** "What should I do about this?" with no context or choices

**Solution:** Provide specific context, clear options with descriptions, and enough information for user to decide.

### Pitfall 4: Assuming Answer Format

**Problem:** Agent assumes user will answer in specific format, breaks when they don't

**Solution:** Provide structured options. If using free text, validate and clarify if needed.

---

## Examples

### Example 1: Mutation Testing Agent (File-Based Implementation)

**Context:** Agent using file-based state persistence (sdlc plugin pattern)

**Step 1: Create Checkpoint**
```bash
# Determine memory path
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
MEMORY_PATH="$HOME/.claude/projects/$(basename "$PROJECT_ROOT")/memory"
mkdir -p "$MEMORY_PATH/checkpoints"

# Create checkpoint file
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
STATE_FILE="$MEMORY_PATH/checkpoints/mutation-agent-${TIMESTAMP}.md"

cat > "$STATE_FILE" << 'EOF'
# mutation-agent Checkpoint

**Timestamp:** 2026-02-04T10:30:00Z
**Task:** Mutation testing for auth module
**Agent:** mutation-agent

## Progress Summary

Testing complete, 97% mutation score achieved.

## Files Analyzed

- src/auth.rs
- tests/auth_test.rs

## Next Step

Handle 3 surviving mutants - need user decision on approach.

## Pending Decision

Should I create individual fix tasks for each surviving mutant or just report?

## Context for Continuation

Three specific mutants survived:
1. Line 45: Boundary condition in token expiry
2. Line 78: Error message text change (no behavior impact)
3. Line 103: Default timeout value change
EOF
```

**Step 2: Signal Pause**
```bash
echo "AWAITING_USER_INPUT"
cat << 'EOF'
{
  "context": "Mutation testing found 3 surviving mutants (97% score overall)",
  "stateFile": "/home/user/.claude/projects/myapp/memory/checkpoints/mutation-agent-2026-02-04T10:30:00Z.md",
  "questions": [{
    "id": "q1",
    "question": "Should I create individual fix tasks for each surviving mutant?",
    "header": "Mutants",
    "options": [
      {"label": "Yes - create tasks", "description": "Create 3 separate tasks to address each mutant"},
      {"label": "No - just report", "description": "Document the mutants but don't create tasks"}
    ],
    "multiSelect": false
  }]
}
EOF
```

**Step 3: Main Conversation Intermediates**
```javascript
// Main conversation detects AWAITING_USER_INPUT
// Calls AskUserQuestion with the provided structure
// Receives answer: "Yes - create tasks"
```

**Step 4: Resume Agent**
```bash
# Main conversation launches NEW agent (not resume)
Task({
  subagent_type: "mutation",
  prompt: `USER_INPUT_RESPONSE
{"q1": "Yes - create tasks"}

Continue from state file: /home/user/.claude/projects/myapp/memory/checkpoints/mutation-agent-2026-02-04T10:30:00Z.md`
});

# Agent reads checkpoint file and continues
STATE_FILE="/home/user/.claude/projects/myapp/memory/checkpoints/mutation-agent-2026-02-04T10:30:00Z.md"
STATE_CONTENT=$(cat "$STATE_FILE")

# Parse context and continue work
# Create 3 tasks for the surviving mutants...
```

### Example 2: Task Metadata Implementation (Claude Code)

**Context:** Agent using Claude Code task metadata for state

**Step 1: Update Task Metadata**
```javascript
// Save state to task metadata
await TaskUpdate({
  taskId: currentTaskId,
  metadata: {
    ...existingMetadata,
    agent_id: myAgentId,
    needs_input: true,
    question: "Found two validation approaches. Which should be standard?",
    question_context: {
      pattern_a: "Strict RFC 5322 (auth module)",
      pattern_b: "Lenient validation (signup module)",
      files_analyzed: ["src/auth/mod.rs", "src/signup/mod.rs"]
    },
    question_options: [
      "Strict RFC 5322 (Recommended for security)",
      "Lenient validation",
      "Keep both (context-dependent)"
    ]
  }
});

// Exit agent
return "Paused - awaiting user decision on validation approach";
```

**Step 2: Main Conversation Detects Pause**
```javascript
// Main orchestrator polls tasks
const task = await TaskGet(taskId);

if (task.metadata.needs_input) {
  // Ask user
  const answer = await AskUserQuestion({
    questions: [{
      question: task.metadata.question,
      header: "Validation",
      options: task.metadata.question_options.map(opt => ({
        label: opt,
        description: ""
      })),
      multiSelect: false
    }]
  });

  // Update task with answer
  await TaskUpdate({
    taskId: task.id,
    metadata: {
      ...task.metadata,
      needs_input: false,
      user_answer: answer,
      answered_at: new Date().toISOString()
    }
  });

  // Resume agent
  await Task({
    subagent_type: "domain",
    resume: task.metadata.agent_id,
    prompt: `User chose: "${answer}". Continue from where you left off.`
  });
}
```

**Step 3: Agent Resumes**
```javascript
// Agent resumes with FULL previous context
const task = await TaskGet(myTaskId);
const answer = task.metadata.user_answer;

// Continue based on answer
if (answer === "Strict RFC 5322 (Recommended for security)") {
  // Apply strict validation standard...
}
```

### Example 3: Simple File-Based State

**Context:** Agent without MCP or tasks, using filesystem

**Step 1: Write State File**
```bash
# Save state to file
cat > /tmp/agent-pause-state.json << 'EOF'
{
  "agent": "domain-agent",
  "timestamp": "2026-02-04T10:30:00Z",
  "progress": "Analyzed email validation patterns",
  "files": ["src/auth/mod.rs", "src/signup/mod.rs"],
  "decision": "Which validation pattern?",
  "question": {
    "text": "Found two email validation approaches. Which should be standard?",
    "options": ["Strict RFC 5322", "Lenient", "Keep both"]
  }
}
EOF
```

**Step 2: Output Pause Signal**
```
PAUSED_FOR_INPUT: /tmp/agent-pause-state.json

Question: Found two email validation approaches. Which should be standard?
A) Strict RFC 5322 (more secure)
B) Lenient (more permissive)
C) Keep both (context-dependent)
```

**Step 3: Resume with Answer**
```bash
# Read state
state=$(cat /tmp/agent-pause-state.json)

# Read answer (provided by main conversation)
answer="A"

# Continue work based on answer...
```

---

## Verification Checklist

Use this checklist to verify you're applying this pattern correctly:

- [ ] Subagent saves comprehensive state before pausing (all files, progress, pending decision)
- [ ] Question includes clear context explaining why input is needed
- [ ] Options are specific with descriptions of implications
- [ ] Pause signal is clear and detectable by main conversation
- [ ] Main conversation can retrieve question and present to user
- [ ] User's answer is stored alongside saved state
- [ ] Agent can resume and retrieve both saved state and answer
- [ ] No work is redone when resuming (uses saved state)
- [ ] Pattern works across session restarts (state is persistent)

---

## References

**Source Documentation:**
- sdlc plugin: docs/SUBAGENT_QUESTION_PROTOCOL.md (file-based implementation)

**Related Skills:**
- orchestration-protocol - How main conversation detects and handles pauses
- debugging-protocol - When debugging needs user input to disambiguate
- memory-protocol - File-based knowledge management patterns

**External Resources:**
- Agent resumption patterns in Claude Code documentation
- Claude Code auto memory directory: ~/.claude/projects/<project-path>/memory/

---

## Version History

### v1.0.1 (2026-02-05)
- Updated Example 1 to use file-based state persistence (removed Memento MCP)
- Updated references to point to SUBAGENT_QUESTION_PROTOCOL.md
- Removed obsolete Memento MCP references from metadata

### v1.0.0 (2026-02-04)
- Initial extraction from sdlc plugin
- Generalized from framework-specific to framework-agnostic pattern
- Added three implementation examples (file-based, task metadata, generic)
- Core principle: pause → save state → ask → resume

---

## Metadata

**Extraction Source:** sdlc/commands/shared/user-input-protocol.md
**Extraction Date:** 2026-02-04
**Last Updated:** 2026-02-04
**Compatibility:** Claude Code 2.1+, Cursor, Windsurf, Cline (with agent resumption support)
**License:** MIT
