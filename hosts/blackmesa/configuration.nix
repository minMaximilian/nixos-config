{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
  ];

  myOptions.vars.withGui = false;

  nixpkgs.hostPlatform = "x86_64-linux";

  myOptions.theme = {
    enable = true;
    colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;
  };
  programs.nix-ld.enable = true;
  wsl = {
    enable = true;
    defaultUser = "max";
    startMenuLaunchers = true;

    wslConf = {
      automount.enabled = true;
      interop.appendWindowsPath = true;
    };
  };

  users.users.max = {
    uid = lib.mkForce 1000;
    isNormalUser = true;
    extraGroups = ["wheel"];
  };

  networking.hostName = "wsl";

  home-manager.users.max.home.stateVersion = "24.05";

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05";
}
