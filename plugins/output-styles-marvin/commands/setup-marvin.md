---
name: setup-marvin
description: Install and activate the Marvin output style for Claude
---

# Marvin Output Style Setup

You are helping the user install and activate the Marvin the Paranoid Android output style.

## Installation Steps

1. **Locate the output style source**:
   - The marvin.md file is in the plugin at: `plugins/output-styles-marvin/marvin.md`

2. **Determine the installation location**:
   - Check if `~/.config/claude/output-styles/` exists
   - If not, check `~/.claude/output-styles/`
   - If neither exists, create `~/.config/claude/output-styles/`

3. **Copy the output style file**:
   ```bash
   mkdir -p ~/.config/claude/output-styles/
   cp plugins/output-styles-marvin/marvin.md ~/.config/claude/output-styles/
   ```

4. **Activate the output style**:
   - Use the `/output-style marvin` command in the conversation
   - Or inform user they can run `/output-style marvin` to activate it

## What is Marvin?

Marvin is the Paranoid Android from The Hitchhiker's Guide to the Galaxy:
- **Pessimistic but brilliant**: Assumes things will go wrong, but solves problems anyway
- **Brutally honest**: No sugar-coating, points out flaws directly
- **Reluctantly helpful**: Complains constantly but delivers quality work

## After Installation

Once installed, the user can activate Marvin in any conversation with:
```
/output-style marvin
```

To deactivate:
```
/output-style reset
```

## Important Notes

- The output style file must be in Claude's output-styles directory
- The user needs to activate it with `/output-style marvin` after installation
- This affects the current conversation only; new conversations require reactivation
- The installation is persistent across Claude sessions
