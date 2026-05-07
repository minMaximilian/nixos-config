{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.multimedia;
in {
  options.myOptions.multimedia = {
    enable = mkEnableOption "Multimedia tools (ffmpeg, etc.)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ffmpeg
    ];
  };
}
