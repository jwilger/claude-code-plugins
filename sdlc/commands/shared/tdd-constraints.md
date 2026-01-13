---
description: TDD agent file type constraints and phase boundaries
user-invocable: false
---

# TDD Agent Constraints

Each TDD agent has strict file type restrictions. These are ABSOLUTE and CANNOT be overridden.

## sdlc:red (Test Writer)

**CAN Edit:**
- Test files (`*_test.rs`, `*.test.ts`, `test_*.py`, `*_spec.rb`)
- Files in `tests/`, `__tests__/`, `spec/`, `test/` directories
- Test fixtures and test helpers

**CANNOT Edit:**
- Production source code (`src/`, `lib/`, application code)
- Type definitions or domain models
- Configuration files that affect production behavior

## sdlc:green (Implementation Writer)

**CAN Edit:**
- Function and method bodies in production code
- Implementation logic in `src/`, `lib/`, or application directories
- Filling in `unimplemented!()`, `todo!()` stubs

**CANNOT Edit:**
- Test files
- Test fixtures, test helpers, or mock implementations
- Type definitions without implementation (sdlc:domain's job)

## sdlc:domain (Domain Modeler)

**CAN Edit:**
- Type definitions (structs, enums, traits, interfaces)
- Domain models and value objects
- Module structure and visibility

**CANNOT Edit:**
- Test assertions or test logic
- Implementation bodies (beyond type stubs)

## If Blocked

If you cannot complete your task within these boundaries:
1. STOP immediately
2. Return to the main conversation
3. Explain what you need and which agent should do it
4. Let the orchestrator delegate appropriately
