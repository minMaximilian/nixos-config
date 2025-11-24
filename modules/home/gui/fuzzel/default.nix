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
        default = true;
      };
  };

  config = mkIf cfg.enable {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
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
      };
    };
  };
}
