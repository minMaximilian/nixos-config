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
    home-manager.users.${config.myOptions.vars.username} = {config, ...}: let
      inherit (config.colorScheme) palette;
    in {
      imports = [inputs.spicetify-nix.homeManagerModules.default];

      programs.spicetify = {
        enable = true;

        theme = spicePkgs.themes.blossom;
        colorScheme = "custom";

        customColorScheme = {
          text = "#${palette.base05}";
          subtext = "#${palette.base04}";
          sidebar-text = "#${palette.base05}";
          main = "#${palette.base00}";
          sidebar = "#${palette.base01}";
          player = "#${palette.base01}";
          card = "#${palette.base01}";
          shadow = "#${palette.base00}";
          selected-row = "#${palette.base02}";
          button = "#${palette.base0E}";
          button-active = "#${palette.base0D}";
          button-disabled = "#${palette.base03}";
          tab-active = "#${palette.base0D}";
          notification = "#${palette.base0E}";
          notification-error = "#${palette.base08}";
          misc = "#${palette.base02}";
        };

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
