{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.myOptions.guiAutostart;
  homeBin = "${config.home.profileDirectory}/bin";
  systemBin = "/run/current-system/sw/bin";

  waitForDesktop = ''
    for _ in $(${pkgs.coreutils}/bin/seq 1 200); do
      if ${pkgs.systemd}/bin/busctl --user --timeout=500ms call org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.DBus.Properties Get ss org.freedesktop.portal.FileChooser version >/dev/null 2>&1; then
        break
      fi

      ${pkgs.coreutils}/bin/sleep 0.1
    done
  '';

  mkLauncher = name: command:
    pkgs.writeShellScript "launch-${name}-after-desktop" ''
      ${waitForDesktop}
      exec ${command}
    '';

  mkAppService = name: command: {
    Unit = {
      Description = "Autostart ${name}";
      PartOf = ["graphical-session.target"];
      After = [
        "graphical-session.target"
        "xdg-desktop-portal.service"
        "xdg-desktop-portal-gtk.service"
      ];
      Wants = ["xdg-desktop-portal.service"];
    };

    Service = {
      Type = "exec";
      ExecStart = mkLauncher name command;
      Environment = [
        "NIXOS_OZONE_WL=1"
        "ELECTRON_OZONE_PLATFORM_HINT=auto"
      ];
    };

    Install.WantedBy = ["graphical-session.target"];
  };
in {
  options.myOptions.guiAutostart = {
    enable = mkEnableOption "desktop application autostart services";
  };

  config = mkIf cfg.enable {
    systemd.user.services = {
      autostart-steam = mkAppService "steam" "${systemBin}/steam";
      autostart-vesktop = mkAppService "vesktop" "${homeBin}/vesktop";
      autostart-helium = mkAppService "helium" "${homeBin}/helium";
      autostart-tidal = mkAppService "tidal" "${homeBin}/tidal";
    };
  };
}
