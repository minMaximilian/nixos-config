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

  cfg = config.myOptions.mako;
in {
  options.myOptions.mako = {
    enable =
      mkEnableOption "Mako notification daemon"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.myOptions.vars.username} = {
      services.mako = {
        enable = true;
        defaultTimeout = 5000;
        layer = "overlay";
        width = 300;
        height = 100;
        borderSize = 2;
        borderRadius = 5;
        backgroundColor = "#1e1e2e";
        textColor = "#cdd6f4";
        borderColor = "#89b4fa";
        progressColor = "over #313244";
        icons = true;
        maxIconSize = 64;
        sort = "-time";
      };
    };
  };
}
