{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  cfg = config.myOptions.hypridle;
in {
  options.myOptions.hypridle = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Hypridle for idle management";
    };
  };

  config = mkIf cfg.enable {
    services.hypridle = {
      enable = true;
    };

    home-manager.users.max = {
      services.hypridle = {
        enable = true;
      };
    };
  };
}
