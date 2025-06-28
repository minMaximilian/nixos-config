{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  myOptions.vars.withGui = true;
  myOptions.amdgpu.enable = true; # Enable AMD GPU support for desktop

  # Temporarily disable waybar to test quickshell (backup available)
  myOptions.waybar.enable = false;
  myOptions.quickshell.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "whiteforest";
  networking.networkmanager.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    code-cursor
    firefox
  ];

  system.stateVersion = "24.11";
}
