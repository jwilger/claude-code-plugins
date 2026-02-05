# Tasks & Skills Integration Research

**Extract sdlc plugin's 10 shared protocols as portable skills, introduce lightweight orchestrator using task dependencies for mechanical workflow enforcement, and leverage task metadata for resumable state - enabling wider TDD pattern distribution while reducing context costs and supporting parallel development.**

## Version
v1

## Key Findings

- **Task system provides mechanical workflow enforcement**: Claude Code's built-in TaskCreate/TaskUpdate/TaskGet/TaskList tools enable structural dependencies (blockedBy) that mechanically prevent workflow violations, replacing prompt-based "invocation gates" with compile-time-like guarantees for TDD phase ordering.

- **Skills.sh format enables cross-agent protocol distribution**: The sdlc plugin's 10 shared protocols (tdd-constraints, orchestration, memory-protocol, etc.) are perfect candidates for extraction as SKILL.md files installable via npx skills, making TDD and domain modeling patterns available across Cursor, Windsurf, and other agent frameworks.

- **Three-layer architecture separates concerns cleanly**: Skills document principles (portable, what and why), tasks enforce structure (built-in, when and who), and hooks validate behavior (Claude Code-specific, how verified) - creating natural extraction boundaries for sdlc redesign.

- **Lightweight orchestrator with task graphs reduces overhead**: A dedicated orchestrator agent loading minimal skills and using TaskCreate/TaskUpdate to structure workflow enables lower context costs, parallel execution of independent task chains, and persistent workflow state across sessions compared to current synchronous pattern.

- **Task metadata enables resumption without external dependencies**: Storing workflow state (cycle number, files, phase, acceptance criteria) in task metadata provides sufficient context for resumption even without Memento MCP, separating workflow mechanics from domain knowledge storage.

## Decisions Needed

- Should invocation gates be fully removed or kept as defensive checks alongside task dependencies?
- Which agents should support self-assignment from TaskList vs explicit orchestrator spawning?
- Should mutation testing run in background tasks or remain foreground for interactivity?
- How much workflow state should live in task metadata vs Memento entities?

## Blockers

None - all research objectives completed with high confidence sources.

## Next Step

Create planning prompt (002-tasks-skills-plan.md) to design the sdlc plugin redesign architecture:
- Define skill extraction strategy (10 shared protocols → SKILL.md format)
- Design lightweight orchestrator agent with task-based coordination
- Map current invocation gates to task dependency graphs
- Specify task metadata schemas for TDD workflow state
- Plan incremental migration path from gates to tasks
- Design agent self-assignment patterns for autonomous operation
