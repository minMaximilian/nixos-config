{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myOptions.urlPrivacy;

  urlPrivacy = pkgs.writeShellApplication {
    name = "url-privacy";
    runtimeInputs = [pkgs.python3];
    text = ''
      exec ${pkgs.python3}/bin/python3 ${./url_privacy.py} "$@"
    '';
  };

  clipboardSanitizer = pkgs.writeShellScript "sanitize-clipboard-url" ''
    cleaned="$(${urlPrivacy}/bin/url-privacy clipboard)"
    if [ -n "$cleaned" ]; then
      printf '%s' "$cleaned" | ${pkgs.wl-clipboard}/bin/wl-copy
    fi
  '';
in {
  options.myOptions.urlPrivacy = {
    enable = lib.mkEnableOption "system-wide URL cleaning and privacy frontend redirects";
    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = urlPrivacy;
      description = "URL privacy command used by browser and clipboard integrations.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      urlPrivacy
      pkgs.wl-clipboard
    ];

    systemd.user.services.url-privacy-clipboard = {
      Unit = {
        Description = "Remove tracking parameters from copied URLs";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${clipboardSanitizer}";
        Restart = "on-failure";
        RestartSec = 1;
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
