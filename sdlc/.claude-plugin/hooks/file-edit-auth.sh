#!/usr/bin/env bash
#
# file-edit-auth.sh - PreToolUse hook for Edit/Write authorization
#
# Simple subagent detection: if transcript_path contains "/subagents/",
# we're in a subagent context and file operations are allowed.
# Otherwise, we're the main orchestrator and must delegate.

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Extract transcript_path from input
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')

if [[ -z "$TRANSCRIPT_PATH" ]]; then
    # Can't determine context without transcript - deny to be safe
    cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Cannot determine context - transcript_path not available. Delegate file operations to appropriate subagent."
  }
}
EOF
    exit 0
fi

# Simple check: if transcript_path contains "/subagents/", we're in a subagent
if [[ "$TRANSCRIPT_PATH" == *"/subagents/"* ]]; then
    # We're a subagent - allow Edit/Write
    # (Agent instructions handle file type restrictions)
    cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Subagent context - file operations allowed"
  }
}
EOF
else
    # Main orchestrator - deny and require delegation
    cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "File modifications must be delegated to subagents. Use Task tool to launch: sdlc:red (tests), sdlc:green (production code), sdlc:domain (type definitions), sdlc:adr (ADRs), sdlc:file-updater (config/docs/scripts), or other appropriate agents."
  }
}
EOF
fi

exit 0
