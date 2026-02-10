{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.teamspeak;
in {
  options.myOptions.teamspeak = {
    enable = mkEnableOption "TeamSpeak client";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.teamspeak6-client
    ];
  };
}
