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

  cfg = config.myOptions.obsidian;
in {
  options.myOptions.obsidian = {
    enable =
      mkEnableOption "Obsidian with custom configuration"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.myOptions.vars.username} = {
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
