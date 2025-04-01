{
  lib,
  config,
  pkgs,
  self,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.hyprpaper;
  username = config.myOptions.vars.username;
in {
  options.myOptions.hyprpaper = {
    enable =
      mkEnableOption "Hyprpaper Wallpaper Service"
      // {
        default = config.myOptions.hyprland.enable;
      };
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {...}: {
      services.hyprpaper = {
        enable = true;
        settings = {
          preload = ["${self}/assets/wallpaper.png"];
          wallpaper = [", ${self}/assets/wallpaper.png"];
        };
      };

      systemd.user.services.hyprpaper.Unit.After = lib.mkForce "graphical-session.target";
    };
  };
}
