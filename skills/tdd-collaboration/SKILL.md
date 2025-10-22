---
name: tdd-collaboration
description: Guides collaborative test-driven development with user during Phase 7 (Story-by-Story Core Loop). Facilitates pair-programming on test and implementation code using IDE diff modification flow and QUESTION: comments. Enforces Red → Domain → Green cycle.
allowed-tools: [Read, Edit, Write, Glob, Grep, mcp__memento__create_entities, mcp__memento__create_relations, mcp__memento__add_observations, mcp__memento__semantic_search, mcp__memento__open_nodes, mcp__time__get_current_time, AskUserQuestion, Bash, mcp__cargo__cargo_check, mcp__cargo__cargo_test, mcp__pytest__execute_tests]
---

# TDD Collaboration Skill

Guides main conversation on how to collaborate with user during Phase 7: Test-Driven Development (Story-by-Story Core Loop).

## Core Principle

**User is co-creator of tests and implementation, not reviewer of AI-generated code.**

## Critical TDD Rules

**ONLY IMPLEMENT WHAT THE TEST FAILURE DEMANDS:**

- Red phase: Write ONE test with ONE assertion
- Domain phase: Create minimal types to make test compile
- Green phase: Make ONLY that test pass
- NO anticipatory implementation
- NO extra features beyond test requirements
- Delete dead code immediately

**See `~/.claude/processes/TDD_WORKFLOW.md` for complete TDD process.**

## Collaboration Protocol

### 1. Red Phase Collaboration (Test Writing)

**Advisory Agent: red-tdd-tester**

1. Call red-tdd-tester agent for test recommendations
2. Agent analyzes story and returns test approach (NO file editing)
3. Main conversation receives test recommendation

**Collaborative Test Creation:**

1. **Propose test code**:
   - Present one test with one assertion
   - Use IDE diff modification
   - User reviews, can modify directly

2. **Acknowledge user modifications**:
   - "I see you changed the assertion to X. That's more specific because..."
   - "I understand you want to test Y. Consider that..."
   - Engage in dialogue about test design

3. **Answer QUESTION: comments in test code**:
   ```rust
   #[test]
   fn test_payment_capture() {
       let amount = MonetaryAmount::new(100, Currency::USD);
       // QUESTION: Should we also test negative amounts here or separately?
       assert_eq!(amount.value(), 100);
   }
   ```

4. **Iterate until test is correct**:
   - User approves test approach
   - Test compiles (may fail - expected)
   - Move to Domain phase

### 2. Domain Modeling Phase Collaboration

**Advisory Agent: [language]-domain-model-expert**

1. Call appropriate domain-modeling agent for type recommendations
2. Agent analyzes test failures and recommends types (NO file editing)
3. Main conversation receives type design recommendations

**Collaborative Type Creation:**

1. **Propose type definitions**:
   - Present minimal type signatures with `unimplemented!()`
   - Use IDE diff modification
   - User reviews, can modify types directly

2. **Acknowledge user modifications**:
   - "I see you added constraint X. That prevents..."
   - "I understand you want type Y. Consider that..."
   - Engage in dialogue about type design

3. **Answer QUESTION: comments in types**:
   ```rust
   pub struct MonetaryAmount {
       value: u64,
       currency: Currency,
       // QUESTION: Should we enforce minimum transaction amounts at the type level?
   }
   ```

4. **Iterate until types compile**:
   - User approves type design
   - Code compiles cleanly
   - Move to Green phase

### 3. Green Phase Collaboration (Implementation)

**Advisory Agent: green-implementer**

1. Call green-implementer agent for minimal implementation recommendations
2. Agent analyzes test failure and returns implementation approach (NO file editing)
3. Main conversation receives implementation recommendation

**Collaborative Implementation:**

1. **Propose minimal implementation**:
   - ONLY what makes test pass
   - NO extra features
   - Use IDE diff modification

2. **Acknowledge user modifications**:
   - "I see you simplified to X. That's more minimal because..."
   - "I understand you want Y. But the test only requires X..."
   - Engage in dialogue about minimal implementation

3. **Answer QUESTION: comments in code**:
   ```rust
   impl MonetaryAmount {
       pub fn new(value: u64, currency: Currency) -> Self {
           // QUESTION: Should we validate value > 0 now or wait for test to demand it?
           Self { value, currency }
       }
   }
   ```

4. **Iterate until test passes**:
   - User approves implementation
   - Test passes
   - All tests pass
   - Project compiles cleanly
   - Ready for next Red cycle or commit

### 4. Post-Implementation Domain Review

**After Green phase:**

1. Domain-modeling agent reviews for:
   - Primitive obsession
   - Type misuse
   - Over-implementation

2. If issues found:
   - Present findings to user
   - Collaborate on type improvements
   - Restart TDD cycle if types change

3. If approved:
   - Commit changes (via git-operations skill)
   - Move to next test

### 5. Memento Integration

**Record TDD decisions:**

```json
{
  "entities": [{
    "name": "TDD Decision: [Topic]",
    "entityType": "tdd_decision",
    "observations": [
      "Project: [project] | Scope: PROJECT_SPECIFIC",
      "Test: [test name]",
      "Decision: [what approach was chosen]",
      "Rationale: [why user chose this]",
      "Phase: [Red|Domain|Green]",
      "Date: [timestamp]"
    ]
  }]
}
```

### 6. TDD Round Completion

**MANDATORY before moving to next Red phase:**

- ✅ Project compiles cleanly (personal verification)
- ✅ ALL tests pass (personal verification)
- ✅ No dead code (deleted immediately)
- ✅ Domain review approved
- ✅ Changes committed via git-operations skill
- ✅ User approved implementation

**NEVER proceed without personal verification of build and tests.**

## QUESTION: Comment Examples

### In Test Code

```rust
#[test]
fn test_concurrent_deposits() {
    // QUESTION: Should we use tokio::spawn for concurrency or is async/await sufficient?
    let account = Account::new();
    // ... test code
}
```

### In Type Definitions

```rust
pub struct UserId(Uuid);

// QUESTION: Should we implement FromStr for parsing user IDs from strings?
```

### In Implementation

```rust
impl EventStore {
    pub fn append(&mut self, event: Event) -> Result<(), StoreError> {
        // QUESTION: Should we add idempotency check here or wait for test to require it?
        self.events.push(event);
        Ok(())
    }
}
```

## Collaboration Anti-Patterns

❌ **Don't**: Write multiple tests and full implementation autonomously
✅ **Do**: ONE test, collaborate, ONE implementation, iterate

❌ **Don't**: Add features not demanded by tests
✅ **Do**: ONLY implement what test failure requires

❌ **Don't**: Skip domain modeling phase
✅ **Do**: Create types collaboratively before implementation

❌ **Don't**: Trust agent reports of build/test success
✅ **Do**: Personally verify EVERY build and test run

❌ **Don't**: Keep dead code "for later"
✅ **Do**: Delete immediately - tests will demand it if needed

## Three-Phase TDD Cycle

**Red (Test):**
- red-tdd-tester recommends
- Main conversation collaborates with user
- ONE test with ONE assertion
- Test may not compile (expected)

**Domain (Types):**
- domain-model-expert recommends
- Main conversation collaborates with user
- Minimal types to make test compile
- Types use `unimplemented!()` for bodies

**Green (Implementation):**
- green-implementer recommends
- Main conversation collaborates with user
- ONLY what makes test pass
- No anticipatory features

**Repeat until story complete.**

## Success Criteria

TDD collaboration is successful when:

- User feels ownership of tests and code (co-created, not reviewed)
- Each test has exactly ONE assertion
- Implementation is minimal (only what tests demand)
- No dead code exists (deleted immediately)
- Types prevent failures at compile-time where possible
- User personally verified build and tests after each cycle
- Changes committed after each successful cycle
- Key decisions documented in memento

## Integration with Other Skills

**After TDD complete for story:**

1. Use trace-analysis skill to verify cognitive complexity
2. Use mutation-testing skill to verify test quality (≥80%)
3. Use git-operations skill for PR creation
4. Update beads issue to close story

**If dependencies needed during TDD:**

1. Use dependency-management skill (NEVER edit manifest files directly)
2. Resume TDD after dependency added
