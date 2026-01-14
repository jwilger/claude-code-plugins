---
description: INVOKE by agents to validate file type boundaries. Defines what each agent can edit
user-invocable: false
---

# Agent File Ownership Constraints

Each SDLC agent has strict file type restrictions. These are ABSOLUTE and CANNOT be overridden.

## File Ownership Matrix

| File Pattern | Authorized Agent(s) | Others BLOCKED |
|--------------|---------------------|----------------|
| Test files (`*_test.*`, `*.test.*`, `tests/`, `__tests__/`, `spec/`, `test/`) | `sdlc:red` | ✓ |
| Production code (`src/`, `lib/`, `app/`) | `sdlc:green` | ✓ |
| Type definitions (structs, enums, traits, interfaces) | `sdlc:domain` | ✓ |
| ADRs (`docs/adr/*.md`) | `sdlc:adr` | ✓ |
| `docs/ARCHITECTURE.md` | `sdlc:design-facilitator`, `sdlc:architect` | ✓ |
| Event model files (`docs/event_model/**/*`) | `sdlc:discovery`, `sdlc:workflow-designer`, `sdlc:gwt`, `sdlc:model-checker` | ✓ |
| Config, scripts, general docs | `sdlc:file-updater` | - |

---

## TDD Agents

### sdlc:red (Test Writer)

**CAN Edit:**
- Test files (`*_test.rs`, `*.test.ts`, `test_*.py`, `*_spec.rb`)
- Files in `tests/`, `__tests__/`, `spec/`, `test/` directories
- Test fixtures and test helpers

**CANNOT Edit:**
- Production source code (`src/`, `lib/`, application code)
- Type definitions or domain models
- Configuration files that affect production behavior
- ADRs, ARCHITECTURE.md, or event model files

### sdlc:green (Implementation Writer)

**CAN Edit:**
- Function and method bodies in production code
- Implementation logic in `src/`, `lib/`, or application directories
- Filling in `unimplemented!()`, `todo!()` stubs

**CANNOT Edit:**
- Test files
- Test fixtures, test helpers, or mock implementations
- Type definitions without implementation (sdlc:domain's job)
- ADRs, ARCHITECTURE.md, or event model files

### sdlc:domain (Domain Modeler)

**CAN Edit:**
- Type definitions (structs, enums, traits, interfaces)
- Domain models and value objects
- Module structure and visibility

**CANNOT Edit:**
- Test assertions or test logic
- Implementation bodies (beyond type stubs)
- ADRs, ARCHITECTURE.md, or event model files

---

## Architecture Agents

### sdlc:adr (ADR Writer)

**CAN Edit:**
- ADR files in `docs/adr/*.md`
- ADR subdirectories `docs/adr/**/*.md`

**CANNOT Edit:**
- ARCHITECTURE.md (use sdlc:design-facilitator or sdlc:architect)
- Event model files
- Test files, production code, or any other files

### sdlc:architect (Technical Architect)

**CAN Edit:**
- `docs/ARCHITECTURE.md` only

**CANNOT Edit:**
- ADRs (archival documents - never edit directly)
- Event model files
- Test files, production code, or any other files

**CRITICAL**: The architect must NEVER reference ADRs by number. Use ARCHITECTURE.md exclusively.

### sdlc:design-facilitator (Architecture Facilitator)

**CAN Edit:**
- `docs/ARCHITECTURE.md`

**Delegates To:**
- `sdlc:adr` for creating/updating ADRs (via `/sdlc:adr` command)

**CANNOT Edit:**
- ADR files directly (must delegate)
- Event model files
- Test files, production code, or any other files

---

## Event Modeling Agents

### sdlc:discovery (Domain Discovery)

**CAN Edit:**
- Files in `docs/event_model/**/*`
- Domain overview: `docs/event_model/domain/overview.md`

**CANNOT Edit:**
- ADRs, ARCHITECTURE.md
- Test files, production code
- Any file outside `docs/event_model/`

### sdlc:workflow-designer (Workflow Designer)

**CAN Edit:**
- Files in `docs/event_model/**/*`
- Workflow overviews: `docs/event_model/workflows/<name>/overview.md`
- Slice documents: `docs/event_model/workflows/<name>/slices/*.md`

**CANNOT Edit:**
- ADRs, ARCHITECTURE.md
- Test files, production code
- Any file outside `docs/event_model/`

### sdlc:gwt (GWT Scenario Generator)

**CAN Edit:**
- Files in `docs/event_model/**/*`
- Adds GWT scenarios to slice documents

**CANNOT Edit:**
- ADRs, ARCHITECTURE.md
- Test files, production code
- Any file outside `docs/event_model/`

### sdlc:model-checker (Model Validator)

**CAN Edit:**
- Files in `docs/event_model/**/*`
- Fixes gaps in workflow and slice documentation

**CANNOT Edit:**
- ADRs, ARCHITECTURE.md
- Test files, production code
- Any file outside `docs/event_model/`

---

## Utility Agent

### sdlc:file-updater (File Updater)

**CAN Edit:**
- Configuration files (*.json, *.yaml, *.toml, etc.)
- Build scripts and tooling
- General documentation (README, CONTRIBUTING, etc.)
- Any file NOT owned by a specialized agent

**CANNOT Edit:**
- Test files (sdlc:red)
- Production code (sdlc:green)
- Type definitions (sdlc:domain)
- ADRs (sdlc:adr)
- ARCHITECTURE.md (sdlc:design-facilitator, sdlc:architect)
- Event model files (sdlc:discovery, sdlc:workflow-designer, sdlc:gwt, sdlc:model-checker)

---

## If Blocked

If you cannot complete your task within these boundaries:

1. **STOP immediately**
2. **Return to the main conversation**
3. **Explain what you need and which agent should do it**
4. **Let the orchestrator delegate appropriately**

Do NOT attempt to circumvent these constraints. They exist to maintain clear separation of concerns and ensure proper workflow.
