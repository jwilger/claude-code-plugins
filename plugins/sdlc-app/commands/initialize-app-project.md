---
description: Initialize project for Event Modeling-based application development workflow
disable-model-invocation: false
---

# Initialize Application Project

This command sets up a project for Event Modeling-based application development using the sdlc-app workflow.

## Steps

### 1. Check for Existing Initialization

First, check if this project is already initialized:

```bash
ls -la CLAUDE.md ./scripts/claude 2>/dev/null
```

If `CLAUDE.md` exists and contains "## SDLC Workflow" section:
- Read the workflow type
- If "Workflow Type: Application" → Already initialized for this workflow
- If "Workflow Type: Infrastructure" → **ERROR**: Project initialized for different workflow
- Otherwise → Continue initialization

### 2. Run Standard Claude Init

Execute the standard Claude Code initialization:

```
/init
```

This creates `CLAUDE.md` with basic project context.

### 3. Append Workflow Configuration to CLAUDE.md

Add the following section to `CLAUDE.md`:

```markdown

## SDLC Workflow

**Workflow Type:** Application
**Plugin:** sdlc-app@jwilger-sdlc
**Initialized:** [current date from mcp__time__get_current_time]

This project uses Event Modeling-based application development workflow.

**Phases:**
1. Requirements Analysis
2. Event Modeling (12-step process)
3. Architectural Decision Records
4. Architecture Synthesis
5. Design System
6. Story Planning
7. Story-by-Story Implementation
8. Acceptance Validation

**Always use:** `./scripts/claude` to ensure correct workflow context.

For complete workflow documentation, see: `plugins/sdlc-app/system-prompt.md`
```

### 4. Create Project-Local Claude Launcher

Create `./scripts/` directory if it doesn't exist:

```bash
mkdir -p ./scripts
```

Create `./scripts/claude` with the following content:

```bash
#!/usr/bin/env bash
# SDLC Application Workflow Launcher
# Generated: [current date]
# DO NOT EDIT - Regenerate with /initialize-app-project

exec claude-code --append-system-prompt "sdlc-app@jwilger-sdlc" "$@"
```

Make it executable:

```bash
chmod +x ./scripts/claude
```

### 5. Store in Memory

Create ProjectWorkflow entity in knowledge graph:

```
mcp__memento__create_entities with:
- name: "ProjectWorkflow-[project_name]"
- entityType: "ProjectWorkflow"
- observations:
  - "Workflow type: Application"
  - "Plugin: sdlc-app@jwilger-sdlc"
  - "Initialized: [timestamp]"
  - "Project path: [current directory]"
```

### 6. Report Success

Output:

```
✅ Application Workflow Initialized

Project configured for Event Modeling-based application development.

**Workflow Configuration:**
- Type: Application
- Plugin: sdlc-app@jwilger-sdlc
- Documented in: CLAUDE.md

**Next Steps:**
1. Always launch Claude Code with: ./scripts/claude
2. Begin Phase 1 with: requirements-analyst agent
3. Follow 8-phase sequential workflow

**Important:**
- Use ./scripts/claude (not plain claude-code) for all work
- This ensures correct workflow context is loaded
- CLAUDE.md documents your workflow choice

Ready to start Phase 1: Requirements Analysis!
```

## Error Handling

### Project Already Initialized for Different Workflow

If CLAUDE.md contains "Workflow Type: Infrastructure":

```
⚠️⚠️⚠️ ERROR: WORKFLOW TYPE CONFLICT ⚠️⚠️⚠️

This project is already initialized for: Infrastructure workflow
You are attempting to initialize as: Application workflow

A project can only use ONE workflow type.

Options:
1. Continue with Infrastructure workflow: ./scripts/claude
2. Re-initialize (DESTRUCTIVE): Remove CLAUDE.md workflow section and ./scripts/claude, then run /initialize-app-project again

🛑 INITIALIZATION BLOCKED 🛑
```

### CLAUDE.md Already Has Workflow Section

If CLAUDE.md already contains "## SDLC Workflow" with "Workflow Type: Application":

```
✅ Project Already Initialized

This project is already configured for Application workflow.

**Current Configuration:**
- Workflow: Application
- Plugin: sdlc-app@jwilger-sdlc
- Launcher: ./scripts/claude

No action needed. Continue your work with ./scripts/claude
```

## Integration with Standard /init

This command extends (not replaces) Claude Code's standard `/init` command:

1. `/init` creates CLAUDE.md with project context
2. `/initialize-app-project` appends workflow-specific configuration
3. Project now has both standard and workflow context

## Why ./scripts/claude?

Project-local launcher ensures:
- Correct workflow context always loaded
- No reliance on global shell aliases
- Portable across team members
- Visible in version control (team can see workflow choice)
- Easy to verify which workflow is active
