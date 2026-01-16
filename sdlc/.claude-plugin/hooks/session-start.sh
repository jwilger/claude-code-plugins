#!/usr/bin/env bash
#
# session-start.sh - SessionStart hook for memory protocol reminder
#
# Outputs additionalContext reminding to check memento for relevant context.

set -euo pipefail

cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "🧠 MEMORY PROTOCOL REMINDER: Before diving into work, consider checking memento for relevant context. Memento may have useful information about: 🐛 Debugging (similar issues solved before?), 🏗️ Architecture (patterns or decisions documented?), 🔧 Tools (known quirks, workarounds, or configurations?), 📋 Conventions (project-specific patterns or preferences?). To search: Use mcp__memento__semantic_search with your task description as the query. This is a gentle reminder - proceed without searching if the work is novel or memento isn't available."
  }
}
EOF
exit 0
