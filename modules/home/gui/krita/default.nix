{
  config,
  lib,
  localPackages,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.krita;
in {
  options.myOptions.krita = {
    enable = mkEnableOption "Krita digital painting application";
  };

  config = mkIf cfg.enable {
    home.packages = [localPackages.krita];
  };
}
