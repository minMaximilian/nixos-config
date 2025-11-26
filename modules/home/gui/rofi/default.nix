{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.rofi;
in {
  imports = [
    ./volume-control.nix
  ];

  options.myOptions.rofi = {
    enable =
      mkEnableOption "rofi"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      terminal = "${pkgs.ghostty}/bin/ghostty";
      extraConfig = {
        modi = "run,drun,window";
        icon-theme = "Papirus";
        show-icons = true;
        drun-display-format = "{name} [<span weight='light' size='small'><i>({generic})</i></span>]";
        disable-history = false;
        display-drun = "Applications";
        display-run = "Commands";
        display-window = "Windows";
        display-Network = "Networks";
        sidebar-mode = true;
      };
    };
  };
}
