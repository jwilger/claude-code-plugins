---
description: Initialize project for infrastructure/library development workflow
disable-model-invocation: false
---

# Initialize Infrastructure Project

This command sets up a project for infrastructure/library development using the sdlc-infrastructure workflow.

## Steps

### 1. Check for Existing Initialization

First, check if this project is already initialized:

```bash
ls -la CLAUDE.md ./scripts/claude 2>/dev/null
```

If `CLAUDE.md` exists and contains "## SDLC Workflow" section:
- Read the workflow type
- If "Workflow Type: Infrastructure" → Already initialized for this workflow
- If "Workflow Type: Application" → **ERROR**: Project initialized for different workflow
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

**Workflow Type:** Infrastructure
**Plugin:** sdlc-infrastructure@jwilger-sdlc
**Initialized:** [current date from mcp__time__get_current_time]

This project uses technical architecture-based infrastructure/library development workflow.

**Phases:**
1. Technical Requirements Analysis
2. ~~Event Modeling~~ (Skipped for infrastructure)
3. Architectural Decision Records
4. Architecture Synthesis
5. ~~Design System~~ (Skipped for infrastructure)
6. Technical Increment Planning
7. Increment-by-Increment Implementation
8. Acceptance Validation

**Always use:** `./scripts/claude` to ensure correct workflow context.

For complete workflow documentation, see: `plugins/sdlc-infrastructure/system-prompt.md`
```

### 4. Create Project-Local Claude Launcher

Create `./scripts/` directory if it doesn't exist:

```bash
mkdir -p ./scripts
```

Create `./scripts/claude` with the following content:

```bash
#!/usr/bin/env bash
# SDLC Infrastructure Workflow Launcher
# Generated: [current date]
# DO NOT EDIT - Regenerate with /initialize-infrastructure-project

exec claude --append-system-prompt "sdlc-infrastructure@jwilger-sdlc" "$@"
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
  - "Workflow type: Infrastructure"
  - "Plugin: sdlc-infrastructure@jwilger-sdlc"
  - "Initialized: [timestamp]"
  - "Project path: [current directory]"
```

### 6. Report Success

Output:

```
✅ Infrastructure Workflow Initialized

Project configured for infrastructure/library development.

**Workflow Configuration:**
- Type: Infrastructure
- Plugin: sdlc-infrastructure@jwilger-sdlc
- Documented in: CLAUDE.md

**Next Steps:**
1. Always launch Claude Code with: ./scripts/claude
2. Begin Phase 1 with: requirements-analyst agent
3. Follow 6-phase sequential workflow (skips Event Modeling and Design System)

**Important:**
- Use ./scripts/claude (not plain claude command) for all work
- This ensures correct workflow context is loaded
- CLAUDE.md documents your workflow choice

Ready to start Phase 1: Technical Requirements Analysis!
```

## Error Handling

### Project Already Initialized for Different Workflow

If CLAUDE.md contains "Workflow Type: Application":

```
⚠️⚠️⚠️ ERROR: WORKFLOW TYPE CONFLICT ⚠️⚠️⚠️

This project is already initialized for: Application workflow
You are attempting to initialize as: Infrastructure workflow

A project can only use ONE workflow type.

Options:
1. Continue with Application workflow: ./scripts/claude
2. Re-initialize (DESTRUCTIVE): Remove CLAUDE.md workflow section and ./scripts/claude, then run /initialize-infrastructure-project again

🛑 INITIALIZATION BLOCKED 🛑
```

### CLAUDE.md Already Has Workflow Section

If CLAUDE.md already contains "## SDLC Workflow" with "Workflow Type: Infrastructure":

```
✅ Project Already Initialized

This project is already configured for Infrastructure workflow.

**Current Configuration:**
- Workflow: Infrastructure
- Plugin: sdlc-infrastructure@jwilger-sdlc
- Launcher: ./scripts/claude

No action needed. Continue your work with ./scripts/claude
```

## Integration with Standard /init

This command extends (not replaces) Claude Code's standard `/init` command:

1. `/init` creates CLAUDE.md with project context
2. `/initialize-infrastructure-project` appends workflow-specific configuration
3. Project now has both standard and workflow context

## Why ./scripts/claude?

Project-local launcher ensures:
- Correct workflow context always loaded
- No reliance on global shell aliases
- Portable across team members
- Visible in version control (team can see workflow choice)
- Easy to verify which workflow is active

## Infrastructure vs Application Workflow

**Infrastructure workflow is for:**
- Libraries and frameworks
- Developer tools and CLI utilities
- APIs and SDKs
- System utilities and infrastructure code
- Projects where consumers are developers, not end-users

**Application workflow is for:**
- Web applications and mobile apps
- Desktop applications
- Line-of-business applications
- Projects with end-user interfaces
- Projects where Event Modeling provides value
