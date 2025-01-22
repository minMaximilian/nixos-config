{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  cfg = config.myOptions.hyprland;
in {
  options.myOptions.hyprland = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Hyprland Window Manager";
    };
  };

  config = mkIf cfg.enable {
    services.xserver.enable = true;
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    home-manager.users.max = {
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = true;
        extraConfig = ''
          monitor=,preferred,auto,1
        '';
      };
    };
  };
}
