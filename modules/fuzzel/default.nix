{
  config,
  pkgs,
  lib,
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
      mkEnableOption "Fuzzel Application Launcher"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.myOptions.vars.username} = {
      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            font = "monospace:size=10";
            terminal = "${pkgs.ghostty}/bin/ghostty";
            layer = "overlay";
          };
        };
      };
    };
  };
}
