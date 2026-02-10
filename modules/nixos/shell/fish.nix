{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.fish;
  username = config.myOptions.vars.username;
in {
  options.myOptions.fish = {
    enable = mkEnableOption "Fish Shell";
  };

  config = mkIf cfg.enable {
    users.users.${username}.shell = pkgs.fish;
    programs.fish.enable = true;

    home-manager.users.${username}.myOptions.fish.enable = true;
  };
}
