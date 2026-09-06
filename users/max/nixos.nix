{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.home-manager.nixosModules.home-manager];
  programs.fish.enable = true;
  programs.nano.enable = false;
  services.greetd.settings.default_session.user = lib.mkIf config.services.greetd.enable "max";
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {inherit inputs;};
    users.max = import ./home.nix;
  };
  users = {
    mutableUsers = true;
    users.max = {
      uid = 1000;
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups =
        [
          "seat"
          "video"
          "wheel"
        ]
        ++ lib.optional config.virtualisation.libvirtd.enable "libvirtd"
        ++ lib.optional config.virtualisation.docker.enable "docker"
        ++ lib.optional config.networking.networkmanager.enable "networkmanager"
        ++ lib.optional config.programs.gamemode.enable "gamemode"
        ++ lib.optional config.hardware.amdgpu.opencl.enable "render"
        ++ lib.optional (config.myOptions.android.enable or false) "kvm";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFciJM84Q9pV8/QcDyO6fgHdPmYN9VgrMQhDY2hZ+a4p max@nixos"
      ];
    };
  };
}
