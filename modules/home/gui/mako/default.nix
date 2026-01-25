{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.mako;
in {
  options.myOptions.mako = {
    enable = mkEnableOption "Mako notification daemon";
  };

  config = mkIf cfg.enable {
    services.mako = {
      enable = true;
      settings = {
        width = 400;
        height = 150;
        margin = "10";
        padding = "15";
        border-size = 2;
        default-timeout = 5000;
        layer = "overlay";
      };

      extraConfig = ''
        [urgency=high]
        ignore-timeout=1

        [app-name=lightbulb]
        ignore-timeout=1
      '';
    };
  };
}
