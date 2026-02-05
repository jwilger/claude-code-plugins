---
description: INVOKE before ANY task to check for existing solutions in auto memory
argument-hint: <what-to-recall>
model: haiku
allowed-tools:
  - Grep
  - Read
  - Glob
---

# Retrieve Memory from Auto Memory

Search and retrieve relevant knowledge from the file-based auto memory system.

## Arguments

`$ARGUMENTS` describes what to recall. Examples:
- "test patterns for this project"
- "database configuration decisions"
- "previous errors with cargo build"
- "user preferences for error handling"

## Process

### 1. Determine Search Terms

Extract key terms from the query:
- Tool names (cargo, npm, gh)
- Error keywords (timeout, SSL, authentication)
- Domain concepts (event sourcing, TDD, hooks)
- Project-specific terms

### 2. Search Memory Files

Use Grep to search all markdown files in the memory directory:

```bash
# Get project-specific memory path
MEMORY_PATH="$HOME/.claude/projects/$(pwd | sed 's/\//-/g' | sed 's/^-//')/memory"

# Search with context for better matches
grep -r -i -C 3 "<search terms>" "$MEMORY_PATH" --include="*.md"
```

**Search strategies:**
- Start with broad terms, then narrow down
- Try variations: singular/plural, synonyms
- Search error messages or command names directly
- Check specific categories: debugging/, architecture/, tools/, etc.

### 3. Read Relevant Files

From grep results, read the most relevant files in full:

```
Read: <memory-path>/<category>/<file>.md
```

**Priority:**
1. Files matching multiple search terms
2. Files in relevant categories (debugging/ for errors, architecture/ for design decisions)
3. Recently created files (higher in MEMORY.md)

### 4. Synthesize and Return

Compile the relevant information and present it:

```
Found in auto memory:

## <File Title>
**Location:** `<category>/<filename>.md`
**Date:** <YYYY-MM-DD>

<Key relevant sections from the file>

---

## <File Title 2>
...

Summary: <1-2 sentence synthesis of what was found>
```

If nothing relevant found:
```
No relevant memories found for: "<query>"

Searched in:
- debugging/ - No matches
- architecture/ - No matches
- conventions/ - No matches
- tools/ - No matches
- patterns/ - No matches

Suggestions:
- Try different search terms (synonyms, variations)
- The information may not have been stored yet
- Consider storing this knowledge after you discover it using /sdlc:remember
```

## Example

Arguments: "cargo test timeout issues"

```bash
# 1. Extract search terms: cargo, test, timeout

# 2. Search memory directory
grep -r -i -C 3 "cargo.*test.*timeout" ~/.claude/projects/.../memory/ --include="*.md"

# 3. Read matching files
Read: ~/.claude/projects/.../memory/debugging/cargo-test-timeout.md

# 4. Present findings in format above
```

## When to Use This Command

**ALWAYS use at the start of:**
- New conversations/sessions
- Working on a new task
- Before making architectural decisions
- When encountering errors or problems
- When unsure about project conventions

**The memory protocol is non-negotiable.** Failing to check auto memory means potentially rediscovering knowledge that was already found.

## Search Query Tips

| Looking for... | Try searching... |
|----------------|------------------|
| Project setup | `"setup configuration"` |
| Error solutions | `"<error message> fix"` or `"<tool> error"` |
| User preferences | `"preference convention"` |
| Architecture | `"architecture decision"` |
| Domain concepts | `"domain <concept>"` |
| Tool quirks | `"<tool name> workaround"` |

## Memory Directory Structure

```
memory/
├── MEMORY.md              # Quick references (check first)
├── debugging/             # Solutions to past problems
├── architecture/          # Architecture decisions
├── conventions/           # Project conventions
├── tools/                 # Tool quirks and discoveries
└── patterns/              # General patterns
```

## Limitations

- **No semantic search:** Only keyword matching available
- **No relationship traversal:** Files are independent; use markdown links manually
- **Manual organization:** Files must be organized by category manually

Use precise keywords and check multiple variations if initial search fails.
