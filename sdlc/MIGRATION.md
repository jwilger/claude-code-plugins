# Migration Guide: sdlc v3.x → v4.0.0

**Breaking changes in v4.0.0.** This guide helps you migrate from v3.x to v4.0.0.

---

## What Changed

### 1. Invocation Gates Removed ❌

**v3.x:** Agents had manual confirmation gates requiring orchestrator to pass context blocks:

```
RED_CONTEXT: FIRST_TEST
ACCEPTANCE_CRITERIA:
- User can create account
```

**v4.0.0:** Task dependencies replace manual gates:

```javascript
const redTask = await TaskCreate({
  subject: "Write failing test",
  metadata: { phase: "red" }
});

const domainTask = await TaskCreate({
  subject: "Create domain types",
  metadata: { phase: "domain-after-red" }
});

await TaskUpdate({
  taskId: domainTask.id,
  addBlockedBy: [redTask.id]  // Mechanical enforcement
});
```

**Why:** Task dependencies enforce workflow mechanically, eliminating human error and enabling visual workflow state.

---

### 2. Protocols Extracted as Skills ✨

**v3.x:** Protocols were inline in agent files or loaded via `sdlc:shared/*`:

```yaml
skills:
  - sdlc:shared/user-input-protocol
  - sdlc:shared/tdd-constraints
```

**v4.0.0:** Protocols are portable, installable skills:

```yaml
skills:
  - user-input-protocol
  - tdd-constraints
```

**Installation:**

```bash
npx skills add jwilger/claude-code-plugins
```

**Benefits:**
- Skills work in Cursor, Windsurf, Cline, and other frameworks
- Versioned independently
- Discoverable via skills.sh marketplace
- Framework-agnostic examples

---

### 3. Skill Enforcement Deprecated 🗑️

**v3.x:** `sdlc:shared/skill-enforcement` protocol with "1% rule" and rationalization checks

**v4.0.0:** Removed entirely. No backward compatibility shim.

**Why:** Task dependencies mechanically enforce workflow. Manual "should I use this skill?" checks are obsolete.

---

## Migration Steps

### Step 1: Update Plugin

```bash
# Pull latest version
git pull origin main

# Or update via Claude Code
/plugin
```

### Step 2: Install Extracted Skills

```bash
npx skills add jwilger/claude-code-plugins
```

This installs 9 skills:
- `user-input-protocol`
- `debugging-protocol`
- `atomic-design`
- `tdd-constraints`
- `git-spice`
- `github-issues`
- `memory-protocol`
- `event-modeling`
- `orchestration-protocol`

### Step 3: Update Custom Agents (If Any)

If you created custom agents that referenced old shared protocols:

**Before:**
```yaml
skills:
  - sdlc:shared/user-input-protocol
  - sdlc:shared/tdd-constraints
```

**After:**
```yaml
skills:
  - user-input-protocol
  - tdd-constraints
```

### Step 4: Remove Invocation Gate Confirmations

If you have custom workflows or scripts that generated gate confirmations:

**Remove this pattern:**
```
RED_CONTEXT: FIRST_TEST
ACCEPTANCE_CRITERIA:
- ...
```

**Replace with task creation:**
```javascript
const task = await TaskCreate({
  subject: "Write test for user creation",
  description: "Test should verify email validation",
  metadata: { phase: "red", feature: "auth" }
});
```

### Step 5: Test TDD Workflow

Run through a complete TDD cycle to verify:

```bash
# Start a new feature
/sdlc:work

# When prompted, describe feature
# Observe automatic task creation and dependencies
# Verify agents complete tasks in sequence
```

Expected behavior:
- Red agent creates failing test
- Domain agent reviews and creates types (blocked until red completes)
- Green agent implements (blocked until domain completes)
- Domain agent reviews implementation (blocked until green completes)

---

## Breaking Changes Summary

| Feature | v3.x | v4.0.0 | Action Required |
|---------|------|--------|-----------------|
| **Invocation Gates** | Manual confirmations | Task dependencies | Update workflows to use TaskCreate |
| **Skill References** | `sdlc:shared/*` | Skill names | Update agent YAML |
| **Skill Enforcement** | Explicit protocol | Removed | Remove references |
| **Protocol Files** | `sdlc/commands/shared/*.md` | `skills/*/SKILL.md` | None (auto-loaded) |

---

## What Stayed the Same

### ✅ TDD Workflow

Red → Domain → Green → Domain cycle unchanged. Same principles, mechanical enforcement.

### ✅ Agent Specialization

Same agents with same responsibilities:
- `sdlc:red` - Test code only
- `sdlc:green` - Implementation only
- `sdlc:domain` - Type definitions only
- All other agents unchanged

### ✅ File Ownership Patterns

Agents still enforce file type restrictions via hooks.

### ✅ Event Modeling

Discovery, workflow design, GWT, and model checking workflows unchanged.

### ✅ GitHub Integration

PR workflow, issue linking, and git-spice patterns unchanged.

---

## Troubleshooting

### "Skill not found: sdlc:shared/user-input-protocol"

**Problem:** Agent still references old shared protocol path

**Solution:** Update agent YAML to use skill name:

```yaml
# Wrong
skills:
  - sdlc:shared/user-input-protocol

# Right
skills:
  - user-input-protocol
```

### "INVOCATION GATE FAILED"

**Problem:** Using v3.x workflow with v4.0.0 plugin

**Solution:** Stop passing manual confirmation blocks. Use TaskCreate instead:

```javascript
const task = await TaskCreate({
  subject: "Your task description",
  metadata: { phase: "red" }
});
```

### Skills don't load in agent

**Problem:** Skills not installed

**Solution:**

```bash
npx skills add jwilger/claude-code-plugins
npx skills list  # Verify installation
```

### Agent can't see skill content

**Problem:** Skill file missing or malformed

**Solution:** Verify skill file exists:

```bash
ls skills/user-input-protocol/SKILL.md
# Should exist and have YAML frontmatter
```

---

## FAQ

### Q: Can I still use v3.x?

**A:** Yes, but v3.x is no longer maintained. No security updates or bug fixes.

### Q: Do I need to reinstall the plugin?

**A:** No. `/plugin` or `git pull` updates in place.

### Q: Will my existing projects break?

**A:** No. TDD workflow unchanged. Task system is backward compatible.

### Q: Can I use the skills in other frameworks?

**A:** Yes! Skills are framework-agnostic. Install via `npx skills` in Cursor, Windsurf, or Cline.

### Q: What if I don't want to use tasks?

**A:** Tasks are central to v4.0.0. If you prefer v3.x manual workflow, stay on v3.x.

### Q: Are the extracted skills versioned separately?

**A:** Yes. Each skill has independent semver in its SKILL.md frontmatter.

### Q: How do I contribute to a skill?

**A:** Submit PR to `skills/<skill-name>/SKILL.md`. Follow contribution guidelines in `skills/README.md`.

---

## Support

**Issues:** https://github.com/jwilger/claude-code-plugins/issues
**Discussions:** https://github.com/jwilger/claude-code-plugins/discussions
**Email:** john@johnwilger.com

---

## Version History

- **v3.12.8** (2026-02-04): Last v3.x release
- **v4.0.0** (2026-02-04): Task-based workflow, extracted skills, removed invocation gates

---

**Migration complete!** You should now have a fully functional v4.0.0 setup with portable skills and task-based workflow enforcement.
