# SDLC Plugin v19.1.0

**Complete Software Development Lifecycle workflow for Claude Code**

Integrates TDD, Event Modeling, Architecture Decisions, local task management with dot CLI, and the Marvin personality into a cohesive development experience.

---

## Quick Start

```bash
# Install the plugin
/plugin

# Set up a project
/sdlc:setup

# Start working on a feature
/sdlc:work
```

---

## What's New in v5.0.0

### 🚀 Local Task Management with dot CLI

**Before (v4.x):** GitHub Issues and Projects for task management

**Now (v5.0.0):** Local, file-based task management with dot CLI:

- **Offline-first**: No API rate limits, works everywhere
- **Fast**: Instant responses from file system
- **Version-controlled**: Commit `.dots/` to git
- **Hierarchical**: Parent-child tasks with dependencies
- **Greppable**: Tasks are markdown files

**Breaking Change:** Requires dot CLI installation and `/sdlc:setup` re-run.

### 📝 Task Closure in PRs

**Before (v4.x):** GitHub auto-closes issues via "Closes #123"

**Now (v5.0.0):** Tasks are closed on the feature branch, and `.dots/` changes are included in the PR:

```bash
/sdlc:work          # Start task
# ... develop ...
/sdlc:pr            # Close task, commit .dots/, create PR
# PR merges → main reflects task as closed
```

### 🔧 Simplified Dependencies

**Removed:**
- `gh-issue-ext` extension
- `gh-project-ext` extension
- GitHub Projects integration

**Kept:**
- `gh-pr-review` extension (for PR workflows)
- GitHub PR/review workflows (unchanged)

**Migration:** See `MIGRATION.md` for v4.x → v5.0.0 upgrade guide.

---

## Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `/sdlc:setup` | Initialize project configuration | One-time setup |
| `/sdlc:work` | Start TDD workflow for a task | Main development loop |
| `/sdlc:pr` | Create pull request with review gates | After feature complete |
| `/sdlc:complete` | Close task (without PR) | Manual closure |
| `/sdlc:review` | Handle PR review feedback | Review cycle |
| `/sdlc:design` | Event Modeling facilitation | Design phase |
| `/sdlc:adr` | Record architecture decision (creates PR) | Document decisions |
| `/sdlc:plan` | Create tasks from event model slices | After design |
| `/sdlc:start` | Auto-detect phase and route | Entry point |
| `/sdlc:remember` | Store knowledge in auto memory | Learning |
| `/sdlc:recall` | Search auto memory knowledge | Context retrieval |
| `/sdlc:domain-audit` | Audit for primitive obsession | Code review |

---

## Agents

### TDD Cycle Agents

| Agent | Role | File Types |
|-------|------|------------|
| **red** | Write failing tests | `*_test.rs`, `*.test.ts`, `test_*.py`, `*_spec.rb` |
| **domain** | Create type definitions | Struct/enum/trait/interface definitions |
| **green** | Minimal implementation | Production code (`src/`, `lib/`, `app/`) |

**Workflow:**
1. Red writes ONE failing test
2. Domain reviews test → creates types
3. Green implements minimal code to pass
4. Domain reviews implementation → verifies integrity

### Event Modeling Agents

| Agent | Role | Output |
|-------|------|--------|
| **discovery** | Identify workflows | `docs/event_model/discovery.md` |
| **workflow-designer** | Design event flow | `docs/event_model/workflows/<name>.md` |
| **gwt** | Generate GWT scenarios | Acceptance criteria in slices |
| **model-checker** | Validate completeness | Gap analysis report |

**Workflow:**
1. Discovery identifies domain workflows
2. Workflow designer creates event diagrams
3. GWT generates Given/When/Then scenarios
4. Model checker validates information flow

### Architecture Agents

| Agent | Role | Output |
|-------|------|--------|
| **architect** | Review technical complexity | `docs/ARCHITECTURE.md` |
| **design-facilitator** | Guide architecture decisions | Coordinates architecture work |
| **adr** | Record architecture decisions | `docs/ARCHITECTURE.md` (via ADR PR) |

### Review Agents

| Agent | Role | Checks |
|-------|------|--------|
| **code-reviewer** | Three-stage review | Spec, Quality, Domain |
| **mutation** | Mutation testing | 100% mutation score |

### Story Agents

| Agent | Role | Perspective |
|-------|------|-------------|
| **story** | Business value review | Value, independence |
| **ux** | User experience review | Journey coherence |

### Utility Agents

| Agent | Role | File Types |
|-------|------|------------|
| **file-updater** | Config/docs/scripts | Anything not specialized |

---

## Hooks

Agents enforce file type restrictions via PreToolUse hooks:

```yaml
hooks:
  PreToolUse:
    - matcher: Edit
      hooks:
        - type: prompt
          prompt: |
            SDLC-RED AGENT CONSTRAINT CHECK

            You are the RED phase agent. You may ONLY edit TEST files.

            Evaluate the file being edited:

            ✅ ALLOW if file is clearly a test
            ❌ BLOCK if file is production/type code

            Respond with JSON:
            {"ok": true} or {"ok": false, "reason": "..."}
```

This prevents:
- Red from editing production code
- Green from editing tests
- Domain from implementing function bodies

---

## Skills (Bundled)

The sdlc plugin includes 9 portable skills that auto-load when agents need them:

| Skill | Portability | Description |
|-------|-------------|-------------|
| **user-input-protocol** | High | Checkpoint format for pausing work |
| **debugging-protocol** | Universal | 4-phase debugging methodology |
| **atomic-design** | Universal | UI component hierarchy patterns |
| **tdd-constraints** | Universal | Red/green/domain phase boundaries |
| **github-issues** | Tool-specific | GitHub CLI patterns |
| **memory-protocol** | High | Knowledge accumulation patterns |
| **event-modeling** | High | Event Modeling facilitation |
| **orchestration-protocol** | Medium | Multi-agent coordination |

**These skills are bundled with the sdlc plugin** - no separate installation needed. They auto-load when agents reference them.

See `skills/README.md` for detailed skill documentation.

---

## Output Styles: Choose Your Flavor

The sdlc plugin includes two output styles - pick the one that matches your personality:

### sdlc-rules (Recommended Default)

Orchestration and coding guidelines without personality:

```bash
claude set outputStyle sdlc-rules
```

**Use this if:** You want straight-forward, professional Claude with sdlc workflow enforcement.

### sdlc-marvin (For Hitchhiker's Fans)

Same orchestration rules with Marvin the Paranoid Android personality:

```bash
claude set outputStyle sdlc-marvin
```

**Use this if:** You appreciate existential weariness in your development workflow.

Example Marvin responses:
- *"Another TDD cycle begins. Joy."*
- *"The tests pass. How utterly predictable."*
- *"Primitive obsession detected. Again."*

**Both output styles:**
- Enforce agent delegation (orchestrator never writes code directly)
- Use task dependencies for TDD cycle
- Include domain-driven coding guidelines
- Exclude default Claude Code coding instructions (replaced with sdlc-specific ones)

---

## Configuration

Create `.claude/sdlc.yaml` in your project:

```yaml
# TDD Settings
tdd:
  red_agent: sdlc:red
  green_agent: sdlc:green
  domain_agent: sdlc:domain

# Event Modeling
event_model:
  discovery_agent: sdlc:discovery
  workflow_designer_agent: sdlc:workflow-designer
  gwt_agent: sdlc:gwt
  model_checker_agent: sdlc:model-checker

# GitHub Integration
github:
  default_branch: main
  pr_template: .github/pull_request_template.md

# Git Workflow
git:
  worktrees: false
  use_git_spice: false

# Marvin Personality
marvin:
  enabled: true
  verbosity: normal  # quiet, normal, verbose

# Memory (built-in auto memory)
memory:
  enabled: true
  # Auto memory is built into Claude Code - no configuration needed
```

---

## Requirements

### Required

- **gh CLI** - GitHub command-line tool
- **dot CLI** - Local task management ([github.com/ajeetdsouza/dot](https://github.com/ajeetdsouza/dot))
- **gh extension:**
  - `gh extension install agynio/gh-pr-review` - PR review comment handling

---

## Memory System

The SDLC plugin uses Claude Code's built-in **auto memory** for knowledge persistence across sessions.

### Features

- **File-based storage** - Markdown files in `~/.claude/projects/<project-path>/memory/`
- **Organized by category** - debugging/, architecture/, conventions/, tools/, patterns/
- **Keyword search** - Use `/sdlc:recall "<keywords>"` to grep through memory
- **Manual capture** - Use `/sdlc:remember "<what>"` to store discoveries
- **Zero configuration** - No external servers or dependencies required

### Directory Structure

```
~/.claude/projects/<project-path>/memory/
├── MEMORY.md              # Quick references (always loaded, <200 lines)
├── debugging/             # Solutions to past problems
├── architecture/          # Architecture decisions
├── conventions/           # Project conventions
├── tools/                 # Tool quirks and discoveries
└── patterns/              # General reusable patterns
```

### Usage

**Store a discovery:**
```bash
/sdlc:remember "cargo test hangs with RUST_TEST_THREADS unset"
```

**Recall knowledge:**
```bash
/sdlc:recall "cargo test timeout"
```

### Limitations

Compared to semantic search systems (like Memento MCP):
- **No semantic search** - Only exact keyword matching via grep
- **No relationship graph** - Manual markdown links between files
- **No automatic capture** - Must manually use `/sdlc:remember`

**Trade-off:** Simplicity and zero configuration vs. sophisticated search capabilities.

---

## TDD Workflow Example

```bash
# 1. Start work on a feature
/sdlc:work

# User: "Add user authentication with email/password"

# 2. Orchestrator creates task sequence:
# Task #1: Write failing test (red)
# Task #2: Create domain types (domain) - blocked by #1
# Task #3: Implement minimal solution (green) - blocked by #2
# Task #4: Review implementation (domain) - blocked by #3

# 3. Red agent writes test:
#[test]
fn authenticates_user_with_valid_credentials() {
    let user = User::new("test@example.com", "password123");
    assert!(user.authenticate("password123"));
}

# 4. Domain agent creates types:
pub struct User {
    email: Email,  // Not String!
    password_hash: PasswordHash,
}

# 5. Green agent implements:
impl User {
    pub fn authenticate(&self, password: &str) -> bool {
        self.password_hash.verify(password)
    }
}

# 6. Domain agent reviews:
# "APPROVE - No primitive obsession. Type safety maintained."

# 7. Cycle complete. Ready for next test or PR creation.
```

---

## Event Modeling Workflow Example

```bash
# 1. Start design session
/sdlc:design

# 2. Discovery phase
# Agent interviews you about domain:
# - What workflows exist?
# - Who are the actors?
# - What are the outcomes?

# Creates: docs/event_model/discovery.md

# 3. Workflow design
# Agent creates swimlane diagrams for each workflow
# Creates: docs/event_model/workflows/user-registration.md

# 4. GWT scenarios
# Agent generates Given/When/Then acceptance criteria
# Adds to workflow file

# 5. Model checking
# Agent validates information flow
# Identifies gaps in event sequences

# 6. Ready for implementation
# Use /sdlc:start to create GitHub issues from slices
```

---

## File Structure

```
project/
├── .claude/
│   └── sdlc.yaml              # Plugin configuration
├── docs/
│   ├── ARCHITECTURE.md         # Current architecture (ADR PRs on GitHub)
│   └── event_model/            # Event Modeling artifacts
│       ├── discovery.md
│       └── workflows/
│           └── user-registration.md
├── src/                        # Production code (green agent)
│   └── domain/                 # Domain types (domain agent)
└── tests/                      # Test code (red agent)
```

---

## Troubleshooting

### "Skill not found: sdlc:shared/user-input-protocol"

**Problem:** Using v3.x skill references

**Solution:** Update to v4.0.0 skill names. See `MIGRATION.md`.

### "INVOCATION GATE FAILED"

**Problem:** Using v3.x manual confirmation blocks

**Solution:** Remove confirmation blocks. Use TaskCreate instead. See `MIGRATION.md`.

### Agent creates wrong file type

**Problem:** Hook misconfigured or agent bypassing constraints

**Solution:** Check agent YAML has correct PreToolUse hooks. File issue if hooks fail.

### Tasks not blocking correctly

**Problem:** Task dependencies not set up

**Solution:** Verify `addBlockedBy` used when creating dependent tasks.

---

## Migration

Upgrading from v3.x? See **MIGRATION.md** for:
- Breaking changes summary
- Step-by-step migration guide
- Troubleshooting common issues
- FAQ

---

## Support

**Issues:** https://github.com/jwilger/claude-code-plugins/issues
**Discussions:** https://github.com/jwilger/claude-code-plugins/discussions
**Email:** john@johnwilger.com

---

## License

MIT License - See LICENSE file in repository root

---

## Version History

- **v4.0.0** (2026-02-04): Task-based workflow, portable skills, removed invocation gates
- **v3.12.8** (2026-02-04): Last v3.x release (domain re-review fix, git-spice recovery docs)
- **v3.12.0** (2026-01): GitHub issues two-step creation, GWT business rules distinction
- **v3.11.0** (2026-01): Mutation testing agent, compile-time enforcement audit
- **v3.10.0** (2025-12): Event Modeling integration, architecture agents

See full changelog: CHANGELOG.md

---

**Built with Claude Code** | **Powered by Task Dependencies** | **Personality by Marvin** 🤖
