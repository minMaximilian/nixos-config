{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.amp;
in {
  options.myOptions.amp = {
    enable =
      mkEnableOption "amp CLI tool"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.myOptions.vars.username} = {
      home.packages = with pkgs; [
        nodejs_20  # Ensure Node.js is available for npx
      ];
    };
  };
} 