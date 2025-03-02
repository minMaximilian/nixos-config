{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;

  cfg = config.myOptions.theme;
in {
  options = {
    myOptions.theme = {
      enable =
        mkEnableOption "Theme configuration"
        // {
          default = config.myOptions.vars.withGui;
        };

      colorScheme = mkOption {
        type = types.attrs;
        default = inputs.nix-colors.colorSchemes.catppuccin-mocha;
        description = "The color scheme to use";
      };
    };

    # NixOS-level colorScheme option
    colorScheme = mkOption {
      type = types.attrs;
      internal = true;
      visible = false;
    };
  };

  config = mkIf cfg.enable {
    colorScheme = cfg.colorScheme;

    home-manager.users.${config.myOptions.vars.username} = {config, ...}: {
      imports = [
        inputs.nix-colors.homeManagerModules.default
      ];

      inherit (cfg) colorScheme;
    };
  };
}
