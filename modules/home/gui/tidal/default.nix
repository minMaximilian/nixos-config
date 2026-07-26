{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.tidal;
  tidal = pkgs.writeShellScriptBin "tidal" ''
    exec ${lib.getExe pkgs.google-chrome} \
      --app=https://listen.tidal.com \
      --ozone-platform=wayland \
      --class=tidal \
      --no-first-run \
      --user-data-dir="$HOME/.config/tidal" \
      "$@"
  '';
in {
  options.myOptions.tidal = {
    enable = mkEnableOption "TIDAL client";
  };

  config = mkIf cfg.enable {
    home.packages = [tidal];

    xdg.desktopEntries.tidal = {
      name = "TIDAL";
      genericName = "Music Player";
      exec = lib.getExe tidal;
      icon = "audio-x-generic";
      terminal = false;
      categories = ["Audio" "Music" "Player" "AudioVideo"];
    };
  };
}
