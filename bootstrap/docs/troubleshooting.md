# Bootstrap Troubleshooting Guide

Common issues and solutions when using the bootstrap plugin.

## Flake Build Failures

### "error: attribute 'X' not found"

**Cause**: Package name doesn't exist in nixpkgs or overlay.

**Solutions**:
1. Search for the correct package name:
   ```bash
   nix search nixpkgs <package>
   ```
2. Check if the package is in a specific overlay
3. The researcher agent may have used an outdated package name - try re-running with `--refresh`

### "error: infinite recursion encountered"

**Cause**: Circular dependency in flake inputs or overlays.

**Solutions**:
1. Check overlay definitions for self-references
2. Ensure inputs are properly passed to overlays
3. Simplify overlay structure

### Darwin Framework Errors

**Symptoms**: Build fails on macOS with missing framework errors.

**Common missing frameworks**:
```nix
darwin.apple_sdk.frameworks.Security
darwin.apple_sdk.frameworks.SystemConfiguration
darwin.apple_sdk.frameworks.CoreFoundation
darwin.apple_sdk.frameworks.CoreServices
```

**Solution**: Add missing frameworks to `darwinDeps` in flake.nix.

### OpenSSL/pkg-config Errors

**Symptoms**: Build fails with "pkg-config not found" or OpenSSL linking errors.

**Solution**: Ensure these are in buildInputs:
```nix
buildInputs = with pkgs; [
  pkg-config
  openssl
];
```

## Detection Issues

### "No project detected" when project exists

**Cause**: Manifest file has non-standard name or location.

**Solutions**:
1. Provide explicit language argument: `/bootstrap:init rust`
2. Check if manifest is in a subdirectory
3. Run detection in the correct directory

### Wrong language detected

**Cause**: Multiple manifest files present (e.g., package.json + Cargo.toml).

**Solution**: Provide explicit language: `/bootstrap:init rust`

## Research Issues

### WebSearch returns outdated patterns

**Cause**: Cached results or search returning old blog posts.

**Solutions**:
1. Clear memento cache for this language
2. Add current year to search terms
3. Manually specify the overlay/input you want

### "Low confidence" research results

**Cause**: Uncommon language/framework with limited Nix documentation.

**Solutions**:
1. Check official nixpkgs for the language
2. Look for community overlays on GitHub
3. Use conservative nixpkgs defaults
4. Ask in NixOS Discourse for guidance

## direnv Issues

### Shell doesn't load automatically

**Cause**: direnv not installed or not configured.

**Solutions**:
1. Install direnv: `nix-env -i direnv` or add to global config
2. Add to shell rc file:
   ```bash
   # bash
   eval "$(direnv hook bash)"

   # zsh
   eval "$(direnv hook zsh)"
   ```
3. Allow the directory: `direnv allow`

### "direnv: error .envrc is blocked"

**Cause**: direnv security feature requires explicit approval.

**Solution**: Run `direnv allow` in the project directory.

## Git Issues

### "Not a git repository"

**Cause**: Git init failed or was skipped.

**Solution**: Run `git init` manually.

### Commit fails with hook errors

**Cause**: pre-commit hooks installed but dependencies missing.

**Solutions**:
1. Ensure you're in the Nix shell: `nix develop`
2. Run `pre-commit install` if hooks aren't set up
3. Check `.pre-commit-config.yaml` for issues

## Platform-Specific Issues

### Linux: Missing shared libraries

**Symptoms**: Runtime errors about missing `.so` files.

**Solutions**:
1. Add the library to buildInputs
2. Use `autoPatchelfHook` for binaries
3. Set `LD_LIBRARY_PATH` in shellHook

### macOS: SDK version mismatch

**Symptoms**: Errors about SDK version or architecture.

**Solutions**:
1. Update nixpkgs input to a newer version
2. Use `apple_sdk_11_0` instead of default SDK
3. Check for architecture-specific packages (aarch64 vs x86_64)

## Recovery Steps

### Start Fresh

If everything is broken:

```bash
# Backup existing files
mv flake.nix flake.nix.broken
mv flake.lock flake.lock.broken

# Clear Nix store cache (careful - affects all projects)
nix-collect-garbage

# Re-run bootstrap
/bootstrap:init <language>
```

### Manual Flake Repair

If you know what's wrong:

1. Edit `flake.nix` directly
2. Run `nix flake check --no-build` to validate syntax
3. Run `nix flake update` to refresh lock file
4. Run `nix develop` to test

### Report Issues

If the bootstrap consistently fails for a language:

1. Note the exact error message
2. Record the language and framework
3. Save the generated flake.nix (even if broken)
4. Report at: https://github.com/anthropics/claude-code/issues

Include:
- Operating system (Linux/macOS)
- Architecture (x86_64/aarch64)
- Language and framework
- Full error output
