{inputs, ...}: {
  imports = [inputs.preservation.nixosModules.preservation];

  preservation = {
    enable = true;
    preserveAt."/persist" = {
      commonMountOptions = ["x-gvfs-hide"];
      directories = [
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
        "/var/lib/NetworkManager"
        "/var/lib/bluetooth"
        "/var/lib/systemd/coredump"
        "/var/lib/postgresql"
        "/var/log"
        "/etc/NetworkManager/system-connections"
      ];
      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
      ];
    };
  };

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';
  systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];
}
