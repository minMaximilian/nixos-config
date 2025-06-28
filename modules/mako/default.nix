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

    home-manager.users.${config.myOptions.vars.username} = {config, ...}: let
      inherit (config.colorScheme) palette;
    in {
      services.mako = {
        enable = true;
        settings = {
          font = "JetBrainsMono Nerd Font 10";
          width = 400;
          height = 150;
          margin = "10";
          padding = "15";
          border-size = 2;
          default-timeout = 5000;
          layer = "overlay";

          background-color = "#${palette.base00}";
          border-color = "#${palette.base0E}";
          text-color = "#${palette.base05}";
          progress-color = "over #${palette.base02}";
        };

        extraConfig = ''
          [urgency=high]
          ignore-timeout=1
          border-color=#${palette.base0B}
          background-color=#${palette.base01}

          [app-name=lightbulb]
          ignore-timeout=1
          background-color=#${palette.base01}
          border-color=#${palette.base0B}
        '';
      };
    };
  };
}
