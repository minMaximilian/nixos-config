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
      config,
      osConfig,
      ...
    }: let
      theme = import ./style.nix {inherit config;};
    in {
      programs.rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
        terminal = "${pkgs.ghostty}/bin/ghostty";
        font = "JetBrainsMono Nerd Font 12";
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

      # Write the theme directly to a file instead of using the theme option
      xdg.configFile."rofi/config.rasi".text = theme;
    };
  };
}
