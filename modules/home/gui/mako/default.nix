{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.mako;
  theme = config.myOptions.theme;
  themeLib = config.lib.theme;
  hasStylix = config.lib.theme.hasStylix or false;
in {
  options.myOptions.mako = {
    enable = mkEnableOption "Mako notification daemon";
  };

  config = mkIf cfg.enable {
    # Disable Stylix auto-styling so we can match waybar exactly
    stylix.targets.mako.enable = false;

    services.mako = {
      enable = true;
      settings = mkIf hasStylix (let
        colors = config.lib.stylix.colors;
      in {
        # Use shared theme values
        width = 400;
        height = 150;
        margin = toString theme.margin;
        padding = toString theme.padding.medium;
        border-size = theme.borderWidth;
        border-radius = theme.borderRadius;
        default-timeout = 5000;
        layer = "overlay";

        # Colors matching waybar (base01 background with configured opacity)
        background-color = "#${colors.base01}${themeLib.opacityToHex theme.opacity.background}";
        text-color = "#${colors.base05}";
        border-color = "#${colors.base0D}";
        progress-color = "over #${colors.base0D}";

        # Urgency overrides
        "[urgency=low]" = {
          border-color = "#${colors.base03}";
        };

        "[urgency=high]" = {
          border-color = "#${colors.base08}";
          ignore-timeout = 1;
        };

        "[app-name=lightbulb]" = {
          ignore-timeout = 1;
        };
      });
    };
  };
}
