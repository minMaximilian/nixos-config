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

  cfg = config.myOptions.packwiz;
in {
  options.myOptions.packwiz = {
    enable = mkEnableOption "packwiz";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.packwiz
    ];
  };
}
