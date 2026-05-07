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

  cfg = config.myOptions.opencode;
in {
  options.myOptions.opencode = {
    enable = mkEnableOption "opencode AI coding agent CLI";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      opencode
    ];
  };
}
