# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Claude Code plugin marketplace containing plugins:
- **sdlc** - Complete SDLC workflow with TDD, Event Modeling, ADRs, and GitHub integration (includes 9 portable agent skills and 2 output styles)
- **bootstrap** - Project scaffolding with Nix-based development environments

## Commands

```bash
# Validate a plugin
claude plugin validate sdlc
claude plugin validate bootstrap

# Update marketplace (fetches latest from source)
/plugin
```

## Documentation Verification

**CRITICAL**: When implementing or modifying features that interact with Claude Code's APIs (hooks, permissions, tool schemas, etc.), you MUST verify against the official documentation:

1. **Always consult docs first** before implementing new features
2. **Verify JSON schemas** against official examples (especially for hooks)
3. **Check return formats** for all hook types (Stop, SubagentStop, PreToolUse, etc.)
4. **Use the claude-code-guide agent** to fetch current documentation when uncertain

**Hook format by type:**
- **Prompt-based hooks** (PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, UserPromptSubmit, Stop, SubagentStop): Use `{"ok": true}` or `{"ok": false, "reason": "..."}`
- **Command-based hooks** (All event types): Use tool-specific `hookSpecificOutput` format

**PreToolUse command hooks** must return:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow" | "deny" | "ask",
    "permissionDecisionReason": "string"
  }
}
```

Official docs: https://code.claude.com/docs

## Plugin Architecture

### Marketplace Structure
- `.claude-plugin/marketplace.json` - Plugin registry (name: `jwilger-claude-plugins`)
- Each plugin lives in its own directory with `.claude-plugin/plugin.json`

### Plugin Components
- `commands/` - Slash commands (filename → command name, plugin name → namespace prefix)
- `agents/` - Specialized subagents with `subagent_type` identifiers
- `output-styles/` - Output style definitions
- `docs/` - Reference documentation

### Skills Structure
- `skills/` - Portable agent skills (skills.sh format)
- Each skill has `SKILL.md` with YAML frontmatter + markdown content
- Skills are framework-agnostic (work in Claude Code, Cursor, Windsurf, Cline)
- Installation: `npx skills add jwilger/claude-code-plugins`
- Documentation: `skills/README.md`

### Command Namespacing
Commands are namespaced automatically: `/<plugin-name>:<command-filename>`
- Example: `sdlc/commands/setup.md` → `/sdlc:setup`
- Command files should NOT have a `name:` field in frontmatter (only `description:`)

## Version Management

**Critical**: When modifying any plugin, update versions in ALL THREE locations:
1. Plugin manifest: `<plugin>/.claude-plugin/plugin.json`
2. Marketplace entry: `.claude-plugin/marketplace.json`
3. **For sdlc plugin**: `sdlc/commands/setup.md` (hardcoded version strings throughout)

The sdlc setup command contains hardcoded version numbers used for update detection. Search for the old version and replace all instances:
```bash
grep -n "3.12.6" sdlc/commands/setup.md  # Find all version references
```

Compare against `origin/main` to determine appropriate semver bump. The plugin cache uses version numbers to detect updates - unchanged versions won't refresh the cache.

## Output Style Synchronization

**CRITICAL**: The sdlc plugin has TWO output styles that share orchestration rules:
- `sdlc/output-styles/sdlc-rules.md` - Orchestration rules without personality
- `sdlc/output-styles/sdlc-marvin.md` - Orchestration rules WITH Marvin personality

**Both files contain identical orchestration rules sections.** When editing one, you MUST update the other in lockstep:
1. The orchestration rules start after the personality section (in marvin) or immediately after frontmatter (in rules)
2. Everything from "# SDLC Workflow Orchestration" to the end must be identical in both files
3. Only the personality section at the top of sdlc-marvin.md differs

**Process for editing orchestration rules:**
1. Edit the rules in ONE file (either one)
2. Copy the entire orchestration section
3. Paste into the OTHER file, preserving the personality section if present
4. Verify both files have identical orchestration content

A PreToolUse hook will remind you of this when editing either file.

## Plugin-Specific Notes

### sdlc Plugin (v4.0.0)
- **Commands:** setup, work, pr, review, design, adr, plan, start, remember, recall, domain-audit
- **Output styles:**
  - `sdlc-rules` - Orchestration and coding guidelines (no personality)
  - `sdlc-marvin` - Same rules with Marvin the Paranoid Android personality
  - **WARNING:** These files must be kept synchronized (see "Output Style Synchronization" above)
- **Agents:** 15 specialized agents for TDD, Event Modeling, and architecture
  - TDD agents: red, green, domain (with hooks to enforce file type restrictions)
  - Event Modeling agents: discovery, workflow-designer, gwt, model-checker
  - Architecture agents: architect, design-facilitator, adr
  - Review agents: code-reviewer, mutation
  - Story planning agents: story, ux
  - Utility agents: file-updater
- **Workflow:** Task-based TDD cycle with mechanical dependency enforcement (v4.0.0+)
- **Skills:** Auto-loads 9 portable skills (tdd-constraints, user-input-protocol, debugging-protocol, etc.)
- **Requires:** gh CLI, gh extensions (gh-issue-ext, gh-project-ext, gh-pr-review)
- **Optional:** git-spice for stacked PRs, Memento MCP for memory
- **Breaking changes in v4.0.0:** See `sdlc/MIGRATION.md`

### bootstrap Plugin
- Commands: rust (bootstraps Rust projects with Nix flake)
- Scaffolds new projects with development environment
