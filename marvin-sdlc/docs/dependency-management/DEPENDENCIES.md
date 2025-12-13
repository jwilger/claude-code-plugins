# Dependency Management

How to add, update, and manage external dependencies.

## Core Principle

**Use CLI tools, not direct file edits.**

Each language ecosystem has tools designed to manage dependencies correctly.
Using them ensures:
- Proper version resolution
- Lock file updates
- Compatibility checks
- Consistent formatting

## Language-Specific Tools

### Rust (Cargo)

```bash
# Add dependency
cargo add serde
cargo add serde --features derive
cargo add tokio --features full

# Add dev dependency
cargo add --dev proptest

# Remove dependency
cargo remove serde

# Update dependencies
cargo update

# Check for outdated
cargo outdated  # requires cargo-outdated

# Audit for vulnerabilities
cargo audit  # requires cargo-audit
```

**Never directly edit Cargo.toml for dependencies.**

### Node.js (npm/yarn/pnpm)

```bash
# npm
npm install lodash
npm install --save-dev jest
npm uninstall lodash
npm update

# yarn
yarn add lodash
yarn add --dev jest
yarn remove lodash
yarn upgrade

# pnpm
pnpm add lodash
pnpm add -D jest
pnpm remove lodash
pnpm update
```

**Never directly edit package.json for dependencies.**

### Python (pip/poetry/uv)

```bash
# pip (with requirements.txt)
pip install requests
pip freeze > requirements.txt

# poetry
poetry add requests
poetry add --group dev pytest
poetry remove requests
poetry update

# uv (fast pip alternative)
uv pip install requests
uv pip compile requirements.in -o requirements.txt
```

**Never directly edit requirements.txt or pyproject.toml for dependencies.**

### Ruby (Bundler)

```bash
# Add to Gemfile and install
bundle add rails
bundle add rspec --group development

# Remove (edit Gemfile, then)
bundle install

# Update
bundle update
bundle update rails  # specific gem
```

### Go

```bash
# Add dependency
go get github.com/gin-gonic/gin

# Update
go get -u github.com/gin-gonic/gin

# Tidy (remove unused)
go mod tidy

# Verify
go mod verify
```

### Elixir (Mix)

```bash
# Add to mix.exs deps, then
mix deps.get

# Update
mix deps.update --all
mix deps.update phoenix  # specific dep
```

## When Adding Dependencies

Before adding a dependency, consider:

1. **Is it necessary?**
   - Can the functionality be implemented simply?
   - Is the dependency actively maintained?
   - How many transitive dependencies does it bring?

2. **Is it trustworthy?**
   - How many downloads/stars?
   - Who maintains it?
   - When was it last updated?
   - Any known vulnerabilities?

3. **Is it the right one?**
   - Are there lighter alternatives?
   - Does it match project conventions?
   - Is the API ergonomic?

## Version Pinning

### Recommended Approach

- **Lock files**: Always commit lock files (Cargo.lock, package-lock.json, etc.)
- **Version ranges**: Use semantic versioning ranges appropriately
  - `^1.2.3` - Compatible with 1.x.x (npm, Cargo default)
  - `~1.2.3` - Patch updates only (1.2.x)
  - `=1.2.3` - Exact version

### When to Pin Exactly

- Production deployments need reproducibility
- Dependency has history of breaking changes
- Specific version required for compatibility

## Security Auditing

Run security audits regularly:

```bash
# Rust
cargo audit

# Node.js
npm audit
yarn audit

# Python
pip-audit  # requires pip-audit
safety check  # requires safety

# Ruby
bundle audit
```

## Updating Dependencies

### Regular Updates

Schedule regular dependency updates:
1. Run update command
2. Run full test suite
3. Review changelog for breaking changes
4. Commit with clear message

### Major Version Updates

For major version bumps:
1. Read migration guide/changelog
2. Create branch for update
3. Update and fix breaking changes
4. Full test suite
5. Review carefully before merge

## Commit Messages for Dependencies

When dependencies change, commit messages should indicate:

```
Add serde for JSON serialization

- Added serde and serde_json for API response handling
- Features: derive for automatic implementations
```

```
Update tokio to 1.35

- Security fix for CVE-XXXX-YYYY
- No breaking changes in our usage
```

```
Remove unused lodash dependency

- Functionality replaced with native methods
- Reduces bundle size by ~70KB
```
