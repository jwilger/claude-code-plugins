---
name: knowledge-graph
description: Manages project knowledge graph for storing decisions, recalling patterns, searching memories, and traversing relationships. Uses temporal anchoring, semantic search, and graph traversal. Use when user wants to remember decisions, recall patterns, search project knowledge, or explicitly manage project memory.
allowed-tools: [mcp__memento__create_entities, mcp__memento__create_relations, mcp__memento__add_observations, mcp__memento__semantic_search, mcp__memento__open_nodes, mcp__memento__read_graph, mcp__memento__search_nodes, mcp__memento__delete_entities, mcp__memento__delete_observations, mcp__memento__delete_relations, mcp__memento__get_relation, mcp__memento__update_relation, mcp__memento__get_entity_embedding, mcp__memento__get_entity_history, mcp__memento__get_relation_history, mcp__memento__get_graph_at_time, mcp__memento__get_decayed_graph, mcp__time__get_current_time, mcp__time__convert_time, Read, Glob, Grep, Bash]
---

# Knowledge Graph Management

Manages project knowledge graph for storing architectural decisions, recalling patterns, and maintaining project context across sessions.

## When to Use This Skill

- **User requests memory operations**: "Remember this decision", "What did we decide about X?"
- **Explicit knowledge storage**: "Store this pattern for future use"
- **Knowledge retrieval**: "Recall our authentication approach", "Find decisions about error handling"
- **Pattern discovery**: "Show me related decisions", "What patterns have we used before?"
- **Memory maintenance**: "Update our decision about X", "Remove obsolete pattern Y"

## Core Operations

### 1. Temporal Anchoring

**ALWAYS start with temporal anchoring:**
```
Call: mcp__time__get_current_time(timezone: "America/Los_Angeles")
```

**Why**: Prevents defaulting to incorrect dates (like January 1st). All temporal references must anchor to reality.

### 2. Storing Decisions

**Create Entity for Decision:**
```json
{
  "entities": [{
    "name": "ADR: Use Event Sourcing for State Management",
    "entityType": "architectural_decision",
    "observations": [
      "Project: ecommerce-platform | Scope: PROJECT_SPECIFIC",
      "Decision: Implement event sourcing for order state management",
      "Rationale: Audit trail required by business, enables temporal queries",
      "Alternatives Considered: Traditional CRUD (rejected - no audit), State machines (rejected - limited history)",
      "Date: 2025-10-16",
      "Status: Accepted"
    ]
  }]
}
```

**Create Relationships:**
```json
{
  "relations": [{
    "from": "ADR: Use Event Sourcing",
    "to": "ADR: Choose PostgreSQL Event Store",
    "relationType": "depends_on"
  }]
}
```

### 3. Recalling Decisions

**Semantic Search:**
```
Query: "event sourcing state management decisions"
Returns: Entities matching semantic meaning, ranked by relevance
```

**Graph Traversal:**
```
1. Open nodes by name
2. Follow relationships ("depends_on", "supersedes", "relates_to")
3. Build complete context from connected decisions
```

**Temporal Queries:**
```
Get graph state at specific time:
mcp__memento__get_graph_at_time(timestamp: 1697500800000)
```

### 4. Updating Knowledge

**Add Observations:**
```json
{
  "observations": [{
    "entityName": "ADR: Use Event Sourcing",
    "contents": [
      "Update 2025-10-20: Successfully implemented for Order domain",
      "Performance: Handles 1000 events/sec comfortably"
    ]
  }]
}
```

**Supersede Old Decisions:**
```json
{
  "relations": [{
    "from": "ADR-023: New Approach",
    "to": "ADR-015: Old Approach",
    "relationType": "supersedes"
  }]
}
```

### 5. Pattern Storage

**Store Reusable Pattern:**
```json
{
  "entities": [{
    "name": "Pattern: Parse Don't Validate",
    "entityType": "design_pattern",
    "observations": [
      "Scope: UNIVERSAL",
      "Description: Transform unvalidated input into domain types at boundaries",
      "Example: UserEmail::parse(string) -> Result<UserEmail, ParseError>",
      "Benefits: Illegal states unrepresentable, validation centralized",
      "Used In: ecommerce-platform, user-service, auth-service"
    ]
  }]
}
```

## Knowledge Classification

### Scope Types

**PROJECT_SPECIFIC:**
- File paths, database schemas, API configs
- Specific to one project
- Priority: 1.0 for current project

**UNIVERSAL:**
- Programming concepts, design patterns, tool usage
- Applies across projects
- Priority: 0.8

**PATTERN:**
- Reusable approaches with adaptation potential
- Transferable with context
- Priority: 0.6

### Entity Types

**architectural_decision:**
- ADRs, technical choices
- Why certain approaches chosen

**design_pattern:**
- Reusable solutions
- Coding patterns and practices

**process_refinement:**
- Workflow improvements
- Lessons learned
- Process evolutions

**user_preference:**
- User-specific preferences per project
- Corrections and feedback

**constraint:**
- Project limitations
- Technical constraints
- Business rules

## Relationship Types

**supersedes:**
- New decision replaces old
- Temporal evolution

**depends_on:**
- Dependencies between decisions
- Implementation order

**relates_to:**
- Associated decisions
- Context connections

**implements:**
- Pattern applied to decision
- Concrete implementation of abstract pattern

**refines:**
- Incremental improvements
- Process evolution

## Memory Retrieval Protocol

### Three-Phase Loading

**Phase 0: Temporal Anchoring**
```
ALWAYS: mcp__time__get_current_time()
```

**Phase 1: Semantic Search**
```
Query: Relevant keywords
Filter: By project context if applicable
Returns: Initial candidates
```

**Phase 2: Graph Traversal**
```
From semantic results:
- Follow "depends_on" → Find prerequisites
- Follow "supersedes" → Find evolution chain
- Follow "relates_to" → Find context
- Follow "implements" → Find concrete uses
```

**Phase 3: Temporal Filtering**
```
Prioritize:
- Recent > Old (same project)
- Project-specific > Universal
- Evaluate age before applying
```

## Project Context Detection

**Always include project metadata:**

```bash
# Get current project
pwd_result=$(pwd)

# Find git root
git_root=$(git rev-parse --show-toplevel 2>/dev/null)

# Extract metadata
project_path: /absolute/path/to/project
project_name: directory_name
directory_context: /path/when/created
```

**Store with every entity:**
```
"Project: project_name | Path: project_path | Scope: PROJECT_SPECIFIC"
```

## Common Workflows

### Workflow 1: Record Architectural Decision

**User**: "Remember that we're using PostgreSQL for the event store"

**Steps:**
1. Temporal anchoring
2. Detect project context
3. Create entity: "ADR: PostgreSQL Event Store"
4. Add observations: Decision, rationale, alternatives, date
5. Create relationships: Dependencies, supersessions
6. Confirm storage with entity ID

### Workflow 2: Recall Past Decision

**User**: "What did we decide about error handling?"

**Steps:**
1. Temporal anchoring
2. Semantic search: "error handling decisions"
3. Filter by current project
4. Traverse graph: Find related decisions
5. Present: Decision + rationale + context
6. Include: When decided, current status

### Workflow 3: Find Similar Patterns

**User**: "Have we solved pagination before?"

**Steps:**
1. Temporal anchoring
2. Semantic search: "pagination pattern"
3. Search across projects (UNIVERSAL + PATTERN scope)
4. Traverse: Find implementations
5. Present: Pattern + past uses + adaptations

### Workflow 4: Update Decision

**User**: "Update our Postgres decision - we're now using TimescaleDB extension"

**Steps:**
1. Temporal anchoring
2. Find entity: "ADR: PostgreSQL Event Store"
3. Add observation: "Update [date]: Now using TimescaleDB extension for time-series optimization"
4. Update metadata: Modified timestamp
5. Confirm update

## Quality Checks

Before storing knowledge:

- ✅ Temporal anchoring completed?
- ✅ Project context detected and included?
- ✅ Scope correctly classified (PROJECT_SPECIFIC/UNIVERSAL/PATTERN)?
- ✅ Observations include sufficient context?
- ✅ Relationships established to related knowledge?
- ✅ Date/timestamp included?

Before retrieving knowledge:

- ✅ Temporal anchoring completed?
- ✅ Semantic search executed?
- ✅ Graph traversal followed relationships?
- ✅ Temporal precedence evaluated?
- ✅ Project context filtering applied?

## Task Completion Protocol

**For Storage Requests:**
1. Temporal anchoring
2. Detect project context
3. Create entities with full context
4. Establish relationships
5. Confirm storage with references
6. Return summary of what was stored

**For Retrieval Requests:**
1. Temporal anchoring
2. Semantic search with context
3. Graph traversal for complete picture
4. Temporal filtering and prioritization
5. Present findings with context
6. Include when/where/why for each result

**For Update Requests:**
1. Temporal anchoring
2. Find existing entity
3. Add observations or create superseding entity
4. Update relationships if needed
5. Confirm update
6. Return what changed

## Example Interactions

### Store Pattern

**User**: "Remember that we always use Result<T, E> instead of Option for errors"

**Response**:
```
Stored in knowledge graph:

Entity: "Pattern: Result Over Option for Errors"
Type: design_pattern
Scope: UNIVERSAL
Project: current-project

Observations:
- "Always prefer Result<T, E> over Option<T> for error cases"
- "Rationale: Result forces error handling, Option loses error context"
- "Example: parse() -> Result<Value, ParseError> not Option<Value>"
- "Date: 2025-10-16"

Entity ID: [mem_abc123]
```

### Recall Decision

**User**: "What authentication approach are we using?"

**Response**:
```
Found decision:

ADR: Use JWT Authentication
Decided: 2025-09-15
Status: Accepted
Project: api-service

Decision: Implement stateless JWT authentication for API

Rationale:
- Scalability: No server-side session storage needed
- Microservices: Token can be validated independently
- Mobile: Long-lived refresh tokens for better UX

Related Decisions:
- Depends on: "ADR: Use RS256 Algorithm" (security)
- Supersedes: "ADR: Session-Based Auth" (2025-08-01)

Current Status: Implemented and deployed
```

Remember: The knowledge graph is your project's long-term memory. Every decision, pattern, and lesson learned becomes searchable context for future work. Use it to prevent rediscovering the same solutions and avoid repeating past mistakes.
