{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.myOptions.vars = {
    username = mkOption {
      type = types.str;
      default = "max";
    };

    terminal = mkOption {
      type = types.str;
      default = "ghostty";
    };

    timezone = mkOption {
      type = types.str;
      default = "Europe/Dublin";
    };

    withGui = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable GUI applications and configurations. Set to true for desktop/laptop systems.";
    };
  };
}
