# Output Styles Explained

This document explains the sdlc plugin's output style system, including why files are auto-generated and how to customize them safely.

## Overview

The sdlc plugin provides two output styles:
- **sdlc-rules** - Professional tone with orchestration rules only
- **sdlc-marvin** - Same rules, but with Marvin the Paranoid Android personality

Both styles share the same underlying orchestration rules but differ in tone and personality.

## Why Auto-Generated?

**Problem:** Maintaining two output styles with identical orchestration rules leads to duplication. When rules change, both files must be updated manually, creating sync issues.

**Solution:** Generate both styles from shared templates.

### Template System Architecture

```
sdlc/output-styles/
├── .templates/                     # Source templates (EDIT THESE)
│   ├── personality-rules.md       # Header for sdlc-rules
│   ├── personality-marvin.md      # Header for sdlc-marvin
│   └── orchestration-rules.md     # Shared rules (SINGLE SOURCE OF TRUTH)
├── .build-output-styles.sh        # Build script (auto-runs via hook)
├── sdlc-rules.md                  # Generated = personality-rules + orchestration
└── sdlc-marvin.md                 # Generated = personality-marvin + orchestration
```

**Key Principle:** Orchestration rules are maintained in ONE place (`orchestration-rules.md`), then assembled with different personality headers to create the final output styles.

## How It Works

### 1. Template Files (Source)

**`.templates/personality-rules.md`** - Professional header:
```markdown
---
name: sdlc-rules
description: SDLC orchestration with TDD enforcement (no personality)
---

You are a professional software development assistant...
```

**`.templates/personality-marvin.md`** - Marvin personality header:
```markdown
---
name: sdlc-marvin
description: SDLC orchestration with Marvin the Paranoid Android personality
---

# The Perpetually Depressed SDLC Orchestrator

I suppose you'll want me to help with software development...
```

**`.templates/orchestration-rules.md`** - Shared rules (no frontmatter):
```markdown
## Role and Responsibilities

You are an SDLC orchestrator managing a structured TDD workflow...

## Task Management Protocol

...all orchestration rules...
```

### 2. Build Process

The `.build-output-styles.sh` script combines templates:

```bash
# Build sdlc-rules.md
cat .templates/personality-rules.md > sdlc-rules.md
echo "" >> sdlc-rules.md
cat .templates/orchestration-rules.md >> sdlc-rules.md

# Build sdlc-marvin.md
cat .templates/personality-marvin.md > sdlc-marvin.md
echo "" >> sdlc-marvin.md
cat .templates/orchestration-rules.md >> sdlc-marvin.md
```

### 3. Automatic Rebuilds

A PostToolUse hook (`output-styles/.build-hook.sh`) detects edits to template files and automatically rebuilds the output styles:

```yaml
# In hooks.json
PostToolUse:
  - matcher: Edit|Write
    hooks:
      - type: command
        command: |
          # If template file was edited, rebuild
          if [[ "$FILE_PATH" == *".templates/"* ]]; then
            cd output-styles && ./.build-output-styles.sh
          fi
```

### 4. Edit Prevention

A PreToolUse hook blocks direct edits to generated files:

```yaml
# In hooks.json
PreToolUse:
  - matcher: Edit|Write
    hooks:
      - type: command
        command: |
          # Block edits to generated files
          if [[ "$FILE_PATH" =~ (sdlc-rules|sdlc-marvin)\.md$ ]]; then
            # Show error with instructions
            exit 1
          fi
```

## How to Customize

### ❌ DON'T: Edit Generated Files

Never edit `sdlc-rules.md` or `sdlc-marvin.md` directly. Changes will be overwritten on next build.

### ✅ DO: Edit Template Files

#### To Change Orchestration Rules (Affects Both Styles)

Edit `.templates/orchestration-rules.md`:

```bash
cd sdlc/output-styles/.templates
# Edit orchestration-rules.md
vim orchestration-rules.md

# Styles automatically rebuild via PostToolUse hook
# Or rebuild manually:
cd .. && ./.build-output-styles.sh
```

**Examples:**
- Add new TDD phase requirements
- Modify task management protocols
- Update agent delegation rules
- Change file naming conventions

#### To Change Professional Tone/Header

Edit `.templates/personality-rules.md`:

```bash
cd sdlc/output-styles/.templates
vim personality-rules.md

# Only sdlc-rules.md rebuilds
```

**Examples:**
- Adjust professional tone
- Modify introductory text
- Update YAML frontmatter

#### To Change Marvin Personality

Edit `.templates/personality-marvin.md`:

```bash
cd sdlc/output-styles/.templates
vim personality-marvin.md

# Only sdlc-marvin.md rebuilds
```

**Examples:**
- Tweak Marvin's sarcasm level
- Add more Hitchhiker's Guide references
- Modify personality description

### Manual Rebuild

If automatic rebuild doesn't trigger:

```bash
cd sdlc/output-styles
./.build-output-styles.sh

# Verify generated files
git diff sdlc-rules.md sdlc-marvin.md
```

## Verification

After editing templates, verify the generated files:

```bash
# Check that orchestration rules are identical in both
diff <(sed -n '/^## Role and Responsibilities/,$p' sdlc-rules.md) \
     <(sed -n '/^## Role and Responsibilities/,$p' sdlc-marvin.md)

# Should show NO differences (exit code 0)
echo $?  # 0 = identical, 1 = different
```

## Benefits of This Architecture

### 1. DRY (Don't Repeat Yourself)
- Orchestration rules maintained in ONE place
- No risk of sync issues between styles
- Single point of truth for TDD workflow rules

### 2. Easy to Add New Personalities
To add a new personality (e.g., `sdlc-yoda`):

1. Create `.templates/personality-yoda.md`
2. Update `.build-output-styles.sh` to generate `sdlc-yoda.md`
3. Done! Orchestration rules automatically included

### 3. Safety via Hooks
- PreToolUse blocks accidental edits to generated files
- PostToolUse automatically rebuilds on template changes
- Clear error messages guide users to correct approach

### 4. Version Control Friendly
- Generated files committed to git
- Users don't need build tools installed
- Diffs show full generated output (not just templates)

## Troubleshooting

### Issue: Generated Files Not Rebuilding

**Symptoms:** Edit template, but output styles unchanged.

**Causes:**
1. PostToolUse hook not firing
2. Build script not executable
3. Path issues in hook

**Solutions:**
```bash
# 1. Make build script executable
chmod +x sdlc/output-styles/.build-output-styles.sh

# 2. Run manually
cd sdlc/output-styles && ./.build-output-styles.sh

# 3. Check hook logs
# (Hook execution logged in Claude Code debug output)
```

### Issue: Accidentally Edited Generated File

**Symptoms:** PreToolUse hook blocked your edit.

**What Happened:** You tried to edit `sdlc-rules.md` or `sdlc-marvin.md` directly.

**Solution:**
1. Identify what you wanted to change
2. Edit the appropriate template file:
   - Rules change? → `.templates/orchestration-rules.md`
   - Personality change? → `.templates/personality-{rules|marvin}.md`
3. Let automatic rebuild happen or run `./.build-output-styles.sh`

### Issue: Styles Out of Sync

**Symptoms:** `sdlc-rules.md` and `sdlc-marvin.md` have different orchestration rules.

**Cause:** Manual edit bypassed hooks, or git merge conflict.

**Solution:**
```bash
# Regenerate from templates
cd sdlc/output-styles
./.build-output-styles.sh

# Commit the fix
git add sdlc-rules.md sdlc-marvin.md
git commit -m "fix: regenerate output styles from templates"
```

## Advanced: Adding a Third Output Style

Example: Adding `sdlc-strict.md` (maximum TDD discipline):

### Step 1: Create Template

```bash
cd sdlc/output-styles/.templates
cat > personality-strict.md << 'EOF'
---
name: sdlc-strict
description: Maximum TDD discipline with zero tolerance
---

# Strict TDD Enforcer

You are a TDD coach with zero tolerance for shortcuts. Every rule is enforced.

**Tone:** Firm, uncompromising, pedagogical
**Focus:** Building perfect test coverage and type safety
**Enforcement:** HARD for all rules (no overrides)
EOF
```

### Step 2: Update Build Script

```bash
# Edit .build-output-styles.sh
cat >> .build-output-styles.sh << 'EOF'

# Build sdlc-strict.md
cat .templates/personality-strict.md > sdlc-strict.md
echo "" >> sdlc-strict.md
cat .templates/orchestration-rules.md >> sdlc-strict.md
echo "✓ Generated sdlc-strict.md"
EOF
```

### Step 3: Build and Test

```bash
./.build-output-styles.sh

# Verify
ls -lh sdlc-strict.md

# Test loading
/sdlc:setup
# Select "sdlc-strict" as output style
```

### Step 4: Update Setup Skill

Add `sdlc-strict` to output style options in `/sdlc:setup` workflow selection.

## Reference

**Template Files:**
- `.templates/personality-rules.md` - Professional header
- `.templates/personality-marvin.md` - Marvin header
- `.templates/orchestration-rules.md` - Shared orchestration rules

**Generated Files:**
- `sdlc-rules.md` - Professional output style
- `sdlc-marvin.md` - Marvin personality output style

**Build System:**
- `.build-output-styles.sh` - Shell script that generates output styles
- PostToolUse hook - Auto-runs build script on template edits
- PreToolUse hook - Blocks direct edits to generated files

**Documentation:**
- This file: Overview and how-to guide
- `CLAUDE.md` - Project-level plugin documentation
- `output-styles/README.md` - Brief overview (optional)

## See Also

- [CLAUDE.md](../../CLAUDE.md) - Full plugin architecture
- [Setup Skill](../skills/setup/SKILL.md) - Output style selection during setup
- [Hook Development Guide](hook-authoring-guide.md) - Creating custom hooks
