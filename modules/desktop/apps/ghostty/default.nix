{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.ghostty;
in {
  options.myOptions.ghostty = {
    enable =
      mkEnableOption "Ghostty terminal emulator"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ghostty
    ];

    home-manager.users.${config.myOptions.vars.username} = {config, ...}: let
      inherit (config.colorScheme) palette;
    in {
      programs.ghostty = {
        enable = true;
        settings = {
          font-family = "JetBrainsMono Nerd Font";
          font-size = 12;
          font-feature = [
            "calt"
            "liga"
            "dlig"
          ];

          window-padding-x = 10;
          window-padding-y = 10;
          window-decoration = false;
          window-theme = "dark";

          background = "#${palette.base00}";
          foreground = "#${palette.base05}";
          cursor-color = "#${palette.base05}";
          cursor-text = "#${palette.base00}";
          selection-background = "#${palette.base02}";
          selection-foreground = "#${palette.base05}";

          palette = [
            "0=#${palette.base00}"
            "1=#${palette.base01}"
            "2=#${palette.base02}"
            "3=#${palette.base03}"
            "4=#${palette.base04}"
            "5=#${palette.base05}"
            "6=#${palette.base06}"
            "7=#${palette.base07}"
            "8=#${palette.base08}"
            "9=#${palette.base09}"
            "10=#${palette.base0A}"
            "11=#${palette.base0B}"
            "12=#${palette.base0C}"
            "13=#${palette.base0D}"
            "14=#${palette.base0E}"
            "15=#${palette.base0F}"
          ];

          confirm-close-surface = false;
          macos-option-as-alt = true;
          mouse-hide-while-typing = true;
          shell-integration-features = "no-cursor";
          cursor-style = "block";
          cursor-style-blink = false;
          unfocused-split-opacity = 0.9;
        };
      };
    };
  };
}
