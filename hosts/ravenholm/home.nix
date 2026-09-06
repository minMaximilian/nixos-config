{lib, ...}: {
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
    home.stateVersion = "24.11";
    # Retain the effective existing settings; hardware changes are a separate task.
    programs.noctalia.settings.bar.main.monitor."DP-3" = {
      match = "DP-3";
      padding = 24;
      widget_spacing = 12;
      scale = 1.05;
    };
  };
}
