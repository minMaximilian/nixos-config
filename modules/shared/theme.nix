{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkOption
    types
    ;
in {
  options.myOptions.theme = {
    # Border styling
    borderRadius = mkOption {
      type = types.int;
      default = 10;
      description = "Border radius in pixels for UI elements";
    };

    borderWidth = mkOption {
      type = types.int;
      default = 2;
      description = "Border width in pixels";
    };

    # Spacing
    padding = {
      small = mkOption {
        type = types.int;
        default = 4;
        description = "Small padding in pixels";
      };
      medium = mkOption {
        type = types.int;
        default = 8;
        description = "Medium padding in pixels";
      };
      large = mkOption {
        type = types.int;
        default = 12;
        description = "Large padding in pixels";
      };
    };

    margin = mkOption {
      type = types.int;
      default = 6;
      description = "Default margin in pixels";
    };

    # Opacity (0.0 - 1.0)
    opacity = {
      background = mkOption {
        type = types.float;
        default = 0.9;
        description = "Background opacity for panels/popups";
      };
      inactive = mkOption {
        type = types.float;
        default = 0.8;
        description = "Opacity for inactive elements";
      };
    };

    # Fonts
    fonts = {
      mono = mkOption {
        type = types.str;
        default = "CaskaydiaCove Nerd Font";
        description = "Monospace font family";
      };
      size = {
        small = mkOption {
          type = types.int;
          default = 12;
          description = "Small font size";
        };
        medium = mkOption {
          type = types.int;
          default = 14;
          description = "Medium font size";
        };
        large = mkOption {
          type = types.int;
          default = 16;
          description = "Large font size";
        };
      };
    };
  };

  # Helper functions for common conversions
  config.lib.theme = let
    theme = config.myOptions.theme;
  in {
    # Get opacity as hex suffix (e.g., 0.9 -> "E6")
    opacityToHex = opacity: let
      hexValue = builtins.floor (opacity * 255);
      toHex = n: let
        hexChars = "0123456789ABCDEF";
        high = n / 16;
        low = n - (high * 16);
      in
        builtins.substring high 1 hexChars + builtins.substring low 1 hexChars;
    in
      toHex hexValue;

    # Common CSS values
    css = {
      borderRadius = "${toString theme.borderRadius}px";
      borderWidth = "${toString theme.borderWidth}px";
      margin = "${toString theme.margin}px";
      paddingSmall = "${toString theme.padding.small}px";
      paddingMedium = "${toString theme.padding.medium}px";
      paddingLarge = "${toString theme.padding.large}px";
      fontMono = theme.fonts.mono;
      fontSizeSmall = "${toString theme.fonts.size.small}px";
      fontSizeMedium = "${toString theme.fonts.size.medium}px";
      fontSizeLarge = "${toString theme.fonts.size.large}px";
    };

    # Raw values for non-CSS contexts
    raw = theme;
  };
}
