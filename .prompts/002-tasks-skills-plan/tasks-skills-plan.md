# sdlc Plugin Redesign: Tasks & Skills Integration Plan

**Created:** 2026-02-04
**Version:** 1.0
**Research Basis:** `.prompts/001-tasks-skills-research/tasks-skills-research.md`

---

<plan>
  <summary>
    This plan redesigns the sdlc plugin to leverage Claude Code's built-in tasks system for workflow orchestration while extracting 10 reusable protocol skills for distribution via skills.sh marketplace. The approach uses a three-layer architecture: portable skills (teaching principles), structural tasks (enforcing workflow order), and Claude Code-specific hooks (validating behavior). The redesign proceeds through 7 phases: analyzing current agents for extractable components, designing standalone skill structure, defining task integration patterns, extracting skills to top-level directory, restructuring agents as lightweight skill loaders, integrating with skills.sh marketplace, and documenting migration paths. This maintains backward compatibility through the existing command interface while enabling incremental adoption of task-based workflows and wider distribution of TDD/domain modeling principles beyond Claude Code users.
  </summary>

  <phases>
    <phase number="1" name="analysis-and-extraction">
      <objective>
        Inventory all 15 sdlc agents and 10 shared protocols to identify extractable components. Map which capabilities should become standalone skills (portable), which should remain plugin-specific (hooks, tool restrictions), and which workflows should use task orchestration (multi-step with dependencies).
      </objective>
      <tasks>
        <task priority="high">Analyze each of the 15 agents: identify skills they load, tools they use, hooks they define, and unique capabilities</task>
        <task priority="high">Map the 10 shared protocols to skill extraction candidates: orchestration, memory-protocol, tdd-constraints, event-modeling, atomic-design, github-issues, user-input-protocol, git-spice, skill-enforcement, debugging-protocol</task>
        <task priority="high">Identify workflows suitable for task orchestration: /work command (research → plan → implement), /review command (three-stage review), /design command (event modeling steps)</task>
        <task priority="medium">Document agent dependencies: which agents spawn other agents, which require specific context, which have cross-cutting concerns</task>
        <task priority="medium">Identify reusable patterns within agent prompts: GWT test generation, domain modeling principles, hook patterns for constraint enforcement</task>
        <task priority="medium">Catalog external integrations: gh CLI usage, git-spice workflows, Memento MCP patterns</task>
        <task priority="low">Document anti-patterns and constraints to preserve: invocation gates (may replace with tasks), workflow discipline (hooks enforce), orchestrator delegation-only pattern</task>
      </tasks>
      <deliverables>
        <deliverable>Analysis document: agents-inventory.md with agent-by-agent breakdown</deliverable>
        <deliverable>Extraction map: skills-extraction-map.md listing 10 shared protocols → skills mapping</deliverable>
        <deliverable>Workflow map: task-workflows.md identifying commands suitable for task orchestration</deliverable>
        <deliverable>Integration inventory: external-integrations.md documenting gh, git-spice, memento patterns</deliverable>
      </deliverables>
      <dependencies>
        Research findings from tasks-skills-research.md (already complete)
      </dependencies>
      <verification>
        - All 15 agents documented with skills/tools/hooks breakdown
        - All 10 shared protocols evaluated for extraction
        - At least 3 commands identified as task-orchestration candidates
        - External integration patterns cataloged
      </verification>
    </phase>

    <phase number="2" name="skill-structure-design">
      <objective>
        Design the top-level skills/ directory structure and SKILL.md manifest format for extracted protocols. Define skill dependency mechanism, installation workflow via npx skills, and integration with Claude Code's skill discovery. Ensure skills are portable across agent frameworks while maintaining Claude Code-specific enhancements.
      </objective>
      <tasks>
        <task priority="high">Design top-level directory structure: skills/tdd-constraints/SKILL.md, skills/orchestration-protocol/SKILL.md, etc.</task>
        <task priority="high">Create SKILL.md template with YAML frontmatter (name, description, metadata fields) and markdown body structure</task>
        <task priority="high">Define skill naming conventions: lowercase-with-hyphens, descriptive but concise</task>
        <task priority="high">Design skill dependency mechanism: how skills reference other skills (if supported by skills.sh format)</task>
        <task priority="medium">Plan skill versioning strategy: semantic versioning independent of sdlc plugin versions</task>
        <task priority="medium">Define skill metadata fields: internal flag, tags/categories for discovery, compatibility notes</task>
        <task priority="medium">Design installation workflow: npx skills add jwilger/sdlc-skills vs npx skills add jwilger/sdlc-skills --skill "tdd-constraints"</task>
        <task priority="medium">Plan GitHub repository structure: single repo with multiple skills vs separate repos per skill</task>
        <task priority="low">Document skill lazy-loading strategy: when skills should auto-load vs manual invocation</task>
      </tasks>
      <deliverables>
        <deliverable>Skill structure specification: skill-structure.md with directory layout, naming conventions, manifest format</deliverable>
        <deliverable>SKILL.md template: templates/SKILL.template.md for consistent skill creation</deliverable>
        <deliverable>Installation guide: skill-installation.md documenting npx workflows</deliverable>
        <deliverable>Repository plan: repository-structure.md defining GitHub organization</deliverable>
      </deliverables>
      <dependencies>
        Phase 1 completion (skills-extraction-map.md identifies which protocols to extract)
      </dependencies>
      <verification>
        - Directory structure supports all 10 identified skills
        - SKILL.md template follows skills.sh official format
        - Installation workflow tested with npx skills (dry run or example)
        - Naming conventions applied to all extracted skills
      </verification>
    </phase>

    <phase number="3" name="task-integration-pattern">
      <objective>
        Define how sdlc agents and commands use Claude Code's task system for workflow orchestration. Design task creation patterns, dependency graphs, metadata conventions, and task lifecycle management. Replace invocation gates with structural task dependencies while maintaining workflow discipline.
      </objective>
      <tasks>
        <task priority="high">Define when to create tasks vs inline execution: multi-step workflows (3+ steps), complex commands (/work, /review, /design), TDD cycles (red → domain → green → domain)</task>
        <task priority="high">Design task metadata conventions: feature identifier, slice_number, cycle_number, acceptance_criterion, phase, file paths, memento checkpoint IDs</task>
        <task priority="high">Create task dependency patterns for TDD workflow: red task → domain-after-red task → green task → domain-after-green task</task>
        <task priority="high">Design orchestrator task creation pattern: lightweight agent creates graph, spawns subagents with task context</task>
        <task priority="medium">Define task naming conventions: subject (imperative: "Write failing test"), activeForm (present continuous: "Writing failing test"), description (detailed context)</task>
        <task priority="medium">Design task resumption pattern: how agents use TaskList + TaskGet to resume interrupted workflows</task>
        <task priority="medium">Plan invocation gate migration: Phase 1 (tasks + gates redundant), Phase 2 (TaskList primary, gates defensive), Phase 3 (gates removed)</task>
        <task priority="medium">Design agent self-assignment pattern: agents poll TaskList for owner=self, status=pending, no blockedBy</task>
        <task priority="low">Define task cleanup/archival strategy: when to mark tasks deleted, how long to retain completed tasks</task>
        <task priority="low">Design parallel task execution strategy: which workflows benefit from background tasks (mutation testing, code review stages)</task>
      </tasks>
      <deliverables>
        <deliverable>Task integration specification: task-patterns.md with creation patterns, dependency graphs, metadata schema</deliverable>
        <deliverable>TDD workflow task graph: tdd-task-graph.md showing red → domain → green → domain with blockedBy relationships</deliverable>
        <deliverable>Task metadata schema: task-metadata-schema.json with standard fields and examples</deliverable>
        <deliverable>Migration strategy: gate-to-task-migration.md with phased approach and verification steps</deliverable>
      </deliverables>
      <dependencies>
        Phase 1 completion (workflow map identifies task-suitable commands)
        Phase 2 completion (skills structure supports orchestration protocols)
      </dependencies>
      <verification>
        - Task patterns defined for at least 3 major workflows (/work, /review, /design)
        - TDD cycle modeled as task graph with clear dependencies
        - Metadata schema supports workflow resumption
        - Migration strategy preserves backward compatibility
      </verification>
    </phase>

    <phase number="4" name="skill-extraction">
      <objective>
        Extract the 10 shared protocols from sdlc plugin to standalone skills in top-level skills/ directory. Convert each protocol to SKILL.md format, test standalone functionality, and ensure portability across agent frameworks while maintaining Claude Code-specific enhancements.
      </objective>
      <tasks>
        <task priority="high">Extract tdd-constraints skill: red/green/domain phase boundaries, one assertion rule, workflow order mandate</task>
        <task priority="high">Extract orchestration-protocol skill: agent delegation rules, file operation hierarchy, workflow state management</task>
        <task priority="high">Extract memory-protocol skill: Memento MCP integration patterns, checkpoint creation, semantic search usage</task>
        <task priority="high">Extract user-input-protocol skill: checkpoint format, question format, user interaction patterns</task>
        <task priority="high">Extract event-modeling skill: Event Modeling patterns, diagram generation, workflow/model-checker integration</task>
        <task priority="medium">Extract github-issues skill: gh CLI patterns, issue creation, sub-issue workflows, project management</task>
        <task priority="medium">Extract git-spice skill: stacked PR workflows, branch navigation, restack patterns</task>
        <task priority="medium">Extract debugging-protocol skill: systematic debugging approach, evidence collection, hypothesis testing</task>
        <task priority="medium">Extract atomic-design skill: UI component hierarchy, composition patterns, design system principles</task>
        <task priority="low">Extract skill-enforcement skill: invocation discipline, self-improvement patterns (may deprecate if tasks replace gates)</task>
        <task priority="low">Test each extracted skill standalone: verify SKILL.md format, check for Claude Code-specific dependencies, ensure portability</task>
      </tasks>
      <deliverables>
        <deliverable>skills/tdd-constraints/SKILL.md: TDD phase boundaries and responsibilities</deliverable>
        <deliverable>skills/orchestration-protocol/SKILL.md: Agent delegation and workflow coordination</deliverable>
        <deliverable>skills/memory-protocol/SKILL.md: Memento MCP integration patterns</deliverable>
        <deliverable>skills/user-input-protocol/SKILL.md: User interaction and checkpoint formats</deliverable>
        <deliverable>skills/event-modeling/SKILL.md: Event Modeling principles and patterns</deliverable>
        <deliverable>skills/github-issues/SKILL.md: GitHub CLI and issue management patterns</deliverable>
        <deliverable>skills/git-spice/SKILL.md: Stacked PR workflow patterns</deliverable>
        <deliverable>skills/debugging-protocol/SKILL.md: Systematic debugging approach</deliverable>
        <deliverable>skills/atomic-design/SKILL.md: UI component design patterns</deliverable>
        <deliverable>skills/skill-enforcement/SKILL.md: Invocation discipline (optional, may deprecate)</deliverable>
      </deliverables>
      <dependencies>
        Phase 2 completion (skill structure and template defined)
        Phase 3 completion (task patterns may inform orchestration-protocol skill)
      </dependencies>
      <verification>
        - All 10 skills extracted to top-level skills/ directory
        - Each SKILL.md follows template format with valid YAML frontmatter
        - Skills contain no hardcoded references to sdlc plugin paths
        - Skills document principles (portable) separate from enforcement (hooks remain in plugin)
      </verification>
      <execution_notes>
        Extraction order (simplest to most complex):
        1. Start with tdd-constraints (most self-contained, core to sdlc)
        2. Extract user-input-protocol (small, clear boundaries)
        3. Extract debugging-protocol (standalone methodology)
        4. Extract atomic-design (UI patterns, independent)
        5. Extract git-spice (tool-specific patterns)
        6. Extract github-issues (tool-specific patterns)
        7. Extract memory-protocol (MCP integration, some complexity)
        8. Extract event-modeling (references multiple agents, more complex)
        9. Extract orchestration-protocol (references other skills, most complex)
        10. Extract skill-enforcement last (may deprecate if tasks replace invocation gates)

        For each extraction:
        - Read current sdlc/commands/shared/[protocol].md
        - Identify Claude Code-specific elements (keep in plugin)
        - Identify portable principles (extract to skill)
        - Convert to SKILL.md format with frontmatter
        - Add examples and anti-patterns
        - Document assumptions and prerequisites
        - Test that skill contains no broken references
      </execution_notes>
    </phase>

    <phase number="5" name="agent-restructuring">
      <objective>
        Rewrite sdlc agents as lightweight skill loaders that compose extracted skills rather than duplicating protocols. Maintain backward compatibility with existing command interfaces. Update agent frontmatter to reference skills from top-level directory. Preserve hooks and tool restrictions (Claude Code-specific features).
      </objective>
      <tasks>
        <task priority="high">Create lightweight orchestrator agent: loads orchestration-protocol + tdd-constraints skills, uses TaskCreate/TaskUpdate/TaskList, disallows Write/Edit, spawns subagents</task>
        <task priority="high">Update red agent: load tdd-constraints + user-input-protocol + memory-protocol skills, preserve hooks for test-file-only constraint, update to reference top-level skills/</task>
        <task priority="high">Update domain agent: load tdd-constraints + memory-protocol skills, preserve hooks for type-definition-only constraint, add task awareness (check TaskList for context)</task>
        <task priority="high">Update green agent: load tdd-constraints skill, preserve minimal implementation principle, add task awareness</task>
        <task priority="high">Update code-reviewer agent: load debugging-protocol skill, restructure as three tasks (initial → deep-dive → final) with dependencies</task>
        <task priority="medium">Update mutation agent: load tdd-constraints skill, prepare for background task execution (no AskUserQuestion, pre-approved permissions)</task>
        <task priority="medium">Update story agent: load orchestration-protocol skill for sub-issue creation, maintain gh CLI integration</task>
        <task priority="medium">Update workflow-designer agent: load event-modeling skill, maintain Event Modeling diagram generation</task>
        <task priority="medium">Update model-checker agent: load event-modeling skill, maintain validation rules</task>
        <task priority="medium">Update design-facilitator agent: load event-modeling + user-input-protocol skills, coordinate workflow-designer and model-checker</task>
        <task priority="low">Update gwt agent: extract GWT test generation pattern as internal skill or keep in agent prompt (small, specialized)</task>
        <task priority="low">Update architect, ux, discovery agents: load appropriate skills (orchestration, memory, user-input protocols)</task>
        <task priority="low">Update adr, file-updater agents: load minimal skills, keep most logic in agent prompts</task>
        <task priority="low">Update all agent frontmatter: change skills: field from sdlc:shared/protocol to top-level skill names</task>
      </tasks>
      <deliverables>
        <deliverable>sdlc/agents/orchestrator.md: New lightweight orchestrator with task-based coordination</deliverable>
        <deliverable>sdlc/agents/red.md: Updated to load skills/ directory skills, preserve hooks</deliverable>
        <deliverable>sdlc/agents/domain.md: Updated to load skills, preserve hooks, add task awareness</deliverable>
        <deliverable>sdlc/agents/green.md: Updated to load skills, add task awareness</deliverable>
        <deliverable>sdlc/agents/code-reviewer.md: Updated with task-based three-stage review</deliverable>
        <deliverable>sdlc/agents/mutation.md: Updated for background task execution</deliverable>
        <deliverable>sdlc/agents/[remaining-agents].md: All agents updated to reference top-level skills</deliverable>
        <deliverable>Agent migration log: agents-migration.md documenting changes to each agent</deliverable>
      </deliverables>
      <dependencies>
        Phase 4 completion (all skills extracted and available in skills/ directory)
        Phase 3 completion (task patterns defined for agent restructuring)
      </dependencies>
      <verification>
        - All 15+ agents updated to reference skills/ directory (not sdlc:shared/)
        - Orchestrator agent created with TaskCreate/TaskUpdate/TaskList tools
        - Red, domain, green agents load tdd-constraints skill
        - Hooks preserved in agents that require constraint enforcement
        - No agent duplicates content from extracted skills
        - Backward compatibility maintained (existing commands still work)
      </verification>
      <execution_notes>
        Agent restructuring order (core workflow first):
        1. Create orchestrator agent (new, defines task-based coordination)
        2. Update red agent (core TDD, hooks critical)
        3. Update domain agent (core TDD, hooks critical)
        4. Update green agent (core TDD, completes cycle)
        5. Update code-reviewer (refactor to task-based stages)
        6. Update mutation agent (prepare for background)
        7. Update story, workflow-designer, model-checker, design-facilitator (event modeling group)
        8. Update architect, ux, discovery (research group)
        9. Update gwt, adr, file-updater (utility agents)

        For each agent restructuring:
        - Identify current skills loaded (from frontmatter)
        - Map sdlc:shared/protocol references to skills/ directory
        - Update skills: field in YAML frontmatter
        - Remove duplicated protocol content from agent prompt
        - Preserve agent-specific instructions
        - Preserve hooks (if any)
        - Add task awareness (TaskList checking) if workflow-critical
        - Test that agent still functions with updated skill references
        - Document breaking changes (if any) in migration log

        Backward compatibility preservation:
        - Existing commands (/sdlc:work, /sdlc:review, etc.) continue to work
        - Commands invoke orchestrator or spawn agents as before
        - Task creation is internal implementation detail (transparent to users)
        - Invocation gates remain as defensive checks during migration
        - Memento MCP integration unchanged
        - gh CLI and git-spice workflows unchanged
      </execution_notes>
    </phase>

    <phase number="6" name="marketplace-integration">
      <objective>
        Publish extracted skills to top-level skills/ directory as standalone installable package. Update plugin marketplace.json to reference skills. Configure npx skills installation workflow. Verify skills are discoverable via skills.sh platform and work across multiple agent frameworks.
      </objective>
      <tasks>
        <task priority="high">Create top-level skills/ directory with all 10 extracted skills</task>
        <task priority="high">Create skills/README.md documenting available skills, installation instructions, usage examples</task>
        <task priority="high">Test npx skills add installation: verify skills install to .claude/skills/, verify Claude Code discovers them, verify agents can load them</task>
        <task priority="high">Update .claude-plugin/marketplace.json to include skills path or reference external skill repository</task>
        <task priority="medium">Create package.json or manifest for skills repository (if publishing as separate package)</task>
        <task priority="medium">Test skill portability: verify skills work in at least one other agent framework (Cursor or Windsurf) if accessible</task>
        <task priority="medium">Submit skills to skills.sh marketplace: follow submission guidelines, await security audit, configure telemetry</task>
        <task priority="medium">Create skill examples and test fixtures: demonstrate skill usage in isolation, provide templates for users</task>
        <task priority="low">Configure skill versioning independent of sdlc plugin: semantic versioning for skills, changelog per skill</task>
        <task priority="low">Set up GitHub repository for skills: jwilger/sdlc-skills or integrate into claude-code-plugins with top-level skills/</task>
      </tasks>
      <deliverables>
        <deliverable>skills/README.md: Comprehensive skill documentation with installation and usage</deliverable>
        <deliverable>skills/[skill-name]/SKILL.md: All 10 skills in top-level directory</deliverable>
        <deliverable>skills/examples/: Example usage for each skill</deliverable>
        <deliverable>.claude-plugin/marketplace.json: Updated to reference skills</deliverable>
        <deliverable>Installation verification: Test results from npx skills add</deliverable>
        <deliverable>skills.sh submission: Confirmation of marketplace listing or pending review</deliverable>
      </deliverables>
      <dependencies>
        Phase 4 completion (skills extracted)
        Phase 5 completion (agents updated to reference skills)
      </dependencies>
      <verification>
        - All 10 skills present in top-level skills/ directory
        - npx skills add successfully installs skills to .claude/skills/
        - Claude Code discovers and loads skills from .claude/skills/
        - Agents can reference skills by name (no path errors)
        - skills.sh submission completed or in progress
        - README.md provides clear installation and usage instructions
      </verification>
    </phase>

    <phase number="7" name="documentation-and-migration">
      <objective>
        Create comprehensive migration guide for existing sdlc plugin users. Update CLAUDE.md with new architecture. Document skill usage, task workflows, and breaking changes. Provide version migration path and troubleshooting guidance. Ensure users can adopt incrementally or continue with existing workflows.
      </objective>
      <tasks>
        <task priority="high">Create MIGRATION.md: guide for users upgrading from v3.12.x to v4.0.0, document breaking changes, provide step-by-step migration</task>
        <task priority="high">Update CLAUDE.md: document new architecture (skills + tasks + hooks), update version management section, add skills installation instructions</task>
        <task priority="high">Update sdlc/commands/setup.md: increment version to 4.0.0, add skill installation prompts, add task system explanation</task>
        <task priority="high">Create CHANGELOG.md: comprehensive changelog from v3.12.8 to v4.0.0, highlight task integration, skill extraction, agent restructuring</task>
        <task priority="medium">Document task workflow patterns: create docs/task-workflows.md with examples for /work, /review, /design commands</task>
        <task priority="medium">Document skill usage: create skills/USAGE.md with examples of loading skills, composing skills, customizing skills</task>
        <task priority="medium">Create troubleshooting guide: common issues (skill not found, task dependencies, hook failures), solutions, debugging steps</task>
        <task priority="medium">Update plugin manifest version: bump to 4.0.0 in .claude-plugin/plugin.json and .claude-plugin/marketplace.json</task>
        <task priority="low">Create video or demo walkthrough: demonstrate task-based workflow, show skill installation, highlight benefits</task>
        <task priority="low">Update agent documentation: add inline comments to agents explaining task integration, skill loading, hook purposes</task>
      </tasks>
      <deliverables>
        <deliverable>MIGRATION.md: Comprehensive migration guide from v3.x to v4.0</deliverable>
        <deliverable>CLAUDE.md: Updated repository instructions with new architecture</deliverable>
        <deliverable>CHANGELOG.md: Detailed changelog documenting all changes</deliverable>
        <deliverable>sdlc/commands/setup.md: Updated to v4.0.0 with skill installation</deliverable>
        <deliverable>docs/task-workflows.md: Task integration patterns and examples</deliverable>
        <deliverable>skills/USAGE.md: Skill usage guide with examples</deliverable>
        <deliverable>docs/TROUBLESHOOTING.md: Common issues and solutions</deliverable>
        <deliverable>Updated plugin manifests: v4.0.0 in plugin.json and marketplace.json</deliverable>
      </deliverables>
      <dependencies>
        Phase 5 completion (agents restructured)
        Phase 6 completion (skills published and tested)
      </dependencies>
      <verification>
        - MIGRATION.md addresses all breaking changes and provides clear upgrade path
        - CLAUDE.md accurately reflects new architecture
        - CHANGELOG.md documents all changes from v3.12.8 to v4.0.0
        - setup.md version updated to 4.0.0 with all hardcoded version strings changed
        - plugin.json and marketplace.json both show version 4.0.0
        - Documentation tested by following migration steps manually
      </verification>
    </phase>

  </phases>

  <metadata>
    <confidence level="high">
      High confidence in this plan based on:
      - Thorough research findings documented in tasks-skills-research.md
      - Direct access to Claude Code tool definitions (TaskCreate, TaskUpdate, TaskGet, TaskList)
      - Official skills.sh format specification from vercel-labs/skills repository
      - Analysis of current sdlc plugin structure (15 agents, 10 shared protocols well-factored)
      - Clear separation between portable knowledge (skills), structural enforcement (tasks), and Claude Code-specific features (hooks)

      The three-layer architecture (skills teach, tasks structure, hooks validate) provides natural extraction boundaries. The phased approach allows incremental progress and validation at each step. The existing sdlc plugin is well-positioned for this redesign due to its already-clean separation of shared protocols from agent-specific logic.

      Medium confidence areas:
      - Task system scalability with many active tasks (research suggests good but not production-tested)
      - Skills.sh marketplace adoption and discoverability (platform is new, January 2026 launch)
      - Agent self-assignment patterns (designed for but not demonstrated in practice)
      - Background task viability for mutation testing (documented but untested in sdlc context)

      Lower confidence on user migration experience - existing users may have customizations or workflows that aren't fully captured in this plan. Migration testing with real users would validate approach.
    </confidence>

    <dependencies>
      External dependencies for implementation:
      - Claude Code 2.1+ with built-in task system (TaskCreate, TaskUpdate, TaskGet, TaskList tools)
      - skills CLI (npx skills) for skill installation and distribution
      - GitHub repository for extracted skills (jwilger/sdlc-skills or top-level skills/ in claude-code-plugins)
      - skills.sh platform for skill discovery and marketplace listing
      - (Optional) Memento MCP server for memory integration (remains unchanged)
      - (Optional) git-spice CLI for stacked PR workflows (remains unchanged)
      - gh CLI with extensions (gh-issue-ext, gh-project-ext, gh-pr-review) - unchanged from current sdlc

      Build/development dependencies:
      - YAML frontmatter parser for SKILL.md validation
      - Markdown linter for skill content quality
      - Testing framework for skill standalone functionality
      - Semantic versioning tooling for independent skill versions

      Process dependencies:
      - skills.sh security audit (if submitting to marketplace)
      - User testing for migration guide validation
      - Backward compatibility testing with existing sdlc installations
    </dependencies>

    <open_questions>
      Uncertainties that may affect execution:

      1. Skill dependency mechanism:
         - Can SKILL.md files reference other skills explicitly?
         - How do skills.sh and Claude Code handle skill-to-skill dependencies?
         - Should orchestration-protocol skill list tdd-constraints as a dependency?

      2. GitHub integration in extracted skills:
         - Should github-issues skill document gh CLI patterns (tool-agnostic) or include Claude Code-specific invocation examples?
         - How to handle skills that reference external tools (gh, git-spice) that may not be installed?
         - Should skills include installation verification or assume prerequisites?

      3. Marvin output style location:
         - Should Marvin personality remain sdlc plugin-specific or become a skill?
         - Output styles are Claude Code-specific, but personality could be portable instructions
         - Would other agent frameworks benefit from Marvin's pessimistic debugging approach?

      4. Version migration for customizations:
         - If existing users have forked agents or customized shared protocols, how do they migrate?
         - Should migration guide include "how to preserve customizations" section?
         - Can we detect customizations and warn during upgrade?

      5. Task persistence across plugin updates:
         - When sdlc plugin updates from v3.12.8 to v4.0.0, do existing tasks survive?
         - How to handle tasks created by old version being processed by new version?
         - Should there be task schema versioning?

      6. Skill namespace collision:
         - If user installs tdd-constraints from multiple sources, which one loads?
         - How does Claude Code resolve skill name conflicts?
         - Should skills use namespaced names (jwilger-tdd-constraints) or rely on directory structure?

      7. Background task MCP limitation workaround:
         - Mutation agent needs Memento for storing results but background tasks can't use MCP
         - Should mutation agent run foreground, pre-load Memento data, or store in task metadata?
         - Is there a hybrid approach (background for execution, foreground for storage)?
    </open_questions>

    <assumptions>
      Critical assumptions made in creating this plan:

      1. Research findings accuracy:
         - Tasks system behavior matches tool documentation (dependencies enforced, metadata persists)
         - skills.sh format is stable and won't change significantly
         - Background task limitations are accurately documented

      2. Skills portability:
         - SKILL.md format works across Cursor, Windsurf, and other agents with minimal adaptation
         - Claude Code-specific examples in skills can be clearly marked as such
         - Other agent frameworks have similar enough architectures to benefit from sdlc principles

      3. Backward compatibility viability:
         - Existing command interface (/sdlc:work, /sdlc:review, etc.) can remain unchanged
         - Task creation can be transparent to users (internal implementation detail)
         - Skill references can change from sdlc:shared/ to skills/ without breaking agents

      4. User acceptance:
         - Existing sdlc users are willing to adopt v4.0.0 if migration path is clear
         - Users see value in task-based workflows (progress tracking, resumability)
         - Users understand distinction between skills (portable) and plugin (Claude Code-specific)

      5. Marketplace dynamics:
         - skills.sh marketplace will drive discovery and adoption of extracted skills
         - Skill telemetry will provide useful feedback on which patterns get actual use
         - Security audit process is reasonable and won't block distribution

      6. Task system capabilities:
         - Task dependencies are strictly enforced (cannot start blocked task)
         - Task metadata has sufficient size limits for workflow context
         - TaskList performance is acceptable with dozens of active tasks
         - CLAUDE_CODE_TASK_LIST_ID enables cross-session persistence reliably

      7. Skill loading performance:
         - Loading 3-5 skills into agent context doesn't significantly increase latency
         - Lazy loading works as documented (skills load on first use, not session start)
         - Skill content size is reasonable (protocols are documentation, not massive codebases)

      8. Hook preservation:
         - Hooks continue to work when agents load skills from different location
         - Hook prompt-based validation remains reliable
         - Hooks can reference skill content (or skills provide context hooks need)

      9. Orchestrator viability:
         - Lightweight orchestrator agent can effectively coordinate workflow using only tasks
         - Haiku model is sufficient for orchestration logic (cheap, fast)
         - Disallowing Write/Edit in orchestrator doesn't break existing workflows

      10. Incremental adoption:
          - Users can adopt task-based workflows gradually (one command at a time)
          - Invocation gates can coexist with tasks during migration
          - Phase 3 (removing gates entirely) is optional for users who prefer them
    </assumptions>
  </metadata>
</plan>
