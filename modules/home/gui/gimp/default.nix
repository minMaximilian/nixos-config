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

  cfg = config.myOptions.gimp;
in {
  options.myOptions.gimp = {
    enable = mkEnableOption "GIMP image manipulation program";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.gimp];
  };
}
