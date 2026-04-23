{
  lib,
  pkgs,
  config,
  inputs ? {},
  ...
}: let
  hasSpicetify = inputs ? spicetify-nix;
  cfg = config.myOptions.spotify;
in {
  imports =
    lib.optionals hasSpicetify
    [inputs.spicetify-nix.homeManagerModules.default];

  options.myOptions.spotify = {
    enable = lib.mkEnableOption "spotify";
  };

  config =
    if hasSpicetify
    then
      lib.mkIf cfg.enable {
        programs.spicetify = {
          enable = true;
          enabledExtensions = with inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system}.extensions; [
            fullAppDisplay
            shuffle
            adblockify
            hidePodcasts
          ];
        };
      }
    else {};
}
