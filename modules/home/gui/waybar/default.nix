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

  cfg = config.myOptions.waybar;
  theme = config.myOptions.theme;
  themeLib = config.lib.theme;
in {
  options.myOptions.waybar = {
    enable =
      mkEnableOption "Waybar status bar"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = false;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 32;
          spacing = 0;
          modules-left = [
            "hyprland/workspaces"
            "tray"
            "custom/lock"
            "custom/reboot"
            "custom/power"
          ];
          modules-center = ["hyprland/window"];
          modules-right = [
            "network"
            "battery"
            "bluetooth"
            "pulseaudio"
            "backlight"
            "custom/temperature"
            "memory"
            "cpu"
            "clock"
          ];
          "hyprland/workspaces" = {
            disable-scroll = false;
            all-outputs = true;
            format = "{icon}";
            format-icons = {
              active = "";
              default = "";
              empty = "";
            };
            on-click = "activate";
            persistent-workspaces = {
              "*" = [1 2 3 4 5];
            };
          };
          "custom/lock" = {
            format = "<span color='#${config.lib.stylix.colors.base0C}'>  </span>";
            on-click = "hyprlock";
            tooltip = true;
            tooltip-format = "Lock Screen";
          };
          "custom/reboot" = {
            format = "<span color='#${config.lib.stylix.colors.base0A}'>  </span>";
            on-click = "systemctl reboot";
            tooltip = true;
            tooltip-format = "Restart";
          };
          "custom/power" = {
            format = "<span color='#${config.lib.stylix.colors.base08}'>  </span>";
            on-click = "systemctl poweroff";
            tooltip = true;
            tooltip-format = "Shutdown";
          };
          network = {
            format-wifi = "<span color='#${config.lib.stylix.colors.base0C}'> 󰤨 </span>{essid} ";
            format-ethernet = "<span color='#${config.lib.stylix.colors.base0B}'>  </span>Wired ";
            tooltip-format = "<span color='#${config.lib.stylix.colors.base0E}'> 󰅧 </span>{bandwidthUpBytes}  <span color='#${config.lib.stylix.colors.base0D}'> 󰅢 </span>{bandwidthDownBytes}";
            format-linked = "<span color='#${config.lib.stylix.colors.base09}'> 󱘖 </span>{ifname} (No IP) ";
            format-disconnected = "<span color='#${config.lib.stylix.colors.base08}'>  </span>Disconnected ";
            format-alt = "<span color='#${config.lib.stylix.colors.base0C}'> 󰤨 </span>{signalStrength}% ";
            interval = 1;
          };
          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "<span color='#${config.lib.stylix.colors.base0B}'> {icon} </span>{capacity}% ";
            format-charging = " 󱐋{capacity}%";
            interval = 1;
            format-icons = ["󰂎" "󰁼" "󰁿" "󰂁" "󰁹"];
            tooltip = true;
          };
          pulseaudio = {
            format = "<span color='#${config.lib.stylix.colors.base0B}'>{icon}</span> {volume}% ";
            format-muted = "<span color='#${config.lib.stylix.colors.base08}'> 󰖁 </span> 0% ";
            format-icons = {
              headphone = "<span color='#${config.lib.stylix.colors.base0E}'>  </span>";
              hands-free = "<span color='#${config.lib.stylix.colors.base0E}'>  </span>";
              headset = "<span color='#${config.lib.stylix.colors.base0E}'>  </span>";
              phone = "<span color='#${config.lib.stylix.colors.base0C}'>  </span>";
              portable = "<span color='#${config.lib.stylix.colors.base0C}'>  </span>";
              car = "<span color='#${config.lib.stylix.colors.base09}'>  </span>";
              default = [
                "<span color='#${config.lib.stylix.colors.base03}'>  </span>"
                "<span color='#${config.lib.stylix.colors.base0A}'>  </span>"
                "<span color='#${config.lib.stylix.colors.base0B}'>  </span>"
              ];
            };
            on-click = "pavucontrol";
            on-click-right = "pavucontrol -t 3";
            on-click-middle = "pactl -- set-sink-mute 0 toggle";
            tooltip = true;
            tooltip-format = "Current system volume: {volume}%";
          };
          "custom/temperature" = {
            exec = "sensors | awk '/^Package id 0:/ {print int($4)}'";
            format = "<span color='#${config.lib.stylix.colors.base09}'> </span>{}°C ";
            interval = 5;
            tooltip = true;
            tooltip-format = "Current CPU temperature: {}°C";
          };
          memory = {
            format = "<span color='#${config.lib.stylix.colors.base0E}'>  </span>{used:0.1f}G/{total:0.1f}G ";
            tooltip = true;
            tooltip-format = "Memory usage: {used:0.2f}G/{total:0.2f}G";
          };
          cpu = {
            format = "<span color='#${config.lib.stylix.colors.base09}'>  </span>{usage}% ";
            tooltip = true;
          };
          clock = {
            interval = 1;
            timezone = "Europe/Dublin";
            format = "<span color='#${config.lib.stylix.colors.base0E}'>  </span>{:%a %d %b %H:%M} ";
            tooltip = true;
            tooltip-format = "{:%Y-%m-%d, %A}";
          };
          tray = {
            icon-size = 14;
            spacing = 10;
          };
          backlight = {
            device = "intel_backlight";
            format = "<span color='#${config.lib.stylix.colors.base0A}'>{icon}</span> {percent}% ";
            tooltip = true;
            tooltip-format = "Screen brightness: {percent}%";
            format-icons = [
              "<span color='#${config.lib.stylix.colors.base03}'> 󰃞 </span>"
              "<span color='#${config.lib.stylix.colors.base04}'> 󰃝 </span>"
              "<span color='#${config.lib.stylix.colors.base0A}'> 󰃟 </span>"
              "<span color='#${config.lib.stylix.colors.base0A}'> 󰃠 </span>"
            ];
          };
          bluetooth = {
            format = "<span color='#${config.lib.stylix.colors.base0D}'>  </span>{status} ";
            format-connected = "<span color='#${config.lib.stylix.colors.base0D}'>  </span>{device_alias} ";
            format-connected-battery = "<span color='#${config.lib.stylix.colors.base0D}'>  </span>{device_alias}{device_battery_percentage}% ";
            tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
            tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
            on-click = "blueman-manager";
          };
        };
      };
      style = let
        colors = config.lib.stylix.colors;
        opacity = toString theme.opacity.background;
        margin = themeLib.css.margin;
        borderRadius = themeLib.css.borderRadius;
        paddingSmall = themeLib.css.paddingSmall;
        paddingMedium = themeLib.css.paddingMedium;
      in ''
        * {
          font-family: "${theme.fonts.mono}", "Font Awesome 6 Free", "Font Awesome 6 Free Solid", "Symbols Nerd Font Mono";
          font-weight: bold;
          font-size: ${themeLib.css.fontSizeLarge};
          color: #${colors.base05};
        }

        window#waybar {
          all: unset;
          background-color: rgba(0, 0, 0, 0);
          border: none;
          box-shadow: none;
        }

        #workspaces,
        #window,
        #tray{
          background-color: rgba(${colors.base01-rgb-r}, ${colors.base01-rgb-g}, ${colors.base01-rgb-b}, ${opacity});
          padding: ${paddingSmall} 2px;
          margin-top: ${margin};
          margin-left: ${margin};
          margin-right: ${margin};
          border-radius: ${borderRadius};
          border-width: 0px;
        }

        #clock,
        #custom-power{
          background-color: rgba(${colors.base01-rgb-r}, ${colors.base01-rgb-g}, ${colors.base01-rgb-b}, ${opacity});
          margin-top: ${margin};
          margin-right: ${margin};
          padding: ${paddingSmall} ${paddingMedium};
          border-radius: 0 ${borderRadius} ${borderRadius} 0;
          border-width: 0px;
        }

        #network,
        #custom-lock{
          background-color: rgba(${colors.base01-rgb-r}, ${colors.base01-rgb-g}, ${colors.base01-rgb-b}, ${opacity});
          margin-top: ${margin};
          margin-left: ${margin};
          padding: ${paddingSmall} ${paddingMedium};
          border-radius: ${borderRadius} 0 0 ${borderRadius};
          border-width: 0px;
        }

        #custom-reboot,
        #bluetooth,
        #battery,
        #pulseaudio,
        #backlight,
        #custom-temperature,
        #memory,
        #cpu{
          background-color: rgba(${colors.base01-rgb-r}, ${colors.base01-rgb-g}, ${colors.base01-rgb-b}, ${opacity});
          margin-top: ${margin};
          padding: ${paddingSmall} ${paddingMedium};
          border-width: 0px;
        }

        #custom-temperature.critical,
        #pulseaudio.muted {
          color: #${colors.base08};
          padding-top: 0;
        }

        #bluetooth:hover,
        #network:hover,
        #backlight:hover,
        #battery:hover,
        #pulseaudio:hover,
        #custom-temperature:hover,
        #memory:hover,
        #cpu:hover,
        #clock:hover,
        #custom-lock:hover,
        #custom-reboot:hover,
        #custom-power:hover,
        #window:hover {
          background-color: rgba(${colors.base02-rgb-r}, ${colors.base02-rgb-g}, ${colors.base02-rgb-b}, ${opacity});
        }

        #workspaces {
          padding: 2px 5px;
        }

        #workspaces button {
          all: unset;
          padding: 2px 10px 2px ${paddingSmall};
          margin: 0 ${paddingSmall};
          background: transparent;
          border-bottom: ${themeLib.css.borderWidth} solid transparent;
        }

        #workspaces button:hover {
          transition: all 1s ease;
        }

        #workspaces button.active {
          color: #${colors.base0D};
          border-bottom: ${themeLib.css.borderWidth} solid #${colors.base0D};
        }
      '';
    };
  };
}
