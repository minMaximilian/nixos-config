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

  cfg = config.myOptions.qobuzPlayer;
in {
  options.myOptions.qobuzPlayer = {
    enable = mkEnableOption "QBZ native Qobuz client";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.qbz];
  };
}
