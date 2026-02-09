{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.login;
  username = config.myOptions.vars.username;
in {
  options.myOptions.login = {
    enable =
      mkEnableOption "Login display manager (auto-login with hyprlock)"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop";
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
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_DESKTOP = "Hyprland";
      };
    };

    security.pam.services.greetd = {
      enableGnomeKeyring = true;
    };

    services.dbus.enable = true;
  };
}
