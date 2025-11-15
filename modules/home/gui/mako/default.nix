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
    environment.systemPackages = with pkgs; [
      mako
    ];

    home-manager.users.${config.myOptions.vars.username} = {
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
          # Font and colors handled by stylix
        };

        extraConfig = ''
          [urgency=high]
          ignore-timeout=1

          [app-name=lightbulb]
          ignore-timeout=1
        '';
      };
    };
  };
}
