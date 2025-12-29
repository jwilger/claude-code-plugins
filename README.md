# Claude Code Plugins

A collection of Claude Code plugins for professional software development workflows.

**Repository**: [jwilger/claude-code-plugins](https://github.com/jwilger/claude-code-plugins)

## Available Plugins

### SDLC Plugins (Modular Development Methodology)

| Plugin | Description |
|--------|-------------|
| [sdlc-core](#sdlc-core) | Core foundations: Marvin persona, memory protocol, shared conventions |
| [sdlc-architecture](#sdlc-architecture) | ADRs and ARCHITECTURE.md synthesis |
| [sdlc-event-modeling](#sdlc-event-modeling) | Event Sourcing with Dilger's methodology |
| [sdlc-planning](#sdlc-planning) | Story planning with three-perspective review |
| [sdlc-tdd](#sdlc-tdd) | TDD workflow with Red/Green/Refactor cycle |

### GitHub Integration Plugins

| Plugin | Description |
|--------|-------------|
| [github-issues](#github-issues) | Issue management with sub-issues, blocking, and linked branches |
| [github-projects](#github-projects) | GitHub Projects V2 Kanban board management |

---

## Installation

### Add the Marketplace

```bash
claude /plugin marketplace add jwilger/claude-code-plugins
```

### Install Plugins

```bash
# Install the full SDLC suite (recommended)
claude /plugin install jwilger-claude-plugins@sdlc-core
claude /plugin install jwilger-claude-plugins@sdlc-architecture
claude /plugin install jwilger-claude-plugins@sdlc-event-modeling
claude /plugin install jwilger-claude-plugins@sdlc-planning
claude /plugin install jwilger-claude-plugins@sdlc-tdd

# Install GitHub plugins
claude /plugin install jwilger-claude-plugins@github-issues
claude /plugin install jwilger-claude-plugins@github-projects
```

---

## SDLC Plugins

### sdlc-core

Core foundations for all SDLC plugins. Includes:

- **Marvin Output Style**: The Paranoid Android persona with weary, melancholic conversational tone
- **Memory Protocol**: Mandatory memento MCP integration for knowledge persistence
- **Session Hooks**: Neo4j availability verification, pre-compact memory saving
- **Shared Conventions**: Collaboration protocols, dependency management, testing philosophy

**Installation**: Required as a dependency for all other sdlc-* plugins.

**Output Style**: After installation, activate with `/output-style` → "Marvin SDLC"

### sdlc-architecture

Architecture Decision Records and documentation synthesis.

**Philosophy**: ADRs are events (immutable historical records), ARCHITECTURE.md is a projection (standalone working document).

| Command | Description |
|---------|-------------|
| `/architect decide <topic>` | Create new ADR |
| `/architect accept <number>` | Accept proposed ADR |
| `/architect reject <number>` | Reject proposed ADR |
| `/architect supersede <old> <new>` | Mark ADR superseded |
| `/architect synthesize` | Update ARCHITECTURE.md |
| `/architect list` | List all ADRs |
| `/architect show <number>` | Show specific ADR |

**Agents**: `adr-writer`, `architecture-synthesizer`

### sdlc-event-modeling

Event Modeling (created by Adam Dymitruk) for event-sourced system development. Based on Martin Dilger's comprehensive book ["Understanding Eventsourcing"](https://leanpub.com/eventmodeling-and-eventsourcing).

**The Four Patterns**:
1. **State Change**: Command → Event (modify state)
2. **State View**: Events → Read Model (query)
3. **Automation**: Event → Process → Command → Event
4. **Translation**: External → Internal Event

| Command | Description |
|---------|-------------|
| `/event-model start` | Begin brainstorming session |
| `/event-model design <workflow>` | Design a workflow |
| `/event-model gwt <workflow>` | Generate GWT scenarios |
| `/event-model validate` | Validate the model |
| `/event-model implement <name>` | Create implementation plan |
| `/event-model reverse [path]` | Reverse-engineer from code |

**Agents**: `event-model-architect`, `gwt-scenario-generator`, `model-validator`, `implementation-guide`, `event-model-reverse-engineer`

### sdlc-planning

Story planning with three-perspective review.

**Critical Mapping**:
- Vertical Slice = Story Issue (1:1)
- GWT Scenarios = Acceptance Criteria
- Chapter/Theme = Epic

| Command | Description |
|---------|-------------|
| `/plan slice <name>` | Plan a slice as story |
| `/plan review <name>` | Three-perspective review |
| `/plan create <name>` | Create GitHub issue |
| `/plan epic <name>` | Create epic from chapter |
| `/plan ready` | Show ready issues |

**Agents**: `story-planner` (business), `story-architect` (technical), `ux-consultant` (UX)

### sdlc-tdd

Test-Driven Development workflow.

**The Cycle**: Red → Domain → Green → Refactor → Commit

| Command | Description |
|---------|-------------|
| `/tdd start` | Begin new TDD cycle |
| `/tdd red` | Write failing test |
| `/tdd green` | Make test pass |
| `/tdd refactor` | Clean up after green |
| `/tdd status` | Show current state |

**Agents**: `red-tdd-tester`, `green-implementer`, `domain-model-expert`, `mutation-tester`

**Quality Gate**: Mutation testing ≥80% score required before merge.

---

## GitHub Plugins

### github-issues

Comprehensive GitHub issue management using the `gh` CLI and `gh-issue-ext` extension.

**Features**:
- Standard issue operations (create, view, edit, close)
- Sub-issues (parent/child hierarchies)
- Blocking relationships
- Linked development branches

**Setup**:
```bash
/github-issues:setup
```

**Permission Configuration**:
```
Bash(gh issue:*)
Bash(gh issue-ext:*)
```

### github-projects

GitHub Projects V2 Kanban board management.

**Features**:
- View board by Status columns (Backlog, Ready, In progress, In review, Done)
- Priority swimlanes (P0, P1, P2)
- Claim issues and create linked branches
- Move items between status columns

**Setup**:
```bash
/github-projects:setup
```

**Commands**:
```bash
gh project-ext ready          # Show ready items
gh project-ext board          # Show Kanban board
gh project-ext move 42 "In progress"   # Move item
gh project-ext claim 42       # Claim and start work
```

---

## Requirements

- **memento MCP server**: Required for memory protocol (sdlc-core)
- **GitHub CLI** (`gh`): Required for github-* plugins
- **gh-issue-ext**: Installed via `/github-issues:setup`
- **gh-project-ext**: Installed via `/github-projects:setup`

---

## Migration from marvin-sdlc

The monolithic `marvin-sdlc` plugin has been split into modular components:

| Old | New |
|-----|-----|
| `marvin-sdlc` | `sdlc-core` + `sdlc-architecture` + `sdlc-event-modeling` + `sdlc-planning` + `sdlc-tdd` |

**Benefits**:
- Install only what you need
- Clearer separation of concerns
- Independent versioning
- Easier maintenance

---

## Repository Structure

```
claude-code-plugins/
├── .claude-plugin/
│   └── marketplace.json
├── sdlc-core/
├── sdlc-architecture/
├── sdlc-event-modeling/
├── sdlc-planning/
├── sdlc-tdd/
├── github-issues/
├── github-projects/
├── marvin-sdlc/           # [DEPRECATED]
└── README.md
```

---

## License

MIT License

## Author

John Wilger (john@johnwilger.com)
