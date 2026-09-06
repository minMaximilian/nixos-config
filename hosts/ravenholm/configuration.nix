{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./home.nix
    ../../profiles/nixos/workstation.nix
    ../../profiles/nixos/gaming.nix
    ../../users/max/nixos.nix
  ];
  environment.systemPackages = [
    (pkgs.callPackage ../../packages/gamescope-native {
      width = 3440;
      height = 1440;
      refreshRate = 144;
    })
  ];
  networking.hostName = "ravenholm";
  system.stateVersion = "24.11";
}
