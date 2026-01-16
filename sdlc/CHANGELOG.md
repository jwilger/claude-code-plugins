# SDLC Plugin Changelog

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
