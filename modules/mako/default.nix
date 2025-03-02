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
        font = "JetBrainsMono Nerd Font 10";
        width = 400;
        height = 150;
        margin = "10";
        padding = "15";
        borderSize = 2;
        defaultTimeout = 5000;
        layer = "overlay";

        backgroundColor = "#${palette.base00}";
        borderColor = "#${palette.base0E}";
        textColor = "#${palette.base05}";
        progressColor = "over #${palette.base02}";

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
