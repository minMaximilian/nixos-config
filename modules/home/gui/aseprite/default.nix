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

  cfg = config.myOptions.aseprite;
in {
  options.myOptions.aseprite = {
    enable = mkEnableOption "Aseprite pixel art editor";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.aseprite];
  };
}
