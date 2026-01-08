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

  cfg = config.myOptions.signal;
in {
  options.myOptions.signal = {
    enable =
      mkEnableOption "Signal messenger"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.signal-desktop];

    xdg.desktopEntries.signal-desktop = {
      name = "Messages";
      genericName = "Encrypted Messenger";
      exec = "signal-desktop %U";
      icon = "signal-desktop";
      terminal = false;
      categories = ["Network" "InstantMessaging"];
    };
  };
}
