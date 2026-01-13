---
description: INVOKE after solving problems or learning conventions. Stores in memento
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

### 2. Determine Entity Type and Create Entity

**Naming convention:** `<Descriptive Name> [Project Name] <Date>`

| Type | Use For | Example |
|------|---------|---------|
| `debugging_insight` | Solutions to problems, error fixes | "Cargo Test Timeout Fix TaskFlow 2026-01" |
| `user_preference` | User's stated preferences, workflow choices | "Error Message Preferences 2026-01" |
| `project` | Project-level configuration, structure | "TaskFlow Project Config 2026-01" |
| `design_pattern` | Architectural patterns, coding conventions | "Event Sourcing Patterns TaskFlow 2026-01" |
| `tool_discovery` | Tool behaviors, CLI options, API quirks | "PostgreSQL JSONB Query Patterns 2026-01" |
| `domain_concept` | Business domain knowledge, terminology | "User Registration Domain Concepts 2026-01" |
| `feature_implementation` | Details about implemented features | "Auth Flow Implementation TaskFlow 2026-01" |
| `architecture_decision` | Technical decisions and rationale | "Database Choice ADR TaskFlow 2026-01" |
| `agent_checkpoint` | Subagent state for continuation | Internal use only |

**Debugging insight example:**
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

**User preference example:**
```
mcp__memento__create_entities:
  entities:
    - name: "Error Message Preferences 2026-01"
      entityType: "user_preference"
      observations:
        - "Scope: GENERAL"
        - "Preference: Verbose error messages preferred over terse ones"
        - "Preference: Include actionable suggestions and context (file paths, line numbers)"
```

### 3. Format Observations

Each observation should be a complete, self-contained statement:

**For project-specific knowledge:**
```
"Project: <name> | Path: <path> | Scope: PROJECT_SPECIFIC"
```

**For general patterns:**
```
"Scope: PATTERN" or "Scope: GENERAL"
```

**Always include:** Date context, specific details (not vague summaries), action taken and outcome, version numbers if applicable.

### 4. Create Relationships

Link to related entities using active voice relation types:

| Relation Type | Use For |
|--------------|---------|
| `implements` | When one thing implements another |
| `extends` | When building on existing knowledge |
| `depends_on` | Prerequisites or dependencies |
| `discovered_during` | Context of discovery |
| `supersedes` | Updated knowledge replacing old |
| `validates` | Confirms previous knowledge |
| `part_of` | Component relationships |
| `related_to` | General association |

**Always try to link to at least one existing entity** to maintain graph connectivity.

### 5. Return Confirmation

After storing, output:
```
Stored in memento:
  Entity: <entity name>
  Type: <entity type>
  Observations: <count>
  Relationships: <list of relations created>
```

## When NOT to Use This Skill

Don't store:
- Transient conversation details
- Information already in project files (code IS documentation)
- Duplicate information already in memento
- Sensitive data (credentials, personal information)
