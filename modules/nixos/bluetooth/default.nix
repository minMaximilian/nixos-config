{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.bluetooth;
in {
  options.myOptions.bluetooth = {
    enable =
      mkEnableOption "Bluetooth support"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          # Enable A2DP sink
          Enable = "Source,Sink,Media,Socket";
          # Required for DualSense/DualShock controllers over Bluetooth
          ClassicBondedOnly = false;
          ControllerMode = "dual";
        };
      };
      input = {
        General = {
          # Allow Bluetooth HID devices (controllers) without classic bonding
          ClassicBondedOnly = false;
          UserspaceHID = false;
          IdleTimeout = 0;
        };
      };
    };

    # Install blueman for GUI management
    services.blueman.enable = true;

    # Add necessary packages
    environment.systemPackages = with pkgs; [
      bluez
      bluez-tools
    ];
  };
}
