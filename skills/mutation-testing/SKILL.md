---
name: mutation-testing
description: Executes mutation testing to verify test suite quality and reports mutation score. Use when checking test effectiveness, validating ≥80% mutation score requirement, analyzing test coverage quality, or verifying tests actually catch bugs. Works with cargo-mutants for Rust and similar tools for other languages.
allowed-tools: [Bash, Read, BashOutput]
---

# Mutation Testing

Verifies test suite quality by introducing code mutations and checking if tests catch them.

## What is Mutation Testing?

Mutation testing validates that tests actually catch bugs by:

1. **Creating Mutants**: Making small changes to code (mutations)
2. **Running Tests**: Executing test suite against each mutant
3. **Checking Results**: Tests should FAIL for mutated code
4. **Scoring**: Percentage of mutants caught by tests

**Key Insight**: Code coverage shows which lines are executed. Mutation testing shows which lines are actually TESTED.

## When to Use Mutation Testing

- **Before PR creation**: Verify new code has effective tests (≥80% score required)
- **During TDD**: Validate that tests actually catch bugs
- **Code review**: Assess test quality objectively
- **Debugging weak tests**: Identify tests that pass even with broken code
- **Quality gates**: Enforce minimum test effectiveness standards

## Mutation Score Requirement

**Mandatory Threshold**: ≥80% mutation score for all new code

**What the score means:**
- **100%**: All mutants killed - perfect test coverage
- **80-99%**: Excellent - minor gaps acceptable
- **60-79%**: Good - but below threshold for new code
- **<60%**: Insufficient - tests don't effectively verify behavior

## Running Mutation Tests

### Rust (cargo-mutants)

**Full Project Analysis:**
```bash
cargo mutants
```

**Specific File:**
```bash
cargo mutants --file src/specific_file.rs
```

**With Timeout (for slow tests):**
```bash
cargo mutants --timeout 300  # 5 minutes per test
```

**JSON Output for Parsing:**
```bash
cargo mutants --output json
```

### Python (mutmut or cosmic-ray)

**mutmut:**
```bash
# Run mutation testing
mutmut run

# Show results
mutmut results

# Show specific mutants
mutmut show <id>
```

**cosmic-ray:**
```bash
cosmic-ray init config.toml session.sqlite
cosmic-ray exec session.sqlite
cosmic-ray report session.sqlite
```

### JavaScript/TypeScript (Stryker)

```bash
# Run mutation testing
npx stryker run

# With configuration
npx stryker run --config stryker.conf.json
```

## Interpreting Results

### Mutation Status Categories

**Caught (Killed)**:
- ✅ Mutation made test FAIL
- This is GOOD - test detected the bug

**Missed (Survived)**:
- ❌ Mutation made NO test fail
- This is BAD - test didn't catch the bug
- Indicates weak or missing tests

**Timeout**:
- ⏱️ Tests took too long (possible infinite loop)
- Often indicates mutation broke critical logic

**Unviable**:
- 🚫 Mutation prevented code from compiling
- Not counted in score

### Example Output Interpretation

```
Mutation Testing Report
=======================

Total Mutants: 50
Caught: 42
Missed: 6
Timeout: 1
Unviable: 1

Mutation Score: 87.5% (42/48 viable mutants caught)
Status: PASS (≥80%)
```

**This shows:**
- 42 mutations were caught by tests (good!)
- 6 mutations survived (tests need improvement)
- 1 caused timeout (might indicate broken logic detection)
- 1 was unviable (doesn't count)
- Score is 42/(42+6) = 87.5% (PASS)

## Common Mutation Types

### Replace with Default/Zero

```rust
// Original
fn calculate_discount(amount: f64) -> f64 {
    amount * 0.1
}

// Mutant
fn calculate_discount(amount: f64) -> f64 {
    amount * 0.0  // <-- Changed to zero
}
```

**If test passes**: Test doesn't verify actual discount calculation!

### Flip Boolean Conditions

```rust
// Original
if user.is_admin() {
    grant_access();
}

// Mutant
if !user.is_admin() {  // <-- Flipped condition
    grant_access();
}
```

**If test passes**: Test doesn't verify authorization logic!

### Remove Return Statements

```rust
// Original
fn validate(input: &str) -> Result<(), Error> {
    if input.is_empty() {
        return Err(Error::Empty);
    }
    Ok(())
}

// Mutant
fn validate(input: &str) -> Result<(), Error> {
    if input.is_empty() {
        // return removed!
    }
    Ok(())
}
```

**If test passes**: Test doesn't verify error handling!

### Change Operators

```rust
// Original
if count > 0 {
    process();
}

// Mutant
if count >= 0 {  // <-- Changed operator
    process();
}
```

**If test passes**: Test doesn't verify boundary conditions!

## Improving Mutation Score

### Strategy 1: Add Missing Assertions

**Problem**: Test runs code but doesn't verify outcomes

```rust
// WEAK TEST (might not catch mutations)
#[test]
fn test_process_user() {
    let user = create_user("John");
    process_user(&user);  // <-- No assertions!
}

// STRONG TEST (catches mutations)
#[test]
fn test_process_user() {
    let user = create_user("John");
    let result = process_user(&user);
    assert_eq!(result.name, "John");
    assert!(result.is_processed);
}
```

### Strategy 2: Test Edge Cases

**Problem**: Only testing happy path

```rust
// Add tests for:
- Empty inputs
- Boundary values (0, 1, max)
- Invalid inputs
- Error conditions
```

### Strategy 3: Property-Based Testing

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn test_parse_always_validates(s in ".*") {
        match parse(&s) {
            Ok(parsed) => assert!(is_valid(&parsed)),
            Err(_) => {} // Rejection is fine
        }
    }
}
```

### Strategy 4: Verify All Branches

```rust
// Test ALL branches
#[test]
fn test_permission_check_admin() {
    let admin = User::admin();
    assert!(can_access(&admin)); // <-- Admin branch
}

#[test]
fn test_permission_check_regular() {
    let user = User::regular();
    assert!(!can_access(&user)); // <-- Regular branch
}
```

## Quality Gates Integration

### Pre-PR Check

Before creating PR:

```bash
# Run mutation tests on changed files
cargo mutants --file src/new_feature.rs

# Verify score ≥80%
# If FAIL: Add/improve tests until passing
```

### CI/CD Integration

```yaml
# .github/workflows/test.yml
- name: Mutation Testing
  run: |
    cargo mutants --check
    # Fails if score <80%
```

## Troubleshooting

### "Mutation testing too slow"

**Solution**: Target specific files or use timeouts

```bash
# Only test new code
cargo mutants --file src/new_module.rs

# Use shorter timeout
cargo mutants --timeout 60
```

### "Too many survived mutants"

**Solution**: Add assertions to verify behavior

1. Review survived mutants: What changed?
2. Write tests that would fail with those changes
3. Re-run mutation testing
4. Repeat until ≥80% score

### "Tests timeout with mutants"

**Solution**: Usually indicates mutation broke critical logic (GOOD!)

- Timeouts often count as "caught"
- But review to ensure not actual infinite loop in tests

## Task Completion Protocol

When invoked for mutation testing:

1. **Identify scope**: Which files/modules to test?
2. **Run mutation tests**: Execute appropriate tool (cargo-mutants, mutmut, Stryker)
3. **Parse results**: Extract score and survived mutants
4. **Determine PASS/FAIL**: Apply ≥80% threshold
5. **If FAIL**: Identify specific survived mutants
6. **Provide remediation**: Specific tests needed to improve score
7. **Return report**: Clear PASS/FAIL with score and recommendations

## Example Report Format

```
Mutation Testing Report
=======================

Scope: src/authentication.rs
Tool: cargo-mutants
Execution Time: 45s

Results:
- Total Viable Mutants: 25
- Caught: 22
- Survived: 3
- Mutation Score: 88%

Status: PASS (≥80% required)

Survived Mutants:
1. Line 42: Changed || to && in permission check
2. Line 67: Removed error return in validation
3. Line 93: Changed 0.1 to 0.0 in calculation

Recommendations:
✅ Overall score meets threshold
⚠️ Consider adding tests for lines 42, 67, 93 to achieve 100%
```

Remember: Mutation testing is the ultimate test of your tests. If your tests don't fail when code is broken, they're not really testing anything.
