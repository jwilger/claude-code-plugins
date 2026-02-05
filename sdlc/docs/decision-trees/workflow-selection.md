# Workflow Selection Decision Tree

Start here if you're unsure what skill to use.

## "I want to start a new feature"

Do you have a detailed design?
- **YES** → `/sdlc:work` (start TDD cycle with existing requirements)
- **NO** → Next question

Do you understand the domain well?
- **YES** → `/sdlc:arch` (document architecture decisions, then work)
- **NO** → `/sdlc:specify discover` (Event Modeling facilitation)

## "I want to continue working"

Is your work in progress?
- **YES** → `/sdlc:start` (auto-detects state and resumes)
- **NO** → Next question

Do you have PR feedback to address?
- **YES** → `/sdlc:review` (handle review comments)
- **NO** → `/sdlc:complete <task-id>` (close completed task)

## "I need to understand the system"

- `/sdlc:recall [search-term]` - Search memory for context
- Read `docs/ARCHITECTURE.md` - System overview
- Read `docs/event_model/` - Domain models
- `/sdlc:specify validate` - Check event model consistency

## "I'm stuck on a test/implementation"

See [TDD Troubleshooting Decision Tree](./tdd-troubleshooting.md)

## "I want to make an architecture decision"

- `/sdlc:arch` - Document architecture decision in ARCHITECTURE.md
- Architect agent guides you through decision rationale and alternatives
- Creates isolated commit with architecture changes

## "I want to create issues from my event model"

- `/sdlc:plan` - Converts event model slices into GitHub issues
- Creates dependency graph between issues
- Generates task breakdown for implementation

## "I want to review my work before PR"

- `/sdlc:pr` - Comprehensive three-stage code review
  - Stage 1: Specification alignment
  - Stage 2: Code quality check
  - Stage 3: Domain integrity review
- Includes mutation testing verification

## "I want to capture knowledge"

- `/sdlc:remember patterns "title"` - Store reusable pattern
- `/sdlc:remember conventions "title"` - Store project convention
- `/sdlc:remember debugging "title"` - Store debugging solution

## "First time using the SDLC plugin?"

- `/sdlc:setup` - One-time project configuration
  - Installs required CLI tools (gh extensions)
  - Creates project structure
  - Configures workflow settings
