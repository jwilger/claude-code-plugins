# Migration Guide: v8.0.0 → v9.0.0

## Summary

Version 9.0.0 completes the transformation to a fully skills-based architecture. All 12 commands have been migrated to skills, removing the commands infrastructure entirely.

## Breaking Changes

### Commands Removed

All commands have been replaced by skills with equivalent functionality:

| Old Command | New Skill | Invocation |
|-------------|-----------|------------|
| `/sdlc:setup` | `/sdlc:setup` | Unchanged |
| `/sdlc:start` | `/sdlc:start` | Unchanged |
| `/sdlc:work` | `/sdlc:work` | Unchanged |
| `/sdlc:pr` | `/sdlc:pr` | Unchanged |
| `/sdlc:complete` | `/sdlc:complete` | Unchanged |
| `/sdlc:review` | `/sdlc:review` | Unchanged |
| `/sdlc:design` | `/sdlc:design` | Unchanged |
| `/sdlc:plan` | `/sdlc:plan` | Unchanged |
| `/sdlc:adr` | `/sdlc:arch` | **CHANGED** (migrated in v8.0.0) |
| `/sdlc:remember` | `/sdlc:remember` | Unchanged |
| `/sdlc:recall` | `/sdlc:recall` | Unchanged |
| `/sdlc:domain-audit` | `/sdlc:domain-audit` | Unchanged |

**Note:** Plugin skills are namespaced as `/sdlc:<skill-name>` to prevent conflicts with personal/project skills.

### What Changed

1. **Commands directory removed**: `/sdlc/commands/` no longer exists
2. **Skills directory expanded**: All workflow logic now in `/sdlc/skills/`
3. **Auto-invocation enabled**: Claude can now invoke skills based on context without explicit commands
4. **Progressive disclosure**: Skills use supporting reference files loaded on-demand
5. **Improved descriptions**: Skill descriptions include "what AND when" for better auto-invocation

### What Stayed the Same

- **Invocation syntax**: `/sdlc:work`, `/sdlc:pr`, etc. still work exactly the same
- **Hooks**: All hooks preserved in skill frontmatter
- **Allowed tools**: Tool restrictions unchanged
- **Agents**: 14 specialized agents unchanged
- **Output styles**: sdlc-rules and sdlc-marvin unchanged
- **Functionality**: All features work identically

## Migration Steps

### For Users

**If you're using the sdlc plugin:**

No action required! The invocation syntax is unchanged. Just update to v9.0.0:

```bash
# Update will happen automatically when plugin cache refreshes
# Or force update:
claude plugin validate sdlc
```

**Your existing workflows continue to work:**
```bash
/sdlc:setup
/sdlc:work
/sdlc:pr
/sdlc:complete
```

### For Plugin Developers

**If you're building plugins that reference sdlc commands:**

Update references to point to skills instead:

```diff
- See sdlc plugin's `/sdlc:work` command
+ See sdlc plugin's `work` skill
```

**If you're extending the sdlc plugin:**

- Commands are now skills in `/sdlc/skills/<name>/SKILL.md`
- Use the same frontmatter format with `hooks`, `allowed-tools`, `dependencies`
- Skills support progressive disclosure with supporting files (reference.md, examples.md)

## New Features

### Auto-Invocation

Skills can now be invoked automatically by Claude based on context:

**Before (v8.0.0):**
```
User: "I want to start working on a task"
You: "Run /sdlc:work to start working"
User: "/sdlc:work"
```

**After (v9.0.0):**
```
User: "I want to start working on a task"
Claude: [Automatically invokes /sdlc:work skill]
```

Claude determines when to apply skills based on description matching user intent.

### Progressive Disclosure

Skills use supporting files loaded on-demand:
- `SKILL.md` - Core principles and usage patterns (<500 lines recommended)
- `reference.md` - Detailed step-by-step instructions
- `examples.md` - Extended examples

**Benefit:** Context budget savings. Reference files load only when needed.

### Better Descriptions

Skill descriptions now include:
- **What** the skill does
- **When** to use it
- **Keywords** for auto-invocation

Example:
```yaml
description: Start or continue work on an issue. Shows ready tasks, creates branch, marks task active. Use when beginning work, switching tasks, or when user asks to start development.
```

## Rationale

### Why Remove Commands?

The January 2026 Claude Code update merged slash commands into skills, making them functionally equivalent. Skills gained additional capabilities (supporting files, better portability) while commands offered no unique advantages.

**Benefits of skills-only architecture:**
1. **Unified system**: One concept (skills) instead of two (commands + skills)
2. **Progressive disclosure**: Supporting files reduce context usage
3. **Auto-invocation**: Claude can apply skills based on context
4. **Framework portability**: Skills work across Claude Code, Cursor, Windsurf, Cline
5. **Better organization**: Clear structure with SKILL.md + reference files

### Why Keep Plugin Namespace?

Plugin skills use `/sdlc:<skill-name>` namespace to prevent conflicts:
- Personal skills (from ~/.skills) don't have namespace
- Project skills (from .skills/) don't have namespace
- Plugin skills need namespace to avoid collisions

**Example conflict without namespace:**
```bash
# User has personal "work" skill for time tracking
/work

# Which skill runs?
# - Personal time tracking skill?
# - sdlc plugin work skill?
```

With namespace:
```bash
/work           # Personal time tracking skill
/sdlc:work      # sdlc plugin workflow skill
```

## Verification

After updating to v9.0.0, verify:

```bash
# Check plugin version
claude plugin validate sdlc

# Test skill invocation
/sdlc:start

# Check that hooks still work
# (Try editing a test file to verify PreToolUse hooks fire)
```

## Rollback

If you need to rollback to v8.0.0:

```bash
# Edit .claude-plugin/marketplace.json
# Change sdlc version from 9.0.0 to 8.0.0
# Reload plugin
claude plugin validate sdlc
```

## Support

- **Issues**: https://github.com/jwilger/claude-code-plugins/issues
- **Documentation**: See `/sdlc/README.md`
- **Changelog**: See `/sdlc/CHANGELOG.md`

## Next Steps

After updating:
1. Continue using your existing workflow - invocation syntax unchanged
2. Explore auto-invocation by asking questions instead of using slash commands
3. Check skill descriptions with `/context` to see when Claude will auto-invoke
4. Read individual skill SKILL.md files for usage patterns and examples
