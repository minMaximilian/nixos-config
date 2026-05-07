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

  cfg = config.myOptions.ryujinx;
in {
  options.myOptions.ryujinx = {
    enable = mkEnableOption "Ryujinx (ryubing fork) Nintendo Switch emulator";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.ryubing];
  };
}
