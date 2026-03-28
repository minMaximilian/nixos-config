{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.quickshellPam;
in {
  options.myOptions.quickshellPam = {
    enable =
      mkEnableOption "Quickshell PAM service for lockscreen"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    security.pam.services.quickshell = {};
  };
}
