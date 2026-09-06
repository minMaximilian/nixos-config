{
  pkgs,
  lib,
  ...
}: {
  home-manager.users.max = {
    imports = [
      ../../profiles/home/development.nix
      ../../profiles/home/desktop.nix
    ];
    wayland.windowManager.hyprland.settings.workspace = lib.mkAfter [
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
    home.stateVersion = "25.11";
    myOptions.hyprland.monitors = [
      "DP-3, 3440x1440@144, 2560x0, 1"
      "HDMI-A-1, 2560x1440@60, 0x0, 1"
    ];
    programs.noctalia.settings.bar.main.monitor."DP-3" = {
      match = "DP-3";
      padding = 24;
      widget_spacing = 12;
      scale = 1.05;
    };
    xdg.configFile."autostart/solaar.desktop".text = ''
      [Desktop Entry]
      Name=Solaar
      Comment=Logitech device manager
      Exec=${pkgs.solaar}/bin/solaar --window=hide
      Icon=solaar
      Terminal=false
      Type=Application
      Categories=Utility;
      StartupNotify=false
    '';
  };
}
