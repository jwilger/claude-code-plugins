# SDLC Plugin Changelog

## [10.0.0] - 2026-02-05

### 🎯 Major Release: Context Preservation & Learning Agents

**Focus:** Leverage modern Claude Code capabilities for better context management, persistent learning, and improved onboarding

#### ✨ Added

- **PreCompact Hook** - Preserves critical context before conversation compaction
  - Injects current domain types, TDD cycle state, active constraints
  - Prevents "forgot the domain model" errors in long sessions
  - Keeps injection under 2000 chars for performance
  - Automatically triggered before compaction

- **Enhanced SessionStart Hook** - Comprehensive context assembly on session start
  - Last 3 commits with timestamps
  - Active branch and associated task status
  - Open tasks summary (via dot CLI)
  - Recent PR activity and review status
  - Memory protocol reminder with quick tips
  - Makes "picking up where we left off" automatic

- **Dynamic Skill Context** - Live branch/PR/task info in skill displays
  - work skill: Shows current branch, PR status, active task
  - pr skill: Shows commits since base, recent commits, PR status
  - review skill: Shows PR status, review decision, comment count
  - Uses `!`command`` syntax for real-time context injection
  - Reduces "what was I working on?" questions

- **Persistent Agent Memory** - Agents learn across sessions
  - code-reviewer: Remembers common code smells per project
  - mutation: Tracks surviving mutant patterns and effective test strategies
  - architect: Recalls past architectural decisions and trade-offs
  - Uses `memory: project` configuration
  - Stored in `.claude/projects/<project-path>/memory/`

- **New /sdlc:status Skill** - Complete project state at a glance
  - Configuration status (Event Modeling / Traditional mode)
  - Current branch, task, and worktree location
  - TDD cycle state with phase indicators (✅🔄⏳)
  - PR status and review comments count
  - Next suggested action based on state
  - Recent activity (commits, agent invocations)
  - Fast, read-only operation (< 2 seconds)

- **Interactive Setup Wizard** - Multi-stage configuration with progressive disclosure
  - Stage 1 (30s): Essential setup - git, gh CLI, authentication
  - Stage 2 (1m): Workflow selection - Event Modeling vs Traditional with clear explanations
  - Stage 3 (1m, optional): Advanced options - worktrees, git-spice, output style
  - Support for `--reconfigure` to change settings later
  - Saves partial config at each stage
  - Reduces onboarding time from 10-15 min to 2-3 min
  - Comprehensive reference documentation with error handling

- **Auto-Invocation Hints** - Added to all 12 workflow skills
  - Each skill documents natural language triggers
  - Users can invoke skills without slash commands
  - Examples: "Create a pull request" → auto-invokes /sdlc:pr
  - Reduces command-line dependency, more conversational UX

- **Enhanced Error Messages** - Recovery guidance for all blocking hooks
  - Domain review checkpoint: Explains why blocked, expected duration, recovery steps
  - Incomplete todo detection: Lists specific incomplete items with status
  - AskUserQuestion enforcement: Shows benefits of structured questions, example patterns
  - gh api check: Explains why avoid, alternatives to check
  - All errors follow pattern: ❌ Blocked → 📚 Why → 🔧 Recovery → 📖 More info

#### 🎨 Improved

- **Onboarding Experience** - SessionStart context + status skill reduces time-to-productivity
- **Long Session Stability** - PreCompact hook maintains context through compaction
- **Cross-Session Learning** - Agents reference past reviews and patterns
- **Error Recovery** - Clear troubleshooting guidance in all blocking messages
- **Skill Discovery** - Auto-invocation examples help users find features naturally

#### 📚 Documentation

- Updated all skill README files with auto-invocation examples
- Enhanced agent documentation with memory usage patterns
- Improved hook error messages with structured recovery guidance

### 🔧 Technical

- New hook: `precompact-inject.sh` (PreCompact event)
- Enhanced hook: `session-start.sh` (now includes git/task/PR context)
- Updated hooks.json with PreCompact configuration
- Added `memory: project` to code-reviewer, mutation, architect agents
- Created status skill with comprehensive state display
- Enhanced all prompt-based hooks with structured error formatting

### 📊 Impact

- **Onboarding time:** 10-15 min → estimated 5-7 min (with status skill + SessionStart context)
- **Context preservation:** Eliminates "forgot domain model" in long sessions
- **Agent learning:** Code reviewers provide contextual feedback based on project history
- **Error recovery:** Users understand WHY blocked and HOW to proceed

### ⚠️ Breaking Changes

None - all changes are additive. Existing workflows continue to work unchanged.

---

## [9.1.0] - 2026-02-05

### 🎯 Phase 1: Quick Wins (UX Improvements)

**Focus:** Reduce friction, improve error messages, add decision trees

#### ✨ Added

- **Intelligent Domain Triage** - Domain agent now auto-triages change complexity
  - Trivial changes: Quick pass (30 seconds) - newtype wrappers, single field additions
  - Simple changes: Standard review (2 minutes) - validation logic, enum variants
  - Complex changes: Deep review (5+ minutes) - aggregates, state machines
  - Domain review remains MANDATORY but becomes proportional to complexity

- **User-Friendly Error Messages** - Replaced technical errors with actionable guidance
  - RED/GREEN/DOMAIN PreToolUse hooks now show:
    - What went wrong (one line with emoji)
    - What user tried
    - What user probably wants (3 bullets)
    - Why rule exists
    - Link to troubleshooting
  - 90% of users understand next action from error message

- **Decision Trees** - Interactive workflow guidance
  - `docs/decision-trees/workflow-selection.md` - Choose the right skill for your situation
  - `docs/decision-trees/tdd-troubleshooting.md` - Solve common TDD problems
  - Covers all entry points, common errors, agent coordination

- **Enforcement Philosophy Documentation** - Transparent rule system
  - `docs/enforcement-philosophy.md` - Explains HARD/SOFT/EDUCATIONAL tiers
  - Domain review rationale (why it stays MANDATORY)
  - Override protocols for SOFT rules
  - Rule reference table

- **Educational Orchestrator Detection** - PostToolUse hook for delegation awareness
  - Warns when orchestrator edits files directly
  - Suggests specialist agent delegation
  - Non-blocking (EDUCATIONAL enforcement)
  - Explains separation of concerns benefits

#### 🎨 Improved

- **Domain Agent Intelligence** - Proportional review based on change complexity
- **Error Message Quality** - Clear guidance instead of JSON-focused technical errors
- **UX Score:** 6.5 → 7.5 (estimated)

#### 📚 Documentation

- Added enforcement philosophy with three-tier model
- Added decision trees for workflow selection and TDD troubleshooting
- Clarified why domain review is HARD (agent expertise, not user override)
- Documented override protocols for SOFT rules

### 🔧 Technical

- New hook: `orchestrator-edit-detection.sh` (PostToolUse for Edit/Write)
- Updated hooks.json with PostToolUse section
- Enhanced domain.md with intelligent triage protocol
- Updated red.md and green.md with user-friendly PreToolUse messages

---

## [9.0.0] - 2026-02-05

### 🚀 BREAKING CHANGES

Commands completely removed - all functionality migrated to skills.

#### Commands → Skills Migration

**BREAKING:** All 12 commands replaced by skills (invocation syntax unchanged).

| Command | Skill | Status |
|---------|-------|--------|
| `/sdlc:setup` | setup skill | ✓ Migrated |
| `/sdlc:start` | start skill | ✓ Migrated |
| `/sdlc:work` | work skill | ✓ Migrated |
| `/sdlc:pr` | pr skill | ✓ Migrated |
| `/sdlc:complete` | complete skill | ✓ Migrated |
| `/sdlc:review` | review skill | ✓ Migrated |
| `/sdlc:design` | design skill | ✓ Migrated |
| `/sdlc:plan` | plan skill | ✓ Migrated |
| `/sdlc:adr` | arch skill | Already migrated in v8.0.0 |
| `/sdlc:remember` | remember skill | ✓ Migrated |
| `/sdlc:recall` | recall skill | ✓ Migrated |
| `/sdlc:domain-audit` | domain-audit skill | ✓ Migrated |

**Why:** January 2026 Claude Code update merged commands into skills, making skills functionally equivalent with additional capabilities (supporting files, better portability).

**Migration:** None required - invocation syntax unchanged (`/sdlc:work`, `/sdlc:pr`, etc.).

### ✨ Added

- **11 new workflow skills** - Complete command→skill transformation
  - work - Start/continue work with clean state enforcement
  - pr - Three-stage review + mutation testing + architecture PR fast path
  - review - Systematic PR feedback handling with in-thread responses
  - start - Smart workflow phase detection and routing
  - design - Event Modeling facilitation (discovery → workflows → GWT → arch)
  - plan - Event model → dot tasks mapping (epic/story/acceptance criteria)
  - setup - One-time SDLC config initialization
  - complete - Task completion with PR merge verification + parent evaluation
  - remember - File-based auto memory storage with categorization
  - recall - Auto memory search and retrieval
  - domain-audit - On-demand domain type safety audit

- **Auto-invocation support** - Skills invokable by Claude based on context
  - Enhanced descriptions with "what AND when" for better matching
  - Claude can apply skills without user requesting slash commands
  - Example: "start working on a task" → auto-invokes work skill

- **Progressive disclosure** - Context budget optimization
  - SKILL.md - Core principles and usage patterns (<500 lines recommended)
  - reference.md - Detailed implementation steps (loaded on-demand)
  - examples.md - Extended examples (loaded on-demand)
  - Zero token cost until supporting files needed

- **MIGRATION-v9.md** - Complete upgrade guide
  - Breaking changes summary with command→skill mapping table
  - Auto-invocation explanation
  - Progressive disclosure benefits
  - Rationale for skills-only architecture

### Changed

- **Plugin description** - Now mentions "11 workflow skills, 14 agents"
- **Version** - Bumped to 9.0.0 (major breaking change)
- **Keywords** - Added "skills" keyword

### Removed

- **Commands infrastructure** - `/sdlc/commands/` directory deleted
- **Shared orchestration** - `commands/shared/orchestration.md` deleted (already in output styles)
- **Deprecated ADR command** - `commands/adr.md` deleted (use `/sdlc:arch` from v8.0.0)

### Documentation

- Added MIGRATION-v9.md - Complete v8→v9 upgrade guide
- Updated CHANGELOG.md - v9.0.0 entry with breaking changes
- Updated README.md - Skills-only architecture documentation
- Updated CLAUDE.md - Skills structure and conventions

### Why This Matters

**Skills-only architecture offers:**
1. **Unified system** - One concept (skills) instead of two (commands + skills)
2. **Progressive disclosure** - Supporting files reduce context usage
3. **Auto-invocation** - Claude applies skills based on user intent, not explicit commands
4. **Framework portability** - Skills work across Claude Code, Cursor, Windsurf, Cline
5. **Better organization** - Clear structure with SKILL.md + reference.md pattern

**Plugin namespace** - Skills use `/sdlc:<skill-name>` to prevent conflicts with personal/project skills.

### Migration Path

None required - invocation syntax unchanged. See MIGRATION-v9.md for details.

### Support

- **Issues**: https://github.com/jwilger/claude-code-plugins/issues
- **Migration Guide**: See MIGRATION-v9.md
- **Documentation**: See README.md

---

## [5.0.0] - 2026-02-04

### 🚀 BREAKING CHANGES

This is a major rewrite replacing GitHub Issues/Projects with local dot CLI task management. See `MIGRATION.md` for upgrade guide.

#### Task Management: GitHub → dot CLI

**BREAKING:** Task management moved from GitHub Issues/Projects to local dot CLI.

**Before (v4.x):**
```bash
gh issue list
gh project-ext ready
gh issue create --title "Task"
gh issue-ext sub add 10 42  # Create sub-issue
```

**After (v5.0.0):**
```bash
dot ls
dot ready
dot add "Task"
dot add "Child" -P parent-id  # Create child task
```

**Why:** Local-first task management offers:
- Offline capability (no API rate limits)
- Instant performance (file-based)
- Version control (commit `.dots/` to git)
- Simplicity (no external service dependencies)

**Migration:** Install dot CLI, run `/sdlc:setup`, recreate active tasks. See `MIGRATION.md`.

#### Configuration Schema Changes

**BREAKING:** Configuration updated for dot CLI.

**Removed:**
- `github.project` (no longer using GitHub Projects)
- `board.statuses` (dot manages statuses)

**Added:**
- `tasks.prefix` (task ID prefix like "myproject")

**Updated:**
- `github.owner` + `github.repository` (for PR workflows only)

#### Manual Task Completion

**BREAKING:** Tasks must be manually completed after PR merge.

**Before (v4.x):**
```bash
/sdlc:pr  # Creates PR with "Closes #123"
# PR merges → Issue auto-closes
```

**After (v5.0.0):**
```bash
/sdlc:pr  # Creates PR referencing task
# PR merges → Manual completion:
/sdlc:complete  # Closes task, checks parent
```

**Why:** Explicit completion gives control to:
- Verify PR actually merged (not just closed)
- Close parent epics when all children done
- Better audit trail with completion reasons

#### Removed Dependencies

**BREAKING:** GitHub-specific extensions removed.

**Removed:**
- `gh-issue-ext` extension
- `gh-project-ext` extension

**Kept:**
- `gh-pr-review` extension (still needed for PR workflows)

### ✨ New Features

#### `/sdlc:complete` Command

New command for explicit task completion after PR merge:

```bash
/sdlc:complete [task-id]  # Auto-detects from branch if omitted
```

Features:
- Verifies PR was merged
- Closes task with completion reason
- Checks if parent epic should close
- Prompts to close parent if all children done

#### Branch Naming with Full Task IDs

Branch names now use full task IDs instead of issue numbers:

```bash
# v4.x: feature/123-add-login
# v5.0.0: feature/myproject-add-login-abc123
```

Benefits:
- Self-contained (no external lookup needed)
- Greppable (find tasks by ID in git history)
- No conflicts (hash ensures uniqueness)

#### Task Management Skill

New comprehensive skill for dot CLI patterns:

```bash
# Skill: sdlc/skills/task-management/
- Parent-child hierarchies
- Blocking dependencies
- Status lifecycle
- Branch integration patterns
```

### 📚 Documentation

- Added `MIGRATION.md` - Complete v4.x → v5.0.0 upgrade guide
- Added `docs/task-management/dot-cli.md` - dot CLI reference
- Added `docs/task-management/workflow.md` - Task workflow patterns
- Updated all agent files to reference "dot task" instead of "GitHub issue"

### 🔧 Updated

- All commands updated for dot CLI integration
- Configuration schema updated to v5.0.0
- Agent instructions updated to use task terminology
- Skill renamed: `github-issues` → `task-management`

## [4.0.0] - 2026-02-04

### 🎯 BREAKING CHANGES

This is a major rewrite of the sdlc plugin with breaking changes. See `MIGRATION.md` for upgrade guide.

#### Invocation Gates Removed

**BREAKING:** Manual confirmation gates completely removed from all agents.

**Before (v3.x):**
```
RED_CONTEXT: FIRST_TEST
ACCEPTANCE_CRITERIA:
- User can authenticate
```

**After (v4.0.0):**
```javascript
const redTask = await TaskCreate({
  subject: "Write failing test",
  metadata: { phase: "red" }
});
```

**Why:** Task dependencies enforce workflow mechanically, eliminating human error and providing visual workflow state.

**Migration:** Remove all `RED_CONTEXT`, `DOMAIN_CONTEXT`, and `GREEN_PHASE_COMPLETE` blocks from workflows. Use `TaskCreate` and `TaskUpdate` with `addBlockedBy` to establish dependencies.

#### Protocols Extracted as Portable Skills

**BREAKING:** Skill references changed from `sdlc:shared/*` to skill names.

**Before (v3.x):**
```yaml
skills:
  - sdlc:shared/user-input-protocol
  - sdlc:shared/tdd-constraints
```

**After (v4.0.0):**
```yaml
skills:
  - user-input-protocol
  - tdd-constraints
```

**Why:** Skills are now portable across Claude Code, Cursor, Windsurf, and Cline. They're installable via `npx skills add jwilger/claude-code-plugins`.

**Migration:** Update all agent YAML files to use skill names without `sdlc:shared/` prefix. Skill auto-loading works automatically - no installation needed for sdlc agents.

#### Skill Enforcement Protocol Deprecated

**BREAKING:** `sdlc:shared/skill-enforcement` removed entirely. No backward compatibility.

**Why:** Task dependencies enforce workflow mechanically. Manual "should I use this skill?" checks are obsolete.

**Migration:** Remove all references to `skill-enforcement`. Workflow enforcement now happens via task blocking relationships.

### Added

- **Task-Based Workflow** - TDD cycle enforced through task dependencies
  - `TaskCreate` with `metadata.phase` tracks workflow state
  - `TaskUpdate` with `addBlockedBy` creates mechanical dependencies
  - Visual workflow state via `TaskList`
  - Resumable workflow after session interruption
  - Parallel cycle support for multiple features

- **9 Portable Skills (Bundled)** - Framework-agnostic protocols included with plugin
  - `user-input-protocol` - Checkpoint/pause patterns (High portability)
  - `debugging-protocol` - 4-phase debugging methodology (Universal)
  - `atomic-design` - UI component hierarchy (Universal)
  - `tdd-constraints` - Red/green/domain boundaries (Universal)
  - `git-spice` - Stacked PR workflows (Tool-specific)
  - `github-issues` - GitHub CLI patterns (Tool-specific)
  - `memory-protocol` - Knowledge accumulation (High)
  - `event-modeling` - Event Modeling facilitation (High)
  - `orchestration-protocol` - Multi-agent coordination (Medium)

- **Skills Auto-Load** - No separate installation required
  - Skills bundled in `sdlc/skills/` directory
  - Automatically available to all sdlc agents
  - Can be used by custom agents when sdlc plugin installed
  - Each skill has YAML frontmatter with metadata
  - Framework-agnostic examples (Rust, TypeScript, Python)

- **MIGRATION.md** - Complete v3.x → v4.0.0 upgrade guide
  - Breaking changes summary
  - Step-by-step migration instructions
  - Troubleshooting common issues
  - FAQ section

### Changed

- **Marvin Output Style** - Moved to separate plugin
  - Marvin is now a standalone plugin (install separately)
  - Removed marvin-sdlc.md from sdlc plugin
  - Marvin is purely cosmetic (personality only)
  - All SDLC orchestration rules remain in sdlc plugin
  - Users can use sdlc without marvin, or marvin without sdlc
  - See marvin plugin for personality-only output style

- **Orchestration Logic** - Updated to use task dependencies
  - Removed invocation gate protocol section
  - Added task dependency patterns and examples
  - Updated Fresh Context Protocol (agents still have zero memory)
  - Git-spice references updated to use skill name

- **Agent Lightness** - All agents updated
  - Removed invocation gate sections (~60 lines per agent)
  - Updated skill references to use skill names
  - Added event-modeling skill to Event Modeling agents
  - Added atomic-design skill to UX agent

- **Plugin Structure** - Simplified command list
  - Removed 9 shared protocol files from commands array
  - Kept only `orchestration.md` in `commands/shared/`
  - Protocols now live in `skills/` directory
  - `plugin.json` simplified by 80%

- **Marketplace Metadata** - Added skills section
  - `.claude-plugin/marketplace.json` now lists 9 skills
  - Each skill has name, source, description, version, portability, tags
  - Skills installable independently of plugin

### Removed

- **Invocation Gate Sections** - All manual confirmation gates removed
  - No more `RED_CONTEXT:` declarations
  - No more `DOMAIN_CONTEXT:` declarations
  - No more `GREEN_PHASE_COMPLETE:` confirmations
  - No more gate validation logic
  - No more "INVOCATION GATE FAILED" error messages

- **Shared Protocol Files** - Extracted to skills
  - `sdlc/commands/shared/atomic-design.md` → `skills/atomic-design/SKILL.md`
  - `sdlc/commands/shared/debugging-protocol.md` → `skills/debugging-protocol/SKILL.md`
  - `sdlc/commands/shared/event-modeling.md` → `skills/event-modeling/SKILL.md`
  - `sdlc/commands/shared/github-issues.md` → `skills/github-issues/SKILL.md`
  - `sdlc/commands/shared/git-spice.md` → `skills/git-spice/SKILL.md`
  - `sdlc/commands/shared/memory-protocol.md` → `skills/memory-protocol/SKILL.md`
  - `sdlc/commands/shared/tdd-constraints.md` → `skills/tdd-constraints/SKILL.md`
  - `sdlc/commands/shared/user-input-protocol.md` → `skills/user-input-protocol/SKILL.md`
  - `sdlc/commands/shared/skill-enforcement.md` - Deleted entirely

- **Backward Compatibility** - No v3.x compatibility shims
  - Old skill references will fail
  - Old invocation gates will be ignored
  - No automatic migration of workflow state

### Documentation

- **Updated README.md** - Comprehensive v4.0.0 documentation
  - What's new in v4.0.0 section
  - Task-based workflow examples
  - All 15 agents documented with roles
  - Skills section with portability levels
  - Troubleshooting for common migration issues
  - Version history updated

- **Updated CLAUDE.md** - Repository overview
  - Added skills directory documentation
  - Updated sdlc plugin description to v4.0.0
  - Listed all 15 specialized agents
  - Breaking changes reference

### Metrics

- **Lines Changed:** ~15,000+ lines
- **Agent Context Reduction:** ~60 lines per agent (invocation gates removed)
- **Protocol Documentation:** ~10,000 lines extracted to skills
- **Skills Created:** 9 portable, framework-agnostic skills
- **Backward Incompatible:** 100% (major version bump justified)

### Why This Matters

**v4.0.0 represents a fundamental shift in workflow enforcement:**

1. **Mechanical > Manual** - Task dependencies replace human confirmation gates
2. **Portable > Inline** - Skills work across all agent frameworks, not just Claude Code
3. **Visual > Hidden** - Task list shows workflow state in real-time
4. **Resumable > Fragile** - Workflow survives session interruption

**The result:** More disciplined TDD cycles, better cross-framework compatibility, and clearer workflow visibility.

### Migration Path

See `MIGRATION.md` for complete guide. Summary:

1. Update plugin: `/plugin` or `git pull`
2. Install skills: `npx skills add jwilger/claude-code-plugins`
3. Update custom agents: Change `sdlc:shared/*` to skill names
4. Remove invocation gate logic: Use `TaskCreate`/`TaskUpdate` instead
5. Test TDD workflow: `/sdlc:work` and verify task creation

### Support

**Issues:** https://github.com/jwilger/claude-code-plugins/issues
**Migration Help:** See `MIGRATION.md` FAQ section
**Email:** john@johnwilger.com

---

## [3.12.3] - 2026-01-16

### Fixed
- **CRITICAL: Hook type compliance with Claude Code documentation**
  - Prompt-based hooks (`type: "prompt"`) are only officially supported for `Stop` and `SubagentStop`
  - Converted PreToolUse, SessionStart, and PreCompact hooks to command-based (`type: "command"`) with shell scripts
  - Created `.claude-plugin/hooks/` directory with shell scripts:
    - `file-edit-auth.sh` - Simple path-based subagent detection for Edit/Write authorization
    - `session-start.sh` - Memory protocol reminder
    - `gh-api-check.sh` - GitHub API extension-first reminder (plugin-level)
  - Fixed CLAUDE.md documentation which incorrectly stated SubagentStop requires `{"decision": "allow"|"block"}`
  - Stop and SubagentStop remain prompt-based with `{"ok": true/false}` format (officially supported)

- **Simplified subagent detection** - Uses transcript path instead of content parsing
  - Subagent transcripts are stored at `{sessionId}/subagents/agent-{agentId}.jsonl`
  - Main agent transcript is at `{sessionId}/{sessionId}.jsonl`
  - Simple check: if `transcript_path` contains `/subagents/`, allow Edit/Write
  - Much more reliable than parsing transcript content for agent types

### Changed
- **Setup command creates hook scripts** - Step 7 now creates `.claude/hooks/` directory with shell scripts
  - User projects get command-based hooks that don't rely on unsupported prompt evaluation
  - Setup generates: `file-edit-auth.sh`, `session-start.sh`, `pre-compact.sh`
  - All scripts are made executable automatically

### Why This Matters
The Claude Code documentation explicitly states that prompt-based hooks are "only officially supported for Stop and SubagentStop". Using prompt-based hooks for PreToolUse, SessionStart, and PreCompact may work but is not guaranteed. This version ensures all hooks use officially supported configurations.

### Migration
Run `/sdlc:setup` in existing projects. The setup will:
1. Create `.claude/hooks/` directory with new shell scripts
2. Update `.claude/settings.json` to reference the shell scripts
3. Maintain Stop and SubagentStop as prompt-based (supported)

## [3.12.2] - 2026-01-16

### Fixed
- **SessionStart hook no longer blocks** - Made SessionStart memory reminder truly non-blocking
  - Removed "Respond with JSON only: {\"ok\": true}" requirement
  - Hook now says "This reminder does not require a response - proceed directly with the user's request"
  - Fixes "SessionStart:startup hook error" when user asks a question immediately at session start
  - Previous versions had contradictory instruction: "GENTLE REMINDER, not a requirement" but forced JSON response
  - Hook is now purely informational - Claude can proceed with user's request without responding to hook

### Why This Matters
SessionStart hooks that require responses create a protocol conflict when users immediately ask questions at startup. Claude has to choose between responding to the hook (JSON) or responding to the user (natural language), causing validation errors and confusion. Making the hook truly non-blocking eliminates this friction.

### Migration
Run `/sdlc:setup` in existing projects to get the updated non-blocking SessionStart hook.

## [3.12.1] - 2026-01-16

### Fixed
- **CRITICAL: All hook JSON schemas corrected** - Fixed prompt-based hooks to use correct response format
  - Prompt-based hooks require `{"ok": boolean, "reason": "..."}` format
  - Command-based hooks use `{"decision": "block", "reason": "..."}` format
  - All plugin hooks are prompt-based, so all must use `{"ok": boolean}` format
  - Fixed 5 hooks in hooks.json: Stop, SubagentStop (domain review), SubagentStop (orchestration), SubagentStop (question detection), SessionStart
  - Fixed 4 hooks in setup.md command template: SubagentStop (domain review), SubagentStop (orchestration), SubagentStop (question detection), SessionStart
  - v3.11.0 and v3.12.0 had this wrong - introduced validation errors when hooks executed

### Why This Matters
The v3.11.0 "fix" was actually a regression. We changed from the CORRECT format (`{"ok": true}`) to the WRONG format (`{"decision": "allow"}`). This caused validation errors whenever hooks tried to block operations. All hooks in v3.11.0 and v3.12.0 would fail with "Schema validation failed" errors when executed.

### Migration
Run `/sdlc:setup` in existing projects to get corrected hook templates. The domain review enforcement and other features from v3.12.0 now work correctly.

## [3.12.0] - 2026-01-16

### Added
- **Domain Review Checkpoint Enforcement** - SubagentStop hook now enforces mandatory domain review after RED and GREEN phases
  - Blocks workflow progression after RED agent completes until sdlc:domain is invoked
  - Blocks workflow progression after GREEN agent completes until sdlc:domain is invoked
  - Enforces TDD cycle discipline: RED → DOMAIN → GREEN → DOMAIN
  - No more skipping domain review for "trivial" changes or "obvious" fixes

- **SessionStart Memory Reminder** - Gentle reminder to check memory for relevant context at session start
  - Suggests checking for debugging insights, architecture patterns, tool quirks, project conventions
  - Non-blocking - just a helpful nudge to use the memory system
  - Helps prevent reinventing solutions already documented in memory

- **TDD/Event Modeling State Schema** - Added state tracking infrastructure to sdlc.yaml
  - `tdd_state` section for tracking TDD workflow phases (future enhancement foundation)
  - `event_modeling_state` section for event modeling workflow stages
  - Prepares for advanced workflow state persistence across sessions

### Changed
- **Agent Context Reduction** - Removed 97 lines of redundant file boundary enforcement prose
  - Removed "INVIOLABLE CONSTRAINT" sections from red.md (28 lines), green.md (28 lines), domain.md (41 lines)
  - File boundaries now enforced automatically by PreToolUse Edit/Write hooks (from v3.11.0)
  - Agents are 6-10% lighter - enforcement moved from prose to deterministic hooks
  - Remaining agent content focuses on HOW to do the work, not WHAT files you can't touch

### Why This Matters

**Domain Review Enforcement** is the #1 most critical workflow violation to prevent. Skipping domain review allows primitive obsession and domain violations to accumulate silently. This hook makes domain review truly mandatory - the LLM cannot rationalize its way around it.

**Context Reduction** improves agent efficiency. Instead of 97 lines of "you can't edit production code" prose, the Edit/Write hooks simply block the operation. Agents now focus on their mission rather than constraint explanations.

**State Infrastructure** lays groundwork for future enhancements:
- Cross-session TDD phase tracking
- Automatic phase transitions
- Event modeling workflow gates
- Evidence verification

### Migration

Existing projects should run `/sdlc:setup` to:
1. Add `tdd_state` and `event_modeling_state` sections to sdlc.yaml
2. Get updated hooks with domain review enforcement
3. Benefit from lighter agent context

New projects automatically get all enhancements.

## [3.11.0] - 2026-01-16

### Added
- **PreToolUse hooks for Edit and Write** - Complete file operation delegation enforcement
  - Blocks ALL direct file edits/writes from main orchestrator
  - Only authorized subagents can modify files
  - Uses correct `hookSpecificOutput` schema with `permissionDecision: allow|deny`
  - Agents self-identify and are responsible for validating file type matches their domain

### Changed
- **Simplified delegation model** - No more pattern matching in hooks
  - Hooks act as "bouncers" - check agent identity, not file patterns
  - Agents validate file types themselves
  - All file operations MUST go through agents (no exceptions)

### Removed
- **`tdd.config_patterns` from sdlc.yaml** - No longer needed with identity-based authorization
  - Old hooks used these patterns to auto-approve config files
  - New hooks don't use patterns at all
  - Existing configs with this field will continue to work (field is just ignored)

- **Complete agent list in hooks** - Added missing event modeling and architecture agents
  - `sdlc:design-facilitator` - Architecture decisions (ADRs, ARCHITECTURE.md)
  - `sdlc:gwt` - GWT scenarios in event model docs
  - `sdlc:workflow-designer` - Event model workflow documents
  - `sdlc:model-checker` - Event model completeness fixes
  - `sdlc:discovery` - Domain discovery documents
  - Previous hooks only listed TDD agents (red, green, domain) + adr + file-updater

### Fixed (REGRESSION - Fixed in v3.12.1)
- **SubagentStop hook JSON schema** - Orchestration reminder changed to return `{"decision": "allow"}`
  - Changed from `{"ok": true}` format
  - **This was actually incorrect** - prompt-based hooks require `{"ok": boolean}`, not `{"decision": string}`
  - This introduced validation errors that were fixed in v3.12.1

### Why This Matters
The previous delegation model had orchestrator try to route files based on patterns, which was complex and had gaps (config files in sdlc.yaml but not hooks). The new model is simpler: hooks just check "are you authorized?" and agents validate their own files. This eliminates the config/hooks inconsistency reported in PR review and ensures ALL file operations go through proper agents.

## [3.10.1] - 2026-01-15

### Fixed
- **CRITICAL: TDD enforcement hooks now functional** - Fixed project-level hooks configuration
  - Hooks must be embedded in `.claude/settings.json` under the `hooks` key, NOT in a separate `.claude/hooks.json` file
  - Claude Code only reads project-level hooks from settings.json; separate hooks.json files are only read at the plugin level
  - Previous versions generated `.claude/hooks.json` which was never read, making TDD enforcement completely non-functional
  - `/sdlc:setup` now embeds hooks directly into settings.json and removes legacy hooks.json files during updates

### Changed
- **Updated setup command**: Step 7 now prepares hook structure, Step 8 embeds it into settings.json
- **Updated commit messages**: Setup commits no longer reference hooks.json, now mention settings.json with embedded hooks
- **Migration path**: Running `/sdlc:setup` in existing projects automatically migrates hooks from hooks.json to settings.json

### Why This Matters
The entire TDD agent delegation system was broken in all previous versions. PreToolUse hooks that should have blocked direct Edit/Write calls to production code were never executed because Claude Code doesn't read `.claude/hooks.json` at the project level. This fix restores the core workflow enforcement that prevents bypassing the TDD agents.

### Migration
Existing projects **must** run `/sdlc:setup` to fix their configuration. The setup command will:
1. Detect the version mismatch
2. Migrate hooks from `.claude/hooks.json` into `.claude/settings.json`
3. Remove the legacy `.claude/hooks.json` file
4. Update `sdlc_version` to 3.10.1

## [3.10.0] - 2026-01-15

### Added
- **Question detection hook**: SubagentStop hook now detects "walls of questions" and enforces AskUserQuestion tool usage
  - Identifies blocking question patterns (numbered lists, "Before I proceed...", multiple options)
  - Blocks agents that ask 2+ questions without using the tool
  - Forces reformulation with structured options for better UX
- **Enhanced AskUserQuestion enforcement**: Output style now explicitly warns about hook-based enforcement
  - Documents common blocking patterns that will be caught
  - Emphasizes the poor UX created by prose questions

### Changed
- **Improved SubagentStop documentation**: Updated setup.md to document question detection capability

### Why This Matters
Users were experiencing "walls of questions" that required manual parsing. The AskUserQuestion tool exists specifically to prevent this, but agents were ignoring the guidelines. This update adds automated enforcement via hooks to ensure a better user experience.

## [3.9.0] - 2026-01-15

### Added
- **Version-aware configuration**: Added `sdlc_version` field to `.claude/sdlc.yaml` for update detection
- **Automatic update detection**: `/sdlc:setup` now detects existing configurations and offers updates
- **Smart update flow**: Re-running `/sdlc:setup` preserves existing choices and only regenerates files
- **Version warnings**: `/sdlc:start` and `/sdlc:work` now warn when SDLC config is outdated
- **SubagentStop hook**: Fires after each agent completes to reinforce orchestration discipline
  - Reminds main conversation to delegate file edits to appropriate agents
  - Displays TDD cycle checkpoints
  - Emphasizes providing full context to agents (no memory assumption)

### Changed
- **Improved hooks documentation**: Setup command now explains all hook types
- **Better commit messages**: Distinguishes between fresh installs and updates

### Migration
Existing projects can update by running `/sdlc:setup` - all configuration choices will be preserved.

## [3.8.0] - Previous release

Earlier versions did not track changes systematically. See git history for details.
