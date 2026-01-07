# jwilger-sdlc

Complete SDLC workflow plugin for Claude Code with TDD, Event Modeling, ADRs, and GitHub integration.

## Features

- **TDD Workflow**: Strict Red/Green/Refactor cycle with specialized agents
- **Event Modeling**: Design event-sourced systems following Martin Dilger's methodology
- **Architecture Decision Records**: Document and manage architectural decisions
- **GitHub Integration**: Project board management, issue tracking, PR workflow
- **Memory Protocol**: Persistent knowledge using Memento MCP

## Installation

```bash
# From local directory
claude plugins:install /path/to/jwilger-sdlc

# Or add to your project's .claude-plugin configuration
```

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- Required gh extensions (installed via `/sdlc:setup`):
  - `gh-issue-ext` for sub-issues and blocking relationships
  - `gh-project-ext` for project board management
  - `gh-pr-review` for PR review comment handling
- git-spice (optional, for stacked PRs)
- Memento MCP server configured

## Commands

| Command | Description |
|---------|-------------|
| `/sdlc:setup` | Initialize project configuration and install extensions |
| `/sdlc:work` | Start or continue working on an issue |
| `/sdlc:pr` | Create/update PR with mutation testing |
| `/sdlc:review` | Handle PR review feedback |
| `/sdlc:design` | Design event model workflows |
| `/sdlc:adr` | Create and manage architecture decisions |

## Project Configuration

After running `/sdlc:setup`, a `.claude/sdlc.yaml` file is created:

```yaml
mode: event-modeling  # or: traditional

git:
  workflow: git-spice  # or: standard
  require_clean: true

github:
  project: 11
  owner: jwilger

board:
  statuses:
    - Backlog
    - Ready
    - In Progress
    - Review
    - Done

tdd:
  verbosity: brief  # silent | brief | explain
  bypass_patterns:
    - "*.md"
    - ".github/**"
    - "*.tf"
    - "Cargo.toml"
    - "package.json"
```

## TDD Agents

The SDLC enforces strict TDD boundaries through specialized agents:

| Agent | Responsibility | Can Edit |
|-------|----------------|----------|
| `sdlc-red` | Write failing tests | Test files only |
| `sdlc-green` | Make tests pass | Production code only |
| `sdlc-domain` | Create type definitions | Type signatures only |
| `sdlc-mutation` | Run mutation testing | Read-only |

These boundaries are **inviolable** - each agent can only edit its designated files.

## Development Modes

### Event Modeling (Applications)

For event-sourced applications:
- Workflow → Vertical Slice → Component → Subtask hierarchy
- GWT scenarios as acceptance criteria
- Event/Command/ReadModel/Automation documentation

### Traditional (Libraries/Utilities)

For libraries, utilities, and legacy applications:
- Feature → Subtask hierarchy
- Architecture documentation focus
- PRD-driven development

## GitHub Integration

The SDLC manages your GitHub workflow:

1. **Issues** become work items with sub-issue support
2. **Project boards** track status (Backlog → Ready → In Progress → Review → Done)
3. **PRs** link to issues and close them on merge
4. **Review comments** are addressed in-thread

## Auto-Approval Patterns

Add these to your Claude Code settings for smoother workflow:

```
Bash(gh issue *)
Bash(gh issue-ext *)
Bash(gh project *)
Bash(gh project-ext *)
Bash(gh pr-review *)
Bash(gs *)  # if using git-spice
```

## Documentation

- `docs/tdd/TDD_WORKFLOW.md` - TDD process and principles
- `docs/domain-modeling/principles.md` - Domain modeling guidelines
- `docs/event-modeling/methodology.md` - Event modeling approach

## Related Plugins

- **marvin-output-style** - Marvin personality (standalone, works with or without SDLC)
