{lib, ...}: {
  imports = [
    ./amp
    ./discord
    ./eww
    ./gammastep
    ./ghostty
    ./helium
    ./hyprcursor
    ./hyprland
    ./lockscreen
    ./mako
    ./nautilus
    ./obsidian
    ./prism-launcher
    ./protonmail
    ./rofi
    ./screenshot
    ./signal
    ./spicetify
    ./waybar
    ./zed
  ];

  config.myOptions = {
    amp.enable = lib.mkDefault true;
    discord.enable = lib.mkDefault true;
    gammastep.enable = lib.mkDefault true;
    ghostty.enable = lib.mkDefault true;
    hyprland.enable = lib.mkDefault true;
    lockscreen.enable = lib.mkDefault true;
    mako.enable = lib.mkDefault true;
    obsidian.enable = lib.mkDefault true;
    protonmail.enable = lib.mkDefault true;
    rofi.enable = lib.mkDefault true;
    screenshot.enable = lib.mkDefault true;
    signal.enable = lib.mkDefault true;
    spotify.enable = lib.mkDefault true;
    hyprcursor.enable = lib.mkDefault true;
  };
}
