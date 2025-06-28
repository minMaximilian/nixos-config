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
  palette = config.colorScheme.palette;
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
      # Vesktop is a Discord client with Vencord built-in
      vesktop
    ];

    environment.variables = {
      DISCORD_SKIP_HOST_UPDATE = "1";
    };

    home-manager.users.${config.myOptions.vars.username} = {
      xdg.desktopEntries.discord = {
        name = "Discord";
        exec = "vesktop --enable-features=UseOzonePlatform --ozone-platform=wayland";
        terminal = false;
        categories = ["Network" "InstantMessaging"];
        type = "Application";
      };

      xdg.configFile."vesktop/settings/settings.json".text = ''
        {
          "minimizeToTray": false,
          "discordBranch": "stable",
          "firstLaunch": false,
          "arRPC": false,
          "themeLinks": [],
          "useNativeTitlebar": false,
          "mods": {
            "vencord": {
              "enabled": true
            }
          }
        }
      '';

      xdg.configFile."Vencord/settings/quickCss.css".text = ''
        /* Use system terminal colors for Discord */
        .theme-dark {
          /* Base background colors */
          --background-primary: #${palette.base00};
          --background-secondary: #${palette.base01};
          --background-secondary-alt: #${palette.base01};
          --background-tertiary: #${palette.base00};
          --background-accent: #${palette.base02};
          --background-floating: #${palette.base00};
          --background-mobile-primary: #${palette.base00};
          --background-mobile-secondary: #${palette.base01};
          --channeltextarea-background: #${palette.base01};

          /* Hover and active states */
          --background-modifier-hover: #${palette.base01};
          --background-modifier-active: #${palette.base02};
          --background-modifier-selected: #${palette.base02};
          --background-modifier-accent: #${palette.base02};

          /* Text colors */
          --text-normal: #${palette.base05};
          --text-muted: #${palette.base04};
          --header-primary: #${palette.base05};
          --header-secondary: #${palette.base04};

          /* Interactive elements */
          --interactive-normal: #${palette.base05};
          --interactive-hover: #${palette.base06};
          --interactive-active: #${palette.base0D};
          --interactive-muted: #${palette.base03};

          /* Accent colors */
          --brand-experiment: #${palette.base0D};
        }

        /* Scrollbar */
        ::-webkit-scrollbar {
          width: 8px;
          height: 8px;
        }

        ::-webkit-scrollbar-track {
          background-color: transparent;
        }

        ::-webkit-scrollbar-thumb {
          background-color: #${palette.base02};
          border-radius: 4px;
        }

        ::-webkit-scrollbar-thumb:hover {
          background-color: #${palette.base03};
        }

        /* Custom styling for better terminal-like appearance */
        .markup-eYLPri {
          font-family: monospace, 'Courier New', Courier;
        }
      '';
    };
  };
}
