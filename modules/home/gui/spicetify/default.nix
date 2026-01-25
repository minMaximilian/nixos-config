{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  cfg = config.myOptions.spotify;
in {
  imports = [inputs.spicetify-nix.homeManagerModules.default];

  options.myOptions.spotify = {
    enable = mkEnableOption "spotify";
  };

  config = mkIf cfg.enable {
    programs.spicetify = {
      enable = true;

      enabledExtensions = with spicePkgs.extensions; [
        fullAppDisplay
        shuffle
        adblockify
        hidePodcasts
      ];
    };
  };
}
