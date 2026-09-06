{
  imports = [
    ./base.nix
    ../../modules/shared/theme.nix
    ../../modules/nixos/audio
    ../../modules/nixos/bluetooth
    ../../modules/nixos/fonts
    ../../modules/nixos/desktop/hyprland.nix
    ../../modules/nixos/login
    ../../modules/nixos/multimedia
    ../../modules/nixos/theme
  ];
  myOptions = {
    audio.enable = true;
    bluetooth.enable = true;
    fonts.enable = true;
    hyprland.enable = true;
    login.enable = true;
    multimedia.enable = true;
    theme.enable = true;
  };
  services.xserver.xkb.layout = "us";
  services.printing.enable = true;
  environment.pathsToLink = ["/share/xdg-desktop-portal" "/share/applications"];
  programs.dconf.enable = true;
}
