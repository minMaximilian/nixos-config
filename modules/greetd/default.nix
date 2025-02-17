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
    ;

  cfg = config.myOptions.greetd;
in {
  options.myOptions.greetd = {
    enable =
      mkEnableOption "Greetd display manager"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = ''
            ${pkgs.greetd.tuigreet}/bin/tuigreet \
              --time \
              --remember \
              --remember-session \
              --sessions ${pkgs.hyprland}/share/wayland-sessions \
              --cmd "dbus-run-session ${pkgs.hyprland}/bin/Hyprland"
          '';
          user = "greeter";
        };
      };
    };

    environment = {
      systemPackages = with pkgs; [
        greetd.tuigreet
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
