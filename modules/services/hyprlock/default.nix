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
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;
    };

    home-manager.users.${config.myOptions.vars.username} = {
      wayland.windowManager.hyprland.enable = true;
      programs.hyprlock = {
        enable = true;
      };
    };
  };
}
