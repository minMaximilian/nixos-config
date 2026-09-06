{
  config,
  localPackages,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.deadlockModManager;
in {
  options.myOptions.deadlockModManager = {
    enable = mkEnableOption "Deadlock Mod Manager";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [localPackages.deadlock-mod-manager];
  };
}
