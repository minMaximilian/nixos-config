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

  cfg = config.myOptions.protonmail;
in {
  options.myOptions.protonmail = {
    enable =
      mkEnableOption "Proton Mail desktop client"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.protonmail-desktop];
  };
}
