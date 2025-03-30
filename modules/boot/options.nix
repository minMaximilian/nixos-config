{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.myOptions.boot;
in {
  options.myOptions.boot = {
    enable = mkEnableOption "Boot configuration";

    loader = mkOption {
      type = types.enum ["systemd-boot" "grub"];
      default = "systemd-boot";
      description = "Boot loader to use";
    };

    dualBoot = {
      enable = mkEnableOption "Dual boot with other OS";

      windows = {
        enable = mkEnableOption "Windows dual boot";
        efiPath = mkOption {
          type = types.str;
          default = "/EFI/Microsoft/Boot/bootmgfw.efi";
          description = "Path to Windows EFI file relative to ESP root";
        };
      };
    };

    configurationLimit = mkOption {
      type = types.int;
      default = 10;
      description = "Maximum number of generations to keep";
    };
  };
}
