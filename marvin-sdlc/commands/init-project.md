---
description: Initialize project with output style and structure
argument-hint: ""
---

# Initialize Project with marvin-sdlc

This command sets up a new project to use the marvin-sdlc methodology.

## Step 1: Ask User for Output Style Location

Use AskUserQuestion to ask whether to install the output style globally or project-level:

```
{
  "questions": [
    {
      "question": "Where should the marvin-sdlc output style be installed?",
      "header": "Install scope",
      "multiSelect": false,
      "options": [
        {
          "label": "Global (all projects)",
          "description": "Install to ~/.claude/output-styles/ - available for all projects on this machine"
        },
        {
          "label": "Project-level (this project only)",
          "description": "Install to .claude/output-styles/ - only this project uses it"
        }
      ]
    }
  ]
}
```

## Step 2: Determine Paths

Based on user's choice:
- **Global**:
  - Output style destination: `~/.claude/output-styles/marvin-sdlc.md`
  - Settings file: `~/.claude/settings.json`
- **Project-level**:
  - Output style destination: `.claude/output-styles/marvin-sdlc.md`
  - Settings file: `.claude/settings.json`

## Step 3: Copy Output Style

Use Bash to copy the output style file from the plugin to the chosen location:

```bash
# Get the plugin root (where this command file lives)
PLUGIN_ROOT="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"

# For global installation:
mkdir -p ~/.claude/output-styles
cp "${CLAUDE_PLUGIN_ROOT}/marvin-sdlc.md" ~/.claude/output-styles/

# OR for project-level:
mkdir -p .claude/output-styles
cp "${CLAUDE_PLUGIN_ROOT}/marvin-sdlc.md" .claude/output-styles/
```

## Step 4: Update settings.json

Use Edit tool to add or update the `"outputStyle"` field in the appropriate settings.json:

```json
{
  "outputStyle": "marvin-sdlc",
  ...existing settings...
}
```

If settings.json doesn't exist, use Write to create it:

```json
{
  "outputStyle": "marvin-sdlc"
}
```

## Step 5: Create Project CLAUDE.md

Create a minimal `.claude/CLAUDE.md` file for project-specific configuration:

```markdown
# Project: [Project Name]

This project uses the marvin-sdlc methodology (TDD, Event Sourcing, ADR, Story Planning).

## Project Configuration

- **Mutation testing threshold**: 80% (default, can override)
- **Event model location**: `docs/event_model/`
- **Architecture docs**: `docs/architecture/`
- **ADRs**: `docs/architecture/decisions/`

## Project-Specific Overrides

<!-- Add any project-specific conventions, tooling, or methodology customizations here -->
```

## Step 6: Create Recommended Directory Structure

Use Bash to create the recommended project structure:

```bash
mkdir -p docs/event_model
mkdir -p docs/architecture/decisions
mkdir -p .claude
```

## Step 7: Report Completion

Inform the user:

```
✓ marvin-sdlc output style installed ([global/project-level])
✓ Settings updated to use marvin-sdlc output style
✓ Created .claude/CLAUDE.md for project configuration
✓ Created recommended directory structure

The marvin-sdlc methodology is now active. You can:
- Use /tdd for Test-Driven Development
- Use /event-model for Event Sourcing design
- Use /architect for Architecture Decision Records
- Use /plan for Story Planning

Restart Claude Code for the output style to take effect.
```

## Implementation Notes

- Use `${CLAUDE_PLUGIN_ROOT}` to reference the plugin directory
- The Edit tool will trigger the user's Helix review hook automatically
- If settings.json exists at both global and project level, project-level takes precedence
- The output style file must be named exactly `marvin-sdlc.md` to match the `name` field in its frontmatter
