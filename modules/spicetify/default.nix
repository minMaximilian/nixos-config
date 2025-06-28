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
  imports = [inputs.spicetify-nix.nixosModules.default];

  options.myOptions.spotify = {
    enable =
      mkEnableOption "spotify"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.myOptions.vars.username} = {
      imports = [inputs.spicetify-nix.homeManagerModules.default];

      programs.spicetify = {
        enable = true;

        # Let stylix handle theming

        enabledExtensions = with spicePkgs.extensions; [
          fullAppDisplay
          shuffle
          adblockify
          hidePodcasts
        ];
      };
    };
  };
}
