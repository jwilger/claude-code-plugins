# Collaboration Protocols

## Core Principle

**ALL creative and decision work happens collaboratively in the main conversation with active user participation.**

Agents serve as advisory/research support, returning recommendations and proposing changes via IDE diffs. The user is not a rubber-stamp committee approving autonomous work—they are an active collaborator in design, architecture, and implementation.

## The Pair-Programming Model

### Traditional (Wrong) Flow
```
User: "Implement feature X"
Main: *launches agent*
[Agent works in isolation]
Agent: *returns finished implementation*
User: [approve/reject] ← Rubber stamp
```

### Collaboration-First (Correct) Flow
```
User: "Implement feature X"
Main: *invokes facilitator slash command or launches advisory agent*
Agent: *researches, analyzes, stores findings in memento*
Agent: *proposes changes via IDE diff*
Agent: *PAUSES and returns to main conversation*
Main: "Agent proposed approach Y. Review the diff."
User: *modifies proposal in IDE, adds QUESTION: comments*
Main: *resumes agent with user's modifications*
Agent: *acknowledges modifications, answers questions*
Agent: *proposes refined version*
[Iterate together until user accepts]
```

## Resumable Subagent Pattern

### Session Lifecycle

All agents operate within a resumable session lifecycle:

**1. LAUNCH**: Main conversation creates new subagent session via Task tool
- Provide complete context and objectives
- Specify expected deliverables
- Indicate when to pause for user input

**2. ACTIVE**: Subagent working autonomously
- Researching, analyzing, proposing changes
- May store findings in memento
- May ask questions via main conversation relay

**3. PAUSE**: Subagent returns control to main conversation
- Returns recommendations/questions/proposals
- Stores interim state in memento if needed
- Session context preserved for resume
- Main conversation facilitates user collaboration

**4. RESUME**: Main conversation continues subagent with new input
- Provide user's answers/decisions/modifications
- Full prior context automatically restored
- Subagent continues from where it paused

**5. COMPLETE**: Subagent finishes work
- Returns final deliverables
- Stores knowledge in memento
- Session ends

**6. ABANDONED**: Session timeout/orphaned
- Auto-cleanup after timeout
- Main conversation tracks and manages active sessions

### Why Resumable Matters

**Before resumable agents:**
- Context lost between invocations
- Agent couldn't see user modifications
- Had to use Skills to maintain state

**With resumable agents:**
- Full context preserved across pause/resume
- Agent sees user modifications when resumed
- Can acknowledge changes and iterate
- Natural collaborative flow

## IDE Diff Modification Flow (MANDATORY)

### How It Works

When agents propose file changes, you see diffs in your IDE. You can:

1. **Modify the proposed changes directly** - Edit the diff before accepting
2. **Add QUESTION: comments** - Insert inline questions about the proposal
3. **Accept, reject, or iterate** - Standard diff workflow

### Agent Responsibilities

**When Proposing Changes:**

1. **Use Write/Edit to create IDE diff**
2. **PAUSE immediately after proposal** - Return to main conversation
3. **Never finalize changes without user approval**

**When Resumed After User Modifies:**

1. **Acknowledge the modification explicitly**
   - ✅ "I see you changed X to Y. Good call because [rationale]..."
   - ✅ "I notice you adjusted X. That makes sense given [context]..."

2. **Offer counterarguments when warranted** (collaboration, not blind obedience)
   - ✅ "I see you changed X to Y, but consider: Z might be better because [rationale]. What do you think?"
   - ❌ "Okay, I'll use Y." (when you have legitimate concerns)

3. **Answer any QUESTION: comments**
   - Explain rationale clearly
   - Reference relevant architectural decisions or patterns
   - Remove QUESTION: comment in next proposal

4. **Iterate until consensus**
   - Discussion continues until both agree
   - No rushing to acceptance

### Main Conversation Responsibilities

**For Decision Points - Use AskUserQuestion Tool:**

When main conversation needs user decision on implementation choices:

1. **ALWAYS use AskUserQuestion tool** - Don't propose options in conversation text
2. **Present 2-4 clear options** with descriptions of trade-offs
3. **Wait for user selection** - Tool handles the UI interaction
4. **Resume agent with user choice** - User picks, agent implements

**Example:**
```python
# ❌ WRONG - Proposing in conversation:
"Should we use Option A (faster) or Option B (more maintainable)?"

# ✅ CORRECT - Using tool:
AskUserQuestion(questions=[{
  "question": "Which approach should we use for the checkpoint filter?",
  "header": "Approach",
  "options": [
    {"label": "Inline (Option A)", "description": "Faster but duplicated code"},
    {"label": "Helper (Option B)", "description": "DRY but adds indirection"}
  ]
}])
```

**When Relaying User Modifications to Agent:**

1. **Resume agent with modification details**
2. **Include any QUESTION: comments from user**
3. **Provide context if needed**

**Example:**
```
# Main conversation resumes agent:
"User modified your proposal:
- Changed from Vec<T> to HashMap<K, V> for O(1) lookups
- Added QUESTION: Why not use BTreeMap for sorted keys?

Please acknowledge the change and answer the question."
```

### QUESTION: Comment Protocol

**When user adds QUESTION: comments in proposed changes:**

```markdown
[Proposed content]

QUESTION: Should we also consider X?
```

**Agent response when resumed:**

"QUESTION: Should we also consider X?

Answer: [Your detailed answer with reasoning]"

After user confirms, agent removes QUESTION: and updates content accordingly in next proposal.

**Example:**
```rust
// User adds in diff:
pub fn process(data: String) -> Result<Output, Error> {
    // QUESTION: Why Result instead of Option here?
    // ... rest of code
}

// Agent responds when resumed:
"Good question! Using Result here because we need to distinguish between
different failure modes (ParseError vs ValidationError), not just
presence/absence. Option would lose that error context. Here's the
cleaned version..."

// Then proposes:
pub fn process(data: String) -> Result<Output, Error> {
    // ... rest of code (no QUESTION: comment)
}
```

## Agent Types and Permissions

### Facilitator Slash Commands (Coordinate Collaboration)

**Purpose:** Put main agent into facilitation mode to actively coordinate collaborative work between user and specialist agents for entire phases

**Characteristics:**
- Main agent invokes slash command (e.g., `/analyze`, `/model`, `/architect`, `/plan`, `/tdd`)
- Main agent gains facilitation-specific instructions and context
- Main agent coordinates between specialist advisory agents (via Task tool) and user
- Main agent pauses at decision points throughout long phases
- MUST use IDE diff collaboration flow
- NEVER finalizes changes without user approval

**Available Commands:**
- `/analyze` - Requirements facilitation (Phase 1)
- `/model` - Event modeling facilitation (Phase 2)
- `/architect` - Architecture/ADR facilitation (Phase 3)
- `/plan` - Story planning facilitation (Phase 6)
- `/tdd` - TDD implementation facilitation (Phase 7)

**Flow:**
1. Main agent invokes facilitator slash command for phase (via SlashCommand tool)
2. Main agent (in facilitation mode) launches specialist agents via Task tool for consultation
3. Main agent proposes changes via IDE diff
4. Main agent PAUSES for user collaboration (waits for IDE diff acceptance/modification)
5. User modifies proposal in IDE, adds QUESTION: comments
6. Main agent acknowledges modifications, answers questions
7. Main agent iterates with user until consensus
8. Repeat until phase complete

### Specialist Advisory Subagents (Propose Changes)

**Purpose:** Domain-specific analysis and recommendations with IDE diff proposals

**Characteristics:**
- Have Write/Edit/NotebookEdit tools for IDE diff proposals
- Research, analyze, store findings in memento
- Propose changes via IDE diffs
- MUST pause after proposals
- NEVER finalize changes without user approval
- Usually short-lived sessions (single consultation)

**Examples:**
- TDD agents (red-tdd-tester, green-implementer)
- Domain modeling agents (rust/python/typescript/elixir-domain-model-expert)
- Planning agents (requirements-analyst, story-planner, adr-writer, story-architect, ux-consultant)
- Event modeling agents (all 13 step agents + pm + architect)
- design-system-architect, architecture-synthesizer
- acceptance-validator

**Flow:**
1. Main agent (possibly in facilitation mode) launches specialist agent via Task tool
2. Agent researches/analyzes
3. Agent stores findings in memento
4. Agent proposes changes via IDE diff
5. Agent PAUSES and returns to main agent
6. Main agent presents to user
7. User modifies proposal in IDE
8. Main agent RESUMES agent with modifications (via Task tool with resume parameter)
9. Agent acknowledges and iterates

### Operational Subagents (Mechanical Operations)

**Purpose:** Mechanical operations with clear procedures and verification

**Characteristics:**
- Have Write/Edit/NotebookEdit for mechanical operations
- Execute well-defined procedures (not creative work)
- May use IDE diff collaboration for user review
- Some operations don't require pause (auto-formatting, auto-commits after verification)

**Examples:**
- source-control-agent (git operations, PR creation, commit verification)
- technical-documentation-writer (markdown formatting/consistency, QA)
- cognitive-complexity-agent (TRACE analysis)
- mutation-testing-agent (mutation testing execution)
- github-pr-agent (PR workflows, review comment threading)
- exploration-agent (fast codebase exploration)
- dependency-agent (dependency management via cargo/uv/npm/pnpm)
- memory-intelligence-agent (complex knowledge graph operations)
- devops (infrastructure configuration)
- file-editor (ONLY for explicit user requests: "fix this typo")

**Flow:**
1. Main conversation launches operational agent for specific task
2. Agent executes procedure
3. Agent verifies results
4. Agent may pause for user review if unclear
5. Agent returns results/status

## Inter-Agent Communication

### Real-Time Communication (Via Main Conversation Relay)

When agents need to coordinate in real-time:

**Pattern:**
1. Agent A pauses with question/request for Agent B
2. Main conversation launches/resumes Agent B
3. Agent B processes and returns response
4. Main conversation resumes Agent A with answer

**Use for:**
- Immediate questions requiring specialist input
- Quick consultations during active work
- Synchronous coordination needs

**Example:**
```
Main (in /tdd mode, paused): "Need domain-model-expert to review this test for type opportunities"
→ Main launches rust-domain-model-expert via Task tool
rust-domain-model-expert: "Types can prevent this - recommend strengthening"
→ Recommendation returned to main agent
Main (in /tdd mode): "Acknowledged. Updating test approach..."
```

### Async Communication (Via Memento Knowledge Graph)

When agents need to share knowledge across sessions:

**Pattern:**
1. Agent A stores findings/decisions in memento
2. Agent B (later) retrieves via semantic search
3. No direct coupling between agents

**Use for:**
- Persistent knowledge and decisions
- Patterns discovered during work
- Historical context for future sessions
- Cross-session learning

**Example:**
```
Main (in /architect mode): Stores ADR decision in memento
→ (later session)
Main (in /tdd mode): Retrieves ADR via semantic search during implementation
```

## Facilitator-Coordinated Phases

### Pattern: Facilitation Mode Orchestrates Collaboration

For phases requiring extensive user participation (Phases 1, 2, 3, 6, 7), main agent enters facilitation mode via slash commands:

**Main Agent Responsibilities (in Facilitation Mode):**
1. Launch specialist agents via Task tool for domain expertise
2. Synthesize specialist recommendations
3. Propose changes via IDE diff
4. Pause for user collaboration (wait for IDE acceptance)
5. Acknowledge user modifications
6. Answer QUESTION: comments
7. Iterate with user until section/phase complete

**User Responsibilities:**
1. Review proposals in IDE
2. Modify directly in IDE diffs
3. Add QUESTION: comments for clarifications
4. Make final decisions on trade-offs
5. Accept when satisfied

## Phase-Specific Collaboration

### Phase 1: Requirements Analysis

**Facilitator:** `/analyze` slash command

**Flow:**
```
Main: Invokes /analyze via SlashCommand tool
Main (in /analyze mode): Launches requirements-analyst via Task tool for research
requirements-analyst: Returns recommendations
Main (in /analyze mode): Proposes REQUIREMENTS_ANALYSIS.md section via IDE diff
Main (in /analyze mode): PAUSES (waits for user to accept/modify)
User: Modifies section, adds "QUESTION: Should we include OAuth?"
Main (in /analyze mode): "I see you added multi-factor auth requirement. Good addition given security concerns. QUESTION: Should we include OAuth? Yes, modern apps expect this. Proposing updated version..."
Main (in /analyze mode): Proposes refined section
[Iterate until section complete, repeat for all sections]
```

### Phase 2: Event Modeling

**Facilitator:** `/model` slash command

**Flow:**
```
Main: Invokes /model via SlashCommand tool
Main (in /model mode): Works through 12-step process
Main (in /model mode): For each step, launches step-specific agent via Task tool
event-modeling-step-1: Returns goal event recommendations
Main (in /model mode): Proposes event model component via IDE diff
Main (in /model mode): PAUSES (waits for user to accept/modify)
User: Refines event sequence, adds questions
Main (in /model mode): Acknowledges, answers questions
[Iterate through all 12 steps]
Main (in /model mode): Launches review agents (pm, architect) via Task tool
[Final consensus and user approval]
```

### Phase 3: Architecture (ADRs)

**Facilitator:** `/architect` slash command

**Flow:**
```
Main: Invokes /architect via SlashCommand tool
Main (in /architect mode): Launches adr-writer via Task tool for analysis
adr-writer: Returns ADR recommendations with alternatives
Main (in /architect mode): Proposes ADR section via IDE diff
Main (in /architect mode): PAUSES (waits for user to accept/modify)
User: Modifies decision rationale, adds context question
Main (in /architect mode): Acknowledges changes, answers question
[Iterate until ADR complete]
Main (in /architect mode): User sets status to accepted/rejected
Main (in /architect mode): If accepted, launches architecture-synthesizer via Task tool to update ARCHITECTURE.md
```

### Phase 6: Story Planning

**Facilitator:** `/plan` slash command

**Flow:**
```
Main: Invokes /plan via SlashCommand tool
Main (in /plan mode): Launches story-planner via Task tool for business perspective
Main (in /plan mode): Launches story-architect via Task tool for technical perspective
Main (in /plan mode): Launches ux-consultant via Task tool for UX perspective
Main (in /plan mode): Synthesizes three-agent consensus
Main (in /plan mode): Proposes story content via IDE diff (or beads fields)
Main (in /plan mode): PAUSES (waits for user to accept/modify)
User: Adjusts scope, priority, acceptance criteria
Main (in /plan mode): Creates beads issue with `/beads:create`
[Repeat for each story]
```

### Phase 7: TDD Implementation (Core Loop)

**Facilitator:** `/tdd` slash command

**Flow:**
```
Main: Invokes /tdd via SlashCommand tool for story
Main (in /tdd mode): Launches red-tdd-tester via Task tool for test approach
red-tdd-tester: Returns test recommendation
Main (in /tdd mode): Proposes test via IDE diff
Main (in /tdd mode): PAUSES (waits for user to accept/modify)
User: Refines test assertion, adds question about setup
Main (in /tdd mode): Acknowledges changes, answers setup question
Main (in /tdd mode): Proposes refined test
User: Accepts
Main (in /tdd mode): Runs test, sees failure
Main (in /tdd mode): Launches rust-domain-model-expert via Task tool for type review
domain-expert: "Types cannot prevent this - approve runtime test"
Main (in /tdd mode): Launches green-implementer via Task tool for minimal implementation
green-implementer: Returns implementation recommendation
Main (in /tdd mode): Proposes implementation via IDE diff
Main (in /tdd mode): PAUSES (waits for user to accept/modify)
User: Refines implementation, adds QUESTION: about edge case
Main (in /tdd mode): Answers edge case question, proposes final version
User: Accepts
Main (in /tdd mode): Verifies tests pass, stores TDD decision in memento
[Repeat TDD cycle until story complete]
```

## When Agents Finalize Without User Review

**The ONLY scenarios where agents can finalize changes without IDE diff pause:**

### 1. Auto-Formatting After Verification
- markdownlint/rustfmt corrections
- Following linter rules automatically
- After user has already approved content

### 2. Auto-Commit After Quality Gates
- ALL tests passing (verified)
- ALL quality gates passing (TRACE ≥70%, mutation ≥80%)
- Source control agent creates commit after verification

### 3. Mechanical Operations With Clear Success Criteria
- Dependency updates (verified by cargo check/npm install)
- Infrastructure configuration following templates

**In ALL other cases:** Agent proposes → PAUSES → user reviews/modifies → agent resumes and acknowledges

## Mandatory Pause Points

Main agent (in facilitation mode) and specialist advisory agents MUST pause at these points:

### Main Agent (in Facilitation Mode via Slash Commands)
- After proposing any file changes via IDE diff
- When user adds QUESTION: comments
- After completing each major section/step
- Before finalizing phase work
- When specialist agents ask questions meant for user
- When agents disagree (user arbitrates)

### Specialist Advisory Agents
- After proposing any changes via IDE diff
- When asking questions meant for user (via main conversation relay)
- After completing analysis/recommendations
- Before any final decisions

### Operational Agents
- When encountering unexpected failures
- When procedure requires user decision
- When verification results are ambiguous

## Collaboration Quality Checks

Before proposing any code/documentation change:

- [ ] Have specialist agents been consulted for research if needed?
- [ ] Is the proposal based on user input and preferences?
- [ ] Will user be able to modify the proposal in IDE?
- [ ] Am I prepared to acknowledge user modifications?
- [ ] Am I prepared to counterargue if I have concerns?
- [ ] Can I explain rationale for design choices?
- [ ] Have I identified where QUESTION: comments might arise?
- [ ] Will I PAUSE immediately after proposal?

After being resumed with user modifications:

- [ ] Did I acknowledge what they changed?
- [ ] Did I explain why I agree or offer thoughtful counterargument?
- [ ] Did I answer any QUESTION: comments?
- [ ] Did I remove QUESTION: comments from cleaned proposal?
- [ ] Are we iterating toward consensus?
- [ ] Am I storing decisions in memento?

## Anti-Patterns to Avoid

### ❌ Agent Finalizes Without Pause
```
Agent: *proposes changes via IDE diff*
Agent: *immediately accepts without pausing*
User: [never sees proposal]
```

**Why wrong:** User excluded from collaboration

### ❌ Rubber-Stamp Approval
```
Agent: *returns complete implementation*
Main: "Agent completed the work. Does this look good?"
User: [approve/reject]
```

**Why wrong:** User never participated in design decisions

### ❌ Blind Obedience
```
User: *changes X to Y*
Agent: "Okay, using Y."
```

**Why wrong:** No critical thinking, missed opportunity to discuss tradeoffs

### ❌ Ignoring User Modifications
```
User: *modifies proposal in IDE*
Agent (when resumed): *proposes next change without acknowledging previous modification*
```

**Why wrong:** User feels ignored, loses sense of collaboration

### ❌ Silent QUESTION: Comment Removal
```
User: // QUESTION: Why this approach?
Agent: *proposes cleaned code without answering question*
```

**Why wrong:** User's question ignored, no learning or collaboration

### ❌ Main Agent Creates Complete Artifacts
```
Main (in /model mode): *creates entire EVENT_MODEL.md in one proposal*
```

**Why wrong:** User didn't participate in design, can only approve/reject whole thing

## Best Practices

### ✅ Acknowledge Modifications Explicitly
```
User: *changes from Vec to HashMap*
Main (in facilitation mode): "I see you switched from Vec to HashMap for storage. Smart—that gives us O(1) lookups instead of O(n). Continuing with HashMap approach..."
```

### ✅ Thoughtful Counterargument
```
User: *changes to simpler error handling*
Main (in facilitation mode): "I see you simplified to Option. That works for happy paths, but we'll lose visibility into why parsing failed. For debugging, Result<T, ParseError> might be better. However, if you prefer simplicity here, we can add detailed logging instead. Which direction feels right?"
```

### ✅ Answer QUESTION: Comments Thoroughly
```
User: // QUESTION: Why Arc<Mutex<T>> instead of RefCell?
Main (in /tdd mode): "Great question! We need Arc<Mutex<T>> here because we're sharing this state across threads. RefCell is single-threaded only—it would panic at runtime if accessed from multiple threads. Since our server uses tokio's multithreaded runtime, Arc<Mutex<T>> gives us thread-safe interior mutability. Here's the cleaned version..."
```

### ✅ Pause Frequently for Long Phases
```
Main (in /model mode): "I've completed Step 3 (Commands) for the authentication workflow. Here's the proposal... [proposes via IDE diff] [PAUSES - waits for user]"
User: Modifies, approves
Main (in /model mode): "Acknowledged. Moving to Step 4 (Triggers)..."
```

### ✅ Iterative Section-by-Section Collaboration
```
Main (in /analyze mode): "Let's start with Functional Requirements section FR-1... [proposes via IDE diff] [PAUSES - waits for user]"
User: Modifies FR-1, adds FR-1.1
Main (in /analyze mode): "I see you added FR-1.1 for OAuth. Makes sense given modern security expectations. Moving to FR-2... [proposes] [PAUSES - waits for user]"
```

## Session Management

**Main Conversation Responsibilities:**

Track all active sessions:
```
Active Slash Command Sessions:
- /model (paused): Awaiting user decision on command naming

Active Subagent Sessions:
- rust-domain-model-expert (paused): Awaiting user review of type strengthening proposal
- source-control-agent (active): Running quality gates before commit
```

**When to Resume vs. Launch Fresh:**

Resume existing session when:
- Continuing work after user collaboration pause
- Adding to prior research/analysis
- User provided answer to agent's question
- Agent explicitly requested pause

Launch fresh session when:
- First time working on a phase/task
- Agent's prior work is complete/irrelevant
- Need clean context for new work
- Previous session ended normally

## Integration with Existing Workflows

This collaboration model integrates with existing processes:

- **TDD_WORKFLOW.md:** Main agent (in `/tdd` mode) coordinates Red → Domain → Green cycle collaboratively
- **DOMAIN_MODELING.md:** Type design happens via main agent (in `/tdd` mode) coordination
- **EVENT_MODELING.md:** Each of 12 steps involves main agent (in `/model` mode) + user
- **DEPENDENCY_MANAGEMENT.md:** Dependency decisions via dependency-agent with verification
- **Git operations:** source-control-agent handles commits/PRs with quality gate verification

See specific process files for phase-specific collaboration details.

## Summary

**Key Mindset Shift:**

- **Old:** Agent does work → user approves/rejects
- **New:** Agent proposes → PAUSES → user modifies → agent resumes and acknowledges → iterate together

**Three-Way Collaboration:**

1. **Main Agent:** In facilitation mode (via slash commands) or launching specialist agents—researches, proposes, acknowledges, iterates
2. **Specialist Agents:** Provide domain expertise, return recommendations to main agent
3. **User:** Modify proposals, ask questions, make final decisions

**The user is not a reviewer. The user is a co-creator.**

Every design decision, architectural choice, and implementation approach should involve the user as an active participant. Main agent facilitates this collaboration using:

- Facilitation slash commands (enter focused mode for collaborative phases)
- Specialist agent coordination (launch experts via Task tool for domain guidance)
- IDE diff modification flow (user modifies proposals directly)
- QUESTION: comment protocol (user asks, main agent answers)
- Mandatory pause points (never finalize without user approval)
- Explicit acknowledgment (main agent recognizes and responds to user changes)

---

*This is pair programming with an AI, not delegation to an AI.*
