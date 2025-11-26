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

  cfg = config.myOptions.hyprlock;
in {
  options.myOptions.hyprlock = {
    enable =
      mkEnableOption "Hyprlock screen locker"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.enable = true;
    programs.hyprlock = {
      enable = true;
    };
  };
}
