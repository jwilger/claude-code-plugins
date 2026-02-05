# Claude Code Plugins

A collection of Claude Code plugins for professional software development workflows.

**Repository**: [jwilger/claude-code-plugins](https://github.com/jwilger/claude-code-plugins)

## Quick Start

### Add the Marketplace

Inside Claude Code, run:

```
/plugin marketplace add jwilger/claude-code-plugins
```

### Install Plugins

```
# Install the complete SDLC workflow
/plugin install sdlc@jwilger-claude-plugins

# Choose your output style (orchestration with or without personality)
claude set outputStyle sdlc-rules    # Professional (recommended)
# or
claude set outputStyle sdlc-marvin   # With Marvin personality

# Install the Nix bootstrapper
/plugin install bootstrap@jwilger-claude-plugins
```

### Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- gh extensions (installed via `/sdlc:setup`):
  - `gh-issue-ext` - sub-issues, blocking, linked branches
  - `gh-project-ext` - project board management
  - `gh-pr-review` - PR review comment handling
- git-spice (optional, for stacked PRs)
- Memento MCP server (for persistent memory)

### Auto-Approval Patterns

Add these to your Claude Code settings for smoother workflow:

```
Bash(gh issue *)
Bash(gh issue-ext *)
Bash(gh project *)
Bash(gh project-ext *)
Bash(gh pr-review *)
Bash(gs *)  # if using git-spice
```

---

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [sdlc](#sdlc-plugin) | Complete SDLC workflow with TDD, Event Modeling, ADRs, and GitHub integration (includes 2 output styles) |
| [bootstrap](#bootstrap-plugin) | Intelligent Nix devshell bootstrapper for any language or framework |

---

## sdlc Plugin

Complete SDLC workflow plugin with:

- **TDD Workflow**: Strict Red/Green/Refactor cycle with specialized agents
- **Event Modeling**: Design event-sourced systems (Martin Dilger's methodology)
- **Architecture Decision Records**: Document and manage architectural decisions
- **GitHub Integration**: Project boards, issues, PRs, review handling
- **Memory Protocol**: Persistent knowledge using Memento MCP

### Commands

| Command | Description |
|---------|-------------|
| `/sdlc:setup` | Initialize project configuration and install gh extensions |
| `/sdlc:work` | Start or continue working on an issue |
| `/sdlc:pr` | Create/update PR with mutation testing |
| `/sdlc:review` | Handle PR review feedback (reply in-thread) |
| `/sdlc:design` | Design event model workflows |
| `/sdlc:adr` | Create and manage architecture decisions |

### Agents

**TDD Agents** (strict file boundaries enforced via hooks):
- `sdlc:red` - Write failing tests (test files only)
- `sdlc:green` - Make tests pass (production code only)
- `sdlc:domain` - Create type definitions (signatures only)
- `sdlc:mutation` - Run mutation testing

**Review Agents**:
- `sdlc:story` - Business value perspective
- `sdlc:architect` - Technical feasibility (ARCHITECTURE.md only)
- `sdlc:ux` - UX/accessibility perspective
- `sdlc:code-reviewer` - Three-stage code review

**Event Modeling Agents** (event model files only):
- `sdlc:discovery` - Domain discovery
- `sdlc:workflow-designer` - Design workflows with 9-step process
- `sdlc:gwt` - Generate Given/When/Then scenarios
- `sdlc:model-checker` - Validate event model completeness

**Architecture Agents**:
- `sdlc:adr` - Write architecture decision records (ADRs only)
- `sdlc:design-facilitator` - Guide architecture decisions

**Utility Agent**:
- `sdlc:file-updater` - Config, scripts, general docs (blocked from specialized files)

### Development Modes

**Event Modeling** (for applications):
- Workflow → Vertical Slice → Component → Subtask hierarchy
- GWT scenarios as acceptance criteria
- Full event sourcing methodology

**Traditional** (for libraries/utilities):
- Feature → Subtask hierarchy
- Architecture documentation focus

---

## bootstrap Plugin

Intelligent Nix devshell bootstrapper that detects your project type and generates appropriate `flake.nix` configurations.

**Features**:
- Auto-detects language/framework from existing files
- Researches current Nix best practices for your stack
- Generates `flake.nix` with development tools and shell hooks
- Supports any language: Rust, TypeScript, Python, Go, Elixir, etc.

### Commands

| Command | Description |
|---------|-------------|
| `/bootstrap:init` | Bootstrap a Nix development environment |

**Usage**: Run `/bootstrap:init` in any project to generate a Nix flake. For new projects, specify the language: `/bootstrap:init rust`

---

## Repository Structure

```
claude-code-plugins/
├── .claude-plugin/
│   └── marketplace.json      # Plugin registry
├── sdlc/
│   ├── .claude-plugin/
│   │   └── plugin.json       # Plugin manifest
│   ├── commands/             # Slash commands
│   ├── agents/               # Specialized subagents
│   ├── output-styles/        # 2 styles (with/without Marvin)
│   │   ├── sdlc-rules.md
│   │   └── sdlc-marvin.md
│   └── skills/               # Bundled portable skills (9 total)
│       ├── user-input-protocol/
│       ├── debugging-protocol/
│       └── ...
├── bootstrap/
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── commands/
│   └── agents/
└── README.md
```

---

# The Philosophy Behind This Setup

I've been iterating on this setup for months now, and I think I've learned something worth sharing. Not the configuration itself—you can copy my files, but that probably won't help you much. What I've learned is *how to think* about working with LLMs for software development.

The short version: the practices that help LLMs succeed at software engineering are the same practices that have been helping humans succeed for decades. TDD, separation of concerns, clear architectural patterns, domain-driven design, small focused units of work—none of these ideas are new. What's new is encoding them in a form an LLM can follow.

This setup isn't a collection of prompts to get Claude to do what I want. It's a description of how I approach software engineering, from requirements to deployment. And like any methodology, it evolves as I learn.

## The Problem I Was Trying to Solve

LLMs are eager to help. Too eager. Ask for "user authentication" and you'll get authentication plus refactored nearby code, error handling for impossible scenarios, abstractions for one-off operations, and documentation nobody requested.

This creates two problems. First, scope creep: you asked for one thing, you got seven. Second, verification burden: now you have to review all seven things instead of just the one you understood.

My first instinct was to write better prompts. Be more specific. Tell the LLM what *not* to do. This helped, but not enough. The LLM would still drift, especially on longer tasks.

Then I realized something that should have been obvious: I was treating the LLM like it was a special case. But the practices that keep human developers focused—clear roles, defined interfaces, single responsibility—work just as well for AI agents.

## Specialized Agents with Inviolable Boundaries

The most important constraint in my setup is separation of concerns through specialized agents. Instead of one general-purpose agent that does everything, I use focused agents that can *only* do one thing.

The red agent writes tests. Only tests. It cannot touch production code or type definitions. When it writes a test that references a type that doesn't exist, it *cannot* create that type. It has to stop.

The domain agent creates type definitions. Only type definitions. No implementation bodies, no tests.

The green agent writes production code to make tests pass. Only production code. No tests, no types.

Why does this matter? Because it breaks the failure mode where an LLM writes a test and immediately makes it pass. When that happens, you end up with tautological tests that verify the implementation does what the implementation does—which tells you nothing.

I describe these boundaries as "inviolable" in the agent prompts. The word choice is deliberate. It signals to the LLM that this isn't a suggestion.

## Hooks: Because Instructions Aren't Enough

Agent instructions are advisory. The LLM might still try to edit files outside its boundary, especially when it's trying to be helpful by "just fixing this one thing."

So I added hooks that enforce the boundaries at runtime. When an agent attempts to edit a file, the hook evaluates whether that file falls within the agent's permitted scope. If not, the edit is blocked.

Instructions describe intent. Hooks enforce it. You need both.

## The TDD Cycle, Made Explicit

I've practiced test-driven development for years, but working with LLMs forced me to articulate what I actually do in a way I never had before.

"Write a failing test" isn't specific enough for an LLM. Given that instruction, it'll write a comprehensive test suite covering every edge case it can imagine. These tests often couple to implementation details, making refactoring painful.

So I had to be precise: write *one* failing test with *one* assertion. Reference types that don't exist yet. Stop when the test fails.

Then create *minimal* type definitions—just enough to make the compiler happy. Signatures only, no bodies.

Then write *minimal* production code. Address only what the error message demands. Stop immediately when the test passes.

Here's the thing: this isn't just good advice for LLMs. It's the discipline I should have been following all along. The LLM forced me to make my methodology explicit, and in doing so, I refined it.

## Mutation Testing as a Quality Gate

Traditional code coverage tells you whether code was *executed* during tests. It doesn't tell you whether tests would *fail* if the code were wrong.

I learned this the hard way when Claude produced code with 100% coverage that was still buggy. The tests ran the code but didn't actually verify its behavior.

Mutation testing fixes this. It makes small changes to your code and checks if your tests catch the modifications. If a test passes when the code is wrong, that's a problem.

My `/sdlc:pr` command requires 100% mutation score before creating a pull request. Every mutant must be killed. This isn't perfectionism—it's the only way I've found to ensure tests actually verify behavior.

## Memory Across Conversations

LLMs have context windows, not memories. Every conversation starts fresh. This is a problem for complex projects where context matters.

My setup uses the Memento MCP server to maintain a knowledge graph across conversations. Before any task, agents search for relevant context. After discoveries, they store learnings immediately. Before context compaction, they save in-progress work.

An LLM that rediscovers the same solution repeatedly wastes both tokens and my attention. Memory lets it build on past work.

## GitHub as the Source of Truth

I experimented with various task management approaches—custom task files, conversation-local todo lists, specialized tools. None of them stuck.

The problem was simple: I already use GitHub. Issues, project boards, pull requests—that's where my work lives. Task management that existed only in Claude conversations created information silos.

So I built integrations that read from and write to GitHub directly. `/sdlc:work` picks up an issue and creates a branch. `/sdlc:pr` creates a pull request linked to the issue. `/sdlc:review` addresses PR comments in-thread.

The tools integrate with my existing workflow instead of replacing it.

## Event Modeling: The Architecture LLMs Were Made For

This section matters more than the others because Event Modeling isn't just another pattern in my setup—it's the foundation that makes everything else work.

Traditional layered architectures create a fundamental problem: there's no clear "right answer" for where business logic belongs. Should validation happen in the controller or the service? Should business rules live in the service layer or the domain? Different developers answer differently, even within the same codebase.

When an LLM encounters this ambiguity, it either makes an arbitrary choice that conflicts with existing patterns, asks clarifying questions that slow things down, or over-engineers to cover all cases.

Event Modeling eliminates this ambiguity by providing exactly four patterns for all system behavior:

1. **State Change**: Command → Event (the only way to modify state)
2. **State View**: Events → Read Model (projections for queries)
3. **Automation**: Event → Process → Command (background work)
4. **Translation**: External Data → Internal Event (anti-corruption layer)

Every feature fits into exactly one of these patterns. There's no debate about where code belongs—the pattern tells you.

A tangent: I've been following Adam Dymitruk's work on Event Modeling for a while now. He's been articulating something I've felt but couldn't express—that AI limitations are driving better architectures. As he puts it: "You don't want to spend your tokens on a lot of cruft in the code—confuse the context with framework scaffolding, mock libraries, etc."

Event Modeling minimizes the context an LLM needs to do its job correctly. Instead of loading an entire service layer, you provide the command being handled, the events it might emit, and the read models that consume those events. That's enough.

Dymitruk suggests using "the introduction of AI to be a measure of how well organized your system is." I think he's right. If an LLM struggles to work in your codebase, that's signal that humans probably struggle too.

Martin Dilger's book [*Understanding Eventsourcing*](https://leanpub.com/eventmodeling-and-eventsourcing) provides the practical bridge from theory to implementation. He emphasizes that he "would never start a new system or microservice without Event Modeling. The time savings and the quality of requirements was previously not possible."

This clarity of requirements is exactly what LLMs need. Ambiguous requirements produce ambiguous code. Event models produce specifications that translate directly to implementation.

I consider Event Modeling essential knowledge for software development in this era. It's not a nice-to-have architectural pattern—it's the difference between LLMs that help and LLMs that create chaos.

**Resources:**
- [Event Modeling](https://eventmodeling.org/) - Adam Dymitruk's methodology
- [Understanding Eventsourcing](https://leanpub.com/eventmodeling-and-eventsourcing) - Martin Dilger's book
- [The Event Modeling and Event Sourcing Podcast](https://podcast.eventmodeling.org/)

## Architecture Decision Records

Technical decisions become mysterious six months later. "Why do we use X instead of Y?" Without documentation, the answer is lost.

I use Architecture Decision Records to capture the why. Status, context, decision, alternatives considered, consequences. The LLM both creates ADRs and consults them when making related decisions.

The ADR system follows event-sourcing principles: ADRs are immutable events, and `ARCHITECTURE.md` is a projection of accepted decisions.

## How This Setup Evolved

Looking at the git history tells the story.

Early on, I had a monolithic system prompt. Then I added task management (later removed for GitHub integration). I created agents, but without enforced boundaries.

The key pivots came from observing failures. I added "inviolable" boundaries after noticing agents drifting outside their scope. I added hooks after instructions alone proved insufficient. I added mutation testing after catching tests that didn't actually test anything.

But here's what I've realized: I wasn't just tuning prompts. I was refining my understanding of software engineering itself. When I added mutation testing, it wasn't because "LLMs need this"—it's because I realized traditional coverage metrics were insufficient for *any* developer. When I separated the domain agent, it was because thinking about types before implementation produces better designs, regardless of who's writing the code.

The LLM is a mirror. When it fails, the question isn't just "how do I fix the prompt?" It's "what am I not articulating clearly about how this should be done?" Often the answer reveals gaps in my own methodology that I'd papered over with intuition.

## What I've Learned

**Constraints enable rather than limit.** An agent that can do anything often does too much. An agent with clear boundaries does its one job well.

**Instructions are necessary but not sufficient.** Telling an LLM "only edit test files" works most of the time. Hooks that enforce it work all the time. Use both.

**Separation of concerns applies to AI too.** The same principles that make human teams effective—clear roles, defined interfaces—make AI agents effective.

**Memory changes everything.** An LLM with persistent memory builds on past work. Without memory, it rediscovers the wheel every conversation.

**Integrate with existing tools.** Developers already have workflows. AI that integrates with those workflows gets adopted. AI that requires parallel systems gets abandoned.

**Architecture is the ultimate constraint.** Event Modeling and vertical slices create a codebase where there's one obvious place for every piece of logic. The LLM doesn't need to be told where to put code; the architecture makes it self-evident.

**The LLM is a mirror.** "Write good tests" isn't a methodology. "Write one failing test with one assertion that references types that don't exist yet" is a methodology. The LLM needs the latter, but so does anyone trying to follow your approach consistently.

## A Final Thought

When I started working with LLMs for software development, I thought I was learning how to prompt AI effectively. What I actually learned was how to articulate software engineering practices I'd internalized but never made explicit.

Every agent definition forced me to answer: "What exactly should this role do, and why?" Every hook made me specify: "What invariants must never be violated?" Every workflow required: "What is the actual sequence of steps, and what makes each step complete?"

These aren't AI questions. They're software engineering questions. Questions that, when answered clearly, produce better outcomes whether the one following the process is human or machine.

The irony is that teaching an LLM to write software has made me a better software engineer. Not because the LLM taught me new techniques, but because it forced me to examine and refine the techniques I already used.

If you take one thing from this document: don't think of LLM configuration as "prompt engineering." Think of it as methodology documentation. Write it as if you were onboarding a skilled but unfamiliar developer to your exact way of working. The clearer you can make your methodology, the better your results—with LLMs, with junior developers, and with your future self.

---

*This setup represents how I work today. It will be different tomorrow as I learn more. The specific files matter less than the thinking behind them—understanding your own problems deeply enough to know what constraints you need.*

---

## License

MIT License

## Author

John Wilger (john@johnwilger.com)
