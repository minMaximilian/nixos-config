{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.screenshot;
in {
  options.myOptions.screenshot = {
    enable =
      mkEnableOption "Screenshot tools for Wayland/Hyprland"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      grim
      slurp
      grimblast
      wl-clipboard
    ];

    home-manager.users.${config.myOptions.vars.username} = {
      xdg.userDirs.pictures = "${config.users.users.${config.myOptions.vars.username}.home}/Pictures";

      home.file."Pictures/Screenshots/.keep".text = "";
    };
  };
}
