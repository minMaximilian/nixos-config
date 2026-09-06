{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/shared/theme.nix
    ../../modules/home/gui/autostart
    ../../modules/home/gui/discord
    ../../modules/home/gui/ghostty
    ../../modules/home/gui/helium
    ../../modules/home/gui/hyprland
    ../../modules/home/gui/krita
    ../../modules/home/gui/libreoffice
    ../../modules/home/gui/lockscreen
    ../../modules/home/gui/nautilus
    ../../modules/home/gui/obsidian
    ../../modules/home/gui/prism-launcher
    ../../modules/home/gui/protonmail
    ../../modules/home/gui/screenshot
    ../../modules/home/gui/signal
    ../../modules/home/gui/tidal
    ../../modules/home/gui/qbittorrent
    ../../modules/home/gui/url-privacy
    ../../modules/home/gui/noctalia
  ];

  config.home.packages = with pkgs; [aseprite blockbench gimp komikku unrar vlc xournalpp tauon ryubing];
  config.programs.obs-studio.enable = true;
  config.myOptions = {
    guiAutostart.enable = lib.mkDefault true;
    discord.enable = lib.mkDefault true;
    ghostty.enable = lib.mkDefault true;
    helium.enable = lib.mkDefault true;
    hyprland.enable = lib.mkDefault true;
    krita.enable = lib.mkDefault true;
    libreoffice.enable = lib.mkDefault true;
    lockscreen = {
      enable = lib.mkDefault true;
      lockOnStartup = lib.mkDefault true;
    };
    nautilus.enable = lib.mkDefault true;
    obsidian.enable = lib.mkDefault true;
    prismLauncher.enable = lib.mkDefault true;
    protonmail.enable = lib.mkDefault true;
    screenshot.enable = lib.mkDefault true;
    signal.enable = lib.mkDefault true;
    tidal.enable = lib.mkDefault true;
    qbittorrent.enable = lib.mkDefault true;
    urlPrivacy.enable = lib.mkDefault true;
    noctalia.enable = lib.mkDefault true;
  };
  config.home.sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";
  config.systemd.user.startServices = "sd-switch";
  config.xdg.desktopEntries.xterm = {
    name = "XTerm";
    exec = "xterm";
    noDisplay = true;
  };
  config.home.pointerCursor.enable = true;
  config.stylix = {
    enableReleaseChecks = false;
    targets.hyprpaper.enable = lib.mkForce false;
    targets.vesktop.enable = false;
  };
}
