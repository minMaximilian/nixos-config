# Auto-discovered homeModules
# New modules in core/ or gui/ are automatically exported
let
  # Get all directories (modules) from a path
  getModules = dir:
    builtins.mapAttrs
    (name: _: dir + "/${name}")
    (builtins.removeAttrs
      (builtins.readDir dir)
      ["default.nix" "exports.nix" "shared"]);
in
  {
    default = ./.;
    vars = ../shared/vars.nix;
    theme = ../shared/theme.nix;
  }
  // getModules ./core
