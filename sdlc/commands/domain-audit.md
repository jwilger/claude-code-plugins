---
description: Audit domain types for semantic correctness and compile-time safety opportunities
invocation: user
---

# Domain Type Audit

Perform a focused audit of domain types in the codebase, identifying opportunities to use the type system to make invalid states unrepresentable.

## When to Use

- **On demand**: When you want a quick check of domain type quality
- **After refactoring**: To verify domain integrity wasn't compromised
- **Before PR**: As a final domain quality gate

## Audit Process

1. **Find domain types**: Search for struct/enum definitions in domain/model files
2. **Check for structural vs semantic types**: Identify generic types that should be domain-specific
3. **Find tests that could be compile-time**: Identify runtime assertions that could be type-enforced
4. **Report findings**: Concise, actionable output

## Execution

Invoke the sdlc-domain agent with a focused audit prompt:

```
Task(subagent_type="sdlc-domain",
     prompt="Perform a FOCUSED domain type audit. No documentation files - just analysis and fixes.

## Audit Scope

1. Read domain/model files (src/**/model.rs, src/**/domain/*, lib/**/types/*)
2. Read test files for runtime assertions

## Identify Issues

For each domain type found, check:
- Is it SEMANTIC (DiagramTitle) or just STRUCTURAL (NonEmptyString)?
- Could two fields be confused? (Both are `String` or both are `NonEmptyString`)
- Are there runtime tests that check invariants a type could enforce?

## Output Format

For each issue found:
```
FILE: <path>
ISSUE: <structural type | missing domain type | runtime check could be compile-time>
CURRENT: <what exists now>
PROPOSED: <what it should be>
RATIONALE: <one sentence why>
```

## Action

If issues are found:
1. Report them concisely
2. Ask if user wants them fixed
3. If yes, make the type changes (following normal domain agent rules)

If no issues: Report 'Domain types look good - no semantic type issues found.'")
```

## Integration with TDD Cycle

This audit runs automatically in lightweight form:
- **After Red phase**: Domain agent checks if test uses semantic types
- **After Green phase**: Domain agent checks if implementation respects type boundaries

The `/sdlc:domain-audit` command is for deeper, on-demand analysis.

## Example Output

```
Domain Type Audit Results
========================

FILE: src/model.rs
ISSUE: Structural type used instead of semantic type
CURRENT: pub struct Config { name: NonEmptyString, path: NonEmptyString }
PROPOSED: Create ConfigName and ConfigPath types
RATIONALE: name and path have different meanings but same type

FILE: src/parser.rs
ISSUE: Runtime check could be compile-time
CURRENT: assert!(!input.is_empty(), "input required")
PROPOSED: Use NonEmptyInput type that validates on construction
RATIONALE: Parse-don't-validate - catch at type boundary, not runtime

Found 2 issues. Would you like me to fix them?
```
