{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  cfg = config.myOptions.discord;
in {
  options.myOptions.discord = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Discord with Wayland compatibility";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.max = {
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
