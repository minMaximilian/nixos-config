{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.myOptions.amdgpu;
  username = config.myOptions.vars.username;
in {
  options.myOptions.amdgpu = {
    enable = mkEnableOption "AMD GPU Support";

    rocm.enable = mkEnableOption ''
      ROCm / HIP compute stack (OpenCL, HIP, rocBLAS). Enables GPU
      compute for ML training, Blender HIP, etc. Adds the primary user
      to the `render` group and exposes HIP libs at /opt/rocm
    '';
  };

  config = mkMerge [
    (mkIf cfg.enable {
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
    })

    (mkIf (cfg.enable && cfg.rocm.enable) {
      # OpenCL via ROCm runtime (registers rocmPackages.clr.icd)
      hardware.amdgpu.opencl.enable = true;

      # Many upstream binaries hard-code /opt/rocm. Expose a combined
      # tree containing the HIP runtime + common math libs there.
      systemd.tmpfiles.rules = let
        rocmEnv = pkgs.symlinkJoin {
          name = "rocm-combined";
          paths = with pkgs.rocmPackages; [
            rocblas
            hipblas
            clr
          ];
        };
      in ["L+    /opt/rocm   -    -    -     -    ${rocmEnv}"];

      # /dev/kfd is owned by render group; needed for HSA / HIP / ROCm.
      users.users.${username}.extraGroups = ["render"];

      environment.systemPackages = with pkgs; [
        rocmPackages.rocminfo
        rocmPackages.rocm-smi
        clinfo
        amdgpu_top
      ];
    })
  ];
}
