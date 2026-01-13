---
description: INVOKE to begin work. Auto-detects project state and routes to appropriate phase
allowed-tools:
  - Bash
  - Read
  - Glob
  - AskUserQuestion
  - mcp__memento__semantic_search
---

# SDLC Start

Smart entry point that detects the current SDLC phase and routes to the appropriate command.

## Steps

### 1. Check for SDLC Configuration

```bash
test -f .claude/sdlc.yaml && echo "CONFIG_EXISTS" || echo "NO_CONFIG"
```

**If NO_CONFIG**:
```
SDLC not configured for this project.

To get started, run:
  /sdlc:setup

This will configure:
- Event modeling vs traditional mode
- GitHub project integration
- Project-specific TDD hooks
```
Then STOP - don't proceed further.

### 2. Load Configuration

```bash
cat .claude/sdlc.yaml
```

Check the mode (event-modeling vs traditional).

**If mode is `traditional`**:
```
This project uses traditional development mode.

Available commands:
  /sdlc:work  - Start working on a GitHub issue
  /sdlc:pr    - Create/update a pull request
  /sdlc:review - Handle PR review feedback

To switch to event modeling, run /sdlc:setup again.
```
Then STOP.

### 3. Check Domain Discovery

```bash
test -f docs/event_model/domain/overview.md && echo "DOMAIN_EXISTS" || echo "NO_DOMAIN"
```

**If NO_DOMAIN**:
```
Event model not started.

Next step:
  /sdlc:design discover

This will help you understand:
- Who uses the system
- What they're trying to accomplish
- What workflows to model
```
Then STOP.

### 4. Check for Workflows

```bash
ls -d docs/event_model/workflows/*/ 2>/dev/null | head -1 || echo "NO_WORKFLOWS"
```

**If NO_WORKFLOWS**:

This indicates the domain overview was written but no workflows were designed yet.
This is a normal progression after discovery, or may indicate the workflow directory
was accidentally deleted. Check domain overview for suggested starting workflow.

```
Domain discovered, but no workflows designed yet.

Next step:
  /sdlc:design workflow <name>

Check docs/event_model/domain/overview.md for suggested workflows to design first.
```
Then STOP.

### 5. Check for GWT Scenarios

```bash
# Find workflows without GWT scenarios in their slices
for workflow in docs/event_model/workflows/*/; do
  name=$(basename "$workflow")
  if ! grep -q "## GWT Scenarios" "$workflow/slices/"*.md 2>/dev/null; then
    echo "NEEDS_GWT:$name"
  fi
done
```

**If any workflow NEEDS_GWT**:
```
Workflow "<name>" needs GWT scenarios.

Next step:
  /sdlc:design gwt <name>

GWT scenarios define the acceptance criteria for each slice.
```
Then STOP.

### 6. Check for Architecture

```bash
test -f docs/ARCHITECTURE.md && echo "ARCH_EXISTS" || echo "NO_ARCH"
```

**If NO_ARCH**:
```
Event model complete, but architecture not defined.

Next step:
  /sdlc:design arch

This will guide you through:
- Technology stack decisions
- Domain boundary definitions
- Integration approaches
- Cross-cutting concerns

Each decision becomes an ADR, synthesized into ARCHITECTURE.md.
```
Then STOP.

### 7. Check for GitHub Issues from Slices

```bash
# Check if any slices exist
SLICE_COUNT=$(find docs/event_model/workflows/*/slices/*.md 2>/dev/null | wc -l)

# Check for event-model labeled issues
ISSUE_COUNT=$(gh issue list --label "event-model" --json number 2>/dev/null | jq length 2>/dev/null || echo "0")

echo "SLICES:$SLICE_COUNT"
echo "ISSUES:$ISSUE_COUNT"
```

**If SLICES > 0 and ISSUES == 0**:
```
Event model and architecture complete, but no GitHub issues created.

Next step:
  /sdlc:plan

This will create:
- Epic issues for each workflow
- Story issues for each slice
- Acceptance criteria from GWT scenarios
```
Then STOP.

### 8. Check for In-Progress Work

```bash
# Check current branch
BRANCH=$(git branch --show-current)

# Check for assigned issues in progress
gh issue list --assignee @me --state open --json number,title,labels 2>/dev/null
```

**If on a feature branch** (not main/master):
```
Currently on branch: <branch>

To check status:
  git status
  gh pr status

To continue working:
  (Just start coding - TDD hooks will guide you)

To create/update PR:
  /sdlc:pr

To handle review feedback:
  /sdlc:review
```
Then STOP.

**If assigned issues exist**:
```
You have assigned issues:

<list issues>

To start working on one:
  /sdlc:work <issue-number>

Or let me pick the next ready item:
  /sdlc:work
```
Then STOP.

### 9. Default - Ready for New Work

```
Project fully configured and up to date.

To start new work:
  /sdlc:work

This will show ready items from your project board.
```
