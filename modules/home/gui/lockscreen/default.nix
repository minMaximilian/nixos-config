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

  # swayidle's systemd unit hardcodes PATH to bash only, so `noctalia`
  # (installed via home.packages by the noctalia home module) is not
  # resolvable. Use the absolute path via the user's home-manager profile
  # directory.
  lockCmd = "${config.home.profileDirectory}/bin/noctalia msg screen-lock";
  dpmsOff = "${pkgs.wlopm}/bin/wlopm --off '*'";
  dpmsOn = "${pkgs.wlopm}/bin/wlopm --on '*'";
in {
  options.myOptions.lockscreen = {
    enable = mkEnableOption "Lockscreen (swayidle for idle management, noctalia for the lock surface)";

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
    # swayidle is compositor-agnostic — works under any compositor that
    # implements ext-idle-notify-v1 (hyprland, niri, sway, wayfire, ...).
    # Display power management uses wlopm via zwlr-output-power-management-v1,
    # also supported by both hyprland and niri.
    services.swayidle = {
      enable = true;

      events = {
        before-sleep = "${pkgs.systemd}/bin/loginctl lock-session";
        lock = lockCmd;
      };

      timeouts = [
        {
          timeout = cfg.idleTimeout;
          command = lockCmd;
        }
        {
          timeout = cfg.dpmsTimeout;
          command = dpmsOff;
          resumeCommand = dpmsOn;
        }
      ];
    };

    systemd.user.services.swayidle.Unit.After = lib.mkForce "graphical-session.target";
  };
}
