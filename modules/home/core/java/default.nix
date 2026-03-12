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

  cfg = config.myOptions.java;
in {
  options.myOptions.java = {
    enable = mkEnableOption "java";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.jdk17
    ];
  };
}
