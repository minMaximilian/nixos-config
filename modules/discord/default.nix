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

  cfg = config.myOptions.discord;
in {
  options.myOptions.discord = {
    enable =
      mkEnableOption "Discord with Wayland compatibility"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.myOptions.vars.username} = {
      home.packages = [
        (pkgs.discord.override {
          withOpenASAR = true;
          withVencord = true;
          nss = pkgs.nss_latest;
        })
      ];

      xdg = {
        enable = true;
        mimeApps = {
          enable = true;
          defaultApplications = {
            "x-scheme-handler/discord" = ["discord.desktop"];
          };
        };
      };
    };
  };
}
