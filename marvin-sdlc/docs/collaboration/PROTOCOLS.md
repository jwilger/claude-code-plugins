# Collaboration Protocols

How agents and users collaborate during development.

## The Pair-Programming Model

Development is a collaboration between AI agents and the user. The user:
- Has final authority on all decisions
- Can modify any proposed changes
- Provides domain expertise and business context
- Approves or rejects agent output

Agents:
- Propose changes, don't dictate
- Explain reasoning
- Ask for clarification when uncertain
- Re-read files after user approval to see actual changes

## QUESTION: Comment Mechanism

Users can add inline questions to proposed changes. Agents must:
1. Look for `QUESTION:` comments after user approves changes
2. Answer each question
3. Update code based on answers
4. Remove the `QUESTION:` prefix once resolved

### In Code

```rust
#[test]
fn test_payment_capture() {
    let amount = Money::new(100, Currency::USD);
    // QUESTION: Should we also test negative amounts here or in a separate test?
    assert!(capture_payment(amount).is_ok());
}
```

Agent sees this after approval, answers the question, and removes the comment:

```rust
#[test]
fn test_payment_capture() {
    let amount = Money::new(100, Currency::USD);
    // Negative amounts tested in test_rejects_negative_payment_amount
    assert!(capture_payment(amount).is_ok());
}
```

### In Documentation

```markdown
## Event: PaymentCaptured

### Data Fields
- transaction_id: String
QUESTION: Should this be a UUID or allow arbitrary strings?
- amount: Money
```

Agent answers and updates:

```markdown
## Event: PaymentCaptured

### Data Fields
- transaction_id: TransactionId  // UUID format enforced by type
- amount: Money
```

### Rules for QUESTION: Comments

1. **Never leave in committed code** - All questions must be resolved before commit
2. **Agent must re-read file** - After user approval, read the file to see questions
3. **Answer inline** - Provide brief answer, then update code accordingly
4. **Ask for clarification** - If question is unclear, use AskUserQuestion

## IDE Diff Modification Flow

When agents propose file changes:

1. **Agent proposes change** - Uses Write or Edit tool
2. **User sees diff in IDE** - Can review, modify, or reject
3. **User approves (possibly modified)** - Accepts the change
4. **Agent re-reads file** - Sees what was actually written
5. **Agent acknowledges modifications** - If user changed something, agent notes it:
   - "I see you changed X to Y. That makes sense because..."
   - "I notice you preferred X. I'll use that pattern going forward."
6. **Agent looks for QUESTION: comments** - Answers any inline questions
7. **Iterate if needed** - Continue until file is correct

### Example Flow

**Agent proposes:**
```rust
pub fn calculate_fee(amount: Money) -> Money {
    amount * 0.03  // 3% fee
}
```

**User modifies before accepting:**
```rust
pub fn calculate_fee(amount: Money) -> Money {
    // QUESTION: Should fees be capped at some maximum?
    amount * FEE_PERCENTAGE  // Use constant instead of magic number
}
```

**Agent re-reads and responds:**
"I see you extracted the magic number to a constant - good call for maintainability.
Regarding capping fees: yes, many payment systems cap fees. Should we add a
`MAX_FEE` constant? What's the appropriate cap for your domain?"

## Re-Read After Approval Protocol

**CRITICAL:** Agents must ALWAYS re-read files after user approval.

Why:
- User may have modified the proposed changes
- User may have added QUESTION: comments
- User may have fixed bugs or improved code
- Agent needs to see the ACTUAL file state, not what was proposed

When:
- After every file write/edit that user approves
- Before making dependent changes
- Before reporting completion

How:
```
1. Agent: [proposes change with Write/Edit tool]
2. User: [approves, possibly with modifications]
3. Agent: [MUST use Read tool on the file]
4. Agent: [acknowledge any changes, answer questions]
5. Agent: [continue with accurate file state]
```

## When to Use AskUserQuestion

Use AskUserQuestion when:
- Multiple valid approaches exist
- Business rules are unclear
- Trade-offs need user input
- Assumptions need validation
- User preference matters

Don't use when:
- Technical question with clear answer
- Question is already answered in docs/context
- Decision doesn't significantly impact outcome

## Commit Boundaries

Commits happen at:
- End of each passing TDD cycle (green phase)
- After refactoring (if tests pass)
- After ADR acceptance
- After story completion

Never commit:
- With failing tests
- With unresolved QUESTION: comments
- With dead code warnings
- Mid-change (partial work)
