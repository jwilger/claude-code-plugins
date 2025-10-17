---
name: codebase-explorer
description: Fast codebase exploration using glob patterns, code search, and file reading. Answers questions about codebase structure, finds files by patterns, searches for keywords, and explores project organization. Use when exploring unfamiliar code, finding files, understanding project structure, or searching for specific code patterns. Specify thoroughness level - quick, medium, or very thorough.
allowed-tools: [Glob, Grep, Read, Bash]
---

# Codebase Explorer

Fast, focused codebase exploration for understanding project structure, finding files, and searching code.

## When to Use This Skill

- **Finding files by name or pattern**: "Find all TypeScript components", "Where are the test files?"
- **Searching for code**: "Find where API endpoints are defined", "Search for error handling patterns"
- **Understanding structure**: "What's the codebase structure?", "How are tests organized?"
- **Locating specific code**: "Where is UserRepository implemented?", "Find the main entry point"

## Thoroughness Levels

Specify the depth of exploration when invoking:

### Quick (Default)
- Single glob pattern or grep search
- Most common naming conventions
- Fast, targeted results
- Good for: Known patterns, standard structures

### Medium
- Multiple search strategies
- Common + alternative naming conventions
- Checks 2-3 common locations
- Good for: Moderate exploration, unfamiliar patterns

### Very Thorough
- Comprehensive search across codebase
- All naming conventions and locations
- Multiple search passes
- Good for: Complete analysis, complex structures

## Exploration Strategies

### Finding Files by Pattern

**Common Patterns:**
```bash
# Source files
**/*.rs          # Rust
**/*.py          # Python
**/*.ts          # TypeScript
**/*.tsx         # React TypeScript

# Test files
**/*_test.rs     # Rust tests
**/test_*.py     # Python tests
**/*.test.ts     # TypeScript tests
**/__tests__/**  # Jest tests

# Configuration
**/Cargo.toml    # Rust
**/package.json  # Node.js
**/pyproject.toml # Python

# Documentation
**/*.md          # Markdown
**/docs/**       # Documentation directories
```

**Example Usage:**
```bash
# Find all Rust source files
glob '**/*.rs'

# Find all test files
glob '**/*test*.{rs,py,ts}'

# Find configuration files
glob '**/Cargo.toml' '**/package.json' '**/pyproject.toml'
```

### Searching Code

**Search Strategies:**

1. **Exact Match**: Find specific identifiers
   ```bash
   grep -i "UserRepository" --output-mode files_with_matches
   ```

2. **Pattern Match**: Find patterns with regex
   ```bash
   grep "class \w+Repository" --output-mode files_with_matches
   ```

3. **Context Search**: Get surrounding lines
   ```bash
   grep "async fn" -A 3 -B 1 --output-mode content
   ```

4. **Type-Filtered Search**: Search specific file types
   ```bash
   grep "useState" --type ts
   grep "impl.*Error" --type rust
   ```

### Understanding Structure

**Progressive Discovery:**

1. **Top-Level Overview**:
   ```bash
   glob '*' --path .
   # Shows: src/, tests/, docs/, Cargo.toml, etc.
   ```

2. **Source Organization**:
   ```bash
   glob '**/*.rs' | head -20
   # Shows: Key source files and structure
   ```

3. **Module Boundaries**:
   ```bash
   grep "^pub mod" --output-mode content
   # Shows: Public module declarations
   ```

4. **Entry Points**:
   ```bash
   grep "fn main" --output-mode content
   # Shows: Main entry points
   ```

## Common Exploration Workflows

### Workflow 1: New Codebase Orientation

**Goal**: Understand what this project does and how it's organized

**Steps**:
1. Find main entry point: `grep "fn main\|if __name__\|export.*App" -n`
2. Identify structure: `glob '*' --path . && glob 'src/**/*' --path .`
3. Find key modules: `grep "^pub mod\|^export\|^from.*import" --output-mode files`
4. Review README: `glob '**/README.md'` then read it

### Workflow 2: Find Feature Implementation

**Goal**: Locate where a specific feature is implemented

**Steps**:
1. Search for feature keywords: `grep -i "feature_name" --output-mode files`
2. Check test files: `grep -i "test.*feature_name" --type rust`
3. Find related types: `grep "struct.*FeatureName\|class.*FeatureName"`
4. Review implementations: Read the most relevant files

### Workflow 3: Understand Error Handling

**Goal**: See how errors are handled in the codebase

**Steps**:
1. Find error types: `grep "enum.*Error\|class.*Error" --output-mode content`
2. Find error handling: `grep "Result<\|try catch\|except" --output-mode files`
3. Review patterns: Read representative error handling code
4. Check tests: `grep "test.*error\|should.*fail" --type rust`

### Workflow 4: Locate API Endpoints

**Goal**: Find where HTTP/API endpoints are defined

**Steps**:
1. Search for route definitions: `grep "route\|@app\|@get\|@post" --output-mode files`
2. Find handler functions: `grep "async fn.*handler\|def.*endpoint"`
3. Check OpenAPI/Swagger: `glob '**/*swagger*' '**/*openapi*'`
4. Review endpoint implementations

## Best Practices

### Start Broad, Then Narrow

1. **First Pass**: Wide search to find candidates
   ```bash
   grep -i "keyword" --output-mode files_with_matches
   ```

2. **Second Pass**: Narrow to specific file types
   ```bash
   grep -i "keyword" --type rust --output-mode content
   ```

3. **Third Pass**: Review specific files
   ```bash
   # Read the most relevant file
   ```

### Use Type Filters

Instead of searching everywhere, filter by language:
- `--type rust`: Rust files
- `--type python`: Python files
- `--type ts`: TypeScript files
- `--type js`: JavaScript files

### Combine Glob and Grep

1. **Find files by pattern**: `glob 'src/**/*repository*.rs'`
2. **Search within matches**: `grep "impl.*Repository" --glob 'src/**/*repository*.rs'`

### Respect head_limit

For large codebases, use `head_limit` to avoid overwhelming results:

```bash
# Get first 20 matches
grep "pattern" --output-mode files_with_matches --head-limit 20
```

## Task Completion Protocol

When invoked for codebase exploration:

1. **Understand the goal**: What is the user trying to find or understand?
2. **Choose thoroughness**: Quick, medium, or very thorough based on context
3. **Execute search strategy**: Use appropriate glob/grep combination
4. **Review results**: Identify most relevant findings
5. **Read key files**: If needed to answer the question
6. **Summarize findings**: Clear, concise answer with file paths and line numbers
7. **Suggest next steps**: If exploration should continue

## Example Invocations

**"Where are API endpoints defined?"**
- Thoroughness: Medium
- Strategy: Search for route/endpoint patterns
- Tools: grep for route definitions + handler functions

**"What's the test structure?"**
- Thoroughness: Quick
- Strategy: Glob for test file patterns
- Tools: glob for *test*, *spec*, __tests__

**"Find all uses of DatabaseConnection"**
- Thoroughness: Medium
- Strategy: Grep for type name in imports and usage
- Tools: grep with type filters

**"How is the codebase organized?"**
- Thoroughness: Very Thorough
- Strategy: Progressive directory listing + module analysis
- Tools: glob for structure + grep for module declarations

Remember: Code exploration is detective work. Start with broad searches, follow the clues, and narrow focus until you find what you need.
