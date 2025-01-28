{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  cfg = config.myOptions.waybar;
in {
  options.myOptions.waybar = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Waybar status bar";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.max = {
      programs.waybar = {
        enable = true;
        systemd = {
          enable = true;
          target = "hyprland-session.target";
        };
        settings = {
          mainBar = {
            layer = "top";
            position = "top";
            height = 30;
            spacing = 4;
            modules-left = [
              "hyprland/workspaces"
              "hyprland/window"
            ];
            modules-center = [
              "clock"
            ];
            modules-right = [
              "pulseaudio"
              "network"
              "cpu"
              "memory"
              "battery"
              "tray"
            ];
            "hyprland/workspaces" = {
              format = "{icon}";
              on-click = "activate";
              sort-by-number = true;
            };
            cpu = {
              format = "󰻠 {usage}%";
              tooltip = false;
            };
            battery = {
              states = {
                warning = 30;
                critical = 15;
              };
              format = "󰁹 {capacity}%";
              format-charging = "󰂄 {capacity}%";
              format-plugged = "󰂄 {capacity}%";
            };
            network = {
              format-wifi = "󰤨 {signalStrength}%";
              format-ethernet = "󰈀 ";
              format-disconnected = "󰖪";
            };
            pulseaudio = {
              format = "{icon} {volume}%";
              format-muted = "󰝟";
              format-icons = {
                default = ["󰕿" "󰖀" "󰕾"];
              };
            };
            memory = {
              format = "󰍛 {}%";
            };
            clock = {
              format = "󰅐 {:%H:%M}";
              format-alt = " {:%Y-%m-%d}";
              tooltip-format = "{:%Y-%m-%d | %H:%M}";
            };
          };
        };
        style = ''
          * {
            border: none;
            border-radius: 0;
            font-family: "FiraCode Nerd Font", "Material Symbols", "Material Design Icons", "Font Awesome 6 Free", monospace;
            font-size: 14px;
            min-height: 0;
          }

          window#waybar {
            background: rgba(30, 30, 46, 0.9);
            color: #cdd6f4;
          }

          #workspaces button {
            padding: 0 5px;
            background: transparent;
            color: #cdd6f4;
          }

          #workspaces button:hover {
            background: rgba(137, 180, 250, 0.2);
          }

          #workspaces button.active {
            background: rgba(137, 180, 250, 0.4);
          }

          #battery,
          #cpu,
          #memory,
          #network,
          #pulseaudio,
          #tray {
            padding: 0 10px;
          }

          #battery.warning {
            color: #ff9e64;
          }

          #battery.critical {
            color: #f7768e;
          }
        '';
      };
    };
  };
}
