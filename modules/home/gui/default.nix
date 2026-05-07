{
  lib,
  config,
  ...
}: {
  imports = [
    ./amp
    ./aseprite
    ./claude-code
    ./clipboard
    ./codex
    ./discord
    ./gammastep
    ./ghostty
    ./gimp
    ./helium
    ./hyprcursor
    ./hyprland
    ./komikku
    ./krita
    ./lockscreen
    ./nautilus
    ./obsidian
    ./opencode
    ./prism-launcher
    ./protonmail
    ./rofi
    ./ryujinx
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
    aseprite.enable = lib.mkDefault true;
    claude-code.enable = lib.mkDefault true;
    clipboard.enable = lib.mkDefault true;
    codex.enable = lib.mkDefault true;
    discord.enable = lib.mkDefault true;
    gammastep.enable = lib.mkDefault true;
    ghostty.enable = lib.mkDefault true;
    gimp.enable = lib.mkDefault true;
    helium.enable = lib.mkDefault true;
    hyprland.enable = lib.mkDefault true;
    komikku.enable = lib.mkDefault true;
    krita.enable = lib.mkDefault true;
    lockscreen.enable = lib.mkDefault true;
    nautilus.enable = lib.mkDefault true;
    obsidian.enable = lib.mkDefault true;
    opencode.enable = lib.mkDefault true;
    prismLauncher.enable = lib.mkDefault true;
    protonmail.enable = lib.mkDefault true;
    rofi.enable = lib.mkDefault true;
    ryujinx.enable = lib.mkDefault true;
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
