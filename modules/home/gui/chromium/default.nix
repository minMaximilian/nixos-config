{
  config,
  lib,
  ...
}: let
  cfg = config.myOptions.chromium;
in {
  options.myOptions.chromium = {
    enable = lib.mkEnableOption "Chromium browser";
  };

  config = lib.mkIf cfg.enable {
    programs.chromium.enable = true;
  };
}
