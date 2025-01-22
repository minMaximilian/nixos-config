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
            clock = {
              format = "{:%H:%M}";
              format-alt = "{:%Y-%m-%d}";
              tooltip-format = "{:%Y-%m-%d | %H:%M}";
            };
            cpu = {
              format = "CPU {usage}%";
              tooltip = false;
            };
            memory = {
              format = "RAM {}%";
            };
            battery = {
              states = {
                warning = 30;
                critical = 15;
              };
              format = "{capacity}% {icon}";
              format-charging = "{capacity}% ";
              format-plugged = "{capacity}% ";
              format-icons = ["" "" "" "" ""];
            };
            network = {
              format-wifi = "WiFi ({signalStrength}%)";
              format-ethernet = "Ethernet";
              format-disconnected = "Disconnected";
            };
            pulseaudio = {
              format = "{volume}% {icon}";
              format-muted = "Muted";
              format-icons = {
                default = ["" "" ""];
              };
            };
          };
        };
        style = ''
          * {
            border: none;
            border-radius: 0;
            font-family: monospace;
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
        '';
      };
    };
  };
}
