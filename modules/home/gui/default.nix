{
  lib,
  config,
  ...
}: {
  imports = [
    ./amp
    ./clipboard
    ./discord
    ./gammastep
    ./ghostty
    ./helium
    ./hyprcursor
    ./hyprland
    ./komikku
    ./krita
    ./lockscreen
    ./nautilus
    ./obsidian
    ./prism-launcher
    ./protonmail
    ./rofi
    ./screenshot
    ./signal
    ./spicetify
    ./tauon
    ./qbittorrent
    ./quickshell
    ./vlc
    ./zed
  ];

  config.myOptions = {
    amp.enable = lib.mkDefault true;
    clipboard.enable = lib.mkDefault true;
    discord.enable = lib.mkDefault true;
    gammastep.enable = lib.mkDefault true;
    ghostty.enable = lib.mkDefault true;
    helium.enable = lib.mkDefault true;
    hyprland.enable = lib.mkDefault true;
    komikku.enable = lib.mkDefault true;
    krita.enable = lib.mkDefault true;
    lockscreen.enable = lib.mkDefault true;
    nautilus.enable = lib.mkDefault true;
    obsidian.enable = lib.mkDefault true;
    prismLauncher.enable = lib.mkDefault true;
    protonmail.enable = lib.mkDefault true;
    rofi.enable = lib.mkDefault true;
    screenshot.enable = lib.mkDefault true;
    signal.enable = lib.mkDefault true;
    spotify.enable = lib.mkDefault false;
    tauon.enable = lib.mkDefault true;
    hyprcursor.enable = lib.mkDefault true;
    qbittorrent.enable = lib.mkDefault true;
    quickshell.enable = lib.mkDefault true;
    vlc.enable = lib.mkDefault true;
    zed.enable = lib.mkDefault true;
  };
}
