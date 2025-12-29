# Claude Code Plugins

A collection of Claude Code plugins for professional software development workflows.

**Repository**: [jwilger/claude-code-plugins](https://github.com/jwilger/claude-code-plugins)

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [marvin-sdlc](#marvin-sdlc) | Complete development methodology with TDD, Event Sourcing, ADRs, and Story Planning |
| [github-issues](#github-issues) | Comprehensive GitHub issue management with sub-issues, blocking, and linked branches |

---

## Installation

### Add the Marketplace

```bash
claude /plugin marketplace add jwilger/claude-code-plugins
```

### Install a Plugin

```bash
# Install marvin-sdlc
claude /plugin install jwilger-claude-plugins@marvin-sdlc

# Install github-issues
claude /plugin install jwilger-claude-plugins@github-issues
```

---

## marvin-sdlc

A comprehensive development methodology plugin featuring the personality of Marvin the Paranoid Android.

### Features

- **Marvin Persona**: Weary, melancholic, perpetually underwhelmed conversational tone
- **TDD Workflow**: Red-Domain-Green-Refactor cycle with mutation testing (≥80% coverage)
- **Event Sourcing**: Martin Dilger's methodology with four patterns
- **ADRs**: Architecture Decision Records with event-sourced workflow
- **Story Planning**: Three-perspective review (business/tech/UX)
- **Memory Protocol**: Mandatory memento MCP integration for knowledge persistence

### Commands

| Command | Description |
|---------|-------------|
| `/marvin-sdlc:tdd` | TDD workflow facilitator (red/green/refactor) |
| `/marvin-sdlc:event-model` | Event sourcing design using Dilger's methodology |
| `/marvin-sdlc:architect` | Architecture Decision Records management |
| `/marvin-sdlc:plan` | Story planning with three-perspective review |
| `/marvin-sdlc:init-project` | Initialize project with methodology |

### Agents

- **TDD**: `red-tdd-tester`, `green-implementer`, `domain-model-expert`, `mutation-tester`
- **Event Model**: `event-model-architect`, `gwt-scenario-generator`, `model-validator`, `implementation-guide`
- **Architecture**: `adr-writer`, `architecture-synthesizer`
- **Planning**: `story-planner`, `story-architect`, `ux-consultant`

### Output Style

The plugin includes a complete output style (`marvin-sdlc.md`) that can be activated in your Claude Code settings:

```json
{
  "outputStyle": "marvin-sdlc"
}
```

### Requirements

- **memento MCP server**: Required for memory protocol
- **Beads CLI** (optional): For advanced task management (`bd` command)

---

## github-issues

Comprehensive GitHub issue management using the `gh` CLI and a custom extension for advanced features.

### Features

- **Standard Operations**: Create, view, edit, close, list issues via `gh issue`
- **Sub-Issues**: Parent/child hierarchies for epics, stories, and tasks
- **Blocking Relationships**: Track issue dependencies (blocked by / blocking)
- **Linked Branches**: Create and manage development branches tied to issues

### Setup

Run the setup command to install the required gh extension:

```bash
/github-issues:setup
```

This installs [gh-issue-ext](https://github.com/jwilger/gh-issue-ext), a custom GitHub CLI extension.

### Permission Configuration

Add these patterns to your Claude Code settings for auto-approval:

```
Bash(gh issue:*)
Bash(gh issue-ext:*)
```

This grants Claude full issue management capability without the overly broad `Bash(gh api:*)`.

### Commands

| Command | Description |
|---------|-------------|
| `/github-issues:setup` | Install the gh-issue-ext extension |

### gh-issue-ext Commands

After setup, these commands are available:

```bash
# Sub-issues
gh issue-ext sub add <parent> <child>
gh issue-ext sub remove <parent> <child>
gh issue-ext sub list <issue>
gh issue-ext sub reorder <parent> <child> --after|--before <sibling>

# Blocking relationships
gh issue-ext blocking add <blocked> <blocker>
gh issue-ext blocking remove <blocked> <blocker>
gh issue-ext blocking list <issue>

# Linked branches
gh issue-ext branch create <issue> [--name <branch-name>]
gh issue-ext branch delete <issue> <branch-name>
gh issue-ext branch list <issue>

# Show all relationships
gh issue-ext show <issue>
```

### Requirements

- **GitHub CLI** (`gh`): Must be installed and authenticated
- **gh-issue-ext**: Installed via `/github-issues:setup`

---

## Development

### Repository Structure

```
claude-code-plugins/
├── .claude-plugin/
│   └── marketplace.json      # Marketplace manifest
├── marvin-sdlc/              # marvin-sdlc plugin
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── agents/
│   ├── commands/
│   ├── docs/
│   └── hooks/
├── github-issues/            # github-issues plugin
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── commands/
│   ├── hooks/
│   └── skills/
└── README.md
```

### Local Development

To test plugins locally:

```bash
# Clone the repo
git clone https://github.com/jwilger/claude-code-plugins.git

# Run Claude Code with the plugin directory
claude --plugin-dir /path/to/claude-code-plugins/marvin-sdlc
```

---

## License

MIT License

## Author

John Wilger (john@johnwilger.com)
