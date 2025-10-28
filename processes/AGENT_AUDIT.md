# Agent Audit and Categorization

**Date:** 2025-10-27
**Purpose:** Document the resumable subagent architecture with IDE diff collaboration model

## Architecture Overview

**All agents now have Write/Edit/NotebookEdit permissions but use IDE diff collaboration:**

- Agents propose changes via IDE diffs
- Agents PAUSE after proposals
- User modifies proposals in IDE, adds QUESTION: comments
- Main conversation RESUMES agent with user modifications
- Agent acknowledges changes, answers questions, iterates
- User accepts when satisfied

This replaces the old model where advisory agents had NO file permissions and had to return recommendations to main conversation.

## Categorization Framework

### Facilitator Subagents (Coordinate Long Phases)

**Purpose:** Actively facilitate collaborative work between user and specialist agents for entire phases

**Characteristics:**
- Have Write/Edit/NotebookEdit tools for IDE diff proposals
- Coordinate between specialist advisory agents and user
- Frequently pause/resume throughout long phases
- MUST use IDE diff collaboration flow
- NEVER finalize changes without user approval

**Examples:**
- requirements-facilitator (Phase 1)
- event-modeling-facilitator (Phase 2)
- architecture-facilitator (Phase 3)
- story-facilitator (Phase 6)
- tdd-facilitator (Phase 7)

**Flow:**
```
Main launches facilitator
→ Facilitator coordinates specialist consultations
→ Facilitator proposes via IDE diff
→ Facilitator PAUSES
→ User modifies in IDE
→ Main RESUMES facilitator with modifications
→ Facilitator acknowledges, iterates
→ Repeat until phase complete
```

### Specialist Advisory Subagents (Propose Changes)

**Purpose:** Domain-specific analysis and recommendations with IDE diff proposals

**Characteristics:**
- Have Write/Edit/NotebookEdit tools for IDE diff proposals
- Research, analyze, store findings in memento
- Propose changes via IDE diffs
- MUST pause after proposals
- NEVER finalize changes without user approval
- Usually short-lived sessions (single consultation)

**Count:** 29 agents

**Examples:**

**TDD & Implementation (6):**
- red-tdd-tester
- green-implementer
- rust-domain-model-expert
- python-domain-model-expert
- typescript-domain-model-expert
- elixir-domain-model-expert

**Planning & Requirements (7):**
- requirements-analyst
- story-planner
- story-architect
- ux-consultant
- adr-writer
- architecture-synthesizer
- design-system-architect

**Event Modeling (15):**
- event-modeling-pm
- event-modeling-architect
- event-modeling-step-0-functional-areas
- event-modeling-step-1-goal-event
- event-modeling-step-2-event-sequence
- event-modeling-step-3-commands
- event-modeling-step-4-triggers
- event-modeling-step-5-final-ui
- event-modeling-step-6-queries-projections
- event-modeling-step-7-projection-events
- event-modeling-step-8-event-data
- event-modeling-step-9-command-sources
- event-modeling-step-10-acceptance
- event-modeling-step-11-cross-linking
- event-modeling-step-12-completeness

**Validation (1):**
- acceptance-validator

**Flow:**
```
Main/facilitator launches specialist
→ Specialist researches/analyzes
→ Specialist proposes via IDE diff
→ Specialist PAUSES
→ User modifies in IDE
→ Main/facilitator RESUMES specialist
→ Specialist acknowledges, iterates
```

### Operational Subagents (Mechanical Operations)

**Purpose:** Mechanical operations with clear procedures and verification

**Characteristics:**
- Have Write/Edit/NotebookEdit for mechanical operations
- Execute well-defined procedures (not creative work)
- May use IDE diff collaboration for user review
- Some operations don't require pause (auto-formatting, auto-commits after verification)

**Count:** 10 agents

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
```
Main launches operational agent
→ Agent executes procedure
→ Agent verifies results
→ Agent may pause for user review if unclear
→ Agent returns results/status
```

## Total Agent Count

**Facilitator Subagents:** 5
**Specialist Advisory Subagents:** 29
**Operational Subagents:** 10
**Total:** 44 agents

## Key Differences from Old Model

### Old Model (October 2025 - Skills Era)
- Advisory agents had NO Write/Edit/NotebookEdit
- Advisory agents returned recommendations only
- Main conversation (via skills) did all file editing
- Skills executed in main conversation to preserve context

### Resumable Subagent Model (October 2025 - Current)
- ALL agents have Write/Edit/NotebookEdit
- ALL agents use IDE diff collaboration (propose → pause → user modifies → resume → acknowledge)
- Resumable sessions preserve context across pause/resume
- No more skills - all work via resumable subagents
- Main conversation coordinates sessions, not file editing

## Mandatory Protocols

All facilitator and specialist advisory agents MUST:

1. **Propose changes via IDE diff** - Use Write/Edit tools
2. **PAUSE immediately after proposal** - Return to main conversation
3. **Never finalize without user approval**
4. **Acknowledge user modifications** - When resumed, recognize what user changed
5. **Answer QUESTION: comments** - When user asks inline questions
6. **Iterate until consensus** - Keep proposing refined versions
7. **Store decisions in memento** - For future sessions

## Session Lifecycle

All agents operate within a resumable session lifecycle:

1. **LAUNCH**: Main creates new session via Task tool
2. **ACTIVE**: Agent working autonomously
3. **PAUSE**: Agent returns control, preserves context
4. **RESUME**: Main continues with new input, context restored
5. **COMPLETE**: Agent finishes, session ends
6. **ABANDONED**: Timeout/orphaned (auto-cleanup)

## Inter-Agent Communication

**Real-Time (Via Main Conversation Relay):**
- Agent A pauses with question for Agent B
- Main launches/resumes Agent B
- Agent B returns answer
- Main resumes Agent A with answer

**Async (Via Memento Knowledge Graph):**
- Agent A stores findings/decisions
- Agent B (later) retrieves via semantic search
- No direct coupling

## Quality Gates

All agents must follow collaboration quality checks:

**Before proposing:**
- [ ] Based on user input and preferences
- [ ] Prepared to acknowledge modifications
- [ ] Prepared to counterargue if concerns
- [ ] Can explain rationale
- [ ] Will PAUSE after proposal

**After being resumed:**
- [ ] Acknowledged what user changed
- [ ] Explained agreement or offered counterargument
- [ ] Answered QUESTION: comments
- [ ] Removed QUESTION: comments from next proposal
- [ ] Iterating toward consensus
- [ ] Storing decisions in memento

## Documentation

**Process Files:**
- COLLABORATION_PROTOCOLS.md - Core collaboration model
- TDD_WORKFLOW.md - TDD facilitator coordination
- EVENT_MODELING.md - Event modeling process
- STORY_PLANNING.md - Story facilitator coordination
- DOMAIN_MODELING.md - Domain modeling in TDD
- DEPENDENCY_MANAGEMENT.md - Dependency agent protocol

**Agent Files:**
- All 44 agent files in ~/.claude/agents/
- Each has Resume Capability Guidance section
- Each has IDE Diff Modification Flow section
- Each has QUESTION: Comment Protocol section

## Migration Complete

**Previous audit (2025-10-22):** Recommended removing Write/Edit/NotebookEdit from 28 advisory agents

**Current state (2025-10-27):** ALL agents have Write/Edit/NotebookEdit + mandatory IDE diff collaboration

This architecture combines:
- Context preservation (resumable sessions)
- User agency (IDE diff collaboration, QUESTION: comments)
- Operational efficiency (subagents for all operations)

---

**Audit Complete:** 2025-10-27
