# Claude Code Tasks System & Skills Architecture Research

**Research Date:** 2026-02-04
**Objective:** Understand how to integrate Claude Code's tasks system into agent workflows and extract reusable skills from the sdlc plugin.

<research>
  <summary>
    Claude Code's tasks system (TaskCreate, TaskUpdate, TaskGet, TaskList) provides mechanical workflow enforcement through task dependencies, complementing the skills.sh marketplace format for distributing reusable agent knowledge. The sdlc plugin is well-positioned for redesign: extract 10 shared protocols as portable skills installable via npx skills, retain 15 specialized agents with hooks in the plugin, and introduce a lightweight orchestrator that uses task dependencies to replace prompt-based "invocation gates." This layered approach separates concerns - skills document principles (portable), tasks enforce structure (built-in), and hooks validate behavior (Claude Code-specific) - enabling both wider distribution of TDD/domain modeling patterns and more robust workflow management.

    The research reveals a clear integration pattern: lightweight agents load skills for knowledge, create task graphs for structure, spawn heavy subagents for specialized work, and use task metadata for resumption context. This reduces context costs (skills loaded only where needed), enables parallel execution (independent tasks run concurrently), and provides persistent workflow state across sessions. The current sdlc plugin's synchronous orchestrator-driven workflow can evolve into an asynchronous task-based coordination model where agents self-assign from TaskList, particularly valuable for the worktree parallel development pattern.

    Key architectural insight: The distinction between "teaching" (skills), "structuring" (tasks), and "validating" (hooks) creates natural extraction boundaries. Skills.sh-compatible SKILL.md files document reusable protocols. Task dependencies enforce phase ordering mechanically (no prompt engineering needed). Hooks validate agent behavior (file type constraints, verification requirements). This three-layer model enables the sdlc plugin to distribute core TDD knowledge widely while keeping enforcement mechanisms tightly integrated with Claude Code.
  </summary>

  <findings>
    <finding category="tasks-system">
      <title>Claude Code Tasks System is Built-In and Fully Functional</title>
      <detail>
        Claude Code 2.1+ includes native task management with TaskCreate, TaskUpdate, TaskGet, and TaskList tools. These are first-class built-in tools available to all agents (not MCP servers). The system enables:

        - Task lifecycle: pending → in_progress → completed
        - Task dependencies: addBlockedBy/addBlocks parameters
        - Task metadata: arbitrary key-value storage for tracking associations
        - Cross-session coordination via CLAUDE_CODE_TASK_LIST_ID environment variable
        - Parallel task execution (background vs foreground)
        - Visual indicators: ✓ (completed), ◻ (open), ▲ (blocked)

        Key parameters from tool definitions:
        - TaskCreate: subject (brief title), description (detailed requirements), activeForm (present continuous for spinner), metadata (arbitrary tracking)
        - TaskUpdate: status transitions, owner assignment, dependency management (addBlocks/addBlockedBy)
        - TaskGet: retrieve full task details including dependencies
        - TaskList: summary view of all tasks with status/owner/blockedBy

        When to use tasks (from tool documentation):
        - Complex multi-step tasks (3+ distinct steps)
        - Non-trivial complex tasks requiring planning
        - Plan mode workflows
        - User explicitly requests todo list
        - User provides multiple tasks

        When NOT to use tasks:
        - Single straightforward tasks
        - Trivial tasks (less than 3 steps)
        - Purely conversational/informational work
      </detail>
      <source>
        - Claude Code tool definitions (TaskCreate, TaskUpdate, TaskGet, TaskList)
        - https://medium.com/@richardhightower/claude-code-todos-to-tasks-5a1b0e351a1c
        - https://claudefa.st/blog/guide/development/task-management
        - https://code.claude.com/docs/en/how-claude-code-works
      </source>
      <relevance>
        The sdlc plugin's complex multi-agent TDD workflow (red → domain → green → domain → refactor) is a perfect candidate for task-based orchestration. Each phase could be a task with dependencies, enabling:
        - Clear progress tracking through TDD cycles
        - Explicit workflow state (preventing agents from skipping steps)
        - Resumable workflows across sessions
        - Parallel development support (multiple slices in separate worktrees)

        The task system could replace the current "invocation gate" pattern where agents check for context declarations - tasks provide that context natively.
      </relevance>
    </finding>

    <finding category="tasks-system">
      <title>Task Tool Schemas Are Well-Defined with Clear Patterns</title>
      <detail>
        From the tool definitions in my system prompt:

        TaskCreate parameters:
        - subject (required): "A brief title for the task" - imperative form (e.g., "Fix authentication bug")
        - description (required): "A detailed description of what needs to be done"
        - activeForm (optional but recommended): Present continuous shown in spinner (e.g., "Fixing authentication bug")
        - metadata (optional): "Arbitrary metadata to attach to the task" - JSON object

        TaskUpdate parameters:
        - taskId (required): ID of task to update
        - status: 'pending', 'in_progress', 'completed', or 'deleted'
        - subject, description, activeForm: Can be updated
        - owner: Change task owner (agent name)
        - metadata: Merge keys (set to null to delete)
        - addBlocks: Task IDs this task blocks
        - addBlockedBy: Task IDs that block this task

        TaskGet:
        - Returns full task details including blocks/blockedBy arrays

        TaskList:
        - Returns summary: id, subject, status, owner, blockedBy

        Critical patterns:
        - Tasks progress: pending → in_progress → completed (no backwards transitions except deleted)
        - Dependencies are directional: "A blocks B" means B cannot start until A completes
        - Owner field enables task assignment to specific agents
        - Metadata enables custom tracking (e.g., feature association, phase tracking)
      </detail>
      <source>
        Tool definitions from Claude Code system prompt (directly observable)
      </source>
      <relevance>
        The well-defined schemas enable reliable task-based workflows. For sdlc redesign:
        - subject/activeForm distinction maps to TDD phase names ("Write failing test" vs "Writing failing test")
        - metadata can track: slice number, acceptance criterion index, cycle number
        - addBlockedBy enforces workflow order (green blocked by red, domain review blocked by both)
        - owner field enables assigning tasks to specific agents (red, green, domain)

        This provides compile-time-like guarantees for workflow correctness.
      </relevance>
    </finding>

    <finding category="tasks-system">
      <title>Background Tasks Enable True Parallel Agent Execution</title>
      <detail>
        Tasks can run in foreground (blocking) or background (concurrent):

        Foreground tasks:
        - Block main conversation until complete
        - Permission prompts passed through to user
        - Clarifying questions (AskUserQuestion) work normally

        Background tasks:
        - Run concurrently with main conversation
        - Pre-approve all permissions upfront (before launch)
        - Auto-deny any unpre-approved permissions
        - AskUserQuestion calls fail (agent continues)
        - No MCP tool access
        - Resume-in-foreground available if permissions needed

        Control:
        - Claude decides foreground/background based on task
        - User can request "run this in the background"
        - Ctrl+B to background a running task
        - CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1 to disable entirely
      </detail>
      <source>
        https://code.claude.com/docs/en/sub-agents.md (subagent documentation - background task section)
      </source>
      <relevance>
        Background tasks enable true parallel development for the sdlc worktree workflow:
        - Multiple slices can progress independently (each in own worktree)
        - Long-running mutation tests can run in background
        - Code review stages could run concurrently
        - Discovery/research tasks don't block implementation

        However, limitations matter:
        - No AskUserQuestion in background = need clear requirements upfront
        - No MCP = Memento integration requires foreground or pre-loading
        - Permission pre-approval = tasks must be well-scoped

        The sdlc plugin's current synchronous workflow could be partially parallelized where slices are independent.
      </relevance>
    </finding>

    <finding category="skills-format">
      <title>Skills Use SKILL.md Format with YAML Frontmatter</title>
      <detail>
        Skills are defined in SKILL.md files with YAML frontmatter + markdown body:

        Required frontmatter fields:
        - name: Unique identifier (lowercase, hyphens allowed)
        - description: Brief explanation of skill's purpose

        Optional frontmatter fields:
        - metadata.internal: true (hide from normal discovery)

        File structure:
        ```markdown
        ---
        name: my-skill
        description: What this skill does
        ---

        # My Skill

        Instructions and guidance for the agent.
        ```

        Installation:
        - npx skills add &lt;owner&gt;/&lt;repo&gt; - Install entire skill package
        - npx skills add &lt;owner&gt;/&lt;repo&gt; --skill "specific-skill" - Install one skill
        - Supports: GitHub shortcuts, full URLs, GitLab, git URLs, local paths
        - Scope: Project (.claude/skills/) or Global (~/.claude/skills/)
        - Methods: Symlink (recommended) or copy

        Discovery:
        - System searches for SKILL.md in: skills/, .claude/skills/, agent-specific dirs
        - Also checks paths in .claude-plugin/marketplace.json

        Key distinction from subagents:
        - Subagents: YAML frontmatter + system prompt (runs in isolated context)
        - Skills: YAML frontmatter + instructions (loaded into agent's context)
        - Subagents spawn separate instances, skills inject into current context
      </detail>
      <source>
        - https://github.com/vercel-labs/skills (official skills CLI)
        - https://skills.sh/docs
        - https://code.claude.com/docs/en/sub-agents.md (skills field in subagent frontmatter)
      </source>
      <relevance>
        The sdlc plugin's "shared" commands (orchestration.md, tdd-constraints.md, etc.) are already skill-like but locked into the plugin. Converting them to standalone skills enables:
        - Cross-agent reuse (not just sdlc agents)
        - Independent versioning and distribution
        - Installation via npx skills (simpler than full plugin)
        - Composition: agents can load only the skills they need

        Current sdlc structure already separates reusable patterns (commands/shared/) from agent-specific logic, making extraction straightforward.
      </relevance>
    </finding>

    <finding category="skills-format">
      <title>Skills Load Into Agent Context, Not Separate Execution</title>
      <detail>
        Critical distinction between skills and subagents:

        Skills (instruction injection):
        - Loaded into agent's context at startup or on-demand
        - Full skill content injected as instructions
        - No separate execution environment
        - Agent sees skill content as part of its system prompt
        - Used for: patterns, protocols, domain knowledge, workflows

        Subagents (separate execution):
        - Run in isolated context window
        - Own system prompt, tool access, permissions
        - Spawn separate instances via Task tool
        - Return summary to parent
        - Used for: delegated work, context isolation, tool restrictions

        Subagent skills field:
        ```yaml
        name: api-developer
        skills:
          - api-conventions
          - error-handling-patterns
        ```
        This injects skill content into the subagent's context (not parent's).

        Skills in main conversation:
        - Skills are invoked via Skill tool or auto-loaded
        - Descriptions visible at session start
        - Full content loads on first use (lazy loading)
        - disable-model-invocation: true keeps descriptions out of context until manual invocation

        Skills.sh installation:
        - Creates symlinks/copies in .claude/skills/ or ~/.claude/skills/
        - Claude Code discovers via standard search paths
        - No plugin manifest required for basic skills
      </detail>
      <source>
        - https://code.claude.com/docs/en/sub-agents.md (skills vs subagents)
        - https://github.com/vercel-labs/skills (CLI installation mechanics)
        - https://code.claude.com/docs/en/how-claude-code-works (context and skills section)
      </source>
      <relevance>
        This distinction clarifies the sdlc redesign strategy:

        Extract as SKILLS (not subagents):
        - TDD constraints (red/green/domain phase rules)
        - Orchestration protocols (workflow state management)
        - Memory protocols (memento integration patterns)
        - User input protocols (checkpoint/question format)
        - Event modeling patterns
        - Debugging protocols
        - Git-spice workflows

        Keep as SUBAGENTS:
        - red, green, domain (need isolated context + hooks)
        - code-reviewer, mutation, story (delegated execution)
        - architect, ux, discovery (research tasks)

        The lightweight "orchestrator" agent can auto-load skills without spawning subagents, reducing context costs.
      </relevance>
    </finding>

    <finding category="skills-format">
      <title>Skills Are Portable Across Multiple Agent Frameworks</title>
      <detail>
        The skills.sh ecosystem is designed for cross-agent compatibility:

        Supported agents (35+):
        - Claude Code
        - Cursor
        - Windsurf
        - GitHub Copilot
        - Cline
        - OpenCode
        - Goose
        - Many others

        Standardization:
        - Agent Skills standard originated by Anthropic
        - Open format (SKILL.md with YAML frontmatter)
        - skills CLI works across all agents
        - Each agent has designated search paths

        Platform features:
        - skills.sh: Central directory and leaderboard
        - Anonymous telemetry tracks installs (no personal data)
        - Trending and all-time install counts
        - Security audits for malicious content
        - Launched January 20, 2026 by Vercel

        Distribution model:
        - Skills live in GitHub repos
        - Install from any source (not just skills.sh)
        - Marketplace is discovery layer, not gatekeep
      </detail>
      <source>
        - https://skills.sh/ (official platform)
        - https://github.com/vercel-labs/skills (CLI repo)
        - https://vercel.com/changelog/introducing-skills-the-open-agent-skills-ecosystem
        - https://www.toolworthy.ai/tool/skills-sh (review)
      </source>
      <relevance>
        Extracting sdlc workflows as skills provides:
        - Portability: TDD patterns work in Cursor, Windsurf, etc.
        - Discoverability: skills.sh leaderboard increases reach
        - Adoption: Lower barrier than full plugin install
        - Telemetry: Track which patterns get actual use
        - Community: Others can fork and adapt patterns

        The sdlc plugin's domain modeling principles, TDD constraints, and orchestration patterns are valuable beyond just Claude Code users. Skills format enables wider distribution.

        However: Hooks and subagent definitions remain Claude Code-specific (keep in plugin).
      </relevance>
    </finding>

    <finding category="sdlc-analysis">
      <title>SDLC Plugin Has Clear Agent/Command Separation</title>
      <detail>
        Current sdlc plugin structure (v3.12.8):

        **15 Agents** (subagent definitions):
        1. red.md - TDD red phase (write failing tests)
        2. green.md - TDD green phase (minimal implementation)
        3. domain.md - Domain modeling and type definitions
        4. mutation.md - Mutation testing
        5. code-reviewer.md - Three-stage code review
        6. story.md - User story breakdown
        7. architect.md - Architecture documentation
        8. ux.md - UX design and prototyping
        9. discovery.md - Discovery and research
        10. workflow-designer.md - Event modeling workflows
        11. model-checker.md - Event model validation
        12. design-facilitator.md - Event modeling facilitation
        13. gwt.md - Given/When/Then scenario writing
        14. adr.md - Architecture Decision Records
        15. file-updater.md - General file updates

        **11 Commands** (user-facing):
        - setup.md - Initial configuration
        - start.md - Start new feature/slice
        - work.md - Work on GitHub issue
        - pr.md - Create pull request
        - review.md - Code review workflow
        - design.md - Event modeling session
        - plan.md - Planning workflow
        - adr.md - Record architectural decision
        - remember.md - Store memory
        - recall.md - Retrieve memory
        - domain-audit.md - Domain integrity check

        **10 Shared Commands** (skill-like patterns):
        1. orchestration.md - Agent delegation rules
        2. memory-protocol.md - Memento integration
        3. event-modeling.md - Event modeling patterns
        4. atomic-design.md - UI component patterns
        5. github-issues.md - GitHub integration
        6. user-input-protocol.md - Checkpoint/question format
        7. tdd-constraints.md - Phase boundary rules
        8. git-spice.md - Git-spice workflow
        9. skill-enforcement.md - Invocation discipline
        10. debugging-protocol.md - Debugging patterns

        The shared commands are already extracted as reusable protocols - perfect candidates for skills.
      </detail>
      <source>
        /home/jwilger/projects/claude-code-plugins/sdlc/.claude-plugin/plugin.json
        Directory structure analysis
      </source>
      <relevance>
        The sdlc plugin is already well-factored for extraction:

        Keep as plugin (Claude Code-specific):
        - 15 agent definitions (use hooks, tool restrictions)
        - User-facing commands (setup, work, pr, review, etc.)
        - Output styles (marvin-sdlc)
        - Integration with gh CLI, git-spice

        Extract as standalone skills:
        - 10 shared command protocols
        - Can be installed via npx skills
        - Reusable across agent frameworks
        - Composable (agents load only what they need)

        The separation is clean - shared commands have "user-invocable: false" and are already designed as protocol documentation, not executable commands.
      </relevance>
    </finding>

    <finding category="sdlc-analysis">
      <title>SDLC Agents Use Hooks Extensively for Workflow Enforcement</title>
      <detail>
        The red and domain agents use hooks to enforce TDD discipline:

        red agent hooks:
        - PreToolUse (Edit): Verify file is a test file, block production code
        - PreToolUse (Write): Verify creating test file only
        - PostToolUse (Edit/Write): Require running tests and pasting output
        - Stop: Store test patterns in memento before completing

        domain agent hooks:
        - PreToolUse (Edit/Write): Verify only editing type definitions (not implementations)
        - PostToolUse (Edit/Write): Require running type checker and pasting output
        - Stop: Store domain modeling decisions in memento

        Hook types used:
        - type: prompt (LLM evaluates and returns JSON)
        - type: command (not used in current agents, but available)

        Pattern: Hooks enforce constraints that can't be expressed via tool restrictions alone. For example, domain agent has Edit tool but hooks ensure it only edits type signatures, not function bodies.

        All hooks return {"ok": true} or {"ok": false, "reason": "..."} for prompt-based hooks.
      </detail>
      <source>
        /home/jwilger/projects/claude-code-plugins/sdlc/agents/red.md (lines 20-112)
        /home/jwilger/projects/claude-code-plugins/sdlc/agents/domain.md (lines 20-113)
      </source>
      <relevance>
        Hooks are critical to sdlc's workflow enforcement and cannot be extracted as skills:
        - Hooks are Claude Code-specific features
        - They prevent workflow violations (red writing production code, domain implementing bodies)
        - They enforce verification (running tests, type checking)
        - They create audit trails (storing decisions in memento)

        For redesign:
        - Keep hooks in subagent definitions (part of plugin)
        - Skills can document the PRINCIPLES (what should be checked)
        - Hooks ENFORCE the principles (how to check)

        The invocation gate pattern (context declarations) could potentially be replaced with task dependencies, but hooks provide finer-grained enforcement.
      </relevance>
    </finding>

    <finding category="sdlc-analysis">
      <title>SDLC Uses "Invocation Gate" Pattern for Workflow State Management</title>
      <detail>
        The sdlc plugin enforces workflow state through "invocation gates" - agents require explicit context declarations before proceeding.

        Red agent gate (one of three required):
        ```
        RED_CONTEXT: FIRST_TEST
        ACCEPTANCE_CRITERIA: [...]

        RED_CONTEXT: CONTINUING
        PREVIOUS_CYCLE_COMPLETE: [...]

        RED_CONTEXT: DRILL_DOWN
        PARENT_TEST: [...]
        ```

        Domain agent gate (one of three required):
        ```
        DOMAIN_CONTEXT: AFTER_RED
        RED_PHASE_COMPLETE: [...]

        DOMAIN_CONTEXT: AFTER_GREEN
        GREEN_PHASE_COMPLETE: [...]

        DOMAIN_CONTEXT: PR_REVIEW
        PR_SCOPE: [...]
        ```

        Green agent gate (both required):
        ```
        RED_PHASE_COMPLETE: [...]
        DOMAIN_CHECK_PASSED: [...]
        ```

        If gate validation fails, agent returns:
        ```
        INVOCATION GATE FAILED
        [Details of missing context]
        ```

        Purpose:
        - Prevents invoking green before test exists
        - Prevents invoking green before domain review
        - Prevents invoking red before previous cycle completes
        - Forces orchestrator to maintain explicit workflow state

        This is a "prompt engineering" solution to workflow discipline.
      </detail>
      <source>
        /home/jwilger/projects/claude-code-plugins/sdlc/agents/red.md (lines 126-188)
        /home/jwilger/projects/claude-code-plugins/sdlc/agents/domain.md (lines 129-189)
        /home/jwilger/projects/claude-code-plugins/sdlc/commands/shared/orchestration.md (lines 226-323)
      </source>
      <relevance>
        The invocation gate pattern solves a real problem (maintaining workflow state) but could be replaced with task dependencies:

        Current approach (gates):
        - Orchestrator declares context in prompt
        - Agent validates context, rejects if invalid
        - Manual discipline required
        - No persistent state between sessions

        Task-based approach (dependencies):
        - Each phase is a task with blockedBy relationships
        - TaskList shows current workflow state
        - Cannot start task until dependencies complete
        - State persists across sessions via CLAUDE_CODE_TASK_LIST_ID

        Example mapping:
        - RED_CONTEXT: FIRST_TEST → TaskCreate "Write first test" (no dependencies)
        - DOMAIN_CONTEXT: AFTER_RED → TaskCreate "Review test and create types" (blockedBy: red task)
        - GREEN_PHASE → TaskCreate "Implement to pass test" (blockedBy: domain task)

        Tasks provide mechanical enforcement (cannot start blocked task) vs gates provide prompt-based checking.
      </relevance>
    </finding>

    <finding category="sdlc-analysis">
      <title>SDLC Agents Pre-Load Skills and Use Memento MCP</title>
      <detail>
        Current agent pattern (from red.md):
        ```yaml
        name: red
        skills:
          - sdlc:shared/user-input-protocol
          - sdlc:shared/memory-protocol
          - sdlc:shared/tdd-constraints
        tools:
          - Read, Write, Edit, Bash, Glob, Grep
          - mcp__memento__semantic_search
          - mcp__memento__create_entities
          - mcp__memento__open_nodes
          - mcp__memento__create_relations
        ```

        Pattern:
        - Agents pre-load skills into context (not lazy)
        - MCP tools explicitly allowed (memento for memory)
        - Skills are namespaced: sdlc:shared/protocol-name

        Memory protocol usage:
        - PostToolUse hooks store decisions in memento
        - Agents search memento for context before starting work
        - Orchestrator queries memento for work session continuity

        Skills vs MCP:
        - Skills: Static knowledge (protocols, patterns)
        - MCP: Dynamic operations (store/retrieve memories)
        - Both injected into agent context
      </detail>
      <source>
        /home/jwilger/projects/claude-code-plugins/sdlc/agents/red.md (lines 1-19)
        /home/jwilger/projects/claude-code-plugins/sdlc/agents/domain.md (lines 1-19)
      </source>
      <relevance>
        This reveals the integration pattern for skills + MCP + tasks:

        Lightweight agent pattern:
        ```yaml
        name: orchestrator
        skills:
          - tdd-constraints          # From skills.sh
          - orchestration-protocol   # From skills.sh
          - memory-protocol          # From skills.sh
        tools:
          - TaskCreate, TaskUpdate, TaskGet, TaskList
          - Task (for spawning subagents)
          - mcp__memento__*
        ```

        The orchestrator loads protocols as skills, uses Task tool to spawn heavy agents (red, green, domain), and uses TaskList to track workflow state.

        Skills provide knowledge, tasks provide structure, subagents provide execution, MCP provides memory.

        This is the integration model: skills + tasks + subagents + MCP = complete workflow.
      </relevance>
    </finding>

    <finding category="sdlc-analysis">
      <title>SDLC Orchestration Has No File Edit Capabilities (Delegation Only)</title>
      <detail>
        From orchestration.md (lines 60-73):
        ```markdown
        ## File Operations (MANDATORY DELEGATION)

        The main conversation **MUST NEVER** use Write or Edit tools directly.
        All file modifications go through specialized agents.

        Agent Selection Hierarchy:
        | File Type | Agent |
        |-----------|-------|
        | Test files | sdlc:red |
        | Implementation code | sdlc:green |
        | Domain types/models | sdlc:domain |
        | ADRs | sdlc:adr |
        | GWT scenarios | sdlc:gwt |
        | Everything else | sdlc:file-updater |
        ```

        The orchestrator's role:
        - Classify user requests
        - Select appropriate agent
        - Provide context to agent
        - Facilitate debates between agents
        - Proxy subagent questions to user
        - Track workflow state

        The orchestrator NEVER:
        - Writes or edits files directly
        - Implements features
        - Makes code changes
        - Runs tests (unless coordinating)

        This is enforced through discipline and skill loading, not tool restrictions.
      </detail>
      <source>
        /home/jwilger/projects/claude-code-plugins/sdlc/commands/shared/orchestration.md (lines 60-202)
      </source>
      <relevance>
        This "orchestrator-only" pattern maps perfectly to task-based workflows:

        Current (prompt-based):
        - Orchestrator decides which agent to invoke
        - Orchestrator provides context in prompt
        - Agent does work, returns results
        - Orchestrator interprets and continues

        Task-based (structural):
        - Orchestrator creates tasks with dependencies
        - Tasks assigned to specific agents (owner field)
        - Agents claim and complete tasks
        - TaskList shows workflow state

        The redesign opportunity:
        - Lightweight orchestrator agent loads orchestration skills
        - Uses TaskCreate/TaskUpdate to structure workflow
        - Uses Task tool to spawn heavy agents (red, green, domain)
        - Tasks encode workflow state (no more invocation gates)
        - Skills document principles, tasks enforce structure

        The orchestrator becomes a "workflow compiler" - translating user intent into task graphs that agents execute.
      </relevance>
    </finding>

    <finding category="integration-patterns">
      <title>Task Dependencies Can Replace Invocation Gates for Workflow Enforcement</title>
      <detail>
        The invocation gate pattern (prompt-based validation) can be mechanically enforced with task dependencies.

        Current gate pattern:
        ```
        Orchestrator checks: "Did red complete?"
        → If yes: Invoke domain with RED_PHASE_COMPLETE context
        → If no: Error or invoke red first
        ```

        Task dependency pattern:
        ```
        TaskCreate("Write failing test", owner="red", status="pending")
        TaskCreate("Create domain types", owner="domain", blockedBy=[red-task-id])
        TaskCreate("Implement to pass test", owner="green", blockedBy=[domain-task-id])
        TaskCreate("Review implementation", owner="domain", blockedBy=[green-task-id])
        ```

        Enforcement:
        - Claude Code prevents starting tasks with unmet dependencies
        - TaskList shows which tasks are blocked (▲ indicator)
        - No prompt engineering needed - structural guarantee
        - State persists across sessions

        Migration path:
        - Phase 1: Add task creation alongside gates (redundant but safe)
        - Phase 2: Agents check TaskList instead of requiring gate context
        - Phase 3: Remove gate validation (tasks are source of truth)

        Tradeoffs:
        - Tasks: Mechanical enforcement, persistent state, visible progress
        - Gates: Explicit context, educational value, flexible validation
      </detail>
      <source>
        TaskUpdate tool definition (addBlockedBy parameter)
        TaskList tool definition (blockedBy field)
        SDLC orchestration.md invocation gate protocol
      </source>
      <relevance>
        Task dependencies provide stronger workflow guarantees than prompt-based gates:

        Benefits:
        - Cannot accidentally skip phases (structural impossibility)
        - Clear visual representation of workflow state
        - Resumable across sessions (gates require re-declaring context)
        - Enables parallel workflows (multiple independent task chains)

        Drawbacks:
        - Less flexible than prompt-based validation
        - Cannot encode complex conditional logic
        - Requires upfront workflow planning

        For sdlc redesign: Use tasks for primary workflow (red→domain→green→domain), keep gates as defensive checks in agent prompts. Tasks enforce structure, gates catch logic errors.
      </relevance>
    </finding>

    <finding category="integration-patterns">
      <title>Skills Can Document Protocols While Tasks Enforce Execution Order</title>
      <detail>
        Separation of concerns for workflow management:

        Skills (WHAT and WHY):
        - Document workflow principles
        - Explain phase responsibilities
        - Provide examples and anti-patterns
        - Injected into agent context as knowledge
        - Example: "Red phase writes ONE test at a time"

        Tasks (WHEN and WHO):
        - Structure execution order
        - Assign work to specific agents
        - Track completion status
        - Enforce dependencies
        - Example: Task "Write failing test" must complete before Task "Create types"

        Hooks (HOW VERIFIED):
        - Validate agent behavior
        - Enforce constraints
        - Require verification evidence
        - Example: PostToolUse hook requires pasting test output

        Combined pattern:
        1. Skill loaded into orchestrator: "TDD workflow requires red→domain→green order"
        2. Orchestrator creates tasks with dependencies matching that order
        3. Agent receives task: "Write failing test for X"
        4. Agent loads skills: "Red phase constraints" (loaded at agent startup)
        5. Agent executes, hooks validate (e.g., only edit test files)
        6. Agent completes task, marks status=completed
        7. Next dependent task unblocks

        This three-layer approach:
        - Skills = education and context
        - Tasks = structure and enforcement
        - Hooks = validation and verification
      </detail>
      <source>
        Skills.sh format (SKILL.md documentation)
        Claude Code task system (dependency management)
        SDLC agent hooks (validation patterns)
      </source>
      <relevance>
        This layered approach enables the sdlc redesign:

        Layer 1 (Skills - Portable):
        - TDD constraints skill
        - Orchestration protocol skill
        - Memory protocol skill
        - Domain modeling principles skill
        Can be installed via npx skills, work across agents

        Layer 2 (Tasks - Structural):
        - Orchestrator creates task graphs
        - Dependencies encode workflow order
        - Persistent across sessions
        Built into Claude Code, no extraction needed

        Layer 3 (Hooks - Claude Code-specific):
        - Agent definitions with hook configurations
        - Validate file types, require evidence
        - Integration with MCP (memento storage)
        Remain in sdlc plugin

        Each layer has distinct responsibility: Skills teach, tasks structure, hooks validate. This separation enables skills to be portable while keeping enforcement Claude Code-specific.
      </relevance>
    </finding>

    <finding category="integration-patterns">
      <title>Lightweight Orchestrator Pattern: Skills + Tasks, Minimal Subagents</title>
      <detail>
        Pattern for reducing context costs while maintaining workflow structure:

        Traditional orchestrator:
        - Heavy system prompt with all protocols
        - Creates subagents for all work
        - High context cost (all protocols loaded)
        - Slower due to subagent spawning overhead

        Lightweight orchestrator:
        - Loads only core orchestration skills
        - Uses TaskCreate/TaskUpdate for structure
        - Spawns subagents only for specialized work
        - Other agents can self-orchestrate via TaskList

        Example workflow:
        ```
        User: "Implement user authentication"

        Orchestrator (lightweight):
        1. Load orchestration-protocol skill
        2. Create task graph:
           - Task: "Write test for auth" (owner: red)
           - Task: "Create auth types" (owner: domain, blocked by red)
           - Task: "Implement auth" (owner: green, blocked by domain)
           - Task: "Review auth implementation" (owner: domain, blocked by green)
        3. Start first task (spawn red subagent)

        Red agent:
        1. Receives task via Task tool invocation
        2. Loads red-specific skills (tdd-constraints)
        3. Writes failing test
        4. Updates task status=completed
        5. Returns to orchestrator

        Orchestrator:
        1. Sees red task complete
        2. Next task (domain) unblocks automatically
        3. Spawns domain subagent with domain task

        [Continue pattern]
        ```

        Alternative: Agents poll TaskList and self-assign:
        ```
        Domain agent (running in background):
        1. Polls TaskList for tasks where owner=domain and status=pending
        2. Sees task unblocked (red completed)
        3. Claims task (status=in_progress)
        4. Does work
        5. Marks complete
        ```

        This reduces orchestrator overhead - it creates structure, agents execute.
      </detail>
      <source>
        Claude Code subagent documentation (context costs)
        Task tool definitions (owner and status fields)
        Skills.sh lazy loading patterns
      </source>
      <relevance>
        The lightweight pattern enables sdlc redesign with lower context costs:

        Current sdlc:
        - Heavy orchestrator with all protocols loaded
        - Synchronous: orchestrator waits for each agent
        - High context consumption
        - Single-threaded workflow

        Lightweight redesign:
        - Orchestrator loads minimal skills (just orchestration)
        - Creates task graph with dependencies
        - Spawns agents who load their own skills
        - Agents can run in parallel where dependencies allow
        - Agents can self-assign from TaskList

        Benefits:
        - Lower context costs (skills loaded only where needed)
        - Faster (parallel execution where safe)
        - More scalable (agents don't wait on orchestrator)
        - Better for worktree workflows (each worktree has task list)

        Tradeoff: Requires agents to be more autonomous (check TaskList, load skills, coordinate). Current pattern is more explicit (orchestrator controls everything).
      </relevance>
    </finding>

    <finding category="integration-patterns">
      <title>Task Metadata Enables Rich Workflow Tracking and Resumption</title>
      <detail>
        Task metadata field accepts arbitrary JSON, enabling rich context storage:

        Example task metadata:
        ```json
        {
          "feature": "user-authentication",
          "slice_number": 3,
          "acceptance_criterion_index": 2,
          "cycle_number": 5,
          "parent_issue": "#123",
          "sub_issue": "#456",
          "test_file": "tests/auth_test.rs",
          "implementation_file": "src/auth.rs",
          "domain_types_created": ["UserId", "AuthToken", "AuthError"],
          "memento_checkpoint": "auth-cycle-5-red-complete"
        }
        ```

        Use cases:
        - Resuming work after interruption (metadata tells you where you were)
        - Filtering tasks (TaskList + metadata = "show all tasks for slice 3")
        - Progress reporting (metadata tracks cycle numbers, criteria completed)
        - Debugging (metadata shows what was created/modified)
        - Memento integration (checkpoint IDs in metadata)

        Pattern for resumption:
        ```
        User: "Continue authentication work"

        Orchestrator:
        1. TaskList → Find tasks with metadata.feature="user-authentication"
        2. Check status: Some completed, some in_progress, some pending
        3. TaskGet(in_progress_task) → See full context
        4. Resume: "Working on cycle 5, red phase complete, waiting for domain"
        5. Continue workflow from that point
        ```

        Metadata can also track:
        - Git branches (useful for worktree workflows)
        - Timestamps (when task started/completed)
        - Dependencies on external work (blocking external issue numbers)
        - Quality metrics (test coverage, mutation score)
      </detail>
      <source>
        TaskCreate metadata parameter
        TaskUpdate metadata parameter (merge with null to delete keys)
      </source>
      <relevance>
        Task metadata solves the "workflow resumption" problem that currently requires Memento MCP:

        Current sdlc pattern:
        - Store context in memento
        - Query memento for "current work"
        - Manually reconstruct workflow state
        - Requires MCP integration

        Task metadata pattern:
        - Store context in task metadata
        - TaskList shows current work
        - Metadata contains workflow state
        - No external dependencies

        For sdlc redesign:
        - Metadata = workflow state (cycle number, files, phase)
        - Memento = domain knowledge (patterns, decisions, learnings)
        - Tasks = structure (what's next, dependencies)

        This separates concerns: Tasks track workflow mechanics, Memento stores semantic knowledge. Metadata enables resumption even without Memento.

        Example: After restarting Claude Code, TaskList shows "Write failing test for auth (cycle 5)" with metadata containing file paths, acceptance criteria, previous types created. Agent can resume without querying Memento.
      </relevance>
    </finding>
  </findings>

  <recommendations>
    <recommendation priority="high">
      <action>Extract 10 shared protocols as standalone skills for skills.sh distribution</action>
      <rationale>
        The sdlc plugin's commands/shared/ directory contains reusable protocols (orchestration, tdd-constraints, memory-protocol, etc.) that are already designed as documentation, not executable code. These are perfect candidates for SKILL.md format:

        - Already have "user-invocable: false" (designed as knowledge, not commands)
        - No Claude Code-specific features (pure documentation/patterns)
        - Valuable across agent frameworks (TDD, domain modeling, debugging patterns)
        - Clean separation from agent definitions

        Converting to skills enables:
        - Installation via npx skills add jwilger/sdlc-skills
        - Reuse in Cursor, Windsurf, other agents
        - Independent versioning from full plugin
        - Community adaptation and forking

        Implementation: Create separate jwilger/sdlc-skills repo with each protocol as SKILL.md, publish to skills.sh marketplace.
      </rationale>
    </recommendation>

    <recommendation priority="high">
      <action>Introduce lightweight orchestrator agent with task-based workflow coordination</action>
      <rationale>
        Replace the current synchronous "orchestrator as main conversation" pattern with a dedicated lightweight agent:

        Orchestrator agent characteristics:
        - Loads orchestration skills (not all protocols)
        - Uses TaskCreate/TaskUpdate to structure workflow
        - Spawns specialized subagents via Task tool
        - Monitors progress via TaskList
        - Disallows Write/Edit (delegation only)
        - Uses Haiku model (fast, cheap for coordination)

        Benefits:
        - Lower context costs (only orchestration skills loaded)
        - Explicit workflow state (task dependencies)
        - Resumable across sessions (tasks persist)
        - Enables parallel execution (independent task chains)
        - Clearer separation of concerns (orchestrator coordinates, agents execute)

        Task dependencies replace invocation gates:
        - Current: Orchestrator checks "did red complete?" then provides gate context
        - New: TaskUpdate adds blockedBy, system prevents starting blocked tasks
        - Mechanical enforcement vs prompt-based discipline

        Implementation: Create agents/orchestrator.md with minimal skills, TaskCreate/TaskUpdate/TaskList/Task tools only, no Write/Edit.
      </rationale>
    </recommendation>

    <recommendation priority="high">
      <action>Use task metadata for workflow state instead of relying solely on Memento MCP</action>
      <rationale>
        Task metadata provides structured workflow context that complements (not replaces) Memento's semantic memory:

        Task metadata stores:
        - Workflow mechanics (cycle number, phase, blockers)
        - File paths (test_file, implementation_file)
        - Feature association (slice_number, acceptance_criterion)
        - Checkpoints (memento entity IDs for deep context)

        Memento stores:
        - Domain knowledge (patterns learned, decisions made)
        - Semantic insights (why approaches work/fail)
        - Project conventions (team-specific patterns)

        Separation of concerns:
        - Tasks = "where we are" (resumable workflow state)
        - Memento = "what we learned" (transferable knowledge)

        Benefits:
        - Resumption works without Memento (TaskList + metadata = sufficient context)
        - Memento becomes optional enhancement (not required dependency)
        - Clearer data model (workflow vs knowledge)

        Implementation: TaskCreate includes metadata with feature, cycle, phase, files. Agents use TaskGet metadata for context instead of requiring extensive Memento queries.
      </rationale>
    </recommendation>

    <recommendation priority="medium">
      <action>Migrate from invocation gates to task dependencies incrementally</action>
      <rationale>
        The invocation gate pattern (RED_CONTEXT: FIRST_TEST, etc.) works but has limitations:
        - Prompt-based (no mechanical enforcement)
        - Non-persistent (doesn't survive session restart)
        - Manual discipline required
        - Verbose (requires context declaration blocks)

        Task dependencies provide stronger guarantees:
        - Structural enforcement (cannot start blocked tasks)
        - Persistent across sessions
        - Visible state (TaskList shows workflow)
        - Less verbose (dependencies implicit in task graph)

        Migration path (safe, incremental):
        1. Phase 1: Add task creation alongside gates (both active)
           - Orchestrator creates tasks + provides gate context
           - Agents validate gates as before
           - Tasks provide redundant tracking
        2. Phase 2: Agents check TaskList instead of requiring gates
           - Agents query TaskList for context
           - Gate validation becomes defensive check
           - Tasks are primary source of truth
        3. Phase 3: Remove gate validation from agent prompts
           - Tasks fully replace gates
           - Simpler agent prompts
           - Mechanical enforcement only

        Keep gates as optional educational feature (explain workflow to users), remove as enforcement mechanism.
      </rationale>
    </recommendation>

    <recommendation priority="medium">
      <action>Design agents to self-assign tasks from TaskList for autonomous operation</action>
      <rationale>
        Current pattern: Orchestrator spawns agents explicitly, waits for completion, then spawns next agent.

        Alternative pattern: Agents poll TaskList and self-assign work when unblocked.

        Autonomous agent pattern:
        ```
        Red agent (background task):
        1. Query TaskList for owner=red, status=pending, no blockedBy
        2. Claim task (TaskUpdate status=in_progress)
        3. Execute work
        4. Update status=completed
        5. Return or continue polling
        ```

        Benefits:
        - Reduced orchestrator overhead (create graph, agents execute)
        - True parallel execution (multiple agents work simultaneously)
        - Better for worktree workflows (each worktree has task list)
        - More scalable (agents don't wait on orchestrator)

        Tradeoffs:
        - More complex agents (need task polling logic)
        - Harder to debug (less centralized control)
        - Requires careful task scoping (agents must understand task requirements)

        Recommendation: Hybrid approach:
        - Orchestrator spawns first agent explicitly (clear starting point)
        - Subsequent agents can self-assign from TaskList
        - Orchestrator monitors overall progress, intervenes if needed

        Implementation: Agents load orchestration-protocol skill that includes task self-assignment pattern.
      </rationale>
    </recommendation>

    <recommendation priority="medium">
      <action>Leverage background tasks for long-running or parallel operations</action>
      <rationale>
        Background tasks enable true concurrency:

        Good candidates for background:
        - Mutation testing (long-running, no user input needed)
        - Code review stages (can run in parallel)
        - Discovery/research (gather info while user works)
        - Multiple independent slices in worktrees

        Keep foreground for:
        - User interaction needed (questions, clarifications)
        - MCP tool usage (Memento integration)
        - Complex permission scenarios

        Pattern:
        ```
        Orchestrator:
        1. Create task "Run mutation tests"
        2. Spawn mutation agent in background
        3. Continue with other work
        4. Agent completes, updates task, summary appears
        ```

        Limitations to manage:
        - Background tasks cannot use AskUserQuestion (fails silently)
        - Background tasks have no MCP access (pre-load data or run foreground)
        - Permission pre-approval required (scope work clearly)

        Recommendation: Use background for mutation testing (current bottleneck), keep TDD cycle foreground (needs interaction).
      </rationale>
    </recommendation>

    <recommendation priority="low">
      <action>Consider publishing sdlc agents as templates/examples alongside skills</action>
      <rationale>
        While agent definitions are Claude Code-specific (hooks, tool restrictions), they provide valuable templates:

        Value for community:
        - Reference implementation of TDD workflow
        - Hook patterns for constraint enforcement
        - Integration examples (skills + MCP + tasks)
        - Domain modeling enforcement patterns

        Distribution strategy:
        - Skills: Portable protocols (via skills.sh)
        - Plugin: Full integration (via Claude Code marketplace)
        - Templates: Agent definitions as documentation (GitHub repo)

        This enables:
        - Users of other agents can adapt patterns
        - Claude Code users can fork and customize agents
        - Educational value (teaching workflow design)

        Implementation: Include agents/ directory in sdlc-skills repo as examples/, with README explaining "these are Claude Code-specific but show patterns you can adapt."
      </rationale>
    </recommendation>

    <recommendation priority="low">
      <action>Explore agent-to-agent communication via task comments or metadata updates</action>
      <rationale>
        Current pattern: Agents return results to orchestrator, orchestrator interprets and continues.

        Alternative: Agents communicate via task updates:
        ```
        Domain agent completes task:
        - Updates metadata: {"domain_concern": "Primitive obsession in test"}
        - Status remains in_progress (blocked on red revision)

        Red agent sees metadata update:
        - Reads concern from TaskGet
        - Revises test
        - Updates metadata: {"concern_addressed": "Using Email type"}
        - Marks status=completed

        Domain agent sees completion:
        - Reads revision from metadata
        - Re-reviews
        - Creates types or raises new concern
        ```

        Benefits:
        - Asynchronous agent interaction
        - Persistent debate record (in task metadata)
        - Less orchestrator mediation needed

        Tradeoffs:
        - More complex coordination logic
        - Harder to follow conversation flow
        - Potential for deadlocks if agents misunderstand

        Recommendation: Start with orchestrator-mediated pattern (proven), explore agent-to-agent as optimization once task-based workflow is stable.
      </rationale>
    </recommendation>
  </recommendations>

  <code_examples>
    ## Task Creation for TDD Workflow

    ```javascript
    // Orchestrator creates task graph for one TDD cycle

    // Task 1: Red phase
    const redTask = await TaskCreate({
      subject: "Write failing test for user authentication",
      description: "Create test that verifies User can be created with valid email and password. Test should fail with 'function not found' error.",
      activeForm: "Writing failing test",
      metadata: {
        feature: "user-authentication",
        slice_number: 3,
        acceptance_criterion: "User can authenticate with email and password",
        cycle_number: 1,
        phase: "red",
        test_file: "tests/auth_test.rs"
      }
    });

    // Task 2: Domain review (blocked by red)
    const domainReviewTask = await TaskCreate({
      subject: "Create domain types for authentication",
      description: "Review test from red phase. Create type definitions (User, Email, Password, AuthError) with unimplemented!() stubs. Check for domain violations.",
      activeForm: "Creating domain types",
      metadata: {
        feature: "user-authentication",
        cycle_number: 1,
        phase: "domain-after-red",
        blocks_test: redTask.id
      }
    });
    await TaskUpdate({
      taskId: domainReviewTask.id,
      addBlockedBy: [redTask.id]
    });

    // Task 3: Green phase (blocked by domain)
    const greenTask = await TaskCreate({
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
    await TaskUpdate({
      taskId: greenTask.id,
      addBlockedBy: [domainReviewTask.id]
    });

    // Task 4: Domain review of implementation (blocked by green)
    const domainReviewImplTask = await TaskCreate({
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
      taskId: domainReviewImplTask.id,
      addBlockedBy: [greenTask.id]
    });
    ```

    ## Skill Format for TDD Constraints

    ```markdown
    ---
    name: tdd-constraints
    description: TDD phase boundaries and responsibilities for red/green/domain workflow
    ---

    # TDD Constraints

    This skill documents the phase boundaries for Test-Driven Development with domain modeling.

    ## Phase Responsibilities

    ### Red Phase
    - Write ONE failing test at a time
    - Use ONE assertion per test
    - Reference types that should exist (let compiler fail)
    - Test code ONLY - no type definitions or implementations
    - Run test and paste FULL output showing failure

    ### Domain Phase (After Red)
    - Review test for domain violations
    - Create minimal type definitions (structs, traits, enums)
    - Use `unimplemented!()` for function bodies
    - Run type checker and paste output
    - VETO POWER over primitive obsession and invalid states

    ### Green Phase
    - Implement minimal code to pass the test
    - Use types created by domain agent
    - No over-engineering or premature optimization
    - Run tests and paste FULL output showing pass

    ### Domain Phase (After Green)
    - Review implementation for domain integrity
    - Check for primitive obsession in implementation
    - Verify parse-don't-validate principles
    - Ensure invalid states are unrepresentable

    ## Anti-Patterns

    | If you're thinking... | The truth is... |
    |-----------------------|-----------------|
    | "Let me write multiple tests at once" | Multiple tests = multiple assertions = unclear failures |
    | "I'll skip running the test" | If you didn't watch it fail, you don't know it tests anything |
    | "This is too simple for domain review" | Trivial changes accumulate into technical debt |
    | "Just a quick fix" | Shortcuts bypass type safety and introduce bugs |

    ## Workflow Order

    The order is MANDATORY:
    1. Red writes test
    2. Domain reviews test and creates types
    3. Green implements to pass test
    4. Domain reviews implementation
    5. Refactor if needed (optional)
    6. Repeat

    Never skip domain review. Even if obvious, the ritual matters.
    ```

    ## Subagent Definition with Skills and Hooks

    ```yaml
    ---
    name: red
    description: INVOKE for ALL test file changes. TEST CODE ONLY. One assertion per test.
    model: inherit
    skills:
      - tdd-constraints              # From skills.sh
      - user-input-protocol          # From skills.sh
      - memory-protocol              # From skills.sh
    tools:
      - Read
      - Write
      - Edit
      - Bash
      - Glob
      - Grep
      - mcp__memento__semantic_search
      - mcp__memento__create_entities
    hooks:
      PreToolUse:
        - matcher: Edit
          hooks:
            - type: prompt
              prompt: |
                CONSTRAINT CHECK: You may ONLY edit TEST files.

                Evaluate: Is this a test file?
                - Path contains: tests/, __tests__/, spec/
                - Name matches: *_test.*, *.test.*, test_*.*

                Respond: {"ok": true} if test file, {"ok": false, "reason": "..."} if not
        - matcher: Write
          hooks:
            - type: prompt
              prompt: |
                CONSTRAINT CHECK: You may ONLY create TEST files.

                Respond: {"ok": true} if test file, {"ok": false, "reason": "..."} if not
      PostToolUse:
        - matcher: Edit|Write
          hooks:
            - type: prompt
              prompt: |
                VERIFICATION REQUIRED: Run tests and paste FULL output.

                1. Run test suite (cargo test, npm test, pytest, etc.)
                2. Copy FULL output into your response
                3. Confirm: "Test [name] FAILS with: [exact error]"

                Output ONLY: {"ok": true}
      Stop:
        - hooks:
            - type: prompt
              prompt: |
                Before completing, store test patterns worth remembering in memento.
                Output ONLY: {"ok": true}
    ---

    # Red Phase Agent

    You write failing tests. ONE test at a time, ONE assertion per test.

    [Agent-specific instructions here - loaded from agent file]
    [Skills provide shared protocols, agent file provides role-specific guidance]
    ```

    ## Lightweight Orchestrator Pattern

    ```yaml
    ---
    name: tdd-orchestrator
    description: Orchestrate TDD workflow using tasks and subagents
    model: haiku  # Fast, cheap for orchestration
    skills:
      - orchestration-protocol    # From skills.sh
      - tdd-constraints          # From skills.sh
    tools:
      - TaskCreate
      - TaskUpdate
      - TaskGet
      - TaskList
      - Task  # For spawning subagents
      - AskUserQuestion
      - mcp__memento__semantic_search
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

    ## Task Creation Pattern

    For each acceptance criterion:
    1. Create "Write failing test" task (owner: red)
    2. Create "Create types" task (owner: domain, blocked by red)
    3. Create "Implement code" task (owner: green, blocked by domain)
    4. Create "Review implementation" task (owner: domain, blocked by green)

    ## Agent Spawning

    When task unblocks:
    - Use Task tool to spawn appropriate subagent
    - Pass task context (use TaskGet for full details)
    - Wait for completion
    - Check for domain concerns or questions

    You are the conductor, agents are the musicians.
    ```
  </code_examples>

  <metadata>
    <confidence level="high">
      High confidence based on:
      - Direct access to Claude Code tool definitions (TaskCreate, TaskUpdate, TaskGet, TaskList schemas)
      - Official Claude Code documentation from code.claude.com/docs
      - Verified skills.sh format from official GitHub repo (vercel-labs/skills)
      - Direct analysis of sdlc plugin codebase structure
      - Multiple corroborating sources for task system capabilities

      Lower confidence areas:
      - Background task behavior in production (documented but not personally tested)
      - Skills.sh marketplace adoption metrics (recent launch, January 2026)
      - Agent-to-agent coordination patterns (theoretical, not demonstrated)
    </confidence>

    <dependencies>
      To act on this research, you will need:
      - Claude Code 2.1+ (for task system)
      - skills CLI (npx skills) for skill distribution
      - Access to .claude-plugin/ directory structure
      - GitHub repo for extracted skills
      - Understanding of YAML frontmatter and Markdown
      - (Optional) Memento MCP server for memory integration
      - (Optional) git-spice for stacked PR workflows
    </dependencies>

    <open_questions>
      Questions that could not be determined from research:

      1. Task system performance at scale:
         - How many tasks can be active before performance degrades?
         - Does TaskList become unwieldy with hundreds of tasks?
         - Are there task cleanup/archival mechanisms?

      2. Background task limitations in practice:
         - How reliable is permission pre-approval?
         - What happens when background task encounters unexpected failure?
         - Can background tasks resume if interrupted?

      3. Skills.sh marketplace dynamics:
         - What makes a skill discoverable and adopted?
         - How do telemetry metrics actually work?
         - Is there review/curation process beyond security audits?

      4. Cross-session task persistence:
         - CLAUDE_CODE_TASK_LIST_ID: How is this set in practice?
         - Do tasks survive Claude Code version updates?
         - How long are completed tasks retained?

      5. Agent coordination complexity:
         - At what point does task-based coordination become harder than prompt-based?
         - What are failure modes for self-assigning agents?
         - How to debug when task dependencies create deadlocks?

      6. Skills vs subagents boundary:
         - When should knowledge become a skill vs built into agent prompt?
         - What's the context cost tradeoff for skill lazy loading?
         - Can skills reference other skills?
    </open_questions>

    <assumptions>
      Assumptions made during research:

      1. Task dependencies are strictly enforced by Claude Code (cannot start blocked task)
         - Based on: Tool documentation and architectural descriptions
         - Risk: Might be advisory rather than enforced

      2. Skills loaded via skills CLI are discovered by Claude Code automatically
         - Based on: Documentation of search paths (.claude/skills/)
         - Risk: Might require configuration or restart

      3. Background tasks truly run in parallel with main conversation
         - Based on: Subagent documentation
         - Risk: Might be pseudo-parallel (rapid switching)

      4. Task metadata is arbitrary JSON with no size limits
         - Based on: Tool parameter description
         - Risk: Might have undocumented size constraints

      5. Hooks in subagent definitions can reliably enforce constraints
         - Based on: Current sdlc plugin success
         - Risk: Might have edge cases or bypass methods

      6. Skills are portable across agents with minimal adaptation
         - Based on: Skills.sh marketing and CLI support list
         - Risk: Might require agent-specific adjustments

      7. The lightweight orchestrator pattern reduces context costs meaningfully
         - Based on: Understanding of context window mechanics
         - Risk: Overhead of task management might offset savings
    </assumptions>

    <quality_report>
      <sources_consulted>
        Official documentation:
        - https://code.claude.com/docs/en/how-claude-code-works
        - https://code.claude.com/docs/en/sub-agents.md
        - https://code.claude.com/docs/llms.txt (full index)
        - https://github.com/vercel-labs/skills (official skills CLI)
        - https://skills.sh/docs
        - https://vercel.com/changelog/introducing-skills-the-open-agent-skills-ecosystem

        Community sources:
        - https://medium.com/@richardhightower/claude-code-todos-to-tasks-5a1b0e351a1c
        - https://claudefa.st/blog/guide/development/task-management
        - https://gist.github.com/kieranklaassen/4f2aba89594a4aea4ad64d753984b2ea

        Codebase analysis:
        - /home/jwilger/projects/claude-code-plugins/sdlc/.claude-plugin/plugin.json
        - /home/jwilger/projects/claude-code-plugins/sdlc/agents/ (all 15 agents)
        - /home/jwilger/projects/claude-code-plugins/sdlc/commands/ (all 11 commands)
        - /home/jwilger/projects/claude-code-plugins/sdlc/commands/shared/ (all 10 protocols)

        Direct observation:
        - Claude Code tool definitions from system prompt
        - TaskCreate, TaskUpdate, TaskGet, TaskList parameter schemas
        - Skill tool definition and behavior
      </sources_consulted>

      <claims_verified>
        Verified with official sources:
        - Task system is built-in to Claude Code 2.1+ (official docs)
        - TaskCreate/TaskUpdate/TaskGet/TaskList schemas (system prompt)
        - Task lifecycle: pending → in_progress → completed (tool docs)
        - Task dependencies via addBlockedBy/addBlocks (tool docs)
        - Skills use SKILL.md with YAML frontmatter (vercel-labs/skills repo)
        - Skills CLI installation: npx skills add (official GitHub)
        - Background tasks run concurrently (subagent documentation)
        - Hooks enforce constraints (current sdlc plugin demonstrates)
        - Subagents load skills via skills: frontmatter field (agent docs)

        Cross-referenced from multiple sources:
        - Task metadata enables rich context (tool definition + community articles)
        - Skills are portable across agents (skills.sh + CLI repo)
        - Task system enables parallel workflows (multiple community examples)
      </claims_verified>

      <claims_assumed>
        Based on inference rather than explicit documentation:
        - Task-based coordination reduces orchestrator context costs (logical inference)
        - Agent self-assignment from TaskList is viable pattern (designed for it, not demonstrated)
        - Lightweight orchestrator is more efficient than heavy main conversation (architectural reasoning)
        - Task metadata can replace Memento for workflow resumption (capability exists, pattern not proven)
        - Skills extraction will increase adoption (market hypothesis)
        - Task dependencies can fully replace invocation gates (technical feasibility, UX unknown)
      </claims_assumed>

      <contradictions_encountered>
        No major contradictions. Minor clarifications:

        1. "Tasks" vs "subagents" terminology:
           - Some sources use "task" for subagent invocation
           - Claude Code also has Task tool for spawning subagents
           - AND has TaskCreate/TaskUpdate for task management
           - Clarified: Task tool spawns agents, TaskCreate creates work items

        2. Skills vs commands:
           - Plugin manifest has "commands" field
           - skills.sh uses "skills" terminology
           - Both use YAML frontmatter + markdown
           - Clarified: Commands are plugin-specific, skills are portable standard

        3. Background task limitations:
           - Some sources emphasize power of background tasks
           - Official docs emphasize limitations (no AskUserQuestion, no MCP)
           - Both are true: powerful but constrained
      </contradictions_encountered>

      <confidence_by_finding>
        HIGH confidence (official documentation + direct observation):
        - Task tool schemas and capabilities
        - Skill format and installation mechanism
        - SDLC plugin current structure and patterns
        - Hook enforcement capabilities
        - Subagent skills field functionality

        MEDIUM confidence (official docs + inference):
        - Lightweight orchestrator pattern effectiveness
        - Task-based workflow benefits over gates
        - Background task practical applications
        - Skills extraction strategy

        LOW confidence (logical reasoning, not demonstrated):
        - Agent self-assignment viability
        - Agent-to-agent communication patterns
        - Task system scalability limits
        - Skills marketplace adoption dynamics
      </confidence_by_finding>
    </quality_report>
  </metadata>
</research>
