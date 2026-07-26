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
  lockCmd = "${config.home.profileDirectory}/bin/noctalia msg session lock";
  startupLock = pkgs.writeShellScript "noctalia-startup-lock" ''
    for _ in $(${pkgs.coreutils}/bin/seq 1 40); do
      if ${lockCmd}; then
        exit 0
      fi
      ${pkgs.coreutils}/bin/sleep 0.5
    done

    exit 1
  '';
  dpmsOff = "${pkgs.wlopm}/bin/wlopm --off '*'";
  dpmsOn = "${pkgs.wlopm}/bin/wlopm --on '*'";
in {
  options.myOptions.lockscreen = {
    enable = mkEnableOption "Lockscreen (swayidle for idle management, noctalia for the lock surface)";

    idleTimeout = mkOption {
      type = types.int;
      default = 600;
      description = "Seconds of inactivity before locking";
    };

    dpmsTimeout = mkOption {
      type = types.int;
      default = 660;
      description = "Seconds of inactivity before turning off displays";
    };

    lockOnStartup = mkOption {
      type = types.bool;
      default = false;
      description = "Lock once when the graphical session starts";
    };
  };

  config = mkIf cfg.enable {
    # Hyprland supports swayidle's idle-notify and wlopm's output-power protocols.
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

    systemd.user.services.noctalia-startup-lock = mkIf cfg.lockOnStartup {
      Unit = {
        Description = "Lock session once Noctalia is ready";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target" "noctalia.service"];
      };

      Service = {
        Type = "oneshot";
        ExecStart = startupLock;
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
