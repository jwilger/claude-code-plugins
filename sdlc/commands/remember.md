---
description: INVOKE after solving problems or learning conventions. Stores in auto memory
argument-hint: <what-to-remember>
model: haiku
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
---

# Store Memory in Auto Memory

Store discoveries, insights, and knowledge in the file-based auto memory system for future retrieval.

## Arguments

`$ARGUMENTS` describes what to remember. Examples:
- "The project uses Rust with Axum framework"
- "Found workaround for cargo test timeout issue"
- "User prefers explicit error messages over generic ones"

## Process

### 1. Determine Category and Check for Duplicates

First, categorize the knowledge:

| Category | Use For | Directory |
|----------|---------|-----------|
| `debugging` | Solutions to problems, error fixes | `debugging/` |
| `architecture` | Architecture decisions, design patterns | `architecture/` |
| `conventions` | Project conventions, coding standards | `conventions/` |
| `tools` | Tool behaviors, CLI options, API quirks | `tools/` |
| `patterns` | General reusable patterns (not project-specific) | `patterns/` |

Then search for existing related files to avoid duplicates:

```bash
# Get memory path
MEMORY_PATH="$HOME/.claude/projects/$(pwd | sed 's/\//-/g' | sed 's/^-//')/memory"

# Search for similar content
grep -r -i "<key terms>" "$MEMORY_PATH/<category>/" --include="*.md"
```

If closely related file exists, consider updating it instead of creating a new one.

### 2. Create Descriptive Filename

**Naming convention:** `<descriptive-kebab-case-name>.md`

Examples:
- `cargo-test-timeout.md`
- `error-message-preferences.md`
- `event-sourcing-rationale.md`
- `postgres-jsonb-queries.md`

Keep filenames:
- Short (3-5 words)
- Descriptive
- Searchable (use keywords that will be grepped)

### 3. Format as Markdown File

Use this template structure:

```markdown
# <Title>

**Date:** <YYYY-MM-DD>
**Category:** <debugging|architecture|convention|tool|pattern>
**Project:** <project-name or "General">

## Problem / Context

<What was the situation? What prompted this discovery?>

## Solution / Discovery

<What did you learn? What's the key insight?>

## Details

<Specific steps, commands, code snippets, configuration>

## Related

- [Link to related memory](../category/related-file.md)
- See also: <Other references>
```

### 4. Write the File

```bash
# Write to appropriate category directory
Write: $MEMORY_PATH/<category>/<filename>.md
```

**Example for debugging insight:**
```markdown
# Cargo Test Timeout Fix

**Date:** 2026-02-04
**Category:** debugging
**Project:** TaskFlow (/home/user/projects/taskflow)

## Problem / Context

Integration tests with `cargo test` were hanging indefinitely when run in parallel. Tests would freeze during database connection setup.

## Solution / Discovery

The issue was connection pool exhaustion. Setting `RUST_TEST_THREADS=1` forces sequential test execution, preventing multiple tests from competing for database connections.

## Details

```bash
# Add to .cargo/config.toml or set environment variable
export RUST_TEST_THREADS=1
cargo test
```

Alternatively, configure test connection pool size:
```rust
Pool::builder().max_connections(1).build()
```

## Related

- See also: Rust testing patterns in conventions/rust-testing.md
```

### 5. Update MEMORY.md

Add a reference to the new file in `MEMORY.md` under "Recent Learnings":

```markdown
## Recent Learnings (Last 5)

1. [2026-02-04] [Cargo test timeout fixed with RUST_TEST_THREADS=1](debugging/cargo-test-timeout.md)
2. [previous entry]
...
```

Keep only the last 5 entries. Move older entries to a `recent-learnings.md` file if needed.

### 6. Return Confirmation

After storing, output:
```
Stored in auto memory:
  File: <category>/<filename>.md
  Category: <category>
  Title: <title>
  Location: ~/.claude/projects/.../memory/<category>/<filename>.md
```

## When NOT to Use This Command

Don't store:
- Transient conversation details
- Information already in project files (code IS documentation)
- Duplicate information already in auto memory
- Sensitive data (credentials, personal information)

## Examples

### Debugging Insight

Arguments: "cargo test hangs on integration tests, fixed by setting RUST_TEST_THREADS=1"

Process:
1. Category: debugging
2. Filename: `cargo-test-timeout.md`
3. Search for duplicates: `grep -r "cargo.*test.*timeout" memory/debugging/`
4. Write file using template above
5. Update MEMORY.md

### User Preference

Arguments: "user prefers verbose error messages with file paths"

Process:
1. Category: conventions
2. Filename: `error-message-style.md`
3. Search: `grep -r "error.*message" memory/conventions/`
4. Write file documenting the preference
5. Update MEMORY.md

### Architecture Decision

Arguments: "chose PostgreSQL over SQLite for multi-tenant support"

Process:
1. Category: architecture
2. Filename: `database-choice.md`
3. Write ADR-style documentation explaining rationale
4. Update MEMORY.md

## Tips for Good Memory Files

- **Be specific:** Include exact commands, error messages, versions
- **Include context:** Why was this needed? What was the situation?
- **Make it searchable:** Use keywords that future you will search for
- **Link related knowledge:** Use markdown links to connect files
- **Keep it concise:** Focus on the key insight, not exhaustive details
- **Date everything:** Helps assess if information is still relevant

## Updating Existing Files

If a related file exists and you want to add to it:

1. Read the existing file
2. Use Edit tool to add new section or update existing content
3. Update the date in the file header
4. Keep the history of changes within the file if needed
