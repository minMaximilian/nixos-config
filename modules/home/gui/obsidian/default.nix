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
        default = true;
      };
  };

  config = mkIf cfg.enable {
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
}
