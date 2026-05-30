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

  cfg = config.myOptions.blockbench;
in {
  options.myOptions.blockbench = {
    enable = mkEnableOption "Blockbench low-poly 3D model editor";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.blockbench];
  };
}
