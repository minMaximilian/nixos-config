{
  config,
  lib,
  pkgs,
  inputs ? {},
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.zig;
  hasZigOverlay = inputs ? zig-overlay;
  zigPkg =
    if hasZigOverlay
    then inputs.zig-overlay.packages.${pkgs.system}.master
    else pkgs.zig;
in {
  options.myOptions.zig = {
    enable = mkEnableOption "zig";
  };

  config = mkIf cfg.enable {
    home.packages = [
      zigPkg
    ];
  };
}
