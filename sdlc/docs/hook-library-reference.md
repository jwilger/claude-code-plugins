# Hook Library Reference

Reference for shared hook utility functions in `sdlc/.claude-plugin/hooks/lib/common.sh`.

## Usage

Source the library from your hook script:

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/lib/common.sh"

# Now you can use library functions
STAGED=$(get_staged_files)
```

## File Operations

### `get_staged_files()`

Returns list of staged files (one per line).

```bash
STAGED_FILES=$(get_staged_files)
```

### `file_matches(file, pattern)`

Check if file path matches regex pattern.

```bash
if file_matches "$FILE" "^src/.*\.rs$"; then
    echo "Rust source file in src/"
fi
```

### `is_test_file(file)`

Check if file is a test file.

```bash
if is_test_file "$FILE"; then
    echo "This is a test file"
fi
```

**Patterns matched:**
- `*_test.*`, `*_spec.*`
- `*.test.*`, `*.spec.*`
- `test_*`
- `tests/` directory

### `is_production_file(file)`

Check if file is production code (not test).

```bash
if is_production_file "$FILE"; then
    echo "This is production code"
fi
```

**Patterns matched:**
- Files in `src/`, `lib/`, or `app/` directories
- NOT matching test file patterns

### `is_config_file(file)`

Check if file is configuration or documentation.

```bash
if is_config_file "$FILE"; then
    echo "This is config/docs"
fi
```

**Patterns matched:**
- `.md`, `.yml`, `.yaml`, `.json`, `.toml`, `.xml`
- `config/` or `docs/` directories

## User Interaction

### `show_violation(title, message, remedy)`

Display structured violation message.

```bash
show_violation \
    "ARCHITECTURE.md must be committed alone" \
    "Architecture decisions are significant and deserve dedicated commits." \
    "Split your changes:\n  1. Commit ARCHITECTURE.md alone\n  2. Commit implementation separately"
```

**Output format:**
```
❌ ARCHITECTURE.md must be committed alone

📚 Why?
Architecture decisions are significant and deserve dedicated commits.

🔧 How to fix:
  1. Commit ARCHITECTURE.md alone
  2. Commit implementation separately

📖 More info: docs/enforcement-philosophy.md
```

## Hook Return Formats

### `hook_success()`

Return success with no additional context.

```bash
hook_success
# Output: {"ok": true}
```

### `hook_failure(reason)`

Return failure with reason.

```bash
hook_failure "Test files can only be edited by RED agent"
# Output: {"ok": false, "reason": "Test files can only be edited by RED agent"}
```

### `hook_success_with_context(context)`

Return success with additional context.

```bash
hook_success_with_context "⚠️ Remember to run tests"
# Output: {"ok": true, "additionalContext": "⚠️ Remember to run tests"}
```

### `command_hook_output(event_name, [json_params])`

Return command hook output format.

```bash
command_hook_output "SessionStart" '"additionalContext": "Project initialized"'
# Output: {"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "Project initialized"}}
```

## JSON Parsing

### `parse_hook_input(field)`

Extract field from hook input JSON (reads from stdin).

```bash
INPUT=$(cat)
TRANSCRIPT=$(echo "$INPUT" | parse_hook_input "transcript_path")
```

## Git Operations

### `is_git_repo()`

Check if current directory is a git repository.

```bash
if is_git_repo; then
    echo "Git repository detected"
fi
```

### `get_current_branch()`

Get current git branch name.

```bash
BRANCH=$(get_current_branch)
```

### `get_project_root()`

Get project root directory (git repository root).

```bash
ROOT=$(get_project_root)
```

## Transcript Operations

### `get_transcript_path()`

Extract transcript path from hook input (reads from stdin).

```bash
TRANSCRIPT_PATH=$(cat | get_transcript_path)
```

## Examples

### Example 1: File Type Check

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/lib/common.sh"

get_staged_files | while read -r file; do
    if is_test_file "$file"; then
        hook_failure "Cannot commit test files in this branch"
        exit 1
    fi
done

hook_success
```

### Example 2: Architecture Isolation Check

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/lib/common.sh"

STAGED=$(get_staged_files)
ARCH_FILE=$(echo "$STAGED" | grep "ARCHITECTURE.md")

if [[ -n "$ARCH_FILE" ]]; then
    OTHER_FILES=$(echo "$STAGED" | grep -v "ARCHITECTURE.md")

    if [[ -n "$OTHER_FILES" ]]; then
        show_violation \
            "ARCHITECTURE.md must be committed alone" \
            "Architecture decisions deserve dedicated commits." \
            "Split your changes"
        exit 1
    fi
fi

hook_success
```

### Example 3: Context Injection

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/lib/common.sh"

BRANCH=$(get_current_branch)
CONTEXT="Current branch: $BRANCH"

hook_success_with_context "$CONTEXT"
```

## Testing

Test library functions with provided test suite:

```bash
cd sdlc/.claude-plugin/hooks/lib
./test-common.sh
```

## Adding New Functions

When adding new functions to common.sh:

1. Follow existing naming conventions
2. Document function purpose in comments
3. Add function to this reference document
4. Add test cases to test-common.sh
5. Keep functions pure (no side effects when possible)

## Related Documentation

- [Hook Authoring Guide](../../../docs/hook-authoring-guide.md)
- [Enforcement Philosophy](../../../docs/enforcement-philosophy.md)
- [Hook Examples](../)
