{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.environments.plasma;
in {
  options.environments.plasma = {
    enable = mkEnableOption "KDE Plasma desktop environment";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };
      desktopManager.plasma5 = {
        enable = true;
        runUsingSystemd = true;
      };
    };

    environment.systemPackages = with pkgs; [
      kde-applications
      libsForQt5.kdeconnect-kde
      libsForQt5.kdeplasma-addons
      libsForQt5.kwin
      plasma-desktop
      plasma-workspace
    ];

    programs.dconf.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-kde];
    };

    qt5 = {
      enable = true;
      platformTheme = "kde";
      style = "breeze";
    };

    networking.networkmanager.enable = true;

    sound.enable = true;
    hardware.pulseaudio.enable = true;

    services.blueman.enable = true;

    services.xserver.libinput.enable = true;

    services.xserver.displayManager.autoLogin.enable = true;
    services.xserver.displayManager.autoLogin.user = "max";

    powerManagement.enable = true;
    services.upower.enable = true;

    environment.sessionVariables = {
      KDEWM = "${pkgs.kwin_wayland}/bin/kwin_wayland";
    };
  };
}
