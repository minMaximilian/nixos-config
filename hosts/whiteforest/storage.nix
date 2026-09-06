{lib, ...}: {
  imports = [
    ../../modules/nixos/preservation
    ../../users/max/persistence.nix
    ../../users/max/passwords.nix
  ];

  fileSystems."/" = lib.mkForce {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=8G" "mode=755"];
  };
  fileSystems."/state" = {
    device = "/dev/disk/by-uuid/b41e5b4b-5020-4c15-bd40-0f78d2c8e237";
    fsType = "ext4";
    neededForBoot = true;
  };
  fileSystems."/nix" = {
    device = "/state/nix";
    fsType = "none";
    options = ["bind"];
    neededForBoot = true;
  };
  fileSystems."/persist" = {
    device = "/state/persist";
    fsType = "none";
    options = ["bind"];
    neededForBoot = true;
  };
}
