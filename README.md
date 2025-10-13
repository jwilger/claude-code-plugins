# Professional SDLC Workflow Plugin Marketplace

A comprehensive Software Development Lifecycle (SDLC) workflow system for Claude Code, featuring Event Modeling, Type-First TDD, and Domain-Driven Design principles.

## Overview

This plugin marketplace provides a complete 8-phase sequential development workflow with 35+ specialized agents, 13 slash commands, and integration with MCP servers for persistent memory and tooling.

### Core Philosophy

- **Event Modeling First**: Business events drive architecture (12-step workflow)
- **Type-System-First TDD**: Compiler-driven types before runtime tests
- **Domain Modeling Made Functional**: Parse Don't Validate, make illegal states unrepresentable
- **Documentation Philosophy**: WHAT/WHY, not HOW - decisions and rationale, not implementation guides
- **Sequential Workflow**: Each phase must complete before the next begins

### 8-Phase Sequential Workflow

1. **Requirements Analysis** - Define WHAT the software should do and WHY
2. **Event Modeling** - 12-step business event modeling with vertical slices
3. **Architectural Decision Records (ADRs)** - Document decisions and rationale
4. **Architecture Synthesis** - Cohesive system design from ADRs
5. **Design System** - Atomic Design methodology for UI patterns
6. **Story Planning** - Thin vertical slice user stories with Gherkin acceptance criteria
7. **Story-by-Story Implementation** - TDD with domain modeling and quality gates
8. **Acceptance Validation** - Requirements verification and documentation QA

## Available Plugins

### Workflow Plugins

Choose the workflow that matches your project type:

#### Application Workflow: `sdlc-app`

**For:** Web/mobile/desktop applications, line-of-business apps, projects with end-user interfaces

Event Modeling-based application development workflow:
- **31 Core Agents**: Requirements analysis, event modeling (15 agents), architecture, planning, TDD, validation
- **14 Slash Commands**: Process methodologies, workflow activation, project initialization
- **2 MCP Servers**: Time (temporal anchoring) and Memento (knowledge graph memory)

**8-Phase Workflow:**
1. Requirements Analysis
2. **Event Modeling** (12-step process)
3. Architectural Decision Records
4. Architecture Synthesis
5. **Design System** (Atomic Design)
6. Story Planning (user stories)
7. Story-by-Story Implementation
8. Acceptance Validation

**Key Features:**
- Event Modeling with hierarchical documentation
- UX consultant involvement throughout
- User-facing acceptance criteria
- UI/UX design patterns

#### Infrastructure Workflow: `sdlc-infrastructure`

**For:** Libraries, frameworks, developer tools, APIs, SDKs, system utilities

Technical architecture-based infrastructure development workflow:
- **3 Core Agents**: Technical requirements analyst, technical increment planner, story architect
- **3 Slash Commands**: Technical increment planning, workflow activation, project initialization
- **2 MCP Servers**: Time (temporal anchoring) and Memento (knowledge graph memory)

**6-Phase Workflow:**
1. Technical Requirements Analysis
2. ~~Event Modeling~~ (Skipped)
3. Architectural Decision Records
4. Architecture Synthesis
5. ~~Design System~~ (Skipped)
6. Technical Increment Planning (dependency-ordered)
7. Increment-by-Increment Implementation
8. Acceptance Validation

**Key Features:**
- Technical requirements focus (API contracts, performance, compatibility)
- Dependency-based prioritization
- Technical acceptance criteria
- Public API integration points
- Usage examples for consumers

**Both Workflows Share:**
- Outside-In TDD with hierarchical chained PRs
- Memory intelligence with semantic search and graph traversal
- Mutation testing (≥80% score) and cognitive load analysis (TRACE framework)
- Type-first domain modeling approach

### Language-Specific Plugins

Each language plugin provides domain modeling expertise using language-specific type systems:

#### `sdlc-rust`
- **Agent**: rust-domain-model-expert
- **MCP Server**: cargo-mcp (Rust tooling integration)
- **Approach**: Typestate pattern, nutype for domain constraints, compile-time safety

#### `sdlc-python`
- **Agent**: python-domain-model-expert
- **Approach**: Pydantic models, runtime validation, type hints

#### `sdlc-typescript`
- **Agent**: typescript-domain-model-expert
- **Approach**: Branded types, discriminated unions, compile-time guarantees

#### `sdlc-elixir`
- **Agent**: elixir-domain-model-expert
- **Approach**: Structs with enforced keys, pattern matching, Ecto schemas

## Installation

### Prerequisites

- Claude Code CLI installed
- Node.js (for MCP servers)
- Git

### Install Marketplace

```bash
# Add this marketplace to Claude Code
/plugin marketplace add /home/jwilger/.claude
```

### Install Core Plugin

```bash
# Install the core SDLC workflow
/plugin install sdlc-app@jwilger-sdlc
```

### Install Language Plugin (Optional)

Choose the language plugin for your project:

```bash
# For Rust projects
/plugin install sdlc-rust@jwilger-sdlc

# For Python projects
/plugin install sdlc-python@jwilger-sdlc

# For TypeScript projects
/plugin install sdlc-typescript@jwilger-sdlc

# For Elixir projects
/plugin install sdlc-elixir@jwilger-sdlc
```

## Getting Started

### Initialize a New Project

The first step is to initialize your project with the appropriate workflow:

#### For Application Projects

```bash
# In Claude Code, in your project directory
/initialize-app-project
```

This will:
1. Run standard `/init` to create CLAUDE.md
2. Append workflow configuration to CLAUDE.md
3. Create `./scripts/claude` launcher configured for application workflow
4. Store workflow choice in memory for verification

#### For Infrastructure/Library Projects

```bash
# In Claude Code, in your project directory
/initialize-infrastructure-project
```

This will:
1. Run standard `/init` to create CLAUDE.md
2. Append workflow configuration to CLAUDE.md
3. Create `./scripts/claude` launcher configured for infrastructure workflow
4. Store workflow choice in memory for verification

### Daily Usage

After initialization, **always** launch Claude Code using the project-local launcher:

```bash
./scripts/claude
```

This ensures the correct workflow context is loaded automatically.

**Benefits of project-local launcher:**
- No system-wide aliases needed
- Correct workflow always loaded
- Portable across team members
- Visible in version control (team sees workflow choice)
- Prevents accidentally using wrong workflow

### Workflow Verification

The plugins automatically verify workflow compatibility:
- Checks CLAUDE.md for "## SDLC Workflow" section
- Validates "Workflow Type: Application" or "Workflow Type: Infrastructure"
- **Blocks all operations** if wrong workflow detected
- Provides clear error message with recovery options

## MCP Server Configuration

The plugins automatically configure required MCP servers:

### Core Plugin MCP Servers

#### Time Server
- **Purpose**: Temporal anchoring for memory operations
- **Package**: `@modelcontextprotocol/server-time`
- **Auto-configured**: Yes

#### Memento Server
- **Purpose**: Knowledge graph memory for persistent learning
- **Package**: `@gannonh/memento-mcp`
- **Storage**: SQLite at `~/.claude/memento.db`
- **Auto-configured**: Yes

### Rust Plugin MCP Server

#### Cargo MCP
- **Purpose**: Rust Cargo operations (check, test, build, clippy)
- **Package**: cargo-mcp
- **Installation**: `/setup-cargo-mcp` (guides you through installation)
- **Manual install**: `cargo install cargo-mcp`

## Key Slash Commands

Process methodology commands (invoked by agents):

- `/domain-modeling-process` - Workflow Functions First, Compiler-Driven Types
- `/tdd-workflow-process` - Outside-In TDD with hierarchical PRs
- `/event-modeling-process` - 12-step Event Modeling methodology
- `/story-planning-process` - Thin vertical slice stories
- `/documentation-philosophy` - WHAT/WHY principles
- `/adr-template` - ADR structure and lifecycle
- `/design-system-process` - Atomic Design methodology
- `/dependency-management-process` - Dependency protocol
- `/github-pr-management` - PR review threading
- `/integration-validation` - Integration testing requirements
- `/event-model-template` - Event Model structure

Setup and activation commands (invoked by user):

- `/sdlc-workflow` - Activate complete workflow
- `/setup-sdlc-alias` - Intelligent alias setup
- `/setup-cargo-mcp` - Cargo MCP installation guide

## Agent Categories

### Phase 1: Requirements Analysis
- `requirements-analyst` - Defines WHAT and WHY

### Phase 2: Event Modeling (12-Step Process)
- `event-modeling-step-0` - Functional areas and workflows
- `event-modeling-step-1` - Goal events
- `event-modeling-step-2` - Event sequences
- `event-modeling-step-3` - Commands
- `event-modeling-step-4` - Triggers
- `event-modeling-step-5` - Final UI screens
- `event-modeling-step-6` - Queries and projections
- `event-modeling-step-7` - Projection events
- `event-modeling-step-8` - Event data fields
- `event-modeling-step-9` - Command sources
- `event-modeling-step-10` - Acceptance criteria
- `event-modeling-step-11` - Cross-linking
- `event-modeling-step-12` - Completeness validation
- `event-modeling-pm` - Business review
- `event-modeling-architect` - Technical review

### Phase 3-4: Architecture
- `adr-writer` - Creates ADRs with user collaboration
- `architecture-synthesizer` - Synthesizes ADRs into cohesive architecture

### Phase 5: Design System
- `design-system-architect` - Creates STYLE_GUIDE.md with Atomic Design

### Phase 6: Story Planning
- `story-planner` - Creates prioritized user stories
- `story-architect` - Reviews technical feasibility
- `ux-consultant` - Reviews UX coherence

### Phase 7: Implementation (Story-by-Story Core Loop)
- `red-tdd-tester` - Writes failing tests (outside-in)
- `green-implementer` - Makes tests pass (minimal implementation)
- `rust-domain-model-expert` (or language variant) - Creates types incrementally
- `cognitive-load-analyzer` - TRACE framework analysis

### Phase 8: Acceptance Validation
- `acceptance-validator` - Requirements verification
- `technical-documentation-writer` - Documentation QA

### Supporting Agents
- `research-specialist` - Deep research with memory storage
- `devops` - Infrastructure and CI/CD
- `dependency-management` - Platform-appropriate dependency management

## Memory Intelligence Protocol

All agents use a mandatory 3-phase memory protocol:

0. **Temporal Anchoring**: Call `mcp__time__get_current_time` first
1. **Semantic Search**: Content-based search for relevant memories
2. **Graph Traversal**: Follow relationships to discover complete context
3. **Temporal Precedence**: Recent project-specific > older general memories

This ensures agents learn from past decisions and maintain consistency across the entire development process.

## Quality Gates

The workflow enforces quality through multiple gates:

### Build/Test Verification
- **MANDATORY**: Clean compile with zero warnings
- **MANDATORY**: All tests passing
- **Auto-commit blocked**: Until build and tests pass

### Domain Review Gate
- **MANDATORY**: Domain modeling agent reviews EVERY test
- **MANDATORY**: Domain modeling agent reviews EVERY implementation
- **Approval required**: Before auto-commit

### Mutation Testing Gate
- **Required**: ≥80% mutation score for new code
- **Enforced by**: cognitive-load-analyzer

### Cognitive Load Gate (TRACE Framework)
- **Required**: ≥70% overall TRACE score, each dimension ≥50%
- **Enforced by**: cognitive-load-analyzer before PR creation
- **Dimensions**: Type-first, Readability, Atomic scope, Cognitive budget, Essential only

## Documentation Structure

The workflow produces comprehensive documentation:

```
docs/
├── REQUIREMENTS_ANALYSIS.md      # Phase 1: User stories and acceptance criteria
├── EVENT_MODEL.md                # Phase 2: Index/TOC for event model
├── event_model/
│   ├── functional-areas/         # Event Model documents with Mermaid diagrams
│   ├── events/                   # Individual event definitions
│   ├── commands/                 # Individual command definitions
│   ├── ui-screens/               # UI screen definitions with wireframes
│   ├── automations/              # Automation definitions
│   ├── projections/              # Projection definitions
│   ├── queries/                  # Query definitions
│   └── domain_types/             # Domain type definitions
├── adr/                          # Phase 3: Architectural Decision Records
├── ARCHITECTURE.md               # Phase 4: Synthesized architecture
├── STYLE_GUIDE.md               # Phase 5: Design system with Atomic Design
└── PLANNING.md                  # Phase 6: Prioritized user stories
```

## Troubleshooting

### Plugin Not Found

```bash
# Verify marketplace is added
/plugin marketplace list

# If not listed, add it
/plugin marketplace add /home/jwilger/.claude
```

### MCP Servers Not Working

```bash
# Check MCP server status
# In Claude Code, servers should auto-start when plugin loads

# For cargo-mcp specifically:
/setup-cargo-mcp
```

### Agents Not Following Workflow

- **If using Approach 1**: Ensure you launched with `claude-sdlc` alias
- **If using Approach 2**: Ensure you ran `/sdlc-workflow` in the conversation
- **Check**: Verify plugin installed: `/plugin list`

### Memory Not Persisting

- **Check**: Memento database location: `~/.claude/memento.db`
- **Ensure**: Time MCP server working (temporal anchoring required)
- **Verify**: Agents are calling memory operations (semantic_search, create_entities, etc.)

### Process Commands Not Loading

- **Symptom**: Agents reference process files instead of slash commands
- **Cause**: Outdated agent definitions
- **Fix**: Reinstall plugin: `/plugin uninstall sdlc-app@jwilger-sdlc` then `/plugin install sdlc-app@jwilger-sdlc`

## Contributing

This plugin marketplace is designed to be extensible:

1. **Add new language plugins**: Follow the pattern in existing language plugins
2. **Customize process files**: Edit commands in `plugins/sdlc-app/commands/`
3. **Add specialized agents**: Create new agents in appropriate plugin's `agents/` directory
4. **Extend workflows**: Modify system-prompt.md for new phases or gates

## Philosophy and Principles

### Event Modeling
- **Focus**: Business events (persistent state changes only)
- **NOT events**: UI interactions, debug logging, performance metrics
- **Process**: 12 sequential steps from goal events to complete vertical slices
- **Output**: Hierarchical documentation with Mermaid diagrams

### Type-First TDD
- **Principle**: Maximize compile-time safety, minimize runtime errors
- **Workflow**: Red → Domain Modeler → Green (NOT Red → Green)
- **Domain review**: After EVERY test write, after EVERY implementation
- **5-Whys Decision Tree**: Drill down when fix not obvious

### Documentation Philosophy
- **Focus**: WHAT and WHY, never HOW
- **ADRs**: Decisions and rationale, not implementation guides
- **Code examples**: Maximum 5-10 lines, only to support rationale
- **Minimal**: No speculative documentation

### Domain Modeling Made Functional
- **Workflow Functions First**: Define what functions you need before types
- **Compiler-Driven Types**: Let compiler errors tell you what types to create
- **Parse Don't Validate**: Make illegal states unrepresentable
- **Minimal Types**: Only create types demanded by compiler or current story

## License

MIT

## Author

John Wilger (john@johnwilger.com)

## Repository

https://github.com/jwilger/claude-code-setup
