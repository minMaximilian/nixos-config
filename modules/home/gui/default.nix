{
  lib,
  config,
  ...
}: {
  imports = [
    ./aseprite
    ./autostart
    ./blockbench
    ./discord
    ./ghostty
    ./gimp
    ./helium
    ./hyprland
    ./komikku
    ./krita
    ./lockscreen
    ./nautilus
    ./obs
    ./obsidian
    ./prism-launcher
    ./protonmail
    ./ryujinx
    ./screenshot
    ./signal
    ./spicetify
    ./tauon
    ./tidal
    ./qbittorrent
    ./url-privacy
    ./noctalia
    ./vlc
    ./xournalpp
  ];

  config.myOptions = {
    aseprite.enable = lib.mkDefault true;
    guiAutostart.enable = lib.mkDefault true;
    blockbench.enable = lib.mkDefault true;
    discord.enable = lib.mkDefault true;
    ghostty.enable = lib.mkDefault true;
    gimp.enable = lib.mkDefault true;
    helium.enable = lib.mkDefault true;
    hyprland.enable = lib.mkDefault true;
    komikku.enable = lib.mkDefault true;
    krita.enable = lib.mkDefault true;
    lockscreen = {
      enable = lib.mkDefault true;
      lockOnStartup = lib.mkDefault true;
    };
    nautilus.enable = lib.mkDefault true;
    obs.enable = lib.mkDefault true;
    obsidian.enable = lib.mkDefault true;
    prismLauncher.enable = lib.mkDefault true;
    protonmail.enable = lib.mkDefault true;
    ryujinx.enable = lib.mkDefault true;
    screenshot.enable = lib.mkDefault true;
    signal.enable = lib.mkDefault true;
    spotify.enable = lib.mkDefault false;
    tauon.enable = lib.mkDefault true;
    tidal.enable = lib.mkDefault true;
    qbittorrent.enable = lib.mkDefault true;
    urlPrivacy.enable = lib.mkDefault true;
    noctalia.enable = lib.mkDefault true;
    vlc.enable = lib.mkDefault true;
    xournalpp.enable = lib.mkDefault true;
  };
}
