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

    home-manager.users.${config.myOptions.vars.username} = {config, ...}: let
      inherit (config.colorScheme) palette;
    in {
      imports = [inputs.nixcord.homeModules.nixcord];

      programs.nixcord = {
        enable = true;
        vesktop.enable = true;

        quickCss = ''
          @import url("https://mrtipson.github.io/DiscordCSS/css/base.css");
          @import url("https://mrtipson.github.io/DiscordCSS/css/base16.css");

          .theme-light, .theme-dark {
              --base00: #${palette.base00};
              --base01: #${palette.base01};
              --base02: #${palette.base02};
              --base03: #${palette.base03};
              --base04: #${palette.base04};
              --base05: #${palette.base05};
              --base06: #${palette.base06};
              --base07: #${palette.base07};
              --base08: #${palette.base08};
              --base09: #${palette.base09};
              --base0A: #${palette.base0A};
              --base0B: #${palette.base0B};
              --base0C: #${palette.base0C};
              --base0D: #${palette.base0D};
              --base0E: #${palette.base0E};
              --base0F: #${palette.base0F};
              --window-opacity: 1;
          }

          ::-webkit-scrollbar {
              width: 8px !important;
              height: 8px !important;
          }

          ::-webkit-scrollbar-track {
              background-color: transparent !important;
          }

          ::-webkit-scrollbar-thumb {
              background-color: var(--base02) !important;
              border-radius: 4px !important;
          }

          ::-webkit-scrollbar-thumb:hover {
              background-color: var(--base03) !important;
          }

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
