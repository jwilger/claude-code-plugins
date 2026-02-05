# Tasks & Skills Integration Plan - Index

This directory contains the complete implementation plan for redesigning the sdlc plugin to maximize use of Claude Code's tasks system and extract reusable skills for skills.sh marketplace distribution.

## Documents

### 1. SUMMARY.md
**Quick overview of the entire redesign plan**
- One-paragraph plan summary
- Phase objectives at a glance
- Key architectural decisions
- Critical assumptions
- Next steps

**Read this first** for executive summary and high-level understanding.

### 2. tasks-skills-plan.md
**Comprehensive detailed implementation plan (35KB, 465 lines)**
- Full 7-phase breakdown with objectives, tasks, deliverables, dependencies, verification
- Detailed execution notes for complex phases
- Extensive metadata: confidence levels, dependencies, open questions, assumptions
- Complete plan in structured XML format

**Read this for implementation guidance** - contains everything needed to execute each phase.

**Structure:**
- `<summary>`: Overall approach
- `<phases>`: 7 phases with detailed tasks and deliverables
- `<metadata>`: Confidence, dependencies, open questions, assumptions

### 3. ROADMAP.md
**Visual timeline and dependency graph**
- ASCII dependency graph showing phase relationships
- Timeline estimates with effort per phase
- Critical path analysis (16 days minimum)
- Deliverables checklist by phase
- Risk mitigation strategies
- Success metrics for verification

**Read this for project planning** - understand sequencing, parallelization opportunities, and what to build when.

### 4. 002-tasks-skills-plan.md
**Original planning prompt (archived)**
- The prompt that generated this plan
- Kept for reference and reproducibility

## Plan Overview

### Three-Layer Architecture

The redesign separates concerns into three distinct layers:

1. **Skills (Teaching)** - Portable knowledge
   - SKILL.md files in top-level skills/ directory
   - Document principles: TDD constraints, orchestration patterns, domain modeling
   - Installable via npx skills add jwilger/sdlc-skills
   - Work across Claude Code, Cursor, Windsurf, and other agents

2. **Tasks (Structure)** - Built-in enforcement
   - Use Claude Code's TaskCreate/TaskUpdate/TaskList tools
   - Encode workflow dependencies: red → domain → green → domain
   - Persistent across sessions via task metadata
   - Replace prompt-based invocation gates with mechanical guarantees

3. **Hooks (Validation)** - Claude Code-specific
   - PreToolUse/PostToolUse/Stop hooks in agent definitions
   - Enforce constraints: red edits only test files, domain edits only types
   - Require verification evidence: paste test output, type check results
   - Remain in sdlc plugin (not extractable)

### Seven Phases

1. **Analysis & Extraction** (1-2 days)
   - Inventory 15 agents and 10 shared protocols
   - Map extraction candidates
   - Identify task-suitable workflows

2. **Skill Structure Design** (0.5-1 day)
   - Design skills/ directory and SKILL.md template
   - Define naming conventions and installation workflow

3. **Task Integration Pattern** (1-2 days)
   - Define task creation patterns
   - Design TDD workflow as task dependency graph
   - Plan invocation gate migration

4. **Skill Extraction** (3-5 days)
   - Extract 10 protocols to standalone SKILL.md files
   - Test portability across agent frameworks

5. **Agent Restructuring** (4-6 days)
   - Rewrite agents as lightweight skill loaders
   - Create orchestrator agent with task-based coordination
   - Update all 15+ agents to reference top-level skills/

6. **Marketplace Integration** (1-2 days)
   - Publish skills to top-level directory
   - Test npx skills installation
   - Submit to skills.sh marketplace

7. **Documentation & Migration** (2-3 days)
   - Create MIGRATION.md for v3.12.8 → v4.0.0 upgrade
   - Update all documentation
   - Bump versions to 4.0.0

**Total Effort:** 12-21 days depending on familiarity and iteration

## Key Benefits

**For sdlc Plugin Users:**
- Task-based progress tracking (see workflow state via TaskList)
- Resumable workflows across sessions (tasks + metadata persist)
- Clearer workflow discipline (task dependencies enforce order mechanically)
- Backward compatible (existing commands continue working)

**For Wider Community:**
- TDD and domain modeling principles available as standalone skills
- Installable via npx skills (simpler than full plugin)
- Portable across Claude Code, Cursor, Windsurf, and other agents
- Community can fork, adapt, and improve patterns

**For sdlc Plugin Maintainability:**
- Lightweight agents (skills loaded on demand, not duplicated)
- Clear separation of concerns (skills teach, tasks structure, hooks validate)
- Independent skill versioning (update protocols without agent changes)
- Reduced context costs (orchestrator loads minimal skills)

## Research Foundation

This plan is based on comprehensive research documented in:
`/home/jwilger/projects/claude-code-plugins/.prompts/001-tasks-skills-research/tasks-skills-research.md`

Research covered:
- Claude Code tasks system (TaskCreate, TaskUpdate, TaskGet, TaskList)
- skills.sh marketplace format and distribution
- Current sdlc plugin architecture (15 agents, 10 shared protocols)
- Integration patterns for skills + tasks + hooks
- Background task capabilities and limitations
- Portability across agent frameworks

## How to Use This Plan

**For Implementation:**
1. Start with SUMMARY.md to understand the overall approach
2. Read tasks-skills-plan.md Phase 1 in detail
3. Use ROADMAP.md to plan work schedule
4. Execute Phase 1, produce deliverables
5. Verify Phase 1 completion criteria
6. Proceed to Phase 2, repeat

**For Review:**
1. SUMMARY.md: Check if approach makes sense
2. tasks-skills-plan.md metadata: Review open questions and assumptions
3. ROADMAP.md: Validate timeline and risks
4. Provide feedback on key decisions before implementation begins

**For Project Management:**
1. ROADMAP.md deliverables checklist: Track progress
2. tasks-skills-plan.md verification criteria: Confirm phase completion
3. ROADMAP.md risk mitigation: Monitor and address risks
4. SUMMARY.md next steps: Know what to do next

## Questions or Feedback

**Open Questions** (from tasks-skills-plan.md metadata):
- Skill dependency mechanism (can SKILL.md reference other skills?)
- GitHub integration portability (how tool-specific should skills be?)
- Marvin personality location (plugin-specific or extractable?)
- Version migration for customizations (how to preserve user changes?)
- Task persistence across updates (do tasks survive v3 → v4 upgrade?)
- Skill namespace collision (how to resolve conflicts?)
- Background task MCP limitation (how to handle Memento in mutation agent?)

**Key Decisions Needed** (from SUMMARY.md):
- Repository structure (single repo, top-level directory, or separate repos?)
- Marvin output style (keep plugin-specific or extract as skill?)
- Skill-enforcement future (deprecate or keep as educational?)
- Mutation agent execution (background or foreground?)
- Task cleanup strategy (auto-delete, archive, or manual?)

## Version

- **Plan Version:** 1.0
- **Created:** 2026-02-04
- **Target sdlc Plugin Version:** 4.0.0 (from current 3.12.8)
- **Research Version:** tasks-skills-research.md (2026-02-04)

## Next Step

Execute Phase 1 by creating implementation prompt or directly producing Phase 1 deliverables:
- agents-inventory.md
- skills-extraction-map.md
- task-workflows.md
- external-integrations.md
