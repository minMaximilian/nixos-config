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
    home-manager.users.${config.myOptions.vars.username} = {config, ...}: let
      inherit (config.colorScheme) palette;
    in {
      home.packages = [
        pkgs.ghostty
      ];

      home.file.".config/ghostty/config" = {
        text =
          lib.generators.toINIWithGlobalSection {
            listsAsDuplicateKeys = true;
          } {
            globalSection =
              cfg.settings
              // {
                # Theme settings
                background = "#${palette.base00}";
                foreground = "#${palette.base05}";
                cursor-color = "#${palette.base05}";
                cursor-text = "#${palette.base00}";
                selection-background = "#${palette.base02}";
                selection-foreground = "#${palette.base05}";

                # Terminal colors (each on its own line)
                palette = [
                  "0=#${palette.base00}" # Black
                  "1=#${palette.base01}" # Red
                  "2=#${palette.base02}" # Green
                  "3=#${palette.base03}" # Yellow
                  "4=#${palette.base04}" # Blue
                  "5=#${palette.base05}" # Magenta
                  "6=#${palette.base06}" # Cyan
                  "7=#${palette.base07}" # White
                  "8=#${palette.base08}" # Bright Black
                  "9=#${palette.base09}" # Bright Red
                  "10=#${palette.base0A}" # Bright Green
                  "11=#${palette.base0B}" # Bright Yellow
                  "12=#${palette.base0C}" # Bright Blue
                  "13=#${palette.base0D}" # Bright Magenta
                  "14=#${palette.base0E}" # Bright Cyan
                  "15=#${palette.base0F}" # Bright White
                ];

                # UI settings
                window-padding-x = 10;
                window-padding-y = 10;
                window-theme = "dark";
                font-family = "monospace";
                font-size = 12;
                confirm-close-surface = false;
                mouse-hide-while-typing = true;
                cursor-style = "block";
                cursor-style-blink = false;
              };
          };
      };
    };
  };
}
