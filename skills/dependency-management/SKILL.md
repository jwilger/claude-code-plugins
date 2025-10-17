---
name: dependency-management
description: User-facing dependency management for analyzing, adding, updating, or removing project dependencies. Uses platform-appropriate tooling (cargo, uv, npm, pnpm). Checks security, recommends latest compatible versions, and provides dependency insights. Use when user asks to add, update, check, or analyze dependencies outside of workflow phases.
allowed-tools: [Bash, Read, WebFetch, WebSearch, BashOutput, mcp__memento__create_entities, mcp__memento__create_relations, mcp__memento__add_observations, mcp__memento__semantic_search, mcp__memento__open_nodes, mcp__time__get_current_time]
---

# Dependency Management (User-Facing)

Analyzes, recommends, and manages project dependencies using platform-appropriate tooling.

**Note**: This skill is for USER-INVOKED dependency operations. The dependency-management AGENT handles workflow-integrated dependency management during development phases.

## When to Use This Skill

- **User requests dependency operations**: "Add serde", "Update all dependencies", "Check for security vulnerabilities"
- **Ad-hoc dependency analysis**: "What version of tokio are we using?", "Are there outdated dependencies?"
- **Security checks**: "Check for vulnerable dependencies", "Audit dependency security"
- **Dependency research**: "What's the best HTTP client for Rust?", "Compare async runtime options"

**NOT for**: Workflow-integrated dependency management (that's the agent's job during Phase 7)

## Platform Detection

Automatically detect project type and use appropriate tools:

### Rust (Cargo.toml present)
- **Tool**: `cargo add/remove/update/check`
- **Lock File**: Cargo.lock
- **Security**: `cargo audit` (if installed)

### Python (pyproject.toml/requirements.txt)
- **Tool**: `uv` (preferred) or `pip`
- **Lock File**: uv.lock or requirements.lock
- **Security**: `safety` or `pip-audit`

### Node.js (package.json)
- **Tool**: `npm` or `pnpm` (detect from lock file)
- **Lock File**: package-lock.json or pnpm-lock.yaml
- **Security**: `npm audit` or `pnpm audit`

## Common Operations

### Add Dependency

**Rust:**
```bash
# Add with default features
cargo add serde

# Add with specific features
cargo add tokio --no-default-features --features rt-multi-thread,macros

# Add dev dependency
cargo add --dev proptest
```

**Python:**
```bash
# Using uv (preferred)
uv add pydantic

# Using pip
pip install pydantic && pip freeze > requirements.txt
```

**Node.js:**
```bash
# Using npm
npm install express

# Using pnpm
pnpm add express

# Dev dependency
npm install --save-dev jest
```

### Update Dependencies

**Rust:**
```bash
# Update all dependencies to latest compatible
cargo update

# Update specific package
cargo update serde

# Check for outdated
cargo outdated  # (if installed)
```

**Python:**
```bash
# Using uv
uv sync --upgrade

# Using pip
pip install --upgrade package-name
```

**Node.js:**
```bash
# Check outdated
npm outdated

# Update all
npm update

# Update specific
npm update express
```

### Remove Dependency

**Rust:**
```bash
cargo remove package-name
```

**Python:**
```bash
# Using uv
uv remove package-name

# Using pip
pip uninstall package-name
```

**Node.js:**
```bash
npm uninstall package-name
# or
pnpm remove package-name
```

### Security Audit

**Rust:**
```bash
cargo audit
```

**Python:**
```bash
safety check
# or
pip-audit
```

**Node.js:**
```bash
npm audit
# or
pnpm audit
```

## Dependency Research

### Finding the Right Dependency

**Process:**
1. **Understand requirement**: What capability is needed?
2. **Search ecosystem**: Find candidates (crates.io, PyPI, npm)
3. **Evaluate options**: Compare features, maintenance, security
4. **Check compatibility**: Verify works with existing dependencies
5. **Recommend**: Provide rationale for choice

**Evaluation Criteria:**
- **Maintenance**: Recent commits, active issues
- **Popularity**: Download counts, GitHub stars
- **Security**: Known vulnerabilities, security advisories
- **License**: Compatible with project requirements
- **Size**: Dependency tree impact
- **API Quality**: Documentation, ergonomics

### Research Example (Rust HTTP Client)

```
Requirement: HTTP client for async Rust application

Candidates:
1. reqwest - Most popular, high-level, good defaults
2. hyper - Lower-level, more control, steeper learning curve
3. ureq - Sync-only, simpler, no async runtime needed

Recommendation: reqwest
Rationale:
- Battle-tested (used by 50k+ crates)
- Async-first design fits tokio runtime
- Excellent documentation and examples
- Active maintenance
- No known security issues

Command: cargo add reqwest --features json
```

## Analyzing Current Dependencies

### View Dependency Tree

**Rust:**
```bash
cargo tree
```

**Python:**
```bash
pip list
# or
pipdeptree  # (if installed)
```

**Node.js:**
```bash
npm list
# or
pnpm list
```

### Check Specific Dependency

**Rust:**
```bash
cargo tree -p serde
```

**Node.js:**
```bash
npm list express
```

### Find Duplicate Dependencies

**Rust:**
```bash
cargo tree --duplicates
```

**Node.js:**
```bash
npm dedupe --dry-run
```

## Security Best Practices

### Regular Security Audits

```bash
# Rust
cargo audit

# Python
safety check --full-report

# Node.js
npm audit --audit-level=moderate
```

### Version Pinning Strategy

**Development**:
- Use semantic versioning ranges
- Allow patch/minor updates
- Pin major versions

**Production**:
- Use lock files for reproducible builds
- Review all updates before deploying
- Test after dependency updates

### Vulnerability Response

When vulnerabilities found:

1. **Assess severity**: Critical, High, Medium, Low
2. **Check fix availability**: Is patched version available?
3. **Update if possible**: `cargo update package-name`
4. **If no fix**: Consider alternatives or mitigations
5. **Document decision**: Record in memory why action taken/deferred

## Task Completion Protocol

When invoked for dependency management:

1. **Detect platform**: Identify Rust/Python/Node.js
2. **Understand request**: Add, update, remove, audit, research?
3. **Execute operation**: Use appropriate tool
4. **Verify success**: Check for errors or conflicts
5. **Report results**: Clear summary of action taken
6. **Store decision**: Record in memory for future reference

## Example Interactions

### User: "Add serde dependency"

**Steps:**
1. Detect platform: Rust (Cargo.toml present)
2. Check if exists: `cargo tree -p serde`
3. If not: `cargo add serde`
4. Verify: Check Cargo.toml updated
5. Report: "Added serde v1.0.X with default features"

### User: "Check for outdated dependencies"

**Steps:**
1. Detect platform: Node.js (package.json present)
2. Run: `npm outdated`
3. Parse results: List packages with current vs. wanted vs. latest
4. Report: Summary table of outdated packages
5. Recommend: "Consider updating X (security) and Y (new features)"

### User: "What's the best async runtime for Rust?"

**Steps:**
1. Research: tokio vs async-std vs smol
2. Compare: Features, ecosystem, performance, maintenance
3. Check project context: Existing dependencies, requirements
4. Recommend: "tokio - most ecosystem support, battle-tested"
5. Explain: Rationale for recommendation

## Integration with Workflow Agent

**This Skill**: User-facing, ad-hoc operations, research, analysis

**Workflow Agent**: Phase 7 integration, automatic during development, commits separately

**Coordination**: Skill can recommend calling workflow agent for proper integration during development phases.

## Memory Storage

After dependency operations, store:

```
Entity: "Dependency Decision - [package-name] - [date]"
Observations:
  - "Project: [name] | Added [package] v[version]"
  - "Purpose: [why needed]"
  - "Alternative Considered: [other options]"
  - "Rationale: [why this choice]"
  - "Security Status: [clean/warnings]"
```

Remember: Dependencies are long-term commitments. Every addition increases maintenance burden, attack surface, and build time. Choose wisely, update regularly, remove when unused.
