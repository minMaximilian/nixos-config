{
  pkgs,
  nixpkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
    "2606:4700:4700:1111"
    "2001:4860:4860:8888"
  ];

  time.timeZone = "Europe/Dublin";

  i18n.defaultLocale = "en_US.UTF-8";

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

  users.users.max = {
    isNormalUser = true;
    description = "Max";
    extraGroups = ["networkmanager" "wheel" "docker"];
    home = "/home/max";
    createHome = true;
    shell = pkgs.zsh;
  };

  # users.mutableUsers = false;

  environment.systemPackages = with pkgs; [
    wget
    nil
    nixpkgs-fmt
    home-manager
    alacritty
    vim
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.max = import ../home-manager/home.nix;

  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixVersions.latest;
    settings.experimental-features = ["nix-command" "flakes"];
  };
}
