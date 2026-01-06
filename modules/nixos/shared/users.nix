{
  config,
  lib,
  ...
}: let
  cfg = config.myOptions.vars;
in {
  users = {
    mutableUsers = true;
    users.${cfg.username} = {
      uid = 1000;
      isNormalUser = true;
      extraGroups =
        [
          "seat"
          "video"
          "wheel"
        ]
        ++ lib.optional config.virtualisation.libvirtd.enable "libvirtd"
        ++ lib.optional config.virtualisation.docker.enable "docker"
        ++ lib.optional config.networking.networkmanager.enable "networkmanager";
      openssh.authorizedKeys.keys = cfg.sshKeys;
    };
  };
}
