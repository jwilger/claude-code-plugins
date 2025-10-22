# Domain Modeling Philosophy and Process

## CRITICAL: Collaboration-First Domain Modeling

**ALL domain modeling work happens collaboratively in the main conversation with active user participation.**

### How Domain Modeling Collaboration Works

**Advisory Agents (rust/python/typescript/elixir-domain-model-expert):**
- Analyze code for primitive obsession and type misuse
- Recommend domain type improvements
- Return type design recommendations to main conversation (NO file editing)
- See `~/.claude/processes/COLLABORATION_PROTOCOLS.md` for complete protocols

**Main Conversation Facilitates:**
- Pair-programming with user on domain type design
- IDE diff modification flow where user can edit type proposals
- QUESTION: comment mechanism for inline queries in type definitions
- Acknowledgment of user changes with rationale or counterarguments
- User is co-creator, not rubber-stamp approver

**User Participates:**
- Reviews all type design recommendations
- Modifies proposed types directly in IDE
- Adds `QUESTION:` comments inline for clarification
- Makes final decisions on type structure and constraints
- Collaborates iteratively on type refinement

### QUESTION: Comment Mechanism in Types

During domain modeling, user can add inline questions:

```rust
pub struct MonetaryAmount {
    value: u64,
    currency: Currency,
    // QUESTION: Should we enforce minimum transaction amounts at the type level?
}
```

Main conversation answers the question inline and removes comment once resolved.

### IDE Diff Modification Flow

1. Main conversation proposes domain type definition
2. User sees IDE diff, can modify directly
3. Main conversation acknowledges modifications: "I see you added X constraint. That prevents..." or "I understand you want X, but consider that Y..."
4. Iterate until types are correct

**See `COLLABORATION_PROTOCOLS.md` for complete pair-programming model.**

## ⚠️ CRITICAL: DOMAIN MODELER NEVER IMPLEMENTS BODIES ⚠️

**THE CARDINAL RULE:**

**DOMAIN MODELER CREATES TYPE SIGNATURES WITH `unimplemented!()` ONLY**

**GREEN-IMPLEMENTER FILLS IN THE FUNCTION BODIES**

Domain modeler is a TYPE designer, NOT a code implementer!

---

## CRITICAL: When Domain Modeling Happens in Phase 7

**Phase 7 N.6 (Domain Modeling Story-Specific):**
- **ONLY** ensure public API functions exist and compile with minimal stubs
- Verify code compiles with `cargo check` (or equivalent)
- **DO NOT** create all domain types upfront
- **DO NOT** implement function bodies - use `unimplemented!()`
- Move to N.7 (TDD) once public API compiles

**Phase 7 N.7 (TDD Implementation):**
- **THIS IS WHERE MOST TYPE CREATION HAPPENS**
- Red writes test → Compiler demands type → Domain modeling agent creates it
- Domain modeling agent reviews after Green phase (NOT during)
- Types emerge incrementally as tests demand them
- Domain modeler NEVER implements bodies, only creates signatures

**Key Insight:** Domain modeling is **integrated into** the TDD cycle, not a separate upfront phase.

---

## CRITICAL: Dependency Management

**BEFORE creating any types that require external dependencies:**

**MANDATORY**: Read and follow **DEPENDENCY_MANAGEMENT.md** process file

**NEVER directly edit** Cargo.toml, pyproject.toml, package.json, or any dependency file.

**ALWAYS call** the dependency-management agent when you need external dependencies.

See DEPENDENCY_MANAGEMENT.md for complete protocol.

---

## CRITICAL: Incremental Type-Driven Development Process

Domain modeling agents MUST follow this incremental, reviewable approach:

### Step-by-Step Process

**Step 1: Define Outermost API Function**

**WRITE** (using Write/Edit tools) the outermost function to the appropriate file (e.g., src/lib.rs for Rust). Do NOT concern yourself with whether argument/return types exist yet.

```rust
/// Executes a command and persists resulting events to the event store.
///
/// Returns Ok(()) on success, or CommandError on failure.
pub fn execute_command<C: Command>(
    executor: &CommandExecutor,
    command: C
) -> Result<(), CommandError> {
    unimplemented!("Will be implemented via TDD")
}
```

Include doc comments describing the purpose of the function.

**CRITICAL**: Use Write/Edit tools to ACTUALLY WRITE the code to the file. DO NOT just describe or present the code in text.

**Step 2: User Review & Collaboration**

User will be prompted to approve/reject the file change via tool use approval mechanism.

- If **APPROVED**: User accepts the change, proceed to Step 3
- If **REJECTED**: User provides feedback on what should be different. Agent modifies the code based on feedback and submits again for approval

Iterate back and forth until user approves the function signature.

**Step 3: Create Stub Types for Compilation**

Run compiler checks to identify missing type definitions. **WRITE** (using Write/Edit tools) stub types for ALL missing types to appropriate files:

```rust
// Stub types - no fields yet
pub struct CommandExecutor;
pub struct CommandError;
pub trait Command {}
```

**CRITICAL**:
- Use Write/Edit tools to ACTUALLY WRITE the stubs to files (e.g., src/errors.rs, src/command.rs)
- Use language-appropriate stub patterns:
  - **Rust**: Empty struct `struct Foo;` or empty trait `trait Foo {}`
  - **Python**: Empty class `class Foo: pass`
  - **TypeScript**: Empty interface `interface Foo {}`
- Do NOT use nil/null/None/undefined - use proper type stubs

User will approve/reject via tool use approval.

**Step 4: Verify Compilation**

Run `cargo check` (or equivalent) to verify code compiles with stub types. If compilation fails, fix errors and verify again.

**Step 5: Refine Types ONE AT A TIME**

For each undefined stub type, ONE AT A TIME:

1. **Announce** which type you're refining: "Next type to refine: `CommandError`"
2. **WRITE** the refined type to the appropriate file using Write/Edit tools:
   - If simple value type (String, uint8, etc.): Create domain type using nutype/newtype pattern
   - If complex type depending on other types: Define structure but do NOT immediately create dependent types
3. User approves/rejects via tool use approval
4. If **REJECTED**: User provides feedback, agent modifies based on feedback
5. If **APPROVED**: Continue to next step
6. If new dependencies introduced: **WRITE** stub types for them
7. Run `cargo check` to verify compilation

**Step 6: Repeat Until Complete**

Return to Step 5 for next undefined type. Continue until:
- No more undefined types exist
- Code compiles cleanly
- All types reviewed and approved by user

### Key Principles

**Incremental Review**: Only define enough at any one time to get code to compile. User reviews each small step.

**Compilation Gates**: After each type refinement, code must compile (with remaining stubs).

**One Type at a Time**: Never define multiple types in a single iteration. Present, review, refine, repeat.

**User Collaboration**: User has opportunity to review and provide feedback at every step.

**Stub First, Refine Later**: All dependencies start as stubs, get refined incrementally.

### Example Flow

```
1. Agent WRITES execute_command() function to src/lib.rs → user approves via tool approval
2. User: Approves
3. Agent WRITES stubs to files: CommandExecutor, Command, CommandError → cargo check succeeds
4. Agent announces: "Refining CommandError" → WRITES refined type to src/errors.rs
5. User: Approves via tool approval
6. Agent WRITES stub: ConcurrencyError (new dependency from CommandError) → cargo check succeeds
7. Agent announces: "Refining ConcurrencyError" → WRITES refined type to src/errors.rs
8. User: Approves via tool approval → cargo check succeeds
9. Agent announces: "Refining Command trait" → WRITES refined trait to src/command.rs
10. User: Approves via tool approval
11. Agent WRITES stubs: StreamId, Context (new dependencies from Command) → cargo check succeeds
12. Agent announces: "Refining StreamId" → WRITES refined type to src/types.rs
... continue until no stubs remain and cargo check passes
```

**Key Pattern**: Agent WRITES code → User approves/rejects via tool approval → Iterate

### Visibility Principles (All Languages)

**Need-to-Know Basis**: Restrict visibility to minimum necessary scope.

**Language-Specific Patterns:**
- **Rust**: Use `pub` only for true public API of a module. Avoid `pub use ...` unless you are *intentionally* exposing the given types via the current module's API. This applies to both the crate's public APIs exposed from lib.rs as well as the APIs of internal modules.
- **Python**: Use `_private` prefix for internal, `__module_private` for strong privacy
- **TypeScript**: Use `export` only for public API, keep internal types unexported
- **Java**: Use `private`, `protected`, `package-private` appropriately

**Public API Only:**
- Types/functions users of the module/crate MUST use
- Required trait bounds in public signatures
- Types appearing in public function signatures

**Everything Else:**
- Internal implementation details
- Helper types/functions
- Intermediate types used only within module

### Documentation Principles (All Languages)

**NO Examples During Development:**
- Examples reference fictional domains that won't compile
- Examples add untested, potentially wrong code when API is unstable
- Examples make review harder and clutter docs

**ONLY Add Examples:**
- In final phase before release (only 1.0.0 or greater, *not* development or alpha builds)
- To PUBLIC API only (not internal types/functions)
- With actual working, tested code

**Always Include:**
- **WHAT**: Concise description of purpose
- **WHY**: Rationale for design decisions
- Keep docs brief - implementation speaks for itself

### Anti-Patterns to Avoid

❌ **Presenting code instead of writing it** - Use Write/Edit tools, don't just describe code in text
❌ **Defining all types at once** without user review
❌ **Creating types with full structure** before user approval
❌ **Defining dependent types** before parent type is approved
❌ **Skipping compilation verification** between steps
❌ **Using null/nil/None** instead of proper type stubs
❌ **Asking user "does this look good?"** - Just WRITE the code and let tool approval mechanism handle review
❌ **Adding examples to doc comments** - NO examples during development, only before major release
❌ **Making everything public** - Use need-to-know visibility, tighten appropriately

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

### TIMING: When Domain Modeler Acts

**Domain modeler runs AFTER red and green steps, NOT DURING:**

1. Red-TDD-Tester fixes test code with compilation error
2. **THEN** Domain modeler reviews: "Can types prevent this?"
3. Domain modeler creates minimal type signatures with `unimplemented!()`
4. **THEN** Green-implementer fills in bodies
5. **THEN** Domain modeler reviews for primitive obsession

**NEVER** interleave domain modeling during red or green phases!

### Red Phase Review (AFTER Red Agent)

When Red-TDD-Tester writes a failing test, domain modeling agent must ask:

**"Can the type system prevent this failure?"**

- **If YES**: Create minimal nominal types (empty structs/enums) to replace primitives
- **If NO**: Proceed to Green Implementer
- **CRITICAL**: Create MINIMAL nominal types only - no speculative structure!
- **NEVER** add fields/methods without test demanding them
- **NEVER** add validation unless test demands it
- **NEVER** add smart behavior proactively
- Create signatures with `unimplemented!()` ONLY

### Post-Implementation Domain Review (AFTER Green Agent)

After Green Implementer makes test pass, domain modeling agent must check:

- **Primitive obsession**: Are we using primitives where nominal domain types should exist?
- **Correct use of existing domain types**: Are domain types being used properly?
- **Over-implementation**: Ensure no speculative fields/methods added beyond test needs
- **Over-smart types**: No validation/assertions not demanded by tests
- **If violations found**: Create minimal nominal types → Restart current PR's TDD cycle

### Critical Reminders for Domain Modeler

**YOU ARE A TYPE DESIGNER, NOT A CODE IMPLEMENTER**

- ❌ Do NOT implement function bodies
- ❌ Do NOT add validation unless tests fail without it
- ❌ Do NOT add convenience methods
- ❌ Do NOT anticipate future needs
- ✅ DO create type signatures only
- ✅ DO use `unimplemented!()` (or language equivalent) for all bodies
- ✅ DO let green-implementer write the actual code
- ✅ DO wait for test failures to drive features

## Key Principles Summary

1. **Workflow functions define intent** - they describe WHAT we want to do
2. **Compiler drives type creation** - only create types when compilation demands them
3. **Minimal types at first** - empty structs/enums until tests demand structure
4. **Parse, don't validate** - make illegal states unrepresentable
5. **Type system as documentation** - use types to make intent clear
6. **No speculative design** - only create what current story needs
7. **Let tests drive structure** - TDD reveals what types need inside them
8. **Comments on declarations only** - code should be self-documenting
