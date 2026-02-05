# sdlc Plugin Redesign Roadmap

Visual representation of phase dependencies and deliverables.

## Phase Dependency Graph

```
Phase 1: Analysis & Extraction
    │
    ├─→ Phase 2: Skill Structure Design
    │       │
    │       └─→ Phase 4: Skill Extraction ──┐
    │                                        │
    └─→ Phase 3: Task Integration Pattern   │
            │                                │
            └─→ Phase 4: Skill Extraction ───┤
                    │                        │
                    └─→ Phase 5: Agent Restructuring
                            │
                            ├─→ Phase 6: Marketplace Integration
                            │       │
                            └───────┴─→ Phase 7: Documentation & Migration
```

## Timeline Estimate

| Phase | Complexity | Estimated Effort | Can Parallelize |
|-------|-----------|------------------|-----------------|
| Phase 1: Analysis & Extraction | Medium | 1-2 days | No (foundation) |
| Phase 2: Skill Structure Design | Low | 0.5-1 day | After Phase 1 |
| Phase 3: Task Integration Pattern | Medium | 1-2 days | After Phase 1 |
| Phase 4: Skill Extraction | High | 3-5 days | After Phases 2+3 |
| Phase 5: Agent Restructuring | High | 4-6 days | After Phase 4 |
| Phase 6: Marketplace Integration | Medium | 1-2 days | After Phase 5 |
| Phase 7: Documentation & Migration | Medium | 2-3 days | After Phases 5+6 |

**Total Estimated Effort:** 12-21 days (varies by familiarity and iteration)

**Parallelization Opportunities:**
- Phases 2 and 3 can run in parallel after Phase 1 completes
- Phase 6 and 7 can partially overlap (doc work while testing marketplace)

## Deliverables by Phase

### Phase 1: Analysis & Extraction
- [ ] agents-inventory.md (15 agents documented)
- [ ] skills-extraction-map.md (10 protocols mapped)
- [ ] task-workflows.md (3+ workflows identified)
- [ ] external-integrations.md (gh, git-spice, memento)

### Phase 2: Skill Structure Design
- [ ] skill-structure.md (directory layout, naming)
- [ ] templates/SKILL.template.md (reusable template)
- [ ] skill-installation.md (npx workflows)
- [ ] repository-structure.md (GitHub organization)

### Phase 3: Task Integration Pattern
- [ ] task-patterns.md (creation patterns, metadata schema)
- [ ] tdd-task-graph.md (red → domain → green → domain)
- [ ] task-metadata-schema.json (standard fields)
- [ ] gate-to-task-migration.md (phased migration)

### Phase 4: Skill Extraction
- [ ] skills/tdd-constraints/SKILL.md
- [ ] skills/orchestration-protocol/SKILL.md
- [ ] skills/memory-protocol/SKILL.md
- [ ] skills/user-input-protocol/SKILL.md
- [ ] skills/event-modeling/SKILL.md
- [ ] skills/github-issues/SKILL.md
- [ ] skills/git-spice/SKILL.md
- [ ] skills/debugging-protocol/SKILL.md
- [ ] skills/atomic-design/SKILL.md
- [ ] skills/skill-enforcement/SKILL.md (optional)

### Phase 5: Agent Restructuring
- [ ] sdlc/agents/orchestrator.md (new)
- [ ] sdlc/agents/red.md (updated)
- [ ] sdlc/agents/domain.md (updated)
- [ ] sdlc/agents/green.md (updated)
- [ ] sdlc/agents/code-reviewer.md (updated, task-based)
- [ ] sdlc/agents/mutation.md (updated, background-ready)
- [ ] sdlc/agents/[remaining 9 agents].md (updated)
- [ ] agents-migration.md (change log)

### Phase 6: Marketplace Integration
- [ ] skills/README.md (installation guide)
- [ ] skills/examples/ (usage examples)
- [ ] .claude-plugin/marketplace.json (updated)
- [ ] Installation verification tests
- [ ] skills.sh submission confirmation

### Phase 7: Documentation & Migration
- [ ] MIGRATION.md (v3.12.8 → v4.0.0)
- [ ] CLAUDE.md (updated architecture)
- [ ] CHANGELOG.md (comprehensive changes)
- [ ] sdlc/commands/setup.md (v4.0.0)
- [ ] docs/task-workflows.md (patterns)
- [ ] skills/USAGE.md (examples)
- [ ] docs/TROUBLESHOOTING.md (common issues)
- [ ] Updated manifests (v4.0.0)

## Critical Path

The critical path (longest dependent chain) is:
1. Phase 1 (analysis) → 2 days
2. Phase 2 (skill structure) → 1 day
3. Phase 4 (extraction) → 4 days
4. Phase 5 (agent restructuring) → 5 days
5. Phase 6 (marketplace) → 1.5 days
6. Phase 7 (documentation) → 2.5 days

**Critical Path Total:** ~16 days

## Risk Mitigation

| Risk | Phase | Mitigation |
|------|-------|------------|
| Skills.sh format changes | 2, 4 | Follow official vercel-labs/skills repo, test early |
| Task system edge cases | 3, 5 | Prototype task patterns in Phase 3 before full agent restructuring |
| Breaking backward compatibility | 5 | Keep invocation gates during migration, test existing commands |
| Skill discovery issues | 6 | Test npx installation early, verify .claude/skills/ loading |
| User adoption resistance | 7 | Comprehensive migration guide, maintain v3.x branch for conservative users |
| Skill portability problems | 4, 6 | Test in multiple agents (Cursor/Windsurf) if accessible |

## Success Metrics

Phase completion verified when:
- **Phase 1:** All agents inventoried, extraction map complete, workflows identified
- **Phase 2:** SKILL.md template follows official format, directory structure planned
- **Phase 3:** TDD cycle modeled as task graph, metadata schema defined
- **Phase 4:** All 10 skills extracted with valid YAML frontmatter, no broken references
- **Phase 5:** All agents load skills from skills/, hooks preserved, commands work
- **Phase 6:** npx skills add installs successfully, skills discoverable by Claude Code
- **Phase 7:** Migration guide tested manually, all versions bumped to 4.0.0

## Next Actions

**Immediate (Phase 1):**
1. Read all 15 agent files, extract skills/tools/hooks
2. Map 10 shared protocols to extraction plan
3. Identify /work, /review, /design for task integration
4. Document gh CLI, git-spice, memento patterns

**After Phase 1 (Parallel):**
- Start Phase 2: Design SKILL.md template and directory structure
- Start Phase 3: Model TDD workflow as task dependency graph

**After Phases 2+3 (Sequential):**
- Phase 4: Extract skills one by one (simplest to most complex)
- Phase 5: Restructure agents to load extracted skills
- Phase 6: Publish and test marketplace integration
- Phase 7: Document everything and create migration guide
