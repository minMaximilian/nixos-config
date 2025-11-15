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

    home-manager.users.${config.myOptions.vars.username} = {
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

          # Colors handled by system theme/stylix
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
