{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.myOptions.vars = {
    username = mkOption {
      type = types.str;
      default = "max";
      description = "The user's username";
    };

    sshKeys = mkOption {
      type = types.listOf types.str;
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFciJM84Q9pV8/QcDyO6fgHdPmYN9VgrMQhDY2hZ+a4p max@nixos"
      ];
      description = "SSH public keys for the user";
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
      default = "oxocarbon-dark";
      description = "The name of the base16 color scheme to use with stylix";
    };

    polarity = mkOption {
      type = types.enum ["light" "dark" "either"];
      default = "dark";
      description = "Whether to use light or dark mode";
    };
  };
}
