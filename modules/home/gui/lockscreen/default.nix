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
    mkOption
    types
    ;

  cfg = config.myOptions.lockscreen;
in {
  options.myOptions.lockscreen = {
    enable =
      mkEnableOption "Lockscreen (hyprlock + hypridle)"
      // {
        default = true;
      };

    idleTimeout = mkOption {
      type = types.int;
      default = 300;
      description = "Seconds of inactivity before locking";
    };

    dpmsTimeout = mkOption {
      type = types.int;
      default = 350;
      description = "Seconds of inactivity before turning off displays";
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.enable = true;

    programs.hyprlock.enable = true;

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
          lock_cmd = "hyprlock";
        };

        listener = [
          {
            timeout = cfg.idleTimeout;
            on-timeout = "hyprlock";
          }
          {
            timeout = cfg.dpmsTimeout;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };

    systemd.user.services.hypridle.Unit.After = lib.mkForce "graphical-session.target";
  };
}
