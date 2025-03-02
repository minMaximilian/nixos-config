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

  cfg = config.myOptions.btop;
in {
  options.myOptions.btop = {
    enable =
      mkEnableOption "btop system monitor"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.myOptions.vars.username} = {pkgs, ...}: {
      programs.btop = {
        enable = true;
        settings = {
          vim_keys = true;
          rounded_corners = true;
          graph_symbol = "braille";
          update_ms = 1000;
          color_theme = "Default";
        };
      };
    };
  };
}
