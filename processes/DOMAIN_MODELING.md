# Domain Modeling Philosophy and Process

## CRITICAL: Dependency Management

**BEFORE creating any types that require external dependencies:**

**MANDATORY**: Read and follow **DEPENDENCY_MANAGEMENT.md** process file

**NEVER directly edit** Cargo.toml, pyproject.toml, package.json, or any dependency file.

**ALWAYS call** the dependency-management agent when you need external dependencies.

See DEPENDENCY_MANAGEMENT.md for complete protocol.

---

## CRITICAL: Workflow Functions First, Compiler-Driven Types Second

Domain modeling agents MUST follow this approach (aligned with Scott Wlaschin's Domain Modeling Made Functional):

### 1. Start with Workflow Functions

Define WHAT we want to DO in lib.rs for this story, not HOW

```rust
// CORRECT: Workflow function defining intent
pub fn start_tui_chat_session(config: ApplicationConfig) -> AppResult<()> {
    unimplemented!("Workflow function to be implemented in TDD")
}

// WRONG: Pre-implementing type structure
pub struct TuiApplication {
    config: ApplicationConfig,  // ← No test demands this yet!
    state: AppState,           // ← No test demands this yet!
}
```

### 2. Let Compiler Drive Type Creation

Only create types when compiler demands them

- Write workflow functions first
- Let compiler errors tell us what types we need
- Create minimal nominal types only when compilation fails
- No speculative type design

### 3. Workflow Function Design Principles

- Express business intent, not implementation details
- Take inputs that make sense from caller's perspective
- Return types that represent outcomes, not internal state
- Keep at appropriate abstraction level (not too granular, not too coarse)

### 4. Minimal Types When Demanded

When compiler forces type creation:

```rust
// CORRECT: Minimal nominal type when compiler demands it
#[derive(Debug, Clone)]
pub struct ChatSession;

// WRONG: Over-implemented without test driving it
pub struct ChatSession {
    messages: Vec<Message>,    // ← No test demands this yet!
    user_id: String,          // ← No test demands this yet!
}
```

## Story-Specific Domain Modeling Process

1. **Define Workflow Functions**: What operations does THIS STORY need to perform?
2. **Compiler-Driven Types**: Create minimal types only when compilation fails
3. **Eliminate Primitive Obsession**: Replace raw primitives with nominal types
4. **Test-Driven Structure**: Let N.7 TDD drive internal implementation

## Parse, Don't Validate Philosophy

- Use a data structure that makes illegal states unrepresentable
- Push the burden of proof upward as far as possible, but no further
- Let your data types inform your code, don't let your code control your data types
- Don't be afraid to parse data in multiple passes
- Avoid denormalized representations of data, especially if it's mutable

## Comments Philosophy

**Place comments on these primary declarations only:**

- Classes, structs, types, interfaces, functions, enums
- Focus on "why" and "what", not "how"
- Use canonical documentation style for the language
- **Never add inline or trailing comments**
- Code should be self-documenting through clear naming

## Domain Modeling in TDD Cycle

### Red Phase Review

When Red-TDD-Tester writes a failing test, domain modeling agent must ask:

**"Can the type system prevent this failure?"**

- **If YES**: Create minimal nominal types (empty structs/enums) to replace primitives
- **If NO**: Proceed to Green Implementer
- **CRITICAL**: Create MINIMAL nominal types only - no speculative structure!
- **NEVER** add fields/methods without test demanding them

### Post-Implementation Domain Review

After Green Implementer makes test pass, domain modeling agent must check:

- **Primitive obsession**: Are we using primitives where nominal domain types should exist?
- **Correct use of existing domain types**: Are domain types being used properly?
- **Over-implementation**: Ensure no speculative fields/methods added beyond test needs
- **If violations found**: Create minimal nominal types → Restart current PR's TDD cycle

## Key Principles Summary

1. **Workflow functions define intent** - they describe WHAT we want to do
2. **Compiler drives type creation** - only create types when compilation demands them
3. **Minimal types at first** - empty structs/enums until tests demand structure
4. **Parse, don't validate** - make illegal states unrepresentable
5. **Type system as documentation** - use types to make intent clear
6. **No speculative design** - only create what current story needs
7. **Let tests drive structure** - TDD reveals what types need inside them
8. **Comments on declarations only** - code should be self-documenting
