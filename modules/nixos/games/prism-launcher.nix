{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.prismLauncher;
  username = config.myOptions.vars.username;
in {
  options.myOptions.prismLauncher = {
    enable = mkEnableOption "Prism Launcher" // {default = config.myOptions.vars.withGui;};
  };

  config = mkIf cfg.enable {
    users.users.${username}.extraGroups = ["video"];

    programs.java = {
      enable = true;
      package = pkgs.temurin-bin-21;
    };

    home-manager.users.${username}.myOptions.prismLauncher.enable = true;
  };
}
