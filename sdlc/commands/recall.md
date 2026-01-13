---
description: INVOKE before ANY task to check for existing solutions in memento
argument-hint: <what-to-recall>
model: haiku
allowed-tools:
  - mcp__memento__semantic_search
  - mcp__memento__open_nodes
---

# Retrieve Memory from Memento

Search and retrieve relevant knowledge from the memento knowledge graph.

## Arguments

`$ARGUMENTS` describes what to recall. Examples:
- "test patterns for this project"
- "database configuration decisions"
- "previous errors with cargo build"
- "user preferences for error handling"

## Process

### 1. Semantic Search

Start with a semantic search using key terms from the query:

```
mcp__memento__semantic_search:
  query: "<query based on arguments>"
  limit: 10
```

**Search tips:**
- Include project name if looking for project-specific knowledge
- Include error messages or tool names for debugging insights
- Use domain terms for business knowledge
- Try variations if first search doesn't find relevant results

### 2. Open Relevant Nodes

From search results, open the most relevant entities to get full details:

```
mcp__memento__open_nodes:
  names: ["<entity1>", "<entity2>", ...]
```

### 3. Traverse Relationships

Check the `relations` returned with each entity. Follow relevant relationships to gather connected context:

**Relationship traversal strategy:**

| If you see... | Then explore... |
|--------------|-----------------|
| `extends` / `derived_from` | The parent entity for foundational context |
| `supersedes` | The newer entity for updated information |
| `contradicts` | Both entities to understand the conflict |
| `part_of` | The container entity for broader context |
| `depends_on` | Dependencies that may affect the solution |
| `implements` | The specification being implemented |
| `related_to` | Adjacent knowledge that may be relevant |

**Continue traversing until:**
- You've gathered sufficient context for the query
- Relationships lead to clearly unrelated topics
- You've checked 2-3 levels of relationships

### 4. Synthesize and Return

Compile the relevant information and present it:

```
Found in memento:

<Entity Name>
  Type: <type>
  Key observations:
    - <relevant observation>
    - <relevant observation>
  Related to: <linked entities>

<Entity Name 2>
  ...

Summary: <1-2 sentence synthesis of what was found>
```

If nothing relevant found:
```
No relevant memories found for: "<query>"

Suggestions:
- Try different search terms
- The information may not have been stored yet
- Consider storing this knowledge after you discover it
```

## Example

Arguments: "test patterns for TaskFlow"

```
# 1. Semantic search with key terms
mcp__memento__semantic_search:
  query: "test patterns TaskFlow project"
  limit: 10

# 2. Open relevant results
mcp__memento__open_nodes:
  names: ["TaskFlow Test Patterns 2026-01"]

# 3. Follow relations (extends, part_of) for more context
# 4. Synthesize findings in output format above
```

**Same process applies to:** debugging solutions ("cargo test hanging"), architecture decisions, user preferences, domain concepts.

**If no results:** suggest alternative search terms or note the knowledge may not be stored yet.

## When to Use This Skill

**ALWAYS use at the start of:**
- New conversations/sessions
- Working on a new task
- Before making architectural decisions
- When encountering errors or problems
- When unsure about project conventions

**The memory protocol is non-negotiable.** Failing to check memento means potentially rediscovering knowledge that was already found.

## Search Query Tips

| Looking for... | Try searching... |
|----------------|------------------|
| Project setup | `"<project> setup configuration"` |
| Error solutions | `"<error message> fix solution"` |
| User preferences | `"preference style convention"` |
| Architecture | `"architecture decision <project>"` |
| Domain concepts | `"domain <concept> <project>"` |
| Tool quirks | `"<tool name> workaround issue"` |
