# Skill Management in SDLC Plugin

Guide to understanding how skills are shared and loaded in the SDLC plugin.

## Plugin Skills Directory

The SDLC plugin provides skills through the `skills/` directory:

```
sdlc/
├── skills/           # All plugin skills
│   ├── setup/        # Workflow skills (user-invocable)
│   ├── work/
│   ├── pr/
│   └── ...
│   ├── tdd-constraints/      # Portable skills (internal)
│   ├── memory-protocol/
│   ├── orchestration-protocol/
│   └── ...
```

**Two types of skills:**

1. **Workflow skills** (13 total) - User-invocable commands
   - Invoked via `/sdlc:skill-name` (e.g., `/sdlc:setup`, `/sdlc:work`)
   - `user-invocable: true` or omitted (default true)
   - Visible in skill list

2. **Portable skills** (9 total) - Internal frameworks
   - Loaded by agents via `skills:` frontmatter
   - `user-invocable: false` (hidden from users)
   - Framework-agnostic patterns

## How Skills Are Shared

### Plugin Skills Directory Auto-Discovery

Claude Code automatically discovers skills in `sdlc/skills/`:

- **NO** `globalSkills` field needed in plugin.json
- **NO** manual skill registration
- Just place skill directories in `skills/` and they're available

**Plugin manifest:**
```json
{
  "name": "sdlc",
  "skills": "./skills/"  # All skills auto-discovered
}
```

### Agent Skill Loading

Agents load skills via frontmatter:

```yaml
---
name: red
skills:
  - tdd-constraints    # Loaded from sdlc/skills/tdd-constraints/
  - memory-protocol    # Loaded from sdlc/skills/memory-protocol/
---
```

**Path resolution:**
- Skills loaded from `sdlc/skills/<skill-name>/`
- No explicit path needed (relative to plugin skills directory)

## Skill Dependency Audit

### Current Agent → Skill Dependencies

| Agent | Skills Loaded | Purpose |
|-------|---------------|---------|
| red | tdd-constraints, memory-protocol, user-input-protocol | Test writing with TDD discipline |
| green | tdd-constraints, memory-protocol, user-input-protocol | Production code with TDD discipline |
| domain | tdd-constraints, memory-protocol, user-input-protocol | Type definitions with TDD discipline |
| code-reviewer | memory-protocol, user-input-protocol | Review with context persistence |
| discovery | memory-protocol, user-input-protocol, event-modeling | Domain discovery facilitation |
| workflow-designer | memory-protocol, user-input-protocol, event-modeling | Event model workflow design |
| gwt | memory-protocol, user-input-protocol, event-modeling | GWT scenario generation |
| model-checker | memory-protocol, user-input-protocol, event-modeling | Event model validation |
| design-facilitator | memory-protocol, user-input-protocol, event-modeling | Architecture design decisions |
| architect | arch, memory-protocol, user-input-protocol | Architecture changes |
| story | memory-protocol, user-input-protocol | Story value assessment |
| ux | memory-protocol, user-input-protocol | UX coherence review |
| mutation | (none) | Mutation testing runner |
| file-updater | memory-protocol, user-input-protocol | Config/docs/scripts updates |
| hook-verifier | orchestration-protocol | Hook precondition verification |

### Redundancy Analysis

**Frequently loaded together:**
- `memory-protocol` + `user-input-protocol` (13 agents)
- `memory-protocol` + `user-input-protocol` + `tdd-constraints` (3 agents)
- `memory-protocol` + `user-input-protocol` + `event-modeling` (4 agents)

**Why not consolidate?**

1. **Clear dependencies** - Each skill has specific purpose
2. **Selective loading** - Not all agents need all skills
3. **Plugin architecture** - Skills in `skills/` are auto-discovered, no "global" config needed
4. **Portability** - Skills designed for reuse across projects/plugins

## Best Practices

### For Plugin Authors

1. **Organize skills by purpose:**
   - Workflow skills in top-level directories
   - Portable skills grouped by category

2. **Use `user-invocable: false`** for internal skills:
   ```yaml
   ---
   user-invocable: false
   name: tdd-constraints
   ---
   ```

3. **Document skill dependencies** in agent frontmatter:
   ```yaml
   ---
   name: my-agent
   skills:
     - skill-name  # Comment explaining why this skill is needed
   ---
   ```

4. **Avoid circular dependencies:**
   - Skills should not load other skills
   - Keep skills independent

### For Agent Authors

1. **Load only what you need:**
   - Don't copy skill lists from other agents
   - Each skill adds startup overhead

2. **Document why each skill is loaded:**
   - Add comments in frontmatter
   - Makes auditing easier later

3. **Check skill compatibility:**
   - Ensure skill works with agent's tools
   - Some skills require specific tool access

## Skill Discovery

Users can discover plugin skills:

```bash
# List all skills
skills list

# Search for specific pattern
skills search "memory"

# Install from plugin
npx skills add jwilger/claude-code-plugins
```

## Future Improvements

Potential optimizations (not currently implemented):

1. **Skill bundles** - Group commonly-used skills
2. **Lazy loading** - Load skills only when needed
3. **Skill versioning** - Lock skills to specific versions
4. **Dependency graphs** - Visualize skill relationships

## Related Documentation

- [Plugin Structure](../.claude-plugin/plugin.json)
- [Portable Skills](../skills/README.md)
- [Agent Development](./agent-development.md)
