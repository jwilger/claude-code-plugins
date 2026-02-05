#!/usr/bin/env bash
# common.sh - Shared hook utility functions
#
# Source this file from hooks: source "$(dirname "$0")/lib/common.sh"

# Get list of staged files
get_staged_files() {
    git diff --cached --name-only 2>/dev/null || echo ""
}

# Check if file matches pattern (regex)
file_matches() {
    local file=$1
    local pattern=$2
    [[ "$file" =~ $pattern ]]
}

# Show structured violation message
show_violation() {
    local title=$1
    local message=$2
    local remedy=$3

    cat <<EOF
❌ $title

📚 Why?
$message

🔧 How to fix:
$(echo "$remedy" | sed 's/^/  /')

📖 More info: docs/enforcement-philosophy.md
EOF
}

# Check if file is a test file
is_test_file() {
    local file=$1
    [[ "$file" =~ _test\.|_spec\.|\.test\.|\.spec\.|^test_ ]] || \
    [[ "$file" =~ ^tests/ ]] || \
    [[ "$file" =~ /tests/ ]]
}

# Check if file is production code
is_production_file() {
    local file=$1
    [[ "$file" =~ ^(src|lib|app)/ ]] && ! is_test_file "$file"
}

# Check if file is config/docs
is_config_file() {
    local file=$1
    [[ "$file" =~ \.(md|yml|yaml|json|toml|xml)$ ]] || \
    [[ "$file" =~ ^(config|docs)/ ]]
}

# Parse hook input JSON
parse_hook_input() {
    local field=$1
    # Reads from stdin, extracts field with jq
    jq -r ".$field // empty" 2>/dev/null
}

# Return hook success
hook_success() {
    echo '{"ok": true}'
}

# Return hook failure
hook_failure() {
    local reason=$1
    jq -n --arg reason "$reason" '{"ok": false, "reason": $reason}'
}

# Return hook with additional context
hook_success_with_context() {
    local context=$1
    jq -n --arg context "$context" '{"ok": true, "additionalContext": $context}'
}

# Return command hook output
command_hook_output() {
    local event_name=$1
    shift
    local json_params="$@"

    echo '{"hookSpecificOutput": {'
    echo "  \"hookEventName\": \"$event_name\""

    # Add additional parameters if provided
    if [[ -n "$json_params" ]]; then
        echo "  ,$json_params"
    fi

    echo '}}'
}

# Get transcript path from hook input
get_transcript_path() {
    cat | parse_hook_input "transcript_path"
}

# Check if git repository exists
is_git_repo() {
    git rev-parse --git-dir &>/dev/null
}

# Get current branch name
get_current_branch() {
    git branch --show-current 2>/dev/null || echo ""
}

# Get project root (git repository root)
get_project_root() {
    git rev-parse --show-toplevel 2>/dev/null || pwd
}
