{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.environments.gnome;
in {
  options.environments.gnome = {
    enable = mkEnableOption "GNOME desktop environment";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
      desktopManager.gnome.enable = true;
    };

    environment.systemPackages = with pkgs; [
      gnome.gnome-tweaks
      gnome.dconf-editor
      gnome-extension-manager
    ];

    services.gnome = {
      core-utilities.enable = true;
      games.enable = false;
    };

    programs.dconf.enable = true;

    environment.gnome.excludePackages = with pkgs.gnome; [
      epiphany
      geary
    ];
  };
}
