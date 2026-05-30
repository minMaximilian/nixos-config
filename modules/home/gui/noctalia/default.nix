{
  config,
  lib,
  inputs ? {},
  self ? null,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.myOptions.noctalia;
  hasNoctalia = inputs ? noctalia;
  hasStylix = config.lib.theme.hasStylix or false;
  hasSelf = self != null;
  wallpaperPath = "${self}/assets/wallpaper.png";
  wallpaperDirectory = "${self}/assets";
  mode =
    if config.myOptions.vars.polarity == "either"
    then "auto"
    else config.myOptions.vars.polarity;
  colors = config.lib.stylix.colors;
  hex = name: "#${colors.${name}}";
  terminalPalette = {
    normal = {
      black = hex "base00";
      red = hex "base08";
      green = hex "base0B";
      yellow = hex "base0A";
      blue = hex "base0D";
      magenta = hex "base0E";
      cyan = hex "base0C";
      white = hex "base05";
    };
    bright = {
      black = hex "base03";
      red = hex "base08";
      green = hex "base0B";
      yellow = hex "base0A";
      blue = hex "base0D";
      magenta = hex "base0E";
      cyan = hex "base0C";
      white = hex "base07";
    };
    foreground = hex "base05";
    background = hex "base00";
    cursor = hex "base05";
    cursorText = hex "base00";
    selectionFg = hex "base05";
    selectionBg = hex "base02";
  };
  stylixPalette = {
    primary = hex "base0D";
    onPrimary = hex "base00";
    secondary = hex "base0C";
    onSecondary = hex "base00";
    tertiary = hex "base0E";
    onTertiary = hex "base00";
    error = hex "base08";
    onError = hex "base00";
    surface = hex "base00";
    onSurface = hex "base05";
    surfaceVariant = hex "base01";
    onSurfaceVariant = hex "base04";
    outline = hex "base03";
    shadow = "#000000";
    hover = hex "base02";
    onHover = hex "base05";
    terminal = terminalPalette;
  };
in {
  imports = lib.optionals hasNoctalia [
    inputs.noctalia.homeModules.default
  ];

  options.myOptions.noctalia = {
    enable = mkEnableOption "Noctalia desktop shell";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = hasNoctalia;
        message = "myOptions.noctalia requires inputs.noctalia";
      }
    ];

    programs.noctalia =
      {
        enable = true;
        systemd.enable = true;
      }
      // lib.optionalAttrs hasStylix {
        settings =
          {
            theme = {
              mode = mode;
              source = "custom";
              custom_palette = "stylix";
            };

            bar.main = {
              position = "top";
              reserve_space = true;
              margin_ends = 0;
              margin_edge = 0;
              padding = 12;
              widget_spacing = 8;

              monitor."DP-3" = {
                match = "DP-3";
                padding = 24;
                widget_spacing = 12;
                scale = 1.05;
              };
            };
          }
          // lib.optionalAttrs hasSelf {
            wallpaper = {
              enabled = true;
              fill_mode = "crop";
              directory = wallpaperDirectory;
              default.path = wallpaperPath;
            };
          };

        customPalettes.stylix = {
          dark = stylixPalette;
          light = stylixPalette;
        };
      };
  };
}
