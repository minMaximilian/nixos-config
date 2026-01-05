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

  cfg = config.myOptions.login;

  hyprlandGreeterConfig = pkgs.writeText "hyprland-greeter.conf" ''
    misc {
      disable_hyprland_logo = true
      disable_splash_rendering = true
    }

    animations {
      enabled = false
    }

    exec-once = ${pkgs.regreet}/bin/regreet; hyprctl dispatch exit
  '';
in {
  options.myOptions.login = {
    enable =
      mkEnableOption "Login display manager (regreet)"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.hyprland}/bin/Hyprland --config ${hyprlandGreeterConfig}";
          user = "greeter";
        };
      };
    };

    programs.regreet.enable = true;

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
