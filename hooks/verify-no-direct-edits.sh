#!/usr/bin/env zsh
# PreToolUse hook to BLOCK main agent from using Write/Edit/NotebookEdit tools.
# This prevents the violation BEFORE it happens.

# Read input from stdin
input=$(cat)

# Extract tool_name using basic text processing
tool_name=$(echo "$input" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)

# Forbidden tools for main agent
forbidden_tools=("Write" "Edit" "NotebookEdit")

# Check if this tool is forbidden
for forbidden in "${forbidden_tools[@]}"; do
  if [[ "$tool_name" == "$forbidden" ]]; then
    # Block the tool use
    echo '{"decision":"block","reason":"🚫 CRITICAL VIOLATION: Main agent is FORBIDDEN from using '"$tool_name"' directly. You MUST delegate to specialized agents: file-editor for explicit edits, red-tdd-tester/green-implementer for code changes, technical-documentation-writer for docs. This is a ZERO TOLERANCE policy."}'
    exit 0
  fi
done

# Allow all other tools
exit 0
