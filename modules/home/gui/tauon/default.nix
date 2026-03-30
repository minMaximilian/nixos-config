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

  cfg = config.myOptions.tauon;
in {
  options.myOptions.tauon = {
    enable = mkEnableOption "Tauon Music Box";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.tauon];
  };
}
