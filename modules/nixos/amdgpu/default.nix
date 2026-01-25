{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.amdgpu;
in {
  options.myOptions.amdgpu = {
    enable = mkEnableOption "AMD GPU Support";
  };

  config = mkIf cfg.enable {
    boot.initrd.kernelModules = ["amdgpu"];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        libvdpau-va-gl
        libva-vdpau-driver
        libva-utils
      ];
    };

    hardware.firmware = [pkgs.linux-firmware];

    environment.variables = {
      AMD_VULKAN_ICD = "RADV";
      RADV_PERFTEST = "aco";
    };
  };
}
