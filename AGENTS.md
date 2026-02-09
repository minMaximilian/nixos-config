# NixOS Config - Agent Guidelines

## ⛔ STOP - READ BEFORE ANY EDIT

Before modifying ANY file in this repo, you MUST:
1. Run `web_search` or `read_web_page` for the relevant documentation
2. State what you found and your plan in your response
3. Only THEN make edits

**NO EXCEPTIONS.** Do not rely on training data for syntax - it is outdated.

---

## ⚠️ CRITICAL: Pre-Update Requirements

**This is a bleeding-edge NixOS system using nixos-unstable.** Before making ANY changes:

### Mandatory Pre-Update Checklist

1. **Research First** — Use `web_search` and `read_web_page` to look up current documentation for:
   - Any package, option, or module being modified
   - NixOS/home-manager release notes for breaking changes
   - Upstream project changelogs (Hyprland, Stylix, nixCats, etc.)

2. **Understand the Scope** — Use `finder` and `Read` to analyze:
   - Which modules will be affected by the change
   - Dependencies between modules (check `Required Inputs by Module` table)
   - Whether the change affects external consumers of this flake

3. **Formulate a Thorough Plan** — Before implementation:
   - Document what changes will be made and why
   - Identify potential breaking changes or conflicts
   - List rollback strategies if the update fails
   - Consult the `oracle` for complex architectural decisions

4. **Use Subagents for Implementation** — Use the `Task` tool to:
   - Delegate independent module updates to parallel subagents
   - Keep changes atomic and reviewable
   - Ensure each subagent runs `nix flake check --no-build` after changes

5. **Verify Extensively** — After changes:
   - Run `nix flake check --no-build`
   - Dry-run build: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel --dry-run`
   - Format with `nix run nixpkgs#alejandra -- .`

### Documentation Sources to Check

- [NixOS Options Search](https://search.nixos.org/options)
- [NixOS Packages Search](https://search.nixos.org/packages)
- [Home-Manager Options](https://nix-community.github.io/home-manager/options.xhtml)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Stylix Documentation](https://danth.github.io/stylix/)
- Flake input repos for breaking changes in their changelogs

---

## Commands

```bash
# Check flake evaluates correctly (run after any change)
nix flake check --no-build

# Format code
nix run nixpkgs#alejandra -- .

# Build a specific host
nix build .#nixosConfigurations.whiteforest.config.system.build.toplevel --dry-run

# Enter dev shell
nix develop
```

## Project Structure

```
flake.nix              # Main flake - imports exports.nix for modules
├── modules/
│   ├── shared/        # Context-agnostic modules (work in both NixOS and home-manager)
│   │   ├── vars.nix   # User variables (username, sshKeys, etc.)
│   │   └── theme.nix  # Unified styling (border-radius, padding, fonts, opacity)
│   ├── nixos/         # NixOS system modules (exported as nixosModules.*)
│   │   ├── default.nix    # Imports all nixos modules
│   │   ├── exports.nix    # Auto-discovers and exports all modules
│   │   └── <feature>/     # Individual feature modules (auto-exported)
│   └── home/          # Home-manager modules (exported as homeModules.*)
│       ├── default.nix    # Imports all home modules
│       ├── exports.nix    # Auto-discovers and exports core/* modules
│       ├── core/          # Terminal/CLI modules (auto-exported individually)
│       └── gui/           # GUI application modules
├── hosts/             # Host-specific configurations (NOT exported)
│   ├── whiteforest/   # Desktop workstation
│   └── ravenholm/     # Secondary host
├── lib/               # Helper functions (exported as lib.*)
├── overlays/          # Package overlays (exported as overlays.*)
├── parts/             # Flake-parts configuration
└── assets/            # Static assets (wallpapers, etc.)
```

## Adding New Modules

Modules are **auto-discovered** via `exports.nix` files using `builtins.readDir`.

### Adding a new NixOS module

1. Create `modules/nixos/<name>/default.nix`
2. Run `nix flake check --no-build` — it's automatically exported as `nixosModules.<name>`

### Adding a new home-manager module

1. Create `modules/home/core/<name>/default.nix`
2. Add import to `modules/home/core/default.nix`
3. Run `nix flake check --no-build` — it's automatically exported as `homeModules.<name>`

## Module Compatibility Rules

### CRITICAL: This flake is designed to be imported by external flakes

Follow these rules to ensure modules remain externally consumable:

---

### 1. All Feature Modules Must Be Opt-In (`enable = false` by default)

```nix
# GOOD - Safe for external consumers
options.myOptions.myFeature = {
  enable = lib.mkEnableOption "My feature";
};

# BAD - Will affect all consumers unexpectedly
options.myOptions.myFeature = {
  enable = lib.mkEnableOption "My feature" // { default = true; };
};
```

---

### 2. Use Shared vars.nix and theme.nix for Both Contexts

The `modules/shared/` directory contains context-agnostic modules:
- **vars.nix** - User variables (username, sshKeys, etc.)
- **theme.nix** - Unified styling (border-radius, padding, fonts, opacity)

```nix
# In NixOS context
imports = [ nixos-config.nixosModules.vars nixos-config.nixosModules.theme ];

# In home-manager context  
imports = [ nixos-config.homeModules.vars nixos-config.homeModules.theme ];

# Bridge vars (theme uses same values, no bridging needed)
myOptions.vars = config.myOptions.vars;
```

### Theme Module Usage

Access theme values in GUI modules via `config.myOptions.theme` and helper functions via `config.lib.theme`:

```nix
# In a module
theme = config.myOptions.theme;
themeLib = config.lib.theme;

# Use raw values
border-radius = theme.borderRadius;        # 10 (int)
padding = theme.padding.medium;            # 8 (int)
opacity = theme.opacity.background;        # 0.9 (float)

# Use CSS helpers
border-radius = themeLib.css.borderRadius; # "10px" (string)
padding = themeLib.css.paddingMedium;      # "8px" (string)

# Convert opacity to hex for colors
background-color = "#${colors.base01}${themeLib.opacityToHex theme.opacity.background}";
```

**Modules using theme.nix:**
- `modules/home/gui/waybar/` - status bar
- `modules/home/gui/rofi/` - launcher
- `modules/home/gui/mako/` - notifications
- `modules/home/gui/eww/` - widgets (partial)

---

### 3. Internal Profiles vs Exported Modules

- **`homeModules.core`** is an INTERNAL profile - it imports all core modules and enables them with `mkDefault true`
- **External consumers should NOT use `homeModules.core`** - they should import individual modules instead
- Individual modules (`homeModules.fish`, `homeModules.git`, etc.) are safe for external use

```nix
# GOOD - For external consumers (servers, other flakes)
imports = [
  maxs-config.homeModules.vars
  maxs-config.homeModules.fish
  maxs-config.homeModules.git
];
myOptions.fish.enable = true;
myOptions.git.enable = true;

# OK - For internal hosts only (desktops in this flake)
imports = [ ../../home/core ];  # Enables everything with mkDefault
```

---

### 4. Guard Optional Input Dependencies

Modules that require external flake inputs must guard them:

```nix
# GOOD - Works even if nixCats is not provided
{
  config,
  lib,
  inputs ? {},
  ...
}: let
  hasNixCats = inputs ? nixCats;
in {
  imports = lib.optionals hasNixCats [
    inputs.nixCats.homeModule
  ];

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = hasNixCats;
      message = "myOptions.neovim requires inputs.nixCats";
    }];
    # ... rest of config
  };
}

# BAD - Breaks if nixCats is not in inputs
{ inputs, ... }: {
  imports = [ inputs.nixCats.homeModule ];  # Error if missing
}
```

---

### 5. Handle Optional `self`

Modules may be used without `self`. Always provide defaults:

```nix
# GOOD
{ self ? null, ... }: {
  nixpkgs.overlays = lib.mkIf (self != null && self ? overlays) [
    self.overlays.default
  ];
}

# BAD
{ self, ... }: {
  nixpkgs.overlays = [self.overlays.default];  # Breaks without self
}
```

---

### 6. Use `myOptions` Namespace

All custom options must be under `myOptions.*` to avoid conflicts:

```nix
# GOOD
options.myOptions.myFeature.enable = mkEnableOption "My feature";

# BAD
options.myFeature.enable = mkEnableOption "My feature";
```

---

### 7. Test After Changes

Always run after modifying modules:

```bash
nix flake check --no-build
```

---

## External Consumer Usage

Other flakes can import this flake's modules like this:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-config.url = "github:minMaximilian/nixos-config";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, nixos-config, home-manager, ... }@inputs: {
    nixosConfigurations.myserver = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        # Shared vars (username, sshKeys, etc.)
        nixos-config.nixosModules.vars
        
        home-manager.nixosModules.home-manager
        
        ({ config, ... }: {
          # User gets SSH keys from vars automatically
          users.users.${config.myOptions.vars.username} = {
            isNormalUser = true;
            openssh.authorizedKeys.keys = config.myOptions.vars.sshKeys;
          };
          
          home-manager.users.${config.myOptions.vars.username} = {
            imports = [
              nixos-config.homeModules.vars
              nixos-config.homeModules.fish
              nixos-config.homeModules.git
              nixos-config.homeModules.btop
            ];
            
            myOptions.vars = config.myOptions.vars;
            myOptions.fish.enable = true;
            myOptions.git.enable = true;
            myOptions.btop.enable = true;
            
            home.stateVersion = "24.11";
          };
        })
        
        ./configuration.nix
      ];
    };
  };
}
```

---

## Required Inputs by Module

| Module | Required Inputs |
|--------|-----------------|
| vars | none |
| fish | none |
| git | none |
| btop | none |
| devenv | none |
| golang | none |
| zellij | none |
| helium | none (auto-enabled when withGui=true) |
| neovim | nixCats |
| desktop | hyprland, hyprlock, hyprcursor |
| theme | stylix |
| login | hyprland |
| shared | home-manager |

---

## Flake Outputs

- `nixosModules.default` - All NixOS modules combined
- `nixosModules.vars` - Shared variables (username, sshKeys, etc.)
- `nixosModules.<name>` - Individual NixOS modules
- `homeModules.default` - All home-manager modules
- `homeModules.vars` - Same as nixosModules.vars (works in HM context)
- `homeModules.core` - INTERNAL profile (enables all with mkDefault)
- `homeModules.<name>` - Individual home modules (fish, git, btop, etc.)
- `overlays.default` - Package overlays
- `lib` - Helper functions
