{
  config,
  pkgs,
  lib,
  inputs,
  self ? null,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.myOptions.hyprland;

  fullscreenToggle = pkgs.writeShellScript "fullscreen-toggle" ''
    ${pkgs.hyprland}/bin/hyprctl dispatch fullscreen 0
    if ${pkgs.hyprland}/bin/hyprctl activewindow -j | ${pkgs.jq}/bin/jq -e '.fullscreen != 0' > /dev/null; then
      ${pkgs.systemd}/bin/systemctl --user stop gammastep
    else
      ${pkgs.systemd}/bin/systemctl --user start gammastep
    fi
  '';

  defaultWallpaper =
    if self != null
    then "${self}/assets/wallpaper.png"
    else null;
in {
  options.myOptions.hyprland = {
    enable = mkEnableOption "Hyprland Window Manager";

    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [", preferred, auto, 1"];
      description = "Monitor configuration strings for Hyprland";
      example = ["DP-1, 2560x1440@144, 0x0, 1" "HDMI-A-1, 1920x1080@60, 2560x0, 1"];
    };

    wallpaper = mkOption {
      type = types.nullOr types.path;
      default = defaultWallpaper;
      description = "Path to wallpaper image for hyprpaper";
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
      package = pkgs.hyprland;
      settings = {
        "$mod" = "SUPER";

        monitor = cfg.monitors;

        exec-once =
          [
            "hyprlock"
            "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
            "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
            "uwsm finalize"
            "uwsm app -- ${pkgs.mako}/bin/mako"
            "wl-paste --type text --watch cliphist store"
            "wl-paste --type image --watch cliphist store"
            "steam"
            "vesktop"
            "helium"
            "spotify"
            "solaar --window=hide"
          ]
          ++ lib.optionals config.myOptions.waybar.enable [
            "uwsm app -- waybar"
          ]
          ++ [
            "hyprctl dispatch workspace 1"
          ];

        windowrule = [
          "workspace 1 silent, match:class ^steam$"
          "workspace 2 silent, match:class ^vesktop$"
          "workspace 3 silent, match:class ^helium$"
          "workspace 4 silent, match:class ^(S|s)potify$"
          "workspace special:solaar silent, match:class ^solaar$"
        ];

        env = [
          "QT_QPA_PLATFORMTHEME,qt5ct"
        ];

        animations = {
          enabled = false;
        };

        dwindle = {
          force_split = 2;
          pseudotile = true;
          preserve_split = true;
        };

        decoration = {
          rounding = 0;
          active_opacity = 1.0;
          inactive_opacity = 0.8;
          dim_inactive = false;

          blur.enabled = false;
          shadow.enabled = false;
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
          accel_profile = "flat";
          sensitivity = 0;

          touchpad = {
            natural_scroll = false;
            disable_while_typing = true;
          };
        };

        misc = {
          disable_splash_rendering = true;
          disable_hyprland_logo = true;
          force_default_wallpaper = false;
          vfr = true;
          vrr = 0;
        };

        ecosystem = {
          no_update_news = true;
        };

        layerrule = [
          "blur on, ignore_alpha 0.69, match:namespace notifications"
          "blur on, ignore_alpha 0.69, match:namespace launcher"
          "blur on, ignore_alpha 0.69, match:namespace lockscreen"
        ];

        workspace = [
          "w[tv1], gapsout:0, gapsin:0"
          "f[1], gapsout:0, gapsin:0"
          "0, monitor:1, default:true"
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
          "$mod, Space, exec, ${pkgs.rofi}/bin/rofi -show drun"
          "$mod SHIFT, Space, exec, ${pkgs.rofi}/bin/rofi -show run"
          "$mod ALT, Space, exec, ${pkgs.rofi}/bin/rofi -show window"

          "$mod, C, killactive"
          "$mod, F, exec, ${fullscreenToggle}"

          ", Print, exec, grimblast --notify copy area"
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
          "$mod SHIFT, h, movewindow, mon:l"
          "$mod SHIFT, l, movewindow, mon:r"
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
          "$mod, 0, workspace, 0"

          "$mod SHIFT, 1, movetoworkspacesilent, 1"
          "$mod SHIFT, 2, movetoworkspacesilent, 2"
          "$mod SHIFT, 3, movetoworkspacesilent, 3"
          "$mod SHIFT, 4, movetoworkspacesilent, 4"
          "$mod SHIFT, 5, movetoworkspacesilent, 5"
          "$mod SHIFT, 6, movetoworkspacesilent, 6"
          "$mod SHIFT, 7, movetoworkspacesilent, 7"
          "$mod SHIFT, 8, movetoworkspacesilent, 8"
          "$mod SHIFT, 9, movetoworkspacesilent, 9"
          "$mod SHIFT, 0, movetoworkspacesilent, 0"

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

          "$mod, V, exec, cliphist list | rofi -dmenu -p 'Clipboard' | cliphist decode | wl-copy && wtype -M ctrl v -m ctrl"
          "$mod SHIFT, V, exec, cliphist wipe"
        ];
      };
    };

    services.hyprpaper = {
      enable = cfg.wallpaper != null;

      settings = lib.mkIf (cfg.wallpaper != null) {
        splash = false;

        wallpaper = [
          {
            monitor = "";
            path = cfg.wallpaper;
          }
        ];
      };
    };

    systemd.user.services.hyprpaper = {
      Unit = {
        After = lib.mkForce ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Install.WantedBy = lib.mkForce ["graphical-session.target"];
    };
  };
}
