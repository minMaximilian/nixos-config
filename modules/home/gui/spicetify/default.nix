{
  lib,
  pkgs,
  config,
  inputs ? {},
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  hasSpicetify = inputs ? spicetify-nix;
  spicePkgs =
    if hasSpicetify
    then inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system}
    else null;

  cfg = config.myOptions.spotify;
in {
  imports = lib.optionals hasSpicetify [inputs.spicetify-nix.homeManagerModules.default];

  options.myOptions.spotify = {
    enable = mkEnableOption "spotify";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = hasSpicetify;
        message = "myOptions.spotify requires inputs.spicetify-nix to be available";
      }
    ];

    programs.spicetify = lib.mkIf hasSpicetify {
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
