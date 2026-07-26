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

  cfg = config.myOptions.xournalpp;
in {
  options.myOptions.xournalpp = {
    enable = mkEnableOption "Xournal++ PDF annotation tool";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.xournalpp];
  };
}
