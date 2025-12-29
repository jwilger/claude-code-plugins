# GitHub Projects Plugin

A Claude Code plugin for managing GitHub Projects V2 Kanban boards with Status columns and Priority swimlanes.

## Features

- **Board View**: Text-based Kanban board showing items by status and priority
- **Ready Queue**: See items ready to work on, sorted by P0 → P1 → P2
- **Quick Move**: Move items between status columns by name
- **Claim**: Assign an issue to yourself and start work in one command
- **Smart Filtering**: Default to top-level items (no parent) and current repository

## Prerequisites

- [GitHub CLI](https://cli.github.com/) 2.0+
- `project` scope for your token: `gh auth refresh -s project`
- Recommended: [github-issues plugin](../github-issues) for sub-issue and branch management

## Installation

### Install gh-project-ext Extension

```bash
gh extension install jwilger/gh-project-ext
```

Or use the setup command after installing the plugin:

```
/github-projects:setup
```

### Configure Default Project

```bash
gh project-ext setup
```

This creates a `.github-project` config file with your project owner and number.

## Commands

| Command | Description |
|---------|-------------|
| `/github-projects:setup` | Install extension and configure project |
| `/github-projects:board` | Show Kanban board overview |
| `/github-projects:ready` | List items ready to work on |
| `/github-projects:move` | Move item to new status |
| `/github-projects:claim` | Assign and start work on an issue |

## Quick Start

```bash
# Install and configure
/github-projects:setup

# See what's ready
gh project-ext ready

# Claim an issue (assigns to you, moves to In Progress)
gh project-ext claim 42

# When ready for review
gh project-ext move 42 "In review"

# When complete
gh project-ext move 42 "Done"
```

## Status Values

The plugin supports standard Kanban statuses:

| Status | Description |
|--------|-------------|
| `Backlog` | Not yet ready for work |
| `Ready` | Groomed and available to pick up |
| `In progress` | Currently being worked on |
| `In review` | PR created, awaiting review |
| `Done` | Completed |

## Priority Levels

| Priority | Description |
|----------|-------------|
| `P0` | Critical/urgent - work immediately |
| `P1` | High priority - complete soon |
| `P2` | Normal priority |

## Filtering Options

| Flag | Description |
|------|-------------|
| `--all` | Include sub-issues (default: top-level only) |
| `--all-repos` | Include all repositories (default: current repo) |
| `--json` | JSON output for scripting |

## Configuration

The extension looks for `.github-project` in:
1. Current directory or git root
2. `~/.config/gh-project-ext/config`

Format:
```yaml
owner: jwilger
project: 11
```

## Permission Patterns

Add to Claude Code settings for auto-approval:

```
Bash(gh project:*)
Bash(gh project-ext:*)
```

## Integration with github-issues

This plugin works alongside the github-issues plugin for comprehensive issue management:

- **Sub-issues**: Use `gh issue-ext sub` for parent/child hierarchies
- **Blocking**: Use `gh issue-ext blocking` for dependencies
- **Branches**: Claim command can create linked branches via gh-issue-ext

## Dependencies

- `github-issues` plugin (recommended for full workflow)
- `gh-project-ext` CLI extension

## License

MIT
