# SDLC Core

Core foundations for software development lifecycle workflows.

## Features

- **Memory Protocol**: Verification and guidance for using memento MCP for persistent knowledge
- **Session Hooks**: Automatic memory checkpoints at session start, compaction, and end

## Prerequisites

- [Memento MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/memento) configured in Claude Code
- Neo4j database for memento storage

## What This Plugin Does

### SessionStart Hook

Verifies that the memento MCP server is available. If not configured, warns the user once without blocking the session.

### PreCompact and Stop Hooks

Prompts memory checkpoints to save unsaved discoveries before context is lost to compaction or session end.

### Memory Protocol Skill

Provides comprehensive guidance on using memento for knowledge persistence:
- How to search for relevant memories before starting work
- How to store discoveries with proper naming and relationships
- Best practices for memory management

## Usage with Other SDLC Plugins

This plugin is a dependency for other sdlc-* plugins:
- sdlc-architecture
- sdlc-event-modeling
- sdlc-planning
- sdlc-tdd

Each of those plugins' agents should follow the memory protocol defined here.

## Configuration

No configuration required. The plugin automatically checks for memento availability at session start.

## License

MIT
