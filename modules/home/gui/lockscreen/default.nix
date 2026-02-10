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
  hasStylix = config.lib.theme.hasStylix or false;
  theme = config.myOptions.theme;
in {
  options.myOptions.lockscreen = {
    enable = mkEnableOption "Lockscreen (hyprlock + hypridle)";

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
      settings = lib.mkIf hasStylix (let
        colors = config.lib.stylix.colors;
      in {
        general = {
          hide_cursor = false;
          immediate_render = true;
        };

        animations = {
          enabled = false;
        };

        background = lib.mkForce [
          {
            monitor = "";
            color = "rgba(0, 0, 0, 0)";
          }
        ];

        input-field = lib.mkForce [
          {
            monitor = "";
            size = "250, 60";
            outline_thickness = theme.borderWidth;
            dots_size = 0.2;
            dots_spacing = 0.35;
            dots_center = true;
            outer_color = "rgba(0, 0, 0, 0)";
            inner_color = "rgba(0, 0, 0, 0.5)";
            font_color = "rgb(${colors.base05})";
            fade_on_empty = false;
            rounding = -1;
            check_color = "rgb(${colors.base0A})";
            fail_color = "rgb(${colors.base08})";
            capslock_color = "rgb(${colors.base0A})";
            placeholder_text = "<i><span foreground=\"##${colors.base05}\">Input Password...</span></i>";
            hide_input = false;
            position = "0, -200";
            halign = "center";
            valign = "center";
          }
        ];

        label = lib.mkForce [
          # Date (above time)
          {
            monitor = "";
            text = "cmd[update:1000] date '+%A, %B %d'";
            color = "rgb(${colors.base05})";
            font_size = 22;
            font_family = theme.fonts.mono;
            position = "0, 300";
            halign = "center";
            valign = "center";
          }
          # Time
          {
            monitor = "";
            text = "cmd[update:1000] date '+%-I:%M'";
            color = "rgb(${colors.base05})";
            font_size = 95;
            font_family = "${theme.fonts.mono} ExtraBold";
            position = "0, 200";
            halign = "center";
            valign = "center";
          }
        ];

        image = lib.mkForce [
          {
            monitor = "";
            path = "$HOME/.face";
            size = 100;
            border_size = theme.borderWidth;
            border_color = "rgb(${colors.base05})";
            position = "0, -75";
            halign = "center";
            valign = "center";
          }
        ];
      });
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
