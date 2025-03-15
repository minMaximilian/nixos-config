# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    # No VSCode module import needed for manual approach
  ];

  myOptions.vars.withGui = false; # WSL typically doesn't need GUI
  
  # Set the platform
  nixpkgs.hostPlatform = "x86_64-linux";

  # Enable theme configuration for terminal usage
  myOptions.theme = {
    enable = true;
    colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;
  };

  wsl = {
    enable = true;
    defaultUser = "max";
    startMenuLaunchers = true;

    # Enable Windows PATH element
    wslConf = {
      automount.enabled = true;
      interop.appendWindowsPath = true;
    };
  };

  # Configure users
  users.users.max = {
    uid = lib.mkForce 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # Use the default username from the modules/vars/default.nix
  # myOptions.vars.username is already set to "max" by default

  networking.hostName = "wsl";

  home-manager.users.max.home.stateVersion = "24.05";

  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}