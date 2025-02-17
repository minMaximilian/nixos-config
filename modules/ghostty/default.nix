{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;

  cfg = config.myOptions.ghostty;
in {
  options.myOptions.ghostty = {
    enable =
      mkEnableOption "Ghostty terminal emulator"
      // {
        default = config.myOptions.vars.withGui;
      };

    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Ghostty configuration settings";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.myOptions.vars.username} = {
      home.packages = [
        pkgs.ghostty
      ];

      home.file.".config/ghostty/config" = mkIf (cfg.settings != {}) {
        text =
          lib.generators.toINIWithGlobalSection {
            listsAsDuplicateKeys = true;
          } {
            globalSection = cfg.settings;
          };
      };
    };
  };
}
