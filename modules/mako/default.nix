{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  cfg = config.myOptions.mako;
in {
  options.myOptions.mako = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Mako notification daemon";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.max = {
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
