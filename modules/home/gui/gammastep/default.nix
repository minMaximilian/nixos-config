{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;

  cfg = config.myOptions.gammastep;

  gammastep-toggle = pkgs.writeShellScriptBin "gammastep-toggle" ''
    if systemctl --user is-active --quiet gammastep; then
      systemctl --user stop gammastep
      notify-send "Gammastep" "Disabled (gaming mode)"
    else
      systemctl --user start gammastep
      notify-send "Gammastep" "Enabled"
    fi
  '';
in {
  options.myOptions.gammastep = {
    enable =
      mkEnableOption "Gammastep blue light filter"
      // {
        default = true;
      };

    latitude = mkOption {
      type = types.float;
      default = 53.3498;
      description = "Your latitude for sunrise/sunset calculation";
    };

    longitude = mkOption {
      type = types.float;
      default = -6.2603;
      description = "Your longitude for sunrise/sunset calculation";
    };

    temperature = {
      day = mkOption {
        type = types.int;
        default = 6500;
        description = "Color temperature during the day (neutral is 6500K)";
      };

      night = mkOption {
        type = types.int;
        default = 3500;
        description = "Color temperature at night (warmer, less blue light)";
      };
    };

    brightness = {
      day = mkOption {
        type = types.float;
        default = 1.0;
        description = "Screen brightness during the day (0.1-1.0)";
      };

      night = mkOption {
        type = types.float;
        default = 0.8;
        description = "Screen brightness at night (0.1-1.0)";
      };
    };
  };

  config = mkIf cfg.enable {
    services.gammastep = {
      enable = true;
      provider = "manual";
      latitude = cfg.latitude;
      longitude = cfg.longitude;
      temperature = {
        day = cfg.temperature.day;
        night = cfg.temperature.night;
      };
      settings = {
        general = {
          fade = 1;
          brightness-day = cfg.brightness.day;
          brightness-night = cfg.brightness.night;
          adjustment-method = "wayland";
        };
      };
    };
  };
}
