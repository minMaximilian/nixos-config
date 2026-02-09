{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.clipboard;
in {
  options.myOptions.clipboard = {
    enable =
      mkEnableOption "Clipboard manager (cliphist)"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      cliphist
      wtype
    ];
  };
}
