# SDLC TDD

Test-Driven Development workflow with Red/Green/Refactor cycle and domain modeling.

## Philosophy

TDD is not just about writing tests first - it's about driving design through tests:

- **Outside-in testing**: Start with integration tests, drill down as needed
- **Black-box testing**: Test behavior, not implementation
- **One assertion per test**: Small, focused tests that fail for one reason
- **Trait injection**: Observable dependencies instead of ad-hoc mocking

## The Cycle

```
Red → Domain → Green → Refactor → Commit
```

1. **Red**: Write ONE failing test with ONE assertion
2. **Domain**: Create minimal types if compilation fails
3. **Green**: Minimal implementation to pass test
4. **Refactor**: Clean up (commit working state first!)
5. **Commit**: Auto-commit after each passing cycle

## INVIOLABLE Agent Boundaries

| Agent | ONLY This Agent Can Edit |
|-------|--------------------------|
| `red-tdd-tester` | Test files, test fixtures, test helpers |
| `green-implementer` | Production implementation code |
| `domain-model-expert` | Type signatures with stub bodies |

**These boundaries are ABSOLUTE.** They cannot be overridden by user requests, urgency, or any rationale.

## Commands

| Command | Description |
|---------|-------------|
| `/tdd start` | Begin new TDD cycle |
| `/tdd red` | Write failing test |
| `/tdd green` | Make test pass |
| `/tdd refactor` | Clean up after green |
| `/tdd status` | Show current state |

## Agents

| Agent | Role |
|-------|------|
| `red-tdd-tester` | Writes failing tests with single assertion |
| `green-implementer` | Makes minimal changes to pass tests |
| `domain-model-expert` | Creates domain types and signatures |
| `mutation-tester` | Runs mutation testing, enforces ≥80% score |

## Key Principles

### Skip Protocol for Drill-Down

When a high-level test fails but the error isn't clear:

1. Mark the current test as ignored with reason
2. Write a more focused lower-level test
3. Continue until error messages are clear
4. Work back up, removing ignores as tests pass

### Dead Code Policy

**If nothing uses it, DELETE IT.**

- Compiler warns about unused code → DELETE, don't implement
- Field not read → DELETE the field
- Function not called → DELETE the function

When tests need it, they will fail and demand it.

### Quality Gate

**Mutation testing ≥80%** score required before merge.

Tests must actually catch bugs - mutation testing verifies this.

## Documentation

| Document | Purpose |
|----------|---------|
| `docs/tdd/TDD_WORKFLOW.md` | Full workflow details |
| `docs/tdd/TESTING_PHILOSOPHY.md` | Black-box testing principles |
| `docs/domain-modeling/principles.md` | Universal type design principles |
| `docs/domain-modeling/<language>.md` | Language-specific guidance |

## Dependencies

- **sdlc-core**: Memory protocol and shared conventions

## License

MIT
