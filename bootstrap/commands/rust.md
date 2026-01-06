---
description: Bootstrap a Rust project with Nix flake development environment
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
  - Glob
---

# Bootstrap Rust Project

Initialize a new Rust project with a Nix-based development environment including:
- rust-overlay for toolchain management
- cargo-nextest and cargo-audit (auto-detected latest versions)
- git-spice for stacked PR workflow
- Optional database tooling (sqlx-cli, postgresql)

## Steps

### 1. Determine Project Location

Use AskUserQuestion to ask:

**Question: Where should the project be created?**
- "Create new directory" - Create a new directory with a specified project name
- "Use current directory" - Initialize in the current working directory

If creating new directory:
- Ask for project name (use second question or follow-up)
- Create the directory: `mkdir -p <project-name>`
- All subsequent file operations should be in that new directory

### 2. Database Tooling

Use AskUserQuestion to ask:

**Question: Include database tooling?**
- "Yes, include database tools" - Add sqlx-cli and postgresql to flake.nix
- "No, skip database tools" - Standard Rust environment only

### 3. Detect Latest Tool Versions

Run these commands to get the latest versions:

```bash
# Get latest cargo-nextest version
nix shell nixpkgs#cargo -c cargo search cargo-nextest 2>/dev/null | head -1 | sed 's/.*= "\([^"]*\)".*/\1/'

# Get latest cargo-audit version
nix shell nixpkgs#cargo -c cargo search cargo-audit 2>/dev/null | head -1 | sed 's/.*= "\([^"]*\)".*/\1/'
```

Store these versions for use in the flake.nix template.

### 4. Create flake.nix

Create `flake.nix` in the project directory with this template (substitute PROJECT_NAME, CARGO_NEXTEST_VERSION, CARGO_AUDIT_VERSION, and conditionally include DATABASE_PACKAGES):

```nix
{
  description = "PROJECT_NAME development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            git
            git-spice
            pre-commit
            nodejs_22
            glow
            just
            jq
            # DATABASE_PACKAGES (sqlx-cli and postgresql - only if database tooling selected)
          ];

          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";

          shellHook = ''
            # Configure git for stacked PR workflow
            git config --local rebase.updateRefs true 2>/dev/null || true

            CARGO_AUDIT_VERSION="CARGO_AUDIT_VERSION"
            CARGO_NEXTEST_VERSION="CARGO_NEXTEST_VERSION"

            # Setup local cargo bin directory
            export CARGO_INSTALL_ROOT="$PWD/.cargo-bin"
            export PATH="$CARGO_INSTALL_ROOT/bin:$PATH"

            # Create directory if it doesn't exist
            mkdir -p "$CARGO_INSTALL_ROOT/bin"

            # Check cargo-nextest version
            if ! command -v cargo-nextest >/dev/null 2>&1 || [ "$(cargo-nextest --version 2>/dev/null | awk '{print $2}')" != "$CARGO_NEXTEST_VERSION" ]; then
              echo "Installing cargo-nextest $CARGO_NEXTEST_VERSION to $CARGO_INSTALL_ROOT..."
              cargo install cargo-nextest --version "$CARGO_NEXTEST_VERSION" --locked --root "$CARGO_INSTALL_ROOT"
            fi

            # Check cargo-audit version
            if ! command -v cargo-audit >/dev/null 2>&1 || [ "$(cargo-audit --version 2>/dev/null | awk '{print $2}')" != "$CARGO_AUDIT_VERSION" ]; then
              echo "Installing cargo-audit $CARGO_AUDIT_VERSION to $CARGO_INSTALL_ROOT..."
              cargo install cargo-audit --version "$CARGO_AUDIT_VERSION" --root "$CARGO_INSTALL_ROOT"
            fi

            # Use project-local advisory database
            alias cargo-audit='cargo audit --db "$PWD/.cargo-advisory-db"'

            # git-spice workflow alias: sync, restack all branches, and submit
            alias gs-sync='gs repo sync --restack && gs stack submit'
          '';
        };
      }
    );
}
```

When creating the file:
- Replace PROJECT_NAME with the actual project name (directory name)
- Replace CARGO_NEXTEST_VERSION and CARGO_AUDIT_VERSION with detected versions
- If database tooling was selected, add `sqlx-cli` and `postgresql` to buildInputs
- If database tooling was NOT selected, remove the comment line about DATABASE_PACKAGES

### 5. Create rust-toolchain.toml

Create `rust-toolchain.toml`:

```toml
[toolchain]
channel = "stable"
components = ["rustfmt", "clippy", "rust-src", "rust-analyzer"]
profile = "default"
```

### 6. Create .envrc

Create `.envrc`:

```
use flake
```

### 7. Create .gitignore

Create `.gitignore`:

```
.direnv/
.envrc

.cargo-bin/
```

### 8. Initialize Git Repository

Run these commands in sequence:

```bash
git init
git add .
git commit -m "Initialize Rust development environment"
```

### 9. Display Success

Show a summary:

```
Rust project initialized successfully!

Created files:
  - flake.nix (Nix development environment)
  - rust-toolchain.toml (Rust stable with rustfmt, clippy, rust-src, rust-analyzer)
  - .envrc (direnv integration)
  - .gitignore

Tool versions:
  - cargo-nextest: X.Y.Z
  - cargo-audit: X.Y.Z

**IMPORTANT: Exit Claude Code now and load the Nix development shell.**

If you have direnv configured, the shell will load automatically when you cd into the project directory.
Otherwise, run `nix develop` manually to enter the development shell.

Once the development shell is loaded, restart Claude Code in the project directory.
```
