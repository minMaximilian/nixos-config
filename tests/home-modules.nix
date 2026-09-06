{
  inputs,
  system,
}: let
  lib = inputs.nixpkgs.lib;
  pkgs = import inputs.nixpkgs {inherit system;};
  modules = import ../modules/home/exports.nix;
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/work"
    else "/home/work";
  evaluate = names: enabled:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs.inputs = lib.optionalAttrs (enabled && builtins.elem "neovim" names) {
        inherit (inputs) nixCats;
      };
      modules =
        map (name: modules.${name}) names
        ++ [
          {
            home = {
              username = "work";
              inherit homeDirectory;
              stateVersion = "25.11";
            };
            myOptions = lib.genAttrs names (_: {enable = enabled;});
          }
        ];
    };
  names = builtins.attrNames modules;
  configurations =
    map (name: evaluate [name] true) names
    ++ [(evaluate names true) (evaluate names false)];
  combined = (evaluate names true).config;
in
  assert builtins.attrNames modules == ["fish" "git" "git-hooks" "ideavim" "neovim" "zellij"];
  assert (combined.programs.git.settings.user or {}) == {};
  assert combined.home.username == "work";
  assert combined.home.homeDirectory == homeDirectory;
  assert !(combined.wayland.windowManager.hyprland.enable or false);
  assert !(combined.myOptions.neovim.debug.enable);
  assert !(combined.myOptions.neovim.godot.enable);
    builtins.deepSeq (map (c: c.activationPackage.drvPath) configurations) true
