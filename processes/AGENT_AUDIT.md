# Agent Audit and Categorization

**Date:** 2025-10-22
**Purpose:** Categorize all agents per collaboration-first model and remove file-edit permissions from advisory agents

## Categorization Framework

### Advisory Agents (NO File Edit Permissions)
- Research, analyze, recommend ONLY
- NO Write/Edit/NotebookEdit access
- Returns recommendations to main conversation
- Main conversation facilitates user collaboration on implementation

### Autonomous Agents (CAN Edit Files - Mechanical Only)
- Purely mechanical operations
- NO creative or design decisions
- Formatting, consistency, explicit user-directed edits only

### Skills (Not Agents)
- Execute in main conversation
- Permissions vary by purpose
- See skills/ directory

## Audit Results

### ADVISORY AGENTS (Remove Write/Edit/NotebookEdit)

#### Planning & Requirements (7 agents)

**requirements-analyst.md**
- **Category:** Advisory
- **Current tools:** Read, Edit, Write, TodoWrite, WebSearch, WebFetch, memento, NotebookEdit, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Should guide collaborative requirement capture, not write REQUIREMENTS_ANALYSIS.md autonomously

**story-planner.md**
- **Category:** Advisory
- **Current tools:** Read, TodoWrite, WebSearch, WebFetch, memento, beads tools, Edit, Write, NotebookEdit
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Should help plan stories collaboratively, not create beads issues autonomously (beads tools OK for issue management)

**adr-writer.md**
- **Category:** Advisory
- **Current tools:** Read, Edit, Write, Glob, Grep, WebSearch, WebFetch, memento, TodoWrite, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Should collaborate with user on ADR creation per collaboration protocols

**story-architect.md**
- **Category:** Advisory
- **Current tools:** Read, Edit, Write, Glob, Grep, WebSearch, WebFetch, memento, TodoWrite, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Provides technical review of stories, shouldn't autonomously modify them

**ux-consultant.md**
- **Category:** Advisory
- **Current tools:** Read, Glob, Grep, TodoWrite, memento, Edit, Write, NotebookEdit, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Provides UX guidance, user collaborates on actual design decisions

**architecture-synthesizer.md**
- **Category:** Advisory
- **Current tools:** Read, Edit, Write, Glob, Grep, WebSearch, WebFetch, memento, TodoWrite, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Synthesizes ADRs into ARCHITECTURE.md collaboratively, not autonomously

**design-system-architect.md**
- **Category:** Advisory
- **Current tools:** Read, Glob, Grep, Edit, Write, TodoWrite, memento, NotebookEdit, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Guides STYLE_GUIDE.md creation collaboratively using Atomic Design

#### Event Modeling (15 agents)

**event-modeling-pm.md**
- **Category:** Advisory
- **Current tools:** Read, Edit, Write, TodoWrite, WebSearch, WebFetch, memento, Glob, Grep, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Reviews event models from business perspective, provides feedback for collaborative refinement

**event-modeling-architect.md**
- **Category:** Advisory
- **Current tools:** Read, Edit, Write, Glob, Grep, WebSearch, WebFetch, memento, TodoWrite, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Reviews event models from technical perspective, provides feedback for collaborative refinement

**event-modeling-step-0-functional-areas.md**
- **Category:** Advisory
- **Current tools:** Read, Write, Edit, Glob, Grep, TodoWrite, WebSearch, WebFetch, memento, NotebookEdit, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Helps identify functional areas, user collaborates on actual organization

**event-modeling-step-1-goal-event.md**
- **Category:** Advisory
- **Current tools:** Read, Write, Edit, Glob, Grep, TodoWrite, WebSearch, WebFetch, memento, NotebookEdit, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Guides goal event identification collaboratively

**event-modeling-step-2-event-sequence.md**
- **Category:** Advisory
- **Current tools:** Read, Write, Edit, Glob, Grep, TodoWrite, WebSearch, WebFetch, memento, NotebookEdit, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Guides event sequence design collaboratively

**event-modeling-step-3-commands.md**
- **Category:** Advisory
- **Current tools:** Read, Write, Edit, Glob, Grep, TodoWrite, WebSearch, WebFetch, memento, NotebookEdit, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Guides command definition collaboratively

**event-modeling-step-4-triggers.md**
- **Category:** Advisory
- **Current tools:** Read, Write, Edit, Glob, Grep, TodoWrite, WebSearch, WebFetch, memento, NotebookEdit, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Guides trigger identification collaboratively

**event-modeling-step-5-final-ui.md**
- **Category:** Advisory
- **Current tools:** Read, Write, Edit, Glob, Grep, TodoWrite, WebSearch, WebFetch, memento, NotebookEdit, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Guides UI wireframe creation collaboratively

**event-modeling-step-6-queries-projections.md**
- **Category:** Advisory
- **Current tools:** Read, Write, Edit, Glob, Grep, TodoWrite, WebSearch, WebFetch, memento, NotebookEdit, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Guides projection/query design collaboratively

**event-modeling-step-7-projection-events.md**
- **Category:** Advisory
- **Current tools:** Read, Write, Edit, Glob, Grep, TodoWrite, WebSearch, WebFetch, memento, NotebookEdit, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Guides event-to-projection mapping collaboratively

**event-modeling-step-8-event-data.md**
- **Category:** Advisory
- **Current tools:** Read, Write, Edit, Glob, Grep, TodoWrite, WebSearch, WebFetch, memento, NotebookEdit, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Guides event data definition collaboratively

**event-modeling-step-9-command-sources.md**
- **Category:** Advisory
- **Current tools:** Read, Write, Edit, Glob, Grep, TodoWrite, WebSearch, WebFetch, memento, NotebookEdit, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Guides command source documentation collaboratively

**event-modeling-step-10-acceptance.md**
- **Category:** Advisory
- **Current tools:** Read, Write, Edit, Glob, Grep, TodoWrite, WebSearch, WebFetch, memento, NotebookEdit, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Guides Gherkin acceptance criteria collaboratively

**event-modeling-step-11-cross-linking.md**
- **Category:** Advisory
- **Current tools:** Read, Write, Edit, Glob, Grep, TodoWrite, WebSearch, WebFetch, memento, NotebookEdit, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Guides cross-reference creation collaboratively

**event-modeling-step-12-completeness.md**
- **Category:** Advisory
- **Current tools:** Read, Write, Edit, Glob, Grep, TodoWrite, WebSearch, WebFetch, memento, NotebookEdit, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Validates completeness, provides feedback for collaborative fixes

#### TDD & Implementation (6 agents)

**red-tdd-tester.md**
- **Category:** Advisory
- **Current tools:** Read, Write, Edit, Glob, Grep, TodoWrite, memento, cargo, pytest, WebFetch, WebSearch, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Analyzes and recommends test approach, main conversation collaborates with user on actual test code

**green-implementer.md**
- **Category:** Advisory
- **Current tools:** Read, Write, Edit, Glob, Grep, TodoWrite, memento, cargo, pytest, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Recommends implementation approach, main conversation collaborates with user on actual code

**rust-domain-model-expert.md**
- **Category:** Advisory
- **Current tools:** memento, Glob, Grep, Read, Edit, Write, NotebookEdit, WebFetch, TodoWrite, WebSearch, cargo, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Analyzes types and recommends domain model improvements, main conversation collaborates on implementation

**python-domain-model-expert.md**
- **Category:** Advisory
- **Current tools:** memento, Glob, Grep, Read, Edit, Write, NotebookEdit, WebFetch, TodoWrite, WebSearch, pytest, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Analyzes types and recommends domain model improvements, main conversation collaborates on implementation

**typescript-domain-model-expert.md**
- **Category:** Advisory
- **Current tools:** memento, Glob, Grep, Read, WebFetch, TodoWrite, WebSearch, Edit, Write, NotebookEdit, Bash, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Analyzes types and recommends domain model improvements, main conversation collaborates on implementation

**elixir-domain-model-expert.md**
- **Category:** Advisory
- **Current tools:** memento, Glob, Grep, Read, WebFetch, TodoWrite, WebSearch, Edit, Write, NotebookEdit, etc.
- **Action:** REMOVE Write, Edit, NotebookEdit
- **Rationale:** Analyzes types and recommends domain model improvements, main conversation collaborates on implementation

#### Research & Validation (2 agents)

**research-specialist.md**
- **Category:** Advisory
- **Current tools:** Read, Glob, Grep, WebSearch, WebFetch, BashOutput, memento, time
- **Action:** KEEP AS-IS (already has NO Write/Edit/NotebookEdit)
- **Rationale:** Already correctly configured as advisory-only

**acceptance-validator.md**
- **Category:** Advisory
- **Current tools:** Read, TodoWrite, memento, Glob, Grep, WebFetch, WebSearch, BashOutput, pytest, etc.
- **Action:** KEEP AS-IS (no Write/Edit in tools list)
- **Rationale:** Validates requirements, provides verification report to main conversation

### AUTONOMOUS AGENTS (Keep File Permissions - Mechanical Only)

**technical-documentation-writer.md**
- **Category:** Autonomous (Mechanical)
- **Current tools:** Edit, Write, NotebookEdit, Read, Glob, Grep, TodoWrite, memento, WebFetch, WebSearch, etc.
- **Action:** KEEP Write, Edit, NotebookEdit BUT clarify constraints
- **Rationale:** Handles formatting/consistency fixes only, NO content creation
- **Constraint Update Needed:** Emphasize mechanical fixes only, no creative writing

**devops.md**
- **Category:** Autonomous (Mechanical)
- **Current tools:** Bash, Glob, Grep, Read, Edit, Write, NotebookEdit, WebFetch, TodoWrite, WebSearch, etc.
- **Action:** KEEP Write, Edit, NotebookEdit for infrastructure configs
- **Rationale:** Handles infrastructure setup following established patterns
- **Note:** Infrastructure decisions should still be collaborative

**file-editor.md**
- **Category:** Autonomous (User-Directed)
- **Current tools:** Read, Write, Edit, NotebookEdit, Glob, Grep, memento, WebFetch, TodoWrite, WebSearch, etc.
- **Action:** KEEP Write, Edit, NotebookEdit
- **Rationale:** Executes explicit user file-edit requests only
- **Constraint:** ONLY for direct user requests like "fix this typo"

**dependency-management.md**
- **Category:** Autonomous (Mechanical)
- **Current tools:** Bash, Read, KillShell, memento, time, BashOutput, cargo, etc.
- **Action:** KEEP AS-IS (no Write/Edit in agent, uses Bash for dep files)
- **Rationale:** Manages dependencies using platform tooling (cargo/uv/npm)
- **Note:** Dependency decisions should be collaborative, execution can be automated

## Summary

### Advisory Agents Requiring Permission Removal: 28

**Planning/Requirements:**
- requirements-analyst
- story-planner
- adr-writer
- story-architect
- ux-consultant
- architecture-synthesizer
- design-system-architect

**Event Modeling:**
- event-modeling-pm
- event-modeling-architect
- event-modeling-step-0 through step-12 (13 agents)

**TDD/Implementation:**
- red-tdd-tester
- green-implementer
- rust-domain-model-expert
- python-domain-model-expert
- typescript-domain-model-expert
- elixir-domain-model-expert

**Already Correct:**
- research-specialist (already advisory-only)
- acceptance-validator (already advisory-only)

### Autonomous Agents Keeping Permissions: 4

- technical-documentation-writer (mechanical formatting only)
- devops (infrastructure configs)
- file-editor (user-directed edits only)
- dependency-management (dependency tooling automation)

## Implementation Plan

For each advisory agent requiring changes:

1. Remove from tools list: `Write, Edit, NotebookEdit`
2. Add to agent instructions:
   - "You are an ADVISORY agent - research and recommend ONLY"
   - "NO file editing - return recommendations to main conversation"
   - "Main conversation facilitates user collaboration on implementation"
3. Reference COLLABORATION_PROTOCOLS.md

For autonomous agents:

1. Clarify mechanical-only constraints
2. Reference when creative decisions need collaboration
3. Document specific use cases where autonomy is appropriate

## Next Steps

1. Update all 28 advisory agent files to remove Write/Edit/NotebookEdit
2. Update autonomous agent files to clarify constraints
3. Verify system-prompt.md reflects new permission model
4. Test with sample workflow to ensure collaboration flow works
5. Document in COLLABORATION_PROTOCOLS.md

---

**Audit Complete:** 2025-10-22
