# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains a Professional SDLC Workflow Plugin Marketplace for Claude Code. It provides comprehensive 8-phase sequential development workflows with 35+ specialized agents, implementing Event Modeling, Type-First TDD, and Domain-Driven Design principles.

## Project Structure

```
.
├── plugins/                      # Plugin marketplace
│   ├── sdlc-core/               # Shared agents and commands
│   │   ├── agents/              # 11 shared agents (TDD, architecture, DevOps, etc.)
│   │   ├── commands/            # 7 shared slash commands
│   │   └── .mcp.json            # MCP server configuration (time, memento)
│   ├── sdlc-app/                # Application workflow (Event Modeling-based)
│   │   ├── agents/              # 20 app-specific agents (event modeling, UX, design system)
│   │   ├── commands/            # 7 app-specific slash commands
│   │   └── system-prompt.md     # Complete workflow documentation
│   ├── sdlc-infrastructure/     # Infrastructure/library workflow
│   │   ├── agents/              # 1 infrastructure-specific agent (technical increment planner)
│   │   ├── commands/            # 1 infrastructure-specific slash command
│   │   └── system-prompt.md     # Complete workflow documentation
│   ├── sdlc-rust/               # Rust domain modeling plugin
│   ├── sdlc-python/             # Python domain modeling plugin
│   ├── sdlc-typescript/         # TypeScript domain modeling plugin
│   ├── sdlc-elixir/             # Elixir domain modeling plugin
│   └── output-styles-marvin/    # Marvin output style plugin
├── output-styles/               # Custom Claude Code output styles (legacy)
├── settings.json                # Claude Code workspace settings
└── .claude-plugin/
    └── marketplace.json         # Plugin marketplace metadata
```

## Plugin Architecture

### Core Shared Plugin

**sdlc-core**: Shared agents and commands used by both workflows
- 11 shared agents: adr-writer, architecture-synthesizer, cognitive-load-analyzer, dependency-management, devops, file-editor, green-implementer, red-tdd-tester, research-specialist, technical-documentation-writer, acceptance-validator
- 7 shared commands: adr-template, dependency-management-process, documentation-philosophy, domain-modeling-process, github-pr-management, integration-validation, tdd-workflow-process
- MCP servers: time (temporal anchoring), memento (knowledge graph memory)
- **MUST be installed** before sdlc-app or sdlc-infrastructure

### Workflow Plugins

**sdlc-app**: Event Modeling-based application development workflow
- 8-phase sequential workflow (includes Event Modeling and Design System)
- 20 app-specific agents: requirements-analyst, 15 event modeling agents, story-planner, story-architect, design-system-architect, ux-consultant
- 7 app-specific commands: event-modeling-process, event-model-template, design-system-process, story-planning-process, setup-sdlc-alias, initialize-app-project, sdlc-workflow
- Target: Web/mobile/desktop apps, line-of-business applications
- Requires: sdlc-core plugin

**sdlc-infrastructure**: Technical architecture-based infrastructure/library workflow
- 6-phase sequential workflow (skips Event Modeling and Design System)
- 1 infrastructure-specific agent: technical-increment-planner (plus requirements-analyst and story-architect from sdlc-app for backward compatibility during transition)
- 1 infrastructure-specific command: technical-increment-planning (plus initialize-infrastructure-project, sdlc-workflow)
- Target: Libraries, frameworks, APIs, developer tools
- Requires: sdlc-core plugin

### Language-Specific Plugins

Each provides domain modeling expertise using language-specific type systems:
- **sdlc-rust**: Typestate pattern, nutype, compile-time safety
- **sdlc-python**: Pydantic models, runtime validation
- **sdlc-typescript**: Branded types, discriminated unions
- **sdlc-elixir**: Structs with enforced keys, pattern matching

### Output Style Plugins

**output-styles-marvin**: Marvin the Paranoid Android personality
- Pessimistic but brilliant, brutally honest, reluctantly helpful
- Use with `/output-style marvin` in conversation

## Development Commands

### Plugin Development

```bash
# View plugin structure
ls -la plugins/sdlc-app/{agents,commands}/

# Check MCP configuration
cat plugins/sdlc-app/.mcp.json

# View marketplace metadata
cat .claude-plugin/marketplace.json
```

### Testing Plugin Installation

```bash
# Add marketplace (from user's home directory)
/plugin marketplace add /home/jwilger/.claude

# List available plugins
/plugin marketplace list

# Install plugins (sdlc-core MUST be installed first)
/plugin install sdlc-core@jwilger-sdlc
/plugin install sdlc-app@jwilger-sdlc
# OR
/plugin install sdlc-infrastructure@jwilger-sdlc

# Install language-specific domain modeling plugin
/plugin install sdlc-rust@jwilger-sdlc

# Install output style
/plugin install output-styles-marvin@jwilger-sdlc

# List installed plugins
/plugin list

# Uninstall plugins
/plugin uninstall sdlc-app@jwilger-sdlc
/plugin uninstall sdlc-core@jwilger-sdlc
```

### Testing Slash Commands

After installing a plugin, test slash commands:

```bash
# Initialize projects
/initialize-app-project              # Application workflow
/initialize-infrastructure-project   # Infrastructure workflow

# Activate workflow in conversation
/sdlc-workflow

# Load process methodologies
/domain-modeling-process
/tdd-workflow-process
/event-modeling-process
```

## Key Design Decisions

### Marketplace Structure

The marketplace uses a single `marketplace.json` file that references multiple plugin directories:
- Each plugin is self-contained with agents/, commands/, and optionally system-prompt.md
- Plugins can define MCP servers in .mcp.json (automatically configured)
- sdlc-core provides shared agents/commands used by both workflows
- Workflow plugins (app/infrastructure) contain workflow-specific agents only
- Agent orchestration: Main conversation agent coordinates all subagents - subagents NEVER call other subagents directly

### Initialization Strategy

Projects are initialized with a project-local launcher (`./scripts/claude`):
- No global shell alias required
- Portable across team members
- Visible in version control
- Ensures correct workflow context always loaded

### Agent Design Philosophy

Agents follow specialized responsibilities:
- **Shared agents** (sdlc-core): TDD, architecture, DevOps, dependency management, validation
- **Phase-specific agents**: Handle sequential workflow phases (1-8)
- **Process agents**: Implement specific methodologies (Event Modeling steps 0-12)
- **Language agents**: Domain modeling expertise per language
- **Orchestration Rule**: Main conversation agent ALWAYS coordinates subagents - subagents NEVER call other subagents
- **Handoff Protocol**: Subagents RETURN control to main agent with clear handoff messages indicating next steps

### Memory Intelligence Protocol

All agents use mandatory 3-phase memory protocol:
1. **Temporal Anchoring**: Call `mcp__time__get_current_time` first
2. **Semantic Search**: Content-based search for relevant memories
3. **Graph Traversal**: Follow relationships to discover context
4. **Temporal Precedence**: Recent project-specific > older general

### Quality Gates

Multiple quality gates enforce rigor:
- **Build/Test Gate**: Zero warnings, all tests pass
- **Domain Review Gate**: Domain modeling agent reviews EVERY test and implementation
- **Mutation Testing Gate**: ≥80% mutation score
- **Cognitive Load Gate**: ≥70% TRACE score (Type-first, Readability, Atomic scope, Cognitive budget, Essential only)

## Documentation Philosophy

The workflows produce WHAT/WHY documentation (not HOW):
- **ADRs**: Decisions and rationale, not implementation guides
- **Event Models**: Business events with Mermaid diagrams
- **Architecture Synthesis**: Cohesive system design from ADRs
- **Minimal code examples**: Maximum 5-10 lines, only to support rationale

## MCP Server Configuration

Plugins automatically configure MCP servers via `.mcp.json`:

### Core Servers (sdlc-app, sdlc-infrastructure)
- **time**: Temporal anchoring for memory operations (`@modelcontextprotocol/server-time`)
- **memento**: Knowledge graph memory (`@gannonh/memento-mcp`, stores at `~/.claude/memento.db`)

### Language Servers
- **cargo-mcp**: Rust tooling (cargo, clippy, test) - manual install via `/setup-cargo-mcp`

## Important Files

### Plugin Metadata
- `.claude-plugin/marketplace.json`: Marketplace configuration with plugin list
- `plugins/*/system-prompt.md`: Complete workflow documentation per plugin
- `plugins/*/.mcp.json`: MCP server configuration per plugin

### Process Documentation
- `plugins/sdlc-app/commands/*.md`: Process methodologies (Event Modeling, TDD, Domain Modeling, etc.)
- `plugins/sdlc-infrastructure/commands/*.md`: Infrastructure-specific processes

### Agent Definitions
- `plugins/sdlc-app/agents/*.md`: 31 specialized agents for application workflow
- `plugins/sdlc-infrastructure/agents/*.md`: 3 specialized agents for infrastructure workflow
- `plugins/sdlc-*/agents/*-domain-model-expert.md`: Language-specific domain modeling agents

## Workflow Integration Points

### Phase 1: Requirements Analysis
- `requirements-analyst` agent defines WHAT and WHY
- Creates `docs/REQUIREMENTS_ANALYSIS.md`

### Phase 2: Event Modeling (Application workflow only)
- 15 agents implement 12-step Event Modeling process
- Creates hierarchical documentation under `docs/event_model/`
- PM and Architect review for completeness

### Phase 3-4: Architecture
- `adr-writer` creates ADRs collaboratively with user
- `architecture-synthesizer` synthesizes cohesive architecture
- Creates `docs/adr/` and `docs/ARCHITECTURE.md`

### Phase 5: Design System (Application workflow only)
- `design-system-architect` creates `docs/STYLE_GUIDE.md`
- Uses Atomic Design methodology

### Phase 6: Planning
- `story-planner` creates prioritized stories in `docs/PLANNING.md`
- `story-architect` reviews technical feasibility
- `ux-consultant` reviews UX coherence (application workflow only)

### Phase 7: Implementation
- TDD cycle: `red-tdd-tester` → domain modeling agent → `green-implementer`
- Hierarchical chained PRs with 5-Whys drill-down
- Mutation testing and cognitive load analysis

### Phase 8: Acceptance Validation
- `acceptance-validator` verifies requirements met
- `technical-documentation-writer` ensures documentation quality

## Contributing to Plugins

When modifying or adding plugins:

1. **Agent files**: Place in `plugins/{plugin-name}/agents/`
   - Name format: `{agent-name}.md`
   - Must define role, tools, and integration points

2. **Command files**: Place in `plugins/{plugin-name}/commands/`
   - Name format: `{command-name}.md`
   - Invoked via slash commands by agents or user

3. **System prompt**: Update `plugins/{plugin-name}/system-prompt.md`
   - Defines complete workflow, coordination rules, phase gates

4. **MCP servers**: Update `plugins/{plugin-name}/.mcp.json`
   - Auto-configured when plugin loads

5. **Marketplace**: Update `.claude-plugin/marketplace.json`
   - Add new plugin entry with name and source path

## Testing Workflows

To test a workflow end-to-end:

1. Create test project directory
2. Install marketplace: `/plugin marketplace add /home/jwilger/.claude`
3. Install workflow plugin: `/plugin install sdlc-app@jwilger-sdlc`
4. Initialize project: `/initialize-app-project` or `/initialize-infrastructure-project`
5. Use project launcher: `./scripts/claude`
6. Begin Phase 1 with requirements-analyst agent
7. Verify phase gates, agent coordination, and memory protocol

## SDLC Workflow

**Workflow Type:** Infrastructure
**Plugin:** sdlc-infrastructure@jwilger-sdlc
**Initialized:** 2025-10-12

This project uses technical architecture-based infrastructure/library development workflow.

**Phases:**
1. Technical Requirements Analysis
2. ~~Event Modeling~~ (Skipped for infrastructure)
3. Architectural Decision Records
4. Architecture Synthesis
5. ~~Design System~~ (Skipped for infrastructure)
6. Technical Increment Planning
7. Increment-by-Increment Implementation
8. Acceptance Validation

**Always use:** `./scripts/claude` to ensure correct workflow context.

For complete workflow documentation, see: `plugins/sdlc-infrastructure/system-prompt.md`
