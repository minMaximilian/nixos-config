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
  imports = [inputs.nixcord.homeModules.nixcord];

  options.myOptions.discord = {
    enable =
      mkEnableOption "Discord with custom configuration"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      DISCORD_SKIP_HOST_UPDATE = "1";
    };

    programs.nixcord = {
      enable = true;
      vesktop.enable = true;

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

    xdg.desktopEntries.discord = {
      name = "Discord";
      exec = "vesktop --enable-features=UseOzonePlatform,VaapiVideoDecoder,VaapiVideoEncoder --ozone-platform=wayland";
      terminal = false;
      categories = ["Network" "InstantMessaging"];
      type = "Application";
    };
  };
}
