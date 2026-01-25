{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = config.myOptions.theme;

  oxocarbon-light = {
    slug = "oxocarbon-light";
    scheme = "Oxocarbon Light";
    author = "shaunsingh/IBM";
    base00 = "f2f4f8";
    base01 = "dde1e6";
    base02 = "525252";
    base03 = "161616";
    base04 = "262626";
    base05 = "393939";
    base06 = "525252";
    base07 = "08bdba";
    base08 = "ff7eb6";
    base09 = "ee5396";
    base0A = "FF6F00";
    base0B = "0f62fe";
    base0C = "673AB7";
    base0D = "42be65";
    base0E = "be95ff";
    base0F = "37474F";
  };

  everforest-light = {
    slug = "everforest-light";
    scheme = "Everforest Light";
    author = "sainnhe (https://github.com/sainnhe/everforest)";
    base00 = "fdf6e3"; # bg0 - Default Background
    base01 = "f4f0d9"; # bg1 - Cursor Line Background
    base02 = "efebd4"; # bg2/bg_dim - Popup Menu Background
    base03 = "e6e2cc"; # bg3 - List Chars
    base04 = "a6b0a0"; # grey0 - Comments
    base05 = "5c6a72"; # fg - Default Foreground
    base06 = "4b565c"; # Darker foreground variant
    base07 = "3a4248"; # Darkest foreground
    base08 = "f85552"; # red - Errors
    base09 = "f57d26"; # orange - Constants
    base0A = "dfa000"; # yellow - Warnings
    base0B = "8da101"; # green - Strings
    base0C = "35a77c"; # aqua - Regex, Escape chars
    base0D = "3a94c5"; # blue - Functions
    base0E = "df69ba"; # purple - Keywords
    base0F = "e66868"; # statusline3 - Deprecated
  };

  customSchemes = {
    "oxocarbon-light" = oxocarbon-light;
    "everforest-light" = everforest-light;
  };

  schemeFile =
    if builtins.hasAttr cfg.colorScheme customSchemes
    then customSchemes.${cfg.colorScheme}
    else "${pkgs.base16-schemes}/share/themes/${cfg.colorScheme}.yaml";
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
      base16Scheme = schemeFile;

      cursor = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 16;
      };

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

      opacity = {
        applications = 0.95;
        terminal = 0.9;
        desktop = 0.9;
        popups = 0.9;
      };

      autoEnable = true;
    };

    home-manager.users.${config.myOptions.vars.username}.stylix.targets = {
      rofi.enable = false;
      hyprpaper.enable = lib.mkForce false;
      vesktop.enable = false;
    };
  };
}
