---
description: "[DEPRECATED] Bootstrap a Rust project - use /bootstrap:init rust instead"
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---

# Bootstrap Rust (Deprecated)

**This command is deprecated.** Use the new unified bootstrapper instead:

```
/bootstrap:init rust
```

## Why the Change?

The new `/bootstrap:init` command:
- Supports ANY language or framework, not just Rust
- Uses web search to find current Nix best practices
- Caches knowledge for faster subsequent runs
- Detects existing projects automatically
- Has better error handling and validation

## Migration

Simply run:
```
/bootstrap:init rust
```

The new system will:
1. Detect if you're in an existing Rust project (has Cargo.toml)
2. Research current rust-overlay patterns
3. Generate an optimized flake.nix
4. Include all the same universal tools (git-spice, just, glow, etc.)

## If You Really Need the Old Behavior

The old template-based approach is preserved in the git history if needed:
```
git show v0.4.0:bootstrap/commands/rust.md
```

But the new intelligent bootstrapper should handle Rust projects better.
