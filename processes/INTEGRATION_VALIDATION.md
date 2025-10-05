# Integration Validation Process

## Purpose

Ensures implemented features are actually accessible to end users through the application's user interface, not just accessible through library APIs and tests.

## Core Principle

**A feature is NOT complete until users can access it through the application entry point.**

Testing that library functions work is NECESSARY but NOT SUFFICIENT. Features must be wired into main.rs (or equivalent application entry point) to be considered complete.

## Application Types and Integration Points

### CLI Applications (Terminal/Command-Line)

- **Entry Point**: `src/main.rs` or equivalent
- **Integration Method**: main() function calls feature code
- **Verification**: Run `cargo run` (or equivalent) and verify feature accessible via:
  - Command-line arguments (`./app --feature`)
  - Interactive prompts (user types commands)
  - Automatic execution (app runs feature on startup)

### Web Applications

- **Entry Point**: HTTP routes/endpoints
- **Integration Method**: Route handlers call feature code
- **Verification**: Start server and make HTTP requests to feature endpoints

### GUI Applications

- **Entry Point**: UI event handlers
- **Integration Method**: Button clicks/menu selections call feature code
- **Verification**: Launch GUI and interact with UI elements

### Library Crates

- **Entry Point**: Public API (`lib.rs` pub functions/types)
- **Integration Method**: Feature exposed through public API
- **Verification**: External code can import and use feature

## Integration Verification Protocol

### For Each Story (Phase 7 N.8 - Story Completion)

1. **Identify Application Type** (from REQUIREMENTS_ANALYSIS.md or ARCHITECTURE.md)
2. **Check Entry Point Integration**:
   - For CLI: Verify main.rs calls the feature code
   - For Web: Verify routes wired to feature handlers
   - For GUI: Verify UI elements connected to feature code
   - For Library: Verify feature exported in public API

3. **Manual Testing**:
   - Provide EXACT command user runs to access feature
   - Run the command yourself to verify it works
   - Document the test in story completion notes

4. **Integration Commit**:
   - Integration with entry point must be separate commit
   - Commit message: "feat: integrate [feature] with [entry point]"
   - Include manual testing evidence in commit message

### For Phase 8 (Acceptance Validation)

1. **Verify ALL completed stories** have entry point integration
2. **Provide manual testing guide** for entire feature set
3. **BLOCK acceptance** if any feature not accessible to users

## Story Template Requirements

Every story MUST include:

```markdown
**Integration Point:** [Where feature connects to user interface]
- CLI Application: main.rs argument/prompt handling
- Web Application: Route path and HTTP method
- GUI Application: Menu/button that triggers feature
- Library: Public API function signature

**User Access Method:** [How user invokes feature]
- CLI: Command-line example (e.g., `cargo run -- --single-player`)
- Web: HTTP request example (e.g., `POST /api/games`)
- GUI: User interaction (e.g., "Click File → New Game")
- Library: Code example (e.g., `use mylib::start_game;`)

**Manual Testing:**
1. [Step-by-step instructions for human to test feature]
2. [Expected observable outcome]
3. [Success criteria]
```

## Common Integration Failures

### "Works in Tests But Not in Application"

- **Symptom**: All tests pass, library functions work, but running app shows "Hello, world!" or doesn't expose feature
- **Root Cause**: main.rs never calls the library functions
- **Fix**: Update main.rs to wire feature into application entry point

### "Feature Partially Accessible"

- **Symptom**: Feature works manually but not via intended interface (e.g., works with hardcoded values but not CLI args)
- **Root Cause**: Integration code incomplete or incorrect
- **Fix**: Complete integration layer (argument parsing, route handling, etc.)

### "Library Without Consumer"

- **Symptom**: Perfect library implementation but no way for users to call it
- **Root Cause**: Building library when should build application, or missing public API
- **Fix**: Either create application layer (main.rs) or expose public API (lib.rs pub exports)

## Blocking Conditions

**Story CANNOT be marked complete** until:

- Feature accessible through documented integration point
- Manual testing instructions provided
- Main agent personally verified feature accessible (not just trusting agent reports)

**Acceptance validation CANNOT pass** until:

- ALL completed stories have verified integration
- Manual testing guide complete for entire feature set
- Main agent personally tested at least one feature end-to-end

## Memory Storage

Store integration verification results:

- Entity: IntegrationVerification
- Relations: "verifies-integration-of" → Story
- Observations: Manual testing command, expected outcome, actual outcome, verification timestamp
