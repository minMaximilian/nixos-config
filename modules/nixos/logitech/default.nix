{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
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

    home-manager.users.${config.myOptions.vars.username} = {
      xdg.configFile."autostart/solaar.desktop".text = ''
        [Desktop Entry]
        Name=Solaar
        Comment=Logitech device manager
        Exec=${pkgs.solaar}/bin/solaar --window=hide
        Icon=solaar
        Terminal=false
        Type=Application
        Categories=Utility;
        StartupNotify=false
      '';
    };
  };
}
