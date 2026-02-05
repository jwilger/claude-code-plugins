#!/usr/bin/env bash
#
# session-start.sh - SessionStart hook for memory protocol reminder
#
# Outputs additionalContext reminding to check auto memory for relevant context.

set -euo pipefail

cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "🧠 MEMORY PROTOCOL REMINDER: Before diving into work, check auto memory for relevant context. Auto memory may have useful information about: 🐛 Debugging (similar issues solved before?), 🏗️ Architecture (patterns or decisions documented?), 🔧 Tools (known quirks, workarounds, or configurations?), 📋 Conventions (project-specific patterns or preferences?). To search: Use /sdlc:recall \"<search terms>\" to grep through memory files. Location: ~/.claude/projects/<project-path>/memory/"
  }
}
EOF
exit 0
