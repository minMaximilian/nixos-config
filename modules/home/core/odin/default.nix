{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.odin;
in {
  options.myOptions.odin = {
    enable = mkEnableOption "odin";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      odin
      ols

      clang
      lld
      pkg-config
      sdl3

      shaderc
      glslang
      spirv-tools
      vulkan-headers
      vulkan-loader
      vulkan-tools
      vulkan-validation-layers
    ];

    home.sessionVariables = {
      VK_LAYER_PATH = "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";
    };
  };
}
