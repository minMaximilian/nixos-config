{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.ghostty;
  theme = config.myOptions.theme;
in {
  options.myOptions.ghostty = {
    enable = mkEnableOption "Ghostty terminal emulator";
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      settings = {
        font-family = theme.fonts.mono;
        font-size = theme.fonts.size.small;
        font-feature = [
          "calt"
          "liga"
          "dlig"
        ];

        window-padding-x = theme.padding.large;
        window-padding-y = theme.padding.large;
        window-decoration = false;
        window-theme = "dark";

        confirm-close-surface = false;
        macos-option-as-alt = true;
        mouse-hide-while-typing = true;
        shell-integration-features = "no-cursor";
        cursor-style = "block";
        cursor-style-blink = false;
        unfocused-split-opacity = theme.opacity.background;
      };
    };

    xdg.desktopEntries.ghostty = {
      name = "Terminal";
      genericName = "Terminal Emulator";
      exec = "ghostty";
      icon = "com.mitchellh.ghostty";
      terminal = false;
      categories = ["System" "TerminalEmulator"];
    };
  };
}
