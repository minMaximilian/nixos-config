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
      large = mkOption {
        type = types.int;
        default = 12;
        description = "Large padding in pixels";
      };
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
      };
    };
  };
}
