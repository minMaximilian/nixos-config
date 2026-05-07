{
  config,
  pkgs,
  lib,
  self ? null,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.myOptions.wallpaper;

  defaultPath =
    if self != null
    then "${self}/assets/wallpaper.png"
    else null;
in {
  options.myOptions.wallpaper = {
    enable = mkEnableOption "Compositor-agnostic wallpaper daemon (awww)";

    path = mkOption {
      type = types.nullOr types.path;
      default = defaultPath;
      description = "Path to the wallpaper image. null disables image loading.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.awww;
      description = "Wallpaper daemon package (must provide awww-daemon and awww binaries).";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    # awww-daemon as a user service. Compositor-agnostic — works on any
    # wlroots-style or wayland compositor that supports the wlr layer-shell
    # protocol (hyprland, niri, sway, wayfire, ...).
    systemd.user.services.awww-daemon = {
      Unit = {
        Description = "awww wallpaper daemon";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${cfg.package}/bin/awww-daemon";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    # One-shot to apply the configured wallpaper after the daemon is up.
    systemd.user.services.awww-set = mkIf (cfg.path != null) {
      Unit = {
        Description = "Apply wallpaper via awww";
        After = ["awww-daemon.service"];
        Requires = ["awww-daemon.service"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${cfg.package}/bin/awww img ${toString cfg.path}";
        # awww-daemon may need a moment to bind sockets after start
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
