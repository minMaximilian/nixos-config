{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myOptions.ml;
in {
  options.myOptions.ml = {
    enable = lib.mkEnableOption ''
      Local ML training environment.

      Provides nix-ld + uv so AMD's prebuilt PyTorch ROCm wheels run
      out of the box. Avoids the multi-hour Nix-side rebuild of the
      ROCm stack every time nixpkgs is bumped.

      Per-project workflow:
        uv venv && source .venv/bin/activate
        uv pip install --index-url https://download.pytorch.org/whl/rocm6.2 \
            torch torchvision

      Verify:
        python -c "import torch; print(torch.cuda.is_available(),
                   torch.cuda.get_device_name(0))"
    '';
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.myOptions.amdgpu.rocm.enable or false;
        message = "myOptions.ml requires myOptions.amdgpu.rocm.enable = true";
      }
    ];

    # nix-ld lets dynamically-linked binaries built for "normal" Linux
    # (i.e. AMD's official torch wheels) find their interpreter + libs.
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        # C/C++ runtime
        stdenv.cc.cc.lib
        zlib
        zstd
        openssl

        # Graphics / DRM / ROCm runtime deps for /dev/kfd userspace
        libGL
        libdrm
        numactl
        elfutils

        # Common transitive deps of ML wheels
        glib
        libxml2
        libx11
        libxext
      ];
    };

    environment.systemPackages = with pkgs; [
      uv # fast venv + pip replacement
      python3 # bare interpreter (uv shells out to it)
    ];

    # gfx1030 (RX 6800/6900/6950 XT) is a first-class ROCm target,
    # so no HSA_OVERRIDE_GFX_VERSION is needed. Set ROCM_PATH for
    # tools that look it up explicitly.
    environment.variables.ROCM_PATH = "/opt/rocm";
  };
}
