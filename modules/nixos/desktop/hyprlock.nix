{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.hyprlock;
  username = config.myOptions.vars.username;
in {
  options.myOptions.hyprlock = {
    enable = mkEnableOption "Hyprlock" // {default = config.myOptions.vars.withGui;};
  };

  config = mkIf cfg.enable {
    programs.hyprlock.enable = true;

    home-manager.users.${username}.myOptions.hyprlock.enable = true;
  };
}
