{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.amp;
in {
  options.myOptions.amp = {
    enable =
      mkEnableOption "amp CLI tool"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      amp
    ];
  };
}
