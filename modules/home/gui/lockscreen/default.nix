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
  colors = config.lib.stylix.colors;
in {
  options.myOptions.lockscreen = {
    enable =
      mkEnableOption "Lockscreen (hyprlock + hypridle)"
      // {
        default = true;
      };

    idleTimeout = mkOption {
      type = types.int;
      default = 300;
      description = "Seconds of inactivity before locking";
    };

    dpmsTimeout = mkOption {
      type = types.int;
      default = 350;
      description = "Seconds of inactivity before turning off displays";
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.enable = true;

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          hide_cursor = true;
          grace = 3;
        };

        label = [
          {
            monitor = "";
            text = "$TIME";
            color = "rgb(${colors.base05})";
            font_size = 96;
            font_family = "sans-serif";
            position = "0, 250";
            halign = "center";
            valign = "center";
          }
          {
            monitor = "";
            text = "cmd[update:60000] date '+%A, %B %d'";
            color = "rgb(${colors.base04})";
            font_size = 24;
            font_family = "sans-serif";
            position = "0, 150";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
          lock_cmd = "hyprlock";
        };

        listener = [
          {
            timeout = cfg.idleTimeout;
            on-timeout = "hyprlock";
          }
          {
            timeout = cfg.dpmsTimeout;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };

    systemd.user.services.hypridle.Unit.After = lib.mkForce "graphical-session.target";
  };
}
