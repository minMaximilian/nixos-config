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
    environment.variables = {
      DISCORD_SKIP_HOST_UPDATE = "1";
    };

    home-manager.users.${config.myOptions.vars.username} = {
      imports = [inputs.nixcord.homeModules.nixcord];

      programs.nixcord = {
        enable = true;
        vesktop.enable = true;

        # Let stylix handle Discord theming automatically
        quickCss = ''
          code, pre, .hljs {
              font-family: 'JetBrains Mono', 'Fira Code', 'Consolas', monospace !important;
          }
        '';

        config = {
          useQuickCss = true;
          frameless = false;
          plugins = {
            youtubeAdblock.enable = true;
            clearURLs.enable = true;
            whoReacted.enable = true;
            messageLogger.enable = true;
            invisibleChat.enable = true;
            serverInfo.enable = true;
            voiceMessages.enable = true;
          };
        };
      };

      # Desktop entry with proper Wayland support and hardware acceleration
      xdg.desktopEntries.discord = {
        name = "Discord";
        exec = "vesktop --enable-features=UseOzonePlatform,VaapiVideoDecoder,VaapiVideoEncoder --ozone-platform=wayland";
        terminal = false;
        categories = ["Network" "InstantMessaging"];
        type = "Application";
      };
    };
  };
}
