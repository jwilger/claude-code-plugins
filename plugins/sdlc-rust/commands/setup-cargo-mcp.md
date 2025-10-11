---
description: Guide user through installing and configuring cargo-mcp MCP server for Rust development
disable-model-invocation: false
---

You are helping the user install and configure cargo-mcp, a Model Context Protocol server that provides safe access to Cargo operations.

## Your Task

1. **Check if cargo-mcp is installed:**
```bash
which cargo-mcp
```

2. **If not installed, guide installation:**
```bash
cargo install cargo-mcp
```

3. **Verify installation:**
```bash
cargo-mcp --version
```

4. **Explain what cargo-mcp provides:**
   - cargo_check: Run cargo check to verify code compiles
   - cargo_clippy: Run clippy lints for code quality
   - cargo_test: Run the test suite
   - cargo_build: Build the project
   - cargo_fmt_check: Check code formatting
   - cargo_add/remove/update: Manage dependencies
   - cargo_clean: Clean build artifacts
   - cargo_run: Run the application
   - cargo_bench: Run benchmarks

5. **Confirm the sdlc-rust plugin configuration:**
   - Show the user that `.mcp.json` in the plugin configures cargo-mcp automatically
   - Explain that no manual MCP configuration is needed - the plugin handles it
   - Mention that cargo-mcp will be available when the plugin is enabled
   - The plugin's `.mcp.json` sets `CARGO_MCP_DEFAULT_TOOLCHAIN` to "stable"

6. **Test the integration:**
   - Recommend running a simple cargo command via MCP tools
   - Example: "Let me run cargo_check to verify everything is working"
   - Verify cargo-mcp is responding correctly

## Important Notes

- cargo-mcp requires Cargo and Rust to be installed
- The plugin's .mcp.json assumes cargo-mcp is in PATH (typically ~/.cargo/bin/)
- If cargo-mcp is installed in a non-standard location, user may need to update the command path in .mcp.json
- The plugin automatically enables cargo-mcp when activated (no manual config needed)
- cargo-mcp runs as `cargo-mcp serve` which the plugin configures automatically

## Troubleshooting

If cargo-mcp doesn't work:
- Verify Rust and Cargo are installed: `rustc --version && cargo --version`
- Check PATH includes ~/.cargo/bin: `echo $PATH | grep cargo`
- Reinstall if needed: `cargo install --force cargo-mcp`
- Restart Claude Code after installation

This setup assistant is now active to help you configure cargo-mcp.