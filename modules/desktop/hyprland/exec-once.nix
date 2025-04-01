{pkgs, ...}: [
  "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
  "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
  "waybar &"
  "${pkgs.mako}/bin/mako &"
]
