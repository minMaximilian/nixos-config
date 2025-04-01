{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.myOptions.boot;
in {
  config = mkIf (cfg.enable && cfg.loader == "systemd-boot") {
    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = cfg.configurationLimit;
      # Add Windows boot entry if windows dual boot is enabled
      extraEntries = mkIf (cfg.dualBoot.enable && cfg.dualBoot.windows.enable) {
        "windows.conf" = ''
          title Windows
          efi ${cfg.dualBoot.windows.efiPath}
          graphics auto
        '';
      };
    };

    boot.loader.efi.canTouchEfiVariables = true;
  };
}
