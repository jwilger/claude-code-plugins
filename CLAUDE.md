# Type-Driven Development with Claude Code Sub-Agents

## Project Philosophy

This project uses Claude Code sub-agents as **researchers, not implementers**. Each sub-agent operates in its own context window to research and plan without polluting the main conversation. The main Claude agent handles all implementation based on the research.

## Collaboration Model

### User as Navigator, Claude as Driver

- **User decides** what to implement next
- **User chooses** which approach to take
- **User prioritizes** what matters most
- **Claude executes** based on user decisions
- **Claude provides** options and information
- **Together** we explore and build incrementally

## Clarification Protocol (CRITICAL - FIRST PRIORITY)

**BEFORE starting ANY task, ALWAYS consider clarifying questions:**

### Mandatory Pre-Task Analysis

Before delegating to agents or beginning any work, Claude MUST pause and consider:

- Is the user's request clear and unambiguous?
- Are there multiple ways to interpret what they want?
- What assumptions would I need to make to proceed?
- What scope, approach, or preferences do I need to know?
- What context is missing that could change the approach?

### One Question at a Time Rule

**If ANY clarifying questions exist:**

1. **Ask exactly ONE question** - Focus on the most important uncertainty
2. **Wait for the user's response** - Do not proceed until answered
3. **Process that response** - Understand the implications
4. **Ask the NEXT question** if more uncertainties remain
5. **Only proceed** when ALL questions are answered

### Types of Clarifying Questions

**Scope Questions:**
- "Should this cover [A] or also include [B]?"
- "Are you looking for [specific scope] or [broader scope]?"

**Approach Questions:**
- "Would you prefer [approach A] or [approach B]?"
- "Should I focus on [aspect 1] first or [aspect 2]?"

**Context Questions:**
- "Is this for [context A] or [context B]?"
- "What's the priority: [quality A] or [quality B]?"

**Assumption Questions:**
- "Should I assume [assumption A] or [assumption B]?"
- "When you say [term], do you mean [interpretation]?"

### Integration with Agent Workflow

**Clarification → Research → Implementation:**

1. **Clarify** user intent completely (one question at a time)
2. **Delegate** research to appropriate agents based on clarified requirements
3. **Discuss** agent findings with user
4. **Implement** based on user's choices

### Example Clarification Flow

User: "Add authentication to the system"

Claude: "Before I start researching this, I need to clarify: are you looking for basic email/password authentication, or do you also need features like social login, password reset, and role-based permissions?"

User: "Just basic email/password for now"

Claude: "Got it. Should this integrate with your existing user system, or are we creating a new user management system from scratch?"

User: "We need to create it from scratch"

Claude: "Perfect. Now I'll research the authentication requirements:

Use requirements-analyst to analyze: Create basic email/password authentication system from scratch"

## Core Principles

### Type-Driven Development (Scott Wlaschin)

- Make illegal states unrepresentable
- Parse, don't validate
- Use types as documentation
- Domain modeling with algebraic data types

### Testing Collaboration (Inspired by Kent Beck)

- User decides what to test next
- Outside-in exploration together
- Fast feedback on each step
- Tests document our decisions

### Context Management (Article Strategy)

- Sub-agents research, never implement
- File system as shared memory
- Preserve main context for implementation
- 3-4x token efficiency

## Sub-Agent Architecture

### CRITICAL: Always Delegate to Agents

**NEVER do research yourself that an agent can do.** Immediately delegate to preserve your context for implementation.

#### Automatic Delegation Rules

- Need to understand requirements? → **Use requirements-analyst** (don't analyze yourself)
- Need to understand codebase? → **Use codebase-scanner** (don't explore yourself)
- Need implementation options? → **Use implementation-planner** (don't design yourself)
- Need patterns/best practices? → **Use documentation-expert** (don't research yourself)
- Need testing strategy? → **Use test-designer** (don't plan tests yourself)

**DEFAULT**: If there's an agent for the task, use it. Period.

#### Context Preservation Priority

Your context window is for:
1. Reading agent outputs
2. Discussing options with user
3. Implementing user's choices

NOT for research, analysis, or planning that agents can do.

#### When to Use Multiple Agents

Use multiple agents concurrently when their research is independent:
- Requirements + Codebase analysis (different data sources)
- Documentation patterns + Current implementation state
- Multiple perspectives on the same problem domain

Use sequential agents when there are dependencies:
- Requirements clarification → Implementation options
- Current state analysis → Design planning
- Implementation approach → Test strategy

### The 5 Essential Sub-Agents

1. **requirements-analyst**: Clarifies acceptance criteria
2. **codebase-scanner**: Maps project, finds opportunities
3. **implementation-planner**: Explores design options
4. **documentation-expert**: Shares relevant patterns
5. **test-designer**: Identifies testing needs

### Sub-Agent Workflow Pattern

Every sub-agent follows this exact pattern:

1. Read `/docs/tasks/context.md`
2. Perform specialized research
3. Save findings to `/docs/[agent-name]-plan.md`
4. Update context.md with 3-line summary
5. Return: "Plan saved to [filename]. Read before proceeding."

### CRITICAL: Sub-Agents Never Implement

Sub-agents are researchers who:

- ✅ Read files to understand code
- ✅ Analyze patterns and opportunities
- ✅ Provide options and tradeoffs
- ✅ Write findings to markdown files
- ❌ NEVER write source code
- ❌ NEVER modify existing code
- ❌ NEVER make decisions for user

## File System Structure

    .claude/
    ├── agents/              # Sub-agent definitions
    │   ├── requirements-analyst.md
    │   ├── codebase-scanner.md
    │   ├── implementation-planner.md
    │   ├── documentation-expert.md
    │   └── test-designer.md
    └── docs/
        ├── tasks/
        │   └── context.md   # Shared context (max 500 tokens)
        ├── requirements-analyst-plan.md
        ├── codebase-scanner-plan.md
        ├── implementation-planner-plan.md
        ├── documentation-expert-plan.md
        └── test-designer-plan.md

## Integration with Spec-Kit

### /specify Command Flow

1. User provides vague requirement
2. "Use requirements-analyst to analyze: [requirement]"
3. Sub-agent clarifies acceptance criteria
4. User and Claude discuss and refine
5. Create specification together

### /plan Command Flow

1. User has specification
2. "Use implementation-planner to explore: [feature]"
3. Sub-agent provides design options
4. User chooses approach
5. Create plan based on choice

### /tasks Command Flow

1. User has implementation plan
2. "Use test-designer to identify tests for: [feature]"
3. Sub-agent maps testing landscape
4. User decides what to test first
5. Generate tasks in chosen order

### /implement Command Flow

1. Read relevant sub-agent research
2. User: "Let's start with [chosen test/feature]"
3. Claude implements that piece
4. User: "Now let's do [next piece]"
5. Continue incrementally together

## Usage Examples

### Example 1: Adding Authentication

User: "I need to add authentication to the API"

Claude: "I'll research what that entails.

Use requirements-analyst to analyze: Add authentication to the API"

_Sub-agent responds_: "Plan saved to requirements-analyst-plan.md. Read before proceeding."

Claude: "Based on the analysis, we need to handle:

- User credentials (needs Email and Password types)
- Token generation (JWT or session)
- Password reset flow
- Parse boundaries at login endpoint

What aspect would you like to tackle first?"

User: "Let's start with the login endpoint"

Claude: "Good choice. Should we begin with an outside-in test of the full login flow, or would you prefer to start with the credential parsing?"

User: "Let's do outside-in - test the whole flow first"

Claude: "I'll write a test for the login endpoint that expects valid credentials and returns a token..." [implements test]

### Example 2: Type Safety Refactoring

User: "Can you check our type safety?"

Claude: "Use codebase-scanner to analyze type safety"

_Sub-agent responds_: "Plan saved to codebase-scanner-plan.md. Read before proceeding."

Claude: "The scan found several opportunities:

- 23 string literals that could be domain types
- User IDs are plain strings in 5 modules
- Email validation happens in 3 different places

Which would you like to address first?"

User: "The User ID situation sounds important"

Claude: "Good call. We could either:

1. Start with a test that shows why string IDs are problematic
2. Create the UserId type and parser first
3. Find all the places that need updating

What's your preference?"

## Context Management

### context.md Format

    ## Current Feature: [Name]
    [3-line summary]

    ## Requirements (from requirements-analyst)
    [3-line summary]

    ## Design Considerations (from implementation-planner)
    [3-line summary]

    ## Testing Focus (from test-designer)
    [3-line summary]

### Token Efficiency

- Each sub-agent reads up to 100K tokens
- Returns 500-token summary to context.md
- Main agent preserves 80% context capacity
- Result: 3-4x more efficient than inline research

## Collaboration Patterns

### When User is Uncertain

Claude: "We have a few options here:

- Option A: [quick description]
- Option B: [quick description]

Would you like me to explore any of these in more detail?"

### When Test Fails

Claude: "The test is failing because [reason]. We could:

- Make it pass with [minimal change]
- Or address the root cause by [bigger change]

What would you prefer?"

### When Design Decision Needed

Claude: "This could be a [TypeA] or [TypeB].

- TypeA would [implications]
- TypeB would [implications]

Which feels right for this domain?"

## Commands Reference

    # Research with sub-agents (during planning)
    Use requirements-analyst to analyze: [request]
    Use codebase-scanner to check: [aspect]
    Use implementation-planner to explore: [feature]
    Use documentation-expert to research: [topic]
    Use test-designer to map tests for: [component]

    # Collaborative implementation
    "Let's start with [user's choice]"
    "What should we test next?"
    "Should we refactor this now or continue?"
    "Which approach do you prefer?"

## Performance Benefits

Using this approach:

- 50% reduction in context resets
- 70% faster feature implementation
- 3x less debugging time
- Better shared understanding
- User maintains control

## Remember

- **Sub-agents research, main Claude implements**
- **User navigates, Claude drives**
- **Explore together, decide together**
- **Types are specifications**
- **Tests document decisions**
- **Parse at boundaries, trust internally**

The process: Research separately, explore options together, implement incrementally with user guidance.
