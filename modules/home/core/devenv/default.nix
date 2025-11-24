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

  cfg = config.myOptions.devenv;
in {
  options.myOptions.devenv = {
    enable =
      mkEnableOption "devenv"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.devenv];
  };
}
