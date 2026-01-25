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

  cfg = config.myOptions.screenshot;
in {
  options.myOptions.screenshot = {
    enable = mkEnableOption "Screenshot tools for Wayland/Hyprland";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      grim
      slurp
      grimblast
      wl-clipboard
    ];

    xdg.userDirs.pictures = "${config.home.homeDirectory}/Pictures";

    home.file."Pictures/Screenshots/.keep".text = "";
  };
}
