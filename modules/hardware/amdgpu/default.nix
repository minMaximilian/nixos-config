{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.amdgpu;
in {
  options.myOptions.amdgpu = {
    enable =
      mkEnableOption "AMD GPU Support"
      // {
        default = false;
      };
  };

  config = mkIf cfg.enable {
    boot.initrd.kernelModules = ["amdgpu"];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        amdvlk

        libvdpau-va-gl
        vaapiVdpau
        libva-utils
      ];

      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };

    hardware.firmware = with pkgs; [
      linux-firmware
    ];

    environment.variables = {
      AMD_VULKAN_ICD = "RADV";
      RADV_PERFTEST = "aco";
    };
  };
}
