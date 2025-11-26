{
  config,
  pkgs,
  lib,
  inputs,
  self,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.hyprland;
in {
  options.myOptions.hyprland = {
    enable =
      mkEnableOption "Hyprland Window Manager"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      settings = {
        "$mod" = "SUPER";

        exec-once =
          [
            "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
            "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
            "uwsm finalize"
            "uwsm app -- ${pkgs.mako}"
          ]
          ++ lib.optionals config.myOptions.waybar.enable [
            "uwsm app -- waybar"
          ];

        env = [
          "QT_QPA_PLATFORMTHEME,qt5ct"
        ];

        animations = {
          enabled = true;
          bezier = ["myBezier, 0.05, 0.9, 0.1, 1.05"];
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "windowsMove, 1, 2, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        dwindle = {
          force_split = 2;
          pseudotile = true;
          preserve_split = true;
        };

        decoration = {
          rounding = 0;
          active_opacity = 1.0;
          inactive_opacity = 0.95;
          dim_inactive = false;
          dim_strength = 0.7;

          blur = {
            enabled = true;
            size = 5;
            passes = 3;
            vibrancy = 0.4;
            new_optimizations = true;
            ignore_opacity = true;
            xray = true;
            special = true;
          };

          shadow = {
            enabled = true;
            range = 8;
            render_power = 2;
            offset = "0 0";
          };
        };

        general = {
          gaps_in = 3;
          gaps_out = 3;
          border_size = 2;
          layout = "dwindle";
        };

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          repeat_rate = 30;
          repeat_delay = 300;
          kb_options = "ctrl:nocaps";

          touchpad = {
            natural_scroll = false;
            disable_while_typing = true;
          };
        };

        misc = {
          disable_splash_rendering = true;
          force_default_wallpaper = false;
          vfr = true;
          vrr = 0;
        };

        layerrule = [
          "blur, notifications"
          "blur, launcher"
          "blur, lockscreen"
          "ignorealpha 0.69, notifications"
          "ignorealpha 0.69, launcher"
          "ignorealpha 0.69, lockscreen"
        ];

        workspace = [
          "w[tv1], gapsout:0, gapsin:0"
          "f[1], gapsout:0, gapsin:0"
          "1, monitor:0"
          "2, monitor:0"
          "3, monitor:0"
          "4, monitor:0"
          "5, monitor:0"
          "6, monitor:0"
          "7, monitor:0"
          "8, monitor:0"
          "9, monitor:0"
          "10, monitor:0"
        ];

        bind = [
          "$mod, Q, exec, ${pkgs.ghostty}/bin/ghostty"
          "$mod, D, exec, ${pkgs.fuzzel}/bin/fuzzel"
          "$mod, Space, exec, ${pkgs.rofi}/bin/rofi -show drun"
          "$mod SHIFT, Space, exec, ${pkgs.rofi}/bin/rofi -show run"
          "$mod ALT, Space, exec, ${pkgs.rofi}/bin/rofi -show window"
          "$mod, C, killactive"
          "$mod, M, exit"
          "$mod, F, fullscreen, 0"

          ", Print, exec, grimblast --notify copy screen"
          "$mod, S, exec, grimblast --notify save area ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"
          "$mod SHIFT, S, exec, grimblast --notify save active ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"
          "$mod ALT, S, exec, grimblast --notify copy area"

          "$mod, h, movefocus, l"
          "$mod, j, movefocus, d"
          "$mod, k, movefocus, u"
          "$mod, l, movefocus, r"

          "$mod CTRL, h, resizeactive, -20 0"
          "$mod CTRL, j, resizeactive, 0 20"
          "$mod CTRL, k, resizeactive, 0 -20"
          "$mod CTRL, l, resizeactive, 20 0"

          "$mod, left, movewindow, l"
          "$mod, right, movewindow, r"
          "$mod, up, movewindow, u"
          "$mod, down, movewindow, d"
          "$mod SHIFT, h, movewindow, l"
          "$mod SHIFT, l, movewindow, r"
          "$mod SHIFT, k, movewindow, u"
          "$mod SHIFT, j, movewindow, d"

          "$mod ALT, h, movecurrentworkspacetomonitor, l"
          "$mod ALT, l, movecurrentworkspacetomonitor, r"
          "$mod ALT, k, movecurrentworkspacetomonitor, u"
          "$mod ALT, j, movecurrentworkspacetomonitor, d"

          "$mod ALT, 1, focusmonitor, 0"
          "$mod ALT, 2, focusmonitor, 1"
          "$mod ALT, 3, focusmonitor, 2"

          "$mod ALT SHIFT, 1, movewindow, mon:0"
          "$mod ALT SHIFT, 2, movewindow, mon:1"
          "$mod ALT SHIFT, 3, movewindow, mon:2"

          "$mod ALT CTRL, 1, moveworkspacetomonitor, 1 0"
          "$mod ALT CTRL, 2, moveworkspacetomonitor, 2 1"
          "$mod ALT CTRL, 3, moveworkspacetomonitor, 3 2"

          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"

          "$mod SHIFT, 1, movetoworkspacesilent, 1"
          "$mod SHIFT, 2, movetoworkspacesilent, 2"
          "$mod SHIFT, 3, movetoworkspacesilent, 3"
          "$mod SHIFT, 4, movetoworkspacesilent, 4"
          "$mod SHIFT, 5, movetoworkspacesilent, 5"
          "$mod SHIFT, 6, movetoworkspacesilent, 6"
          "$mod SHIFT, 7, movetoworkspacesilent, 7"
          "$mod SHIFT, 8, movetoworkspacesilent, 8"
          "$mod SHIFT, 9, movetoworkspacesilent, 9"
          "$mod SHIFT, 0, movetoworkspacesilent, 10"

          ", XF86AudioRaiseVolume, exec, pamixer -i 5"
          ", XF86AudioLowerVolume, exec, pamixer -d 5"
          ", XF86AudioMute, exec, pamixer -t"

          "$mod, equal, exec, pamixer -i 5"
          "$mod, minus, exec, pamixer -d 5"
          "$mod, m, exec, pamixer -t"

          "$mod ALT, o, exec, audio-switcher output"
          "$mod ALT, i, exec, audio-switcher input"
          "$mod ALT, p, exec, pavucontrol"
          "$mod ALT, q, exec, qpwgraph"
          "$mod ALT, h, exec, helvum"
          "$mod ALT, e, exec, easyeffects"
          "$mod ALT, v, exec, rofi-volume"
        ];
      };
    };

    services.hyprpaper = {
      enable = true;

      settings = {
        preload = ["${self}/assets/wallpaper.png"];

        wallpaper = [", ${self}/assets/wallpaper.png"];
      };
    };

    systemd.user.services.hyprpaper.Unit.After = lib.mkForce "graphical-session.target";
  };
}
