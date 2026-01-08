# Auto-discovered nixosModules
# New modules added to this directory are automatically exported
let
  # Get all directories (modules) from a path
  getModules = dir:
    builtins.mapAttrs
    (name: _: dir + "/${name}")
    (builtins.removeAttrs
      (builtins.readDir dir)
      ["default.nix" "exports.nix" "vars"]);
in
  {
    default = ./.;
    vars = ../shared/vars.nix;
  }
  // getModules ./.
