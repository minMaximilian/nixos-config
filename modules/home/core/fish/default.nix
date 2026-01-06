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
    enable = lib.mkEnableOption "Fish Shell";
  };

  config = mkIf cfg.enable {
    home.packages = lib.attrValues {
      inherit
        (pkgs)
        zoxide
        fzf
        fd
        bat
        nodejs_20
        ;
    };

    programs = {
      fish = {
        enable = true;
        plugins = import ./plugins.nix {inherit pkgs;};
        functions = {
          fish_greeting = "";
        };
        shellAliases = {
        };
        interactiveShellInit = ''
          fish_vi_key_bindings
        '';
      };
      man.generateCaches = true;
      zoxide.enable = true;
    };
  };
}
