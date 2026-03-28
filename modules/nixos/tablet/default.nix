{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.tablet;
in {
  options.myOptions.tablet = {
    enable = mkEnableOption "Drawing tablet support (OpenTabletDriver)";
  };

  config = mkIf cfg.enable {
    hardware.opentabletdriver.enable = true;
    hardware.uinput.enable = true;
    boot.kernelModules = ["uinput"];
  };
}
