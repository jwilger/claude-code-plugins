# SDLC Plugin Changelog

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
