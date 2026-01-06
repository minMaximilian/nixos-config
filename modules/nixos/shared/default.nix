{
  lib,
  inputs,
  pkgs,
  config,
  self,
  ...
}: {
  imports = [
    ./users.nix
    ./home-manager.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  nixpkgs.overlays = [self.overlays.default];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  time.timeZone = "Europe/Dublin";

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
