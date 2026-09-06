{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ./feeds.nix
    ./home.nix
    ../../profiles/nixos/workstation.nix
    ../../profiles/nixos/gaming.nix
    ../../users/max/nixos.nix
    ../../modules/nixos/amdgpu
    ../../modules/nixos/ml
    ../../modules/nixos/logitech
    ../../modules/nixos/tablet
    ../../modules/nixos/games/deadlock-mod-manager.nix
    ../../modules/nixos/games/teamspeak.nix
    ../../modules/nixos/protonvpn
  ];

  myOptions = {
    amdgpu.enable = true;
    amdgpu.rocm.enable = true;
    ml.enable = true;
    logitech.enable = true;
    tablet.enable = true;
    deadlockModManager.enable = true;
    teamspeak.enable = true;
    protonvpn.enable = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_zen;
  environment.systemPackages = [
    (pkgs.callPackage ../../packages/gamescope-native {
      width = 3440;
      height = 1440;
      refreshRate = 144;
    })
  ];
  networking.hostName = "whiteforest";
  services.resolved.enable = true;
  system.stateVersion = "25.11";
}
