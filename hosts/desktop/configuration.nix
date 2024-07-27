{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./home.nix
    ../common.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
    };
  };

  boot.initrd.luks.devices."luks-c2722997-f97a-416b-8774-c0dd5eddb092".device = "/dev/disk/by-uuid/c2722997-f97a-416b-8774-c0dd5eddb092";
  networking.hostName = "desktop";

  networking.networkmanager.enable = true;

  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  programs.firefox.enable = true;
  programs.git.enable = true;

  services.printing.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    vscode
    discord
  ];

  system.stateVersion = "24.05";
}
