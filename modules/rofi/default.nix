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
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.myOptions.vars.username} = {
      programs.rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
        terminal = "${pkgs.ghostty}/bin/ghostty";
        # Font and theme handled by stylix
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
  };
}
