{
  config,
  lib,
  inputs ? {},
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.discord;
  hasStylix = config.lib.theme.hasStylix or false;
  hasNixcord = inputs ? nixcord;
in {
  imports = lib.optionals hasNixcord [
    inputs.nixcord.homeModules.nixcord
  ];

  options.myOptions.discord = {
    enable = mkEnableOption "Discord via Nixcord";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = hasNixcord;
        message = "myOptions.discord requires inputs.nixcord to be available";
      }
    ];

    stylix.targets.nixcord.enable = false;

    programs.nixcord = lib.mkIf hasNixcord ({
        enable = true;
        discord.enable = false;
        vesktop.enable = true;
        config.useQuickCss = true;
        config.plugins = {
          ClearURLs.enable = true;
          anonymiseFileNames.enable = true;
          noBlockedMessages.enable = true;
          betterSessions.enable = true;
          crashHandler.enable = true;
          permissionsViewer.enable = true;
          relationshipNotifier.enable = true;
          validUser.enable = true;
          voiceDownload.enable = true;
          webContextMenus.enable = true;
          fixSpotifyEmbeds.enable = true;
          webScreenShareFixes.enable = true;
          unsuppressEmbeds.enable = true;
          volumeBooster.enable = true;
        };
      }
      // lib.optionalAttrs hasStylix (let
        colors = config.lib.stylix.colors;
        fonts = config.stylix.fonts;
      in {
        quickCss = ''
          @import url('https://raw.githubusercontent.com/imbypass/base16-discord/refs/heads/main/base16.css');

          :root {
            --font: "${fonts.sansSerif.name}";
            --font-code: "${fonts.monospace.name}";

            --base00: #${colors.base00};
            --base01: #${colors.base01};
            --base02: #${colors.base02};
            --base03: #${colors.base03};
            --base04: #${colors.base04};
            --base05: #${colors.base05};
            --base06: #${colors.base06};
            --base07: #${colors.base07};
            --base08: #${colors.base08};
            --base09: #${colors.base09};
            --base0A: #${colors.base0A};
            --base0B: #${colors.base0B};
            --base0C: #${colors.base0C};
            --base0D: #${colors.base0D};
            --base0E: #${colors.base0E};
            --base0F: #${colors.base0F};
          }
        '';
      }));
  };
}
