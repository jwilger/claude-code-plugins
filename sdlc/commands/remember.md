---
description: Store discoveries and insights in memento knowledge graph
argument-hint: <what-to-remember>
model: haiku
allowed-tools:
  - mcp__memento__create_entities
  - mcp__memento__create_relations
  - mcp__memento__add_observations
  - mcp__memento__semantic_search
---

# Store Memory in Memento

Store discoveries, insights, and knowledge in the memento knowledge graph for future retrieval.

## Arguments

`$ARGUMENTS` describes what to remember. Examples:
- "The project uses Rust with Axum framework"
- "Found workaround for cargo test timeout issue"
- "User prefers explicit error messages over generic ones"

## Process

### 1. Search for Existing Related Entities

Before creating new entities, check if related knowledge already exists:

```
mcp__memento__semantic_search: "<key terms from arguments>"
```

If a closely related entity exists, consider adding observations to it rather than creating a new entity.

### 2. Determine Entity Type

Choose an appropriate entity type based on what's being stored:

| Type | Use For |
|------|---------|
| `project` | Project-level configuration, structure, purpose |
| `debugging_insight` | Solutions to problems, error fixes, workarounds |
| `design_pattern` | Architectural patterns, coding conventions |
| `user_preference` | User's stated preferences, workflow choices |
| `tool_discovery` | Tool behaviors, CLI options, API quirks |
| `domain_concept` | Business domain knowledge, terminology |
| `agent_checkpoint` | Subagent state for continuation (internal use) |
| `feature_implementation` | Details about implemented features |
| `architecture_decision` | Technical decisions and rationale |

### 3. Create Entity with Proper Naming

**Entity naming convention:** `<Descriptive Name> [Project Name] <Date>`

Examples:
- "Cargo Test Timeout Workaround TaskFlow 2026-01"
- "User Registration Domain Concepts 2026-01-08"
- "PostgreSQL JSONB Query Patterns 2026-01"

### 4. Format Observations

Each observation should be a complete, self-contained statement. Include metadata:

**For project-specific knowledge:**
```
"Project: <name> | Path: <path> | Scope: PROJECT_SPECIFIC"
```

**For general patterns:**
```
"Scope: PATTERN" or "Scope: GENERAL"
```

**Always include:**
- Date context when relevant
- Specific details (not vague summaries)
- Action taken and outcome (for debugging insights)
- Version numbers if applicable

**Example observations:**
```
"Project: TaskFlow | Path: /home/user/taskflow | Scope: PROJECT_SPECIFIC"
"Problem: cargo test hangs when running integration tests in parallel"
"Root cause: Database connection pool exhaustion under concurrent load"
"Solution: Set RUST_TEST_THREADS=1 for integration tests or use separate connection pools"
"Date discovered: 2026-01-08"
```

### 5. Create Relationships

After creating an entity, link it to related entities using active voice relation types:

| Relation Type | Use For |
|--------------|---------|
| `implements` | When one thing implements another |
| `extends` | When building on existing knowledge |
| `depends_on` | Prerequisites or dependencies |
| `discovered_during` | Context of discovery |
| `contradicts` | Conflicting information (note both!) |
| `supersedes` | Updated knowledge replacing old |
| `validates` | Confirms previous knowledge |
| `part_of` | Component relationships |
| `related_to` | General association |
| `derived_from` | Origin of knowledge |

**Always try to link to at least one existing entity** to maintain graph connectivity.

### 6. Return Confirmation

After storing, output:
```
Stored in memento:
  Entity: <entity name>
  Type: <entity type>
  Observations: <count>
  Relationships: <list of relations created>
```

## Examples

### Example 1: Storing a debugging insight

Arguments: "Fixed cargo test timeout by setting RUST_TEST_THREADS=1"

```
mcp__memento__create_entities:
  entities:
    - name: "Cargo Test Timeout Fix TaskFlow 2026-01"
      entityType: "debugging_insight"
      observations:
        - "Project: TaskFlow | Path: /home/user/taskflow | Scope: PROJECT_SPECIFIC"
        - "Problem: cargo test hangs on integration tests"
        - "Solution: Set RUST_TEST_THREADS=1 to prevent connection pool exhaustion"
        - "Date: 2026-01-08"
```

### Example 2: Storing a user preference

Arguments: "User wants verbose error messages with suggestions"

```
mcp__memento__create_entities:
  entities:
    - name: "Error Message Preferences 2026-01"
      entityType: "user_preference"
      observations:
        - "Scope: GENERAL"
        - "Preference: Verbose error messages preferred over terse ones"
        - "Preference: Error messages should include actionable suggestions"
        - "Preference: Include relevant context (file paths, line numbers) when available"
```

## When NOT to Use This Skill

Don't store:
- Transient conversation details
- Information already in project files (code IS documentation)
- Duplicate information already in memento
- Sensitive data (credentials, personal information)
