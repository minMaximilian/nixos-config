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
    enable = mkEnableOption "Lockscreen (hypridle for idle management)";

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
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
          lock_cmd = "qs ipc call lockscreen lock";
        };

        listener = [
          {
            timeout = cfg.idleTimeout;
            on-timeout = "qs ipc call lockscreen lock";
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
