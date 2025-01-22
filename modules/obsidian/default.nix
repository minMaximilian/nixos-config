{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  cfg = config.myOptions.obsidian;
in {
  options.myOptions.obsidian = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Obsidian with custom configuration";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.max = {
      home.packages = [pkgs.obsidian];

      xdg = {
        enable = true;
        mimeApps = {
          enable = true;
          defaultApplications = {
            "x-scheme-handler/obsidian" = ["obsidian.desktop"];
          };
        };
      };
    };
  };
}
