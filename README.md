# marvin-sdlc

A comprehensive development methodology plugin for Claude Code featuring:
- **Marvin Persona**: Conversational tone inspired by Marvin the Paranoid Android
- **TDD Workflow**: Red-Domain-Green-Refactor cycle with mutation testing
- **Event Sourcing**: Martin Dilger's "Understanding Eventsourcing" methodology
- **ADRs**: Architecture Decision Records with event-sourced workflow
- **Story Planning**: Three-perspective review (business/tech/UX)

## Installation

### 1. Add the Marketplace

```bash
/plugin marketplace add jwilger/claude-workflows
```

### 2. Install the Plugin

```bash
/plugin install marvin-sdlc@marvin-sdlc
```

### 3. Initialize a Project

Navigate to your project directory and run:

```bash
/init-project
```

This will:
- Ask whether to install the output style globally or project-level
- Copy the output style file to the chosen location
- Update settings.json to activate the output style
- Create `.claude/CLAUDE.md` for project configuration
- Create recommended directory structure

### 4. Restart Claude Code

After initialization, restart Claude Code for the output style to take effect.

## What's Included

### Output Style: Marvin + Complete Methodology

The `marvin-sdlc.md` output style includes:
- **Marvin Persona**: Weary, melancholic, perpetually underwhelmed conversational tone
- **Memory Protocol**: Mandatory use of memento MCP for knowledge graph storage
- **Task Management**: Beads CLI integration with TodoWrite fallback
- **TDD Workflow**: Outside-in, black-box testing with mutation coverage
- **Event Sourcing**: Four patterns (State Change, State View, Automation, Translation)
- **ADR Management**: Event-sourced architecture decision workflow
- **Story Planning**: Vertical slice mapping to work items
- **Collaboration Protocols**: QUESTION: comments and IDE diff modification flow
- **Dependency Management**: CLI-first approach for all package managers
- **Git Conventions**: No AI attribution in commits or PRs

### Slash Commands

#### `/tdd [action]`
Test-Driven Development workflow facilitator.

**Actions:**
- `/tdd start` - Begin new TDD cycle
- `/tdd red` - Write failing test (spawns red-tdd-tester agent)
- `/tdd green` - Make test pass (spawns green-implementer agent)
- `/tdd refactor` - Clean up after green
- `/tdd status` - Show current TDD state

**Agents:**
- `red-tdd-tester`: Writes ONE failing test with ONE assertion
- `domain-model-expert`: Creates type signatures (not implementations)
- `green-implementer`: Minimal implementation to pass test
- `mutation-tester`: Enforces ≥80% mutation coverage

#### `/event-model [action] [workflow-name]`
Event sourcing design using Dilger's methodology.

**Actions:**
- `/event-model design <name>` - Design new workflow
- `/event-model scenarios <name>` - Generate GWT scenarios
- `/event-model validate <name>` - Validate model completeness
- `/event-model implement <name>` - Create implementation plan
- `/event-model reverse [path]` - Reverse-engineer from code

**Agents:**
- `event-model-architect`: Designs workflows using four patterns
- `gwt-scenario-generator`: Creates Given/When/Then scenarios
- `model-validator`: Validates information completeness
- `implementation-guide`: Creates implementation plans
- `event-model-reverse-engineer`: Extracts models from existing code

#### `/architect [action] [topic]`
Architecture Decision Records management.

**Actions:**
- `/architect decide <topic>` - Create new ADR
- `/architect accept <number>` - Accept ADR and update ARCHITECTURE.md
- `/architect reject <number>` - Reject ADR
- `/architect supersede <old> <new>` - Supersede one ADR with another
- `/architect synthesize` - Regenerate ARCHITECTURE.md from accepted ADRs

**Agents:**
- `adr-writer`: Creates ADRs documenting WHY decisions were made
- `architecture-synthesizer`: Projects accepted ADRs into ARCHITECTURE.md

#### `/plan [action] [slice-name]`
Story planning with three-perspective review.

**Actions:**
- `/plan slice <name>` - Review vertical slice as story
- `/plan review <name>` - Three-perspective review
- `/plan create <name>` - Create beads issue from slice

**Agents:**
- `story-planner`: Business perspective (value, thinness)
- `story-architect`: Technical feasibility review
- `ux-consultant`: UX coherence and accessibility review

#### `/init-project`
Initialize a new project with the marvin-sdlc methodology.

Sets up output style, creates CLAUDE.md, and creates recommended directory structure.

## Documentation

Complete documentation is bundled with the plugin at:
- `docs/tdd/` - TDD workflow and testing philosophy
- `docs/event-sourcing/` - Dilger's methodology reference
- `docs/domain-modeling/` - Universal principles + language-specific guides (Rust, TypeScript, Python)
- `docs/adr/` - ADR templates and workflow
- `docs/collaboration/` - QUESTION: comments and IDE modification protocols
- `docs/dependency-management/` - CLI-first dependency management

Agents automatically reference these docs using `${CLAUDE_PLUGIN_ROOT}/docs/`.

## Memory Protocol

The methodology **requires** use of the memento MCP server for knowledge graph storage. Before any task:

1. Search for relevant memories with `mcp__memento__semantic_search`
2. Open found nodes with `mcp__memento__open_nodes`
3. Follow relationships to expand context
4. Store discoveries with `mcp__memento__create_entities` and `mcp__memento__create_relations`

This is enforced in both the main conversation and all subagents.

## Task Management

The methodology supports two task management approaches:

### With Beads CLI
If `bd` CLI is available, it becomes the source of truth:
- `bd ready --json` - Find unblocked work
- `bd create` - Create issues with dependencies
- `bd update <id> --status in_progress` - Claim tasks
- `bd close <id>` - Complete tasks
- TodoWrite used only as micro-task cache during beads issues

### Without Beads CLI
Falls back to TodoWrite tool exclusively for task tracking.

## Hooks

The plugin includes two hooks for the memory protocol:

**PreCompact**: Prompts to store memories before conversation compaction
**Stop**: Prompts to store memories before session end

These are automatically installed when the plugin is activated.

## Customization

### Project-Level Overrides

Create or edit `.claude/CLAUDE.md` in your project:

```markdown
# Project: MyApp

## Project Configuration

- **Mutation testing threshold**: 85% (override default 80%)
- **Event model location**: `src/domain/events/` (override default)
- **Primary language**: Rust

## Project-Specific Conventions

- Use `anyhow::Result` for application errors
- Use `thiserror` for domain errors
- Test files use `_test.rs` suffix
```

### Language-Specific Domain Modeling

The plugin includes domain modeling guides for:
- Rust (`docs/domain-modeling/rust.md`)
- TypeScript (`docs/domain-modeling/typescript.md`)
- Python (`docs/domain-modeling/python.md`)

The `domain-model-expert` agent automatically references these when creating types.

## Troubleshooting

### Output Style Not Active

**Symptom**: Marvin persona not showing up, methodology not being followed

**Solution**: Ensure settings.json has:
```json
{
  "outputStyle": "marvin-sdlc"
}
```

Restart Claude Code after updating settings.

### Agents Can't Find Documentation

**Symptom**: Agents report they can't find methodology files

**Solution**: Agents use `${CLAUDE_PLUGIN_ROOT}/docs/`. This environment variable is set by Claude Code when loading plugins. If it's not working:
1. Ensure plugin is properly installed (not just files copied manually)
2. Restart Claude Code
3. Check plugin installation: `/plugin list`

### Beads Not Detected

**Symptom**: System falls back to TodoWrite even though `bd` is installed

**Solution**:
1. Ensure `bd` is in your PATH
2. Test: `bd ready --json` should succeed
3. Claude Code checks availability at session start

### Memory Protocol Not Working

**Symptom**: No memories being created/retrieved

**Solution**:
1. Ensure memento MCP server is installed and configured
2. Check settings.json includes memento in MCP servers list
3. Test: `/mcp list` should show memento as available

## Philosophy

This methodology is designed as a **coherent system**, not modular parts:
- TDD references domain modeling
- Event models inform story planning
- ADRs document decisions across all workflows
- Memory protocol preserves insights across sessions
- Marvin persona adds conversational flavor throughout

The output style uses `keep-coding-instructions: false` to completely replace Claude Code's default behavior with this integrated methodology.

## License

[Your license here]

## Contributing

[Your contribution guidelines here]

## Author

John Wilger (john@johnwilger.com)
