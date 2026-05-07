{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.myOptions.login;
  username = config.myOptions.vars.username;

  isHyprland = cfg.compositor == "hyprland";

  sessionCommand =
    if isHyprland
    then "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop"
    else "niri-session";

  desktopName =
    if isHyprland
    then "Hyprland"
    else "niri";
in {
  options.myOptions.login = {
    enable =
      mkEnableOption "Login display manager (auto-login compositor)"
      // {
        default = config.myOptions.vars.withGui;
      };

    compositor = mkOption {
      type = types.enum ["hyprland" "niri"];
      default = "hyprland";
      description = "Compositor session greetd should auto-launch.";
    };
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = sessionCommand;
          user = username;
        };
      };
    };

    environment = {
      systemPackages = with pkgs; [
        dbus
      ];

      sessionVariables = {
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = desktopName;
        XDG_SESSION_DESKTOP = desktopName;
      };
    };

    security.pam.services.greetd = {
      enableGnomeKeyring = true;
    };

    services.dbus.enable = true;
  };
}
