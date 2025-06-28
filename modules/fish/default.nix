{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  cfg = config.myOptions.fish;
  username = config.myOptions.vars.username;
in {
  options.myOptions.fish = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Fish Shell by default";
    };
  };

  config = mkIf cfg.enable {
    users.users.${username}.shell = pkgs.fish;
    programs.fish.enable = true;

    home-manager.users.${username} = {
      home.packages = lib.attrValues {
        inherit
          (pkgs)
          zoxide
          fzf
          fd
          bat
          ;
      };

      programs = {
        fish = {
          enable = true;
          plugins = import ./plugins.nix {inherit pkgs;};
          functions = {
            fish_greeting = "";
          };
          # Colors handled by stylix
        };
        man.generateCaches = true;
        zoxide.enable = true;
      };
    };
  };
}
