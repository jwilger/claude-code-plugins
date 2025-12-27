# TDD Workflow

## Overview

Test-Driven Development following outside-in, black-box principles with strict agent boundaries.

## The Cycle

```
Red → Domain → Green → Refactor → Commit
```

1. **Red**: Write ONE failing test with ONE assertion
2. **Domain**: Create minimal types if compilation fails
3. **Green**: Minimal implementation to pass test
4. **Refactor**: Clean up (commit working state first!)
5. **Commit**: Auto-commit after each passing cycle

## Agent Boundaries

| Agent | Scope | Never |
|-------|-------|-------|
| red-tdd-tester | Test files ONLY | Production code |
| green-implementer | Production code ONLY | Test files |
| domain-model-expert | Type signatures ONLY | Function bodies |

**Boundaries are NON-NEGOTIABLE.**

## Acceptance Criteria Checkpoint

**BEFORE delegating from Red to Domain/Green:**

1. Verify red-tdd-tester's test matches the acceptance criteria
2. Check that Given/When/Then in test aligns with Given/When/Then in scenario
3. For trait implementations, ensure test uses trait interface
4. If test doesn't match criteria, reject and have red-tdd-tester rewrite

**This checkpoint is NON-NEGOTIABLE.** A passing test that verifies the wrong thing is worse than no test.

## Outside-In Approach

Start with integration/acceptance tests, drill down as needed:

```
Integration Test (fails)
    ↓
  Unit Test (drill down if error unclear)
    ↓
  Another Unit Test (keep drilling)
    ↓
  Implementation (when error is obvious)
    ↓
  Work back up (remove skips, tests pass)
```

## Skip Protocol for Drill-Down

When a high-level test fails but the error isn't clear enough:

### 1. Mark Parent Test as Ignored

```rust
#[ignore = "working on: test_specific_component"]
fn test_high_level_behavior() { ... }
```

The ignore message MUST reference the child test being worked on.

### 2. Write Lower-Level Test

Create a more focused test for the suspected component.

### 3. Work at Lower Level

Continue Red → Domain → Green at this level until passing.

### 4. Remove Ignore and Work Up

Once child passes, remove parent's ignore annotation and verify parent progresses.

### 5. Repeat Until Integration Test Passes

## When to Drill Down vs. Implement

**Implement (error is obvious):**
- Test expects value A, got value B → change to return A
- Single clear fix needed
- No ambiguity about what's wrong

**Drill Down (error is unclear):**
- "Test failed" but multiple possible causes
- Integration test fails, unclear which component
- "Something went wrong" → need to isolate

**Rule of thumb:** If you have to guess, drill down.

## Integration Testing for Interfaces

When implementing an adapter/implementation of a trait/interface:

**REQUIRED: Test through the interface, not concrete type**

```rust
// Given: Implementing GuardTrait for PostgresCoordinatorGuard

// DON'T: Test only concrete methods
let guard = PostgresCoordinatorGuard::new();
guard.is_valid(); // Bypasses trait - mismatches won't be caught

// DO: Test through trait to verify compatibility
fn accepts_guard<G: GuardTrait>(g: &G) -> bool {
    g.is_valid()
}
let guard = PostgresCoordinatorGuard::new();
accepts_guard(&guard); // Ensures trait is actually implemented correctly
```

**Why this matters:**
- Catches signature mismatches (async vs sync)
- Verifies trait bounds are satisfied
- Ensures the implementation actually works in production contexts
- Direct method calls bypass trait constraints

This catches type system violations at test time, not in production.

## Dead Code Policy

**If nothing uses it, DELETE IT.**

- Compiler warns about unused code → DELETE, don't implement
- Field not read → DELETE the field
- Function not called → DELETE the function

When tests need it, they will fail and demand it.

## Verification Requirements

Before any TDD round is considered complete:

1. **Build passes** - No compilation errors
2. **All tests pass** - Not just the new test, ALL tests
3. **No dead code warnings** - Delete unused code
4. **Mutation score ≥80%** - Tests actually catch bugs

Never proceed to next Red phase without verification.

## Commit Points

Commit after:
- Each passing Green phase (before refactor)
- After refactor (if tests still pass)
- When removing a skip and parent test passes

## Integration with Event Model

Stories come from event model slices:
- GWT scenarios → Test cases
- Each scenario → One or more tests
- Slice complete → Story complete
