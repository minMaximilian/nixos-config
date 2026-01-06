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

  cfg = config.myOptions.golang;
in {
  options.myOptions.golang = {
    enable = mkEnableOption "golang";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      go
      gopls
      gotools
      go-tools
    ];
  };
}
