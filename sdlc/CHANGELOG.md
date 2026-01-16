# SDLC Plugin Changelog

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
