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

  cfg = config.myOptions.logitech;
in {
  options.myOptions.logitech = {
    enable = mkEnableOption "Logitech device support";
  };

  config = mkIf cfg.enable {
    hardware.logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    services.udev.extraRules = ''
      # Allow users in the wheel group to access /dev/uinput for Solaar rules
      KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
    '';
  };
}
