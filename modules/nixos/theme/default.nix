{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;

  cfg = config.myOptions.theme;
in {
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  options = {
    myOptions.theme = {
      enable =
        mkEnableOption "Theme configuration"
        // {
          default = config.myOptions.vars.withGui;
        };

      colorScheme = mkOption {
        type = types.str;
        default = config.myOptions.vars.colorScheme;
        description = "The color scheme to use";
      };

      wallpaper = mkOption {
        type = types.path;
        default = ../../../assets/wallpaper.png;
        description = "The wallpaper image to use";
      };
    };
  };

  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      image = cfg.wallpaper;
      polarity = config.myOptions.vars.polarity;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.colorScheme}.yaml";

      fonts = {
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };
        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };

      fonts.sizes = {
        applications = 12;
        terminal = 14;
        desktop = 12;
        popups = 12;
      };

      autoEnable = true;
    };

    home-manager.users.${config.myOptions.vars.username}.stylix.targets = {
      rofi.enable = false;
      hyprpaper.enable = lib.mkForce false;
      zen-browser.profileNames = [config.myOptions.vars.username];
      vesktop.enable = false;
    };
  };
}
