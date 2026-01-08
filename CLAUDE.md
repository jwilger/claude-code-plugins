# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Claude Code plugin marketplace containing plugins:
- **sdlc** - Complete SDLC workflow with TDD, Event Modeling, ADRs, GitHub integration, and Marvin personality
- **bootstrap** - Project scaffolding with Nix-based development environments

## Commands

```bash
# Validate a plugin
claude plugin validate sdlc
claude plugin validate bootstrap

# Update marketplace (fetches latest from source)
/plugin
```

## Plugin Architecture

### Marketplace Structure
- `.claude-plugin/marketplace.json` - Plugin registry (name: `jwilger-claude-plugins`)
- Each plugin lives in its own directory with `.claude-plugin/plugin.json`

### Plugin Components
- `commands/` - Slash commands (filename → command name, plugin name → namespace prefix)
- `agents/` - Specialized subagents with `subagent_type` identifiers
- `output-styles/` - Output style definitions
- `docs/` - Reference documentation

### Command Namespacing
Commands are namespaced automatically: `/<plugin-name>:<command-filename>`
- Example: `sdlc/commands/setup.md` → `/sdlc:setup`
- Command files should NOT have a `name:` field in frontmatter (only `description:`)

## Version Management

**Critical**: When modifying any plugin, update versions in BOTH locations:
1. Plugin manifest: `<plugin>/.claude-plugin/plugin.json`
2. Marketplace entry: `.claude-plugin/marketplace.json`

Compare against `origin/main` to determine appropriate semver bump. The plugin cache uses version numbers to detect updates - unchanged versions won't refresh the cache.

## Plugin-Specific Notes

### sdlc Plugin
- Commands: setup, work, pr, review, design, adr, plan, start
- Output style: marvin-sdlc (Marvin the Paranoid Android personality)
- 10 specialized agents for TDD, planning, and event modeling
- Requires: gh CLI, gh extensions (gh-issue-ext, gh-project-ext, gh-pr-review)
- Optional: git-spice for stacked PRs, Memento MCP for memory

### bootstrap Plugin
- Commands: rust (bootstraps Rust projects with Nix flake)
- Scaffolds new projects with development environment
