{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.myOptions.vars = {
    username = mkOption {
      type = types.str;
      default = "max";
      description = "The user's username";
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
      description = "Whether to enable GUI applications";
    };

    colorScheme = mkOption {
      type = types.str;
      default = "catppuccin-mocha";
      description = "The name of the base16 color scheme to use with stylix";
    };
  };
}
