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

  cfg = config.myOptions.discord;
in {
  options.myOptions.discord = {
    enable =
      mkEnableOption "Discord with custom configuration"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      discord
    ];

    environment.variables = {
      DISCORD_SKIP_HOST_UPDATE = "1";
    };

    home-manager.users.${config.myOptions.vars.username} = {
      xdg.desktopEntries.discord = {
        name = "Discord";
        exec = "discord --enable-features=UseOzonePlatform --ozone-platform=wayland";
        terminal = false;
        categories = ["Network" "InstantMessaging"];
        type = "Application";
      };
    };
  };
}
