{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.qbittorrent;
in {
  options.myOptions.qbittorrent = {
    enable = mkEnableOption "qBittorrent torrent client";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.qbittorrent];
  };
}
