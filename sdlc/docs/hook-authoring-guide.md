# Hook Authoring Guide

Guide for creating and maintaining hooks in the SDLC plugin.

## Hook Return Formats

Different hook types require different return formats. **Always follow these patterns exactly.**

### Prompt-Based Hooks

Used for hooks that inject prompts or make simple allow/deny decisions.

**Format:**
```json
{"ok": true}
```

Or with reason:
```json
{
  "ok": false,
  "reason": "Explanation of why action is blocked"
}
```

**Events that use prompt-based hooks:**
- PreToolUse (when type: prompt)
- PostToolUse (when type: prompt)
- PostToolUseFailure
- Stop
- SubagentStop

**Example:**
```yaml
hooks:
  Stop:
    - hooks:
        - type: prompt
          prompt: |
            Before completing, verify all tests pass.

            Output ONLY: {"ok": true}
```

### Command-Based Hooks

Used for hooks that execute shell commands and return structured data.

**Format:**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "EventName",
    "additionalContext": "Optional context to inject",
    "permissionDecision": "allow",  # For PreToolUse only
    "permissionDecisionReason": "Reason"  # For PreToolUse only
  }
}
```

**Events that use command-based hooks:**
- SessionStart
- PreToolUse (when type: command)
- PostToolUse (when type: command)
- PreCompact

**Example:**
```bash
#!/usr/bin/env bash
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Project context here"
  }
}
EOF
```

### PreToolUse Command Hooks (Special Case)

PreToolUse command hooks require `permissionDecision`:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",  # or "deny" or "ask"
    "permissionDecisionReason": "Why this decision was made"
  }
}
```

## Hook Types by Event

| Event | Allowed Types | Return Format |
|-------|---------------|---------------|
| SessionStart | command | hookSpecificOutput |
| PreToolUse | prompt, command | prompt: {"ok": true}, command: hookSpecificOutput with permissionDecision |
| PostToolUse | prompt, command | prompt: {"ok": true}, command: hookSpecificOutput |
| PostToolUseFailure | prompt | {"ok": true} |
| Stop | prompt | {"ok": true} |
| SubagentStop | prompt | {"ok": true} |
| PreCompact | command | hookSpecificOutput |
| UserPromptSubmit | prompt | {"ok": true} |

## Common Mistakes

### ❌ Wrong: Missing "ok" in prompt hook
```yaml
prompt: |
  Do something.

  # Missing: {"ok": true}
```

### ✅ Right: Include {"ok": true}
```yaml
prompt: |
  Do something.

  Output ONLY: {"ok": true}
```

### ❌ Wrong: Command hook without hookSpecificOutput
```bash
echo '{"contextInjected": "some data"}'
```

### ✅ Right: Command hook with proper format
```bash
echo '{"hookSpecificOutput": {"hookEventName": "PreCompact", "additionalContext": "some data"}}'
```

### ❌ Wrong: PreToolUse command hook without permissionDecision
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse"
  }
}
```

### ✅ Right: PreToolUse with permissionDecision
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "File type is allowed"
  }
}
```

## Validation

Run the validation script to check all hooks:

```bash
cd sdlc/.claude-plugin/hooks
./validate-formats.sh
```

This script checks:
- Prompt hooks have `{"ok": true}` output
- Command hooks use `hookSpecificOutput`
- PreToolUse command hooks have `permissionDecision`

## Best Practices

1. **Always output JSON** - Never output plain text from hooks
2. **Use exact format** - Don't add extra fields unless documented
3. **Test hooks locally** - Run validation before committing
4. **Document hook purpose** - Add comments explaining what hook does
5. **Handle errors gracefully** - Use `set -euo pipefail` in bash hooks

## Testing Hooks

Test your hooks manually before committing:

```bash
# For command hooks
./your-hook.sh <<< '{"transcript_path": "/tmp/test.jsonl"}'

# Check output format
./your-hook.sh <<< '{}' | jq .
```

## Further Reading

- [Claude Code Hooks Documentation](https://code.claude.com/docs/hooks)
- [SDLC Enforcement Philosophy](./enforcement-philosophy.md)
- [Hook Examples](../.claude-plugin/hooks/)
