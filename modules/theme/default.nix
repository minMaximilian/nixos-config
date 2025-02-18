{
  lib,
  pkgs,
  config,
  inputs,
  self,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.myOptions.theme;
in {
  options = {
    myOptions.theme = {
      enable =
        mkEnableOption ""
        // {
          default = config.myOptions.vars.withGui;
        };

      colorScheme = mkOption {
        type = types.anything;
        default = inputs.nix-colors.colorSchemes.${config.myOptions.vars.colorScheme};
      };
    };

    # NixOS-level colorScheme option
    colorScheme = mkOption {
      type = types.anything;
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
