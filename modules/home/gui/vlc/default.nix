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

  cfg = config.myOptions.vlc;
in {
  options.myOptions.vlc = {
    enable = mkEnableOption "VLC media player";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.vlc];
  };
}
