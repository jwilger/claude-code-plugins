---
description: Intelligently configure shell alias for appending SDLC system prompt based on your environment
disable-model-invocation: false
---

You are helping the user set up a shell alias or configuration so that `claude` automatically appends the SDLC system prompt from the plugin's `system-prompt.md`.

## Your Task

### 1. Investigate the user's environment

**Platform detection:**
```bash
uname -s    # Linux, Darwin (macOS), etc.
```

**Shell detection:**
```bash
echo $SHELL           # Current shell
ps -p $$ -o comm=     # Actual running shell
```

**Check for NixOS:**
```bash
which nix-env || ls /etc/nixos/ 2>/dev/null
```

**Check for project-specific tools:**
```bash
ls -la | grep -E '\.envrc|flake\.nix|\.tool-versions'
```

### 2. Ask clarifying questions

- "Do you want this alias available system-wide or only in specific projects?"
- "Are you using NixOS? If so, do you want this in your system configuration or home-manager?"
- "Are you using direnv for project-specific environments?"
- "Would you like the alias to be `claude` (override) or `claude-sdlc` (separate command)?"

### 3. Research the correct approach

**For bash:**
- System-wide: Add to `~/.bashrc` or `~/.bash_profile`
- Syntax: `alias claude-sdlc='claude-code --append-system-prompt "sdlc-app@jwilger-sdlc"'`

**For zsh:**
- System-wide: Add to `~/.zshrc`
- Same alias syntax as bash

**For fish:**
- System-wide: Add to `~/.config/fish/config.fish`
- Syntax: `alias claude-sdlc='claude --append-system-prompt "(cat ~/.claude/plugins/sdlc-core/system-prompt.md)"'`

**For NixOS system-wide:**
```nix
# In /etc/nixos/configuration.nix
environment.shellAliases = {
  claude-sdlc = "claude --append-system-prompt \"$(cat ~/.claude/plugins/sdlc-core/system-prompt.md)\"";
};
```

**For NixOS home-manager:**
```nix
# In ~/.config/home-manager/home.nix
programs.bash.shellAliases = {
  claude-sdlc = "claude --append-system-prompt \"$(cat ~/.claude/plugins/sdlc-core/system-prompt.md)\"";
};
# OR for zsh
programs.zsh.shellAliases = { ... };
```

**For direnv (project-specific):**
```bash
# In project root .envrc
alias claude-sdlc='claude --append-system-prompt "$(cat ~/.claude/plugins/sdlc-core/system-prompt.md)"'
```

**For Nix flake (project-specific):**
```nix
# In flake.nix devShells.default
shellHook = ''
  alias claude-sdlc='claude --append-system-prompt "$(cat ~/.claude/plugins/sdlc-core/system-prompt.md)"'
'';
```

### 4. Generate exact configuration

Provide:
- The exact line(s) to add
- Exactly where to add them
- The command to reload configuration
- Verification command: `alias claude-sdlc` or `type claude-sdlc`

### 5. Test with the user

Guide them through:
- Adding the configuration
- Reloading (e.g., `source ~/.bashrc` or `home-manager switch`)
- Testing: `claude-sdlc --help` should show Claude Code help
- Verifying system prompt: Explain that the prompt is appended transparently

## Important Notes

### Quote Handling
- **Single quotes on outer layer** to prevent early evaluation
- **Double quotes around file path** for proper argument passing
- Example: `'claude --append-system-prompt "$(cat /path/to/file)"'`

### Path Verification
- Confirm `~/.claude/plugins/sdlc-core/system-prompt.md` exists before creating alias
- If path doesn't exist, plugin may not be installed correctly

### Plugin Installation
- Remind user that sdlc-core plugin must be installed first
- File path assumes standard plugin installation location

### Troubleshooting
- If alias doesn't work, check shell syntax for that specific shell
- Verify file path resolves correctly: `cat ~/.claude/plugins/sdlc-core/system-prompt.md`
- Ensure Claude Code is in PATH: `which claude`

This setup assistant is now active to configure your shell for the SDLC workflow.