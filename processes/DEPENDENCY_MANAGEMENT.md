# Dependency Management Protocol

## CRITICAL: NEVER Directly Edit Dependency Files

**This is a MANDATORY protocol for ALL agents across ALL phases.**

### Forbidden Actions

**NEVER do these:**
- ❌ Directly edit `Cargo.toml` (Rust)
- ❌ Directly edit `pyproject.toml` or `requirements.txt` (Python)
- ❌ Directly edit `package.json` (Node.js)
- ❌ Directly edit any other dependency manifest file
- ❌ Manually run `cargo add`, `uv add`, `npm install`, etc.

### Required Actions

**ALWAYS do this instead:**
1. **STOP** when you identify need for external dependency
2. **PAUSE** your current work
3. **CALL** the dependency-management agent with:
   - Specific dependency name
   - Purpose/context for why it's needed
   - Any specific version requirements (rare)
   - Any feature flags needed (be specific)
4. **WAIT** for dependency-management agent to complete
5. **RESUME** your work with dependency available

## Why This Protocol Exists

### 1. Latest Compatible Versions
Platform tools (`cargo add`, `uv add`, `npm install`) automatically determine the latest compatible versions. Manual edits bypass this intelligence.

### 2. Minimal Feature Flags (Rust)
`cargo add` allows specifying minimal feature sets, reducing:
- Binary size
- Attack surface area
- Compilation time
- Dependency tree complexity

Example:
```bash
# CORRECT: Minimal features
cargo add serde --no-default-features --features derive

# WRONG: Manual edit gets all features by default
[dependencies]
serde = "1.0"  # ← Gets ALL features
```

### 3. Dependency Resolution
Platform tools handle:
- Transitive dependency conflicts
- Version compatibility checking
- Feature unification across workspace
- Platform-specific dependencies

### 4. Separate Commit Discipline
Dependency changes should be committed separately from application code:
- Clear change attribution
- Easier dependency audits
- Simpler rollbacks if needed
- Better code review separation

## Integration Points

### Phase 7 N.6: Domain Modeling

**Scenario**: Domain modeling agent needs `thiserror` for error types

```rust
// Agent writes this and realizes it needs thiserror:
#[derive(Debug, thiserror::Error)]  // ← Compiler will fail
pub enum AppError {
    #[error("Configuration error: {0}")]
    ConfigError(String),
}
```

**CORRECT Protocol**:
1. Domain agent STOPS and PAUSES domain modeling work
2. Domain agent CALLS dependency-management agent:
   - "Need `thiserror` dependency for error type implementation"
   - "Latest stable version"
   - "Default features sufficient"
3. dependency-management agent runs `cargo add thiserror`
4. dependency-management agent commits separately
5. Domain agent RESUMES with dependency available

**VIOLATION (what happened in Story 1)**:
- Domain agent directly edited Cargo.toml
- Added `thiserror = "2.0"` manually
- Attempted to commit with code changes
- User correctly stopped the violation

### Phase 7 N.7: TDD Implementation

**Scenario**: Test or implementation needs external crate

**CORRECT Protocol**:
1. TDD agent (red or green) identifies missing dependency
2. TDD agent PAUSES TDD cycle (don't write more tests)
3. TDD agent CALLS dependency-management agent
4. dependency-management agent adds dependency and commits
5. TDD agent RESUMES TDD cycle with dependency available

**Common TDD Dependencies**:
- `mockall` for mocking (testing)
- `proptest` for property-based testing
- `criterion` for benchmarking
- `tokio` features (e.g., `--features macros,rt-multi-thread`)

### DevOps and Infrastructure

**Scenario**: Build tools, CI/CD utilities, dev dependencies

**CORRECT Protocol**:
Same as above - ALWAYS call dependency-management agent

## The dependency-management Agent's Responsibilities

When called, the dependency-management agent will:

1. **Research**: Verify dependency exists and is appropriate
2. **Add**: Use platform-appropriate tooling:
   - Rust: `cargo add <crate> [--features ...] [--no-default-features]`
   - Python: `uv add <package>` or pip equivalent
   - Node.js: `npm install <package>` or `pnpm add <package>`
3. **Verify**: Ensure dependency resolves cleanly (no conflicts)
4. **Commit**: Separate commit with clear message explaining purpose
5. **Report**: Return control with dependency available

## Error Recovery

**If you've already edited a dependency file:**

1. **STOP immediately** - don't commit
2. **REVERT** the manual changes
3. **CALL** dependency-management agent properly
4. **LEARN** from the violation (update memory)

## Examples

### Example 1: Rust Error Handling

```rust
// BEFORE: Need thiserror for error types
// Domain agent identifies: "I need thiserror to implement AppError"

// STOP and CALL dependency-management:
// "Need thiserror crate for custom error type implementation in Story 1.
//  Latest stable version.
//  Default features are sufficient."

// AFTER dependency-management completes:
#[derive(Debug, thiserror::Error)]
pub enum AppError {
    #[error("Configuration error: {0}")]
    ConfigError(String),
}
// ✅ Now compiles, dependency added correctly
```

### Example 2: Rust Async Runtime Features

```rust
// BEFORE: Need tokio with specific features
// Domain agent identifies: "I need tokio with macros and rt-multi-thread"

// STOP and CALL dependency-management:
// "Need tokio crate for async runtime in Story 1.
//  Latest stable version.
//  Features needed: macros, rt-multi-thread
//  No default features."

// AFTER dependency-management completes:
#[tokio::main]
async fn main() { }
// ✅ Now compiles with minimal tokio features
```

### Example 3: Python Type Checking

```python
# BEFORE: Need pydantic for domain types
# Domain agent identifies: "I need pydantic for validated domain models"

# STOP and CALL dependency-management:
# "Need pydantic package for Parse Don't Validate domain types in Story 2.
#  Latest stable version (v2.x preferred).
#  Standard features sufficient."

# AFTER dependency-management completes:
from pydantic import BaseModel

class UserConfig(BaseModel):
    name: str
    email: str
# ✅ Now works, dependency added correctly
```

## Memory Pattern

**When violations occur**, store this pattern:

```
Entity: "Dependency Management Violation - [Agent] - [Date]"
Observations:
- Agent: [which agent violated]
- Violation: Directly edited [dependency file]
- Project: [project path]
- Correction: Called dependency-management agent properly
- Lesson: NEVER edit dependency files - ALWAYS use dependency-management agent
```

## Quick Reference Card

**Agent identifies need for dependency:**

```
❌ DON'T: Edit Cargo.toml/package.json/pyproject.toml
✅ DO: Call dependency-management agent

❌ DON'T: Run cargo add/npm install yourself
✅ DO: Call dependency-management agent

❌ DON'T: Commit dependency changes with code
✅ DO: Separate commits (dependency-management agent handles this)

❌ DON'T: Guess at versions or features
✅ DO: Let dependency-management agent research and determine optimal configuration
```

## Rationale Summary

This protocol ensures:
- ✅ Latest compatible versions automatically selected
- ✅ Minimal feature flags reduce binary size and attack surface
- ✅ Proper dependency resolution and conflict handling
- ✅ Separate commits for clear change attribution
- ✅ Consistent approach across all languages and platforms
- ✅ Platform-specific best practices applied correctly

**Remember**: Editing dependency files directly is like editing `.git/` directly - technically possible, catastrophically wrong.
