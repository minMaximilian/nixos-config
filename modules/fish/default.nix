{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  cfg = config.myOptions.fish;
in {
  options.myOptions.fish = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Fish Shell by default";
    };
  };

  config = mkIf cfg.enable {
    users.users.max.shell = pkgs.fish;
    programs.fish.enable = true;

    home-manager.users.max = {
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
        };
        man.generateCaches = true;
        zoxide.enable = true;
      };
    };
  };
}
