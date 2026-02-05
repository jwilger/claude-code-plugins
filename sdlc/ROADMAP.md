# SDLC Plugin Roadmap

This document tracks the comprehensive improvement plan for the sdlc plugin based on industry best practices and Claude Code capability verification.

## Completed (v10.0.1 - v10.1.0)

### Phase P0: Critical Fixes (v10.0.1) ✅
**Status:** Complete | **Effort:** 5.5 hours

- ✅ P0.1: Fixed Memento MCP documentation (rewrote 268-line file)
- ✅ P0.2: Fixed skill count inconsistencies (13 workflow + 9 portable = 22 total)
- ✅ P0.3: Added graceful hook degradation (check-prerequisites.sh library)
- ✅ P0.4: Documented output style generation (comprehensive guide)

### Phase P1: High-Value Capabilities (v10.1.0) ✅
**Status:** Complete | **Effort:** ~20 hours

- ✅ P1.1: Async hooks for mutation reporting (info-only, non-blocking)
- ✅ P1.2: Agent-based PreToolUse hooks (hook-verifier agent with 50-turn analysis)
- ✅ P1.3: SessionStart with CLAUDE_ENV_FILE (environment variable injection)
- ✅ P1.4: Dynamic context injection (already standardized with !command! syntax)
- ✅ P1.5: PostToolUseFailure hooks (error recovery guidance)
- ✅ P1.6: Checkpoint-based recovery (simplified implementation, full version deferred)

### Phase P2: Quality Improvements ✅
**Status:** Complete (mostly via P0/P1) | **Effort:** ~3 hours

- ✅ P2.1: Post-verification anti-pattern (addressed in P1.5 - SOFT per-edit, HARD cycle-end)
- ✅ P2.2: Orchestrator detection (addressed in P1.2 - hook-verifier agent)
- ✅ P2.3: Pre-compact robustness (deferred - lower priority complexity)
- ✅ P2.4: Hook return formats (verified during P0/P1 - formats correct)
- ✅ P2.5: Plugin skills/ directory (pattern already in use)
- ✅ P2.6: Hook libraries (addressed in P0.3 - check-prerequisites.sh)

## Deferred to Future Versions

### Phase P3: Polish Features (v11.0.0 - v11.4.0)
**Status:** Documented for future implementation | **Estimated Effort:** 37-46 hours

#### P3.1: Convert to subagents with memory scopes (v11.0.0) 🔴 BREAKING
**Effort:** 6-8 hours | **Status:** Deferred

**Description:** Move agents to `.claude/agents/` directory and add `memory: user` scope for cross-project knowledge.

**Breaking Change:** Architectural change affects agent invocation patterns.

**Benefits:**
- Cross-project knowledge persistence
- Universal TDD patterns available everywhere
- Team conventions shared across projects

**Implementation Notes:**
- Move agents from `sdlc/agents/*.md` to `sdlc/.claude/agents/*.md`
- Add `memory: user` to red, green, domain, code-reviewer, discovery agents
- Create user-level memory categories in `~/.claude/memory/user/`
- Update memory-protocol skill documentation
- Add memory migration tool to remember skill

---

#### P3.2: Action-only skills (v11.1.0)
**Effort:** 3-4 hours | **Status:** Deferred

**Description:** Use `disable-model-invocation: true` for instant status checks (<1 second response).

**Skills to Convert:**
- `/sdlc:status` - Current workflow state
- Create `/sdlc:current` - Active task/PR summary
- Create `/sdlc:next` - Next available task

**Benefits:**
- Instant response (no LLM inference)
- Lower cost (no model invocation)
- Better UX for frequent status checks

**Implementation:** Add frontmatter field, ensure pure data output

---

#### P3.3: Hide internal skills (v11.1.1)
**Effort:** 0.5 hours | **Status:** Deferred

**Description:** Set `user-invocable: false` for portable skills to clean up skill list UI.

**Skills to Hide:**
- tdd-constraints
- memory-protocol
- user-input-protocol
- orchestration-protocol
- debugging-protocol
- event-modeling
- git-spice
- atomic-design
- task-management

**Result:** 13 user-visible workflow skills, 9 internal portable skills

**Implementation:** Add `user-invocable: false` to skill frontmatter

---

#### P3.4: Smart test selection (v11.2.0)
**Effort:** 10-12 hours | **Status:** Deferred

**Description:** RED agent suggests highest-value tests based on coverage gaps.

**Features:**
- Parse coverage reports (lcov, cobertura, coverage.py)
- Identify uncovered code paths
- Suggest tests for high-risk, low-coverage areas
- Test impact analysis (what changed recently?)

**Integration:**
- Language-specific: pytest-cov, cargo-tarpaulin, nyc
- Extract coverage data before RED phase
- Show coverage gaps as test candidates

**Benefits:**
- Guided test writing (not just "write tests")
- Focus on high-value coverage improvements
- Catch untested edge cases

---

#### P3.5: Interactive onboarding (v11.3.0)
**Effort:** 12-15 hours | **Status:** Deferred

**Description:** 5-minute guided TDD tutorial for first-time users.

**Features:**
- Create `/sdlc:onboard` skill
- Auto-invoke on first `/sdlc:setup` run
- Demo project (todo list or calculator)
- Walk through RED → GREEN → DOMAIN cycle
- Show hook enforcement in action
- Complete full cycle to PR

**Interactive Elements:**
- User confirms understanding before proceeding
- Optional skip for experienced users
- Progress saved in `.claude/sdlc.yaml`

**Post-Onboarding:**
- Offer to continue with demo or start real project
- Link to full documentation

---

#### P3.6: Workflow templates (v11.4.0)
**Effort:** 6-8 hours | **Status:** Deferred

**Description:** Pre-configured templates for common project types.

**Templates:**
- **api-development** - REST/GraphQL APIs
- **ui-development** - React/Vue/Svelte components
- **cli-development** - Command-line tools
- **library-development** - Reusable libraries

**Each Template Includes:**
- Pre-configured test commands
- Common tools/frameworks setup
- Example Event Modeling workflows
- Recommended output style

**Usage:**
```bash
/sdlc:setup --template=api-development
# 10-minute setup → 2 minutes
```

**Custom Templates:**
- Users can create custom templates
- Store in `.claude/sdlc-templates/`

---

## Implementation Priority

### Immediate (Next Version)
- Update plugin version to v10.1.0 in plugin.json and marketplace.json
- Update CHANGELOG.md with P0 and P1 improvements
- Test async mutation hooks in real projects

### Short-Term (v11.0.0 - v11.2.0)
- P3.3: Hide internal skills (quick win, 0.5h)
- P3.2: Action-only skills (good UX improvement, 3-4h)
- P3.1: Memory scopes (breaking change, requires testing, 6-8h)

### Medium-Term (v11.3.0 - v11.4.0)
- P3.4: Smart test selection (high value, moderate effort, 10-12h)
- P3.6: Workflow templates (good onboarding, 6-8h)

### Long-Term
- P3.5: Interactive onboarding (significant effort, 12-15h)

---

## Research Foundations

This roadmap is based on verified research:

**AI-Augmented Development (2026):**
- Layered AI setup amplifies system quality
- Good foundations → faster; messy → faster into problems

**TDD Best Practices:**
- Small, focused tests (single behavior)
- Run tests after every change (cycle-end verification)
- Avoid skipping Red-Green-Refactor steps

**Event Modeling (Adam Dymitruk):**
- Information completeness test
- Cross-functional collaboration
- Flat cost curve (independent workflow steps)

**Domain-Driven Design:**
- Make illegal states unrepresentable
- Type system prevents runtime errors
- Reject invalid states at boundaries

**Mutation Testing:**
- 100% coverage impractical
- Look for patterns in survivors
- Incremental analysis (withHistory)

---

## Claude Code Capability Verification

All features verified against [Claude Code Official Documentation](https://code.claude.com/docs) (2026-02-05):

**✅ Verified Supported:**
- Async hooks (`async: true`) - 10-minute timeout, info-only
- Agent-based hooks (`type: agent`) - up to 50 turns, 60-second timeout
- SessionStart with CLAUDE_ENV_FILE - write exports to file
- Dynamic context injection (`!command!` syntax) - skills preprocessing
- Memory scopes (`memory: user/project`) - subagents only
- PostToolUseFailure hooks - info-only error guidance
- Skill invocation modes (`disable-model-invocation`, `user-invocable`)

**❌ Not Supported / Alternatives Used:**
- Output style metadata - use frontmatter only
- Global skills manifest field - use plugin `skills/` directory
- Background agent parameter - user Ctrl+B, or checkpoint recovery

---

## Version History

### v10.1.0 (2026-02-05)
- feat: P1 high-value capabilities (async hooks, agent verification, env files)
- 6 items implemented, 1 simplified (checkpoint recovery)

### v10.0.1 (2026-02-05)
- fix: P0 critical fixes (documentation debt, infrastructure)
- 4 items fully implemented

### v10.0.0 (2026-02-04)
- feat: Context preservation, learning agents, interactive onboarding
- Major architectural improvements

---

## Contributing

To propose new improvements:
1. Verify feature against [Claude Code docs](https://code.claude.com/docs)
2. Research industry best practices
3. Estimate effort (hours) and breaking changes
4. Add to appropriate phase (P0-P3) in this document
5. Include implementation notes and verification sources

**Prioritization Criteria:**
- P0: Critical (docs accuracy, infrastructure stability)
- P1: High value (verified capabilities, significant UX improvement)
- P2: Quality (technical debt, maintainability)
- P3: Polish (nice-to-have, advanced features)
