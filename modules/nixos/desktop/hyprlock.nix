{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.lockscreen;
  username = config.myOptions.vars.username;
in {
  options.myOptions.lockscreen = {
    enable = mkEnableOption "Lockscreen" // {default = config.myOptions.vars.withGui;};
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.myOptions.lockscreen.enable = true;
  };
}
