{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  cfg = config.myOptions.hyprlock;
in {
  options.myOptions.hyprlock = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Hyprlock screen locker";
    };
  };

  config = mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;
    };

    home-manager.users.max = {
      wayland.windowManager.hyprland.enable = true;
      programs.hyprlock = {
        enable = true;
      };
    };
  };
}
