# Git Hooks and Formatters System

## Overview

This configuration provides a system-wide pre-commit hook and formatter system that works across all your git repositories. It automatically formats code before commits, ensuring consistent code style across all your projects.

## Features

- **Automatic formatting**: Staged files are automatically formatted before commit
- **Smart detection**: Detects project-specific formatters (pre-commit, treefmt, .editorconfig)
- **Fallback system**: Uses system formatters when no project config is found
- **Multi-language support**: Built-in support for Nix, Go, Python, Rust, Shell, YAML, TOML, Lua, JavaScript/TypeScript, JSON, and Markdown
- **Configurable**: Customize behavior through NixOS options
- **Per-repo control**: Enable/disable hooks per repository
- **Fish shell integration**: Convenient commands for managing hooks

## Supported Formatters

| File Type | Formatter | Package |
|-----------|-----------|---------|
| Nix | alejandra | alejandra |
| Go | gofmt | go |
| Python | black | python311Packages.black |
| Rust | rustfmt | rustfmt |
| Shell | shfmt | shfmt |
| YAML/TOML | yamlfmt/taplo | yamlfmt/taplo |
| Lua | stylua | stylua |
| JS/TS/JSON/MD | prettier | nodePackages.prettier |

## Usage

### New Repositories

New repositories will automatically have hooks installed when you run `git init`:

```bash
mkdir my-project
cd my-project
git init
# Hooks are automatically installed from the template directory
```

### Existing Repositories

To install hooks in existing repositories:

```bash
cd my-project
git-init-hooks  # Install hooks manually
```

### Manual Formatting

Format all files in a repository:

```bash
git-format-repo  # Format all tracked files
```

### Disable Hooks Temporarily

Disable hooks for a specific repository:

```bash
git-disable-hooks  # Disable pre-commit hook
```

Enable them again:

```bash
git-enable-hooks   # Re-enable pre-commit hook
```

### Bypass Hooks

Skip hooks for a single commit:

```bash
git commit --no-verify -m "WIP"
```

## Fish Shell Commands

The system provides convenient Fish shell commands and abbreviations:

| Command | Abbreviation | Description |
|---------|--------------|-------------|
| `git-init-hooks` | `gih` | Install hooks in current repository |
| `git-format-repo` | `gfr` | Format all files in current repository |
| `git-disable-hooks` | `gdh` | Disable hooks for current repository |
| `git-enable-hooks` | `geh` | Enable hooks for current repository |

## Configuration

### NixOS Configuration

Customize the formatter system in your NixOS config:

```nix
{
  myOptions.formatters = {
    enable = true;

    # Add custom formatters
    systemFormatters = {
      ".*\\.elm$" = ["elm-format"];
      ".*\\.ex$" = ["mix format"];
      ".*\\.exs$" = ["mix format"];
    };

    # Check for additional project config files
    projectConfigFiles = [
      ".pre-commit-config.yaml"
      "treefmt.toml"
      "dprint.json"
    ];

    # Set to false to fail instead of auto-formatting
    formatInPlace = true;

    # Enable verbose output
    verbose = false;
  };

  myOptions.git = {
    enable = true;
    hooks.enable = true;  # Enable/disable git hooks globally
  };
}
```

### Git Configuration

Configure per-repo behavior:

```bash
# Disable hooks for this repo
git config core.hooksPath /dev/null

# Re-enable hooks
git config --unset core.hooksPath
```

## Project-Specific Configuration

### Pre-commit

If your project has a `.pre-commit-config.yaml`, it will be used instead of system formatters:

```yaml
repos:
  - repo: https://github.com/psf/black
    rev: 24.1.1
    hooks:
      - id: black
  - repo: https://github.com/pre-commit/mirrors-clang-format
    rev: v17.0.6
    hooks:
      - id: clang-format
```

### Treefmt

If your project uses `treefmt.toml`, it will be used instead of system formatters:

```toml
[formatter.nix]
command = "alejandra"
includes = ["*.nix"]

[formatter.python]
command = "black"
includes = ["*.py"]
```

### EditorConfig

The system checks for `.editorconfig` files. While it doesn't directly use EditorConfig for formatting, the presence of this file indicates that the project has its own formatting standards, and the system will respect project-specific formatters if configured.

## Troubleshooting

### Hooks Not Running

Check if hooks are installed:

```bash
ls -la .git/hooks/pre-commit
```

If missing, run:

```bash
git-init-hooks
```

### Formatter Not Found

Ensure the formatter is installed:

```bash
which alejandra  # or other formatter
```

If not found, it will be skipped. The system installs all required formatters automatically, but you can verify they're available.

### Hook Fails Silently

Enable verbose mode in your config:

```nix
myOptions.formatters.verbose = true;
```

Then commit again to see detailed output.

### Conflicts with Project Hooks

If you have project-specific hooks that conflict, disable the global hooks:

```bash
git-disable-hooks
```

Then manage hooks manually in `.git/hooks/`.

### Template Directory Not Found

If you see "No template directory configured" error, check:

```bash
git config --get init.templateDir
```

It should point to `~/.config/git/templates/`. If not set, the hooks will only work for new repositories.

## How It Works

1. When you run `git commit`, the pre-commit hook runs
2. The hook checks for project-specific configuration files (.pre-commit-config.yaml, treefmt.toml, etc.)
3. If found, it tries to use project formatters (pre-commit, treefmt, etc.)
4. If not found, it uses system formatters based on file extensions
5. Files are formatted in-place (or check fails if `formatInPlace = false`)
6. Formatted files are automatically staged
7. Commit proceeds if all formatting succeeds

### Fallback Priority

The system checks for formatters in this order:

1. **Project-specific**: Check for `.pre-commit-config.yaml`, `treefmt.toml`, `treefmt.nix`, `.editorconfig`
2. **If project config found**:
   - Try `pre-commit run --files <file>` if pre-commit is available
   - Try `treefmt <file>` if treefmt is available
3. **If no project config**:
   - Match file extension against `systemFormatters` regex patterns
   - For each matching formatter:
     - Check if command is available via `command -v`
     - Run formatter on the file
     - If `formatInPlace = true`: format and stage the file
     - If `formatInPlace = false`: check formatting and fail if needed

## Adding New Formatters

To add a new formatter:

1. Add the package to your NixOS config
2. Add to `systemFormatters` in `myOptions.formatters`

```nix
{
  myOptions.formatters = {
    systemFormatters = {
      ".*\\.elm$" = ["elm-format"];
      ".*\\.ex$" = ["mix format"];
      ".*\\.exs$" = ["mix format"];
    };
  };

  home.packages = with pkgs; [
    elmPackages.elm-format  # Add package
    elixir  # For mix format
  ];
}
```

## Best Practices

1. **Test first**: Run `git-format-repo` before committing to see what changes
2. **Review changes**: Check `git diff` after automatic formatting
3. **Commit hooks**: Add your `.gitignore` to version control to track ignored files
4. **Document**: Add a `CONTRIBUTING.md` explaining your formatting standards
5. **CI/CD**: Configure CI to run the same formatters
6. **Team alignment**: Ensure your team uses the same formatters
7. **Project consistency**: Use project-specific configs when team standards differ from system defaults

## Advanced Configuration

### Disabling Specific Formatters

If you want to disable a specific formatter for certain files, you can modify the regex patterns:

```nix
{
  myOptions.formatters = {
    systemFormatters = {
      ".*\\.nix$" = ["alejandra"];
      # Comment out or remove unwanted formatters
      # ".*\\.py$" = ["black"];
    };
  };
}
```

### Strict Mode

To fail commits when formatting is needed (instead of auto-formatting):

```nix
{
  myOptions.formatters = {
    formatInPlace = false;
  };
}
```

### Custom Formatter Paths

If you have custom formatters in non-standard locations:

```nix
{
  home.packages = [
    (pkgs.writeShellScriptBin "my-custom-formatter" ''
      # Your custom formatting logic
      format_custom_file "$1"
    '')
  ];

  myOptions.formatters = {
    systemFormatters = {
      ".*\\.custom$" = ["my-custom-formatter"];
    };
  };
}
```

## System Requirements

- Git 2.40+
- NixOS 24.11+
- Home Manager 24.11+
- Fish shell (for convenience commands)

## Files Created/Modified

### New Files:
- `/home/max/workspace/repos/nixos-config/modules/shared/formatters.nix` - Formatter configuration
- `/home/max/workspace/repos/nixos-config/modules/home/core/git-hooks/default.nix` - Git hooks module
- `/home/max/workspace/repos/nixos-config/modules/home/core/fish/hooks.nix` - Fish convenience functions
- `/home/max/workspace/repos/nixos-config/docs/GIT_HOOKS.md` - This documentation

### Modified Files:
- `/home/max/workspace/repos/nixos-config/modules/home/core/git/default.nix` - Added hooks option
- `/home/max/workspace/repos/nixos-config/modules/home/core/default.nix` - Import and enable git-hooks
- `/home/max/workspace/repos/nixos-config/modules/home/core/fish/default.nix` - Import hooks module

## Rollback

If you encounter issues with the git hooks system:

### Disable Globally

```nix
myOptions.git.hooks.enable = false;
```

Then rebuild:

```bash
nixos-rebuild switch  # or home-manager switch
```

### Disable Per-Repo

```bash
cd your-repo
git config core.hooksPath /dev/null
```

### Remove Hooks Manually

```bash
rm .git/hooks/pre-commit
```

### Restore Hooks

```bash
git-init-hooks  # Re-install from templates
```

## See Also

- [Git Hooks Documentation](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)
- [pre-commit Framework](https://pre-commit.com/)
- [treefmt](https://github.com/numtide/treefmt)
- [EditorConfig](https://editorconfig.org/)
- [NixOS Configuration](../AGENTS.md)
