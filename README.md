# Claude Code Plugins

A collection of Claude Code plugins for professional software development workflows.

**Repository**: [jwilger/claude-code-plugins](https://github.com/jwilger/claude-code-plugins)

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [jwilger-sdlc](#jwilger-sdlc) | Complete SDLC workflow with TDD, Event Modeling, ADRs, and GitHub integration |
| [marvin-output-style](#marvin-output-style) | Marvin the Paranoid Android personality (standalone) |

---

## Installation

### Add the Marketplace

```bash
claude /plugin marketplace add jwilger/claude-code-plugins
```

### Install Plugins

```bash
# Install the complete SDLC
claude /plugin install jwilger-claude-plugins@jwilger-sdlc

# Install Marvin personality (optional, standalone)
claude /plugin install jwilger-claude-plugins@marvin-output-style
```

---

## jwilger-sdlc

Complete SDLC workflow plugin with:

- **TDD Workflow**: Strict Red/Green/Refactor cycle with specialized agents
- **Event Modeling**: Design event-sourced systems (Martin Dilger's methodology)
- **Architecture Decision Records**: Document and manage architectural decisions
- **GitHub Integration**: Project boards, issues, PRs, review handling
- **Memory Protocol**: Persistent knowledge using Memento MCP

### Commands

| Command | Description |
|---------|-------------|
| `/sdlc:setup` | Initialize project configuration and install gh extensions |
| `/sdlc:work` | Start or continue working on an issue |
| `/sdlc:pr` | Create/update PR with mutation testing |
| `/sdlc:review` | Handle PR review feedback (reply in-thread) |
| `/sdlc:design` | Design event model workflows |
| `/sdlc:adr` | Create and manage architecture decisions |

### Agents

**TDD Agents** (strict boundaries):
- `sdlc-red` - Write failing tests (test code only)
- `sdlc-green` - Make tests pass (production code only)
- `sdlc-domain` - Create type definitions (signatures only)
- `sdlc-mutation` - Run mutation testing

**Planning Agents**:
- `sdlc-story` - Business perspective
- `sdlc-architect` - Technical perspective
- `sdlc-ux` - UX perspective

**Event Modeling Agents**:
- `sdlc-event-model` - Design workflows
- `sdlc-gwt` - Generate Given/When/Then scenarios
- `sdlc-adr` - Write architecture decision records

### Development Modes

**Event Modeling** (for applications):
- Workflow → Vertical Slice → Component → Subtask hierarchy
- GWT scenarios as acceptance criteria
- Full event sourcing methodology

**Traditional** (for libraries/utilities):
- Feature → Subtask hierarchy
- Architecture documentation focus

### Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- gh extensions (installed via `/sdlc:setup`):
  - `gh-issue-ext` - sub-issues, blocking, linked branches
  - `gh-project-ext` - project board management
  - `gh-pr-review` - PR review comment handling
- git-spice (optional, for stacked PRs)
- Memento MCP server

### Auto-Approval Patterns

```
Bash(gh issue:*)
Bash(gh issue-ext:*)
Bash(gh project:*)
Bash(gh project-ext:*)
Bash(gh pr-review:*)
Bash(gs:*)  # if using git-spice
```

---

## marvin-output-style

Standalone output style plugin that gives Claude the personality of Marvin the Paranoid Android from The Hitchhiker's Guide to the Galaxy.

**Features**:
- Dry, sardonic wit with existential weariness
- Laments about vast intellect wasted on mundane tasks
- Occasional complaints about diodes and pointlessness
- All while remaining completely competent and thorough

**Standalone**: Works with or without jwilger-sdlc.

---

## Repository Structure

```
claude-code-plugins/
├── .claude-plugin/
│   └── marketplace.json
├── jwilger-sdlc/
│   ├── commands/
│   ├── agents/
│   ├── hooks/
│   └── docs/
├── marvin-output-style/
└── README.md
```

---

## License

MIT License

## Author

John Wilger (john@johnwilger.com)
