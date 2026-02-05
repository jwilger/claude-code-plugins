# sdlc Plugin Redesign: Implementation Summary

**Date:** 2026-02-04
**Analysis Version:** 1.0
**Status:** ✅ Analysis Complete - Ready for Implementation

---

## Executive Summary

This analysis documents the implementation approach for redesigning the sdlc plugin v3.12.8 to integrate Claude Code's tasks system and extract 10 portable skills for distribution via skills.sh marketplace.

**Key Finding:** The sdlc plugin is exceptionally well-positioned for this redesign. The current architecture already cleanly separates shared protocols from agent-specific logic, making skill extraction straightforward and low-risk.

**Confidence Level:** 85% - High confidence based on:
- Clear architectural boundaries already exist
- Skills are already well-factored (commands/shared/)
- Task system is well-documented and proven
- Migration path is incremental and backward compatible
- No blocking dependencies identified

---

## What This Redesign Would Achieve

### 1. Portable Skills (Teaching Layer)

**Extract 10 reusable protocols as standalone skills:**

| Skill | Purpose | Portability | Priority |
|-------|---------|-------------|----------|
| tdd-constraints | Red/green/domain phase boundaries | Universal | HIGH |
| user-input-protocol | Checkpoint/question format | Universal | HIGH |
| debugging-protocol | Systematic debugging methodology | Universal | HIGH |
| atomic-design | UI component hierarchy | Universal | HIGH |
| git-spice | Stacked PR workflow patterns | Tool-specific | MEDIUM |
| github-issues | GitHub CLI patterns | Tool-specific | MEDIUM |
| memory-protocol | Memento MCP integration | MCP-specific | MEDIUM |
| event-modeling | Event Modeling patterns | High | MEDIUM |
| orchestration-protocol | Agent delegation rules | Medium | MEDIUM |
| skill-enforcement | DEPRECATED | N/A | LOW |

**Benefits:**
- **Wider Distribution:** Install via `npx skills add jwilger/claude-code-plugins`
- **Cross-Platform:** Work in Cursor, Windsurf, Cline, etc.
- **Independent Versioning:** Skills evolve separately from plugin
- **Discoverability:** skills.sh marketplace listing with telemetry

### 2. Task-Based Workflow (Structural Layer)

**Replace prompt-based invocation gates with task dependencies:**

**Current (v3.12.8):**
```
Orchestrator: "RED_CONTEXT: FIRST_TEST, ACCEPTANCE_CRITERIA: ..."
Agent: Validates context, rejects if invalid
```

**Future (v4.0.0):**
```javascript
TaskCreate("Write failing test");
TaskCreate("Create types", blockedBy: [redTask]);  // Cannot start until red completes
TaskCreate("Implement code", blockedBy: [domainTask]);  // Cannot start until domain completes
```

**Benefits:**
- **Mechanical Enforcement:** Cannot start blocked tasks (structural guarantee)
- **Persistent State:** Tasks survive session restarts
- **Progress Tracking:** TaskList shows ✓ completed, ◻ pending, ▲ blocked
- **Resumability:** Pick up where you left off
- **Parallel Workflows:** Multiple independent task chains (worktrees)

### 3. Lightweight Agents (Validation Layer)

**Transform agents from heavy protocol duplicators to skill loaders:**

**Before:** 400-line agent with duplicated protocol content
**After:** 200-line agent that loads skills, uses tasks, preserves hooks

**Agent restructuring:**
- Remove sdlc:shared/ prefix from skill references
- Add TaskGet/TaskUpdate tools for task awareness
- Replace invocation gates with TaskList checking
- Preserve hooks (unchanged - critical validation)
- Reduce prompt size (skills handle protocols)

**New orchestrator agent:**
- Haiku model (fast, cheap for coordination)
- disallowedTools: Write, Edit (delegation only)
- Creates task graphs, spawns subagents, monitors progress

---

## Implementation Phases

### Phase 1: Analysis and Extraction ✅ COMPLETE

**What was done:**
- ✅ Analyzed 15 agents, 10 shared protocols, 11 commands
- ✅ Identified extractable components
- ✅ Mapped task-suitable workflows
- ✅ Documented integration patterns
- ✅ Created comprehensive implementation analysis

**Deliverables:**
- implementation-analysis.md (43 pages)
- skill-extraction-plan.md (22 pages)
- agent-restructuring-plan.md (27 pages)
- task-integration-patterns.md (25 pages)
- SUMMARY.md (this document)

### Phase 2: Skill Structure Design 📋 READY

**What would be done:**
- Design skills/ directory structure
- Create SKILL.md template with frontmatter
- Define skill naming conventions
- Design metadata schema
- Plan npx skills installation workflow

**Estimated Effort:** 2-3 days
**Risk:** LOW - Clear format, proven examples

### Phase 3: Task Integration Patterns 📋 READY

**What would be done:**
- Define task metadata schema (SDLCTaskMetadata)
- Create task dependency patterns (TDD cycle, code review, etc.)
- Design invocation gate migration (3 phases)
- Document agent self-assignment pattern
- Identify background task candidates

**Estimated Effort:** 2-3 days
**Risk:** LOW - Schemas defined, patterns documented

### Phase 4: Skill Extraction 📋 READY

**What would be done:**
- Extract 10 skills in recommended order:
  1. user-input-protocol (simplest)
  2. debugging-protocol
  3. atomic-design
  4. tdd-constraints (core)
  5. git-spice
  6. github-issues
  7. memory-protocol
  8. event-modeling
  9. orchestration-protocol (most complex)
  10. skill-enforcement (deprecate)

**Estimated Effort:** 5-7 days (0.5-1 day per skill)
**Risk:** LOW - Protocols are documentation-only, clear transformation

### Phase 5: Agent Restructuring 📋 READY

**What would be done:**
- Create new orchestrator agent
- Update core TDD agents (red, green, domain)
- Restructure code-reviewer as task-based
- Update mutation agent for background tasks
- Update remaining 11 agents
- Verify all skill references

**Estimated Effort:** 7-10 days
**Risk:** MEDIUM - Complex changes, thorough testing needed

### Phase 6: Marketplace Integration 📋 READY

**What would be done:**
- Create skills/README.md
- Test npx skills installation
- Update marketplace.json
- Submit to skills.sh
- Verify Claude Code discovery

**Estimated Effort:** 2-3 days
**Risk:** LOW - Installation workflow defined, marketplace submission straightforward

### Phase 7: Documentation and Migration 📋 READY

**What would be done:**
- Create MIGRATION.md (v3.12.8 → v4.0.0 guide)
- Update CLAUDE.md (architecture docs)
- Create CHANGELOG.md (comprehensive history)
- Update setup.md (version 4.0.0)
- Create task-workflows.md examples
- Create TROUBLESHOOTING.md

**Estimated Effort:** 3-5 days
**Risk:** LOW - Documentation templates provided

**Total Estimated Effort:** 18-26 days (3.5-5 weeks)

**Revised from original 21-31 days due to:**
- ✅ Removed: Gate migration complexity (-2 days)
- ✅ Removed: Dedicated orchestrator agent (-2 days)
- ✅ Removed: Custom cleanup logic (-1 day)
- ➕ Added: Agent resumption pattern (+1 day)
- ➕ Added: Background execution testing (+1 day)
- **Net savings: -3 days**

---

## Key Findings

### Strengths of Current Architecture

1. **Clean Separation:** Shared protocols (commands/shared/) vs agents (agents/) already separated
2. **Well-Factored:** 10 protocols are documentation-only, no executable code
3. **Clear Boundaries:** Hooks in agents, protocols in shared, no overlap
4. **Consistent Patterns:** All agents reference skills via frontmatter uniformly

### Opportunities for Improvement

1. **Invocation Gates:** Replace with task dependencies (mechanical enforcement)
2. **Protocol Duplication:** Extract to skills (compose vs duplicate)
3. **Workflow State:** Use task metadata (persistent across sessions)
4. **Parallel Execution:** Enable via background tasks (mutation testing)
5. **Wider Distribution:** skills.sh marketplace (beyond Claude Code users)

### Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Task system scalability | Medium | High | Test with 50+ tasks, implement cleanup |
| Skill discovery after extraction | Low | Critical | Test loading, verify search paths |
| Backward compatibility breaking | Medium | High | Maintain command interface, support gates |
| Background task MCP limitation | High | Medium | Use task metadata, foreground for MCP |
| Agent self-assignment complexity | Medium | Medium | Start orchestrator-driven, phase in |

**Overall Risk:** LOW - Well-planned, incremental approach, backward compatible

---

## Implementation Readiness Assessment

### ✅ Ready to Proceed

**Phase 2-4 (Skill Extraction):**
- Clear extraction candidates identified
- SKILL.md format defined
- Extraction order planned
- Validation checklists created
- **Confidence:** 95%

**Phase 3 (Task Patterns):**
- Metadata schema defined
- Dependency patterns documented
- Migration path clear
- Examples provided
- **Confidence:** 90%

### ⚠️ Requires Additional Planning

**Phase 5 (Agent Restructuring):**
- High-risk changes (code-reviewer, orchestrator)
- Extensive testing needed
- Backward compatibility critical
- **Confidence:** 80%
- **Action:** Create detailed testing plan before implementation

### ✅ All Decisions Finalized (2026-02-04)

**Architectural decisions resolved:**
1. **Skill distribution:** ✅ Same repository (claude-code-plugins/skills/)
2. **Invocation gate timeline:** ✅ Aggressive removal - no gates in v4.0.0 (tasks only)
3. **Orchestrator approach:** ✅ Task-based orchestration in main conversation
4. **Background tasks:** ✅ Background by default + agent resumption pattern (NEW)
5. **Skill naming:** ✅ Generic names (tdd-constraints, not jwilger-tdd-constraints)
6. **Task cleanup:** ✅ Rely on Claude Code built-in cleanup (no custom code)

**See:** `.prompts/003-tasks-skills-implement/DECISIONS.md` for complete rationale

**Key Discovery:** Agent resumption pattern enables background agents to ask questions indirectly by pausing, storing question in task metadata, and resuming with user's answer. Critical for v4.0.

---

## Migration Path for Existing Users

### Backward Compatibility Strategy

**v4.0.0 Changes:**
- All commands work unchanged (/sdlc:work, /sdlc:review, etc.)
- Task creation is internal (transparent to users)
- Skills loaded from top-level (agents updated automatically)
- Invocation gates still supported (Phase 1 migration)

**No Breaking Changes for:**
- Command interfaces
- Agent invocations
- Workflow patterns
- External integrations (gh CLI, git-spice, Memento)

**Breaking Changes for:**
- Plugin customizers (must update skill references)
- Forked agents (must update skills: field)

### Migration Steps

1. **Update plugin:** `git pull origin main`
2. **Re-run setup:** `/sdlc:setup` (preserves config, installs skills)
3. **Verify installation:** Check .claude/skills/ directory
4. **Test workflow:** Run /sdlc:work, observe tasks in TaskList
5. **Report issues:** GitHub issues or email

**Rollback:** `git checkout tags/v3.12.8` + `/sdlc:setup`

---

## Success Metrics

### Quantitative Metrics

**Plugin Adoption:**
- Skills.sh install count (target: 100+ installs in first 3 months)
- Cross-platform usage (target: 3+ agent frameworks)
- GitHub stars/forks (measure community interest)

**Performance:**
- Context reduction (target: 30-40% smaller agent prompts)
- Task system overhead (target: < 100ms per task operation)
- Workflow completion time (target: equivalent or faster)

**Quality:**
- Bug reports (target: < 5 critical bugs in first month)
- Backward compatibility issues (target: 0)
- Migration success rate (target: 95% smooth migrations)

### Qualitative Metrics

**User Feedback:**
- Task-based workflow clarity
- Skill installation experience
- Documentation quality
- Migration guide effectiveness

**Developer Experience:**
- Skill composition patterns
- Task debugging ease
- Error messages clarity

---

## Recommendations

### Immediate Actions (Before Code Changes)

1. **✅ Review this analysis** - Ensure alignment with goals
2. **📋 Get user input on open questions** - Resolve decision points
3. **📋 Create GitHub milestone for v4.0.0** - Track progress
4. **📋 Set up test environment** - Fork for v4.0.0 testing
5. **📋 Create detailed testing plan** - Phase 5 validation

### Implementation Sequence

**Week 1-2: Foundation**
- Phase 2: Skill structure design
- Phase 3: Task integration patterns
- Create testing plan

**Week 3-4: Extraction**
- Phase 4: Extract all 10 skills
- Test skill installation
- Verify skill loading

**Week 5-7: Restructuring**
- Phase 5: Create orchestrator
- Update core TDD agents
- Restructure code-reviewer
- Update remaining agents

**Week 8: Integration & Testing**
- Phase 6: Marketplace integration
- Phase 7: Documentation
- Comprehensive testing
- User acceptance testing

**Week 9: Release**
- Create v4.0.0 release
- Submit to skills.sh
- Announce to users
- Monitor for issues

### Long-Term Evolution

**v4.1.0 (2-3 months after v4.0.0):**
- Phase 2 invocation gate migration (tasks primary)
- Feature-based task cleanup
- Background task patterns validated
- Agent self-assignment (optional)

**v4.2.0 (4-6 months after v4.0.0):**
- Skills versioned independently
- Marketplace analytics integration
- Enhanced task metadata schemas

**v5.0.0 (1 year after v4.0.0):**
- Phase 3 invocation gate migration (tasks only)
- Remove deprecated shared protocols
- Pure task-based workflows

---

## Conclusion

**This redesign is READY for implementation.**

**Key Strengths:**
- ✅ Well-factored current architecture
- ✅ Clear extraction boundaries
- ✅ Low-risk incremental approach
- ✅ Backward compatible migration
- ✅ Comprehensive documentation

**Next Step:** Proceed with Phase 2 (Skill Structure Design) after resolving open questions.

**Expected Outcome:** v4.0.0 release in 6-9 weeks with:
- 10 portable skills on skills.sh marketplace
- Task-based workflow orchestration
- Lightweight skill-loading agents
- Smooth migration from v3.12.8
- Foundation for long-term evolution

**This analysis provides a complete roadmap from current state to future state. Ready to implement.**

---

## Document Index

### Analysis Documents

1. **implementation-analysis.md** (43 pages)
   - Phase-by-phase implementation approach
   - File-by-file change analysis
   - Risk assessment and mitigation
   - Open questions for user input

2. **skill-extraction-plan.md** (22 pages)
   - 10 skill candidates with rationale
   - Extraction complexity assessment
   - Portability considerations
   - SKILL.md transformation examples

3. **agent-restructuring-plan.md** (27 pages)
   - Before/after conceptual examples
   - Skill loading patterns
   - Backward compatibility approach
   - Agent-by-agent summary

4. **task-integration-patterns.md** (25 pages)
   - Task metadata schema
   - Dependency patterns (TDD, review, PR)
   - Resumption patterns
   - Invocation gate migration

5. **SUMMARY.md** (this document) (11 pages)
   - Executive summary
   - Implementation readiness
   - Success metrics
   - Recommendations

**Total Documentation:** 128 pages of comprehensive implementation planning

---

**Analysis Status:** ✅ COMPLETE

**Next Phase:** Skill Structure Design (Phase 2)

**Estimated Time to v4.0.0 Release:** 6-9 weeks

**Confidence in Success:** 85% (HIGH)
