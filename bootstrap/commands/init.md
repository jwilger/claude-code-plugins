---
description: Bootstrap a Nix development environment for any language or framework
argument-hint: "[language/framework]"
allowed-tools:
  - Bash
  - Read
  - Glob
  - Task
  - AskUserQuestion
  - mcp__memento__semantic_search
---

# Bootstrap Init

Intelligent Nix development environment bootstrapper. Works with any language or framework by detecting existing projects or asking what to build.

## Overview

This command orchestrates three specialized agents:
1. **detector** - Analyzes the directory to detect project type
2. **researcher** - Searches for current Nix best practices
3. **generator** - Creates flake.nix and supporting files

## Usage

```bash
# Auto-detect from existing project
/bootstrap:init

# Specify language/framework
/bootstrap:init rust
/bootstrap:init "elixir phoenix"
/bootstrap:init "typescript nextjs"
```

## Process Flow

### Step 1: Check Location

Determine where to bootstrap:

```bash
# Check if we're in an empty directory or existing project
ls -la
```

If the user provided a project name argument and directory is not empty:
- Ask if they want to create a subdirectory or use current directory

### Step 2: Check for Existing Nix

```bash
test -f flake.nix && echo "FLAKE_EXISTS" || echo "NO_FLAKE"
test -f shell.nix && echo "SHELL_NIX_EXISTS" || echo "NO_SHELL_NIX"
```

**If FLAKE_EXISTS**:
```
This directory already has a flake.nix.

Options:
1. Enhance existing flake (add universal tools, update packages)
2. Replace flake (backup existing, create fresh)
3. Cancel

Which would you prefer?
```

**If SHELL_NIX_EXISTS** (but no flake.nix):
```
This directory has a legacy shell.nix but no flake.

Flakes are the modern approach with better reproducibility.

Options:
1. Migrate to flake (backup shell.nix, create flake.nix)
2. Cancel

Would you like to migrate?
```

### Step 3: Check Memento Cache

Before launching agents, check for cached knowledge:

```
mcp__memento__semantic_search for relevant Nix bootstrap patterns
```

If recent research exists for this language/framework, note it for the researcher agent.

### Step 4: Launch Detector Agent

Use the Task tool to launch the detector agent:

```
Launch bootstrap:detector agent to analyze the current directory.

Context:
- User argument: [if provided]
- Current directory contents: [summary]
- Existing Nix status: [from step 2]

The detector should:
1. Scan for project manifest files
2. Identify language and frameworks
3. Check for toolchain files
4. Ask user if needed
5. Return structured JSON

Wait for detection results.
```

Receive detection results as JSON.

### Step 5: Launch Researcher Agent

Use the Task tool to launch the researcher agent:

```
Launch bootstrap:researcher agent to find current Nix best practices.

Context from detector:
- Primary language: [from detection]
- Frameworks: [from detection]
- Package managers: [from detection]
- Additional requirements: [from detection]

The researcher should:
1. Check memento cache first
2. Search web for current patterns
3. Find official overlays
4. Document platform-specific needs
5. Cache findings in memento
6. Return structured JSON

Wait for research results.
```

Receive research results as JSON.

### Step 6: Launch Generator Agent

Use the Task tool to launch the generator agent:

```
Launch bootstrap:generator agent to create the development environment.

Detection context:
[paste detection JSON]

Research context:
[paste research JSON]

The generator should:
1. Create flake.nix with universal + language tools
2. Create toolchain file if needed
3. Create .envrc, .gitignore, CLAUDE.md
4. Validate with nix flake check
5. Build the devshell
6. Initialize git and commit
7. Return success/failure report

Wait for generation results.
```

### Step 7: Handle Results

**On success:**
```
Bootstrap Complete!

[Display generator's success output]

**Next Steps:**

1. Exit Claude Code now
2. If you have direnv, the shell will load automatically
   Otherwise, run: nix develop
3. Restart Claude Code in this directory

Happy coding!
```

**On failure:**
```
Bootstrap encountered issues.

[Display generator's failure output]

Would you like to:
1. Retry with different settings
2. See detailed error information
3. Try a manual fix approach
```

## Shortcut: Argument Provided

If the user provided a language/framework argument:

```
/bootstrap:init rust
```

Skip some detection questions - pass the argument directly to the detector agent as a hint.

The detector can still ask clarifying questions (e.g., "Which Rust framework?" or "Include database tooling?") but has a strong starting point.

## Error Handling

### Agent Failures

If any agent fails:
1. Capture the error message
2. Try to recover if possible
3. Report clearly to user

### Network Issues

If WebSearch fails in researcher:
- Fall back to memento cache
- Use conservative defaults from nixpkgs
- Note reduced confidence

### Nix Build Failures

If generator's flake check fails:
- Generator handles retries internally
- If still failing, report specific error
- Offer manual intervention option

## Enhancement Mode

When enhancing an existing flake:
1. Detector notes `existing_nix.has_flake: true`
2. Researcher checks what's already configured
3. Generator reads existing flake, adds missing tools
4. Creates backup before modifying

The goal is additive - don't break what works.

## Success Criteria

Bootstrap is successful when:
1. `flake.nix` exists and passes `nix flake check`
2. `nix develop` successfully builds the shell
3. `flake.lock` exists with pinned versions
4. `.envrc` exists for direnv
5. Git repository initialized (or already existed)
6. Initial commit created (or skipped if existing repo)
