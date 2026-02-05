# TDD Troubleshooting Decision Tree

## My test won't compile

### Error about missing types
- **Problem:** Test references types that don't exist yet
- **Solution:** Launch sdlc:domain agent to create type definitions
- **What it does:** Creates struct/enum/trait signatures with `unimplemented!()` stubs
- **Example:** Use Task tool with `subagent_type: "sdlc:domain"`

### Error about wrong module path
- **Problem:** Test imports from wrong location
- **Solution:** Check `docs/ARCHITECTURE.md` for module organization
- **Pattern:** Domain types usually in `src/domain/`, not `src/`

## My test fails for the wrong reason

### Test fails with panic/crash instead of assertion
- **Problem:** Test too complex, multiple assertions, or setup issues
- **Solution:** Launch sdlc:red agent to simplify test (ONE assertion only)
- **Pattern:** Split into multiple tests, each testing one behavior

## My implementation is complex

### GREEN agent wrote lots of code (>20 lines)
- **Problem:** Test is too broad or poorly designed
- **Solution:** Return to RED phase, split test into smaller tests
- **Pattern:** Each test should require <10 lines of production code

### Implementation has primitive types (String, i64, etc.)
- **Problem:** Missing domain types
- **Solution:** Domain review will catch this (or launch sdlc:domain explicitly)
- **Pattern:** Use `Email` instead of `String`, `UserId` instead of `i64`

## Agent coordination unclear

### When to use RED vs GREEN vs DOMAIN?
- **RED:** Writing new test (ONE assertion)
- **DOMAIN:** Creating type definitions (after RED, or standalone audit)
- **GREEN:** Implementing code to make test pass
- **Pattern:** RED → DOMAIN → GREEN → DOMAIN (enforced by hooks)

### How to invoke agents?
Use Task tool:
```javascript
await Task({
  subagent_type: "sdlc:red",
  prompt: "Write test for user authentication..."
});
```

Or let orchestrator handle it (recommended).

## Domain review feedback

### "Primitive obsession detected"
- **Problem:** Using raw types (String, i64) instead of domain types
- **Solution:** Create semantic types (Email, UserId, OrderQuantity)
- **Why:** Type system can enforce domain rules at compile time

### "Invalid states representable"
- **Problem:** Struct allows contradictory field combinations
- **Solution:** Use enums to represent mutually exclusive states
- **Example:** Replace `{email: Option<String>, verified: bool}` with `enum { Unverified{email}, Verified{email, verified_at} }`

### "Parse-don't-validate violation"
- **Problem:** Validation happening deep in logic instead of at construction
- **Solution:** Move validation to type constructors
- **Pattern:** Create type = validate input, use type = trust it's valid

## Tests pass too easily

### Test passed on first try
- **Problem:** Test wasn't actually testing anything new, or implementation already existed
- **Solution:** Check if test is redundant or if code was already present
- **Pattern:** RED phase should ALWAYS produce a failing test

## Error messages unclear

### "Cannot edit this file type"
- **Problem:** Wrong agent for the file type
- **Solution:** See error message for suggested agent to launch
- **RED:** Test files only
- **GREEN:** Production implementation only
- **DOMAIN:** Type definitions only
- **file-updater:** Config, docs, scripts

### "Domain review required"
- **Problem:** Trying to skip mandatory domain review after RED or GREEN
- **Solution:** Domain review is HARD enforcement - must run after RED/GREEN
- **Why:** Prevents primitive obsession and domain violations

## Performance issues

### Domain review takes too long for trivial changes
- **Problem:** Domain agent should auto-triage complexity
- **Solution:** Domain agent has intelligent triage (v9.1.0+):
  - Trivial: 30 seconds (newtype wrapper, field addition)
  - Simple: 2 minutes (validation logic, enum variants)
  - Complex: 5+ minutes (aggregates, state machines)
- **If not working:** File bug - agent needs intelligence improvement

### Tests take forever to run
- **Problem:** Running full test suite after every change
- **Solution:** Run specific test: `cargo test test_name`, `npm test -- test_name`
- **Pattern:** Full suite only before PR creation

## I need to bypass a rule

### Can I skip domain review?
- **NO:** Domain review is HARD enforcement (inviolable)
- **Why:** Domain agent has expertise to determine if change is trivial
- **Fast path:** Trivial changes get quick pass from domain agent (<30 seconds)

### Can I skip test verification?
- **YES (with reason):** Test verification is SOFT enforcement
- **How:** Say "skip test verification because [reason]"
- **Valid reasons:** Tests running in CI, known infrastructure issues, prototyping

### Can I edit files directly (not through agents)?
- **DISCOURAGED:** Orchestrator should delegate to specialists
- **Why:** Specialists have file-type-specific validation
- **Acceptable cases:** Emergency fixes, trivial config changes, prototyping

## Still stuck?

- Check [Enforcement Philosophy](../enforcement-philosophy.md) for rule details
- Check [Workflow Selection](./workflow-selection.md) to find right skill
- Search memory: `/sdlc:recall [problem description]`
- Read [ARCHITECTURE.md](../../ARCHITECTURE.md) if it exists in your project
