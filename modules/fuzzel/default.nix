{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.fuzzel;
in {
  options.myOptions.fuzzel = {
    enable =
      mkEnableOption "fuzzel"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.myOptions.vars.username} = {
      config,
      osConfig,
      ...
    }: let
      inherit (config.colorScheme) palette;
    in {
      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            font = "monospace:size=10";
            terminal = "${pkgs.ghostty}/bin/ghostty";
            layer = "overlay";
            prompt = ">";
            width = 50;
            horizontal-pad = 20;
            vertical-pad = 10;
            inner-pad = 5;
            line-height = 20;
            fuzzel-show-animation = "none";
            fuzzel-hide-animation = "none";
          };

          border = {
            width = 2;
            radius = 5;
          };

          colors = {
            background = "${palette.base00}f2";
            text = "${palette.base05}ff";
            match = "${palette.base0A}ff";
            selection = "${palette.base03}ff";
            selection-text = "${palette.base05}ff";
            selection-match = "${palette.base0A}ff";
            border = "${palette.base0D}ff";
          };
        };
      };
    };
  };
}
