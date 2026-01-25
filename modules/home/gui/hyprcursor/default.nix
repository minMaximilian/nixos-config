{
  config,
  pkgs,
  lib,
  inputs ? {},
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.hyprcursor;

  hasHyprcursor = inputs ? hyprcursor;
  cursorTheme = config.stylix.cursor.name or "Bibata-Modern-Classic";
  cursorSize = config.stylix.cursor.size or 16;
in {
  options.myOptions.hyprcursor = {
    enable = mkEnableOption "Hyprcursor environment variables for Hyprland";
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals hasHyprcursor [
      inputs.hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.hyprcursor
    ];

    wayland.windowManager.hyprland.settings = {
      exec-once = lib.optionals hasHyprcursor ["hyprcursor"];

      env = [
        "HYPRCURSOR_THEME,${cursorTheme}"
        "HYPRCURSOR_SIZE,${toString cursorSize}"
        "XCURSOR_THEME,${cursorTheme}"
        "XCURSOR_SIZE,${toString cursorSize}"
      ];
    };
  };
}
