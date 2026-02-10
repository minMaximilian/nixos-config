{
  lib,
  inputs,
  pkgs,
  config,
  self ? null,
  ...
}: {
  imports = [
    ./users.nix
    ./home-manager.nix
  ];

  nixpkgs.overlays = lib.mkIf (self != null && self ? overlays) [self.overlays.default];

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      warn-dirty = false;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  boot.loader.systemd-boot.configurationLimit = 10;
  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.networkmanager.enable = true;
  services.xserver.xkb.layout = "us";
  services.printing.enable = true;

  time.timeZone = config.myOptions.vars.timezone;

  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IE.UTF-8";
    LC_IDENTIFICATION = "en_IE.UTF-8";
    LC_MEASUREMENT = "en_IE.UTF-8";
    LC_MONETARY = "en_IE.UTF-8";
    LC_NAME = "en_IE.UTF-8";
    LC_NUMERIC = "en_IE.UTF-8";
    LC_PAPER = "en_IE.UTF-8";
    LC_TELEPHONE = "en_IE.UTF-8";
    LC_TIME = "en_IE.UTF-8";
  };

  nixpkgs.config.allowUnfree = true;

  environment.pathsToLink = ["/share/xdg-desktop-portal" "/share/applications"];

  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    git
    home-manager
    python3
    unzip
  ];
}
