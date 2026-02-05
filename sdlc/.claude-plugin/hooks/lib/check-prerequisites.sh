#!/usr/bin/env bash
# Shared utilities for checking CLI tool prerequisites in hooks

# Check if a CLI tool is available
# Usage: check_cli_tool "toolname" "installation hint"
# Returns: 0 if tool exists, 1 if missing
check_cli_tool() {
  local tool=$1
  local install_hint=$2

  if ! command -v "$tool" &> /dev/null; then
    echo "❌ Missing required CLI tool: $tool" >&2
    echo "   Install: $install_hint" >&2
    echo "" >&2
    return 1
  fi
  return 0
}

# Show a formatted error message with installation instructions
# Usage: show_missing_tool_error "toolname" "installation hint" "impact description"
show_missing_tool_error() {
  local tool=$1
  local install_hint=$2
  local impact=$3

  cat >&2 <<EOF
╔════════════════════════════════════════════════════════════════╗
║ Missing Required Tool: $tool
╚════════════════════════════════════════════════════════════════╝

❌ Impact:
   $impact

🔧 Installation:
   $install_hint

📚 More info: https://github.com/jwilger/claude-code-plugins#prerequisites
EOF
}

# Check multiple tools at once
# Usage: check_multiple_tools "tool1:hint1" "tool2:hint2" ...
# Returns: 0 if all exist, 1 if any missing
check_multiple_tools() {
  local all_present=0

  for tool_spec in "$@"; do
    local tool="${tool_spec%%:*}"
    local hint="${tool_spec#*:}"

    if ! check_cli_tool "$tool" "$hint"; then
      all_present=1
    fi
  done

  return $all_present
}

# Export functions for use in other scripts
export -f check_cli_tool
export -f show_missing_tool_error
export -f check_multiple_tools
