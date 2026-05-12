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
    #
    # The wallpaper image is applied via ExecStartPost rather than a
    # separate one-shot service, because a separate service ordered both
    # `After=awww-daemon` and `WantedBy=graphical-session.target` produces
    # a systemd ordering cycle (graphical-session → awww-set → awww-daemon
    # → graphical-session) which causes the set step to be silently
    # dropped, leaving a black background.
    systemd.user.services.awww-daemon = {
      Unit = {
        Description = "awww wallpaper daemon";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service =
        {
          ExecStart = "${cfg.package}/bin/awww-daemon";
          Restart = "on-failure";
          RestartSec = 3;
        }
        // lib.optionalAttrs (cfg.path != null) {
          # awww-daemon needs a moment to bind its socket before `awww img`
          # can talk to it. ExecStartPost runs after ExecStart has begun,
          # so a short sleep is sufficient.
          ExecStartPost = "${pkgs.bash}/bin/bash -c 'sleep 1 && ${cfg.package}/bin/awww img --transition-type none ${toString cfg.path}'";
        };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
