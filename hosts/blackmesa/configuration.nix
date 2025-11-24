{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
  ];

  myOptions.vars.withGui = false;

  nixpkgs.hostPlatform = "x86_64-linux";

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

  networking.hostName = "blackmesa";

  home-manager.users.max.home.stateVersion = "24.05";
  home-manager.users.max.myOptions.zed.enable = true;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05";
}
