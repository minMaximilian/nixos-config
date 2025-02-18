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
in {
  options.myOptions.waybar = {
    enable =
      mkEnableOption "Waybar status bar"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.myOptions.vars.username} = {
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
            height = 32;
            margin = "0";
            spacing = 0;
            fixed-center = true;
            ipc = true;
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
        style = import ./style.nix {inherit config;};
      };
    };
  };
}
