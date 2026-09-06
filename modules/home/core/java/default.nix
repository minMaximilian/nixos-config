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
    home.file = {
      ".local/share/java/temurin-17".source = pkgs.temurin-bin-17;
      ".local/share/java/temurin-21".source = pkgs.temurin-bin-21;
    };

    home.packages = [
      pkgs.jdk17
    ];
  };
}
