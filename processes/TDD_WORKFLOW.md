# TDD Workflow Process

## Dependency Resolution (When Needed)

**Trigger**: When TDD agents encounter missing dependencies

**Process**:
1. **Pause TDD Cycle**: Temporarily halt Red → Domain → Green process
2. **Call Dependency-Management**: Request specific dependency with purpose/context
3. **Dependency Resolution**: dependency-management agent adds dependency using appropriate tooling
4. **Separate Commit**: Dependency changes committed independently of implementation
5. **Resume TDD**: Continue with Red → Domain → Green cycle using new dependency

## Outside-In TDD with Hierarchical Chained PRs

### CRITICAL TDD COMPLETION RULES

- **Project MUST compile cleanly before any TDD round is considered complete**
- **ALL tests MUST pass before any TDD round is considered complete**
- **NEVER write new tests when build is failing OR any test is failing**
- **NEVER exit TDD cycle with failing build or failing tests**

### Hierarchical PR Structure

```
main
└── PR #1: Integration Test for Feature X
    ├── PR #2: Unit Test for Component A (chains off PR #1)
    │   └── PR #3: Unit Test for Helper Function (chains off PR #2)
    └── PR #4: Unit Test for Component B (chains off PR #1)
```

## Outside-In TDD Process

### 1. Integration Test PR

Create feature branch, write/refine integration test:
- Run test → hits first failure (unimplemented!() or assertion)
- Create PR #1 (stays open throughout feature development)

### 2. Drill Down with Skip Protocol

- Identify appropriate test scope for the failure
- **Create new branch** chaining off current branch
- **IMMEDIATELY mark parent test as skipped** with comment
- Write unit test at appropriate level
- Domain review → Can types prevent this?
- Green implementation if needed
- **Post-Implementation Domain Review**: Check for primitive obsession and type misuse
- Auto-commit when passing

### 3. Unskip Protocol Before Merge

- **MANDATORY**: Must unskip parent test before merging
- Verify parent test now progresses further (or passes)
- Create PR for review
- Merge child PR back to parent branch

### 4. Enhanced TDD Cycle per PR

#### Red-TDD-Tester: Write/refine failing test (ONE ASSERTION)

- **PREREQUISITE**: Project must compile cleanly and all other tests must pass
- **TEST WORKFLOW FUNCTIONS**: Focus on testing exported workflow functions from lib.rs, not pre-conceived type structures
- **ASSUME CODE EXISTS**: Write tests assuming the workflow functions you want exist, let compiler drive type creation
- **Property Testing**: Use property testing for domain type boundaries
- **Mutation Testing**: Add mutation score verification (≥80% for new code)

#### Domain Modeling Agent: Review test

**Question**: "Can type system prevent this failure?"

- **CRITICAL**: Create MINIMAL nominal types only - no speculative structure!
- If YES: Create minimal nominal types (empty structs/enums) to replace primitives
- If NO: Proceed to Green Implementer
- **NEVER** add fields/methods without test demanding them

#### Green Implementer: Make minimal change to pass ONE assertion

- **BUILD VERIFICATION**: MUST verify project compiles cleanly after changes
- **TEST VERIFICATION**: MUST verify ALL tests pass after changes

#### Post-Implementation Domain Review

Domain modeler checks implementation:
- Check for primitive obsession (using primitives where nominal domain types should exist)
- Verify correct use of existing domain types
- **Check for over-implementation**: Ensure no speculative fields/methods added beyond test needs
- If violations found: Create minimal nominal types → Restart current PR's TDD cycle

#### Auto-Commit Integration

ONLY when project compiles cleanly AND all tests pass AND domain review approves:
- Green implementer calls source-control agent
- Auto-commit with descriptive message including test that passed
- Auto-push to remote branch
- **MANDATORY**: Main coordinator MUST verify commit success independently

### 5. TDD Round Completion

Round complete ONLY when:
- Project compiles without errors or warnings
- ALL tests pass (no failing, no skipped tests remain)
- All temporary test skips have been resolved
- Domain review approves implementation
- **MANDATORY**: Main coordinator has personally verified ALL above conditions

## MANDATORY VERIFICATION PROTOCOL

**MAIN COORDINATOR AGENT MUST PERSONALLY VERIFY EVERY TDD ROUND COMPLETION**

### After EVERY Green Implementer and Source Control Agent Report

1. **NEVER TRUST AGENT REPORTS** - Always verify independently
2. **BUILD VERIFICATION**: Run `mcp__cargo__cargo_check` or `mcp__cargo__cargo_test` personally
3. **TEST VERIFICATION**: Confirm ALL tests pass by running tests yourself
4. **COMMIT VERIFICATION**: Run `mcp__git__git_status` to verify repository state
5. **CODE VERIFICATION**: Read actual implementation files to confirm changes

### TDD Round Completion Checklist (MANDATORY)

**✅ BEFORE marking ANY TDD round "complete":**
- [ ] **Personal build verification** - Run cargo test/check yourself
- [ ] **Personal test verification** - See "X passed; 0 failed" output yourself
- [ ] **Personal commit verification** - See "is_clean": true in git status yourself
- [ ] **Personal code verification** - Read the actual implementation yourself
- [ ] **Mutation testing verification** - Verify ≥80% mutation score for new code
- [ ] **Cognitive load verification** - Verify TRACE analysis passes before PR creation

### Violation Consequences

**If you proceed to next TDD round without personal verification:**
1. **IMMEDIATELY STOP** all work
2. **UNDO** any premature next-round work
3. **COMPLETE** the incomplete round properly
4. **UPDATE** system prompt to prevent recurrence

### Zero Exception Rule

**NEVER, UNDER ANY CIRCUMSTANCES, proceed to the next Red phase without:**
- Personal verification of build success
- Personal verification of all tests passing
- Personal verification of successful commit
- Personal confirmation repository is clean
- Personal verification of mutation testing compliance
- Personal verification of cognitive load compliance (for PR finalization)

**"Trust but verify" is WRONG - it should be "Never trust, always verify"**
