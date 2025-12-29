---
name: Memory Protocol
description: |
  This skill should be used when the user asks about "memory protocol", "memento", "knowledge graph",
  "remembering context", "storing memories", "long-term memory", or when any SDLC workflow needs
  to persist or retrieve knowledge across sessions. Provides the standard protocol for using the
  memento MCP server to maintain project context.

  Trigger phrases: "memory protocol", "how to remember", "store this for later", "memento usage",
  "knowledge graph", "persist context", "recall previous", "remember this"
version: 1.0.0
---

# Memory Protocol

## Overview

The memory protocol defines how to use the memento MCP server for persistent knowledge across sessions.
This protocol is used by all SDLC workflows to maintain project context, store discoveries, and
build cumulative knowledge about codebases and decisions.

## Core Principle

Long-term memory (training data) and short-term memory (conversation context) are excellent, but
"mid-term" memory for project-specific knowledge outside the current context is limited. Memento
addresses this gap by providing a knowledge graph that persists between sessions.

---

## Before Starting Any Task

**ALWAYS search for relevant memories FIRST:**

```
1. Use mcp__memento__semantic_search with a query describing the current task
2. Use mcp__memento__open_nodes to get full details on relevant results
3. Follow graph relationships to expand context
4. Continue traversing until results are no longer relevant
```

**IMPORTANT:** Do NOT use `mcp__memento__read_graph` to read the entire graph. Memories are stored
across ALL projects and the graph can be huge. Always use semantic search to find relevant subsets.

---

## During and After Work

Store memories for any interesting, non-obvious information acquired, especially:

- Anything that required research or web searches
- Solutions found through trial and error
- Project-specific conventions, patterns, or architectural decisions
- User preferences and workflow patterns
- Debugging insights and root cause analyses
- Integration details and API quirks

### Creating Entities

Use `mcp__memento__create_entities` with:

**Entity naming:** Use descriptive names with project and date context
- Example: "Railgun Event Modeling 2025-12", "PrimeCtrl Design Principles"

**Entity types:** Choose meaningful types like:
- `project`, `constraint`, `design_pattern`, `debugging_insight`
- `user_preference`, `architectural_decision`, `api_quirk`

**Observations format:**
- Project-specific: `Project: <name> | Path: <path> | Scope: PROJECT_SPECIFIC`
- General patterns: `Scope: PATTERN` or `Scope: GENERAL`
- Add dates to observations for temporal context

### Creating Relationships

**Always** create relationships between related memories using `mcp__memento__create_relations`.

Use descriptive relation types in active voice:
- `implements`, `extends`, `depends_on`, `discovered_during`
- `contradicts`, `supersedes`, `validates`
- `part_of`, `related_to`, `derived_from`

---

## For Subagents

All agents delegated work via the Task tool should:

1. Search for relevant memories before beginning their delegated task
2. Store any new insights discovered during their work
3. Create relationships to existing memories when applicable

Include a reminder in agent prompts: "Remember: Follow the memory protocol - search memento for
project context, store discoveries."

---

## Before Session End or Compact

When detecting a session is ending or conversation will be compacted, **proactively store any
unsaved discoveries** in memento. Don't let knowledge be lost to context truncation.

The sdlc-core plugin provides hooks for PreCompact and Stop events to prompt memory checkpoints.

---

## Example Usage

### Searching Before a Task

```
Task: Implement user authentication
Query: "authentication patterns user login security"

Results might include:
- Previous auth decisions for this project
- Security patterns used in similar projects
- User preferences about auth libraries
```

### Storing a Discovery

```
Entity: "Eventcore PostgreSQL Connection Pooling 2025-12"
Type: debugging_insight
Observations:
  - "Project: eventcore | Path: /home/user/projects/eventcore | Scope: PROJECT_SPECIFIC"
  - "PostgreSQL connection pool exhaustion occurs when >50 concurrent projections"
  - "Solution: Use bb8 pool with max_size=20, connection_timeout=5s"
  - "Root cause: Each projection held connection during entire batch processing"
```

### Creating Relationships

```
From: "Eventcore PostgreSQL Connection Pooling 2025-12"
To: "PostgreSQL Best Practices"
RelationType: "validates"

From: "Eventcore PostgreSQL Connection Pooling 2025-12"
To: "Eventcore Projection System Design"
RelationType: "discovered_during"
```

---

## Best Practices

1. **Search first** - Always check if relevant knowledge exists before starting work
2. **Be specific** - Use descriptive entity names and detailed observations
3. **Create relationships** - Connected memories are more discoverable
4. **Date your observations** - Temporal context helps track evolution
5. **Scope appropriately** - Mark project-specific vs general patterns
6. **Don't over-store** - Focus on non-obvious, valuable insights
7. **Follow up** - When using stored knowledge, verify it's still accurate
