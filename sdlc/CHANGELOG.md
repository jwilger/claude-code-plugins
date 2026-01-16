# SDLC Plugin Changelog

## [3.12.0] - 2026-01-16

### Added
- **Domain Review Checkpoint Enforcement** - SubagentStop hook now enforces mandatory domain review after RED and GREEN phases
  - Blocks workflow progression after RED agent completes until sdlc:domain is invoked
  - Blocks workflow progression after GREEN agent completes until sdlc:domain is invoked
  - Enforces TDD cycle discipline: RED → DOMAIN → GREEN → DOMAIN
  - No more skipping domain review for "trivial" changes or "obvious" fixes

- **SessionStart Memory Reminder** - Gentle reminder to check memento for relevant context at session start
  - Suggests checking for debugging insights, architecture patterns, tool quirks, project conventions
  - Non-blocking - just a helpful nudge to use the memory system
  - Helps prevent reinventing solutions already documented in memento

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

### Fixed
- **SubagentStop hook JSON schema** - Orchestration reminder now returns `{"decision": "allow"}`
  - Changed from invalid `{"ok": true}` format
  - Fixes "JSON validation failed" error after subagents completed

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
