{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  cfg = config.myOptions.ghostty;
in {
  options.myOptions.ghostty = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Ghostty terminal emulator";
    };

    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Ghostty configuration settings";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.max = {
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
