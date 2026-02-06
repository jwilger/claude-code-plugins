<plan>
  <summary>
    This plan enhances the SDLC plugin (v16.0.0 -> v17.0.0) to leverage Opus 4.6 and Claude Code 2.1 capabilities in five phases, ordered by impact-to-effort ratio. The core SDLC workflow (RED -> DOMAIN -> GREEN -> DOMAIN, mechanical enforcement, orchestrator-delegates, fresh context, event modeling) is treated as inviolable throughout. Phase 1 adds persistent memory to key agents and optimizes model routing -- both high-impact, low-effort frontmatter changes. Phase 2 adds a PreCompact hook to preserve TDD cycle state through compaction and a SubagentStart hook for reliable context injection -- addressing two of the most painful workflow failure modes. Phase 3 upgrades file-type enforcement hooks from prompt to agent type for content-based verification. Phase 4 adds dynamic context injection to skills via the !`command` syntax. Phase 5 explores agent teams for parallel code review as an experimental, opt-in capability. Every phase is independently testable, revertible, and preserves the complete SDLC workflow.
  </summary>

  <constraint_verification_protocol>
    After each phase, run these checks to verify the core SDLC workflow is intact:

    1. TDD CYCLE ENFORCEMENT
       - Verify SubagentStop hooks still contain domain review checkpoint prompt
       - Verify hooks.json still contains the Stop hook for incomplete todo detection
       - Confirm the orchestration-protocol skill still documents RED -> DOMAIN -> GREEN -> DOMAIN
       - Check that red.md, green.md, domain.md agents all still have PreToolUse hooks for file-type enforcement

    2. AGENT FILE-TYPE RESTRICTIONS
       - Verify red.md PreToolUse hook blocks non-test files
       - Verify green.md PreToolUse hook blocks test and type-definition files
       - Verify domain.md PreToolUse hook blocks test and implementation files
       - Verify file-updater.md PreToolUse hook blocks specialized file types

    3. DOMAIN REVIEW MANDATORY
       - Verify SubagentStop hooks still enforce domain review after red and green agents
       - Verify the "DOMAIN REVIEW CHECKPOINT (MANDATORY)" prompt is present in hooks.json

    4. ORCHESTRATOR DELEGATES PATTERN
       - Verify SubagentStop orchestration reminder hook is present in hooks.json
       - Verify the setup.md still generates file-edit-auth.sh for project-level enforcement
       - Verify orchestration-protocol skill is still listed in plugin commands

    5. FRESH CONTEXT PROTOCOL
       - Verify orchestration-protocol skill still contains "Fresh Context Per Agent" principle
       - Verify agents still require explicit context in delegation (no "continue from before")

    6. EVENT MODELING INTEGRATION
       - Verify all event modeling agents exist: discovery, workflow-designer, gwt, model-checker, design-facilitator
       - Verify event-modeling skill exists in skills/

    7. LOCAL TASK MANAGEMENT
       - Verify task-management skill references dot CLI
       - Verify setup.md still configures dot CLI initialization

    8. ALL COMMANDS FUNCTIONAL
       - Verify all 13 command files exist in sdlc/commands/ (including shared/orchestration.md)
       - Verify plugin.json lists all commands
       - Verify all 15 agent files exist in sdlc/agents/
       - Verify plugin.json lists all agents

    9. VERSION CONSISTENCY
       - Verify sdlc/.claude-plugin/plugin.json version matches
       - Verify .claude-plugin/marketplace.json sdlc version matches
       - Verify sdlc/commands/setup.md version strings match
  </constraint_verification_protocol>

  <phases>
    <!-- ============================================================ -->
    <!-- PHASE 1: Agent Memory and Model Routing (HIGH impact, LOW effort) -->
    <!-- ============================================================ -->
    <phase number="1" name="agent-memory-and-model-routing">
      <objective>Add persistent memory to domain, code-reviewer, and architect agents. Optimize model routing so critical reasoning agents use opus and utility agents use sonnet. These are frontmatter-only changes with zero risk to workflow logic.</objective>
      <rationale>Highest impact-to-effort ratio. Adding `memory: project` and changing `model:` fields are single-line frontmatter changes that require no new scripts, no hook modifications, and no template changes. Persistent memory directly addresses the "starting fresh every invocation" problem for the domain agent, which is the guardian of domain integrity. Model routing saves cost without degrading quality. Both are verified Claude Code features with high confidence.</rationale>
      <tasks>
        <task priority="high">
          <description>Add `memory: project` to domain agent frontmatter. This gives the domain agent persistent project-scoped memory for accumulating type conventions, common violations, architectural patterns, and domain modeling decisions across sessions.</description>
          <affected_files>
            - sdlc/agents/domain.md
          </affected_files>
          <acceptance_criteria>
            - domain.md frontmatter includes `memory: project`
            - Domain agent body text mentions using memory to recall project conventions
            - A brief note added to the "Architecture Alignment" section about checking persistent memory for project-specific conventions
          </acceptance_criteria>
          <constraint_check>SAFE: Only adds memory capability to domain agent. Does not change the agent's role, veto power, file restrictions, or workflow position. The domain agent still runs after RED and GREEN, still creates type definitions, still has veto authority. Memory makes it more effective, not different.</constraint_check>
        </task>

        <task priority="high">
          <description>Add `memory: project` to code-reviewer agent frontmatter. This lets the code-reviewer accumulate knowledge about recurring code quality patterns, common issues in the project, and review history.</description>
          <affected_files>
            - sdlc/agents/code-reviewer.md
          </affected_files>
          <acceptance_criteria>
            - code-reviewer.md frontmatter includes `memory: project`
            - Code-reviewer body text mentions checking memory for past review patterns
          </acceptance_criteria>
          <constraint_check>SAFE: Code-reviewer is a read-only analysis agent. Adding memory doesn't change its three-stage review process or its relationship to the TDD cycle.</constraint_check>
        </task>

        <task priority="high">
          <description>Add `memory: project` to architect agent frontmatter. This lets the architect accumulate knowledge about technical decisions, complexity assessments, and architectural evolution.</description>
          <affected_files>
            - sdlc/agents/architect.md
          </affected_files>
          <acceptance_criteria>
            - architect.md frontmatter includes `memory: project`
            - Architect body text mentions checking memory for previous architecture reviews
          </acceptance_criteria>
          <constraint_check>SAFE: Architect is an analysis agent that only edits ARCHITECTURE.md. Adding memory doesn't change its scope or constraints.</constraint_check>
        </task>

        <task priority="medium">
          <description>Set `model: opus` on domain, code-reviewer, and architect agents. Set `model: sonnet` on file-updater agent. These agents have different reasoning needs: domain/code-reviewer/architect benefit from maximum reasoning quality, while file-updater performs straightforward edits.</description>
          <affected_files>
            - sdlc/agents/domain.md
            - sdlc/agents/code-reviewer.md
            - sdlc/agents/architect.md
            - sdlc/agents/file-updater.md
          </affected_files>
          <acceptance_criteria>
            - domain.md has `model: opus`
            - code-reviewer.md has `model: opus`
            - architect.md has `model: opus`
            - file-updater.md has `model: sonnet`
            - All other agents retain `model: inherit`
          </acceptance_criteria>
          <constraint_check>SAFE: Model routing doesn't change any workflow logic, hook behavior, or agent constraints. The TDD cycle sequence is completely unaffected. Agents perform the same roles with the same file restrictions; only the underlying model changes.</constraint_check>
        </task>
      </tasks>
      <deliverables>
        <deliverable>Domain, code-reviewer, and architect agents with persistent project memory</deliverable>
        <deliverable>Optimized model routing across all 15 agents</deliverable>
      </deliverables>
      <dependencies>None. These are self-contained frontmatter changes.</dependencies>
      <rollback>Revert the 4 agent markdown files to their pre-change state. Memory directories (.claude/agent-memory/) can be deleted if needed. Model fields can be set back to `inherit`.</rollback>
      <constraint_verification>
        1. Read domain.md, green.md, red.md frontmatter -- verify all PreToolUse hooks unchanged
        2. Read hooks.json -- verify SubagentStop domain review checkpoint unchanged
        3. Verify all 15 agent files listed in plugin.json still exist
        4. Verify all 13 command files listed in plugin.json still exist
        5. Verify orchestration-protocol skill still contains fresh context and orchestrator-delegates principles
        6. Run `grep -c "memory: project" sdlc/agents/*.md` -- should show exactly 3
        7. Run `grep "model: opus" sdlc/agents/*.md` -- should show domain, code-reviewer, architect
        8. Run `grep "model: sonnet" sdlc/agents/*.md` -- should show file-updater
        9. Run `grep "model: inherit" sdlc/agents/*.md` -- should show all remaining agents
      </constraint_verification>
    </phase>

    <!-- ============================================================ -->
    <!-- PHASE 2: TDD State Preservation and Context Injection Hooks -->
    <!-- ============================================================ -->
    <phase number="2" name="tdd-state-preservation-hooks">
      <objective>Add a PreCompact hook that preserves TDD cycle state through context compaction, and a SubagentStart hook that injects dynamic context (task state, project metadata, ARCHITECTURE.md existence) into TDD agents at spawn time. These two hooks address the most common workflow failure modes: state loss during compaction and incomplete context provision.</objective>
      <rationale>Second-highest impact-to-effort ratio. State loss during compaction causes the orchestrator to lose track of the TDD phase, repeat work, or skip domain reviews. The SubagentStart hook provides a hook-enforced context baseline that the orchestrator cannot forget. Both are medium-effort (new shell scripts + hooks.json entries) but address high-severity pain points that directly threaten workflow integrity.</rationale>
      <tasks>
        <task priority="high">
          <description>Create a PreCompact command hook script at `sdlc/.claude-plugin/hooks/pre-compact.sh` that reads the current dot CLI task state and injects a structured TDD cycle state summary into the compaction context. The hook should extract: current active tasks from dot CLI, detected TDD phase (inferred from task metadata if available), and a reminder about the RED -> DOMAIN -> GREEN -> DOMAIN sequence.</description>
          <affected_files>
            - sdlc/.claude-plugin/hooks/pre-compact.sh (NEW)
            - sdlc/.claude-plugin/hooks.json (add PreCompact entry)
          </affected_files>
          <acceptance_criteria>
            - pre-compact.sh exists, is executable, and produces valid JSON with hookSpecificOutput
            - hooks.json has a PreCompact entry referencing the script
            - The additionalContext includes: current dot CLI task state, TDD cycle reminder, and instruction to check dot CLI after compaction
            - Script handles gracefully if dot CLI is not installed (no crash)
            - Script handles gracefully if no active tasks exist
          </acceptance_criteria>
          <constraint_check>ENHANCES TDD ENFORCEMENT: This directly strengthens the RED -> DOMAIN -> GREEN -> DOMAIN cycle by preventing state loss during compaction. Without this, compaction can cause the orchestrator to skip domain review or re-do completed phases. The hook only injects context; it does not change any workflow logic or agent behavior.</constraint_check>
        </task>

        <task priority="high">
          <description>Create a SubagentStart command hook script at `sdlc/.claude-plugin/hooks/subagent-start-context.sh` that fires when red, green, or domain agents spawn. The hook should inject: current dot CLI active task info, ARCHITECTURE.md existence check, and the current TDD phase context. Use a matcher of "red|green|domain" to scope to TDD agents only.</description>
          <affected_files>
            - sdlc/.claude-plugin/hooks/subagent-start-context.sh (NEW)
            - sdlc/.claude-plugin/hooks.json (add SubagentStart entry)
          </affected_files>
          <acceptance_criteria>
            - subagent-start-context.sh exists, is executable, and produces valid JSON with hookSpecificOutput
            - hooks.json has a SubagentStart entry with matcher "red|green|domain" referencing the script
            - The additionalContext includes: agent type identification, current task info from dot CLI, ARCHITECTURE.md existence, TDD cycle position
            - Script handles gracefully if dot CLI is not installed
            - Script handles gracefully if ARCHITECTURE.md does not exist
            - Other agents (not matching red|green|domain) are unaffected
          </acceptance_criteria>
          <constraint_check>ENHANCES FRESH CONTEXT PROTOCOL: This supplements (does NOT replace) the orchestrator's delegation message with reliable, hook-enforced context. The orchestrator still must provide full context per the fresh context protocol. The hook provides a baseline that catches omissions. It does not change agent behavior, file restrictions, or workflow sequence.</constraint_check>
        </task>

        <task priority="medium">
          <description>Update the setup.md command to generate the PreCompact hook in the project-level `.claude/hooks/pre-compact.sh` (Step 7c already exists but currently only reminds about memory saves). Update the hook to also include TDD state preservation matching the plugin-level hook behavior. Also update Step 8 and Step 9 to include the project-level hook configuration.</description>
          <affected_files>
            - sdlc/commands/setup.md (update Step 7c pre-compact.sh template, update Step 8 hooks structure)
          </affected_files>
          <acceptance_criteria>
            - setup.md Step 7c pre-compact.sh template includes TDD state preservation (dot CLI task state, TDD cycle reminder)
            - setup.md Step 8 hook structure includes the updated PreCompact hook
            - Existing project-level hooks still work (SubagentStop, SessionStart, Stop)
          </acceptance_criteria>
          <constraint_check>SAFE: Updates generated project-level hooks to mirror plugin-level improvements. Does not change any workflow logic. The setup command still generates the same hook categories; the PreCompact hook content is enhanced.</constraint_check>
        </task>
      </tasks>
      <deliverables>
        <deliverable>Plugin-level PreCompact hook for TDD state preservation through compaction</deliverable>
        <deliverable>Plugin-level SubagentStart hook for TDD agent context injection</deliverable>
        <deliverable>Updated setup.md with enhanced project-level PreCompact hook</deliverable>
      </deliverables>
      <dependencies>None (Phase 1 is not a prerequisite; phases are independent).</dependencies>
      <rollback>Remove the two new hook scripts from sdlc/.claude-plugin/hooks/. Remove the PreCompact and SubagentStart entries from hooks.json. Revert setup.md changes. The plugin returns to its v16 hook behavior.</rollback>
      <constraint_verification>
        1. Read hooks.json -- verify ALL existing hooks are unchanged (Stop, PreToolUse gh-api-check, SubagentStop domain review, SubagentStop orchestration reminder, SubagentStop question detection, SessionStart)
        2. Read hooks.json -- verify PreCompact and SubagentStart entries are additive (not replacing existing entries)
        3. Run `bash -n sdlc/.claude-plugin/hooks/pre-compact.sh` -- verify script syntax is valid
        4. Run `bash -n sdlc/.claude-plugin/hooks/subagent-start-context.sh` -- verify script syntax is valid
        5. Run `jq . sdlc/.claude-plugin/hooks.json` -- verify valid JSON
        6. Verify pre-compact.sh output is valid JSON with hookSpecificOutput.hookEventName = "PreCompact"
        7. Verify subagent-start-context.sh output is valid JSON with hookSpecificOutput.hookEventName = "SubagentStart"
        8. Verify all 15 agents still exist in plugin.json
        9. Verify all 13 commands still exist in plugin.json
        10. Read setup.md -- verify version strings, Step 7c content, and Step 8/9 hook structures
      </constraint_verification>
    </phase>

    <!-- ============================================================ -->
    <!-- PHASE 3: Upgrade File-Type Enforcement to Agent Hooks -->
    <!-- ============================================================ -->
    <phase number="3" name="agent-hook-file-enforcement">
      <objective>Upgrade the PreToolUse hooks on red, green, and domain agents from `type: prompt` to `type: agent`, enabling content-based file verification instead of path-pattern-based checks. Agent hooks can use Read and Grep tools to examine actual file content -- checking for test annotations, unimplemented!() stubs, trait definitions, etc. -- making enforcement dramatically more reliable.</objective>
      <rationale>This addresses a fundamental limitation: prompt-based file-type enforcement relies on path patterns and naming conventions, which are inherently imprecise. A file in `src/` that contains `#[test]` is a test file despite its path, and a file in `tests/` that contains production logic is not truly a test file. Agent hooks resolve this ambiguity by inspecting content. The effort is medium (rewriting hook prompts for agent type, increasing timeout), but the impact on enforcement reliability is high.</rationale>
      <tasks>
        <task priority="high">
          <description>Upgrade red agent PreToolUse hooks (Edit and Write matchers) from `type: prompt` to `type: agent`. The agent hook prompt should instruct the verification agent to: (1) extract file_path from tool_input, (2) read the file if it exists, (3) check for test indicators (test annotations, test framework imports, test directory patterns, test file naming), and (4) return ok/not-ok based on content verification. Set timeout to 60 seconds (agent hooks default).</description>
          <affected_files>
            - sdlc/agents/red.md (PreToolUse hooks section)
          </affected_files>
          <acceptance_criteria>
            - red.md PreToolUse Edit hook has `type: agent` instead of `type: prompt`
            - red.md PreToolUse Write hook has `type: agent` instead of `type: prompt`
            - Agent hook prompt instructs verification of test content (annotations, imports, directory patterns)
            - Timeout is set to 60 seconds
            - PostToolUse hooks are unchanged (still `type: prompt`)
            - Stop hook is unchanged
            - The hook still returns {"ok": true/false} format
            - Rejection reason still mentions "sdlc:red can only edit test files"
          </acceptance_criteria>
          <constraint_check>ENHANCES TDD FILE RESTRICTIONS: This makes the RED phase file-type enforcement MORE precise, not less. The RED agent still can only edit test files; the verification is now content-based instead of path-based. The workflow sequence (RED -> DOMAIN -> GREEN -> DOMAIN) is completely unchanged.</constraint_check>
        </task>

        <task priority="high">
          <description>Upgrade green agent PreToolUse hooks (Edit and Write matchers) from `type: prompt` to `type: agent`. The agent hook prompt should verify: (1) file is in production code location, (2) file is NOT a test file (by content inspection), (3) file is NOT a type-only definition file. Set timeout to 60 seconds.</description>
          <affected_files>
            - sdlc/agents/green.md (PreToolUse hooks section)
          </affected_files>
          <acceptance_criteria>
            - green.md PreToolUse Edit hook has `type: agent` instead of `type: prompt`
            - green.md PreToolUse Write hook has `type: agent` instead of `type: prompt`
            - Agent hook prompt instructs content-based verification of production code
            - Timeout is set to 60 seconds
            - PostToolUse and Stop hooks unchanged
            - Returns {"ok": true/false} format
          </acceptance_criteria>
          <constraint_check>ENHANCES TDD FILE RESTRICTIONS: GREEN agent enforcement becomes more precise. Still can only edit production implementation code, but now verified by content inspection.</constraint_check>
        </task>

        <task priority="high">
          <description>Upgrade domain agent PreToolUse hooks (Edit and Write matchers) from `type: prompt` to `type: agent`. The agent hook prompt should verify: (1) file contains type definitions (structs, enums, traits, interfaces), (2) function bodies contain only unimplemented!() or equivalent stubs, (3) file is NOT a test file, (4) file does NOT contain implementation logic beyond stubs. Set timeout to 60 seconds.</description>
          <affected_files>
            - sdlc/agents/domain.md (PreToolUse hooks section)
          </affected_files>
          <acceptance_criteria>
            - domain.md PreToolUse Edit hook has `type: agent` instead of `type: prompt`
            - domain.md PreToolUse Write hook has `type: agent` instead of `type: prompt`
            - Agent hook prompt instructs content-based verification of type definition files
            - Special attention to verifying function bodies are stubs only
            - Timeout is set to 60 seconds
            - PostToolUse and Stop hooks unchanged
            - Returns {"ok": true/false} format
          </acceptance_criteria>
          <constraint_check>ENHANCES TDD FILE RESTRICTIONS: DOMAIN agent enforcement becomes more precise. Critical check that function bodies are stubs (not implementations) is now content-verified rather than path-guessed.</constraint_check>
        </task>

        <task priority="low">
          <description>Upgrade file-updater agent PreToolUse hooks from `type: prompt` to `type: agent` for more reliable scope enforcement. The agent hook can inspect file content to distinguish between config/docs (allowed) and specialized files (blocked).</description>
          <affected_files>
            - sdlc/agents/file-updater.md (PreToolUse hooks section)
          </affected_files>
          <acceptance_criteria>
            - file-updater.md PreToolUse hooks have `type: agent`
            - Agent hook verifies content-based scope (config/docs/scripts allowed, code/tests/types blocked)
            - Timeout is set to 60 seconds
          </acceptance_criteria>
          <constraint_check>SAFE: File-updater scope enforcement is tightened. Does not affect TDD cycle agents.</constraint_check>
        </task>

        <task priority="low">
          <description>Upgrade architect agent PreToolUse hooks from `type: prompt` to `type: agent` for more reliable ARCHITECTURE.md-only enforcement.</description>
          <affected_files>
            - sdlc/agents/architect.md (PreToolUse hooks section)
          </affected_files>
          <acceptance_criteria>
            - architect.md PreToolUse hooks have `type: agent`
            - Agent hook verifies file is specifically ARCHITECTURE.md (by path and content)
            - Timeout is set to 60 seconds
          </acceptance_criteria>
          <constraint_check>SAFE: Architect scope enforcement is tightened. Does not affect TDD cycle.</constraint_check>
        </task>
      </tasks>
      <deliverables>
        <deliverable>Content-based file-type enforcement on all TDD agents (red, green, domain)</deliverable>
        <deliverable>Content-based scope enforcement on file-updater and architect agents</deliverable>
      </deliverables>
      <dependencies>None (independent of Phases 1 and 2).</dependencies>
      <rollback>Revert each agent's PreToolUse hooks back to `type: prompt` with the original prompt text. The enforcement becomes path-based again but still functional.</rollback>
      <constraint_verification>
        1. Read red.md -- verify PreToolUse hooks exist with `type: agent` and appropriate prompts
        2. Read green.md -- verify PreToolUse hooks exist with `type: agent` and appropriate prompts
        3. Read domain.md -- verify PreToolUse hooks exist with `type: agent` and appropriate prompts
        4. Verify PostToolUse hooks on red, green, domain are UNCHANGED (still `type: prompt`)
        5. Verify Stop hooks on red, green, domain are UNCHANGED
        6. Read hooks.json -- verify SubagentStop domain review checkpoint is present and unchanged
        7. Read hooks.json -- verify SubagentStop orchestration reminder is present and unchanged
        8. Verify red.md still blocks non-test files (just with agent verification now)
        9. Verify green.md still blocks test and type-only files
        10. Verify domain.md still blocks test and implementation files
        11. All 15 agents still listed in plugin.json
        12. All 13 commands still listed in plugin.json
      </constraint_verification>
    </phase>

    <!-- ============================================================ -->
    <!-- PHASE 4: Dynamic Skill Context Injection -->
    <!-- ============================================================ -->
    <phase number="4" name="dynamic-skill-context">
      <objective>Add dynamic context injection to the task-management and tdd-constraints skills using the !`command` syntax, making skills aware of runtime project state (current tasks, detected test runner, project language) without increasing their static size.</objective>
      <rationale>Low effort (adding !`command` lines to skill frontmatter or body) with meaningful usability improvement. Skills currently provide generic guidance; dynamic injection lets them provide project-specific information. The task-management skill can show current dot CLI task state, and the tdd-constraints skill can inject the detected test runner command. This is a well-documented, high-confidence feature.</rationale>
      <tasks>
        <task priority="medium">
          <description>Add dynamic context injection to the task-management skill. Insert a !`command` block that runs `dot ls --status active 2>/dev/null || echo "No active tasks (dot CLI not available or no tasks)"` to inject current active task state into the skill content at load time.</description>
          <affected_files>
            - sdlc/skills/task-management/SKILL.md
          </affected_files>
          <acceptance_criteria>
            - SKILL.md contains a !`command` block that injects dot CLI active task state
            - The command handles gracefully when dot CLI is not installed
            - The command handles gracefully when no active tasks exist
            - The rest of the skill content is unchanged
          </acceptance_criteria>
          <constraint_check>SAFE: Skills are read-only context providers. Adding dynamic injection makes the skill more context-aware but does not change any workflow logic, agent behavior, or hook enforcement. The task-management skill still teaches the same patterns; it just has better information about current state.</constraint_check>
        </task>

        <task priority="medium">
          <description>Add dynamic context injection to the tdd-constraints skill. Insert a !`command` block that detects the project's primary language and test runner: checks for Cargo.toml (cargo test), package.json (npm test/npx jest/npx vitest), pyproject.toml (pytest), go.mod (go test), mix.exs (mix test). Inject the detected test command into the skill context.</description>
          <affected_files>
            - sdlc/skills/tdd-constraints/SKILL.md
          </affected_files>
          <acceptance_criteria>
            - SKILL.md contains a !`command` block that detects the project test runner
            - Detection covers: Rust, TypeScript/JavaScript, Python, Go, Elixir
            - Falls back gracefully to "unknown test runner" if nothing detected
            - The rest of the skill content is unchanged
            - The injected context is a brief string, not verbose output
          </acceptance_criteria>
          <constraint_check>SAFE: The tdd-constraints skill still enforces the same RED -> DOMAIN -> GREEN -> DOMAIN constraints. Dynamic injection adds project-specific test runner information but does not change any constraint logic.</constraint_check>
        </task>

        <task priority="low">
          <description>Add dynamic context injection to the memory-protocol skill. Insert a !`command` block that checks if the memory directory exists and shows a brief summary of available memory categories.</description>
          <affected_files>
            - sdlc/skills/memory-protocol/SKILL.md
          </affected_files>
          <acceptance_criteria>
            - SKILL.md contains a !`command` block that checks memory directory
            - Handles gracefully when memory directory doesn't exist
            - Shows brief listing of available memory subdirectories if they exist
          </acceptance_criteria>
          <constraint_check>SAFE: Memory protocol skill is a utility skill. Dynamic injection adds awareness of existing memory state but doesn't change any workflow.</constraint_check>
        </task>
      </tasks>
      <deliverables>
        <deliverable>Task-management skill with live task state injection</deliverable>
        <deliverable>TDD-constraints skill with detected test runner injection</deliverable>
        <deliverable>Memory-protocol skill with memory directory state injection</deliverable>
      </deliverables>
      <dependencies>None (independent of all other phases).</dependencies>
      <rollback>Remove the !`command` blocks from each skill file. Skills return to static-only content.</rollback>
      <constraint_verification>
        1. Read each modified skill SKILL.md -- verify !`command` blocks are syntactically correct
        2. Verify the rest of each skill's content is unchanged
        3. Verify tdd-constraints skill still documents RED -> DOMAIN -> GREEN -> DOMAIN cycle
        4. Verify task-management skill still documents dot CLI usage patterns
        5. Verify all 9 skills are still listed in sdlc/skills/ (count skill directories)
        6. Verify plugin.json skills path unchanged
        7. Verify all 15 agents still exist
        8. Verify all 13 commands still exist
      </constraint_verification>
    </phase>

    <!-- ============================================================ -->
    <!-- PHASE 5: Experimental Agent Teams for Parallel Code Review -->
    <!-- ============================================================ -->
    <phase number="5" name="experimental-parallel-review">
      <objective>Explore agent teams for parallel code review as an experimental, opt-in capability. This would allow the three code review stages (spec compliance, code quality, domain integrity) to run in parallel instead of sequentially, significantly reducing review time for large PRs. CRITICAL: This must NEVER apply to the TDD cycle, which must remain strictly sequential.</objective>
      <rationale>Lowest priority due to experimental status and largest implementation effort. Agent teams are labeled experimental in Claude Code docs. However, code review is the most time-consuming single operation in the SDLC workflow, and parallelizing it could provide significant time savings. This phase is gated behind an environment variable and scoped exclusively to the review workflow.</rationale>
      <tasks>
        <task priority="medium">
          <description>Research and document agent teams behavior with a spike. Test: (1) Can agent teams be spawned from within a plugin command? (2) How do teammates share findings? (3) What happens when a teammate fails? (4) How does task coordination work? Document findings in a design doc at sdlc/docs/agent-teams-spike.md before proceeding with implementation.</description>
          <affected_files>
            - sdlc/docs/agent-teams-spike.md (NEW - spike documentation)
          </affected_files>
          <acceptance_criteria>
            - Spike document exists with findings from testing agent teams
            - Document covers: API compatibility, failure modes, teammate communication, task coordination
            - Document includes a Go/No-Go recommendation
            - If No-Go: document why and what would need to change for future consideration
          </acceptance_criteria>
          <constraint_check>SAFE: This is a research task that produces documentation only. No workflow code is modified. No agents are changed. The spike does not affect the running plugin.</constraint_check>
        </task>

        <task priority="low">
          <description>If spike is Go: Add an experimental parallel review mode to the review command. Gate behind `SDLC_EXPERIMENTAL_PARALLEL_REVIEW=1` environment variable. When enabled, the three review stages (spec compliance, code quality, domain integrity) run as parallel agent team members instead of sequentially. When disabled (default), review works exactly as today.</description>
          <affected_files>
            - sdlc/commands/review.md (add parallel review option)
          </affected_files>
          <acceptance_criteria>
            - Default behavior (no env var) is IDENTICAL to current sequential review
            - With SDLC_EXPERIMENTAL_PARALLEL_REVIEW=1, reviews run in parallel
            - Parallel mode still produces the same three-stage output format
            - Parallel mode still requires all three stages to pass
            - TDD cycle agents are completely unaffected
            - If agent teams are not available (Claude Code version doesn't support them), falls back to sequential
          </acceptance_criteria>
          <constraint_check>CRITICAL VERIFICATION: The TDD cycle (RED -> DOMAIN -> GREEN -> DOMAIN) must remain strictly sequential. This parallel mode applies ONLY to the code review workflow invoked by /sdlc:review. Verify: (1) No changes to SubagentStop hooks that enforce domain review, (2) No changes to red/green/domain agent configurations, (3) The parallel review mode is gated behind an explicit environment variable, (4) Default behavior is unchanged.</constraint_check>
        </task>

        <task priority="low">
          <description>Add LSP plugin recommendation to the setup command. Detect the project language and suggest appropriate LSP plugins that would enhance the domain agent's type-checking and the code-reviewer's analysis. This is informational only -- no agent changes needed since agents naturally use LSP tools if available.</description>
          <affected_files>
            - sdlc/commands/setup.md (add LSP recommendation section after Step 12)
          </affected_files>
          <acceptance_criteria>
            - Setup command detects project language and suggests LSP plugins
            - Recommendation is informational (not blocking)
            - Includes instructions for ENABLE_LSP_TOOL=1 environment variable
            - Does not modify any agent configurations
          </acceptance_criteria>
          <constraint_check>SAFE: This is a documentation/recommendation change in the setup command. No agents, hooks, or workflow logic are modified. Agents will use LSP tools if available without any changes to their configurations.</constraint_check>
        </task>
      </tasks>
      <deliverables>
        <deliverable>Agent teams spike documentation with Go/No-Go recommendation</deliverable>
        <deliverable>Experimental parallel review mode (if spike is Go)</deliverable>
        <deliverable>LSP plugin recommendation in setup command</deliverable>
      </deliverables>
      <dependencies>Phases 1-4 should be complete (stable baseline). Agent teams require CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1.</dependencies>
      <rollback>Remove agent-teams-spike.md. Revert review.md changes. Revert setup.md LSP section. Plugin returns to sequential review and no LSP recommendation.</rollback>
      <constraint_verification>
        1. CRITICAL: Verify SubagentStop domain review checkpoint hook is UNCHANGED
        2. CRITICAL: Verify red/green/domain agent PreToolUse hooks are UNCHANGED
        3. CRITICAL: Verify TDD cycle sequence documentation is UNCHANGED in orchestration-protocol skill and tdd-constraints skill
        4. Verify /sdlc:review with NO environment variable produces identical behavior to pre-phase behavior
        5. Verify all 15 agents still exist in plugin.json
        6. Verify all 13 commands still exist in plugin.json
        7. Verify hooks.json is UNCHANGED from Phase 2 state
        8. Verify setup.md version strings are correct
      </constraint_verification>
    </phase>
  </phases>

  <version_management>
    Version bump strategy:

    Phase 1 (agent memory + model routing): Minor bump to v17.0.0
    - New capability (persistent memory) that changes agent behavior
    - Model routing is a behavioral change (different model per agent)
    - Not breaking: all commands/hooks/workflow remain identical
    - Files to update: sdlc/.claude-plugin/plugin.json, .claude-plugin/marketplace.json, sdlc/commands/setup.md (all version strings)

    Phase 2 (PreCompact + SubagentStart hooks): Patch bump to v17.1.0
    - New hooks are additive (no existing behavior changed)
    - setup.md template updates are non-breaking
    - Files to update: same 3 files

    Phase 3 (agent hook enforcement): Patch bump to v17.2.0
    - Hook type change (prompt -> agent) is internal improvement
    - External behavior is identical (same allow/deny decisions)
    - Files to update: same 3 files

    Phase 4 (dynamic skill context): Patch bump to v17.3.0
    - Skill content changes are additive
    - No breaking changes
    - Files to update: same 3 files

    Phase 5 (experimental parallel review): Minor bump to v18.0.0
    - New experimental capability
    - Optional but potentially changes review workflow behavior
    - Gated behind environment variable so default behavior is stable
    - Files to update: same 3 files

    Alternative: If all phases are delivered as a single release, bump directly to v17.0.0 with Phase 5 items noted as experimental.

    The 3-file update checklist for each version bump:
    1. sdlc/.claude-plugin/plugin.json -- "version" field
    2. .claude-plugin/marketplace.json -- "version" field for sdlc entry
    3. sdlc/commands/setup.md -- ALL hardcoded version strings (grep for old version, replace all instances)
  </version_management>

  <risk_assessment>
    <risk severity="high">
      <description>Agent hooks (type: "agent") may not work correctly in plugin-defined agent frontmatter hooks. The documentation describes agent hooks alongside other types but doesn't explicitly confirm they work when defined inside an agent's own hooks section (where the agent hook would spawn a sub-sub-agent to verify the parent agent's file edit).</description>
      <mitigation>Phase 3 is designed to be independently revertible. If agent hooks don't work in agent frontmatter, revert to prompt hooks. Test on a single agent (red.md) first before upgrading all three TDD agents. Keep the original prompt hook text as comments for easy revert.</mitigation>
      <detection>If agent hooks fail: the PreToolUse verification will time out or error, causing all file edits by the agent to be blocked. This is immediately visible because the agent cannot make any progress.</detection>
    </risk>

    <risk severity="high">
      <description>Persistent subagent memory may not work with plugin-defined agents. The documentation describes memory for user/project agents but doesn't explicitly confirm plugin agents. Memory directories may resolve differently for plugin agents.</description>
      <mitigation>Phase 1 is low-effort to revert (remove `memory: project` from frontmatter). Test on the domain agent first. Check that .claude/agent-memory/domain/ is created and accessible. If plugin agents can't use memory, remove the field -- agents continue to work exactly as before.</mitigation>
      <detection>If memory doesn't work: the agent will not find a memory directory, and the memory-related instructions in its system prompt will be inert. This is a graceful degradation -- the agent works normally, just without persistent memory.</detection>
    </risk>

    <risk severity="medium">
      <description>PreCompact hook additionalContext may not survive compaction. The docs say it's "added to compaction context" but don't guarantee the information persists in the post-compaction summary. If the compaction algorithm discards the TDD state summary, the hook provides no benefit.</description>
      <mitigation>Even if the hook's additionalContext doesn't fully survive compaction, it provides useful context DURING the compaction step, which may influence what the compaction algorithm preserves. Additionally, the SubagentStart hook provides a separate mechanism for injecting TDD context that doesn't depend on compaction behavior.</mitigation>
      <detection>After a compaction event, check if the orchestrator still knows the current TDD phase. If it doesn't, the PreCompact hook didn't effectively preserve state. This can be observed by asking "what TDD phase am I in?" after compaction.</detection>
    </risk>

    <risk severity="medium">
      <description>Agent hooks may be significantly slower than prompt hooks, adding latency to every file edit in TDD agents. With a 60-second timeout and up to 50 turns of investigation, an agent hook that's overly thorough could slow down the TDD cycle noticeably.</description>
      <mitigation>Write agent hook prompts to be efficient: read the file path first, check obvious indicators (directory, file name), only read file content if the path-based check is ambiguous. Most files will be clearly test or non-test from their path alone. Set explicit instructions to respond quickly when the answer is obvious.</mitigation>
      <detection>Monitor the time between file edit attempts and edit completion. If agent hooks consistently take more than 5-10 seconds, they're too slow and should be optimized or reverted to prompt hooks.</detection>
    </risk>

    <risk severity="medium">
      <description>Dynamic skill context injection via !`command` may cause skill loading failures if the command fails or produces unexpected output. A broken dot CLI command could prevent the task-management skill from loading.</description>
      <mitigation>All !`command` blocks must include error handling: redirect stderr, use `|| echo "fallback"` patterns, and produce minimal output. Test each command in isolation. Skills should degrade gracefully if the command fails -- they still have their static content.</mitigation>
      <detection>If a skill fails to load, Claude Code will report a skill loading error. The agent will still function but without the skill's context. Test by running skills in a project without dot CLI installed.</detection>
    </risk>

    <risk severity="low">
      <description>Model routing (model: sonnet on file-updater) may produce lower quality output for edge cases where the file-updater needs to understand complex project context. The file-updater is scoped to config/docs/scripts, but some config files can be complex.</description>
      <mitigation>Monitor file-updater output quality. If sonnet produces inadequate results, change file-updater back to `model: inherit`. The most critical agents (domain, code-reviewer, architect) are explicitly set to opus, so the TDD workflow quality is protected.</mitigation>
      <detection>Review file-updater output for quality issues: incorrect formatting, misunderstood instructions, incomplete edits. If issues appear, revert to `model: inherit`.</detection>
    </risk>

    <risk severity="low">
      <description>Agent teams (Phase 5) are experimental and may be unstable. A teammate failure during parallel review could leave the review in an inconsistent state.</description>
      <mitigation>Phase 5 is gated behind an environment variable and includes a spike task to evaluate stability before implementation. Default behavior (sequential review) is always available. The parallel mode includes a fallback to sequential if agent teams are unavailable.</mitigation>
      <detection>If parallel review fails, the review command will produce an error or incomplete output. The user can re-run with sequential mode (without the environment variable).</detection>
    </risk>
  </risk_assessment>

  <metadata>
    <confidence level="high">
      Phases 1-4 use well-documented, high-confidence Claude Code features verified against official documentation (code.claude.com/docs). Persistent memory, model routing, PreCompact hooks, SubagentStart hooks, and skill !`command` syntax are all confirmed in official docs. Phase 3 (agent hooks in agent frontmatter) has slightly lower confidence due to the nested agent context question, but the feature itself is documented. Phase 5 (agent teams) has medium confidence due to its experimental status. The constraint verification protocol ensures workflow integrity at every step.
    </confidence>
    <dependencies>
      - Claude Code version supporting agent hooks (type: "agent") -- confirmed in current docs
      - Claude Code version supporting SubagentStart hook -- confirmed in current docs
      - Claude Code version supporting persistent subagent memory -- confirmed in current docs
      - Claude Code version supporting skill !`command` syntax -- confirmed in current docs
      - dot CLI for task management (existing dependency)
      - For Phase 5: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 (experimental feature)
      - For LSP recommendation: ENABLE_LSP_TOOL=1 + language-specific LSP plugin
    </dependencies>
    <open_questions>
      1. Do agent hooks (type: "agent") work when defined inside a plugin agent's frontmatter hooks section? This creates a sub-sub-agent for verification. Need to test in Phase 3.
      2. Does persistent subagent memory (memory: project) work correctly with plugin-defined agents? Memory directory resolution may differ for plugins.
      3. Does PreCompact additionalContext actually survive compaction, or is it only shown during the compaction step? Need to test in Phase 2.
      4. What is the actual latency of agent hooks vs prompt hooks for file verification? If agent hooks are too slow (over 10 seconds), Phase 3 may need to be adjusted.
      5. How stable are agent teams for production use? Phase 5 spike will answer this.
      6. Can the effort parameter (low/medium/high/max) be controlled per-agent in Claude Code, or is it session-level? If per-agent, we could set different effort levels for different agents.
    </open_questions>
    <assumptions>
      1. Agent hooks (type: "agent") are available in plugin hooks and agent frontmatter hooks, not just project settings.
      2. Persistent subagent memory (memory: project) works with plugin-defined agents.
      3. The SubagentStart hook fires for plugin-defined agents.
      4. PreCompact hook additionalContext influences what gets preserved during compaction.
      5. Skill !`command` syntax works with commands that reference project-local tools (dot CLI).
      6. The 3-file version update requirement (plugin.json, marketplace.json, setup.md) will continue to be the version management pattern.
      7. All phases can be implemented and tested independently within a single working session each.
    </assumptions>
  </metadata>
</plan>
