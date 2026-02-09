{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.komikku;
in {
  options.myOptions.komikku = {
    enable = mkEnableOption "Komikku manga reader";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.komikku
      pkgs.unrar # Required for CBR/RAR archive support
    ];
  };
}
