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

  cfg = config.myOptions.discord;
in {
  options.myOptions.discord = {
    enable =
      mkEnableOption "Discord with Wayland compatibility"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.myOptions.vars.username} = {
      home.packages = [
        (pkgs.discord.override {
          withOpenASAR = true;
          withVencord = true;
          nss = pkgs.nss_latest;
        })
      ];

      # Add Discord-specific environment variables
      home.sessionVariables = {
        DISCORD_SKIP_FRAME_BUFFER_RESIZE = "1";
        DISCORD_WAYLAND_SCALING = "1";
      };

      xdg = {
        enable = true;
        # Add desktop entry with Wayland flags
        desktopEntries.discord = {
          name = "Discord";
          exec = "discord --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland";
          icon = "discord";
          terminal = false;
          type = "Application";
          categories = ["Network" "InstantMessaging"];
          mimeType = ["x-scheme-handler/discord"];
        };
        mimeApps = {
          enable = true;
          defaultApplications = {
            "x-scheme-handler/discord" = ["discord.desktop"];
          };
        };
      };
    };
  };
}
