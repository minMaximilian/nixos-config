{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.android;
  username = config.myOptions.vars.username;
in {
  options.myOptions.android = {
    enable = mkEnableOption "Android development (adb, emulator support)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.android-tools];

    users.users.${username}.extraGroups = [
      "kvm"
    ];
  };
}
