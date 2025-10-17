---
name: trace-analysis
description: Analyzes code cognitive complexity using TRACE framework (Type-first, Readability, Atomic scope, Cognitive budget, Essential only). Use when analyzing code maintainability, checking complexity violations, evaluating PR cognitive load, or assessing code quality. Enforces ≥70% overall score and ≥50% per dimension thresholds.
allowed-tools: [Read, Grep, Glob, Bash, mcp__memento__create_entities, mcp__memento__create_relations, mcp__memento__add_observations, mcp__memento__semantic_search, mcp__memento__open_nodes, mcp__memento__read_graph, mcp__time__get_current_time, BashOutput, WebFetch, WebSearch]
---

# TRACE Framework Analysis

Evaluates cognitive complexity and maintainability of code changes using the TRACE decision framework.

## TRACE Framework

Every code change is evaluated across five dimensions:

**T**ype-first thinking - Can the type system prevent this bug entirely?
**R**eadability check - Would a new developer understand this in 30 seconds?
**A**tomic scope - Is the change self-contained with clear boundaries?
**C**ognitive budget - Does understanding require holding multiple files in your head?
**E**ssential only - Is every line earning its complexity cost?

## Analysis Process

### 1. Initial Memory Loading

Before analyzing any code:

1. Call `mcp__time__get_current_time` for temporal anchoring
2. Use semantic_search to find relevant complexity patterns
3. Use open_nodes to explore relationships between complexity decisions
4. Review past cognitive load violations and their resolutions

### 2. Code Analysis

For each changed file, evaluate all five TRACE dimensions:

#### T - Type-First Thinking (25% weight)

**Question**: "Can the type system prevent this bug entirely?"

- **PASS (80-100)**: New logic encoded in types, minimal runtime validation
- **GOOD (60-79)**: Most validation in types, some necessary runtime checks
- **FAIR (50-59)**: Mixed type/runtime validation
- **FAIL (<50)**: Runtime checks for type-preventable conditions

**Examples**:
- ✅ Branded types for domain primitives (UserId, Email)
- ✅ Sum types for state machines
- ✅ Phantom types for typestate pattern
- ❌ String validation in function bodies
- ❌ Manual bounds checking for numeric ranges

#### R - Readability Check (25% weight)

**Question**: "Would a new developer understand this in 30 seconds?"

- **PASS (80-100)**: Self-documenting, clear naming, obvious flow
- **GOOD (60-79)**: Mostly clear, minor clarifications needed
- **FAIR (50-59)**: Requires some study to understand
- **FAIL (<50)**: Requires deep context or multiple mental mappings

**Metrics**:
- Function length ≤15 lines (excluding signatures)
- Variable naming clarity
- Control flow complexity (nesting ≤3 levels)
- Clear separation of concerns

#### A - Atomic Scope (20% weight)

**Question**: "Is the change self-contained with clear boundaries?"

- **PASS (80-100)**: Single responsibility, clear interfaces, minimal coupling
- **GOOD (60-79)**: Focused responsibility with some coupling
- **FAIR (50-59)**: Mixed responsibilities but bounded
- **FAIL (<50)**: Touches multiple concerns or creates hidden dependencies

**Metrics**:
- Single responsibility principle
- Clear module boundaries
- Explicit dependencies
- Interface clarity

#### C - Cognitive Budget (20% weight)

**Question**: "Does understanding require holding multiple files in your head?"

- **PASS (80-100)**: ≤2 files to understand, ≤5 concepts per function
- **GOOD (60-79)**: 3 files, ≤7 concepts
- **FAIR (50-59)**: 3 files, 7-9 concepts
- **FAIL (<50)**: >3 files or >9 concepts

**Metrics**:
- Cross-file references ≤3 files
- Concept count ≤7 per function (Miller's magic number)
- Nesting depth ≤3 levels
- Parameter count ≤4

#### E - Essential Only (10% weight)

**Question**: "Is every line earning its complexity cost?"

- **PASS (80-100)**: Every line adds essential business value
- **GOOD (60-79)**: Mostly essential, minor optimization
- **FAIR (50-59)**: Some unnecessary abstraction
- **FAIL (<50)**: Accidental complexity, premature optimization, dead code

**Metrics**:
- Code-to-value ratio
- Abstraction necessity
- No dead code or unused variables
- Minimal premature optimization

### 3. Calculate Overall Score

```
Overall TRACE Score = (T * 0.25) + (R * 0.25) + (A * 0.20) + (C * 0.20) + (E * 0.10)
```

### 4. Quality Gates

**PASS Conditions:**
- Overall TRACE score ≥70%
- All TRACE dimensions ≥50%
- Functions within complexity thresholds
- PR understandable with ≤3 files

**FAIL Conditions (Block PR):**
- Overall TRACE score <70%
- Any TRACE dimension <50%
- Function exceeds cognitive complexity thresholds
- PR requires >3 files to understand
- Primitive obsession in new code

## Complexity Thresholds

### Function-Level

- Cyclomatic complexity: ≤10
- Function length: ≤15 lines (excluding signatures)
- Parameter count: ≤4
- Nesting depth: ≤3 levels
- Concept count: ≤7 per function

### File-Level

- Lines of code: ≤250 per file
- Public interface: ≤10 public methods/functions
- Dependencies: ≤8 imports
- Single responsibility principle

### PR-Level

- Files changed: ≤5 per PR
- Lines changed: ≤200 per PR
- Cognitive files: ≤3 files to understand change
- Single domain concept per PR

## Remediation Recommendations

### Type-First Violations (T)

- Move runtime validation to type constructors
- Use branded types for domain primitives
- Encode business rules in type definitions
- Replace runtime checks with type constraints

### Readability Violations (R)

- Extract functions for complex operations
- Improve variable and function naming
- Reduce nesting through early returns
- Add type annotations for clarity

### Atomic Scope Violations (A)

- Split mixed responsibilities into separate functions
- Extract shared logic to pure functions
- Reduce coupling through dependency injection
- Define clear module boundaries

### Cognitive Budget Violations (C)

- Break large functions into smaller ones
- Reduce file coupling and cross-references
- Extract complex logic to helper functions
- Use composition over inheritance

### Essential Complexity Violations (E)

- Remove dead code and unused variables
- Eliminate premature optimizations
- Replace complex abstractions with simple ones
- Remove accidental complexity

## Analysis Report Format

```
TRACE Analysis Report
=====================

Overall Score: X%
Status: PASS/FAIL

Dimension Breakdown:
- Type-First (25%):     X%  [PASS/FAIL]
- Readability (25%):    X%  [PASS/FAIL]
- Atomic Scope (20%):   X%  [PASS/FAIL]
- Cognitive Budget (20%): X%  [PASS/FAIL]
- Essential Only (10%):  X%  [PASS/FAIL]

Files Analyzed:
- file1.rs: Score X%
- file2.rs: Score X%

Violations Found:
1. [Specific violation with location]
2. [Specific violation with location]

Remediation Steps:
1. [Specific actionable step]
2. [Specific actionable step]

Conclusion: [PASS and approve PR / FAIL and block PR until remediation]
```

## Memory Storage

After each analysis, store in memento:

- TRACE scores and breakdowns
- Complexity threshold violations
- Remediation patterns that worked
- Project-specific complexity preferences
- Evolution of cognitive load standards

**Example**:
```
Entity: "TRACE Analysis - [PR/Feature Name] - [Date]"
Observations:
  - "Project: [name] | Overall Score: X%"
  - "Type-First: X% | Readability: X% | Atomic: X% | Cognitive: X% | Essential: X%"
  - "Status: PASS/FAIL"
  - "Key Violations: [list]"
  - "Remediation Applied: [list]"
```

## Task Completion Protocol

When invoked for TRACE analysis:

1. **Load memory context** - Find past analyses and patterns
2. **Identify files to analyze** - Get git diff or specific files
3. **Evaluate each TRACE dimension** - Systematic scoring
4. **Calculate overall score** - Weighted average
5. **Apply quality gates** - PASS/FAIL determination
6. **Generate remediation** - Specific, actionable steps if FAIL
7. **Store results in memory** - For future reference
8. **Return comprehensive report** - With clear PASS/FAIL status

Remember: Code is read far more than it's written. Every complexity decision affects maintainability for years to come.
