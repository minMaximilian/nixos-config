{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  cfg = config.myOptions.fuzzel;
in {
  options.myOptions.fuzzel = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Fuzzel Application Launcher";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.max = {
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
