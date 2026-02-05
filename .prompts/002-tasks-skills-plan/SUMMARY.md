# sdlc Plugin Redesign Plan

This plan redesigns the sdlc plugin through 7 phases that extract 10 reusable protocol skills for skills.sh distribution, introduce task-based workflow orchestration using Claude Code's built-in task system, and restructure 15 agents as lightweight skill loaders while maintaining backward compatibility with existing command interfaces.

## Version
v1.0

## Phase Overview
1. **Analysis & Extraction**: Inventory 15 agents and 10 shared protocols to identify extractable components, map workflows suitable for task orchestration, and catalog integration patterns with gh CLI, git-spice, and Memento MCP.

2. **Skill Structure Design**: Design top-level skills/ directory structure with SKILL.md manifest format, define naming conventions and dependency mechanisms, plan npx skills installation workflow, and establish skill versioning independent of plugin versions.

3. **Task Integration Pattern**: Define when agents create tasks (multi-step workflows, TDD cycles), design task dependency graphs for red → domain → green → domain workflow, establish metadata conventions for resumption context, and plan migration from invocation gates to structural task dependencies.

4. **Skill Extraction**: Extract 10 shared protocols (tdd-constraints, orchestration-protocol, memory-protocol, user-input-protocol, event-modeling, github-issues, git-spice, debugging-protocol, atomic-design, skill-enforcement) to standalone SKILL.md files in skills/ directory, ensuring portability across agent frameworks.

5. **Agent Restructuring**: Rewrite agents as lightweight skill loaders, create new orchestrator agent with task-based coordination, update red/domain/green agents to reference top-level skills/, preserve hooks for constraint enforcement, and maintain backward compatibility with existing commands.

6. **Marketplace Integration**: Publish skills to top-level directory, test npx skills add installation, update marketplace.json, submit to skills.sh platform, create skill examples and documentation, and verify cross-framework portability.

7. **Documentation & Migration**: Create comprehensive MIGRATION.md for v3.12.8 → v4.0.0 upgrade, update CLAUDE.md with new architecture, document task workflows and skill usage, provide troubleshooting guide, and bump all version references.

## Key Decisions
- **Three-layer architecture**: Skills document portable principles, tasks enforce structural workflow order, hooks validate Claude Code-specific constraints - this separation enables wider distribution while maintaining sdlc's workflow discipline.

- **Backward compatibility**: Existing commands (/sdlc:work, /sdlc:review, etc.) continue working unchanged; task creation is internal implementation detail transparent to users; invocation gates coexist with tasks during migration.

- **Version bump to 4.0.0**: Skill extraction changes agent frontmatter (skills: field references), task integration changes orchestration model, breaking changes warrant major version bump per semver.

- **Incremental invocation gate migration**: Phase 1 (tasks + gates redundant), Phase 2 (TaskList primary, gates defensive), Phase 3 optional (full gate removal) - allows users to adopt at their own pace.

- **Lightweight orchestrator pattern**: New orchestrator agent uses Haiku model with TaskCreate/TaskUpdate/TaskList tools, disallows Write/Edit, loads minimal skills, spawns specialized subagents - reduces context costs while maintaining coordination.

## Critical Assumptions
- Task dependencies are strictly enforced by Claude Code (cannot start blocked tasks) - this provides mechanical workflow guarantees replacing prompt-based invocation gates.

- SKILL.md format is portable across Cursor, Windsurf, and other agent frameworks with minimal adaptation - enables wider distribution of TDD and domain modeling principles.

- Task metadata has sufficient size/capability for workflow resumption context (feature IDs, cycle numbers, file paths, checkpoint references) - reduces reliance on Memento MCP for state management.

- skills.sh marketplace will drive discovery and adoption of extracted skills - telemetry will validate which patterns get actual use beyond sdlc plugin users.

- Existing sdlc users accept breaking changes in v4.0.0 if migration guide is comprehensive and backward compatibility preserved for command interfaces.

## Decisions Needed
- **Repository structure**: Single jwilger/sdlc-skills repo with all 10 skills, or top-level skills/ directory in claude-code-plugins, or separate repos per skill? (Recommend: top-level skills/ for simplicity, single source of truth)

- **Marvin output style**: Keep as sdlc plugin-specific feature or extract personality as skill for wider use? (Recommend: keep plugin-specific, output styles are Claude Code feature)

- **Skill-enforcement future**: Deprecate entirely if tasks replace invocation gates, or keep as educational documentation of discipline patterns? (Recommend: keep but mark as optional/deprecated)

- **Mutation agent execution**: Run as background task (no MCP, store in metadata) or foreground (access Memento)? (Recommend: foreground initially, optimize to background after testing)

- **Task cleanup strategy**: Auto-delete completed tasks after N days, archive to file, or manual cleanup? (Recommend: manual cleanup initially, gather data on task accumulation)

## Blockers
None identified. All dependencies are available:
- Claude Code 2.1+ with task system (confirmed in research)
- skills CLI (npx skills) available and documented
- skills.sh platform accepting submissions (launched January 2026)
- Current sdlc plugin well-factored for extraction (10 shared protocols already separated)

## Next Step
Execute Phase 1 (analysis and extraction) by creating:
1. agents-inventory.md - detailed breakdown of all 15 agents with skills/tools/hooks
2. skills-extraction-map.md - mapping of 10 shared protocols to skill names and content
3. task-workflows.md - identification of /work, /review, /design commands for task orchestration
4. external-integrations.md - documentation of gh CLI, git-spice, Memento patterns

Alternative: Create implementation prompt for Phase 1 if delegating to another agent or session.
