# Project-Aware Memory Classification Protocol

## Overview

This protocol prevents project bleed-over in the Memento MCP memory system by implementing intelligent memory classification and project-aware retrieval.

## Memory Classification System

### 1. PROJECT_SPECIFIC Memories

**Definition**: Knowledge that only applies to a specific project and could cause harm if applied elsewhere.

**Auto-Classification Triggers**:
- Contains specific project names (e.g., "caxton", "old-tm-hs", "ticketbus")
- References specific file paths (`/home/jwilger/projects/caxton/src/main.rs`)
- Contains database schemas, table names, or connection strings
- Mentions API keys, deployment configurations, or environment settings
- References specific repository URLs or branch names
- Contains project-specific business logic or domain terms

**Examples**:
```
✅ PROJECT_SPECIFIC:
"ETL pipeline for old-tm-hs processes TMRawCust table with HubSpot integration"
"Caxton project uses Rust with axum framework for web server"
"Ticketbus database schema includes events, venues, and ticket_sales tables"
"Deploy old-tm-hs to AWS Lambda with terraform in us-west-2"

❌ NOT PROJECT_SPECIFIC:
"Rust web servers should use structured logging"
"Database migrations should be idempotent"
```

### 2. UNIVERSAL Memories

**Definition**: General programming knowledge applicable across all projects.

**Auto-Classification Triggers**:
- Programming language concepts and best practices
- Tool usage patterns (git, docker, testing frameworks)
- Design patterns and architectural principles
- General debugging and troubleshooting techniques
- Language-agnostic principles (SOLID, DRY, KISS)

**Examples**:
```
✅ UNIVERSAL:
"Rust trait bounds enable compile-time polymorphism"
"Git rebase -i allows interactive commit history editing"
"TDD Red-Green-Refactor cycle improves code quality"
"Docker multi-stage builds reduce image size"
"Parse don't validate philosophy prevents runtime errors"

❌ NOT UNIVERSAL:
"Use caxton's custom error handling middleware for API responses"
"Old-tm-hs ETL runs daily at 6 PM UTC via cron"
```

### 3. PATTERN Memories

**Definition**: Reusable approaches that can be adapted to different projects with modification.

**Auto-Classification Triggers**:
- Contains words: "pattern", "approach", "strategy", "technique", "methodology"
- Describes a solution framework rather than specific implementation
- Shows adaptation potential across project contexts
- Demonstrates transferable architectural decisions

**Examples**:
```
✅ PATTERN:
"Thread-safe state management pattern using Arc<Mutex<T>> prevents race conditions"
"Event sourcing pattern separates commands from queries for better scalability"
"Repository pattern abstracts data access layer from business logic"
"CQRS approach enables independent read/write optimization"

🔄 ADAPTABLE ACROSS PROJECTS:
"ETL error recovery pattern: retry with exponential backoff, dead letter queue for permanent failures"
"Web API rate limiting strategy: token bucket per user with Redis backend"
```

## Project Context Detection

### Automatic Project Detection Algorithm

```bash
# 1. Find project root
current_dir = pwd
while current_dir != "/":
    if exists(current_dir + "/.git"):
        project_path = current_dir
        break
    current_dir = parent(current_dir)

# 2. Extract project metadata
project_name = basename(project_path)
directory_context = pwd

# 3. Determine if in known project
known_projects = ["/home/jwilger/projects/caxton", "/home/jwilger/projects/old-tm-hs",
                  "/home/jwilger/projects/ticketbus", "/home/jwilger/projects/tim-dotfiles"]
is_project_context = project_path in known_projects
```

### Manual Project Override

When working outside standard project directories:
```
"Project: manual-override | Path: /tmp/experiment | Scope: UNIVERSAL"
```

## Memory Storage Format

### Enhanced Memory Entity Structure

```json
{
  "name": "Thread Safety Fix Implementation",
  "entityType": "implementation_solution",
  "observations": [
    "Project: old-tm-hs | Path: /home/jwilger/projects/old-tm-hs | Scope: PROJECT_SPECIFIC",
    "Fixed ETL data contamination using ThreadSafeAttendanceAggregates class",
    "Replaced builtins._attendance_scan_aggregates with threading.local() storage",
    "Each thread gets isolated attendance scan aggregate storage",
    "Files modified: tm_to_hubspot_dto.py, sync_rds_to_hubspot.py, to_hubspot.py",
    "Root cause: Global state shared across ThreadPoolExecutor parallel processing"
  ],
  "metadata": {
    "project_path": "/home/jwilger/projects/old-tm-hs",
    "project_name": "old-tm-hs",
    "memory_scope": "PROJECT_SPECIFIC",
    "directory_context": "/home/jwilger/projects/old-tm-hs/src/pipeline",
    "created_date": "2025-09-17"
  }
}
```

### Universal Knowledge Example

```json
{
  "name": "Rust Thread Safety Patterns",
  "entityType": "programming_knowledge",
  "observations": [
    "Project: universal | Path: N/A | Scope: UNIVERSAL",
    "Arc<Mutex<T>> provides shared ownership with interior mutability",
    "threading::local() creates thread-local storage for global-like access",
    "Channels (mpsc::channel) enable message passing between threads",
    "Rayon provides data parallelism with work-stealing scheduler"
  ],
  "metadata": {
    "memory_scope": "UNIVERSAL",
    "language": "rust",
    "topic": "concurrency"
  }
}
```

## Memory Retrieval Protocol

### Three-Tier Search Priority System

```python
def enhanced_semantic_search(query, current_project_path):
    results = mcp_memento_semantic_search(query)

    scored_results = []
    for result in results:
        base_score = result.similarity_score

        # Apply project-aware weighting
        if result.metadata.get("project_path") == current_project_path:
            final_score = base_score * 1.0  # Current project exact match
        elif result.metadata.get("memory_scope") == "UNIVERSAL":
            final_score = base_score * 0.8  # Universal knowledge
        elif result.metadata.get("memory_scope") == "PATTERN":
            final_score = base_score * 0.6  # Cross-project patterns
        else:
            final_score = base_score * 0.3  # Other project specifics

        scored_results.append((result, final_score))

    return sorted(scored_results, key=lambda x: x[1], reverse=True)
```

### Cross-Project Learning Protocol

When applying patterns from other projects:

1. **Explicit Attribution**: Always mention source project
2. **Adaptation Notes**: Document what needs to change
3. **Context Validation**: Verify pattern fits current project

Example:
```
"Adapting thread safety pattern from old-tm-hs ETL pipeline to caxton web server:
- old-tm-hs: ThreadSafeAttendanceAggregates for ETL processing
- caxton adaptation: ThreadSafeSessionStore for web session management
- Key difference: HTTP request lifecycle vs batch processing lifecycle"
```

## Directory Safety Protocol

### Pre-Command Verification

Before ANY file-modifying operation:

```python
def verify_directory_context(memory, current_dir):
    memory_project = memory.metadata.get("project_path")
    current_project = detect_current_project()

    if memory_project and memory_project != current_project:
        print(f"⚠️  WARNING: Memory from {memory_project} but you're in {current_project}")
        print(f"🔍 Memory: {memory.name}")
        print(f"📁 Current: {current_dir}")

        response = input("Continue anyway? [y/N]: ")
        if response.lower() != 'y':
            raise DirectoryMismatchError("Operation cancelled due to directory mismatch")

    # Store verification result
    create_verification_memory(memory, current_dir, "directory_verified")
```

### Command Execution Memory Format

```json
{
  "name": "Cargo Build Command Execution",
  "entityType": "command_execution",
  "observations": [
    "Project: caxton | Path: /home/jwilger/projects/caxton | Scope: PROJECT_SPECIFIC",
    "Command: cargo build --release",
    "Directory: /home/jwilger/projects/caxton",
    "Result: SUCCESS - Binary created at target/release/caxton",
    "Directory verification: PASSED - Command run in correct project context"
  ]
}
```

## Implementation Guidelines

### For AI Agents

1. **Always Start with Project Detection**:
   ```python
   project_context = detect_current_project()
   if project_context:
       search_query = f"project:{project_context.name} {user_query}"
   ```

2. **Include Project Metadata in All Memory Creation**:
   ```python
   observation = f"Project: {project_name} | Path: {project_path} | Scope: {scope}"
   ```

3. **Validate Directory Context for Commands**:
   ```python
   if is_file_modifying_command(command):
       verify_directory_context(relevant_memory, os.getcwd())
   ```

### Memory Migration Strategy

For existing memories without project context:

1. **Heuristic Classification**: Analyze content for project-specific markers
2. **Gradual Tagging**: Add project context when memories are accessed
3. **Legacy Handling**: Treat untagged memories as UNIVERSAL with lower priority

## Examples of Prevented Project Bleed-Over

### Before Enhancement
```
User working in caxton project
Search: "database schema"
Returns: "old-tm-hs ETL tm_raw_cust table structure"
Result: User tries to create tm_raw_cust table in caxton ❌
```

### After Enhancement
```
User working in caxton project (/home/jwilger/projects/caxton)
Search: "database schema"
Returns (prioritized):
1. [score: 0.9] "Caxton user authentication schema with JWT tokens"
2. [score: 0.6] "PATTERN: Event sourcing schema design principles"
3. [score: 0.3] "old-tm-hs ETL tm_raw_cust table structure"
Result: User uses appropriate caxton schema ✅
```

This protocol ensures agents maintain project context awareness while preserving valuable cross-project learning opportunities.