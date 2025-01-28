{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  cfg = config.myOptions.greetd;
in {
  options.myOptions.greetd = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Greetd display manager";
    };
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
          user = "greeter";
        };
      };
    };

    programs.uwsm = {
      enable = true;
      waylandCompositors.hyprland = {
        binPath = "/run/current-system/sw/bin/Hyprland";
        prettyName = "Hyprland";
        comment = "Hyprland managed by UWSM";
      };
    };

    environment.systemPackages = with pkgs; [
      greetd.tuigreet
    ];
  };
}
