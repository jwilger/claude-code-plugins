<research>
  <summary>
    Claude Opus 4.6 (released 2026-02-05) and Claude Code 2.1 introduce several capabilities that can meaningfully improve the SDLC plugin without breaking its core workflow. The most impactful findings are: (1) Agent hooks (type: "agent") now exist as a third hook type alongside command and prompt hooks, enabling multi-turn tool-using verification that could replace the current prompt-based file-type enforcement with more reliable, file-inspecting checks; (2) Agent teams provide experimental multi-session parallelism with inter-agent messaging, which could enhance the code review workflow; (3) Persistent subagent memory enables cross-session learning for domain, red, and green agents; (4) LSP integration gives agents access to go-to-definition, find-all-references, and type information, which would make the domain agent's type-checking vastly more precise; (5) Adaptive thinking with effort controls allows Opus 4.6 to automatically allocate more reasoning to harder subtasks.

    The SDLC plugin's mechanical enforcement via hooks and agent specialization maps well onto Claude Code's current architecture. The key gap is that the file-edit-auth.sh hook (which blocks the orchestrator from editing files directly) is currently disabled because Claude Code historically did not provide subagent context to hooks. This remains partially unresolved -- the hook input now includes agent_type for SubagentStart/SubagentStop, and agent transcript paths are separate, but the PreToolUse hook still does not include an explicit is_subagent field. However, agent-based hooks could work around this by inspecting the transcript path. Additionally, several new Claude Code features (skill hot-reload, forked subagent skills, once-per-session hooks) could streamline plugin setup and reduce context consumption.

    Six high-priority improvements are recommended: upgrading prompt hooks to agent hooks for file-type enforcement, adding LSP plugin dependency for type-aware domain review, leveraging persistent subagent memory for the domain agent, adding a PreCompact hook to preserve TDD cycle state, utilizing the SubagentStart hook for richer context injection, and exploring agent teams for parallel code review.
  </summary>

  <findings>
    <!-- ==================== MODEL CAPABILITIES ==================== -->

    <finding category="model">
      <title>Opus 4.6: 1M Token Context Window (Beta)</title>
      <detail>Claude Opus 4.6 supports a 1M token context window (beta), up from the standard 200K. This is activated via the context-1m-2025-08-07 beta header on the API. In Claude Code, this appears to be available when running with Opus 4.6. The max output is 128K tokens (up from 64K on Opus 4.5). This larger context means longer sessions before compaction, more room for agent system prompts plus codebase context, and ability to hold more of the TDD cycle state in memory.</detail>
      <source>https://platform.claude.com/docs/en/docs/about-claude/models</source>
      <relevance>The SDLC plugin's orchestrator manages multi-step workflows that consume significant context. The 1M context window means fewer compaction events and better state retention across TDD cycles. Agent system prompts (which are large in the SDLC plugin) have more room alongside actual codebase content.</relevance>
      <constraint_impact>ENHANCES - More context means better state tracking across RED/DOMAIN/GREEN/DOMAIN cycles without losing information to compaction.</constraint_impact>
    </finding>

    <finding category="model">
      <title>Opus 4.6: Adaptive Thinking (Replaces Manual Extended Thinking)</title>
      <detail>Opus 4.6 introduces adaptive thinking (thinking: {type: "adaptive"}) as the recommended replacement for manual extended thinking (thinking: {type: "enabled", budget_tokens: N}). The manual mode is deprecated on Opus 4.6. Adaptive thinking uses the effort parameter (low/medium/high/max) to let the model decide how much reasoning to apply based on task complexity. The model "picks up contextual clues about how much to use its extended thinking." Interleaved thinking (reasoning between tool calls) is automatically enabled with adaptive thinking on Opus 4.6 -- no beta header needed.</detail>
      <source>https://platform.claude.com/docs/en/docs/build-with-claude/extended-thinking, https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking</source>
      <relevance>The domain agent's type review and the red agent's test design require deep reasoning, while the green agent's minimal implementation needs less. Adaptive thinking means Opus 4.6 naturally invests more reasoning where it matters (domain modeling decisions, architecture alignment) and moves quickly through straightforward implementation steps.</relevance>
      <constraint_impact>ENHANCES - Better reasoning on domain modeling decisions strengthens the domain agent's veto authority. The model automatically reasons more deeply about type design and less about trivial implementations.</constraint_impact>
    </finding>

    <finding category="model">
      <title>Opus 4.6: Improved Agentic Coding and Self-Correction</title>
      <detail>Opus 4.6 scores 65.4% on Terminal-Bench 2.0 (up from 59.8% for Opus 4.5) and 72.7% on OSWorld (up from 66.3%). Anthropic specifically highlights improvements in: planning more carefully, sustaining agentic tasks for longer, operating more reliably in larger codebases, better code review and debugging, and detecting/correcting its own mistakes during code review.</detail>
      <source>https://www.anthropic.com/news/claude-opus-4-6, https://siliconangle.com/2026/02/05/anthropic-rolls-claude-opus-4-6-1-million-token-context-support/</source>
      <relevance>The SDLC plugin's TDD cycle is an inherently agentic, multi-step workflow. Better self-correction means the green agent is less likely to over-implement, the red agent writes more precise tests, and the domain agent catches more genuine violations. The improved code review capability directly benefits the code-reviewer and mutation agents.</relevance>
      <constraint_impact>ENHANCES - Better agentic reliability means fewer workflow breakdowns where agents violate their constraints or produce poor quality output.</constraint_impact>
    </finding>

    <finding category="model">
      <title>Opus 4.6: 128K Max Output Tokens</title>
      <detail>Opus 4.6 supports up to 128K output tokens, double the 64K limit of Opus 4.5 and Sonnet 4.5. This allows for much longer single-turn responses.</detail>
      <source>https://platform.claude.com/docs/en/docs/about-claude/models</source>
      <relevance>Large agent outputs (comprehensive domain reviews, detailed code reviews, long mutation testing reports) are less likely to be truncated. The domain agent can provide more thorough type analysis in a single turn.</relevance>
      <constraint_impact>SAFE - No workflow changes needed; agents simply have more room to express their findings.</constraint_impact>
    </finding>

    <finding category="model">
      <title>Opus 4.6: Thinking Block Preservation Across Turns</title>
      <detail>Starting with Opus 4.5 (continuing in 4.6), thinking blocks from previous assistant turns are preserved in model context by default. This differs from earlier models which removed thinking blocks from prior turns. Benefits include cache optimization for multi-step workflows and no intelligence impact from preservation.</detail>
      <source>https://platform.claude.com/docs/en/docs/build-with-claude/extended-thinking</source>
      <relevance>In the SDLC workflow, the orchestrator makes multi-turn decisions about which agent to dispatch next. Preserved thinking blocks mean the orchestrator's reasoning about the current TDD cycle state is retained, leading to better delegation decisions.</relevance>
      <constraint_impact>ENHANCES - Better reasoning continuity across the orchestrator's multi-turn workflow management.</constraint_impact>
    </finding>

    <!-- ==================== CLI FEATURES ==================== -->

    <finding category="cli">
      <title>Claude Code: Agent-Based Hooks (type: "agent")</title>
      <detail>Claude Code now supports three hook types: command, prompt, and agent. Agent hooks (type: "agent") spawn a subagent that can use tools like Read, Grep, and Glob to verify conditions before returning a decision. The agent hook can perform up to 50 turns of investigation before deciding. Configuration uses the same format as prompt hooks but with type: "agent". Default timeout is 60 seconds (vs 30 for prompt hooks). The response schema is the same: {"ok": true} or {"ok": false, "reason": "..."}.</detail>
      <source>https://code.claude.com/docs/en/hooks (official docs, fetched 2026-02-05)</source>
      <relevance>CRITICAL OPPORTUNITY: The SDLC plugin currently uses prompt hooks for file-type enforcement on red/green/domain agents. These prompt hooks evaluate based only on the file path and name patterns. Agent hooks could actually READ the file content to determine whether it's truly a test file, type definition, or implementation -- making enforcement dramatically more reliable. For example, instead of guessing from path patterns, an agent hook could grep for test annotations (#[test], describe(), etc.) or check for unimplemented!() stubs.</relevance>
      <constraint_impact>ENHANCES - Agent hooks make file-type enforcement more precise and harder to circumvent, strengthening the mechanical enforcement of the TDD cycle.</constraint_impact>
    </finding>

    <finding category="cli">
      <title>Claude Code: Expanded Hook Event Types</title>
      <detail>Claude Code now supports 12 hook events: SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, Stop, PreCompact, SessionEnd. Notable additions beyond what the SDLC plugin currently uses: SubagentStart (fires when a subagent spawns, can inject context), Notification (fires on permission/idle prompts), SessionEnd (fires on session termination for cleanup), PermissionRequest (fires when permission dialog appears). The SubagentStart hook receives agent_id and agent_type and can return additionalContext that is injected into the subagent's context.</detail>
      <source>https://code.claude.com/docs/en/hooks (official docs, fetched 2026-02-05)</source>
      <relevance>SubagentStart is particularly valuable for the SDLC plugin. Currently, agent context is entirely determined by the agent's markdown file and the orchestrator's delegation message. SubagentStart hooks could inject dynamic context: current TDD cycle phase, what the previous agent found, the dot CLI task status, or project-specific conventions from memory. This addresses the "fresh context" problem more systematically.</relevance>
      <constraint_impact>ENHANCES - SubagentStart context injection provides a reliable mechanism to pass TDD cycle state to agents without relying solely on the orchestrator's delegation message.</constraint_impact>
    </finding>

    <finding category="cli">
      <title>Claude Code: Async Hooks</title>
      <detail>Command hooks support async: true to run in the background without blocking. The hook starts and Claude continues working immediately. When the hook completes, its output is delivered on the next conversation turn. Only command hooks support async (not prompt or agent hooks). Background hook output can include systemMessage or additionalContext fields.</detail>
      <source>https://code.claude.com/docs/en/hooks (official docs, fetched 2026-02-05)</source>
      <relevance>Async hooks could run test suites in the background after file edits, providing results without blocking the agent's workflow. The current PostToolUse prompt hooks on red/green agents instruct the agent to run tests, but an async command hook could trigger the test run automatically and feed results back.</relevance>
      <constraint_impact>SAFE - This is an additive capability that wouldn't change the workflow; it could speed up feedback loops within agent turns.</constraint_impact>
    </finding>

    <finding category="cli">
      <title>Claude Code: Agent Teams (Experimental)</title>
      <detail>Agent teams allow multiple Claude Code instances to work in parallel. A team lead coordinates work, spawns teammates, assigns tasks via a shared task list (DAG-based). Teammates communicate via a mailbox system. Key differences from subagents: teammates message each other directly (not just back to the parent), each has its own full context window, and task coordination uses file locking. Agent teams are experimental, disabled by default, enabled via CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1. Best for: research/review, new modules, debugging with competing hypotheses, cross-layer coordination.</detail>
      <source>https://code.claude.com/docs/en/agent-teams (official docs, fetched 2026-02-05)</source>
      <relevance>The SDLC plugin's code review workflow (code-reviewer + mutation + domain review as separate passes) could potentially benefit from agent teams, where each reviewer works in parallel and they share findings. However, the TDD cycle itself (RED -> DOMAIN -> GREEN -> DOMAIN) is inherently sequential and should NOT use agent teams. The Event Modeling design phase (discovery, workflow-designer, gwt, model-checker working on different aspects) could also benefit from parallelism.</relevance>
      <constraint_impact>RISK for TDD cycle (must remain sequential), SAFE/ENHANCES for review and design phases. Must be carefully scoped to avoid breaking sequential TDD enforcement.</constraint_impact>
    </finding>

    <finding category="cli">
      <title>Claude Code: Persistent Subagent Memory</title>
      <detail>Subagents now support a memory field in frontmatter with scopes: user (~/.claude/agent-memory/name/), project (.claude/agent-memory/name/), or local (.claude/agent-memory-local/name/). When enabled, the subagent's system prompt includes instructions for reading/writing to the memory directory. The first 200 lines of MEMORY.md in the memory directory are automatically included. Read, Write, and Edit tools are automatically enabled for memory management.</detail>
      <source>https://code.claude.com/docs/en/sub-agents (official docs, fetched 2026-02-05)</source>
      <relevance>SIGNIFICANT OPPORTUNITY: The domain agent could use persistent memory to build up knowledge about the project's type conventions, common violations it's caught, and architectural patterns. The code-reviewer agent could remember common issues across review sessions. This addresses a key limitation: currently each agent invocation starts completely fresh, losing accumulated domain knowledge.</relevance>
      <constraint_impact>ENHANCES - Persistent memory makes agents smarter over time without changing the workflow structure. The domain agent becomes more effective at enforcing domain integrity across sessions.</constraint_impact>
    </finding>

    <finding category="cli">
      <title>Claude Code: SubagentStart Hook with Context Injection</title>
      <detail>The SubagentStart hook fires when a subagent is spawned and receives agent_id and agent_type. The hook can return additionalContext that is injected into the subagent's context. This runs in addition to the agent's normal system prompt and the orchestrator's delegation message. Matcher supports filtering by agent type name.</detail>
      <source>https://code.claude.com/docs/en/hooks (official docs, fetched 2026-02-05)</source>
      <relevance>This could be used to inject TDD cycle state into red/green/domain agents at spawn time. A SubagentStart hook matching "red|green|domain" could read the current dot CLI task state and inject it as context, ensuring agents always know what phase they're in and what came before.</relevance>
      <constraint_impact>ENHANCES - Provides a reliable, hook-enforced mechanism for passing TDD cycle context to agents, reducing reliance on the orchestrator's memory of what context to provide.</constraint_impact>
    </finding>

    <finding category="cli">
      <title>Claude Code: LSP Integration via Plugin</title>
      <detail>Claude Code supports Language Server Protocol (LSP) integration via plugins. LSP servers provide go-to-definition, find-all-references, type information, diagnostics, and symbol hierarchies. Requires ENABLE_LSP_TOOL=1 environment variable. LSP plugins are installed from marketplaces and support 20+ languages including Rust, TypeScript, Python, Go. Configuration is via .lsp.json in the plugin directory.</detail>
      <source>https://code.claude.com/docs/en/plugins-reference, community sources</source>
      <relevance>SIGNIFICANT OPPORTUNITY: The domain agent's type-checking is currently done by running the compiler (cargo check, tsc --noEmit). LSP integration would give the domain agent access to go-to-definition and find-all-references, enabling it to verify that domain types are used correctly throughout the codebase, not just that they compile. The code-reviewer and mutation agents could use symbol information for more targeted analysis.</relevance>
      <constraint_impact>ENHANCES - LSP gives agents richer code understanding without changing the workflow. Domain review becomes more thorough because the agent can navigate type relationships programmatically.</constraint_impact>
    </finding>

    <finding category="cli">
      <title>Claude Code: Skill Frontmatter context: fork and Agent Field</title>
      <detail>Skills now support context: fork in frontmatter to run in a forked subagent context. The agent field specifies which subagent configuration to use (built-in like Explore/Plan or custom agents). This creates an isolated context where the skill content becomes the task prompt. Skills also support once: true in hooks to run only once per session.</detail>
      <source>https://code.claude.com/docs/en/skills (official docs, fetched 2026-02-05)</source>
      <relevance>The once: true hook feature could be used for one-time setup checks (verify dot CLI is installed, check ARCHITECTURE.md exists). The context: fork pattern is already conceptually how the SDLC agents work, but skills with fork could provide an alternative lightweight pattern for some utility operations.</relevance>
      <constraint_impact>SAFE - These are additive patterns that could simplify certain plugin components without changing the workflow.</constraint_impact>
    </finding>

    <finding category="cli">
      <title>Claude Code: Hook once: true for One-Time Execution</title>
      <detail>Hooks defined in skills and agents support a once: true field that causes the hook to run only once per session and then be removed. This is useful for initialization checks that should not repeat.</detail>
      <source>https://code.claude.com/docs/en/hooks (official docs, fetched 2026-02-05)</source>
      <relevance>The SDLC plugin's SessionStart hook currently runs on every session start (including after compaction). A once: true hook in agent frontmatter could perform one-time architecture reading verification without repeating on every compaction event.</relevance>
      <constraint_impact>SAFE - Reduces unnecessary hook executions without changing enforcement.</constraint_impact>
    </finding>

    <finding category="cli">
      <title>Claude Code: PreCompact Hook with Custom Instructions</title>
      <detail>The PreCompact hook fires before context compaction with trigger (manual/auto) and custom_instructions fields. For auto-compact, custom_instructions is empty. For manual /compact, it contains the user's input. Hooks can return additionalContext to influence what gets preserved during compaction.</detail>
      <source>https://code.claude.com/docs/en/hooks (official docs, fetched 2026-02-05)</source>
      <relevance>IMPORTANT OPPORTUNITY: During compaction, the orchestrator's TDD cycle state (which phase it's in, what tests were written, what domain reviewed) could be lost. A PreCompact hook could inject a summary of the current TDD cycle state into the compaction context, ensuring critical workflow state survives compaction. This directly addresses a known pain point where compaction causes the orchestrator to "forget" where it is in the cycle.</relevance>
      <constraint_impact>ENHANCES - Preserving TDD cycle state through compaction strengthens mechanical enforcement by preventing state loss.</constraint_impact>
    </finding>

    <finding category="cli">
      <title>Claude Code: Model Field in Agent Frontmatter</title>
      <detail>Subagent frontmatter supports model: sonnet|opus|haiku|inherit. This allows routing different agents to different models. For example, read-only exploration agents can use haiku for speed, while complex reasoning agents use opus.</detail>
      <source>https://code.claude.com/docs/en/sub-agents (official docs, fetched 2026-02-05)</source>
      <relevance>The SDLC plugin currently sets model: inherit on all agents. For cost optimization, the file-updater agent (which handles config/docs/scripts) could use sonnet, while domain and code-reviewer agents could explicitly use opus for maximum reasoning quality. This is already available but not leveraged.</relevance>
      <constraint_impact>SAFE - Model routing doesn't change the workflow; it optimizes cost/quality tradeoffs per agent.</constraint_impact>
    </finding>

    <finding category="cli">
      <title>Claude Code: CLAUDE_ENV_FILE for Persistent Environment Variables</title>
      <detail>SessionStart hooks have access to CLAUDE_ENV_FILE, which allows persisting environment variables for all subsequent Bash commands in the session. Variables written to this file are available in all Bash tool calls.</detail>
      <source>https://code.claude.com/docs/en/hooks (official docs, fetched 2026-02-05)</source>
      <relevance>The SDLC plugin could use this to set environment variables like SDLC_TDD_PHASE or SDLC_CURRENT_TASK at session start, making TDD state available to all agent Bash commands without requiring explicit parameter passing.</relevance>
      <constraint_impact>SAFE - Additive; provides a mechanism for state sharing without changing workflow.</constraint_impact>
    </finding>

    <!-- ==================== PLUGIN SYSTEM ==================== -->

    <finding category="plugin">
      <title>Plugin Hooks in hooks/hooks.json</title>
      <detail>Plugins define hooks in hooks/hooks.json with an optional top-level description field. When a plugin is enabled, its hooks merge with user and project hooks. Plugin hooks appear as [Plugin] in the /hooks menu and are read-only (users cannot modify them). Hook commands can reference ${CLAUDE_PLUGIN_ROOT} for the plugin's root directory. The full hook system (all 12 events, all 3 types) is available to plugin hooks.</detail>
      <source>https://code.claude.com/docs/en/hooks (official docs, fetched 2026-02-05)</source>
      <relevance>The SDLC plugin already uses hooks.json. The finding confirms that agent-type hooks are available in plugin hooks, which means the plugin could upgrade its prompt hooks to agent hooks for file-type enforcement.</relevance>
      <constraint_impact>SAFE - Confirms existing capability; no workflow change.</constraint_impact>
    </finding>

    <finding category="plugin">
      <title>Plugin .lsp.json for Language Server Configuration</title>
      <detail>Plugins can include a .lsp.json file at the root to configure language servers. This allows plugins to bundle LSP configuration alongside their agents and hooks. The LSP tool must be enabled (ENABLE_LSP_TOOL=1). LSP provides diagnostics, go-to-definition, find-all-references, type information, and symbol hierarchies.</detail>
      <source>https://code.claude.com/docs/en/plugins (official docs, fetched 2026-02-05)</source>
      <relevance>The SDLC plugin could recommend or depend on LSP plugins for the user's primary language, enabling the domain agent and code-reviewer to use type information for more precise analysis. However, LSP plugins are language-specific and the SDLC plugin is language-agnostic, so this would be a recommended optional dependency rather than a bundled component.</relevance>
      <constraint_impact>SAFE - Optional enhancement; doesn't change the workflow.</constraint_impact>
    </finding>

    <finding category="plugin">
      <title>Plugin Skills with Frontmatter Options</title>
      <detail>Skills support extensive frontmatter: name, description, argument-hint, disable-model-invocation, user-invocable, allowed-tools, model, context (fork), agent, hooks. Skills can have supporting files in subdirectories. The $ARGUMENTS placeholder and positional $N arguments are available. Skills support !`command` syntax for dynamic context injection (shell command output is preprocessed into the skill content). Skills support the ${CLAUDE_SESSION_ID} substitution.</detail>
      <source>https://code.claude.com/docs/en/skills (official docs, fetched 2026-02-05)</source>
      <relevance>The SDLC plugin's 9 skills could potentially leverage dynamic context injection (!`command`) to inject real-time project state. For example, the task-management skill could inject the current dot CLI task list, and the tdd-constraints skill could inject the current TDD phase from a state file.</relevance>
      <constraint_impact>SAFE - Additive features that could make skills more dynamic without changing their purpose.</constraint_impact>
    </finding>

    <!-- ==================== OPPORTUNITIES ==================== -->

    <finding category="opportunity">
      <title>Re-enable Orchestrator File-Edit Block with Agent Hooks</title>
      <detail>The file-edit-auth.sh hook is currently DISABLED because Claude Code's PreToolUse hook input does not include a reliable is_subagent field. The transcript_path is identical for main orchestrator and subagents. However, with agent-based hooks (type: "agent"), the hook could use Read/Grep tools to examine the hook input JSON more thoroughly, check for agent-specific markers, or inspect the session state to determine if a file edit is coming from the orchestrator vs a subagent.</detail>
      <source>Cross-reference: sdlc/.claude-plugin/hooks/file-edit-auth.sh (disabled) + Claude Code hook docs</source>
      <relevance>CRITICAL: The orchestrator file-edit block is a core enforcement mechanism that prevents the orchestrator from writing code directly. Its disablement is a significant workflow enforcement gap. Agent hooks might provide enough investigative capability to reliably distinguish orchestrator from subagent context.</relevance>
      <constraint_impact>ENHANCES - Re-enabling this enforcement directly strengthens the "orchestrator delegates, never acts directly" principle.</constraint_impact>
    </finding>

    <finding category="opportunity">
      <title>Upgrade File-Type Enforcement Hooks from Prompt to Agent</title>
      <detail>The red, green, and domain agents use prompt hooks for PreToolUse to verify file types (test files for red, production files for green, type definitions for domain). These prompt hooks evaluate based on file path patterns and name conventions. Agent hooks could actually READ the file content, check for test annotations, look for unimplemented!() stubs, verify module structure, etc. This would catch edge cases like: a test file in src/ (currently allowed by path-based check), or a production file named with _test suffix but not actually containing tests.</detail>
      <source>Cross-reference: sdlc/agents/red.md hooks + Claude Code agent hooks docs</source>
      <relevance>File-type enforcement is the primary mechanism for ensuring RED only edits tests, GREEN only edits production code, and DOMAIN only edits type definitions. More reliable enforcement directly strengthens the TDD cycle discipline.</relevance>
      <constraint_impact>ENHANCES - More precise enforcement of the existing constraints.</constraint_impact>
    </finding>

    <finding category="opportunity">
      <title>PreCompact Hook to Preserve TDD Cycle State</title>
      <detail>Currently, when auto-compaction triggers during a long TDD session, the orchestrator may lose track of which phase it's in (RED, DOMAIN after red, GREEN, DOMAIN after green), what tests have been written, and what domain concerns were raised. A PreCompact hook could: (1) read the current dot CLI task state, (2) determine the current TDD phase from recent agent invocations, and (3) inject a structured summary into the compaction context.</detail>
      <source>Cross-reference: SDLC workflow description + Claude Code PreCompact hook docs</source>
      <relevance>State loss during compaction is a real workflow problem. The orchestrator may re-do work, skip steps, or lose track of domain concerns raised in earlier cycles. A PreCompact hook directly addresses this by ensuring state survives compaction.</relevance>
      <constraint_impact>ENHANCES - Preserving TDD cycle state through compaction prevents the workflow from breaking at compaction boundaries.</constraint_impact>
    </finding>

    <finding category="opportunity">
      <title>SubagentStart Hook for Dynamic Context Injection</title>
      <detail>A SubagentStart hook matching TDD agents (red|green|domain) could inject dynamic context at spawn time: current TDD phase, recent test results, current dot CLI task description, project language/framework detection, and ARCHITECTURE.md summary. This supplements the orchestrator's delegation message with reliable, hook-enforced context that the orchestrator cannot forget to include.</detail>
      <source>Cross-reference: orchestration-protocol skill (fresh context requirement) + Claude Code SubagentStart hook docs</source>
      <relevance>The "fresh context" protocol requires the orchestrator to provide complete context to every agent. In practice, the orchestrator sometimes omits important context (especially after compaction). A SubagentStart hook provides a reliable baseline of context that is always injected, reducing the impact of orchestrator omissions.</relevance>
      <constraint_impact>ENHANCES - Strengthens the fresh context protocol by providing a hook-enforced context baseline.</constraint_impact>
    </finding>

    <finding category="opportunity">
      <title>Persistent Memory for Domain Agent</title>
      <detail>Adding memory: project to the domain agent would give it a persistent directory for recording: project type conventions discovered during reviews, common domain violations caught, architectural patterns and decisions, and type naming conventions established. The first 200 lines of the domain agent's MEMORY.md would be automatically injected into its context at spawn time. Over sessions, the domain agent becomes increasingly knowledgeable about the project's domain model.</detail>
      <source>Cross-reference: sdlc/agents/domain.md + Claude Code persistent memory docs</source>
      <relevance>The domain agent currently starts fresh every invocation and must re-discover project conventions from ARCHITECTURE.md and the codebase. Persistent memory would let it accumulate project-specific knowledge: "In this project, we use nutype for value objects," "Email addresses use the CustomerEmail type, not just Email," "The team decided against NonEmptyVec in ADR-003."</relevance>
      <constraint_impact>ENHANCES - A more knowledgeable domain agent provides better domain review, strengthening domain integrity enforcement without changing the workflow.</constraint_impact>
    </finding>

    <finding category="opportunity">
      <title>Agent Teams for Parallel Code Review</title>
      <detail>The SDLC plugin's code review workflow currently runs three sequential review stages (functional correctness, mutation testing, domain integrity). With agent teams, these three reviewers could work in parallel, each analyzing the code from their perspective, and then share findings. This would significantly reduce review time for large PRs. CRITICAL CONSTRAINT: Agent teams must NOT be used for the TDD cycle (RED/DOMAIN/GREEN/DOMAIN), which must remain strictly sequential.</detail>
      <source>Cross-reference: sdlc review workflow + Claude Code agent teams docs</source>
      <relevance>Code review is the SDLC plugin's most time-consuming single operation. Parallelizing it with agent teams could cut review time significantly. The sequential TDD cycle would be completely unaffected.</relevance>
      <constraint_impact>RISK if applied to TDD cycle; ENHANCES if scoped only to code review and design phases. Must be carefully gated.</constraint_impact>
    </finding>

    <finding category="opportunity">
      <title>Model Routing for Cost Optimization</title>
      <detail>The SDLC plugin sets model: inherit on all 15 agents. Not all agents require the full reasoning power of Opus 4.6. The file-updater agent (config/docs/scripts) could use sonnet. The Explore-like agents (discovery, model-checker) could potentially use sonnet for initial research. The domain agent and architect should use opus for maximum reasoning quality.</detail>
      <source>Cross-reference: sdlc/agents/*.md frontmatter + Claude Code model field docs</source>
      <relevance>Cost optimization without quality degradation. Some agents perform relatively simple tasks (file-updater edits config files per instruction) while others require deep reasoning (domain reviews types for correctness). Routing appropriately saves cost while maintaining quality where it matters.</relevance>
      <constraint_impact>SAFE - Model routing doesn't affect the workflow; just optimizes resource allocation.</constraint_impact>
    </finding>

    <finding category="opportunity">
      <title>Dynamic Context Injection in Skills via !`command`</title>
      <detail>Skills support !`command` syntax that runs shell commands and injects their output into the skill content before Claude sees it. The task-management skill could use !`dot list` to inject the current task list. The tdd-constraints skill could inject the current project's test runner command. The memory-protocol skill could inject the first few lines of the auto memory MEMORY.md.</detail>
      <source>Cross-reference: sdlc/skills/*/SKILL.md + Claude Code skill !`command` docs</source>
      <relevance>Dynamic context injection makes skills more context-aware without increasing their static size. Instead of generic instructions, skills could provide project-specific guidance based on runtime state.</relevance>
      <constraint_impact>SAFE - Additive feature; enhances skill effectiveness without changing their purpose.</constraint_impact>
    </finding>
  </findings>

  <recommendations>
    <recommendation priority="high" effort="medium">
      <action>Upgrade file-type enforcement hooks from prompt to agent hooks on red, green, and domain agents</action>
      <rationale>Prompt-based file-type enforcement relies on path patterns and naming conventions, which are inherently imprecise. Agent hooks can use Read and Grep tools to examine actual file content -- checking for test annotations, unimplemented!() stubs, trait definitions, etc. This makes the enforcement dramatically more reliable and harder to circumvent.</rationale>
      <constraint_preservation>This directly strengthens the existing TDD cycle enforcement. The RED agent can only edit verified test files (content-checked, not just path-checked). The GREEN agent can only edit verified production files. The DOMAIN agent can only edit verified type definition files. The workflow sequence is unchanged; only the precision of enforcement increases.</constraint_preservation>
      <affected_components>Agents: red, green, domain (PreToolUse hooks). Timeout may need to increase from 30s to 60s for agent hooks.</affected_components>
    </recommendation>

    <recommendation priority="high" effort="medium">
      <action>Add PreCompact hook to preserve TDD cycle state through compaction</action>
      <rationale>When auto-compaction triggers during a multi-cycle TDD session, the orchestrator loses track of which phase it's in, what tests were written, and what domain concerns were raised. A PreCompact hook can read the dot CLI task state and recent agent transcripts to inject a structured TDD state summary into the compaction context.</rationale>
      <constraint_preservation>This prevents compaction from breaking the TDD cycle. Without it, the orchestrator may skip domain review or re-do completed phases after compaction. The hook ensures the RED -> DOMAIN -> GREEN -> DOMAIN sequence is maintained even across compaction boundaries.</constraint_preservation>
      <affected_components>New: hooks.json PreCompact entry + new shell script (.claude-plugin/hooks/pre-compact.sh). Reads dot CLI state and recent transcript to build state summary.</affected_components>
    </recommendation>

    <recommendation priority="high" effort="small">
      <action>Add persistent memory to domain agent (memory: project scope)</action>
      <rationale>The domain agent is the guardian of domain integrity but starts fresh every invocation. With persistent memory, it accumulates project-specific knowledge: type conventions, common violations, architectural decisions. This makes it increasingly effective over time. The memory field in frontmatter enables this with minimal configuration.</rationale>
      <constraint_preservation>The domain agent's role and veto power are unchanged. It still reviews after RED and GREEN, still creates type definitions, still pushes back on violations. It simply does so with accumulated project knowledge, making its reviews more precise and its veto decisions more informed.</constraint_preservation>
      <affected_components>Agent: domain (add memory: project to frontmatter). Also consider: code-reviewer (memory: project), architect (memory: project).</affected_components>
    </recommendation>

    <recommendation priority="medium" effort="medium">
      <action>Add SubagentStart hook for TDD agent context injection</action>
      <rationale>The orchestration protocol requires fresh, complete context for every agent invocation. In practice, the orchestrator sometimes omits important context, especially after compaction. A SubagentStart hook matching red|green|domain agents could inject: current TDD phase (from dot CLI), current task description, detected language/framework, and ARCHITECTURE.md existence check.</rationale>
      <constraint_preservation>This supplements (not replaces) the orchestrator's delegation message. The hook provides a reliable baseline of context that the orchestrator cannot forget. The fresh context protocol is strengthened because agents receive both hook-injected context AND orchestrator-provided context.</constraint_preservation>
      <affected_components>New: hooks.json SubagentStart entry + new shell script (.claude-plugin/hooks/subagent-start-context.sh). Reads dot CLI state and project metadata.</affected_components>
    </recommendation>

    <recommendation priority="medium" effort="small">
      <action>Optimize model routing for cost-effective agent execution</action>
      <rationale>Not all 15 agents need Opus-level reasoning. The file-updater agent performs straightforward file edits per instruction and could use sonnet. The domain agent and architect should explicitly use opus for maximum type reasoning quality. This can reduce overall cost without degrading quality where it matters.</rationale>
      <constraint_preservation>The workflow is completely unchanged. Only the model used by each agent changes. The most critical agents (domain, architect, code-reviewer) retain or gain maximum reasoning power. Less critical agents (file-updater) use a faster, cheaper model.</constraint_preservation>
      <affected_components>Agents: file-updater (model: sonnet), domain (model: opus), architect (model: opus), code-reviewer (model: opus). Others remain model: inherit.</affected_components>
    </recommendation>

    <recommendation priority="medium" effort="large">
      <action>Explore agent teams for parallel code review (experimental, gated)</action>
      <rationale>The SDLC plugin's code review currently runs three sequential stages (functional, mutation, domain). Agent teams could parallelize these, cutting review time significantly. This should be experimental and opt-in, gated behind an environment variable or configuration flag.</rationale>
      <constraint_preservation>CRITICAL: Agent teams must be scoped ONLY to the review workflow (/sdlc:review command). They must NEVER be used for the TDD cycle. The implementation should check that the current workflow phase is "review" before offering parallel review. The sequential TDD enforcement (RED -> DOMAIN -> GREEN -> DOMAIN) remains completely independent of any agent team usage.</constraint_preservation>
      <affected_components>Commands: review (optional parallel mode). New: review agent team configuration. Gated behind experimental flag. Does not affect: work command, TDD cycle, any agent's individual behavior.</affected_components>
    </recommendation>

    <recommendation priority="low" effort="small">
      <action>Add dynamic context injection to task-management and tdd-constraints skills</action>
      <rationale>Skills support !`command` syntax for dynamic context. The task-management skill could inject the current dot CLI task list (!`dot list 2>/dev/null || echo "No tasks"`). The tdd-constraints skill could inject detected test runner (!`test -f Cargo.toml && echo "rust/cargo test" || test -f package.json && echo "node/npm test" || echo "unknown"`).</rationale>
      <constraint_preservation>Skills are read-only context providers. Adding dynamic injection makes them more context-aware but doesn't change their role. The TDD constraints skill still enforces the same constraints; it just has better information about the project's test infrastructure.</constraint_preservation>
      <affected_components>Skills: task-management (add !`command` for dot status), tdd-constraints (add !`command` for test runner detection).</affected_components>
    </recommendation>

    <recommendation priority="low" effort="medium">
      <action>Investigate re-enabling orchestrator file-edit block using agent hooks</action>
      <rationale>The file-edit-auth.sh hook is disabled because PreToolUse inputs don't include a reliable is_subagent indicator. An agent hook could potentially determine context by examining the transcript or other signals. However, this requires careful investigation to avoid false positives that would block legitimate subagent file edits.</rationale>
      <constraint_preservation>Re-enabling this enforcement directly strengthens the "orchestrator delegates, never acts directly" principle. However, if the detection is unreliable, it could break the workflow by blocking legitimate agent file edits. This should be investigated carefully before implementation.</constraint_preservation>
      <affected_components>Hooks: PreToolUse for Edit|Write (currently disabled file-edit-auth.sh). Would need to determine a reliable orchestrator vs subagent detection method.</affected_components>
    </recommendation>

    <recommendation priority="low" effort="small">
      <action>Add LSP plugin recommendation to /sdlc:setup command</action>
      <rationale>LSP integration gives agents richer code intelligence (go-to-definition, find-all-references, type info). The setup command could detect the project language and recommend installing the appropriate LSP plugin. This makes the domain agent and code-reviewer more effective when LSP is available.</rationale>
      <constraint_preservation>Optional recommendation; doesn't change any workflow. Agents work exactly the same with or without LSP -- LSP just provides additional code intelligence tools they can optionally use.</constraint_preservation>
      <affected_components>Commands: setup (add LSP recommendation section). Documentation only; no agent changes needed. Agents will naturally use LSP tools if available.</affected_components>
    </recommendation>
  </recommendations>

  <code_examples>
    <!-- Agent hook for file-type enforcement (replacing prompt hook) -->
    <example name="Agent hook for red agent file-type enforcement">
```yaml
# In sdlc/agents/red.md frontmatter hooks section
hooks:
  PreToolUse:
    - matcher: Edit|Write
      hooks:
        - type: agent
          prompt: |
            SDLC RED AGENT FILE-TYPE VERIFICATION

            You must verify this is a test file by examining its content.
            The hook input is: $ARGUMENTS

            Steps:
            1. Extract file_path from the tool_input
            2. Read the file (if it exists) or examine the content being written
            3. Check for test indicators:
               - Test annotations: #[test], #[cfg(test)], describe(), it(), test(), @Test
               - Test framework imports: use ...::test, import { describe } from
               - Test directory patterns: tests/, __tests__/, spec/
               - Test file naming: *_test.*, *.test.*, test_*.*

            Respond with:
            {"ok": true} if this IS a test file (by content, not just path)
            {"ok": false, "reason": "sdlc:red can only edit test files. This file does not contain test code."} if NOT a test file
          timeout: 60
```
    </example>

    <!-- PreCompact hook for TDD state preservation -->
    <example name="PreCompact hook script for TDD state preservation">
```bash
#!/usr/bin/env bash
# .claude-plugin/hooks/pre-compact.sh
# Injects TDD cycle state into compaction context

set -euo pipefail

INPUT=$(cat)
TRIGGER=$(echo "$INPUT" | jq -r '.trigger // "unknown"')

# Gather current TDD state
TDD_STATE=""

# Check dot CLI for current task
if command -v dot &>/dev/null; then
  CURRENT_TASK=$(dot list 2>/dev/null | head -20 || echo "No active tasks")
  TDD_STATE="CURRENT TASKS:\n$CURRENT_TASK\n"
fi

# Build compaction context
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreCompact",
    "additionalContext": "TDD CYCLE STATE (preserve through compaction):\n${TDD_STATE}\nREMINDER: After compaction, check dot CLI for current task state. The TDD cycle is: RED -> DOMAIN (after red) -> GREEN -> DOMAIN (after green). Never skip domain review."
  }
}
EOF
exit 0
```
    </example>

    <!-- SubagentStart hook for context injection -->
    <example name="SubagentStart hook for TDD agent context injection">
```json
{
  "SubagentStart": [
    {
      "matcher": "red|green|domain",
      "hooks": [
        {
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/hooks/tdd-agent-context.sh"
        }
      ]
    }
  ]
}
```

```bash
#!/usr/bin/env bash
# tdd-agent-context.sh - Injects TDD context into agents at spawn
set -euo pipefail

INPUT=$(cat)
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // "unknown"')

CONTEXT="TDD AGENT CONTEXT INJECTION (via SubagentStart hook)\n"
CONTEXT+="Agent: $AGENT_TYPE\n"

# Inject current task info
if command -v dot &>/dev/null; then
  TASKS=$(dot list 2>/dev/null | head -10 || echo "No tasks found")
  CONTEXT+="Current tasks:\n$TASKS\n"
fi

# Check for ARCHITECTURE.md
if [ -f "docs/ARCHITECTURE.md" ]; then
  CONTEXT+="ARCHITECTURE.md: EXISTS (read it before proceeding)\n"
else
  CONTEXT+="ARCHITECTURE.md: NOT FOUND (use general DDD best practices)\n"
fi

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SubagentStart",
    "additionalContext": "$CONTEXT"
  }
}
EOF
exit 0
```
    </example>

    <!-- Domain agent with persistent memory -->
    <example name="Domain agent frontmatter with persistent memory">
```yaml
---
name: domain
description: INVOKE for type definitions. TYPE DEFINITIONS ONLY. Has VETO POWER over domain violations
model: opus
memory: project
skills:
  - user-input-protocol
  - memory-protocol
  - tdd-constraints
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
hooks:
  # ... existing hooks ...
---
```
    </example>
  </code_examples>

  <metadata>
    <confidence level="high">
      Model capabilities (Opus 4.6) are verified against official Anthropic documentation at platform.claude.com. Claude Code features are verified against official documentation at code.claude.com/docs. All hook system details are from the official hooks reference page fetched on 2026-02-05. The SDLC plugin cross-references are from direct file reading of the current v16.0.0 codebase.
    </confidence>
    <dependencies>
      - Claude Code version >= 2.0.74 (for LSP support)
      - Claude Code version supporting agent hooks (type: "agent") -- confirmed in current docs
      - Claude Code version supporting SubagentStart hook -- confirmed in current docs
      - Claude Code version supporting persistent subagent memory -- confirmed in current docs
      - For agent teams: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 (experimental feature)
      - For LSP: ENABLE_LSP_TOOL=1 + language-specific LSP plugin installed
      - dot CLI for task management (existing dependency)
    </dependencies>
    <open_questions>
      1. Does the PreToolUse hook input include any field that reliably distinguishes orchestrator vs subagent context? The docs show tool_name, tool_input, tool_use_id, and common fields (session_id, transcript_path, cwd, permission_mode, hook_event_name). The file-edit-auth.sh notes that transcript_path is identical for both. This needs testing.
      2. How does the agent hook's 50-turn limit interact with complex file verification? For simple "read file and check for test annotations," 50 turns is more than enough, but the timeout of 60s may be tight if the file system is slow.
      3. Will persistent subagent memory work correctly with plugin-defined agents? The docs describe it for user and project agents. Plugin agents may have different directory resolution.
      4. How does the PreCompact hook's additionalContext interact with the compaction process? Does it get included in the summary that survives compaction, or is it just shown to the model during the compaction step?
      5. Agent teams are experimental. How stable are they for production use in the review workflow? What happens if a teammate fails mid-review?
      6. The effort parameter (low/medium/high/max) for adaptive thinking -- can this be controlled per-agent in Claude Code, or is it a session-level setting?
    </open_questions>
    <assumptions>
      1. Agent hooks (type: "agent") are available in plugin hooks.json, not just project settings. The docs mention them alongside other hook types without restricting where they can be defined.
      2. Persistent subagent memory (memory: project) works with plugin-defined agents stored in the plugin's agents/ directory.
      3. The SubagentStart hook fires for plugin-defined agents (not just built-in and user/project agents).
      4. PreCompact hook additionalContext influences what gets preserved during compaction (not just displayed).
      5. Claude Code is currently running Opus 4.6 as its primary model (confirmed by system information showing "Claude Opus 4.6 (1M context)").
    </assumptions>
    <quality_report>
      <sources_consulted>
        - https://platform.claude.com/docs/en/docs/about-claude/models (official model comparison)
        - https://platform.claude.com/docs/en/docs/build-with-claude/extended-thinking (official extended thinking docs)
        - https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking (referenced in extended thinking docs)
        - https://code.claude.com/docs/en/hooks (official hooks reference - full page fetched)
        - https://code.claude.com/docs/en/sub-agents (official subagent docs - full page fetched)
        - https://code.claude.com/docs/en/skills (official skills docs - full page fetched)
        - https://code.claude.com/docs/en/plugins (official plugins docs - full page fetched)
        - https://code.claude.com/docs/en/agent-teams (official agent teams docs - full page fetched)
        - https://www.anthropic.com/news/claude-opus-4-6 (official announcement)
        - https://siliconangle.com/2026/02/05/anthropic-rolls-claude-opus-4-6-1-million-token-context-support/ (news coverage)
        - https://techcrunch.com/2026/02/05/anthropic-releases-opus-4-6-with-new-agent-teams/ (news coverage)
        - https://medium.com/@richardhightower/build-agent-skills-faster-with-claude-code-2-1-release-6d821d5b8179 (Claude Code 2.1 features)
        - sdlc/.claude-plugin/plugin.json (current plugin manifest)
        - sdlc/.claude-plugin/hooks.json (current hooks configuration)
        - sdlc/.claude-plugin/hooks/file-edit-auth.sh (disabled orchestrator block hook)
        - sdlc/.claude-plugin/hooks/session-start.sh (session start hook)
        - sdlc/agents/red.md, green.md, domain.md (TDD agent configurations)
        - sdlc/skills/orchestration-protocol/SKILL.md (orchestration protocol)
      </sources_consulted>
      <claims_verified>
        - Opus 4.6: 1M context (beta), 128K output, adaptive thinking -- verified via official docs
        - Opus 4.6: Terminal-Bench 65.4%, OSWorld 72.7% -- verified via official announcement
        - Opus 4.6: Thinking block preservation across turns -- verified via official docs
        - Claude Code: 12 hook event types -- verified via official hooks reference
        - Claude Code: Agent hooks (type: "agent") -- verified via official hooks reference
        - Claude Code: Async hooks (async: true) -- verified via official hooks reference
        - Claude Code: Persistent subagent memory -- verified via official subagent docs
        - Claude Code: SubagentStart hook with additionalContext -- verified via official hooks reference
        - Claude Code: Skill frontmatter options (context: fork, once: true) -- verified via official skill docs
        - Claude Code: Agent teams (experimental) -- verified via official agent teams docs
        - Claude Code: LSP integration -- verified via official plugin docs and community sources
        - Claude Code: CLAUDE_ENV_FILE in SessionStart -- verified via official hooks reference
        - SDLC plugin: file-edit-auth.sh disabled with documented reason -- verified by reading the file
        - SDLC plugin: 15 agents, 12 commands, 9 skills -- verified by file listing
      </claims_verified>
      <claims_assumed>
        - Agent hooks work in plugin hooks.json (not just project settings) -- assumed from docs not restricting this
        - Persistent memory works with plugin-defined agents -- assumed; docs describe it for user/project agents
        - SubagentStart hook fires for plugin-defined agents -- assumed; docs describe it for all agents
        - PreCompact additionalContext survives compaction -- assumed; docs say it's "added to compaction context"
        - Agent hook file verification would be reliable enough to replace prompt hooks -- assumed based on capability description
      </claims_assumed>
      <contradictions_encountered>
        - Claude Code 2.1 is referenced in medium articles but the official docs don't use version numbers for Claude Code itself. Resolved: features are confirmed regardless of version labeling.
        - The file-edit-auth.sh comment says "Re-enable when Claude Code adds is_subagent field." Current hook docs still don't show this field. However, agent hooks provide an alternative approach that may work around this limitation.
        - News articles mention "agent teams" as a headline Opus 4.6 feature, but official Claude Code docs label them experimental with known limitations. Resolved: treating as experimental with careful scoping.
      </contradictions_encountered>
      <confidence_by_finding>
        - Opus 4.6 model capabilities: HIGH (verified via official docs)
        - Agent hooks feature: HIGH (verified via official hooks reference)
        - SubagentStart context injection: HIGH (verified via official hooks reference)
        - Persistent subagent memory: HIGH (verified via official subagent docs)
        - Agent teams for parallel review: MEDIUM (experimental feature, stability unclear)
        - Re-enabling file-edit-auth via agent hooks: MEDIUM (theoretically possible, needs testing)
        - PreCompact state preservation: MEDIUM (additionalContext behavior during compaction needs verification)
        - LSP integration benefit for domain agent: MEDIUM (depends on user having LSP configured)
        - Dynamic skill context injection: HIGH (well-documented feature)
      </confidence_by_finding>
    </quality_report>
  </metadata>
</research>
