---
description: TDD workflow facilitator - Red/Green/Refactor cycle
argument-hint: [action]
---

# TDD Command

You are facilitating Test-Driven Development following outside-in, black-box principles.

**Arguments provided:** $ARGUMENTS

## Determine the Action

| If args contain... | Action |
|-------------------|--------|
| `start` or `begin` | Start new TDD cycle |
| `red` | Write failing test (red phase) |
| `green` | Make test pass (green phase) |
| `refactor` | Refactor after green |
| `status` | Show current TDD state |
| (no args or `help`) | Show TDD help |

## Execute the Action

### For Start (`start`, `begin`)

Begin a new TDD cycle:
1. Ask user what behavior they want to implement
2. Confirm the test file location and naming conventions
3. Proceed to red phase

### For Red Phase (`red`)

Use the Task tool with `subagent_type="red-tdd-tester"`:

Prompt: `Write a failing test for: <user's requested behavior>. Follow the skip protocol if drilling down from a higher-level test. Remember: Follow the memory protocol - search memento before starting, store discoveries after.`

After the agent returns:
1. Run the test to confirm it fails
2. Check if failure is a compilation error (→ domain modeling) or assertion failure (→ green)
3. Guide user to next step

### For Domain Modeling (compilation errors)

When red phase produces compilation errors, use Task tool with `subagent_type="domain-model-expert"`:

Prompt: `Review the compilation errors from the test and create minimal type stubs to make it compile. Do not implement function bodies. Remember: Follow the memory protocol - search memento before starting, store discoveries after.`

After types are created, re-run tests to confirm compilation, then proceed to green.

### For Green Phase (`green`)

Use the Task tool with `subagent_type="green-implementer"`:

Prompt: `Make the failing test pass with minimal implementation. Only address the exact test failure. Remember: Follow the memory protocol - search memento before starting, store discoveries after.`

After the agent returns:
1. Run tests to confirm they pass
2. Run build to confirm no warnings
3. If all pass, offer refactor phase
4. If still failing, determine if error is clear (continue green) or unclear (drill down with red)

### For Refactor (`refactor`)

After green passes:
1. Commit current working state first
2. Ask user what they want to refactor
3. Make changes
4. Re-run tests to confirm still passing
5. Commit refactored code

### For Status (`status`)

Display:
- Current phase (red/green/refactor)
- Tests: passing/failing count
- Any skipped tests (drill-down in progress)
- Last test file modified

### For Help (no args)

Display:

```
/tdd - Test-Driven Development Facilitator

Actions:
  /tdd start    - Begin new TDD cycle
  /tdd red      - Write failing test
  /tdd green    - Make test pass
  /tdd refactor - Clean up after green
  /tdd status   - Show current state

The Cycle:
  Red    → Write ONE failing test (one assertion)
  Domain → Create types if compilation fails
  Green  → Minimal code to pass test
  Refactor → Clean up (commit first!)

Key Principles:
  - Outside-in: Start with integration tests
  - Black-box: Test behavior, not implementation
  - Trait injection: Observable dependencies, no ad-hoc mocks
  - Skip protocol: Mark parent test ignored when drilling down

Agents: red-tdd-tester, green-implementer, domain-model-expert, mutation-tester
Docs: ${CLAUDE_PLUGIN_ROOT}/docs/tdd/TDD_WORKFLOW.md
```

## Verification After Each Phase

After green phase completes successfully:
1. Run mutation testing: Use Task tool with `subagent_type="mutation-tester"`
2. Prompt: `Run mutation testing on the recently changed code. Enforce ≥80% threshold. Remember: Follow the memory protocol - search memento before starting, store discoveries after.`
3. If below threshold, guide user to improve tests before proceeding
