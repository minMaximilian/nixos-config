{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  myOptions.vars.withGui = true;
  myOptions.amdgpu.enable = true;
  myOptions.logitech.enable = true;
  myOptions.deadlockModManager.enable = true;
  myOptions.teamspeak.enable = true;

  myOptions.hyprland.monitors = [
    "DP-3, 3440x1440@144, 2560x0, 1"
    "HDMI-A-1, 2560x1440@60, 0x0, 2"
  ];

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
  ];

  system.stateVersion = "25.11";
}
