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

  cfg = config.myOptions.golang;
in {
  options.myOptions.golang = {
    enable = mkEnableOption "golang";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.go
      pkgs.gopls
      pkgs.gotools
      pkgs.go-tools
    ];
  };
}
